#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

Class BnsDroidChimeraLab {
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

    FIGHTING_MODE := 1    ;0:alone, 1:specific, 2:all

    ; FIGHTING_MEMBERS := "1,2,3,4"    ;action member
    ; FIGHTING_MEMBERS := "1,2,3"    ;action member
    ; FIGHTING_MEMBERS := "1,2"    ;action member
    ; FIGHTING_MEMBERS := "1"    ;action member

    ;戰鬥成員狀態(array)
    fighterState := [1,1,1,1]


    ;傳點類別
    TELEPORT_TYPE :=

    ;左傳點座標
    L_AREA_TP_X :=
    L_AREA_TP_Y :=

    ;右傳點座標
    R_AREA_TP_X :=
    R_AREA_TP_Y :=


;================================================================================================================
;█ Interface
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;* @return - .cp file; empty means not used.
    getCharacterProfiles() {
        return ""
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 廣場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------
    dungeonNavigation() {
        return BnsOuF8DefaultGoInDungeon(2, 0)    ;封魔進場, 不確認過圖
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

            case 1:
                return this.runnableSpecific()

            case 2:
                return this.runnableAll()
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

    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runnableSpecific() {
        this.runStageClearEnteryGateB3()

        if(this.runStageClearMiniBoss1st() != 2) {
            this.runStageClearGasRoom()
            this.runStagePassPoisonPool()
        }

        this.runStageClearMiniBoss2nd()

        loop {
            ret := this.runStageFightFinalBoss()

            if(ret == 0) {
                ;復活重來
                BnsStopAutoCombat()

                sleep 8000
                loop 10 {
                    ControlSend,,{4}, %res_game_window_title%
                    sleep 100
                }
                sleep 6000
                BnsWaitMapLoadDone()
                sleep 2000

                this.takeDragonPulse(3) ;搭龍脈回去
            }
            else {
                break
            }
        }
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runnableAll() {
    }



;================================================================================================================
;█ Functions - STAGE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 第一階段: 開啟 B3 入口閘門
    ;------------------------------------------------------------------------------------------------------------
    runStageClearEnteryGateB3() {
        ShowTipI("●[Mission1] - Start to clear the enemies and reach the Gate")

        ;開場房間
        BnsActionWalkToPosition(860, -640, 0x01)
        BnsActionWalkToPosition(754, -1255, 0x04)
        BnsActionSprintToPosition(700, -2780)
        ShowTipI("●[Mission1] - Clear first gate")
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 20)
        BnsStopAutoCombat()

        ;人肉電梯
        ShowTipI("●[Mission1] - Fall to B3")
        this.actionGoFallToB3()

        ;等待脫戰
        loop {
            if(BnsIsLeaveBattle()) {
                break
            }
            sleep 1000
        }

        sleep 1500

        ;清除隨機閘門區, 移動引怪
        BnsStartHackSpeed()
        BnsActionSprintToPosition(2800, -1900)
        sleep 1200
        BnsActionSprintToPosition(4340, -2000)
        sleep 1200
        BnsActionSprintToPosition(3700, -1700)
        sleep 2000

        ;是否是需要清怪
        if(BnsIsLeaveBattle()) {
            ShowTipI("●[Mission1] - Second Gate has open, mission completed")
        }
        else {
            ShowTipI("●[Mission1] - Clear second gate area")
            BnsStartHackSpeed()
            BnsStartAutoCombat()
            sleep 1000

            BnsIsEnemyClear(1000, 20)
            BnsStopAutoCombat()
            BnsActionSprintToPosition(3700, -1700)

            BnsActionSprintToPosition(3700, -300)   ;引誘門口3氣功
            sleep 1500
            BnsActionSprintToPosition(3700, -1500)
            sleep 6000                              ;等3氣功離開門口
            BnsActionAdjustDirection(90)
            BnsStartAutoCombat()
            BnsIsEnemyClear(3000, 30)
            BnsStopAutoCombat()
            BnsStopHackSpeed()

            ShowTipI("●[Mission1] - Enermy clear, mission completed")
        }

        BnsActionAdjustDirection(90)
        sleep 1000

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 對戰一王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageClearMiniBoss1st() {
        ShowTipI("●[Mission2] - Clear gate of B4 Boss1 room")
        BnsStartHackSpeed()
        ; BnsActionSprintToPosition(3720, 3200)
        ; sleep 1000
        ; BnsStopHackSpeed()
        BnsActionSprintToPosition(3728, 4770)   ;一王前閘門
        sleep 2000

        ShowTipI("●[Mission2] - Clear enermies of B4 gate")
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 30)
        BnsStopAutoCombat()

        ShowTipI("●[Mission2] - Go to fight mini boss1")
        BnsActionSprintToPosition(3740, 5430, 0x1)  ;一王前走廊
        BnsActionSprintToPosition(5000, 5600, 0x2)
        BnsActionSprintToPosition(4290, 8840, 0x4)

        ShowTipI("●[Mission2] - fight mini boss1...")
        BnsStartAutoCombat()    ;對戰一王

        dsleep(5000)
        BnsStopAutoCombat()
        ControlSend,,{q}, %res_game_window_title%
        BnsStartAutoCombat()

        dsleep(6500)
        BnsStopAutoCombat()
        ControlSend,,{e}, %res_game_window_title%
        BnsStartAutoCombat()
        if(BnsIsEnemyClear(1500, 300) != 1) {
            return 0
        }
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        ;開啟龍脈
        BnsStartHackSpeed()
        BnsActionSprintToPosition(3190, 9060)
        sleep 1500

        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission3] - trigger dragon pulse")
            ControlSend,,{f}, %res_game_window_title%
            sleep 5000
        }
        BnsStopHackSpeed()

        ;確認龍脈
        BnsActionSprintToPosition(2750, 8900)
        sleep 1500
        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission3] - Detected dragon pulse")
            ControlSend,,{f}, %res_game_window_title%
            return 2
        }

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 清理瓦斯毒氣室
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageClearGasRoom() {

        BnsStartHackSpeed()
        BnsActionSprintToPosition(-840, 8862)  ;第一引怪點
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 30)
        BnsStopAutoCombat()

        BnsActionSprintToPosition(-4720, 8900)  ;第二引怪點
        sleep 1000

        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 30)
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        loop 3 {
            BnsActionSprintToPosition(-4570, 7740)  ;防毒機關

            if(BnsIsAvailableTalk() != 0) {
                ShowTipI("●[Mission3] - disable poison gas mechanism")
                ControlSend,,{f}, %res_game_window_title%
                sleep 5000
            }
            else {
                break
            }
        }

        BnsStartHackSpeed()
        BnsActionSprintToPosition(-4920, 7180, 0x1)     ;樓梯
        BnsActionSprintToPosition(-6890, 7180, 0x4)     ;樓梯
        BnsStopHackSpeed()
        BnsActionAdjustDirection(270)                   ;調整方向
        BnsWaitingLeaveBattle()
        BnsActionSprintJump(1600)
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-6840, 5720, 0x1)     ;對面平台
        BnsActionSprintToPosition(-6340, 5420, 0x4)     ;對面平台往毒池
        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 飛越毒池
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStagePassPoisonPool() {
        this.actionPassPoisonPool()

        sleep 1000
        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission4] - Turn off gas")
            ControlSend,,{f}, %res_game_window_title%
            sleep 3000
        }
        ; BnsActionSprintToPosition(-6240, -2304)  ;龍脈

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 對戰二王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageClearMiniBoss2nd() {
        ShowTipI("●[Mission5] - fighting to mini boss2")
        BnsActionSprintToPosition(-6300, -2920)  ;二王攻擊位置

        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsActionAdjustCamaraAltitude(330)  ;往下看,避免環境取色誤判
        BnsIsEnemyClear(1500, 30)
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第六階段: 對戰尾王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageFightFinalBoss() {
        ret := 0

        ;前往尾王
        this.actionGoToFinalRoom()

        ;判定傳送點
        this.TELEPORT_TYPE := this.detectTeleportType()
        ShowTipI("●[Mission6] - start fight final boss")

        BnsStartHackSpeed()
        ;開打BOSS, 每9秒就啟動換邊

        loop {
            ShowTipI("●[Mission6] - fighting...")
            BnsStartAutoCombat()

            state := this.fightStateChanged()
            ShowTipI("●[Mission6] - on fighting state changed, state: " state)

            switch state {
                case 1, 2:   ;交換對戰區域
                    ShowTipI("●[Mission6] - switch fighting Area")
                    BnsStopAutoCombat()

                    if(this.getBossArea() == 0) {   ;身在左邊
                        BnsActionSprintToPosition(this.L_AREA_TP_X, this.L_AREA_TP_Y,, 3000)   ;走傳點到毒雪
                        ; BnsActionSprintToPosition(this.L_AREA_TP_X, this.L_AREA_TP_Y)   ;走傳點到毒雪
                    }
                    else {  ;身在右邊
                        BnsActionSprintToPosition(this.R_AREA_TP_X, this.R_AREA_TP_Y,, 3000)   ;走傳點到惡延
                        ; BnsActionSprintToPosition(this.R_AREA_TP_X, this.R_AREA_TP_Y)   ;走傳點到惡延
                    }

                    sleep 1000
                    BnsStartAutoCombat()

                case 3:     ;戰鬥結束
                    ShowTipI("●[Mission6] - Mission completed")
                    ret := 1
                    break

                case 4:     ;角色死亡
                    ShowTipI("●[Mission6] - WARNING, charactor dead")
                    ret := 0
                    break
            }
        }

        BnsStopHackSpeed()

        return ret
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 最後階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ;暫時方案
        BnsStartHackSpeed()
        if(this.getBossArea() != 1) {   ;不是在毒雪房(右), 移動到毒雪房
            BnsActionSprintToPosition(this.L_AREA_TP_X, this.L_AREA_TP_Y,, 3000)
        }

        BnsStopHackSpeed()
        BnsStartAutoCombat()
        sleep 5000
        BnsStopHackSpeed()

        BnsWaitingLeaveBattle()
    }




;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 人肉電梯
    ;------------------------------------------------------------------------------------------------------------
    actionGoFallToB3() {
        ;人肉電梯
        BnsActionSprintToPosition(2000, -2770)
        msleep(1000)
        ControlSend,,{Space}, %res_game_window_title%

        BnsStartHackSpeed()
        BnsActionSprintToPosition(5000, -2630)
        BnsStopHackSpeed()
        ControlSend,,{Space}, %res_game_window_title%
        msleep(1500)
        ControlSend,,{Space}, %res_game_window_title%

        BnsStartHackSpeed()
        BnsActionSprintToPosition(3140, -3670)
        BnsStopHackSpeed()
        ControlSend,,{Space}, %res_game_window_title%
        msleep(1800)
        ControlSend,,{Space}, %res_game_window_title%
        msleep(200)
        ControlSend,,{Space}, %res_game_window_title%

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 飛越毒池
    ;------------------------------------------------------------------------------------------------------------
    actionPassPoisonPool() {
        BnsStopHackSpeed()
        BnsActionSprintToPosition(-6330, 4882)  ;毒池跳台
        BnsActionWalkToPosition(-6000, 2920, 0x1, 1000)  ;目標毒池中繼點跳涯
        dsleep(30)
        ControlSend,,{Space}, %res_game_window_title%   ;滑翔
        dsleep(30)

        BnsStartHackSpeed()
        BnsActionWalkToPosition(-6000, 2920, 0x2)  ;毒池中繼點
        BnsStopHackSpeed()

        BnsActionSprintToPosition(-6020, 920, 0x4)  ;毒池對岸
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-6240, 450)  ;毒池出口前樓梯
        BnsActionSprintToPosition(-6240, -1740)  ;毒池機關
        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往尾王
    ;------------------------------------------------------------------------------------------------------------
    actionGoToFinalRoom() {
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-6300, -7350)  ;王房分叉口

        ;右邊
        ; BnsActionSprintToPosition(-8734, -8200)  ;右轉(地圖左邊)
        ; BnsActionSprintToPosition(-7930, -10490,, 2000)  ;左邊王房

        ;左邊
        BnsActionSprintToPosition(-3820, -8200)  ;左轉(地圖左邊)
        BnsActionSprintToPosition(-3820, -9850,, 900)  ;右邊王房

        ControlSend,,{Space}, %res_game_window_title%
        msleep(100)
        ControlSend,,{Space}, %res_game_window_title%
        BnsActionSprintToPosition(-3820, -9850)  ;右邊王房
        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 搭龍脈
    ;------------------------------------------------------------------------------------------------------------
    takeDragonPulse(cate := 0) {
        switch cate {
            case 1: ;門口 - 一王前龍脈

            case 2: ;一王後 - 二王前龍脈

            case 3: ;尾王直達龍脈
                BnsActionSprintToPosition(880, -665, 0x1)  ;入口門前
                BnsActionSprintToPosition(830, -950, 0x2)  ;入口門後
                BnsActionSprintToPosition(530, -1160, 0x4)  ;尾王龍脈
                sleep 300
                if(BnsIsAvailableTalk() != 0) {
                    ShowTipI("●[Mission3] - Detected dragon pulse")
                    ControlSend,,{f}, %res_game_window_title%
                    sleep 8000
                }
        }

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 判定傳送點
    ;------------------------------------------------------------------------------------------------------------
    ;傳送點類別;  [ return ] 1: ( | );  2: ( — ); 4: ( \ ); 8: ( / )
    detectTeleportType() {
        ret := 0

        BnsStartHackSpeed()
        BnsActionSprintToPosition(-3825, -10000) ;引王
        dsleep(2000)


        ;右邊 - 毒雪, 傳點偵測 -------------------------------------------------------
        BnsActionSprintToPosition(-3830, -9740) ;毒雪, 試探12點傳點是否會換邊
        dsleep(500)

        if(this.getBossArea() == 0) {   ;確實換到了惡延區
            ;毒雪區為 12 - 6 傳點 ( | )

            ; 12點傳點
            this.R_AREA_TP_X := -3830
            this.R_AREA_TP_Y := -9740

            DumpLogD("[●Action] detectTeleportType: RIGHT - A ( | )")
            ret := ret | 0x01
        }
        else {  ;沒有變化, 不是傳點位置
            ;毒雪區為9 - 3 傳點 ( — )

            ; 9點傳點
            this.R_AREA_TP_X := -4550
            this.R_AREA_TP_Y := -10460

            ;移動到惡延(左)
            BnsActionSprintToPosition(this.R_AREA_TP_X, this.R_AREA_TP_Y)
            dsleep(300)

            DumpLogD("[●Action] detectTeleportType: RIGHT - B ( — )")
            ret := ret | 0x02
        }

        ;左邊 - 惡延, 傳點偵測 -------------------------------------------------------
        BnsActionSprintToPosition(-8240, -11000) ;惡延, 試探8點傳點是否會換邊
        dsleep(4000)

        if(this.getBossArea() == 1) {   ;確實換到了毒雪區
            ;惡延區為 10 - 4 傳點 ( \ )

            ; 4點傳點
            this.L_AREA_TP_X := -8240
            this.L_AREA_TP_Y := -11000

            DumpLogD("[●Action] detectTeleportType: LEFT - A ( \ )")
            ret := ret | 0x04
        }
        else {  ;沒有變化, 不是傳點位置
            ;惡延區為 2 - 8 傳點 ( / )

            ; 8點傳點
            this.L_AREA_TP_X := -9280
            this.L_AREA_TP_Y := -11020

            ;移動到毒雪(右)
            BnsActionSprintToPosition(this.L_AREA_TP_X, this.L_AREA_TP_Y)
            dsleep(300)

            DumpLogD("[●Action] detectTeleportType: LEFT - B ( / )")
            ret := ret | 0x08
        }

        BnsStopHackSpeed()

        return ret
    }




;================================================================================================================
;█ Functions - STATUS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 判定戰區
    ;* @return - 0: left; 1: right
    ;------------------------------------------------------------------------------------------------------------
    getBossArea() {
        if(GetMemoryHack().getPosX() > -6300) {
            DumpLogD("[State] getBossArea: Right(1)")
            return 1    ;right
        }

        DumpLogD("[State] getBossArea: Left(0)")
        return 0    ;left
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥狀態改變
    ;* @return - 0: no; 1: yes
    ;------------------------------------------------------------------------------------------------------------
    fightStateChanged() {
        ret := 0

        tick := A_TickCount

        loop {

            if(BnsIsCharacterDead() > 0) {
                ShowTipI("[State] - " A_ThisFunc ", character dead")
                ret := 4
                break
            }


            if(this.getBossBlood() == 0 && this.isBoss()) {  ;結束戰鬥,
                ShowTipI("[State] - " A_ThisFunc ", boss clear")
                ret := 3
                break
            }

            if(this.getBossBlood() == 1 && this.isBoss()) {  ;單邊結束, 立即換邊
                ShowTipI("[State] - " A_ThisFunc ", boss blood 1")
                ret := 2
                break
            }

            if(A_TickCount - tick > 8500) {    ;超時換邊
                ShowTipI("[State] - " A_ThisFunc ", 10s times up")
                ret := 1
                break
            }

            sleep 100
        }

        ShowTipI("●[Action] - " A_ThisFunc ", ret:" ret)
        return ret
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS血量
    ;------------------------------------------------------------------------------------------------------------
    getBossBlood() {
        return GetMemoryHack().getMainTargetBlood()
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS血量白分比
    ;------------------------------------------------------------------------------------------------------------
    getBossBloodPercent(checkPoint) {
        return floor(GetMemoryHack().getMainTargetBlood() / GetMemoryHack().getMainTargetBloodFull() * 100)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS
    ;------------------------------------------------------------------------------------------------------------
    isBoss() {
        return (GetMemoryHack().getMainTargetBloodFull() == 6855200000 || GetMemoryHack().getMainTargetBloodFull() == 7068400000)
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {

    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 是否需要競標
    ;* @return - 0: no; 1: yes
    ;------------------------------------------------------------------------------------------------------------
    isBidding() {

        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 100, "res\pic_bidding_form_icon") == 1) {
            return 1
        }

        return 0
    }





}
