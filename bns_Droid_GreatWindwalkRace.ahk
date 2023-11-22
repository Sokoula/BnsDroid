#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



Class BnsDroidGreatWindwalkRace {
    ;AHK class constructor
    __new() {
        RACE_FORM_SX := 525
        RACE_FORM_SY := 380
    
        RACE_FORM_EX := 1630
        RACE_FORM_EY := 765
    


        this.RACE_FORM_POS_Y := RACE_FORM_SY + ((RACE_FORM_EY - RACE_FORM_SY) // 2)

        loop 5 {
            this.RACE_FORM_POS_X.push(RACE_FORM_SX + (((RACE_FORM_EX - RACE_FORM_SX) // 5) // 2) + ((RACE_FORM_EX - RACE_FORM_SX) // 5) * (A_Index - 1))
        }

        return this
    }

    ;AHK class destructor
    __delete() {
    }


;================================================================================================================
;█ Variables
;================================================================================================================
    RACE_FORM_POS_X := Array()
    RACE_FORM_POS_Y :=

    MENU_BUTTON_X := 1400
    MENU_BUTTON_Y := 570

;================================================================================================================
;█ Interface
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 廣場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------    
    dungeonNavigation() {

        ;ESC 選單 -> 天下第一輕功大會
        if(A_Min >= 30) {
            Msgbox % "非活動入場時間!"
            return 0
        }

        ControlSend,,{ESC}, %res_game_window_title%   ;ESC Menu
        sleep 300
        MouseClick, left, this.MENU_BUTTON_X, this.MENU_BUTTON_Y
        sleep 1000

        switch A_Hour {
            case 00:
                MouseClick, left, this.RACE_FORM_POS_X[1], this.RACE_FORM_POS_Y

            case 12:
                MouseClick, left, this.RACE_FORM_POS_X[2], this.RACE_FORM_POS_Y

            case 15:
                MouseClick, left, this.RACE_FORM_POS_X[3], this.RACE_FORM_POS_Y

            case 18:
                MouseClick, left, this.RACE_FORM_POS_X[4], this.RACE_FORM_POS_Y

            case 21:
                MouseClick, left, this.RACE_FORM_POS_X[5], this.RACE_FORM_POS_Y
            
            Default:
                return 0
        }

        sleep 5000
        BnsWaitMapLoadDone()
        sleep 1000

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 執行腳本
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    start() {
        return this.runnableAlone()
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
    ;------------------------------------------------------------------------------------------------------------
    ;* @return - 1: success; 0: failed
    runnableAlone() {
        this.runStageWaitingStart()
        this.runStageAreaRiverMouth()
        this.runStageAreaFlotingChain()
        this.runStageAreaUphill()
        this.runStageAreaSnowMountain()
        this.runStageAreaPeakFinish()

        return ret
    }


;================================================================================================================
;█ Functions - STAGE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 第一階段: 起跑點等待起跑
    ;------------------------------------------------------------------------------------------------------------
    runStageWaitingStart() {
        ShowTipI("●[Mission] - Start mission")

        BnsActionWalkToPosition(13590, -16880)
        sleep 25000

        ShowTipI("●[Mission] - Waitting for count down")
        loop {
            BnsActionWalkToPosition(13590, -16600,,1000)    ;偵測是否開始

            if(GetMemoryHack().getPosY() > -16880) {
                ShowTipI("●[Mission] - Racing...")
                break
            }
            sleep 1000
        }

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 河口區域
    ;------------------------------------------------------------------------------------------------------------
    runStageAreaRiverMouth() {
        ;2.起始平台跨欄 - 平台尾瑞  ---------------------------------------------------------------
        BnsStartHackSpeed()
        ; BnsActionSprintToPosition(13578, -15214, 0x1)
        ; ControlSend,,{Space}, %res_game_window_title%
        ; BnsActionSprintToPosition(13578, -14503, 0x2)
        ; ControlSend,,{Space}, %res_game_window_title%
        ; BnsActionSprintToPosition(13578, -13779, 0x2)
        ; ControlSend,,{Space}, %res_game_window_title%
        ; BnsActionSprintToPosition(13578, -13062, 0x2)
        ; ControlSend,,{Space}, %res_game_window_title%

        BnsActionSprintToPosition(13300, -15150, 0x1)
        BnsActionSprintToPosition(13880, -14470, 0x2)
        BnsActionSprintToPosition(13300, -13750, 0x2)
        BnsActionSprintToPosition(13880, -13000, 0x2)
        BnsActionSprintToPosition(13584, -11740, 0x2)   ;開始平台最邊緣

        BnsStopHackSpeed()
        

        ;3.起始平台尾瑞 - 過河起跳石頂 ------------------------------------------------------------
        BnsActionSprintToPosition(13450, -7260, 0x4, 500)   ;離開起始平台 500ms , 目標起跳石底
        dsleep(30)
        ControlSend,,{Space}, %res_game_window_title%   ;滑翔
        dsleep(30)
        
        BnsStartHackSpeed()
        BnsActionSprintToPosition(13450, -7260,,500)   ;目標起跳石底, 仙速輕功飛行 500ms 以驗證是否有成功進滑翔
        dsleep(300)
        BnsStopHackSpeed()

        loop 3 {    ;滑翔失敗，重試回到正確道路
            if(GetMemoryHack().getPosZ() < -12660 && GetMemoryHack().getPosY() < -10000) {
                ShowTipI("●[Exception] - Failed to glide, climb back to stone, retry " A_index)
                BnsActionSprintToPosition(13568, -10464)        ;移動到失敗起跳點
                BnsActionAdjustDirection(88)                    ;調整方向
                BnsActionSprintJump(1500)
            }
            else {
                ShowTipI("●[Mission] - Failed to glide, climb back to stone, SUCCESS")
                break
            }
        }

        if(GetMemoryHack().getPosZ() < -12660) {    ;重試失敗
            ShowTipI("●[Mission] - Failed to glide, climb back to stone, FAILED")
            return 0
        }

        ShowTipI("●[Mission] - Racing...")

        BnsStartHackSpeed()
        BnsActionSprintToPosition(13450, -7260,, 8000)    ;起跳石底
        BnsActionSprintToPosition(12030, -6200,, 5000, 80)    ;起跳石頂(藍龍脈)
        sleep 200


        ;4. 起跳石頂 - 音符陷阱平台 ---------------------------------------------------------------
        BnsStopHackSpeed()
        BnsActionSprintToPosition(11800, -6080, 0x1, 5000)    ;起跳石頂(往前衝不搭龍脈)
        ControlSend,,{Space}, %res_game_window_title%
        BnsStartHackSpeed()
        BnsActionSprintToPosition(11100, -5800, 0x4, 5000, 80)      ;起跳石頂(陷阱平台起始)
        if(!BnsActionSprintToPosition(11100, -5800,,5000, 80))  {       ;起跳石頂(陷阱平台起始)
            return 0
        }

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 懸空鎖鍊區域
    ;------------------------------------------------------------------------------------------------------------
    runStageAreaFlotingChain() {
        loop 3 {

            ;5. 音符陷阱平台 - 懸空鎖鍊 ---------------------------------------------------------------
            BnsStartHackSpeed()
            BnsActionSprintToPosition(9350, -3450)          ;陷阱平台尾鎖鍊前
            BnsStopHackSpeed()

            BnsActionWalkToPosition(9260, -3200)            ;鎖鍊一頭


            ;6. 懸空鎖鍊 - 二區山坡前 -----------------------------------------------------------------
            BnsStartHackSpeed()
            if(!BnsActionSprintToPosition(8930, 500, 0x1, 5000)) {       ;鎖鍊一尾中繼浮石前
                continue
            }
            BnsStopHackSpeed()

            BnsActionSprintToPosition(8537, 1097, 0x2, 5000)      ;爬中繼浮石
            BnsActionAdjustDirection(158)                   ;面向鎖鍊二
            ControlSend,,{Space}, %res_game_window_title%   ;脫離浮石
            dsleep(500)
            ControlSend,,{Space}, %res_game_window_title%   ;輕功滑翔
            
            BnsStartHackSpeed()
            if(!BnsActionSprintToPosition(7695, 1355, 0x4, 5000)) {      ;降落到鎖鍊二頭
                continue
            }

            ControlSend,,{Space}, %res_game_window_title%
            dsleep(100)
            if(!BnsActionSprintToPosition(4450, 1540,, 5000)) {          ;鎖鍊二尾
                continue
            }

            BnsStopHackSpeed()
            dsleep(100)

            BnsActionSprintToPosition(4150, 1580,,5000 ,100)     ;鎖鍊二尾上石峰
            dsleep(300)
            BnsActionSprintToPosition(3700, 1800,,5000)           ;石峰涯前起跳點

            BnsActionAdjustDirection(160)                   ;調整方向
            BnsStartHackSpeed()
            ; BnsActionGliding(4000, 1, 1)                     ;滑翔過涯
            BnsActionGliding(500, 1, 1)                     ;滑翔過涯(仙速)
            if(BnsActionSprintToPosition(2343, 2307,, 5000)) {           ;過涯起始點(防失手爬牆)
                dsleep(100)
                return 1
            }

            ;等待復活回到陷阱平台
        }

        return 0
    }

 
    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 陷阱山坡區
    ;------------------------------------------------------------------------------------------------------------
    runStageAreaUphill() {
        ;7. 二區山坡前 - 雪球坡道底 ---------------------------------------------------------------
        BnsStartHackSpeed()
        BnsActionSprintToPosition(1460, 2300, 0x1)      ;第一地雷
        BnsActionSprintToPosition(1040, 1750, 0x1)      ;上坡轉折1
        BnsActionSprintToPosition(540, 1450, 0x2)       ;上坡轉折2
        BnsActionSprintToPosition(-20, 1360, 0x4)       ;山澗風道前
        ; BnsStopHackSpeed()
        dsleep(100)
        BnsActionAdjustDirection(186)                   ;調整方向
        ; BnsActionGliding(2000, 1)                       ;滑翔過山澗
        BnsActionGliding(700, 1)                       ;滑翔過山澗

        loop 3 {
            if(GetMemoryHack().getPosX() > -1200 || GetMemoryHack().getPosZ() < -7000) {         ;跳山澗掉下去
                BnsStopHackSpeed()
                ShowTipI("●[Exception] - Failed to jump and fell into a mountain ravine, retry " A_index)
                BnsActionSprintToPosition(-1000, 1670)
                BnsActionAdjustDirection(113)               ;調整方向
                BnsActionSprintJump(2000)
                BnsActionAdjustDirection(257)               ;調整方向
                BnsActionSprintJump(500)
                BnsStartHackSpeed()
            }
            else {
                ShowTipI("●[Mission] - Escape from mountain ravine, SUCESS")
                break
            }
        }

        if(GetMemoryHack().getPosZ() < -6900) {     ;重跳還是失敗
            ShowTipI("●[Exception] - Escape from mountain ravine, FAILED")
            return 0
        }

        ShowTipI("●[Mission] - Racing...")
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-1824, 876,, 8000)      ;山澗後左邊補給點
        ; BnsActionSprintToPosition( -2039 952, 0x2, 8000)      ;山澗後左邊補給點
        if(!BnsActionSprintToPosition(-4340, 1250,, 5000)) {     ;雪球坡底
            return 0
        }

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 雪山垂升區域
    ;------------------------------------------------------------------------------------------------------------
    runStageAreaSnowMountain() {

        ;8. 雪球坡道底 - 垂直鎖鍊完 ---------------------------------------------------------------
        loop 5 {
            BnsStartHackSpeed()
            BnsActionSprintToPosition(-7325, 1266,, 10000)         ;雪球坡道頂
            dsleep(100)
            ; BnsActionSprintToPosition(-7440, 440,, 5000)         ;左側補給小平台上
            
            BnsActionSprintToPosition(-7436, 770,, 5000)           ;左側補給小平台右側
            BnsActionSprintToPosition(-7400, 390,, 5000)           ;左側補給小平台上

            BnsStopHackSpeed()

            BnsWaitingLeaveBattle()                         ;等待脫戰
            dsleep(100)

            BnsActionAdjustDirection(90)                    ;調整方向往回起跳
            dsleep(500)
            ; BnsActionGliding(1850, 0, 1)                    ;起跳滑翔, 1950ms 算好的, 不要用仙速
            ; BnsActionAdjustDirection(2)                     ;對準鎖鍊, 算好別動

            BnsActionGliding(200, 0, 1)                        ;起跳滑翔, 1950ms 算好的, 不要用仙速
            BnsActionSprintToPosition(-7400, 1200)           ;左側補給小平台右側
            BnsActionAdjustDirection(359)                     ;對準鎖鍊, 算好別動

            dsleep(100)
            BnsStartHackSpeed()
            BnsActionSprintToPosition(-6519, 1200,, 4000)   ;垂直鎖鍊頂

            if(GetMemoryHack().getPosZ() > -3700) {         ;高度正確(爬成功)
                ShowTipI("●[Mission] - Failed to climb with the chain, SUCCESS")*
                break
            }
            else {
                ShowTipI("●[Exception] - Failed to climb with the chain, retry " A_index)
            }
        }

        if(GetMemoryHack().getPosZ() < -3700) {             ;高度不正確(爬失敗)
            ShowTipI("●[Exception] - Failed to climb with the chain, FAILED")
            return 0                                        ;回伺服器重排下一場(TBD)
        }

        ShowTipI("●[Mission] - Racing...")
        BnsStopHackSpeed()


        ;9. 垂直鎖鍊完 - 跨島鎖鍊頂 ---------------------------------------------------------------
        BnsWaitingLeaveBattle()                         ;等待脫戰
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-6261, 790, 0x1)      ;往右避開地雷
        BnsActionSprintToPosition(-5959, 804, 0x4)      ;往前起跳點對準鎖鍊
        ; BnsStopHackSpeed()
        BnsActionAdjustDirection(2)                     ;對準鎖鍊
        BnsActionGliding(1000, 0, 1)                    ;起跳滑翔

        ; BnsStartHackSpeed()
        BnsActionSprintToPosition(-4484, 860)           ;跨島鎖鍊上升段
        BnsActionSprintToPosition(-4080, 850)           ;跨島鎖鍊尾
        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第六階段: 山頂終點區
    ;------------------------------------------------------------------------------------------------------------
    runStageAreaPeakFinish() {

        ;10. 跨島鎖鍊頂 - 終點 --------------------------------------------------------------------
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-2913, 1300, 0x1)     ;最後區樓梯下
        BnsActionSprintToPosition(-2505, 5, 0x2)        ;最後區樓梯中
        BnsActionSprintToPosition(-1670, 221, 0x4)      ;最後區樓梯上

        BnsStopHackSpeed()
        loop 3 {
            BnsActionSprintToPosition(-1670, 221,,, 80)           ;終點石階下
            BnsWaitingLeaveBattle()                         ;等待脫戰
            BnsActionAdjustDirection(47)                    ;對準終點
            BnsActionSprintJump(3000)

            if(GetMemoryHack().getPosZ() > -1230) {         ;高度正確(跳成功)
                ShowTipI("●[Mession] - Jump to goal, SUCCESS")
                break
            }
            else {

            }
        }

        if(GetMemoryHack().getPosZ() < -1230) {         ;高度不正確(跳失敗)
            ShowTipI("●[Exception] - Jump to goal, FAILED")
            return 0
        }

        ShowTipI("●[Mission] - Racing...")
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-197, 183)           ;終點
        BnsStopHackSpeed()
        ShowTipI("●[Mission] - Completed")

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第七階段: 離開副本
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ;11. 結束 ---------------------------------------------------------------------------------

        sleep 8000
        MouseClick, left, 1560, 960
        BnsWaitMapLoadDone()
    }



;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================



;================================================================================================================
;█ Functions - STATUS
;================================================================================================================

}