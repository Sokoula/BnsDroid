#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global CB_ExcuteRoundTimes := -1        ;-1: unlimited
global CB_PickRewardsSecond := 30



;================================================================================================================
;    Main
;================================================================================================================
BnsDroidRun_CelestialBasinKeys() {
    ;搭配 speed hack
    
    ;自動執行戰鬥
    BnsDroidMission_CB_HuntKey()
    
    ;進入密室
    BnsMoveDungeon_CelestialBasinKeys()
    
    return 1
}



;================================================================================================================
;    Naviation
;================================================================================================================
BnsMoveDungeon_CelestialBasinKeys() {
    ShowTipI("●[System] - Move to treasure room")
    BnsActionAdjustDirectionOnMap(2)
    sleep 200
    BnsActionWalk(950)
    ;BnsMoveDungeon_RandomConfuseProtection(1100)
    ;BnsMoveDungeon_RandomConfuseProtection(4300)
    sleep 200

    ;點擊傳點5次，防止別人佔用
    loop, 10 {
        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_dungeon_option") == 1) {
            loop, 3 {
                Send, {f}
                sleep 100
            }

            sleep 4300

            if(BnsIsMapLoading() == 1) {
                ShowTipI("●[System] - Enter into treasure room")
                if(BnsWaitMapLoadDone() == 1) {
                    return 1
                }
            }
        }

        sleep 5000
    }

    BnsDroidMission_CB_Fail("the entry does not find")
    
    return 0
}



;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_CB_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
    CommonTimeout:=0
    sleep 1000
}


CB_TIMEOIT_NOTIFY_THREAD() {
    ShowTipE("[GT_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
    CommonTimeout:=1
}



;################################################################################################################
;================================================================================================================
;    Mission1 - Auto Fighting
;================================================================================================================
;################################################################################################################
BnsDroidMission_CB_HuntKey(){
    ShowTipI("●[Mission1] - Engage")
    ;BnsStartHackSpeed()
    sleep 500

    BnsActionLateralWalkRight(60)
    ;BnsActionLateralWalkRight(300)
    BnsActionWalk(300)
    ;BnsActionWalk(1400)
    sleep 200
    
    ShowTipI("●[Mission1] - Fighting")
    BnsStartStopAutoCombat()
    sleep 5000
    ;sleep 12000
    BnsStartStopAutoCombat()
    sleep 200
    BnsActionWalk(4000)
    ;BnsActionWalk(10000)
    sleep 200

    ShowTipI("●[Mission1] - Mission Completed")
    sleep 200
    ShowTipI("●[Mission1] - Exit the treasure room")
    
    ;BnsStopHackSpeed()
    sleep 500
    BnsWaitMapLoadDone()
}
