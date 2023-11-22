#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global GV_ExcuteRoundTimes := -1		;-1: unlimited
global GV_PickRewardsSecond := 30


;================================================================================================================
;	Main
;================================================================================================================
BnsDroidRun_GhostfaceVillage() {

	;校正視角
	;BnsActionAdjustCamara(-50, 8)

	if(BnsActionFixWeapon() == 1) {
		;ShowTipI("")
	}

	;自動執行戰鬥
	BnsDroidMission_GV_AutoFighting()

	;校正視角
	;BnsActionAdjustCamara(-50, 8)

	;離開副本
	;if(BsnLookingExit() > 0 ) {
	;	movetimes:=1500
	;}

	BnsActionAdjustDirectionOnMap(1)
	sleep 200
	BnsActionWalk(3400)

	if(BnsDungeonLeave(10) == 0) {
		;return 0
		return BnsDungeonRetreat()
	}

	if(GV_ExcuteRoundTimes > 0) {
		GV_ExcuteRoundTimes -= 1
		ShowTipI("●[Mission] - execute round count: " GV_ExcuteRoundTimes)
		return 1
	}
	else if(GV_ExcuteRoundTimes != -1) {
		ShowTipI("●[Mission] - execute round done")
		return 0
	}
	
	return 1
}




;================================================================================================================
;	Error
;================================================================================================================
BnsDroidMission_GV_Fail(ex) {
	ShowTipE("●[Exception] - " ex)
	CommonTimeout:=0
	sleep 1000
}


GV_TIMEOIT_NOTIFY_THREAD() {
	ShowTipE("[GT_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
	CommonTimeout:=1
}



;################################################################################################################
;================================================================================================================
;	Mission1 - Auto Fighting
;================================================================================================================
;################################################################################################################
BnsDroidMission_GV_AutoFighting(){
	disengage:=10

	ShowTipI("●[Mission1] - Prepare options")
	;吃包子燒酒
	Send 6
	sleep 2800
	Send 7
	sleep 2800
	Send 7
	sleep 2800
	Send 7
	sleep 2800

	ShowTipI("●[Mission1] - Open the door to fight")
	BnsActionWalk(1500)
	sleep 100
	Send f
	sleep 5000
	
	;衝刺到場中
	;BnsActionSprint(1800)
	BnsActionWalk(1800*1.7875)
	BnsActionLateralWalkRight(2100)
	sleep 200

	ShowTipI("●[Mission1] - Engage!")
	;開啟自動戰鬥
	BnsStartStopAutoCombat()
	sleep 10000
	
	
	while(disengage >= 0) {
		sleep 1000

		disengage-=1

		if(BnsIsEnemyDetected() > 0) {
			disengage:=10
		}
		
		;使用星
		BnsDroidSkill_commonPrepare()

		ShowTipI("●[Mission1] - Out of battle count: " disengage)
	}


	;保留自動戰鬥撿取葫蘆時間
	ShowTipI("●[Mission1] - Pickup rewards")
	Loop, %GV_PickRewardsSecond% {
		ShowTipI("●[Mission1] - Pickup rewards " (GV_PickRewardsSecond - A_index) "s")
		sleep 1000
	}

	;關閉自動戰鬥
	BnsStartStopAutoCombat()
	ShowTipI("●[Mission1] - Disengage!")	
	
	ShowTipI("●[Mission1] - Mission Completed")
}

