#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

;崑崙派本山
Class BnsDroidAltarInfinite {
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

    FIGHTING_MODE := 0      ;0:specific, 1:all
    
    FIGHTING_MEMBERS := "1"    ;action member 
    ; FIGHTING_MEMBERS := "1,2,3,4"    ;action member 
    ; FIGHTING_MEMBERS := "1,2,3"    ;action member 


    ;戰鬥成員狀態
    fighterState := 0


    ;是否完成特殊機制, 只在 SPECIAL_STAGE_HANDLE = 1 作用
    isStageSpecialDone := 0    

    ;變身cd等待時間(狗之類)
    hensin := 0

;================================================================================================================
;█ Interface
;================================================================================================================
    
    ;------------------------------------------------------------------------------------------------------------
    ;■ 取得 cp 設定檔 ****
    ;------------------------------------------------------------------------------------------------------------
    ;Get character profiles; @return - .cp file; empty means not used.
    getCharacterProfiles() {
        return ""
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 廣場導航 ****
    ;* @return - undefine
    ;------------------------------------------------------------------------------------------------------------    
    dungeonNavigation() {
        return BnsOuF8DefaultGoInDungeon(1, 0)    ;封魔進場, 不確認過圖
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 執行腳本
    ;------------------------------------------------------------------------------------------------------------
    ;Droid script stat; @return - 1: success; 0: failed
    start() {
        this.isStageSpecialDone := 0    ;重置特殊機制 flag
        
        switch this.FIGHTING_MODE
        {
            case 0:
                return this.runnableSpecific()
            
            case 1:
                return this.runnableAll()
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
    runnableSpecific() {
        state := 0
        BnsStopHackSpeed()      ;停用 speed hack

        loop {
            state := this.runStageClearBurnerAera1()

            if(state == 1)  {
                ;沒龍脈硬清到第二香爐區
                if(this.runStageClearGateAera2() == 0) {
                    ;死掉復活
                    BnsStopAutoCombat()
                    BnsStopHackSpeed()
                    BnsActionResurrection()
                    sleep 6000    ;等待動畫
                    BnsWaitMapLoadDone()
                    sleep 1000
                }
                else {
                    break
                }
            }
            else {
                ;有龍脈搭龍脈
                sleep 300
                send {f}
                sleep 6000

                break
            }
        }

        if(state == 1 || state == 2) {
            state := this.runStageClearBurnerAera2()
        }

        if(state == 0) {
            ;任務失敗
            return 0
        }
        else if(state == 1) {
            ;沒龍脈硬清到小王區
            this.runStageClearInterior()
        }
        else {
            ;有龍脈搭龍脈
            sleep 300
            send {f}
            sleep 6000
        }

        this.runStageFightLittleBoss()
        this.runStageFightFinalBoss()
        BnsStopHackSpeed()

        ;競標
        if(this.isBidding() == 1) {
            ShowTipI("●[Action] - Bidding begin")
            loop {
                if(this.isBidding() != 1) {
                    break
                }

                ShowTipI("●[Action] - Bidding item: " A_index)
                this.teamBidding()

                sleep 3000
            }
            ShowTipI("●[Action] - Bidding done")
        }
        ; sleep 2000

        return 1
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
    ;■ 第一階段: 開啟香爐
    ;------------------------------------------------------------------------------------------------------------

    runStageClearBurnerAera1() {
        ShowTipI("●[Mission1] - Go incense burner")

        BnsActionSprintToPosition(14878, 32, 0x1)  ;階梯前
        BnsActionSprintToPosition(12619, 20, 0x4)  ;斷崖前 
        
        BnsActionAdjustDirection(180)
        BnsActionGliding(20000, 1)
        
        BnsActionSprintToPosition(5917, 144)    ;門前開戰點
        BnsStartHackSpeed()
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()

        BnsActionSprintToPosition(5917, 144)    ;門前開戰點
        BnsActionSprintToPosition(-3490, -45)   ;香爐階梯前
        BnsStopHackSpeed()

        BnsActionSprintToPosition(-4490, 116)   ;香爐前
        BnsActionAdjustDirection(159)
        
        sleep 6000  ;狗拳使用

        sleep 500
        send {f}
        sleep 3000

        BnsActionSprintToPosition(-4049, -58)    ;香爐2龍脈點
        sleep 1000


        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission1] - Detect dragon pulse A")
            return 2
        }
        
        BnsActionSprintToPosition(-4050, 195)    ;一王龍脈點
        sleep 1000

        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission1] - Detect dragon pulse B")
            return 3
        }

        ShowTipI("●[Mission1] - Dragon pulse all not found")
        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 火力清掃第二閘門區
    ;------------------------------------------------------------------------------------------------------------
    runStageClearGateAera2() {
        ShowTipI("●[Mission2] - Road clearance to secound burner")
        BnsStartHackSpeed()
        BnsActionWalkToPosition(-3188, 428, 0x01)           ;第二閘門區起始點

        BnsActionWalkToPosition(-3160, 4040, 0x04)          ;第二閘門區第一開戰點
        BnsStartAutoCombat()
        BnsIsEnemyClear(1500, 60)
        BnsStopAutoCombat()
        sleep 1000

        BnsActionWalkToPosition(-3190, 5120,,5000)         ;第二閘門區第二開戰點
        BnsStartAutoCombat()
        BnsIsEnemyClear(1500, 60)
        BnsStopAutoCombat()
        sleep 1000

        BnsActionWalkToPosition(-3190, 5120,,5000)         ;第二閘門區第二開戰點,再一次
        BnsStartAutoCombat()
        BnsIsEnemyClear(1500, 60)
        BnsStopAutoCombat()
        sleep 1000

        BnsActionWalkToPosition(-3177, 9010,,5000)          ;第二閘門區門守開戰點
        sleep 100

        if(BnsIsEnemyDetected() > 0) {
            BnsStartAutoCombat()
            BnsIsEnemyClear(1000, 60)
            BnsStopAutoCombat()
        }
        else {
            ShowTipI("●[Mission2] - failed, gate keeper not found")
            sleep 60000
            return 0
        }

        sleep 1000

        if(BnsIsCharacterDead() == 1) {
            ShowTipI("●[Mission2] - failed, character dead")
            return 0
        }

        BnsActionWalkToPosition(-3140, 10400,,5000)         ;第二香爐區過場起始點
        BnsActionWalkToPosition(-4200, 10620,,5000)         ;第二香爐區過場起始點

        BnsStopHackSpeed()

        ShowTipI("●[Mission2] - Gate Aera2 completed")
        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 清理第二香爐
    ;------------------------------------------------------------------------------------------------------------
    runStageClearBurnerAera2() {
        ShowTipI("●[Mission3] - Clear second burner")

        BnsStartHackSpeed()
        BnsActionWalkToPosition(-4147, 12440,,10000)     ;第二香爐
        
        if(this.hensin) {
            sleep 40000 ;狗狗變身
        }

        sleep 500
        send {f}
        sleep 3000

        BnsActionWalkToPosition(-4157, 12000,,10000)     ;第二龍脈
        sleep 1000

        ;有龍脈就搭龍脈
        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Mission3] - Detect dragon pulse C")
            return  3
        }

        ShowTipI("●[Mission3] - dragon pulse not found, prepare to clear area")
        BnsActionSprintToPosition(-3180, 11251,,10000)     ;第二香爐開戰點
        
        ShowTipI("●[Mission3] - Fighting...")
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 60, func(this.actionEscape.name).bind(this, 0))
        BnsStopAutoCombat()
        
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 30)
        BnsStopAutoCombat()

        BnsActionSprintToPosition(-6359, 11390,,10000)     ;第二香爐守門怪開戰點
        
        BnsStartAutoCombat()
        if(BnsIsEnemyClear(1000, 30) != 1) {
            BnsStopAutoCombat()
            return 0
        }

        BnsStopAutoCombat()
        BnsStopHackSpeed()
        
        ShowTipI("●[Mission3] - Completed")
        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 清理室內
    ;------------------------------------------------------------------------------------------------------------
    runStageClearInterior() {
        ShowTipI("●[Mission4] - Clear interior")
        BnsStartHackSpeed()

        BnsActionWalkToPosition(-7795, 11370)     ;室內1樓起點
        BnsActionWalkToPosition(-9740, 11830)     ;左引戰點
        ; sleep 3000      ;等待聚怪
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600,, func(this.actionEscape.name).bind(this, 1))
        BnsStopAutoCombat()
        
        BnsActionWalkToPosition(-9750, 10890)    ;右引戰點
        ;sleep 3000      ;等待聚怪
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()

        BnsActionWalkToPosition(-9750, 10890)    ;右引戰點2W
        ;sleep 3000      ;等待聚怪
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()


        BnsActionWalkToPosition(-10138, 10621)      ;室內1樓樓梯間前
        BnsActionWalkToPosition(-10748, 9344)       ;室內1樓樓梯走廊中
        BnsActionWalkToPosition(-13016, 9414)       ;室內1樓樓梯口前
        BnsActionWalkToPosition(-13235, 11339)      ;室內樓梯平台1階中
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()

        BnsActionWalkToPosition(-13616, 10951)      ;室內樓梯平台2階前
        BnsActionWalkToPosition(-13361, 9475)       ;室內樓梯平台2階中
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()


        BnsActionWalkToPosition(-12999, 9744)       ;室內樓梯平台3階前
        BnsActionWalkToPosition(-13058, 11700)      ;室內2樓階梯前
        BnsActionWalkToPosition(-10676, 11532)      ;室內2樓右開戰點
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()


        BnsActionWalkToPosition(-10687, 12200)      ;室內2樓左開戰點
        BnsStartAutoCombat()
        BnsIsEnemyClear(1000, 600)
        BnsStopAutoCombat()

        
        BnsActionWalkToPosition(-10113, 11235)      ;室內2樓出口走廊前
        BnsActionWalkToPosition(-9476, 11103)       ;室內2樓出口走廊中
        BnsActionWalkToPosition(-9348, 7696)        ;室內2樓出口走廊外


        BnsStopHackSpeed()

        ShowTipI("●[Mission4] - Completed")
        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 對戰一王
    ;------------------------------------------------------------------------------------------------------------
    runStageFightLittleBoss() {
        ShowTipI("●[Mission5] - Go to fight little boss")
        BnsStartHackSpeed()
        BnsActionWalkToPosition(-10632, 6154, 0x01)     ;一王移動點1
        BnsActionWalkToPosition(-11504, 5189, 0x02)     ;一王移動點2
        BnsActionWalkToPosition(-12246, 5148, 0x04)     ;一王開戰點
        BnsActionAdjustDirection(295)

        if(this.hensin) {
            sleep 60000 ;等狗狗變身;懶人處理法
        }

        ShowTipI("●[Mission5] - Fighting...")
        this.actionPrefix()
        BnsStartAutoCombat()

        dsleep(35<00)
        send {q}
        dsleep(4000)
        send {q}
        dsleep(4000)
        send {q}

        BnsIsEnemyClear(3000, 600)
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        ShowTipI("●[Mission5] - Completed")
        return 1
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第六階段: 對戰尾王
    ;------------------------------------------------------------------------------------------------------------
    runStageFightFinalBoss() {
        ShowTipI("●[Mission6] - Go to fight final boss")
        BnsStartHackSpeed()
        ;移動到尾王
        BnsActionWalkToPosition(-12240, 3100)       ;尾王龍脈移動點1
        BnsActionWalkToPosition(-12790, 1330)       ;尾王龍脈移動點2

        ;搭龍脈
        sleep 500
        send {f}
        sleep 6000

        BnsActionWalkToPosition(-18765, -10182)     ;移動到尾王
        sleep 1000

        DBUG := 1

        ShowTipI("●[Mission6] - Fighting...")
        this.actionPrefix()
        BnsStartAutoCombat()
        sleep 2000
        BnsIsEnemyClear(3000, 600,, func(this.actionEscape.name).bind(this, 2))    ;脫戰逃逸
        sleep 3000

        loop {
            if(this.actionEscape(2) == 1) {
                ShowTipI("●[Mission6] - disengage")
                break
            }

            sleep 1000
        }

        BnsStopAutoCombat()
        BnsStopHackSpeed()
        ShowTipI("●[Mission6] - Completed")

        
        if(this.isBidding() == 1) {
            ShowTipI("●[Action] - Bidding begin")
            loop {
                if(this.isBidding() != 1) {
                    break
                }

                ShowTipI("●[Action] - Bidding item: " A_index)
                this.teamBidding()
            }
        }

        DBUG := 0

        return 1
    }




    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        return 1
    }




;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 撿取戰利品 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    pickReward(mId := "") {
        DumpLogD("●[Action] - " A_ThisFunc)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 角色復活 ****
    ;------------------------------------------------------------------------------------------------------------
    ;死亡復活;  ■return 0:生者, 1:死亡後復活
    resurrectionIfDead(mId := "") {
        DumpLogD("●[Action] - " A_ThisFunc)

        if(BnsIsCharacterDead() == 1) {
            BnsActionResurrection()
            sleep 6000    ;等待動畫
            BnsWaitMapLoadDone()
            sleep 1000

            return 1
        }
        ; this.takeRedDragonPulse(2)
        ; sleep 5000    ;等待動畫

        return 0
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 尾王房集合 ****
    ;------------------------------------------------------------------------------------------------------------
    ; #mIds - string of member id(split by ",")
    teamMusterInFinalRoom(mIds := "") {
        DumpLogD("●[Action] - " A_ThisFunc)

        ;成員復活
        fn := func(this.resurrectionIfDead.name).bind(this)
        BnsPcTeamMemberAction(fn, StrSplit(mIds, ","), 1)

        fn := func(this.takeRedDragonPulse.name).bind(this, 2)
        BnsPcTeamMemberAction(fn, StrSplit(mIds, ","), 1)

        sleep 6000    ;等待最後一員的龍脈動畫

        ;王房集合
        fn := func(this.navigateDpToFinalBoss.name).bind(this)
        BnsPcTeamMemberAction(fn, StrSplit(mIds, ","), 1)
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
    ;■ 全員開啟自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    startTeamAutoCombat(mids := "1,2,3,4") {
        DumpLogD("●[Action] - " A_ThisFunc)
        fn := func("BnsStartAutoCombat")
        ; BnsPcTeamMemberAction(fn)    ;全員開始自動戰鬥
        BnsPcTeamMemberAction(fn,StrSplit(mids,","))    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員停止自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    stopTeamAutoCombat(mids := "1,2,3,4") {
        DumpLogD("●[Action] - " A_ThisFunc)
        fn := func("BnsStopAutoCombat")
        ; BnsPcTeamMemberAction(fn)    ;全員停止自動戰鬥
        BnsPcTeamMemberAction(fn,StrSplit(mids,","))    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前置動作
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    actionPrefix(arg := 0, mid := 0) {
        DumpLogD("●[Action] - " A_ThisFunc)
        ;使用星
        send {``}
        sleep 100

        ;使用狗盾
        ; send {1}
        ; sleep 500
        ; send {f}

        ;使用狗
        send {tab}
        sleep 300
        send {v}

    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥逃逸
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    actionEscape(arg := 0, mid := 0) {
        ; DumpLogD("●[Action] - " A_ThisFunc ", mid:" mid)


        switch arg
        {
            case 0:         ;回避木頭人誘餌
                if(BnsGetPosY() > 12200) {
                    DumpLogD("●[Action] - " A_ThisFunc ", avoid the dummy bait, mid:" mid)
                    BnsActionWalkToPosition(-3300, 11600)
                    return 0
                }

            case 1:         ;防卡柱子移位
                if(BnsGetPosX() < -10500) {
                    DumpLogD("●[Action] - " A_ThisFunc ", avoid floor block, mid:" mid)
                    BnsActionWalkToPosition(-10550, 12200)
                    return 0
                }

            case 2:         ;尾王結束戰鬥(殘血會莫名出現一次脫戰判定, 需要加血量下去判斷才不會誤判)
                ShowTipD("●[Action] - " A_ThisFunc ", blood: " GetMemoryHack().getMainTargetBlood() ", isNotBattle: " BnsIsLeaveBattle())    
                if(BnsIsLeaveBattle() == 1 && (GetMemoryHack().getMainTargetBlood() < 1 || GetMemoryHack().getMainTargetBlood() >= 6615000)) {
                    return 1
                }

                return 0
        }
    }




    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥中迴避卡點
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    


;================================================================================================================
;█ Functions - STATUS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape 
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {
        DumpLogD("●[Status] - " A_ThisFunc)
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
