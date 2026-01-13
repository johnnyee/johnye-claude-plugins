# Ralph Loop Stop Hook (PowerShell version for Windows)
# Prevents session exit when a ralph-loop is active
# Feeds Claude's output back as input to continue the loop
#
# [2026-01-13] 修复会话串扰bug：
# - 从 transcript 中提取当前会话的 loop_id
# - 只匹配对应的状态文件 ralph-loop-{loop_id}.local.md
# - 不同会话的循环完全隔离，互不干扰

# Suppress ALL errors to prevent stderr output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
$DebugPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# Redirect all error streams to null
trap { continue }

# Read hook input from stdin
$HOOK_INPUT = ""
try {
    $HOOK_INPUT = @($input) -join ""
    if ([string]::IsNullOrWhiteSpace($HOOK_INPUT)) {
        $HOOK_INPUT = [Console]::In.ReadToEnd()
    }
} catch { }

if ([string]::IsNullOrWhiteSpace($HOOK_INPUT)) {
    $HOOK_INPUT = "{}"
}

# Get transcript path from hook input
try {
    $hookData = $HOOK_INPUT | ConvertFrom-Json -ErrorAction SilentlyContinue
    $TRANSCRIPT_PATH = $hookData.transcript_path
} catch {
    exit 0
}

# Check if transcript path is valid
if ([string]::IsNullOrWhiteSpace($TRANSCRIPT_PATH) -or -not (Test-Path $TRANSCRIPT_PATH -ErrorAction SilentlyContinue)) {
    exit 0
}

# ============================================================================
# [2026-01-13] 核心修复：从 transcript 提取 loop_id，匹配正确的状态文件
# ============================================================================

# 从 transcript 中提取最后一个 loop_id
# setup-ralph-loop.sh 输出格式: "Loop ID: xxxxxxxx"
function Get-LoopIdFromTranscript {
    param([string]$TranscriptPath)

    try {
        $transcriptContent = Get-Content $TranscriptPath -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrEmpty($transcriptContent)) {
            return $null
        }

        # 匹配所有 "Loop ID: xxxxxxxx" 模式，取最后一个
        $loopIdMatches = [regex]::Matches($transcriptContent, 'Loop ID:\s*([a-fA-F0-9]{8})')

        if ($loopIdMatches.Count -gt 0) {
            # 返回最后一个匹配的 loop_id
            return $loopIdMatches[$loopIdMatches.Count - 1].Groups[1].Value.ToLower()
        }

        return $null
    } catch {
        return $null
    }
}

# 获取当前会话的 loop_id
$LOOP_ID = Get-LoopIdFromTranscript -TranscriptPath $TRANSCRIPT_PATH

if ([string]::IsNullOrEmpty($LOOP_ID)) {
    # 当前会话没有启动过 ralph-loop，正常退出
    exit 0
}

# 构建状态文件路径
$RALPH_STATE_FILE = ".claude/ralph-loop-$LOOP_ID.local.md"

if (-not (Test-Path $RALPH_STATE_FILE)) {
    # 状态文件不存在（可能已被取消或完成），正常退出
    exit 0
}

# ============================================================================
# 以下逻辑与原版相同，但使用会话特定的状态文件
# ============================================================================

# Read state file content
try {
    $stateContent = Get-Content $RALPH_STATE_FILE -Raw -ErrorAction SilentlyContinue
} catch {
    exit 0
}

if ([string]::IsNullOrWhiteSpace($stateContent)) {
    exit 0
}

# Parse YAML frontmatter
$frontmatterMatch = [regex]::Match($stateContent, "(?s)^---\r?\n(.*?)\r?\n---")
if (-not $frontmatterMatch.Success) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

$frontmatter = $frontmatterMatch.Groups[1].Value

# Extract values
$iterationMatch = [regex]::Match($frontmatter, "iteration:\s*(\d+)")
$maxIterationsMatch = [regex]::Match($frontmatter, "max_iterations:\s*(\d+)")
$completionPromiseMatch = [regex]::Match($frontmatter, 'completion_promise:\s*"?([^"\r\n]*)"?')

