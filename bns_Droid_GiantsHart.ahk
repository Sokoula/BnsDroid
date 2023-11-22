#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

Class BnsDroidGiantsHart {
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

    SPECIAL_STAGE_HANDLE := 0    ;

    ; FIGHTING_MODE := 1    ;0:alone, 1:specific, 2:all
    FIGHTING_MODE := 0    ;0:alone, 1:specific, 2:all

    ; FIGHTING_MEMBERS := "1"    ;action member
    ; FIGHTING_MEMBERS := "1,2,3,4"    ;action member
    FIGHTING_MEMBERS := "1,2,3"    ;action member


    ;戰鬥成員狀態
    fighterState := 0


    ;是否完成特殊機制, 只在 SPECIAL_STAGE_HANDLE = 1 作用
    isStageSpecialDone := 0



;================================================================================================================
;█ Interface
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;* @return - .cp file; empty means not used.
    getCharacterProfiles() {
        return "GiantsHart.cp"
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 廣場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------
    dungeonNavigation() {

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 執行腳本
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    start() {
        this.isStageSpecialDone := 0    ;重置特殊機制 flag


        switch this.FIGHTING_MODE
        {
            case 0:
                return this.runnableAlone()

            case 1:
                return this.runnableTeam()

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
        ShowTipI("●[Mission] - Go to Gaint Hart")

        this.runStageF8Engage()
        this.runStageAcceptMission()
        this.runStageGoDestination(BnsCmGetArg1())
        this.runStageFight()

        return 1

    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runnableTeam() {
        return 1
    }


;================================================================================================================
;█ Functions - STAGE
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 第一階段: 進入巨神
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageF8Engage() {
        send {f8}
        sleep 2000
        MouseClick left, 640, 430
        sleep 5000
        BnsWaitMapLoadDone()
        sleep 2000
        BnsActionWalk(1200)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 接任務
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageAcceptMission() {
        BnsActionLateralWalkLeft(1400)
        sleep 500

        send {f}
        sleep 2000

        if(FindPicList(WIN_THREE_QUARTERS_X, WIN_THREE_QUARTERS_Y, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_f8_menu_exit") == 1) {
            loop 2 {
                send {Esc}
                sleep 200
            }
        }
        else {
            loop 2 {
                send {f}
                sleep 200
            }

            sleep 500
            send {y}
        }

        sleep 500
        BnsActionLateralWalkRight(2400)
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 移動到目的地
    ;* @param level - floor of destination, 1: 1st floor; 2: B2
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageGoDestination(level := 1) {
        ShowTipI("●[Mission] - Get mission from bulletin")
        BnsActionLateralWalkRight(800)
        sleep 500
        send {f}
        sleep 2000



        switch level
        {
            case 0:

            case 1:
                ShowTipI("●[Mission] - Navigate to destination: Ground")
                BnsActionLateralWalkLeft(11000)
                BnsActionCornerSprintUpLeft(25000)
                BnsActionLateralWalkLeft(3000)

            case 2:
                ShowTipI("●[Mission] - Navigate to destination: B1")
                ;Ground
                BnsActionLateralWalkLeft(11000)
                BnsActionCornerSprintUpLeft(13000)
                BnsActionLateralWalkLeft(7000)
                sleep 3000
                BnsWaitMapLoadDone()

                ;B1
                BnsActionSprint(2500)
                BnsActionCornerSprintUpRight(8500)
                BnsActionSprint(8500)
                BnsActionCornerSprintUpRight(9500)
                BnsActionSprint(3000)
                BnsActionCornerSprintUpRight(3000)
                BnsActionSprint(3000)
                BnsActionCornerSprintUpLeft(6000)
                BnsActionSprint(7000)
                BnsActionCornerSprintUpRight(8000)
                BnsActionLateralWalkRight(18000)
                BnsActionCornerSprintUpRight(12000)
        }

        ShowTipI("●[Mission] - Reach the destination")
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 開始打怪
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageFight() {
        BnsStartHackSpeed()
        BnsStartAutoCombat()    ;start
        sleeptime := (BnsCmGetArg2() == 0 ? 60 : BnsCmGetArg2()) * 60 * 1000    ;預設戰鬥60分鐘

        DumpLogD("★[DEBUG] - runStageFight, sleep time:" sleeptime)

        ShowTipI("●[Mission] - Fighting start, time:" floor(sleeptime / 60000) "mins")

        timeBlock := floor(sleeptime / 5)
        DumpLogD("★[DEBUG] - runStageFight, block time:" timeBlock)
        loop 5 {
            msleep(timeBlock)
            ShowTipI("●[Mission] - Fighting expired time:" floor((timeBlock * (5 - A_index)) / 60000) "mins")
        }

        ShowTipI("●[Mission] - Fighting stop, time up")
        BnsStopAutoCombat()    ;stop
        sleep 3000
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 收尾
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ShowTipI("●[Mission] - Ending, forced disengagement")
        BnsActionAdjustDirectionOnMap(30)
        BnsActionWalk(10000)
        BnsStopHackSpeed()

        ;自動回報任務
        Send {alt Down}
        sleep 200
        MouseClick, left, 1700, 415
        sleep 200
        Send {alt Up}
        sleep 1000
        Send {f}
        sleep 5000
    }

;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員開啟自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    startTeamAutoCombat(mids := "1,2,3,4") {
        fn := func("BnsStartStopAutoCombat")
        ; BnsPcTeamMemberAction(fn)    ;全員開始自動戰鬥
        BnsPcTeamMemberAction(fn, StrSplit(mids,","))    ;全員開始自動戰鬥
    }



;================================================================================================================
;█ Functions - STATUS
;================================================================================================================

}
