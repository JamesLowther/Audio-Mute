#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance force
#InstallKeybdHook

if FileExist("Config.ini")
{

	IniRead, DeviceNumber, %A_ScriptDir%\Config.ini, General, Sound Device Number
	IniRead, MainToggle, %A_ScriptDir%\Config.ini, Hotkeys, Main Toggle
	IniRead, SwitchMode, %A_ScriptDir%\Config.ini, Hotkeys, Switch Mode
	IniRead, DisableToggle, %A_ScriptDir%\Config.ini, Hotkeys, Disable Toggle
	IniRead, MainToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Main Toggle
	IniRead, SwitchModeEnabled, %A_ScriptDir%\Config.ini, Enabled, Switch Mode
	IniRead, DisableToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Disable Toggle
	
	Menu, Tray, NoStandard
	Menu, HotkeyMenu, Add, Set Main Toggle Hotkey (%MainToggle%), SetMainToggle
	Menu, HotkeyMenu, Add, Set Switch Mode Hotkey (%SwitchMode%), SetSwitchMode
	Menu, HotkeyMenu, Add, Set Disable Toggle Hotkey (%DisableToggle%), SetDisableToggle
	Menu, HotkeyMenu, Add, Restore to Defaults, SetDefault
	Menu, Tray, Add, Hotkeys, :HotkeyMenu
	Menu, Tray, Add
	Menu, Tray, Add, Set Mixer Number, SetSoundDevice
	Menu, Tray, Add, Find Mixer Number, MixerAnalysis
	Menu, Tray, Add
	Menu, Tray, Add, Readme, OpenReadme
	Menu, Tray, Add, Reload, RefreshApp
	Menu, Tray, Add
	Menu, Tray, Add, Exit, ExitProgram
	
	maintogglecheck := 0
	switchmodecheck := 0
	disabletogglecheck := 0
	
	Hotkey, %MainToggle%, MainFunction, UseErrorLevel
	
	if Errorlevel = 2
	{
		errorkey := MainToggle
		errornumber := 1
		gosub ErrorCheck
		
	return
	}

	Hotkey, %SwitchMode%, ModeFunction, UseErrorLevel
	
	if Errorlevel = 2
	{
		errorkey := SwitchMode
		errornumber := 2
		gosub ErrorCheck
		
	return
	}
	
	Hotkey, %DisableToggle%, DisableFunction, UseErrorLevel
	
	if Errorlevel = 2
	{
		errorkey := DisableToggle
		errornumber := 3
		gosub ErrorCheck
		
	return
	}
	
	if !DeviceNumber OR !MainToggle OR !SwitchMode OR !DisableToggle OR !MainToggleEnabled OR !SwitchModeEnabled OR !DisableToggleEnabled
	{
		Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\cross-circle.ico
		
		errorfound := 0
		
		MsgBox,	4, Missing Info, You're missing some information in your config file. Restore to default?

		IfMsgBox, Yes
		{
			IniWrite, 1, Config.ini, General, Sound Device Number
			IniWrite, RAlt, Config.ini, Hotkeys, Main Toggle
			IniWrite, ^Q, Config.ini, Hotkeys, Switch Mode
			IniWrite, ^T, Config.ini, Hotkeys, Disable Toggle
			IniWrite, true, Config.ini, Enabled, Main Toggle
			IniWrite, true, Config.ini, Enabled, Switch Mode
			IniWrite, true, Config.ini, Enabled, Disable Toggle
	
			Reload
		
		return
		}
		
		IfMsgBox, No
		{
		
		return
		}
		
	return
	}
	
	else
	{
		Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\cross-circle.ico

		errorfound := 0
		modevalue := 0
		disablevalue := 0
	
		SoundGet, MuteState, MASTER, MUTE, %DeviceNumber%
	
		gosub EnableCheck
	
		if (MuteState = "On")
		{
			Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
		
		return
		}
		
		else if (MuteState = "Off")
		{
			Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\red-circle.ico
		
		return
		}
		
		DisableFunction:

			if (disablevalue = 1)
			{
				disablevalue = 0
				SoundPlay, %A_ScriptDir%\resources\audio\keys-off.wav

				Hotkey, %MainToggle%, On
				Hotkey, %SwitchMode%, On
				
				if (modevalue = 0) && (MuteState = "On")
				{
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
					
				return
				}
				
				else if (modevalue = 0) && (MuteState = "Off")
				{
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\red-circle.ico
				
				return
				}
				
				else if (modevalue = 1)
				{
				
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
					SoundSet, 1, MASTER, MUTE, %DeviceNumber%
				
				return
				}
				
			return
			}

			else if (disablevalue = 0)
			{
				disablevalue = 1
				Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\purple-circle.ico
				SoundPlay, %A_ScriptDir%\resources\audio\keys-on.wav
				
				Hotkey, %MainToggle%, Off
				Hotkey, %SwitchMode%, Off
				
			return
			}

		return
		
		ModeFunction:
		
			if (modevalue = 1) && (disablevalue = 0)
			{
				modevalue = 0
				SoundPlay, %A_ScriptDir%\resources\audio\mode-switch.wav
	
			return
			}
				
			else if (modevalue = 0) && (disablevalue = 0)
			{
				modevalue = 1
				SoundPlay, %A_ScriptDir%\resources\audio\mode-switch.wav
				Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
				SoundSet, 1, MASTER, MUTE, %DeviceNumber%
					
			return
			}
			
		return
		
		MainFunction:

			if (modevalue = 0) && (disablevalue = 0)
			{
				SoundSet, +1, MASTER, MUTE, %DeviceNumber%
				SoundGet, MuteState, MASTER, MUTE, %DeviceNumber%

				if (MuteState = "On")
				{
					SoundPlay, %A_ScriptDir%\resources\audio\mic-off.wav
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
					
				return
				}
				
				else if (MuteState = "Off")
				{
					SoundPlay, %A_ScriptDir%\resources\audio\mic-on.wav
					Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\red-circle.ico
					
				return
				}
				
			return
			}

			else
			{
				While (modevalue = 1) && (disablevalue = 0)
				{
					if (GetKeyState(MainToggle,"P") = 1) && (modevalue = 1)
					{
						Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\blue-circle.ico
						Soundset, 0, MASTER, MUTE, %DeviceNumber%
					}
					else if (GetKeyState(MainToggle,"P") = 0) && (modevalue = 1)
					{
						Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\black-circle.ico
						Soundset, 1, MASTER, MUTE, %DeviceNumber%
					}
					
					else
					{
					
					break
					}
				}
			
			return
			}

		return
	}
	
return

}

