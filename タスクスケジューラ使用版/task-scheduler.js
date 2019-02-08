wsShell = WScript.createObject("WScript.Shell");
retCode = wsShell.Run("\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -File \"" + WScript.Arguments.Item(0)+"\"",0,true);
WScript.Quit(retCode);