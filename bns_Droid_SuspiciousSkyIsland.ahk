#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global CHARACTER_PROFILES    ;defined in bns_common.ahk
global PROFILES_ITERATOR


Class BnsDroidSuspiciousSkyIsland {
    ;AHK class constructor
    __new() {
        return this
    }

    ;AHK class destructor
    __delete() {
    }

;================================================================================================================
;█ Variables
;================================================================================================================
    MISSION_POSX := 1700
    MISSION_POSY := 400

    FIGHTING_MODE := 0    ;0:alone



;================================================================================================================
;█ Interface
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;* @return - .cp file; empty means not used.
    getCharacterProfiles() {
        return "SuspiciousSkyIsland.cp"
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 廣場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------
    dungeonNavigation() {
        return BnsOuF8DefaultGoInDungeon(1, 1, 0)    ;普通進場, 不確認過圖
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 執行腳本
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    start() {

        switch this.FIGHTING_MODE
        {
            case 0:
                return this.runnableAlone()
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 結束腳本
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    finish() {
        return this.runStageEnding()
    }


;================================================================================================================
;█ Functions - RUNNABLE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runnableAlone() {
        BnsActionFixWeapon()

        BnsStartHackSpeed()
        ;清小豬豬消進度條
        if(this.runStageClearAll() == 0) {
            return 0
        }

        ;消滅 Boss
        this.runStageFinishBoss()
        BnsStopHackSpeed()

        return 1
    }



;================================================================================================================
;█ Functions - STAGE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 第一階段: 清除小豬豬
    ;------------------------------------------------------------------------------------------------------------
    runStageClearAll() {
        ShowTipI("●[Mission1] - Clear all zakos")
        sleep 1000

        this.actionGoToFightingAera()

        ShowTipI("●[Mission1] - Engage!")
        BnsStartAutoCombat()

        if(BnsIsEnemyClear(5000, 480) == 0) {
            ShowTipI("●[Mission1] - Mission Failed, timeout!")
            BnsStartStopAutoCombat()    ;stop
            return 0
        }
        BnsStopAutoCombat()

        ShowTipI("●[Mission1] - Mission clear")
        return 1
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 清除大豬豬
    ;------------------------------------------------------------------------------------------------------------
    runStageFinishBoss() {
        ShowTipI("●[Mission2] - Clear Boss")
        sleep 1000
        this.actionGoToBossAera()

        ShowTipI("●[Mission2] - Engage!")
        BnsStartAutoCombat()
        sleep 3000
        BnsWaitingLeaveBattle()
        BnsStopAutoCombat()
        ShowTipI("●[Mission2] - Mission clear")
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 最後階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ;領取斬首獎勵
        ControlSend,,{Alt Down}, %res_game_window_title%
        sleep 200
        MouseClick, left, this.MISSION_POSX, this.MISSION_POSY
        ControlSend,,{Alt Up}, %res_game_window_title%
        sleep 500
        ControlSend,,{f}, %res_game_window_title%
        sleep 500
        ControlSend,,{f}, %res_game_window_title%
        sleep 1000
        ControlSend,,{f}, %res_game_window_title%
        sleep 300

        ;回報任務
        ControlSend,,{Alt Down}, %res_game_window_title%
        sleep 200
        MouseClick, left, this.MISSION_POSX, this.MISSION_POSY
        ControlSend,,{Alt Up}, %res_game_window_title%
        sleep 1200
        ; ScreenShot()
        ControlSend,,{y}, %res_game_window_title%
        sleep 1000

        ShowTipI("●[Mission3] - Mission Completed!")
    }

;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 導航至戰鬥位置
    ;------------------------------------------------------------------------------------------------------------
    actionGoToFightingAera() {
        ShowTipI("●[Action] - Move to fighting aera")

        BnsActionSprintToPosition(26100, 1340)   ;入口轉向點
        BnsActionSprintToPosition(28380, 6530)   ;小豬豬戰鬥區

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 導航至戰鬥位置
    ;------------------------------------------------------------------------------------------------------------
    actionGoToBossAera() {
        ShowTipI("●[Action] - Move to boss aera")
        BnsActionSprintToPosition(31500, 8520)   ;尾王前轉向點
        BnsActionSprintToPosition(31630, 10000)   ;尾王戰鬥區
    }


;================================================================================================================
;█ Functions - STATUS
;================================================================================================================


}
















; ;================================================================================================================
; ;    █ Interface - Get Character Profiles
; ;================================================================================================================
; BnsDroidGetCP_SuspiciousSkyIsland() {
;     return "SuspiciousSkyIsland.cp"
; }


; ;================================================================================================================
; ;    █ Interface - Navigation into dungeon
; ;================================================================================================================
; BnsDroidNavigation_SuspiciousSkyIsland() {
;     return BnsOuF8DefaultGoInDungeon(1)
; }


; ;================================================================================================================
; ;    █ Main
; ;================================================================================================================
; BnsDroidRun_SuspiciousSkyIsland() {

;     ;校正視角
;     ;BnsActionAdjustCamara(-50, 8)

;     BnsActionFixWeapon()

;     ;自動執行戰鬥
;     BnsDroidMission_SI_AutoFighting()

;     return 1
; }


; ;================================================================================================================
; ;    Error
; ;================================================================================================================
; BnsDroidMission_SI_Fail(ex) {
;     ShowTipE("●[Exception] - " ex)
; }


; ;################################################################################################################
; ;================================================================================================================
; ;    Mission1 - Auto Fighting
; ;================================================================================================================
; ;################################################################################################################
; BnsDroidMission_SI_AutoFighting(){

;     ShowTipI("●[Mission] - Move to target")
;     BnsActionSprint(3500)

;     BnsActionAdjustDirectionOnMap(75)
;     ;sleep 1000
;     ;WinActivate, "劍靈"
;     ;sleep 1000


;     ;BnsActionWalk(6500)
;     BnsActionSprint(14000)
;     ;BnsActionLateralWalkRight(800)

;     ShowTipI("●[Mission] - Engage!")

;     ;清除小豬豬
;     BnsStartHackSpeed()
;     BnsStartStopAutoCombat()    ;start

;     if(BnsIsEnemyClear(5000, 480) == 0) {    ;阻塞式函數, 丟失目標最大容許值5秒, 超時時限8分鐘, 1 表示完成
;         BnsDroidMission_SI_Fail(" - pig not found, Mission failure")
;         BnsStartStopAutoCombat()    ;stop
;         return 0
;     }

;     BnsStartStopAutoCombat()    ;stop
;     BnsStopHackSpeed()
;     sleep 1000

;     ;等待脫戰
;     loop {
;         if(BnsIsLeaveBattle()) {
;             break
;         }
;         sleep 100
;     }

;     ShowTipI("●[Mission] - Zako clear!")

;     ;小怪全清除後, 再往 BOSS 出現方向移動
;     BnsActionAdjustDirectionOnMap(56)
;     sleep 200
;     ;BnsActionLateralWalkLeft(100)
;     BnsActionSprint(11500)

;     ;清除大豬豬
;     BnsStartStopAutoCombat()    ;start
;     sleep 2000

;     if(BnsIsBossDetected() == 0) {
;         ShowTipI("●[Mission] - Boss not found, more walk ahead to find.")
;         Send {w Down} {d Down}
;         sleep 3000
;         Send {d Up} {w Up}
;     }

;     if(BnsIsEnemyClear(4000, 480) == 0) {
;         BnsDroidMission_SI_Fail(" - Boss not found, Mission failure")
;         BnsStartStopAutoCombat()    ;stop
;         return 0
;     }

;     BnsStartStopAutoCombat()    ;stop
;     ShowTipI("●[Mission] - Boss clear!")

;     ;等待脫戰
;     loop {
;         if(BnsIsLeaveBattle()) {
;             break
;         }
;         sleep 100
;     }

;     ShowTipI("●[Mission] - Disengage!")

;     ;回報任務
;     Send {Alt Down}
;     sleep 200
;     MouseClick, left, 1700, 460
;     Send {Alt Up}
;     sleep 1000
;     ScreenShot()
;     Send y
;     sleep 200

;     ShowTipI("●[Mission] - Mission Completed")
; }
