#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Globals
DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in     HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
	global CurrentDesktop, DesktopCount
	; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
	IdLength := 32

	RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, CurrentVirtualDesktop

	; Get a list of the UUIDs for all virtual desktops on the system
	RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
	if (DesktopList) {
		DesktopListLength := StrLen(DesktopList)
		; Figure out how many virtual desktops there are
		DesktopCount := DesktopListLength / IdLength
	}
	else {
		DesktopCount := 1
	}

	; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
	i := 0
	while (CurrentDesktopId and i < DesktopCount) {
		StartPos := (i * IdLength) + 1
		DesktopIter := SubStr(DesktopList, StartPos, IdLength)
		OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
		; Break out if we find a match in the list. If we didn't find anything, keep the
		; old guess and pray we're still correct :-D.

		if (DesktopIter = CurrentDesktopId) {
			CurrentDesktop := i + 1
			OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
			break
		}
		i++
	}
}

;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop)
{
	global CurrentDesktop, DesktopCount
	; Re-generate the list of desktops and where we fit in that. We do this because
	; the user may have switched desktops via some other means than the script.
	mapDesktopsFromRegistry()

	; Don't attempt to switch to an invalid desktop
	if (targetDesktop > DesktopCount || targetDesktop < 1) {
		OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
		return
	}

	; Go right until we reach the desktop we want
	while(CurrentDesktop < targetDesktop) {
		Send ^#{Right}
		CurrentDesktop++
		OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
	}

	; Go left until we reach the desktop we want
	while(CurrentDesktop > targetDesktop) {
		Send ^#{Left}
		CurrentDesktop--
		OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
	}
}