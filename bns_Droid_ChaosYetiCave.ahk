#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

Class BnsDroidChaosYetiCave {
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
        this.runStageClearEnteryGate()
        this.runStageClearSnowBallRamp()

        ;Mini Boss 戰 ----------
        loop {
            if(this.runStageClearMiniBossIceGate() == 0) {
                ;復活重來
                sleep 8000
                BnsStopAutoCombat()
                this.moveToBossRoom(1, StrSplit("1", ",")) ;回去再戰一王
            }
            else {
                break
            }
        }

        ;前往尾王房集合 ---------
        ;團隊集合需要處理 TBD
        fn := func(this.navigateToFinalBoss.name).bind(this)
        BnsPcTeamMemberAction(fn, StrSplit(FIGHTING_MEMBERS, ","))    ;戰鬥人員全員移動到尾王
        sleep 2000

        ;Final Boss 戰 ----------
        loop {
            ret := this.runStageFightFinalBoss()

            if(ret == 0) {  ;滅團
                ShowTipI("●[Action] - go back to fight the boss again")
                ;復活重來
                sleep 2000
                this.moveToBossRoom(2) ;回去再戰尾王
            }
            else {
                break
            }
        }

        ;競標 -----------------
        if(BnsIsBidding() != 0) {
            ShowTipI("●[Action] - Bidding begin, " BnsIsBidding())
            loop {
                if(BnsIsBidding() == 0) {
                    break
                }

                ShowTipI("●[Action] - Bidding item: " A_index ", " BnsIsBidding())
                BnsPcTeamMembersBidding(2)

                sleep 1000
            }

            ShowTipI("●[Action] - Bidding done, " BnsIsBidding())
        }

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
    ;■ 第一階段: 火力解除第一閘門
    ;------------------------------------------------------------------------------------------------------------
    runStageClearEnteryGate() {
        ShowTipI("●[Mission1] - Start to clear the enemies and destory the gate")
        ;前往清除守門怪
        BnsStartHackSpeed()
        sleep 1000

        BnsActionSprintToPosition(-3700, 770, 0x1)
        BnsActionSprintToPosition(-4100, 220, 0x2)
        BnsActionSprintToPosition(-3450, -170, 0x2,,50)
        BnsActionSprintToPosition(-2800, -770, 0x4)

        ShowTipI("●[Mission1] - Fighting...")
        BnsStartAutoCombat()
        sleep 4000
        BnsIsEnemyClear(1500, 30)
        BnsStopAutoCombat()

        ;前往破壞冰門
        ShowTipI("●[Mission1] - Go to destory the road block")
        BnsActionSprintToPosition(-2200, -2450, 0x1)
        BnsActionSprintToPosition(-1870, -2570, 0x4)
        BnsActionAdjustDirection(340)

        if(this.actionDestroyRoadBlock() == 0) {   ;打爆冰門
            return 0
        }

        BnsStopHackSpeed()
        
        ShowTipI("●[Mission1] - Stage clear")

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 清理雪球通道
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageClearSnowBallRamp() {
        ShowTipI("●[Mission2] - Start to clear the rolling snow ball ramp")
        BnsStartHackSpeed()

        BnsActionSprintToPosition(-1290, -2900)
        BnsWaitingLeaveBattle()

        loop {
            BnsActionSprintToPosition(2270, -1900,,10000,50)
            BnsActionAdjustDirection(22)

            if(BnsMeansureTargetDistDegree(2270, -1900, BnsGetPosX(), BnsGetPosY())[1] < 50 ) {
                break
            }
            else {
                BnsStartAutoCombat()
                BnsWaitingLeaveBattle()
                BnsStopAutoCombat()
            }
        }
        
        if(this.actionDestroyRoadBlock() == 0) {   ;打爆圖騰
            return 0
        }

        BnsActionWalkToPosition(2510, -1530,,5000)  ;小王房前

        BnsStopHackSpeed()
        ShowTipI("●[Mission2] - Stage clear")

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 清理小王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageClearMiniBossIceGate() {
        count := 0
        move := 0

        ShowTipI("●[Mission3] - Start to clear the mini boss")
        BnsStartHackSpeed()

        BnsActionSprintToPosition(2830, -1275)   ;小王房進入點
        BnsActionSprintToPosition(3400, -1910)   ;小王房清小怪點
        BnsActionSprintToPosition(4120, -1160)   ;小王房釣小王點
        sleep 1000
        BnsActionSprintToPosition(3560, -1700)   ;小王房清小怪點, 看運氣好釣一隻小王出來
        sleep 3000
        BnsStartAutoCombat()

        loop {
            state := this.fightStateChanged()

            switch state {
                case 1:
                    count := count | 0x1

                case 2:
                    count := count | 0x2

                case 3:
                    count := 3

                case 4: ;角色死亡
                    ShowTipI("●[Mission3] - WARNING, charactor dead")
                    return 0
            }

            switch count {
                case 1,2:
                    ShowTipI("●[Mission3] - one mini boss clear")
                    sleep 2000
                    BnsStopAutoCombat()

                    ;交換移動, 拉開雙胖
                    if(move == 0) {
                        BnsActionSprintToPosition(3320, -520,, 10000)   ;打殘一隻，移動位置引開另一隻以破盾
                        move := 1
                    }
                    else if(move == 1) {
                        BnsActionSprintToPosition(3400, -1910,, 10000)   ;小王房清小怪點
                        move := 0
                    }

                    sleep 3000
                    BnsStartAutoCombat()

                case 3: ;小王都打死了
                    ShowTipI("●[Mission3] - Both mini boss clear")
                    break

            }
        }

        BnsIsEnemyClear(1500, 15)
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        ShowTipI("●[Mission3] - Mission completed")
        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 對戰尾王
    ;* @return - 1: success; 0: failed
    ;------------------------------------------------------------------------------------------------------------
    runStageFightFinalBoss(mIds := "") {
        ret := 0
        
        ;未指定 mIds, 默認 FIGHTING_MEMBERS
        mIds := (!mIds) ? StrSplit(FIGHTING_MEMBERS, ",") : mIds

        ;指定的 mIds 為字串(非陣列)時, 先轉換為陣列
        fighters := (!isObject(mIds)) ? StrSplit(mIds, ",") : mIds        

        ShowTipI("●[Mission4] - Start to clear the final boss")
        BnsStartHackSpeed()
        BnsActionWalkCircle(5000, 5000, 90)

        this.startTeamAutoCombat(fighters)

        loop {
            state := this.fightStateChanged()
            ShowTipI("●[Mission4] - on fighting state changed, state: " state)

            switch state {
                case 4:     ;角色死亡
                    ShowTipI("●[Mission4] - WARNING, detect charactor dead: " BnsPcGetCurrentDid())
                    BnsStopAutoCombat()

                    ;目前當前隊長為死亡
                    ; this.fighterState[BnsPcGetCurrentDid()] := 0
                    chNext := 0

                    ;尋找下一個隊長
                    For i, f in fighters
                    {
                        if(!BnsIsCharacterDead(f)) {
                            ShowTipI("●[Mission4] - change leader to alive fighter: " f)
                            switchDesktopByNumber(f)   ;隊長切換為下一個組員
                            chNext := 1
                            break
                        }

                        ; if(this.fighterState[f] == 1) {
                        ;     ShowTipI("●[Mission4] - change leader to alive fighter: " f)
                        ;     switchDesktopByNumber(f)   ;隊長切換為下一個組員
                        ;     chNext := 1
                        ;     break
                        ; }
                    }

                    ;交接成功, 繼續戰鬥
                    if(chNext == 1) {
                        continue
                    }

                    ;找不到活著的接隊長 => 團滅
                    ShowTipI("●[Mission4] - Mission failed - all fighters gone")
                    ret := 0
                    break

                case 3:     ;戰鬥結束
                    ShowTipI("●[Mission4] - Mission completed")
                    ret := 1
                    break
            }
        }

        ; this.stopTeamAutoCombat(FIGHTING_MEMBERS)
        ; BnsStopHackSpeed()

        sleep 2000

        return ret
    }        


    ;------------------------------------------------------------------------------------------------------------
    ;■ 最後階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        ;執行 pickReward
        ; fn := func(this.pickReward.name).bind(this)
        ; BnsPcTeamMemberAction(fn, , 1, 0)  ; 回傳執行mId, 不切回 leader 
        ShowTipI("●[Mission5] - pick reward")

        this.pickReward()
        ShowTipI("●[Mission5] - Mission completed")
        
        sleep 2000
        return 1
    }




;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 破壞冰門
    ;------------------------------------------------------------------------------------------------------------
    actionDestroyRoadBlock() {
        ;冰門1 = 11, 圖騰 = 52, 冰門2 = 14

        if(BnsGetTargetSerial() != 0) {
            loop {
                ControlClick,,%res_game_window_title%,,Right, 3    ;無鎖定指向性攻擊

                if(BnsGetTargetSerial() == 0) {
                    DumpLogD("●[Action] actionBrokeIceGate: destroy the road block - Success")
                    return 1
                }

                sleep 500
            }
        }

        DumpLogD("●[Action] actionBrokeIceGate: destroy the road block - Failure")
        return 0
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 從小王房前往尾王
    ;------------------------------------------------------------------------------------------------------------
    actionGoToFinalRoom() {
        BnsStartHackSpeed()
        
        ;撿取小王箱
        BnsActionSprintToPosition(3530, -820)      ;小王房中間
        BnsStartAutoCombat()
        ; sleep 3000
        BnsIsEnemyClear(1,3)                       ;只看一眼，3秒就跑
        BnsStopAutoCombat()

        BnsActionSprintToPosition(4350, -1400,,8000,50)    ;小王房斜坡底
        BnsActionSprintToPosition(5160, -840,,8000,50)      
        BnsActionSprintToPosition(5640, -40,,8000,50)       
        BnsActionWalkToPosition(5800, 410,,8000,50)        ;轉角慢速防卡圖錯位1
        BnsActionWalkToPosition(5620, 880,,8000,50)        ;轉角慢速防卡圖錯位2
        BnsActionWalkToPosition(5070, 1140,,8000,50)       ;轉角慢速防卡圖錯位3
        BnsActionSprintToPosition(4040, 1040,,8000,50)     ;尾王房門雙火柱
        BnsActionWalkToPosition(4040, 1430,,8000,50)       ;尾王房門冰門前

        if(BnsRoleType() == 14) {
            sleep 7000
        }


        if(BnsGetTargetSerial() != 0) {
            this.actionDestroyRoadBlock()
        }

        BnsActionSprintToPosition(4500, 3400,,8000,50)      ;尾王房前高地
        BnsActionSprintToPosition(4050, 5051,,3000,100)     ;尾王房前高地
        BnsActionSprintToPosition(4100, 5000,,3000)         ;王房開戰集合點
        BnsActionAdjustDirection(353)

        BnsStopHackSpeed()

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 搭龍脈
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    takeDragonPulse(type := 0) {
        switch type {
            case 1: ;門口 - 一王前龍脈
                BnsActionSprintToPosition(-3725, 1580,,5000)

            case 2: ;門口 - 尾王直達龍脈
                BnsActionSprintToPosition(-3725, 1740,,5000)
        }

        sleep 1300

        if(BnsIsAvailableTalk() != 0) {
            ShowTipI("●[Action] - take dragon pulse, type: " type)
            ControlSend,,{f}, %res_game_window_title%
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往尾王 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    navigateToFinalBoss(type := -1) {
        mode := 0

        ;角色已在尾王房 - 無需處理
        if(BnsGetPosZ() >= -660 && BnsGetPosZ() < -630) {   ;尾王房
            return
        }

        ;尾王龍脈未開的自動判斷( 如果是尾王龍脈已開請指定 type = 3, 要撿箱請指定 type = 4 )
        ;角色在小王房 - 需走路導航
        if(BnsGetPosZ() >= -181 && BnsGetPosZ() < -100) {   ;小王房
            mode := 1
        }

        ;角色在起點 - 搭龍脈到小王房, 再走路導航
        if(BnsGetPosZ() >= 317 && BnsGetPosZ() < 405) {     ;起點
            mode := 2
        }

        type := (type < 0) ? mode : type

        ShowTipI("●[Action] - " A_ThisFunc " Move to final BOSS room, type: " type)

        switch type {
            case 0:     ;走地圖過去
                ;TBD

            case 1:     ;小王房到尾王房
                this.actionGoToFinalRoom()

            case 2:     ;副本起始點(先到小王房)
                this.takeDragonPulse(1)
                sleep 6000
                this.actionGoToFinalRoom()
            
            case 3:     ;尾王直達
                this.takeDragonPulse(2)
                sleep 6000
                BnsStartHackSpeed()
                BnsActionSprintToPosition(4100, 5000,,10000)           ;王房開戰集合點
                BnsActionAdjustDirection(353)

                sleep 500
                if(!BnsIsEnemyDetected()) {      ;開戰點沒有目標, 表示這是復活後撿箱
                    BnsStartAutoCombat()
                }
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 角色復活 ****
    ;------------------------------------------------------------------------------------------------------------
    ;死亡復活;  ■return 0:生者, 1:死亡後復活
    resurrectionIfDead(mId := "") {
        BnsStopAutoCombat()
        BnsStopHackSpeed()

        if(BnsIsCharacterDead() > 0) {
            DumpLogD("●[Action] - resurrectionIfDead , mId:" mId)
            sleep 1500
            BnsActionResurrection()

            return 1
        }

        return 0
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 重回尾王 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    moveToBossRoom(boss := 2, mIds := "") {
        ShowTipI("●[Action] - " A_ThisFunc)

        ;未指定 mIds, 默認 FIGHTING_MEMBERS
        mIds := (!mIds) ? StrSplit(FIGHTING_MEMBERS, ",") : mIds

        ;指定的 mIds 為字串(非陣列)時, 先轉換為陣列
        mIds := (!isObject(mIds)) ? StrSplit(mIds, ",") : mIds

        ;篩選出死亡角色(mem)
        For i, f in mIds {
            if(BnsIsCharacterDead(f)) {
                mDeadId := mDeadId "," f
            }
        }

        ;戰鬥成員復活
        DumpLogD("●[Action] - resurrectionIfDead")
        fn := func(this.resurrectionIfDead.name).bind(this)
        BnsPcTeamMemberAction(fn, mDeadId, 1, 0)
        ; For i, f in fighters {
        ;     if(fighterState[f] == 0) {
        ;         switchDesktopByNumber(f)
        ;         this.resurrectionIfDead(f)
        ;     }
        ; }

        sleep 3000    ;等待最後一員的龍脈動畫
        BnsWaitMapLoadDone()
        sleep 1000

        switch boss {
            case 1: ;一王龍脈
                DumpLogD("●[Action] - takeDragonPulse")
                fn := func(this.takeDragonPulse.name).bind(this, 1)
                BnsPcTeamMemberAction(fn, mIds, 1, 1)

            case 2: ;尾王龍脈
                DumpLogD("●[Action] - navigateToFinalBoss")
                fn := func(this.navigateToFinalBoss.name).bind(this, 3)
                BnsPcTeamMemberAction(fn, mIds, 1, 1)
        }

        sleep 2000
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 撿取戰利品 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    pickReward(mIds := "") {
        DumpLogD("●[Action] - " A_ThisFunc)
        
        this.moveToBossRoom(2, BnsPcGetPartyMemberList())
        ; this.startTeamAutoCombat(BnsPcGetPartyMemberList())
        sleep 3000
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員開啟自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    startTeamAutoCombat(mIds := 0) {
        midsArray := (!isObject(mIds)) ? StrSplit(mIds, ",") : mIds
        
        fn := func("BnsStartAutoCombatSpeed")
        BnsPcTeamMemberAction(fn, midsArray)    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員停止自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    stopTeamAutoCombat(mIds := 0) {
        midsArray := (!isObject(mIds)) ? StrSplit(mIds, ",") : mIds

        fn := func("BnsStopAutoCombatSpeed")
        BnsPcTeamMemberAction(fn, midsArray)    ;全員停止自動戰鬥
    }



;================================================================================================================
;█ Functions - STATUS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥狀態改變
    ;* @return - 0: no; 1: yes
    ;------------------------------------------------------------------------------------------------------------
    fightStateChanged() {
        ret := 0
        disengage := 0
        tick := A_TickCount
        

        loop {
            ;角色死亡
            if(BnsIsCharacterDead() > 0) {
                DumpLogD("[State] - " A_ThisFunc ", character dead")
                ret := 4
                break
            }

            ;戰鬥結束
            if(BnsGetTargetSerial() == 0) {
                if(disengage > 10) {
                    DumpLogD("[State] - " A_ThisFunc ", boss clear")
                    ret := 3
                    break
                }

                disengage := disengage + 1
            }
            else {
                disengage := 0
            }

            ;小王已被打殘 - 酷寒捕獲隊長 10
            if(BnsGetTargetSerial() == 10 && this.getTargetBlood() == 1) {
                DumpLogD("[State] - " A_ThisFunc ", mini boss clear, serial: 10")
                ret := 2
                break
            }

            ;小王已被打殘 - 酷寒捕獲隊長 9
            if(BnsGetTargetSerial() == 9 && this.getTargetBlood() == 1) {
                DumpLogD("[State] - " A_ThisFunc ", mini boss clear, serial: 9")
                ret := 1
                break
            }

            sleep 100
        }

        ShowTipI("●[Action] - " A_ThisFunc ", ret:" ret)
        return ret
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS血量白分比
    ;------------------------------------------------------------------------------------------------------------
    getTargetBlood() {
        return GetMemoryHack().getMainTargetBlood()
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 確認BOSS血量白分比
    ;------------------------------------------------------------------------------------------------------------
    getBossBloodPercent(checkPoint) {
        return floor(GetMemoryHack().getMainTargetBlood() / GetMemoryHack().getMainTargetBloodFull() * 100)
    }

    
    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape 
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {

    }


}
