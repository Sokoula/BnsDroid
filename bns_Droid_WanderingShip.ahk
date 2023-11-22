#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

;================================================================================================================
;    █ Interface - Get Character Profiles
;================================================================================================================
BnsDroidGetCP_WanderingShip() {
    return "WanderingShip.cp"
}


;================================================================================================================
;    █ Interface - Navigation into dungeon
;================================================================================================================
BnsDroidNavigation_WanderingShip() {
    return BnsOuF8DefaultGoInDungeon(1)
}

;================================================================================================================
;    █ Main
;================================================================================================================
BnsDroidRun_WanderingShip() {

    BnsActionFixWeapon()

    BnsDroidMission_WS_ExperienceATM()

    sleep 13000
}

;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_WS_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
    CommonTimeout:=0
    sleep 1000
}


WS_TIMEOUT_NOTIFY_THREAD() {
    ShowTipE("[WS_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
    CommonTimeout:=1
}



;================================================================================================================
;    Common
;================================================================================================================
BnsDroid_WS_isZakoClear() {
    zakoCheck := 0

    loop 30 {
        if(BnsIsEnemyDetected() == 0) {
            zakoCheck += 1
        }
        else {
            zakoCheck := 0
        }

        if(zakoCheck == 5) {
            return 1
        }
        sleep 100
    }

    return 0
}

;################################################################################################################
;================================================================================================================
;    MissionA - Experience ATM
;================================================================================================================
;################################################################################################################
BnsDroidMission_WS_ExperienceATM() {
    ShowTipI("●[MissionA] - Experience ATM")

    ;開啟 CE 加速
    BnsStartHackSpeed()
    sleep 100

    BnsActionWalk(4250)
    BnsActionLateralWalkLeft(2200)
    sleep 100
    BnsActionWalk(1610)
    BnsActionLateralWalkLeft(500)    ;吸引左邊怪, 不要修改
    BnsActionLateralWalkRight(1000) ;吸引右邊怪, 不要修改
    sleep 100
    BnsActionWalk(1000)
    BnsActionLateralWalkLeft(1600)    ;吸引上邊怪, 走到左邊等待, 不要修改
    sleep 1000

    ;關閉 CE 加速
    BnsStopHackSpeed()

    ;BnsDroidSkill_ProtectBeforeFighting(BnsRoleType())

    ;使用自動戰鬥轉向
    BnsStartStopAutoCombat()
    sleep 100
    BnsStartStopAutoCombat()

    sleep 7000

    BnsDroidSkill_ProtectBeforeFighting(BnsRoleType())

    sleep 2000

    ;使用星
    BnsDroidSkill_commonPrepare()

    ;超時計時器 60s
    SetTimer, WS_TIMEOUT_NOTIFY_THREAD, -120000

    ShowTipI("●[MissionA] - start fighting for part A ...")

    ;開始自動戰鬥
    BnsStartStopAutoCombat()

    disengage := 1

    while(disengage >= 0 && CommonTimeout == 0) {
        sleep 1000
        ShowTipI("●[MissionA] - Out of battle count: " disengage)

        disengage-=1

        if(BnsIsEnemyDetected() > 0) {
            disengage := 1
        }
    }

    ShowTipI("●[MissionA] - stop fighting for part A...")
    ;停止自動戰鬥
    BnsStartStopAutoCombat()

    ;等待門後的敵人自己過來
    sleep 6000

    ShowTipI("●[MissionA] - start fighting for part B...")
    ;開始自動戰鬥
    BnsStartStopAutoCombat()

    sleep 2000

    while(BnsIsEnemyDetected() > 0 && CommonTimeout == 0) {
        sleep 100
    }

    ShowTipI("●[MissionA] - stop fighting for part B...")
    ;停止自動戰鬥
    BnsStartStopAutoCombat()

    if(CommonTimeout == 1) {
        BnsDroidMission_WS_Fail("Fight timeout, escape fighting program")
        return 0
    }

    ;註消計時器
    SetTimer, WS_TIMEOUT_NOTIFY_THREAD, delete            ;未超時, 解除超時計時

    ShowTipI("●[MissionA] - mission completed...")

    return 1
}
