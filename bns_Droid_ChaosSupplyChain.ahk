#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

Class BnsDroidChaosSupplyChain {
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
        return BnsOuF8DefaultGoInDungeon(2, 0)    ;封魔進場, 不確認過圖
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
        BnsStartHackSpeed()

        ;開啟閘門
        if(this.runStageOpenGate() == 0) {
            return 0
        }


        ;對戰一王
        if(this.runStageFightBoss1() == 0) {
            return 0
        }


        ;清理王前通道, 移動到尾王
        if(this.runStageClearLastCorridor() == 0) {
            return 0
        }

        ; ;移動到尾王
        ; ; fn := func(this.navigateToFinalBoss.name)
        ; fn := func(this.navigateToFinalBoss.name).bind(this)
        ; BnsPcTeamMemberAction(fn, StrSplit(FIGHTING_MEMBERS, ","))    ;全員移動到尾王
        ; ; sleep 6000
        ; sleep 4000


        ;對戰尾王
        loop {
            ret := this.runStageFightFinalBoss()
            
            if(ret == 0) {    ;handle die and retry
                ShowTipI("●[Mission4] - stage retry to fight final Boss")
                sleep 15000 ;等確定死透
                ;搭龍脈回去再戰尾王

                this.teamMusterInFinalRoom(FIGHTING_MEMBERS)
            }
            else {
                break
            }

        }

        BnsStopHackSpeed()

        if(ret == 2) {    ;timeout
            return 0
        }
    
        return 1    ;clear

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
    ;■ 第一階段: 開啟閘門
    ;------------------------------------------------------------------------------------------------------------
    ;Stage1; @return - 1: success; 0: failed
    runStageOpenGate() {
        ShowTipI("●[Mission1] - Open Gate")
        
        BnsActionWalkToPosition(-36311.570, 3058.332, 0x1)  ;綠膜前
        
        loop 4 {

            switch A_Index
            {
                case 1:
                    BnsActionWalkToPosition(-37742.347, 3211.656, 0x4)  ;起始點
                
                case 2:
                    BnsActionWalkToPosition(-37743.964, 6829.596)   ;中間點

                case 3, 4:
                    BnsActionWalkToPosition(-37482.074, 9051.730,,,30)   ;閘門前
            }

            sleep 200

            ;自動戰鬥開啟
            BnsStartAutoCombat()
            ; BnsStartHackSpeed()

            sleep 5000
    
            ;進入戰鬥
            if(BnsIsEnemyDetected() > 0) {
                ShowTipI("●[Mission1] - stage" A_index " Fighting")
    
                if(BnsIsEnemyClear(1000, 90) == 1) {
                    sleep 100
    
                    ; BnsStopCheatEngiwneSpeed()
    
                    ;自動戰鬥關閉
                    BnsStopAutoCombat()
    
                    ShowTipI("●[Mission1] - stage" A_index " Completed")
                    sleep 1000
                }
                else {
                    ;2分鐘都無法接觸鎖定目標，角色卡住了
                    ; BnsDroidMission_CS_Fail("stage" A_index " timeout")
                    ShowTipE("●[Mission1] - Exception, timeout")
                    return 0
                }
    
            }
            else {
                sleep 100
                ; BnsStopHackSpeed()
    
                ;自動戰鬥關閉
                BnsStopAutoCombat()

                ;第一輪就找不到怪
                if(A_index == 1) {
                    ; BnsDroidMission_CS_Fail("Not found enemy")
                    ShowTipE("●[Mission1] - Exception, not found enermy")
                    return 0
                }
    

                ; if(A_index < 4) {
                ;     BnsActionAdjustDirectionOnMap(90)
                ;     sleep 100
                ;     ;BnsActionLateralWalkLeft(1500)
                ;     BnsActionWalk(12000)
                ; }
            }
        }
        
        return 1
    }
    

    ;------------------------------------------------------------------------------------------------------------
    ;■ 第二階段: 對戰一王(花媽)
    ;------------------------------------------------------------------------------------------------------------
    ;Stage2; @return - 1: success; 0: failed
    runStageFightBoss1() {
        ShowTipI("●[Mission2] - go to boss1 room")

        BnsActionSprintToPosition(-37450.199, 12666.190, 0x1) ;雜魚高地
        BnsActionSprintToPosition(-36412.632, 12465.103, 0x2) ;樓梯下
        BnsActionSprintToPosition(-36411.644, 10912.168, 0x2) ;花媽右側角落
        BnsActionSprintToPosition(-35341.382, 10650.022, 0x4) ;花媽右上角落
        ; BnsActionWalkToPosition(-35279.410, 10634.192)

        ;擺脫小怪
        sleep 8000

        ShowTipI("●[Mission2] - start to fight")

        ;自動戰鬥開啟, 打花媽
        BnsStartAutoCombat()
        sleep 3000

        ;進入戰鬥
        if(BnsIsEnemyDetected() > 0) {
            ShowTipI("●[Mission2] - stage2 Fighting")

            if(BnsIsEnemyClear(500, 120) == 1) {

                ;預留撿箱時間
                sleep 15<d00
                
                ;自動戰鬥關閉
                BnsStopAutoCombat()

                ShowTipI("●[Mission2] - stage2 Completed")
                sleep 1000
            }
            else {
                ;2分鐘都無法接觸鎖定目標，角色卡住了
                ; BnsDroidMission_CS_Fail("stage2 timeout")
                ShowTipE("●[Mission2] - Exception, timeout")
                return 0
            }
        }
        else {
            sleep 100
            ;自動戰鬥關閉
            BnsStopAutoCombat()

            ; BnsDroidMission_CS_Fail("Not found enemy")
            ShowTipE("●[Mission2] - Exception, not found enermy")
            return 0
        }

        
        BnsActionWalkToPosition(-35683.546, 11678.355)

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第三階段: 清除王前走廊
    ;------------------------------------------------------------------------------------------------------------
    ;Stage3; @return - 1: success; 0: failed
    runStageClearLastCorridor() {
        ShowTipI("●[Mission3] - Clear last corridor")
        
        BnsActionWalkToPosition(-33926.093, 11609.183, 0x1)

        loop 3 {

            switch A_Index
            {
                case 1:
                    BnsActionWalkToPosition(-33868.031, 8969.347, 0x4)

                case 2, 3:
                    BnsActionWalkToPosition(-30813.390, 8992.314,,,30)
            }


            ;自動戰鬥開啟
            BnsStartAutoCombat()
            sleep 5000

            ;進入戰鬥
            if(BnsIsEnemyDetected() > 0) {
                ShowTipI("●[Mission3] - stage" A_index " Fighting")

                if(BnsIsEnemyClear(1000, 90) == 1) {
                    sleep 100
                    ;自動戰鬥關閉
                    BnsStopAutoCombat()

                    ShowTipI("●[Mission3] - stage" A_index " Completed")
                    sleep 1000
                }
                else {
                    ;2分鐘都無法接觸鎖定目標，角色卡住了
                    ; BnsDroidMission_CS_Fail("Mission3 - stage" A_index " timeout")
                    ShowTipE("●[Mission3] - Exception, timeout")
                    return 0
                }
            }
            else {
                sleep 100
                ;自動戰鬥關閉
                BnsStopAutoCombat()

                ;第一輪就找不到怪
                if(A_index == 1) {
                    ; BnsDroidMission_CS_Fail("Mission3 - stage" A_index " Not found enemy")
                    ShowTipE("●[Mission3] - Exception, not found enermy")
                    return 0
                }

                ;補正機制，自動戰鬥打漏回補會超過範圍，造成下一輪鎖不到怪，往前走再試著鎖定一次(通常是發生在一二群中間)
                ; if(A_index < 4) {
                ;     BnsActionAdjustDirectionOnMap(3)
                ;     sleep 100
                ;     BnsActionWalk(10000)
                ; }
            }
        }

        ;移動到王房集合點
        ShowTipI("●[Mission3] - move to final boss room")
        ; BnsStartHackSpeed()
        BnsActionWalkToPosition(-28986.642, 9005.414, 0x1)
        BnsActionWalkToPosition(-28812.654, 7794.907, 0x2)
        BnsActionWalkToPosition(-27034.808, 7800.593, 0x4)
        ; BnsStopHackSpeed()
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 第四階段: 對戰尾王
    ;------------------------------------------------------------------------------------------------------------
    ;stage4; @return - 1: success; 0: failed
    runStageFightFinalBoss() {
        ;自動戰鬥開啟
        BnsStartAutoCombat()
        sleep 5000
        
        ; BnsStartHackSpeed()

        ;進入戰鬥
        if(BnsIsEnemyDetected() == 1) {
            ret := 1
            ShowTipI("●[Mission4] - stage Fighting")

            ;啟動非同步計時，時間到放技能
            ; SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, 4300

            fight := BnsIsEnemyClear(5000, 600)

            ; BnsStopHackSpeed()

            if(fight == 1) {    ;clear
                ;自動戰鬥關閉
                BnsStopAutoCombat()
                
                ;註消計時器
                ; SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, delete

                ret := 1
                ShowTipI("●[Mission4] - stage Completed")
            }
            else if(fight == -1) {    ;die
                ;自動戰鬥關閉
                BnsStopAutoCombat()

                ;註消計時器
                ; SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, delete

                ;角色死亡
                ShowTipI("●[Mission4] - stage Falure, charactor dead")
            
                sleep 4000
                Send {4 2}    ;復活
                sleep 3000
                BnsWaitMapLoadDone()
                ret := 0
            }
            else {    ;timeout
                ;註消計時器
                ; SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, delete

                ;10分鐘都無法接觸鎖定目標，角色卡住了
                ; BnsDroidMission_CS_Fail("Mission4 - stage timeout")
                ShowTipE("●[Mission4] - stage timeout")
                ret := 2
            }

            sleep 2000

            return ret
        }
        else {
            sleep 100

            ; BnsStopHackSpeed()

            ;自動戰鬥關閉
            BnsStopAutoCombat()

            ;第一輪就找不到怪
            if(A_index == 1) {
                ; BnsDroidMission_CS_Fail("Mission4 - Not found enemy")
                ShowTipE("●[Mission4] - Exception, Not found enemy")
                return 0
            }
        }

        ;等待脫戰
        sleep 2000

        return 1
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 第五階段: 收尾
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    runStageEnding() {
        BnsStartHackSpeed()

        ;執行 pickReward
        fn := func(this.pickReward.name).bind(this)

        BnsPcTeamMemberAction(fn, , 1, 0)  ; 回傳執行mId, 不切回 leader 

        ; sleep 2000    ;等待最後一員龍脈動畫
    
        ; this.startTeamAutoCombat()    ;TODO
        sleep 5000    ;等待撿箱
        
        BnsStopHackSpeed()

        ;如果不是全模式, 掛件們去尾王房撿箱
        ; fn := func("BnsDroidChaosBlackShenmu.takeRedDragonPulse").bind(BnsDroidChaosBlackShenmu, 2)    
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
    ;------------------------------------------------------------------------------------------------------------
    ;Take dragon pulse; #cate - 1: BOSS1; 2: Final BOSS
    takeRedDragonPulse(cate) {
        DumpLogD("●[Action] - " A_ThisFunc)

        switch cate
        {        
            case 1:        ;小王龍脈
                BnsActionWalkToPosition(-35791.628, 2572.629)
                send {f}
                ; sleep 6000    ;等待龍脈動畫
                ; BnsActionSprint(1500)
                ; BnsActionLateralWalkRight(2800)
                ; BnsActionSprint(3400)
                ; BnsActionLateralWalkLeft(2100)
                
                ; BnsActionRotationDegree180()
                ; sleep 5000    ;需要這個delay 防止上一動的 movsemove 造成視角偏轉
        
            case 2:     ;尾王龍脈
                BnsActionWalkToPosition(-35786.531, 3056.019)                
                Send {f}
        }
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往一王(龍脈) ****
    ;------------------------------------------------------------------------------------------------------------
    ;
    navigateDpToBoss1() {
        DumpLogD("●[Action] - " A_ThisFunc)

        ; this.takeRedDragonPulse(1)

        ; sleep 6000    ;等待龍脈動畫
        ; BnsActionSprint(1500)
        ; BnsActionLateralWalkRight(2800)
        ; BnsActionSprint(3300)
        ; BnsActionLateralWalkLeft(2000)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前往尾王(龍脈) ****
    ;------------------------------------------------------------------------------------------------------------
    navigateDpToFinalBoss() {
        DumpLogD("●[Action] - " A_ThisFunc)
        BnsStopAutoCombat()    ;stop
        BnsActionWalkToPosition(-27034.808, 7800.593)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 撿取戰利品 ****
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    pickReward(mId := "") {
        DumpLogD("●[Action] - " A_ThisFunc)

        BnsStartHackSpeed()

        ;戰鬥成員: 活著的跳過, 死掉的復活
        if(inStr(FIGHTING_MEMBERS, mId) != 0) {
            if(this.resurrectionIfDead() == 1) {    ;角色死亡
                ShowTipI("●[Action] - pickReward " mId " is dead, do resurrection and go back to pick reward")
            }
            else {    ;角色存活, 無需處理
                return     
            }
        }

        ;復活成員及掛件成員: 搭尾王龍脈
        this.takeRedDragonPulse(2)
        sleep 8000  ;等待動畫

        ;移到尾房集合點
        this.navigateDpToFinalBoss()

        ;自動戰鬥撿箱
        BnsStartAutoCombat()

        BnsStopHackSpeed()
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
        BnsPcTeamMembersBidding(4)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員開啟自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    startTeamAutoCombat(mids := "1,2,3,4") {
        fn := func("BnsStartAutoCombat")
        ; BnsPcTeamMemberAction(fn)    ;全員開始自動戰鬥
        BnsPcTeamMemberAction(fn,StrSplit(mids,","))    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 全員停止自動戰鬥
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    stopTeamAutoCombat(mids := "1,2,3,4") {
        fn := func("BnsStopAutoCombat")
        ; BnsPcTeamMemberAction(fn)    ;全員停止自動戰鬥
        BnsPcTeamMemberAction(fn,StrSplit(mids,","))    ;全員開始自動戰鬥
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 前置動作
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    actionPrefix(arg := 0, mid := 0) {
        ;使用星
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

        if(BnsIsEnemyDetected() == 0) {
            return
        }

        ; BnsActionLateralWalkLeft(200)
        if(BnsIsCharacterDead() == 1) {
            if(this.fighterState[mid] > 0) {
                this.fighterState[mid] := 0
            }
        }

        ;放星
        Send {``}
        sleep 200


        ;迴避
        switch BnsPcGetCurrentDid() 
        {
            case 1:
                send {q}
                sleep 100

            case 2:
                send {q}
                sleep 100

                ;狗盾保一下
                ; BnsStartStopAutoCombat()    ;stop
                ; sleep 100
                ; send {1}
                ; sleep 500
                ; send {f}
                ; BnsStartStopAutoCombat()    ;start


            case 3:
                ; send {q}
                ; sleep 100

                ;0劍放保護
                send {s}
                sleep 30
                send {s}

                sleep 100
                send {tab}
                sleep 100
                send {f}


                ;給乾坤奶一下 only, //TODO: Hotcode
                ; BnsStartStopAutoCombat()    ;stop
                ; sleep 100
                ; send {s}
                ; sleep 30
                ; send {s}
                ; sleep 1000
                ; BnsActionWalk(30)
                ; send {c}
                ; sleep 100
                ; send {1}
                ; sleep 800
                ; send {x}
                ; sleep 100

                ; BnsStartStopAutoCombat()    ;start

            case 4:
            
        }


        ;補充動作計時器
        ; for i, f in this.fighterState
        ; {
            ; if(f != 0) {
                ; fighting := fighting "," f
            ; }
        ; }

        ; fnAdditional := func("BnsPcTeamMemberAction").bind(func(this.actionAdditional.name).bind(this), StrSplit(fighting, ","),1)    ;mid 引數
        ; SetTimer, % fnAdditional, -31000    ;啟動迴避黑水保護計時器
    }



;================================================================================================================
;█ Functions - STATUS
;================================================================================================================

    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape 
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {
        DumpLogD("●[Status] - " A_ThisFunc)

        if(BnsIsLeaveBattle(1) == 1) {
            DumpLogD("●[Status] leave battle")
            return 255
        }

        ;放星
        Send {``}
        sleep 100


        deadCount := 0
        fighters := StrSplit(FIGHTING_MEMBERS, ",")
        
        ;//TODO應該記住目前是誰，哪個桌面
        currentFighter := BnsPcGetCurrentDid()
        
        DumpLogD("●[Status] - " A_ThisFunc ", DBG currentFighter=" currentFighter)
        DumpLogD("●[Status] - " A_ThisFunc ", DBG " this.fighterState[1] "," this.fighterState[2] "," this.fighterState[3] "," this.fighterState[4])

        if(BnsIsCharacterDead() == 1) {    ;死掉偵測， 扣 1 次扣 1/5
            if(this.fighterState[currentFighter] > 0) {
                this.fighterState[currentFighter] := this.fighterState[currentFighter] - 1
            }
        }
        else {    ;防誤判機制, 非連續5次確認死亡, 需重新計算
            this.fighterState[currentFighter] := (this.fighterState[currentFighter] != 0) ? 5 : 0
        }

        
        if(this.fighterState[currentFighter] == 0) {    ;確認死透了
            ;瓜瓜附身者死掉後換下一個替補(畫面切過去, 因為瓜瓜太廢需要活著的隊員維持瓜瓜判斷
            For i, f in fighters
            {
                if(this.fighterState[f] != 0) {
                    switchDesktopByNumber(f)
                    sleep 500
                    WinActivate, %res_game_window_title%

                    break
                }
            }
        }

        For i, f in fighters
        {
            deadCount += (this.fighterState[f] == 0) ? 1 : 0
        }

        DumpLogD("●[Status] - " A_ThisFunc ", DBG  " this.fighterState[1] "," this.fighterState[2] "," this.fighterState[3] "," this.fighterState[4] ", deadCount: " deadCount)

        if(deadCount == fighters.length()) {    ;全部死光
            return -1
        }
        
        return 0
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
