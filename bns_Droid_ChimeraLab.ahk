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

    ; FIGHTING_MODE := 1    ;0:alone, 1:specific, 2:all
    FIGHTING_MODE := 1    ;0:alone, 1:specific, 2:all
    
    ; FIGHTING_MEMBER := "1"    ;action member 
    ; FIGHTING_MEMBER := "1,2,3,4"    ;action member 
    FIGHTING_MEMBER := "1,2,3"    ;action member 
    ; FIGHTING_MEMBER := "1,2"    ;action member 


    ;戰鬥成員狀態(array)
    fighterState := [1,1,1,1]


    ;是否完成特殊機制, 只在 SPECIAL_STAGE_HANDLE = 1 作用
    isStageSpecialDone := 0    


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
        this.isStageSpecialDone := 0    ;重置特殊機制 flag


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
        ret := 0

        return ret
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
    ;■ 第一階段: 開啟小王房門
    ;------------------------------------------------------------------------------------------------------------
    runStageClearGate() {
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
        ShowTipI("●[Mission1] - Fall down to B1")
        BnsActionSprintToPosition(2000, -2770)
        msleep(1000)
        ControlSend,,{Space}, %res_game_window_title%
        ShowTipI("●[Mission1] - Fall down to B2")
        BnsActionSprintToPosition(5000, -2630)
        ControlSend,,{Space}, %res_game_window_title%
        msleep(1500)
        ControlSend,,{Space}, %res_game_window_title%
        ShowTipI("●[Mission1] - Fall down to B3")
        BnsActionSprintToPosition(3140, -3670)
        ControlSend,,{Space}, %res_game_window_title%
        msleep(1800)
        ControlSend,,{Space}, %res_game_window_title%
        msleep(200)
        ControlSend,,{Space}, %res_game_window_title%

        ;等待脫戰
        loop {
            if(BnsIsLeaveBattle()) {
                break
            }
            sleep 1000
        }

        sleep 1500

        ;清除隨機閘門區
        BnsActionSprintToPosition(2800, -1900, 1)
        BnsActionSprintToPosition(4340, -2000, 2)
        BnsActionSprintToPosition(3700, -1700, 4)
        
        sleep 3000
        if(BnsIsLeaveBattle()) {
            ShowTipI("●[Mission1] - Second Gate has open, mission completed")
        }
        else {
            ShowTipI("●[Mission1] - Clear second gate area")

            BnsStartAutoCombat()
            sleep 1000
            BnsIsEnemyClear(3000, 30)
            BnsStopAutoCombat()

            BnsActionSprintToPosition(3700, -300)
            BnsActionSprintToPosition(3700, -1500)
            sleep 6000
            BnsActionAdjustDirection(90)
            BnsStartAutoCombat()
            BnsIsEnemyClear(500, 30)
            BnsStopAutoCombat()

            ShowTipI("●[Mission1] - Enermy clear, mission completed")
        }
        
        BnsActionAdjustDirection(90)

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 爬樹到一王
    ;------------------------------------------------------------------------------------------------------------
    ;上右 1
    runStageClimbTree1() {
        ret := 0

        ret := BnsActionSprintToPosition(-4550, 7500,,15000,5)  ;1號藤前
        ret := BnsActionSprintToPosition(-3840, 8540,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 1-1 failed")
            return 0
        }

        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ret := BnsActionSprintToPosition(-3860, 9730,,15000,5)
        ret := BnsActionSprintToPosition(-4510, 10660,,15000,5)
        ret := BnsActionSprintToPosition(-5480, 10820,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 1-2 failed")
            return 0
        }

        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ret := BnsActionSprintToPosition(-6840, 10870,,15000,5)
        ret := BnsActionSprintToPosition(-8140, 10670,,15000,5)
        ret := BnsActionSprintToPosition(-9990, 8340,,15000,5)
        sleep 1000
        ret := BnsActionSprintToPosition(-9630, 7300,,15000,5)

        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 1-3 failed")
            return 0
        }

        ShowTipI("●[Mission2] - Climb vine 1 Success")
        return 1
    }


    ;上左 2
    runStageClimbTree2() {
        ret := 0
        ret := BnsActionSprintToPosition(-6180, 7400,,15000,5)  ;2號藤前
        ret := BnsActionSprintToPosition(-6690, 8460,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 2-1 failed")
            return 0
        }

        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ret := BnsActionSprintToPosition(-7800, 8840,,15000,5)
        ret := BnsActionSprintToPosition(-8421, 8090,,15000,5)
        sleep 1000
        ret := BnsActionSprintToPosition(-8882, 7246,,30000,5)

        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 2-2 failed")
            return 0
        }
        
        ShowTipI("●[Mission2] - Climb vine 2 Success")
        return 1
    }
    
    
    ;下右 3
    runStageClimbTree3() {
        ret := 0
        ret := BnsActionSprintToPosition(-4600, 5000,,15000,5)  ;3號藤前
        ret := BnsActionSprintToPosition(-4120, 4000,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 3-1 failed")
            return 0
        }

        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ;1樓到2樓
        ret := BnsActionSprintToPosition(-4350, 3000,,15000,5)
        ret := BnsActionSprintToPosition(-5580, 2850,,15000,5)
        ret := BnsActionSprintToPosition(-5810, 2700,,15000,5)
        ret := BnsActionSprintToPosition(-6700, 2970,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 3-2 failed")
            return 0
        }


        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ;2樓到一王
        ret := BnsActionSprintToPosition(-8100, 3440,,15000,5)
        ret := BnsActionSprintToPosition(-9321, 4288,,15000,5)
        sleep 1000
        ret := BnsActionSprintToPosition(-9435, 5100,,15000,5)

        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 3-3 failed")
            return 0
        }
        
        ShowTipI("●[Mission2] - Climb vine 3 Success")
        return 1
    }

    
    ;下左 4
    runStageClimbTree4() {
        ret := 0
        ret := BnsActionSprintToPosition(-6400, 5000,,15000,5)  ;4號藤前
        ret := BnsActionSprintToPosition(-7080, 3940,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 4-1 failed")
            return 0
        }

        sleep 1000
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 10)
        BnsStopAutoCombat()
        BnsStopHackSpeed()
        sleep 3000

        ;2樓到一王
        ret := BnsActionSprintToPosition(-8100, 3440,,15000,5)
        ; BnsActionSprintToPosition(-9250, 3970,,15000,5)
        ret := BnsActionSprintToPosition(-9321, 4288,,15000,5)
        sleep 1000
        ret := BnsActionSprintToPosition(-9435, 5100,,15000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 4-2 failed")
            return 0
        }

        ShowTipI("●[Mission2] - Climb vine 4 Success")
        return 1
    }

    ;中左 5 (直達車)
    runStageClimbTree5() {
        ret := 0
        ret := BnsActionSprintToPosition(-6900, 6200,,15000,5)  ;5號藤前
        ret := BnsActionSprintToPosition(-8000, 6250,,35000,5)
        if(ret == 0) {
            ShowTipE("●[Mission2] - Climb vine 5 failed")
            return 0
        }

        ShowTipI("●[Mission2] - Climb vine 5 Success")
        return 1
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第一階段: 對戰一王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageFightBoss1(members := "1") {

        ShowTipI("●[Mission3] - start to fight")

        ; this.startTeamAutoCombat(this.FIGHTING_MEMBER)
        ; sleep 1000

        ; ;進入戰鬥
        ; sleep 10000

        ; if(BnsIsEnemyDetected() > 0) {
            BnsStartHackSpeed()

            this.startTeamAutoCombat(members)
            sleep 1000

            if(BnsIsEnemyClear(1500, 60) == 1) {    ;允許丟失目標 1.5秒, 超時時間 60 秒
                ;預留撿箱時間
                ; sleep 3000

                ;預留撿箱時間
                ; BnsIsLeaveBattle(3000)    ;等待脫戰

                ;this.stopTeamAutoCombat()

                ShowTipI("●[Mission3] - completed")
            }
            else {
                ;2分鐘都無法接觸鎖定目標，角色卡住了
                ShowTipE("●[Mission3] - Exception: timeout")
                return 0
            }
        ; }
        ; else {
            ; sleep 100
            ; this.stopTeamAutoCombat()
            ; ShowTipE("●[Exception] - boss1 not found")
            ; return 0
        ; }

        this.stopTeamAutoCombat(members)
        BnsStopHackSpeed()
        ShowTipI("●[Mission3] - completed")

        return 1
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 對戰尾王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageFightFinalBoss(members := "1") {
        ShowTipI("●[Mission4] - start to fight")

        this.fighterState := [1,1,1,1]    ;生存名單

        ret := 0

        ;是否開啟特殊機制的保護機制
        fnSSHandler := (this.SPECIAL_STAGE_HANDLE) ? func(this.isSpecialStageDetected.name).bind(BnsDroidChaosBlackShenmu) : 0

        ;補充動作計時器
        ; fnAdditional := func("BnsPcTeamMemberAction").bind(func(this.actionAdditional.name).bind(this), StrSplit(this.FIGHTING_MEMBER, ","),1)    ;mid 引數
        fnAdditional := func(this.actionAdditional.name).bind(this)

        ;戰鬥條件脫離
        fnEscape := func(this.isFightEscape.name).bind(this)

        ; sleep 3000

        BnsActionWalkCircle(-7100, 5630, -180)  ;繞到王的背面(避免隊友被打飛)
        BnsActionWalk(2000)    ;前進到可鎖定BOSS的範圍
        
        if(BnsIsEnemyDetected() > 0) {
            ; SetTimer, % fnAdditional, 31000    ;啟動迴避黑水保護計時器

            this.actionPrefix()    ;開王前準備動作

            BnsStartHackSpeed()

            this.startTeamAutoCombat(members)
            sleep 1000

            ; fight := BnsIsEnemyClear(10000, 480, fnSSHandler, fnEscape)
            fight := BnsIsEnemyClear(8000, 480, 0, fnEscape)

            ; ShowTipI("●[Mission4] - stop additional action timer")
            ; SetTimer, % fnAdditional, delete    ;判除迴避黑水保護計時器

            if(fight >= 1)    ;completed
            {    
                ;預留撿箱時間
                
                ; BnsIsLeaveBattle(3000)    ;等待脫戰
                ; this.stopTeamAutoCombat(this.FIGHTING_MEMBER)
                ShowTipI("●[Mission4] - completed, ret:" fight)

                ret := 1
            }
            else if(fight == 0) {    ;timeout 
                ;2分鐘都無法接觸鎖定目標，角色卡住了
                ShowTipE("●[Mission4] - Exception: timeout")
                ret := 0
            }
            else {    ;escape condition
                ShowTipE("●[Mission4] - Exception: fighter all gone")
                ret := fight
            }

            BnsStopHackSpeed()
        }
        else {
            ; SetTimer, % fnAdditional, delete    ;判除迴避黑水保護計時器
            sleep 100
            this.stopTeamAutoCombat(members)
            ShowTipE("●[Mission4] - Exception: boss not found")
            ret := 0
        }

        return ret
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 最後階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ShowTipI("●[Mission5] - pick reward")
        ;執行 pickReward
        fn := func(this.pickReward.name).bind(this)

        ;戰鬥組員
        BnsPcTeamMemberAction(fn, StrSplit(this.FIGHTING_MEMBER, ","), 1, 0)  ; 回傳執行mId, 不切回 leader 

        ; ;掛件組員
        ; BnsPcTeamMemberAction(fn,StrSplit("4", ","), 1, 0)  ; 回傳執行mId, 不切回 leader
        sleep 2000    ;等待最後一員龍脈動畫
    
        this.startTeamAutoCombat()    ;TODO
        sleep 5000    ;等待撿箱

        ;如果不是全模式, 掛件們去尾王房撿箱
        ; fn := func("BnsDroidChaosBlackShenmu.takeDragonPulse").bind(BnsDroidChaosBlackShenmu, 2)    
        ; BnsPcTeamMemberAction(fn,StrSplit("3,4", ","))
        ; sleep 6000

        ; this.startTeamAutoCombat("3,4")    ;TODO
        ; sleep 5000    ;等待撿箱
    
        ; fn := func("BnsOuF8GobackLobby").bind(0)    ;0: 不確認是否回等候成功
        ; BnsPcTeamMemberAction(fn,StrSplit)    ;全員回到等候室
        
        ; return
    }




;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 搭乘龍脈 
    ;* @param cate - indentify for each dragon pulse(if more then one dragon pulse).
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    takeDragonPulse(cate) {
        DumpLogD("●[Action] - " A_ThisFunc "  cate: " cate)

        switch cate
        {        
            case 0:         ;開場龍脈
                BnsActionSprintToPosition(16583, -7870)

            case 1:         ;崖前小王龍脈(red)
                BnsActionSprintToPosition(16220, -8040)

            case 2:         ;崖前尾王龍脈(red)
                BnsActionSprintToPosition(16330, -8180)
            
            case 3:         ;小王房龍脈
                BnsActionSprintToPosition(-10170, 6430)

        }

        sleep 500
        ControlSend,,{f}, %res_game_window_title%

    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往一王 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    navigateToBoss1(type := -1) {
        if(BnsGetPosZ() between -808 and 848) {   ;副本起始點 Z = -828
            kind := 1
        }
        
        type := (type < 0) ? kind : type

        DumpLogD("●[Action] - " A_ThisFunc "  type: " type)

        switch type {
            case 0:     ;走地圖過去
                ;TBD
            
            case 1:     ;副本起始點
                this.takeDragonPulse(1)

        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往尾王 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    navigateToFinalBoss(type := -1) {
        kind := 0

        if(BnsGetPosZ() > -878 && BnsGetPosZ() < -778) {
            kind := 1
        }

        if(BnsGetPosZ() > 3352 && BnsGetPosZ() < 3452) {
            kind := 2
        }

        type := (type < 0) ? kind : type

        ShowTipI("●[Action] - " A_ThisFunc " Move to final BOSS room, type: " type)

        switch type {
            case 0:     ;走地圖過去
                ;TBD

            case 1:     ;副本起始點(先到小王房)
                this.navigateToBoss1()
                sleep 6000
                this.takeDragonPulse(3)

            case 2:     ;一王房內
                this.takeDragonPulse(3)

        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 重回尾王 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    backToFightFinalBoss(mIds := "") {
        DumpLogD("●[Action] - " A_ThisFunc)

        ;戰鬥成員復活
        fn := func(this.resurrection.name).bind(this)
        BnsPcTeamMemberAction(fn, StrSplit(mIds, ","), 1)

        fn := func(this.takeDragonPulse.name).bind(this, 2)
        BnsPcTeamMemberAction(fn, StrSplit(mIds, ","), 1)

        sleep 6000    ;等待最後一員的龍脈動畫
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 團隊競標 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    teamBidding() {
        DumpLogD("●[Action] - " A_ThisFunc)
        BnsPcTeamMembersBidding(2)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 撿取戰利品 ****
    ;* @return - none
    ;-------------------------------------------------------------------------------------------------------BnsIsAvailableTalk()-----
    pickReward(mId := "") {
        DumpLogD("●[Action] - " A_ThisFunc)

        if(inStr(this.FIGHTING_MEMBER, mId) != 0) {    ;戰鬥成員
            if(BnsIsCharacterDead() == 1) {    ;角色死亡
                ShowTipI("●[Action] - pickReward " mId " is dead, do resurrection and go back to pick reward")
                this.resurrection()
                ; BnsStartAutoCombat()  ;start
            }
            else {    ;角色存活, 無需處理
                ; BnsStopAutoCombat()    ;stop
                return     
            }
        }

        this.takeDragonPulse(2)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 角色復活 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    resurrection(mId := "") {
        DumpLogD("●[Action] - " A_ThisFunc)
        BnsStopAutoCombat()    ;stop

        ControlSend,,{4}, %res_game_window_title%    ;復活
        sleep 6000    ;等待動畫
        BnsWaitMapLoadDone()
        sleep 1000
        ; this.takeDragonPulse(2)
        ; sleep 5000    ;等待動畫
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 繞圈移動 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    circledAroundAltar(deltaDegree, times := 1) {
        ALTAR_X := -5380
        ALTAR_Y := 6237

        times := (times == 0) ? times := 2147483647 : 1

        loop %times% {
            BnsActionWalkCircle(ALTAR_X, ALTAR_Y, deltaDegree)
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員開啟自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    startTeamAutoCombat(mids := 0) {
        midsArray := 0
        fn := func("BnsStartAutoCombat")
        
        if(mids) {
            midsArray := StrSplit(mids, ",")
        }

        ; BnsPcTeamMemberAction(fn)    ;全員開始自動戰鬥
        BnsPcTeamMemberAction(fn, midsArray)    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員停止自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    stopTeamAutoCombat(mids := 0) {
        midsArray := 0
        fn := func("BnsStopAutoCombat")
        
        if(mids) {
            midsArray := StrSplit(mids, ",")
        }

        BnsPcTeamMemberAction(fn, midsArray)    ;全員停止自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 黃面機制處理-開始
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    yellowFaceHandle(cate) {    ;1:進機制, 2:出機制
        if(cate == 1) { ;進機制
            ShowTipD("perform special stage handle Begin")
            BnsStartStopAutoCombat()    ;stop
            
            ;貼牆遠離BOSS
            BnsActionRotationDegree180()
            BnsActionWalk(2000)
            BnsActionRotationDegree180()
        }
        else {    ;出機制
            ShowTipD("perform special stage handle End")
            BnsActionWalk(500)
            BnsStartStopAutoCombat()    ;start 
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前置動作
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    actionPrefix(arg := 0, mid := 0) {
        send {``}
        sleep 100
        
        send {tab}
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 補充動作
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    actionAdditional(mid := 0) {
        DumpLogD("●[Action] - " A_ThisFunc ", mid:" mid)

        fighters := StrSplit(this.FIGHTING_MEMBER, ",")

        For i, f in fighters
        {
            if(fighters[f] == 0) {  ;隊員死掉便不做事
                continue
            }

            switchDesktopByNumber(fighters[f])
            sleep 500
            WinActivate, %res_game_window_title%
            sleep 200

            ;放星
            Send {``}
            sleep 200

        }
    
    }



;================================================================================================================
;█ Functions - STATUS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 判斷開啟路線
    ;------------------------------------------------------------------------------------------------------------
    judgeVine() {
        ret := 0
        sx := WIN_CENTER_X - WIN_BLOCK_WIDTH
        sy := WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 4
        ex := WIN_CENTER_X + WIN_BLOCK_WIDTH
        ey := WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 1
        
        BnsActionWalkToPosition(-5790, 6150)  ;祭壇西側觀察點

        BnsActionAdjustCamaraAltitude(1.8)

        loop 5 {
            ; ShowTipI("detected vine: " A_index)
            switch A_index {
                case 1:
                    BnsActionAdjustDirection(50)    ;  上右

                case 2:
                    BnsActionAdjustDirection(110)   ;  上左
        
                case 3:
                    BnsActionAdjustDirection(312)   ;  下右
    
                case 4:
                    BnsActionAdjustDirection(241)   ;  下左
            
                case 5:
                    BnsActionAdjustDirection(177)   ;  左中
                    
            }

            count := 0
            loop 10 {
                if(FindPixelRGB(sx, sy, ex, ey, 0xFDFDEF, 0x5) == 1) {
                    count++
                    ; ShowTipI("detected vine count: " count)
                    if(count > 4) {
                        ret := 1
                        break
                    }
                }
                sleep 200
            }

            ret := (ret == 1) ? ret := A_index : 0

            if(ret > 0 ) {
                break
            }
        }

        return ret
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape 
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {
        ; DumpLogD("●[Status] - " A_ThisFunc)
        bossX := GetMemoryHack().getMainBossPosX()
        bossY := GetMemoryHack().getMainBossPosY()


        fighters := StrSplit(this.FIGHTING_MEMBER, ",")
        deadCount := 0
        leaderDid := 0

        ; DumpLogD("●[Status] - " A_ThisFunc " 1:" fighters[1] ", 2:" fighters[2] ", 3:" fighters[3] ", 4:" fighters[4])
        ; DumpLogD("●[Status] - " A_ThisFunc " Boss: " res_dungeon_chaos_block_shenmu_boss_name ", target: " GetMemoryHack().getMainTargetName() ", HP: " GetMemoryHack().getMainTargetBlood())

        ;依目標名字及血量判斷(名字部份解析失敗, 每次掃到的offset 都不一樣)
        ; if(GetMemoryHack().getMainTargetName() == res_dungeon_chaos_block_shenmu_boss_name && GetMemoryHack().getMainTargetBlood() == 0) {   ;偵測 boss 死掉
        ;     DumpLogD("●[Status] - " A_ThisFunc "  detect BOSS gone")
        ;     return 1
        ; }

        DumpLogD("●[Status] - " A_ThisFunc "  leave battle: " BnsIsLeaveBattle())
        if(BnsIsLeaveBattle() == 1) {
            DumpLogD("●[Status] - " A_ThisFunc "  detect BOSS gone")
            sleep 3000  ;王一打死就會脫戰, 留3秒撿箱
            return 1
        }

        ; if(DBUG >= 1) {
        ;     DumpLogD("●[Status] - " A_ThisFunc " did: " BnsPcGetCurrentDid() ", dead:" BnsIsCharacterDead())
        ; }

        if(BnsIsCharacterDead() == 1 && this.fighterState[BnsPcGetCurrentDid()] == 1) {
            DumpLogD("●[Status] - " A_ThisFunc "  detect dead:" BnsPcGetCurrentDid())
            this.fighterState[BnsPcGetCurrentDid()] := 0
        }

        ; DumpLogD("●[Status] - " A_ThisFunc " fightstate: " this.fighterState[1] "," this.fighterState[2] "," this.fighterState[3] "," this.fighterState[4])


        For i, f in fighters
        {
            deadCount += (this.fighterState[f] == 0) ? 1 : 0

            ;死掉就換下一個還活著的接隊長
            leaderDid := (leaderDid == 0 && this.fighterState[f] == 1) ? f : leaderDid

            ; DumpLogD("●[Status] - " A_ThisFunc "  fighter: " f  ", dead count: " deadCount ", leaderDid: " leaderDid)
        }


        if(deadCount == fighters.length()) {    ;全部死光
            DumpLogD("●[Status] - " A_ThisFunc "  return: " -1)
            return -1
        }

        
        if(leaderDid != getCurrentDesktopId()) {
            DumpLogD("●[Status] - " A_ThisFunc "  switch to new leader desktop: " leaderDid)
            switchDesktopByNumber(leaderDid)   ;隊長切到下一個組員
            sleep 500
            WinActivate, %res_game_window_title%
        }

        ; DumpLogD("●[Status] - " A_ThisFunc "  return: " 0)
        return 0
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 特珠機制發生
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    isSpecialStageDetected() {
        ; tfn := this["timerRun"].bind(this)
        ; SetTimer, % tfn, 1000
        
        ; sleep 10000
    
        if(!this.isStageSpecialDone && this.detectBossBlood(80)) {
            fnStart := func(this.yellowFaceHandle.name).bind(BnsDroidChaosBlackShenmu, 1)
            BnsPcTeamMemberAction(fnStart,StrSplit("4",","))



            ; ShowTipD("perform special stage handle end")
            ; fnExit := func(this.yellowFaceHandle.name).bind(BnsDroidChaosBlackShenmu, 2)
            ; BnsPcTeamMemberAction(fnExit,StrSplit("4",","))

            fn := func(this.yellowFaceHandle.name).bind(BnsDroidChaosBlackShenmu, 2)
            fnExit := func("BnsPcTeamMemberAction").bind(fn, StrSplit("4", ","),,, 100)
            SetTimer, % fnExit, -10000    ;10秒後只執行1次, fnExit 是變數所以要用 % 加在前面

            this.isStageSpecialDone := 1
        }
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


    ;------------------------------------------------------------------------------------------------------------
    ;■ BOSS血量偵測
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    detectBossBlood(blood) {
        x := 790, y := 120,    w := 360, h := 18

        x80 := x + floor(w * 0.79)
        y80 := y + floor(h * 0.5)

        g := GetColorGray(GetPixelColor(x80, y80))

        if((g > 148 && g < 151) || g < 50) {
            ShowTipD("detect boss blood in 80%, g=" g )
            return 1
        }
        return 0
    }

}