$ITERATION = if ($iterationMatch.Success) { [int]$iterationMatch.Groups[1].Value } else { 0 }
$MAX_ITERATIONS = if ($maxIterationsMatch.Success) { [int]$maxIterationsMatch.Groups[1].Value } else { 0 }
$COMPLETION_PROMISE = if ($completionPromiseMatch.Success) { $completionPromiseMatch.Groups[1].Value.Trim('"') } else { "null" }

# Validate numeric fields
if ($ITERATION -lt 0) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Check if max iterations reached
if ($MAX_ITERATIONS -gt 0 -and $ITERATION -ge $MAX_ITERATIONS) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Read last assistant message from transcript
try {
    $transcriptContent = Get-Content $TRANSCRIPT_PATH -Raw -ErrorAction SilentlyContinue
} catch {
    exit 0
}

$assistantMessages = [regex]::Matches($transcriptContent, '"role":"assistant".*')

if ($assistantMessages.Count -eq 0) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Find the complete JSON line containing the last assistant message
$lines = $transcriptContent -split "`n"
$LAST_LINE = ""
foreach ($line in $lines) {
    if ($line -match '"role":"assistant"') {
        $LAST_LINE = $line
    }
}

if ([string]::IsNullOrEmpty($LAST_LINE)) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Parse JSON and extract text content
try {
    $messageData = $LAST_LINE | ConvertFrom-Json -ErrorAction SilentlyContinue
    $textContents = $messageData.message.content | Where-Object { $_.type -eq "text" } | ForEach-Object { $_.text }
    $LAST_OUTPUT = $textContents -join "`n"
} catch {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

if ([string]::IsNullOrEmpty($LAST_OUTPUT)) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Check for completion promise
if ($COMPLETION_PROMISE -ne "null" -and -not [string]::IsNullOrEmpty($COMPLETION_PROMISE)) {
    $promiseMatch = [regex]::Match($LAST_OUTPUT, "<promise>(.*?)</promise>", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($promiseMatch.Success) {
        $PROMISE_TEXT = $promiseMatch.Groups[1].Value.Trim()
        if ($PROMISE_TEXT -eq $COMPLETION_PROMISE) {
            Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
            exit 0
        }
    }
}

# Not complete - continue loop with SAME PROMPT
$NEXT_ITERATION = $ITERATION + 1

# Extract prompt (everything after the closing ---)
$promptMatch = [regex]::Match($stateContent, "(?s)^---\r?\n.*?\r?\n---\r?\n(.*)$")
$PROMPT_TEXT = if ($promptMatch.Success) { $promptMatch.Groups[1].Value.Trim() } else { "" }

if ([string]::IsNullOrEmpty($PROMPT_TEXT)) {
    Remove-Item $RALPH_STATE_FILE -Force -ErrorAction SilentlyContinue 2>$null
    exit 0
}

# Update iteration in state file
$newContent = $stateContent -replace "iteration:\s*\d+", "iteration: $NEXT_ITERATION"
Set-Content -Path $RALPH_STATE_FILE -Value $newContent -NoNewline -ErrorAction SilentlyContinue 2>$null

# Build system message (包含 loop_id 以便调试)
if ($COMPLETION_PROMISE -ne "null" -and -not [string]::IsNullOrEmpty($COMPLETION_PROMISE)) {
    $SYSTEM_MSG = "Ralph iteration $NEXT_ITERATION [loop:$LOOP_ID] | To stop: output <promise>$COMPLETION_PROMISE</promise> (ONLY when statement is TRUE - do not lie to exit!)"
} else {
    $SYSTEM_MSG = "Ralph iteration $NEXT_ITERATION [loop:$LOOP_ID] | No completion promise set - loop runs infinitely"
}

# Output JSON to stdout ONLY - no stderr
# Build JSON manually to ensure clean output
$jsonOutput = '{"decision":"block","reason":' + ($PROMPT_TEXT | ConvertTo-Json) + ',"systemMessage":' + ($SYSTEM_MSG | ConvertTo-Json) + '}'

# Output to stdout only
[Console]::Out.WriteLine($jsonOutput)

# Exit with code 0 for structured control (not error)
exit 0