else
{
	Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\cross-circle.ico

	IniWrite, 1, Config.ini, General, Sound Device Number
	IniWrite, RAlt, Config.ini, Hotkeys, Main Toggle
	IniWrite, ^Q, Config.ini, Hotkeys, Switch Mode
	IniWrite, ^T, Config.ini, Hotkeys, Disable Toggle
	IniWrite, true, Config.ini, Enabled, Main Toggle
	IniWrite, true, Config.ini, Enabled, Switch Mode
	IniWrite, true, Config.ini, Enabled, Disable Toggle
	
	Sleep, 1000
	
	Reload
	
return
}

ErrorCheck:

errorfound := 1

Menu, TRAY, ICON, %A_ScriptDir%\resources\icons\cross-circle.ico

MsgBox, 4, Invalid Hotkey, The hotkey '%errorkey%' is invalid. Reset to default?

IfMsgBox, Yes
{
	if (errornumber = 1)
	{
		IniWrite, RAlt, Config.ini, Hotkeys, Main Toggle
		
		Reload
		
	return
	}
	 
	else if (errornumber = 2)
	{
		IniWrite, ^Q, Config.ini, Hotkeys, Switch Mode
	
		Reload
	
	return
	}
	
	else if (errornumber = 3)
	{
		IniWrite, ^T, Config.ini, Hotkeys, Disable Toggle
		
		Reload
	
	return
	}
	
return
}

IfMsgBox, No
{
		
return
}

return

EnableCheck:

Loop, 7
{
	if (MainToggleEnabled = "false") && (maintogglecheck = 0) && (errorfound = 0)
	{
		maintogglecheck = 1
		
		Hotkey, %MainToggle%, Off
		
	}
			
	else if (SwitchModeEnabled = "false") && (switchmodecheck = 0) && (errorfound = 0)
	{
		switchmodecheck = 1
		
		Hotkey, %SwitchMode%, Off

	}
			
	else if (DisableToggleEnabled = "false") && (disabletogglecheck = 0) && (errorfound = 0)
	{
		disabletogglecheck = 1
				
		Hotkey, %DisableToggle%, Off		
			
	}
	
	else if (MainToggleEnabled = "true") && (maintogglecheck = 0) && (errorfound = 0)
	{
		maintogglecheck = 1
				
		Hotkey, %MainToggle%, On

	}
			
	else if (SwitchModeEnabled = "true") && (switchmodecheck = 0) && (errorfound = 0)
	{
		switchmodecheck = 1
				
		Hotkey, %SwitchMode%, On		
			
	}
			
	else if (DisableToggleEnabled = "true") && (disabletogglecheck = 0) && (errorfound = 0)
	{
		disabletogglecheck = 1
		
		Hotkey, %DisableToggle%, On
			
	}
}

return
	
MixerAnalysis:

Loop, 100
{
	CurrentMixer := A_Index
	
	SoundGet, CorrectMixerVol, MASTER, VOLUME, %CurrentMixer%

	if (CorrectMixerVol != 50)
	{
		foundmixer = 0
	}
	
	else if (CorrectMixerVol = 50)
	{
		foundmixer = 1
		
	break
	}
}

if (foundmixer = 0)
{
	MsgBox, 0, Error, Unable to find mixer value. Make sure the sound device has its volume set to 50.

return
} 

else if (foundmixer = 1)
{
	MsgBox, 4, Mixer Number, Mixer number is %CurrentMixer%.  Would you like to use this deivce?
	
	IfMsgBox, Yes
	{
		IniWrite, %CurrentMixer%, Config.ini, General, Sound Device Number
		
	Reload
	}
	
return
}

