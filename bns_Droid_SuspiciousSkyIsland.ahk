#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global CHARACTER_PROFILES    ;defined in bns_common.ahk
global PROFILES_ITERATOR

;================================================================================================================
;    █ Interface - Get Character Profiles 
;================================================================================================================
BnsDroidGetCP_SuspiciousSkyIsland() {
    return "SuspiciousSkyIsland.cp"
}


;================================================================================================================
;    █ Interface - Navigation into dungeon
;================================================================================================================
BnsDroidNavigation_SuspiciousSkyIsland() {
    return BnsOuF8DefaultGoInDungeon(1)
}


;================================================================================================================
;    █ Main
;================================================================================================================
BnsDroidRun_SuspiciousSkyIsland() {
    
    ;校正視角
    ;BnsActionAdjustCamara(-50, 8)

    BnsActionFixWeapon()

    ;自動執行戰鬥
    BnsDroidMission_SI_AutoFighting()

    return 1
}


;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_SI_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
}


;################################################################################################################
;================================================================================================================
;    Mission1 - Auto Fighting
;================================================================================================================
;################################################################################################################
BnsDroidMission_SI_AutoFighting(){

    ShowTipI("●[Mission] - Move to target")
    BnsActionSprint(3500)

    BnsActionAdjustDirectionOnMap(75)
    ;sleep 1000
    ;WinActivate, "劍靈"
    ;sleep 1000

    
    ;BnsActionWalk(6500)
    BnsActionSprint(14000)
    ;BnsActionLateralWalkRight(800)
    
    ShowTipI("●[Mission] - Engage!")
    
    ;清除小豬豬
    BnsStartHackSpeed()
    BnsStartStopAutoCombat()    ;start

    if(BnsIsEnemyClear(5000, 480) == 0) {    ;阻塞式函數, 丟失目標最大容許值5秒, 超時時限8分鐘, 1 表示完成
        BnsDroidMission_SI_Fail(" - pig not found, Mission failure")
        BnsStartStopAutoCombat()    ;stop
        return 0
    }

    BnsStartStopAutoCombat()    ;stop
    BnsStopHackSpeed()
    sleep 1000

    ;等待脫戰
    loop {
        if(BnsIsLeaveBattle()) {
            break
        }
        sleep 100
    }

    ShowTipI("●[Mission] - Zako clear!")

    ;小怪全清除後, 再往 BOSS 出現方向移動
    BnsActionAdjustDirectionOnMap(56)
    sleep 200
    ;BnsActionLateralWalkLeft(100)
    BnsActionSprint(11500)

    ;清除大豬豬    
    BnsStartStopAutoCombat()    ;start
    sleep 2000

    if(BnsIsBossDetected() == 0) {
        ShowTipI("●[Mission] - Boss not found, more walk ahead to find.")
        Send {w Down} {d Down}
        sleep 3000
        Send {d Up} {w Up}
    }

    if(BnsIsEnemyClear(4000, 480) == 0) {
        BnsDroidMission_SI_Fail(" - Boss not found, Mission failure")
        BnsStartStopAutoCombat()    ;stop
        return 0
    }

    BnsStartStopAutoCombat()    ;stop
    ShowTipI("●[Mission] - Boss clear!")

    ;等待脫戰
    loop {
        if(BnsIsLeaveBattle()) {
            break
        }
        sleep 100
    }

    ShowTipI("●[Mission] - Disengage!")

    ;回報任務
    Send {Alt Down}
    sleep 200
    MouseClick, left, 1700, 460
    Send {Alt Up}
    sleep 1000
    ScreenShot()
    Send y
    sleep 200

    ShowTipI("●[Mission] - Mission Completed")
}
