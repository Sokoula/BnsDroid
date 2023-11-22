#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk



Class BnsDroidShroudedAjanara {
    ;AHK class constructor
    __new() {
        return this
    }

    ;AHK class destructor
    __delete() {
    }

;================================================================================================================
;█ VariablesAVOID_
;===========AVOID_=====================================================================================================
    ;入門千手卡片
    EASY_CARD_X := 850
    EASY_CARD_Y := 580

    ;一般千手卡片
    NORMAL_CARD_X := 970
    NORMAL_CARD_Y := 580

    ;門外載入點
    LOAD_POX_X := -15712    
    LOAD_POX_Y := 57864
    
    ;千手入口機關
    ENTERY_POS_X := -16282.921
    ENTERY_POS_Y := 58350.269

    ;引誘 BOSS 離開中心點(離開王但不會被抓回去的距離)
    BAIT_POS_X := -14021.839
    BAIT_POS_Y := 53122.757
    
    ;千手正中心座標(王回中的位置)
    CENTER_POS_X := -13713.596
    CENTER_POS_Y := 52842.773

    SKYSTAY_POS_X := -13216.246094
    SKYSTAY_POS_Y := 53707.746094

    ;特殊機制整備座標
    EDGE_POS_X := -14710.527
    EDGE_POS_Y := 53852.906

    ;TYPE-A 廻避座標
    A_AVOID_POS_X := -14123.204
    A_AVOID_POS_Y := 53252.285

    ;TYPE-B 起跳座標
    B_JUMP_POS_X := -13771.625
    B_JUMP_POS_Y := 52902.152

    ;出口龍脈座標
    EXIT_PULSE_POS_X := -13322.669
    EXIT_PULSE_POS_Y := 52129.886




    attackMode := 0

;================================================================================================================
;█ Interface
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;------------------------------------------------------------------------------------------------------------
    ;讀取與 CP 檔; [ return ] 回傳 cp 檔名
    getCharacterProfiles() {
        return "ShroudedAjanara.cp"
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 入場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------    
    dungeonNavigation() {
        dist := BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y)[1]

        if(dist > 1421) {   ;1421 已經在千手場上
            if(dist < 5424 ) {
                BnsActionSprintToPosition(this.LOAD_POX_X, this.LOAD_POX_Y)
            }

            BnsActionWalkToPosition(this.ENTERY_POS_X, this.ENTERY_POS_Y)
            sleep 2000
            ; BnsActionWalkToPosition(this.ENTERY_POS_X, this.ENTERY_POS_Y)
            ; loop 3 {
                Send {f}
            ;     sleep 200
            ; }
            sleep 1000
            switch PARTY_MODE {
                case 1:
                    MouseClick left, this.EASY_CARD_X, this.EASY_CARD_Y
                case 2:
                    MouseClick left, this.NORMAL_CARD_X, this.NORMAL_CARD_Y
                case 3:
            }
            sleep 4000
            BnsWaitMapLoadDone()
            sleep 1000
        }

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 執行腳本
    ;------------------------------------------------------------------------------------------------------------
    ;Droid script stat; @return - 1: success; 0: failed
    start() {
        ; this.isStageSpecialDone := 0    ;重置特殊機制 flag
        switch PARTY_MODE {
            case 1:
                return this.runnableEasy()

            case 2:
                return this.runnableNormal()

            case 3:
        }

        
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 結束腳本
    ;------------------------------------------------------------------------------------------------------------
    ;Droid script finished; [@return] 1:success; 0:failed
    finish() {
        return this.runStageEnding()
    }

;================================================================================================================
;█ Functions - RUNNABLE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;------------------------------------------------------------------------------------------------------------
    ;Script runnable for specific; @return - 1: success; 0: failed
    runnableEasy() {
        BnsStartHackSpeed()
        loop {
            ShowTipI("●[Mission] - 開始戰鬥")
            BnsActionWalkToPosition(this.BAIT_POS_X, this.BAIT_POS_Y,,5000)
            BnsStartAutoCombat()
            
            sleep 500

            if(this.runStageFinished() == 1) {
                sleep 3000  ;預留撿箱時間
                BnsStopAutoCombat()
                BnsStopHackSpeed()
                ShowTipI("●[Mission] - 任務達成")
                break
            }
            else {
                ShowTipI("●[Mission] - 角色死亡, 40% 應對失敗")
                this.resurrection()
                continue
            }
        }
        BnsStopHackSpeed()
        return 1
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 腳本 ****
    ;------------------------------------------------------------------------------------------------------------
    ;Script runnable for specific; @return - 1: success; 0: failed
    runnableNormal() {

        loop {

            BnsStartHackSpeed()
            ShowTipI("●[Mission] - 開始戰鬥至 80%")
            BnsActionWalkToPosition(this.BAIT_POS_X, this.BAIT_POS_Y,,5000)
            BnsStartAutoCombat()

            sleep 3000
            this.baitBossMoveOutOfCenter()

            ;80%
            ; if(this.listenBloodPercent80()) {
            if(this.listenBloodPercent(80) == 1) {
                BnsStopAutoCombat()
                ShowTipI("●[Mission] - call runStageMechanics80")
                this.runStageMechanics80()
                ShowTipI("●[Mission] - call runStageMechanics80 done")
            }

            BnsStartHackSpeed()
            BnsStartAutoCombat()
            ShowTipI("●[Mission] - 繼續戰鬥至 40%")            
            ; sleep 5000     ;減少無用運算, 視機體而定

            sleep 4000
            this.baitBossMoveOutOfCenter()

            ;40%
            ; if(this.listenBloodPercent40() == 1){
            if(this.listenBloodPercent(40) == 1){
                BnsStopAutoCombat()
                this.runStageMechanics40()
            }
            else {
                ShowTipI("●[Mission] - 角色死亡, 80% 應對失敗")
                this.resurrection()
                continue
            }

            BnsStartHackSpeed()
            BnsStartAutoCombat()
            ShowTipI("●[Mission] - 繼續戰鬥至結束")
            sleep 5000


            if(this.runStageFinished() == 1) {
                sleep 3000  ;預留撿箱時間
                BnsStopAutoCombat()
                BnsStopHackSpeed()
                ShowTipI("●[Mission] - 任務達成")
                break
            }
            else {
                ShowTipI("●[Mission] - 角色死亡, 40% 應對失敗")
                this.resurrection()
                continue
            }
        }

        return 1
    }


;================================================================================================================
;█ Functions - STAGE
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 特殊階段: 80%
    ;------------------------------------------------------------------------------------------------------------
    runStageMechanics80() {
        this.evacuateToEdge()
        dsleep(200)

        loop {
            this.attackMode := this.adjuestMechanicsType()

            if(this.attackMode != 0) {
                break
            }

            sleep -1
        }

        ; dsleep(500)

        switch this.attackMode {
            case 1:     ;type A
                this.handleMechanicsTypeA()

            case 2:     ;type B
                this.handleMechanicsTypeB()
        }

    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 特殊階段: 40%
    ;------------------------------------------------------------------------------------------------------------
    runStageMechanics40() {
        this.evacuateToEdge()
        dsleep(200)

        loop {
            if(this.adjuestMechanicsType() != 0) {
                break
            }

            sleep -1
        }

        ; dsleep(500)

        if(this.attackMode == 1) {
            this.handleMechanicsTypeB()
        }
        else {
            this.handleMechanicsTypeA()
        }

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 收尾階段: 40% ~ 0%
    ;------------------------------------------------------------------------------------------------------------
    runStageFinished() {
        return BnsIsEnemyClear(1000, 600)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 結束
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        BnsActionWalkToPosition(this.EXIT_PULSE_POS_X, this.EXIT_PULSE_POS_Y)     ;精確走到固定位置
        sleep 500

        ;領取獎勵
        loop 3 {
            Send {f}
            sleep 1000
            Send (y)
            sleep 200
            Send {f}
            sleep 200
            Send {f}
            sleep 200
        }

        ;搭龍脈
        Send {f}
        sleep 6000
        BnsWaitMapLoadDone()
    }




;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 應對特殊機制A
    ;------------------------------------------------------------------------------------------------------------
    handleMechanicsTypeA() {
        ShowTipI("●[Action] - TYPE A: 原地硬吃6層")
        ; msleep(4300)    ;ori
        ; dsleep(4000)    ;劍
        ; dsleep(3900)      ;拳
        dsleep(4500)

        ; ShowTipD("TYPE A: 起身")*
        ; send {1} ;劍士起身
        ; dsleep(500)

        ShowTipI("●[Action] - TYPE A: CE 離開第7掌範圍")    ;可以省下起身的3秒
        BnsStartHackSpeed()
        BnsActionWalkToPosition(this.A_AVOID_POS_X, this.A_AVOID_POS_Y,,10000)
        dsleep(1000)
        ShowTipI("●[Action] - TYPE A: CE 回去吃第7層")    ;可以省下起身的3秒
        BnsActionWalkToPosition(this.EDGE_POS_X, this.EDGE_POS_Y,,5000)
        ; dsleep(700)
        dsleep(500)

        BnsActionWalkToPosition(this.A_AVOID_POS_X, this.A_AVOID_POS_Y,,5000)
        BnsActionRotationDegree180()
        BnsStopHackSpeed()

        ShowTipI("●[Action] - TYPE A: SS抵抗")
        send {s 2}
        dsleep(30)
        send {s 2}

        dsleep(500)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 應對特殊機制B
    ;------------------------------------------------------------------------------------------------------------
    handleMechanicsTypeB() {
        ShowTipI("●[Action] - TYPE B: 等待崩拳放完")
        ; msleep(2000)    ;ori
        ; dsleep(1900)
        dsleep(2300)

        ; 針對自帶加速buff的職業補償時間, 以免太快起跳
        ; role := "2,2,0,1,12000,2,60"
        ; switch BnsCcGetRole(role) {
        ;     case 2:
        ;         dsleep(350)

        ;     default:
        ; }

        sTime := A_TickCount
        ShowTipI("●[DEBUG] - stime: " sTime)
        BnsStartHackSpeed()    ;speed on
        ShowTipI("●[Action] - TYPE B: 踩前3圈")
        BnsActionWalkToPosition(this.B_JUMP_POS_X, this.B_JUMP_POS_Y,,5000, 30)
        BnsStopHackSpeed()    ;speed off

        eTime := A_TickCount
        dTime := eTime - sTime
        ShowTipI("●[DEBUG] - etime: " eTime " dTime:" dTime)

        wTime := (dTime > 1800) ? 0 : 1800 - dTime  

        ShowTipI("●[DEBUG] - wait time: " wTime)
        
        dsleep(wTime)


        ShowTipD("●[Action] - TYPE B: 輕功起跳躲飛高高")
        ; Send, {w Down}
        ; Send, {Shift}
        ; dsleep(200)    ;必需 > 200ms, 不然跳不起來
        ; Send, {Space Down}    ;Space 必需拆開寫，不然沒作用
        ; dsleep(50)
        ; Send, {Space Up}
        ; dsleep(400)            ;不要動這個, 需要 400ms 才能到最高點
        ; Send, {w Up}

        BnsActionSprintJump(400)    ;不要動這個, 需要 400ms 才能到需要的高度
        dsleep(50)
        Send, {Space Down}
        dsleep(50)
        Send, {Space Up}
        dsleep(500)            ;飄一段時間閃第一炸圈
        Send  {s Down}
        dsleep(300)              ;不要動這個, 這是落地所需時間
        Send  {s Up}
        dsleep(100)
        Send  {w Down}
        dsleep(50)
        Send {Shift}
        dsleep(50)
        Send {w Up}
        BnsActionRotationDegree180()
        dsleep(100)

        BnsStartHackSpeed()

        ShowTipD("●[Action] - TYPE B: 遠離第2次崩拳的範圍")    ;拉遠距離比較好處理
        BnsActionWalkToPosition(this.EDGE_POS_X, this.EDGE_POS_Y,,5000, 30)
        BnsActionRotationDegree180()

        dsleep(2500)
        ShowTipI("●[Action] - TYPE A: 踩後3圈")
        BnsActionWalkToPosition(this.B_JUMP_POS_X, this.B_JUMP_POS_Y,,5000, 30)

        ShowTipI("●[Action] - TYPE B: 貼王給3控")
        BnsStopHackSpeed()

        dsleep(200)
        this.brokeShield()

        dsleep(500)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 三控破盾
    ;------------------------------------------------------------------------------------------------------------
    brokeShield(role := 0) {
        ; ShowTipI("TYPE B: 突進貼王")
        ; send {2 Down}
        ; dsleep(100)
        ; send {2 Up}m
        ; dsleep(500)

        degree := BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y)[2]
        BnsActionAdjustDirection(degree)

        ;劍士/拳士
        ShowTipI("●[Action] - 破盾1: 飛燕劍")
        ControlSend,,{z}, %res_game_window_title%        
        dsleep(500)
        ShowTipI("●[Action] - 破盾2: 下斷斬")
        ControlSend,,{3}, %res_game_window_title%        
        dsleep(600)
        ShowTipI("●[Action] - 破盾3: 下斷斬")
        ControlSend,,{3}, %res_game_window_title%        
        dsleep(100)

        
        ;天道
        ; ControlSend,,{1}, %res_game_window_title%
        ; dsleep(100)
        ; ShowTipI("●[Action] - 破盾1: 飛燕劍")
        ; ControlSend,,{x}, %res_game_window_title%        
        ; dsleep(500)
        ; ShowTipI("●[Action] - 破盾2: 下斷斬")
        ; ControlSend,,{x}, %res_game_window_title%        
        ; dsleep(500)
        ; ShowTipI("●[Action] - 破盾3: 下斷斬")
        ; ControlSend,,{x}, %res_game_window_title%        
        ; dsleep(100)
        

        ;氣功
        ; ShowTipI("●[Action] - 破盾1: 黑閃雷")
        ; ; ControlSend,,{1 Down}, %res_game_window_title%
        ; ControlSend,,{1}, %res_game_window_title%        
        ; dsleep(200)
        ; ControlSend,,{f}, %res_game_window_title%        
        ; dsleep(500)
        ; ShowTipI("●[Action] - 破盾2: 電力擊")
        ; ControlSend,,{3}, %res_game_window_title%        
        ; dsleep(500)
        ; ShowTipI("●[Action] - 破盾3: 電力擊")
        ; ControlSend,,{3}, %res_game_window_title%        
        ; dsleep(100)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 退到牆角
    ;------------------------------------------------------------------------------------------------------------
    evacuateToEdge() {
        ShowTipI("●[Action] - 進入機制, 遠離王等待模式判定")
        ; BnsStartHackSpeed()
        BnsActionWalkToPosition(this.EDGE_POS_X, this.EDGE_POS_Y,,10000)
        ; BnsStopHackSpeed()

        ;轉頭回中間
        degree := BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y)[2]
        BnsActionAdjustDirection(degree)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 引誘 BOSS 離開中心
    ;------------------------------------------------------------------------------------------------------------
    baitBossMoveOutOfCenter() {
        ret := 0
        BnsStopAutoCombat()
        BnsActionWalkToPosition(this.BAIT_POS_X, this.BAIT_POS_Y,,5000)
        BnsActionAdjustDirection(BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y)[2])

        loop 100 {
            bossX := GetMemoryHack().getMainBossPosX()
            bossY := GetMemoryHack().getMainBossPosY()
            dist := BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y, bossX, bossY)[1]
            
            ShowTip("●[Action] - 引誘BOSS離開中間 - 等待")

            if(dist > 250) {
                ShowTip("●[Action] - 引誘BOSS離開中間 - 成功")
                ret := 1
                break
            }

            if(BnsIsCharacterDead() == 1) { ;確認角色死亡, 前一動機制處理失敗
                ret := 0
                break
            }

            sleep 100
        }

        BnsStartAutoCombat()
        return ret
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 復活
    ;------------------------------------------------------------------------------------------------------------
    resurrection() {
        sleep 2000  ;需等待復活鍵準備好
        BnsActionResurrection()
        sleep 6000  ;等待動畫
        BnsWaitMapLoadDone()
        sleep 1000
    }


;================================================================================================================
;█ Functions - STATUS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS血量
    ;------------------------------------------------------------------------------------------------------------
    listenBloodPercent(checkPoint) {
        loop {
            percent := floor(GetMemoryHack().getMainTargetBlood() / 6520000000 * 100)

            if(percent < checkPoint) {     ;BOSS 血量低於指定 % 數(公式計算會與遊戲多1%)
                if(DBUG >= 1) {
                    ShowTipI("●[System] - 偵測到 BOSS 血量低於" checkPoint "%")  
                }
                return 1
            }

            if(BnsIsCharacterDead() == 1) { ;確認角色死亡, 前一動機制處理失敗
                return 0
            }

            sleep -1
        }
    }


    listenBloodPercent80() {
        x := 790
        y := 120
        w := 360
        h := 18

        x80 := x + floor(w * 0.797)
        y80 := y + floor(h * 0.5)

        loop {
            g := GetColorGray(GetPixelColor(x80, y80))

            if((g > 148 && g < 151) || g < 50) {
                return 1
            }

            if(BnsIsCharacterDead() == 1) { ;確認角色死亡, 前一動機制處理失敗
                return 0
            }

            sleep -1
        }
    }


    listenBloodPercent40() {
        x := 790
        y := 120
        w := 360
        h := 18

        x40 := 932          ;x + floor(w * 0.41)
        y40 := 123          ;y + floor(h * 0.2)
        loop {
            g := GetColorGray(GetPixelColor(x40, y40))

            if(g < 40 || g > 130) {
                return 1
            }

            if(BnsIsCharacterDead() == 1) { ;確認角色死亡, 前一動機制處理失敗
                return 0
            }

            sleep -1

        }
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 辦識特殊機制類別
    ;------------------------------------------------------------------------------------------------------------
    adjuestMechanicsType() {
        bossX := GetMemoryHack().getMainBossPosX()
        bossY := GetMemoryHack().getMainBossPosY()

        dist := BnsMeansureTargetDistDegree(this.CENTER_POS_X, this.CENTER_POS_Y, bossX, bossY)[1]
        ; ShowTipD("x: " bossX ", y: " bossY ", dist: " dist )

        if(dist > 900) {
            ShowTipD("●[Action] - 偵測到BOSS進行 A 類攻擊 ")
            return 1
        }

        if(dist <= 12) {
            ShowTipD("●[Action] - 偵測到BOSS進行 B 類攻擊 ")
            return 2
        }
       

        ; if(floor(abs(bossX - this.SKYSTAY_POS_X)) <= 2 && floor(abs(bossY - this.SKYSTAY_POS_Y)) <= 2) {
        ;     ShowTipD("●[Action] - 偵測到BOSS進行 A 類攻擊 ")
        ;     return 1
        ; }

        ; if(floor(abs(bossX - this.CENTER_POS_X)) <= 2 && floor(abs(bossY - this.CENTER_POS_Y)) <= 2) {
        ;     ShowTipD("●[Action] - 偵測到BOSS進行 B 類攻擊 ")
        ;     return 2
        ; }

        return 0
    }


    adjuestMechanicsTypeLegacy() {
        w := 360
        h := 18

        ax := 790 + floor(w * 0.8)
        ay := 120 - floor(h * 0.8)
        
        c := GetPixelColor(ax, ay)
        
        r := GetColorRed(c)
        g := GetColorGreen(c)
        b := GetColorBlue(c)
         
        if (abs(r - g) < 0x10 &&  abs(g - b) < 0x10 && abs(r - b) < 0x10 && r > 0x50) {
            ShowTipD("●[Action] - 偵測到BOSS進行 A 類攻擊 ")
            return 1
        }
        else {
            ShowTipD("●[Action] - 偵測到BOSS進行 B 類攻擊 ")
            return 2
        }
    }

}