return


RefreshApp:

	Reload
	
return

OpenReadme:

Run, %A_ScriptDir%\Readme.txt

return

ExitProgram:

	ExitApp

return

SetSoundDevice:

	InputBox, DeviceNumber, Set Sound Device Number, Enter the mixer number for your sound device. 										This value can be found by running 'Find Mixer Number' found in the tray menu., 150, 275
	
	if !DeviceNumber
	{
	
	return
	}
	
	else
	{
		IniWrite, %DeviceNumber%, Config.ini, General, Sound Device Number
	
	Reload
	}

return

SetMainToggle:

	InputBox, PreMainToggle, Set Main Toggle Hotkey, Enter the hotkey you would like to use. Type 'enable' or 'disable' to activate and deactivate the hotkey. 			Go to autohotkey.com/docs/Hotkeys.htm for possible combinations., 150, 275
	
	if !PreMainToggle
	{
	
	return
	}
	
	else if (PreMainToggle = "DISABLE")
	{
		IniWrite, false, Config.ini, Enabled, Main Toggle
		maintogglecheck = 0
		IniRead, MainToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Main Toggle
		MsgBox, 0, Disabled, Main toggle hotkey is disabled.
		gosub EnableCheck
		
	return
	}
	
	else if (PreMainToggle = "ENABLE")
	{
		IniWrite, true, Config.ini, Enabled, Main Toggle
		maintogglecheck = 0
		IniRead, MainToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Main Toggle
		MsgBox, 0, Enabled, Main toggle hotkey is enabled.
		gosub EnableCheck

	return
	}
	
	else
	{
		IniWrite, %PreMainToggle%, Config.ini, Hotkeys, Main Toggle
		
	Reload
	}

return

SetSwitchMode:

	InputBox, PreSwitchMode, Set Switch Mode Hotkey, Enter the hotkey you would like to use. Type 'enable' or 'disable' to activate and deactivate the hotkey. 			Go to autohotkey.com/docs/Hotkeys.htm for possible combinations., 150, 275

	if !PreSwitchMode
	{
	
	return
	}
	
	else if (PreSwitchMode = "DISABLE")
	{
		IniWrite, false, Config.ini, Enabled, Switch Mode
		switchmodecheck = 0
		IniRead, SwitchModeEnabled, %A_ScriptDir%\Config.ini, Enabled, Switch Mode
		MsgBox, 0, Disabled, Switch mode hotkey is disabled.
		gosub EnableCheck

	return
	}
	
	else if (PreSwitchMode = "ENABLE")
	{
		IniWrite, true, Config.ini, Enabled, Switch Mode
		switchmodecheck = 0
		IniRead, SwitchModeEnabled, %A_ScriptDir%\Config.ini, Enabled, Switch Mode
		MsgBox, 0, Enabled, Switch mode hotkey is enabled.
		gosub EnableCheck

	return
	}
	
	else
	{
		IniWrite, %PreSwitchMode%, Config.ini, Hotkeys, Switch Mode
		
	Reload
	}

return

SetDisableToggle:

InputBox, PreDisableToggle, Set Disable Toggle Hotkey, Enter the hotkey you would like to use. Type 'enable' or 'disable' to activate and deactivate the hotkey. 			Go to autohotkey.com/docs/Hotkeys.htm for possible combinations., 150, 275

	if !PreDisableToggle
	{
	
	return
	}
	
	else if (PreDisableToggle = "DISABLE")
	{
		IniWrite, false, Config.ini, Enabled, Disable Toggle
		disabletogglecheck = 0
		IniRead, DisableToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Disable Toggle
		MsgBox, 0, Disabled, Disable toggle hotkey is disabled.
		gosub EnableCheck

	return
	}
	
	else if (PreDisableToggle = "ENABLE")
	{
		IniWrite, true, Config.ini, Enabled, Disable Toggle
		disabletogglecheck = 0
		IniRead, DisableToggleEnabled, %A_ScriptDir%\Config.ini, Enabled, Disable Toggle
		MsgBox, 0, Enabled, Disable toggle hotkey is enabled.
		gosub EnableCheck

	return
	}
	
	else
	{
		IniWrite, %PreDisableToggle%, Config.ini, Hotkeys, Disable Toggle
		
	Reload
	}

return

SetDefault:

	MsgBox, 4 , Restore to Defaults, Are you sure?

	IfMsgBox, Yes
	{
		IniWrite, RAlt, Config.ini, Hotkeys, Main Toggle
		IniWrite, ^Q, Config.ini, Hotkeys, Switch Mode
		IniWrite, ^T, Config.ini, Hotkeys, Disable Toggle
		IniWrite, true, Config.ini, Enabled, Main Toggle
		IniWrite, true, Config.ini, Enabled, Switch Mode
		IniWrite, true, Config.ini, Enabled, Disable Toggle
		
	Reload
	}

	IfMsgBox, No
	{

	return
	}	
	
return
