#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;version 1.0.20220819

#include common.ahk
#include bns_DungeonManager.ahk

;================================================================================================================
;	Configuration (this config will be overlay if config.ini has value)
;================================================================================================================
;---系統設定---
global DBUG := 1
global LOGABLE := 4		;1:only Error, 2:E|Warning, 3:E|W|Debug, 4:all

;---系統環境設定---
;劍靈設定 界面大小85, 橫軸速度:60, 縱軸速度:60

;(覆寫 common.ahk 預設值)
global WIN_WIDTH := 1920			;視窗的寬度 pixel
global WIN_HEIGHT := 1080 + 30		;視窗的高度 pixel (需補上標題列的高度)



;---F8副本選單設定---
;(覆寫 bns_DungeonDispater.ahk 預設值)
global ACTIVITY:=1			;當前活動副本(入門才會有)		
global PARTY_MODE:=2		;組隊模式: 1:入門, 2:一般, 3:困難


;-------------------------
; 001 - 天之盆地鑰匙	- 地表
; 101 - 鬼怪村活動 		- 地表
; 102 - 紅絲倉庫   		- 地表
; 201 - 鬼面劇團   		- 地表
; 202 - 沙暴神殿   		- f8
; 203 - 青空船     		- f8
; 204 - 混沌補給基地	- f8
global DUNGEON_INDEX:=102


;---地表副本選單設定---

;================================================================================================================
;	ACTION - Go into dungeon - Ghost Face
;================================================================================================================
EngageDungeon() {
	return DungeonSelecter(DUNGEON_INDEX)
}

;================================================================================================================
;	System Event
;================================================================================================================
onStart() {
	tooltip                             ;清掉tooltip
	global v_Enable:=!v_Enable
}


onInit() {
	global pLogfile
	
	LoadExternConfig()	;載入外部 config.ini 設定
	
	DumpFileOpen()
	DumpLogI("=== Script cycle start ==============================================================================================================================")
	DumpSystemConfig()

	BnsF8Init()

	sleep 500
	MousePositionAdjust()
}

onPauseResume() {
	v_Pause := !v_Pause
	if(v_Pause == 1) {
		ShowTipI("●[Script] Pause!!")
	}
	else {
		ShowTipI("●[Script] Resume!!")
	}

	Pause
	
}


onReset() {
	tooltip                             ;清掉tooltip

	;釋放按鍵
	Send {w Up}
	Send {a Up}
	Send {s Up}
	Send {d Up}
	Send {Alt up}
	Send {Shift Up}

	;Pause
	;EXITAPP
}


onDestory() {
	;tooltip                             ;清掉tooltip
	global v_Enable:=0
	global v_pause:=0
	global pLogfile

	DumpLogI("=== Script cycle stop ===============================================================================================================================")
	DumpFileClose()

	;重設AHK
	Reload
}


onFinish(msg) {
	DumpLogI("●[FINISH] reason: " msg)
	onDestory()
}


;================================================================================================================
;	Test 
;================================================================================================================
singleStepTest() {
	testMode:=1
	if(testMode == 1)
	{
		;BnsActionAdjustDirectionOnMap(325)
		;BnsIsEnemyDetected()
		;BnsIsCharacterDead()

		;switchDesktopByNumber(1)
		;BnsEnterRoomAndReady(511280)
		;BnsRoomTeamUp()
		
		;BnsActionAdjustDirectionOnMap(75)
		;return 1
		
		BnsF8SelectPartyModeHard()
		return 1

		BnsEarthGoF8Lobby()
		return 1
		;自動選活動本
		
		Send {w Down}
		Send {a Down}
		sleep 2300
		Send {a Up}
		sleep 1500
		Send {w Up}
		sleep 100
		
		Send {f}
		
		loop ,3 {
			sleep 1000
			Send {f}
		}
		Send {Esc}
		sleep 100

		Send {w Down}
		Send {d Down}
		sleep 3000
		Send {d Up}
		Send {w Up}
		
		sleep 10000	;等過圖
		

		Send {w Down}
		Send {Shift}
		sleep 3500
		Send {w Up}

		BnsActionAdjustDirectionOnMap(75)
		sleep 1000
		WinActivate, "劍靈"
		sleep 1000

		BnsStartCheatEngineSpeed()
		BnsActionWalk(8800)
		BnsActionLateralWalkRight(800)
		BnsActionWalk(1800)
		BnsStartStopAutoCombat()
		
		if(BnsIsEnemyClear(5000, 600) != 0) {
			BnsStopCheatEngineSpeed()
			BnsGobackF8Lobby()
		}

	}

	return testMode
}



;================================================================================================================
;================================================================================================================
;	Main 
;================================================================================================================
main() {
	onStart()

	if(v_Enable == 1) {
		onInit()
		sleep 300
	}

	if(DBUG == 1) {
		ShowTipD("[System] Scritp flag:" v_Enable)
		sleep 500
	}

	if(v_Enable == 0) {
		onReset()						;重設腳本
		onDestory()

		return
	}


	ShowTipI("●[Script] - Staring...")


	if(singleStepTest() == 1) {
		onDestory()
		return
	}

	loop
	{
		DumpLogI("[System] Start Next Round -------------------------------------")
		
		if(EngageDungeon() == 0) {
			break
		}
		
		sleep 3000
	}

	onFinish(ERR_CAUSE)
	return
}


;================================================================================================================
;================================================================================================================
;	Preloader
;================================================================================================================
;================================================================================================================

#MaxThreadsPerHotkey 2              ;設置從此開始為 multi-thread (最大2個thead)
global v_Enable := 0				;腳本啟動狀態
global v_Pause :=0					;腳本暫停狀態

;Start Key
;^F1::

LoadExternConfig()	;載入外部 ini 設置, 取得 Hotkey 設定鍵(這邊需要 Reload 才會套用)

Hotkey, %HKEY%, main
Hotkey, !%HKEY%, main	;多加 alt 聯動，防止 alt 鍵壓住時沒反應


Hotkey, %PRKEY%, onPauseResume
