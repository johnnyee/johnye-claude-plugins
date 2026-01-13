' Ralph Loop Stop Hook VBScript Wrapper
' Launches PowerShell script silently without affecting parent window

Set objShell = CreateObject("WScript.Shell")
strScriptPath = Replace(WScript.ScriptFullName, "stop-hook.vbs", "stop-hook.ps1")
strCommand = "pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File """ & strScriptPath & """"
objShell.Run strCommand, 0, True
