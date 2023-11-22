#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global CHARACTER_PROFILES    ;defined in bns_common.ahk
global PROFILES_ITERATOR


Class BnsDroidKaebiVillage {
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
    FIGHTING_MODE := 0    ;0:alone

    isMissionAccepted := 0


;================================================================================================================
;█ Interface
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;* @return - .cp file; empty means not used.
    getCharacterProfiles() {
        return "KaebiVillage.cp"
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 武神塔導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------
    dungeonNavigation() {
        ;//TODO: 自動飛地圖待完成
        BnsWaitMapLoadDone()

        ;武神塔飛入遁地座標
        ;6376, -53732

        if(BnsGetPosX() > -6330 && BnsGetPosX() < -5630 && BnsGetPosX() > -43090 && BnsGetPosY() < -42340 ) {
            ;已入場
            return 1
        }


        ;接任務
        if(this.isMissionAccepted == 0 && MISSION_ACCEPT == 1) {
            this.isMissionAccepted := 1
            BnsActionSprintToPosition(7003, -53850)   ;武神塔鬼怪村 npc - 魑比鬼比
            BnsActionAdjustDirection(0)

            sleep 1000
            if(BnsIsAvailableTalk() == 18) {
                loop 4 {
                    ControlSend,,{f}, %res_game_window_title%
                    sleep 1000
                }
            }
            sleep 1000

            if(BnsIsNpcTalking() == 1) {
                ControlSend,,{ESC}, %res_game_window_title%
            }
            sleep 1000
        }

        ;走向入門機關
        BnsActionSprintToPosition(7070, -53900)   ;鬼怪村入場機關
        BnsActionAdjustDirection(0)
        sleep 500


        if(BnsIsAvailableTalk() == 0) {
            return 0
        }

        loop 4 {
            ControlSend,,{f}, %res_game_window_title%
            sleep 200
        }
        sleep 3000
        BnsWaitMapLoadDone()

        return 1
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
        ; BnsActionFixWeapon()

        this.runStageGoEngage()
        this.runStageClearEnemies()

        return 1
    }



;================================================================================================================
;█ Functions - STAGE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------IdI
    ;■ 第一階段: 入村就戰鬥位置
    ;------------------------------------------------------------------------------------------------------------
    runStageGoEngage() {
        ShowTipI("●[Mission1] -  Go entry village")

        BnsActionSprintToPosition(-5755, -42740)   ;鬼怪村大門封印
        BnsActionAdjustDirection(0)

        loop 4 {
            ControlSend,,{f}, %res_game_window_title%
            sleep 200
        }

        sleep 4000
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-4970, -42740)   ;鬼怪村入口牌樓後
        BnsActionSprintToPosition(-3840, -43280)   ;右上角戰鬥整備點(龍脈後)
        BnsStopHackSpeed()
        ShowTipI("●[Mission1] - Goal")
        return 1
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 清除敵人
    ;------------------------------------------------------------------------------------------------------------
    runStageClearEnemies() {
        ShowTipI("●[Mission2] - Clear all zakos")
        sleep 1000

        ShowTipI("●[Mission2] - Waiting start!")
        sleep 12000

        ShowTipI("●[Mission2] - Engage!")
        BnsStartHackSpeed()
        BnsStartAutoCombat()

        ; if(BnsIsEnemyClear(5000, 480) == 0) {
        ;     ShowTipI("●[Mission2] - Mission Failed, timeout!")
        ;     BnsStartStopAutoCombat()    ;stop
        ;     return 0
        ; }

        this.waitVillageClear()
        BnsStopAutoCombat()

        ShowTipI("●[Mission2] - Mission clear")
        return 1
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 最後階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        BnsStopAutoCombat()

        ;移動到出口龍脈
        BnsActionSprintToPosition(-3840, -43280)   ;右上角戰鬥起始點(龍脈後)
        BnsActionAdjustDirection(127)
        sleep 2000

        ;領取斬首獎勵
        ControlSend,,{f}, %res_game_window_title%
        sleep 500
        ControlSend,,{y}, %res_game_window_title%
        sleep 500
        ControlSend,,{f}, %res_game_window_title%
        sleep 500
        ControlSend,,{f}, %res_game_window_title%
        sleep 300

        ;離開副本
        ControlSend,,{f}, %res_game_window_title%
        sleep 3000
        BnsWaitMapLoadDone()
        sleep 1000

        ;回報今日任務
        if(this.isMissionAccepted == 1) {
            BnsActionSprintToPosition(7003, -53850)   ;武神塔鬼怪村 npc - 魑比鬼比
            BnsActionAdjustDirection(0)
            sleep 2000

            loop 3 {
                ControlSend,,{f}, %res_game_window_title%
                sleep 800
            }

            if(BnsIsNpcTalking() == 1) {
                ControlSend,,{ESC}, %res_game_window_title%
            }
            sleep 1000

            this.isMissionAccepted := 2
        }

        ShowTipI("●[Mission3] - Mission Completed!")
    }

;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 等待活動結束
    ;------------------------------------------------------------------------------------------------------------
    waitVillageClear() {
        disengage := 0

        loop {
            ShowTipI("●[waitVillageClear] - isLeaveBattle:" BnsIsLeaveBattle() ", dist:" BnsMeansureTargetDistDegree(-3840, -43280)[1] ", count: " disengage)

            if(BnsIsLeaveBattle() == 1 && BnsMeansureTargetDistDegree(-3840, -43280)[1] < 100) {
                ;角色在整備點, 開始計數
                if(disengage < 10) {
                    disengage += 1
                }
                else {
                    ;活動任務結束
                    return 1
                }
            }
            else {
                ;角色不在整備點, 重新計算
                disengage := 0
            }

            sleep 300
        }
    }


;================================================================================================================
;█ Functions - STATUS
;================================================================================================================

}