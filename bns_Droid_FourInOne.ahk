#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

Class BnsDroidFourInOne {
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


    ;安息導電花座標,1,2,3,4,5,6
    CURRENT_FLOWER_POS := " -45290,92170;-43800,92190;-45290,93700;-43800,93690;-45290,95190;-43800,95195"


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
        ;------------------------------------------------------------------------------------
        ; 安息庭院
        ;------------------------------------------------------------------------------------
        
        ;團隊進本
        fn := func(this.nativeToDungeon.name).bind(this, 1)
        BnsPcTeamMemberAction(fn, BnsPcGetPartyMemberList())
        sleep 3000    ;等待最後一員過圖
        BnsWaitMapLoadDone()
        sleep 1000

        ;清理副本
        this.runStageTranquilCourtyard()


        ;------------------------------------------------------------------------------------
        ; 貪慾密室
        ;------------------------------------------------------------------------------------

        ;------------------------------------------------------------------------------------
        ; 束縛石室
        ;------------------------------------------------------------------------------------

        ;------------------------------------------------------------------------------------
        ; 紀律廻廊
        ;------------------------------------------------------------------------------------



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
    ;■ 安息庭院階段
    ;------------------------------------------------------------------------------------------------------------
    runStageTranquilCourtyard() {
        ;1. 清理妖花
        BnsStartHackSpeed()
        BnsActionSprintToPosition(-43860, 91306,,15000)
        BnsActionWalkToPosition(-44650, 94120,,10000)
        BnsStopHackSpeed()
        sleep 5000
        BnsActionSprintToPosition(-45290, 92170,,10000)
        sleep 5000
        BnsStartAutoCombat()
        BnsIsEnemyClear(200, 10)
        BnsStopAutoCombat()

        ;2. 導電
        sleep 10000  ;等蟲蟲屍體消失，防誤判
        this.actionLinkCurrent()

        ;3. 尾王集合
        fn := func(this.nativeOfTranquilCourtyard.name).bind(this, 2)
        BnsPcTeamMemberAction(fn, StrSplit("1,2", ","))

        ;4. 打王
        this.startTeamAutoCombat()
        
        ;5. 打手離開副本
        loop {
            if(this.getBossBloodPercent() < 20) {

                switchDesktopByNumber(2)    ;切到下一個
            }
        }

        ;6. 離開副本
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
;█ Functions TranquilCourtyard 安息庭院 - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 安息庭院 - 入口導航
    ;------------------------------------------------------------------------------------------------------------
    nativeOfTranquilCourtyard(type) {
        switch type {
            case 1:         ;入口導航
                ; BnsStartHackSpeed()
                BnsActionSprintToPosition(-40050,51900,,10000)
                BnsActionAdjustDirection(123)

                ;接任務

                BnsActionSprintToPosition(-40370,52340,,10000)
                ; BnsStopHackSpeed()

            case 2:         ;尾王導航
                BnsStartHackSpeed()
                if(BnsGetPosY() < 91300) {
                    BnsActionSprintToPosition(-43860, 91306,,15000)
                }

                BnsActionSprintToPosition(-45370, 95860,,10000)
                BnsActionSprintToPosition(-45480, 97560,,10000)
                BnsActionSprintToPosition(-44900, 99060,,10000)
                BnsActionSprintToPosition(-45600, 100080,,10000)
                BnsActionSprintToPosition(-45580, 103530,,10000)    ;王前集合點
                BnsStopHackSpeed()

        }
    }



    ;------------------------------------------------------------------------------------------------------------
    ;■ 安息庭院 - 導電
    ;------------------------------------------------------------------------------------------------------------
    actionLinkCurrent() {
        
        TYPEA := "1,3,2,4,5,6"
        TYPEB := "1,2,3,4,6,5"
        TYPEC := "1,2,4,3,6,5"
        TYPED := "1,3,6,5,4,2"

        ;第二跟三朵花決定就能決定何種路徑
        SEARCH_PATTERN := "2,3;3,4;2,6"     ;在1找2,3; 在2找3,4; 在3找2,6

        fpos := StrSplit(this.CURRENT_FLOWER_POS,";")

        loop 3 {
            fnow := 1

            ;確定2跟3的花朵
            loop 2 {
                next := this.judgeLightLink(StrSplit(SEARCH_PATTERN,";")[fnow])
                ShowTipI("detected next flower: " next)

                if(next == "") {    ;沒找到，進下一輪重頭找
                    break
                }

                tx := StrSplit(fpos[next], ",")[1]
                ty := StrSplit(fpos[next], ",")[2]
                BnsStartHackSpeed()
                BnsActionSprintToPosition(tx, ty,,15000)
                BnsStartHackSpeed()
                fnow := next


            }

            if(fnow != "") {
                ShowTipI("detected light linked pattern: " fnow)
                break
            }
            else {
                ShowTipI("detected light linked pattern FAILURE!!")
                ShowTipI("Go back to flower1 and retry")
                BnsActionSprintToPosition(StrSplit(fpos[1], ",")[1], StrSplit(fpos[1], ",")[2],,15000)
            }
        }

        ;第三朵花決定 TYPE
        switch fnow {
            case 2:
                type := TYPEA

            case 3:
                type := TYPEB

            case 4:
                type := TYPEC

            case 6:
                type := TYPED
        }

        ;依 type 走完剩下的花朵
        BnsStartHackSpeed()
        loop 3 {
            sleep 1200
            next := StrSplit(type, ",")[A_index + 3]    ;從第四步開始
            tx := StrSplit(fpos[next], ",")[1]
            ty := StrSplit(fpos[next], ",")[2]
            BnsActionSprintToPosition(tx, ty,,15000)
        }
        BnsStartHackSpeed()

    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ 安息庭院 - 判斷導電光鍊類別
    ;------------------------------------------------------------------------------------------------------------
    judgeLightLink(flowers := "2,3") {
        ;   5: -45290, 95189        6: -43800, 95195 
        ;   3: -45290, 93695        4: -43800, 93690
        ;   1: -45290, 92170        2: -43800, 92189

        BnsActionAdjustCamaraAltitude(280)  ;拉到俯視視角270
        BnsActionAdjustCamaraZoom(800)      ;䟳離800

        For i, f in StrSplit(flowers, ",")
        {

            fpos := StrSplit(this.CURRENT_FLOWER_POS,";")   ;將花朵座標列表轉為陣列
            tx := StrSplit(fpos[f], ",")[1]
            ty := StrSplit(fpos[f], ",")[2]
            BnsActionAdjustDirection(BnsMeansureTargetDistDegree(tx, ty)[2])    ;面向下個目標方位
            ; sleep 1000

            count := 0
            loop 10 {
                ; colorGray := GetColorGray(GetPixelColor(WIN_CENTER_X, WIN_CENTER_Y - WIN_BLOCK_HEIGHT*2))   ;轉換為灰階
                ; colorGray := GetColorGray(GetPixelColor(WIN_CENTER_X, WIN_CENTER_Y - WIN_QUARTER_Y))   ;轉換為灰階
                colorGray := GetColorGray(GetPixelColor(WIN_CENTER_X, WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 3))   ;轉換為灰階

                ShowTipI("detected " f  ", gray: " colorGray)
                if(colorGray > 60) {
                    count++
                    ShowTipI("detected light link count: " count)
                    if(count >= 3) {
                        ret := 1
                        break
                    }
                }
                sleep 100
            }

            if(ret == 1) {
                ShowTipI("detected light link to flower: " f)
                return f    ;返回偵則到的下朵花編號
            }

        }

    }





;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 副本導航 ****
    ;------------------------------------------------------------------------------------------------------------
    nativeToDungeon(cate) {
        switch cate {
            case 1:     ;安息庭院
                this.nativeOfTranquilCourtyard(1)

            case 2:


            case 3:
            case 4:
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
    getBossBloodPercent() {
        return floor(this.getTargetBlood() / GetMemoryHack().getMainTargetBloodFull() * 100)
    }

    
    ;------------------------------------------------------------------------------------------------------------
    ;■ 戰鬥脫離
    ;* @return - 0: no action; 1~n: escape 
    ;------------------------------------------------------------------------------------------------------------
    isFightEscape() {

    }


}
