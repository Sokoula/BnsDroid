#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global GT_BOSS1_JUMP_PROTECT_TIMER := -3200

;================================================================================================================
;    █ Interface - Get Character Profiles 
;================================================================================================================
BnsDroidGetCP_GhostfaceTheater() {
    return "GhostfaceTheater.cp"
}


;================================================================================================================
;    █ Interface - Navigation into dungeon
;================================================================================================================
BnsDroidNavigation_GhostfaceTheater() {
    ;向後轉180度(一次性)
    BnsActionRotationDuring(-2.755 * 180, 1)

    ShowTipI("●[System] - Move into dungeon GhostfaceTheater ...")

    if(CONFUSE_PROTECT == 1) {
        BnsActionRandomConfuseMove(3500)
    }
    else {
        BnsActionSprint(2200)
    }

    sleep 1500

    if(BnsWaitMapLoadDone() == 0) {
        return 0
    }
}



;================================================================================================================
;    █ Main
;================================================================================================================
BnsDroidRun_GhostfaceTheater() {
    ;校正視角
    BnsActionAdjustCamara(-50, 8)

    if(BnsActionFixWeapon() == 1) {
        ;ShowTipI("")
    }

    ;攻略守門怪
    if(BnsDroidMission_GT_KillGateKeeper() == 0) {
        ;return 0
        return BnsDungeonRetreat()
    }

    ;攻略一王
    if(BnsDroidMission_GT_KillFirstBoss() == 0) {
        ;return 0
        return BnsDungeonRetreat()
    }

    ;攻略尾王
    if(BnsDroidMission_GT_KillFinalBoss() == 0) {
        ;return 0
        return BnsDungeonRetreat()
    }

    ;取得將勵
    BnsDroidMission_RewardAndSecret()

    ;離開副本
    if(BsnLookingExitDirection() == 0 ) {
        return BnsDungeonRetreat()
    }

    ;@Discard
    if(BnsDungeonLeave(5300) == 0) {    ;有商人3300, 沒商人5300
        return BnsDungeonRetreat()
    }
    
    ;if(BnsDungeonLeave(BsnLookingExit()) == 0) {
    ;    return BnsDungeonRetreat()
    ;}
    
}




;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_GT_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
    CommonTimeout:=0
    sleep 1000
}


GT_TIMEOUT_NOTIFY_THREAD() {
    ShowTipE("[GT_TIMEOUT_NOTIFY_THREAD] Procedure Timeout！！！")
    CommonTimeout:=1
}


;################################################################################################################
;================================================================================================================
;    Mission1 - Gate Keeper
;================================================================================================================
;################################################################################################################
BnsDroidMission_GT_KillGateKeeper() {
    ShowTipI("●[Mission1] - Looking for gatekeeper")

    ;跑到第一個門口
    BnsActionSprint(11300)
    BnsActionLateralWalkLeft(8100)
    sleep 200
    BnsActionWalk(500)

    ;進入戰鬥
    if(BnsIsEnemyDetected() > 0) {
        ShowTipI("●[Mission1] - Fighting gatekeeper")
        durning:=0

        ;戰鬥前置準備(喝水，吃符，開星等)
        BnsDroidSkill_commonPrepare()

        ;啟動非同步計時，時間到放技能
        SetTimer, GT_GATE_FIGHTING_SKILL_THREAD, -5800        ;戰鬥中施放(負值表示只執行一次，不需另設off)
        
        ;啟動非同步計時，計算長CD時間
        if(PARTY_MODE == 3){
            global SkillAsyncLock := 1
            SetTimer, WAIT_SKILL_CD_DONE_THREAD, -61000        ;戰鬥中使用，CD 很長的技能(一王前等待)
        }

        ;超時計時器 60s
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, -60000

        ;自動戰鬥開啟
        BnsStartStopAutoCombat()

        while(BnsIsEnemyDetected() > 0 && CommonTimeout == 0) {
            sleep 100
        }
        
        if(CommonTimeout == 1) {
            BnsDroidMission_GT_Fail("Fight timeout, escape gatekeeper fighting program")
            return 0
        }

        ;註消計時器
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, delete            ;未超時, 解除超時計時
        SetTimer, GT_GATE_FIGHTING_SKILL_THREAD, delete        ;取消來不及放的技能計時器(王死太快)

        ;自動戰鬥關閉
        BnsStartStopAutoCombat()

        ShowTipI("●[Mission1] - Completed")
        sleep 5000
    }
    else {
        BnsDroidMission_GT_Fail("Not found gatekeeper")
        ;ShowTip("●[Mission1] - Exception, no found gatekeeper")
        return 0
    }
    
    return 1
}

;----------------------------------------------------------------------------
;    Mission1 - 使用技能(非同步計時)
;----------------------------------------------------------------------------
GT_GATE_FIGHTING_SKILL_THREAD() {
    BnsDroidSkill_ProtectInFighting(BnsRoleType())
}


;################################################################################################################
;================================================================================================================
;    Mission2 - Little BOSS
;================================================================================================================
;################################################################################################################
BnsDroidMission_GT_KillFirstBoss() {
    ShowTipI("●[Mission2] - Looking for first Boss")

    BnsActionAdjustCamara(-50, 8)

    ;向後轉尋找一王通道
    if(BnsDroidAction_GT_SearchFirstBossEntry() == 0) {
        BnsDroidMission_GT_Fail("Not detect 1st BOSS entry, go back dungeon hall")
        return 0
    }

    ShowTipI("●[Mission2] - Move to first Boss's room")
    if(PARTY_MODE == 3){
        BnsActionWalk(15000)
    }
    else {
        BnsActionSprint(8000)
    }
    BnsActionSprintJump(1100)

    BnsActionWalk(2500)

    ;旋轉以面向BOSS
    if(BnsDroidAction_FaceToBoss() == 0) {
        BnsActionWalk(300)
        if(BnsDroidAction_FaceToBoss() == 0) {
            BnsDroidMission_GT_Fail("Face to Boss fail")
            return 0
        }
    }
    
    ;等前次戰鬥施放的技能CD完成
    ;ShowTipI("●[Mission2] - Waiting for CD done")
    while(global SkillAsyncLock == 1) {
        ShowTipI("●[Mission2] - Waiting for CD done")
        sleep 1000
    }

    ;進入戰鬥
    if(BnsIsEnemyDetected() > 0) {
        ShowTipI("●[Mission2] - Fighting first Boss")
        durning=0

        BnsDroidSkill_commonPrepare()

        BnsDroidSkill_ProtectBeforeFighting(BnsRoleType())

        DumpLogD("●[Mission2] - GT_BOSS1_JUMP_PROTECT_TIMER =" GT_BOSS1_JUMP_PROTECT_TIMER)
        ;啟動非同步計時，時間到放技能
        SetTimer, GT_BOSS1_FIGHTING_SKILL_THREAD, %GT_BOSS1_JUMP_PROTECT_TIMER%

        ;啟動非同步計時，計算長CD時間
        if(PARTY_MODE == 3) {
            global SkillAsyncLock := 1
            SetTimer, WAIT_SKILL_CD_DONE_THREAD, -61000        ;戰鬥中使用，CD 很長的技能
        }

        ;超時計時器 60s
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, -60000

        ;自動戰鬥開啟
        BnsStartStopAutoCombat()

        while(BnsIsEnemyDetected() > 0  && CommonTimeout == 0) {
            sleep 100
        }

        if(CommonTimeout == 1) {
            BnsDroidMission_GT_Fail("Fight timeout, escape BOSS1 fighting program")
            return 0
        }

        ;註消計時器
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, delete            ;未超時, 解除超時計時
        SetTimer, GT_BOSS1_FIGHTING_SKILL_THREAD, delete    ;取消來不及放的技能計時器(王死太快)

        ;自動戰鬥關閉
        sleep 100    ;等300ms, 讓自動戰鬥接近箱子
        BnsStartStopAutoCombat()

        ShowTipI("●[Mission2] - Completed")
        sleep 6000
    }
    else {
        BnsDroidMission_GT_Fail("no found first BOSS")
        ;ShowTip("●[Mission2] - Exception, no found first BOSS")
        return 0
    }
    
    return 1
}



;----------------------------------------------------------------------------
;    Mission2 - 尋找一王通道
;----------------------------------------------------------------------------
BnsDroidAction_GT_SearchFirstBossEntry() {
    
    ;先看看正前方是不是目標
    if(BnsDroidAction_GT_SearchFirstBossEntryPattern() == 7) {
        return 1
    }
    
    ;向左後轉大角度
    ;BnsActionRotationDuring(-2.755 * 155, 1)
    ;轉向指定角度
    BnsActionAdjustDirectionOnMap(75)
    

    ;左旋尋找
    loop, 20
    {
        turn := BnsDroidAction_GT_SearchFirstBossEntryPattern()
        
        if( turn == 7 ) {
            ;完美定位
            ShowTipI("●[Mission2] - Search first entry Success!")
            return 1
        }
        
        if( turn & 0x04 == 0) {
            ;偏差有點遠，大角度繼續轉頭找
            BnsActionRotationLeftAngle(6)
        }
        else {
            ;目標近了，小角度找
            ;BnsActionRotationLeftAngle(1)
            BnsActionRotationLeftPixel(1, 1)
        }
    }

    return 0
}

;----------------------------------------------------------------------------
;    Mission2 - 比對一王通道特徵
;----------------------------------------------------------------------------
BnsDroidAction_GT_SearchFirstBossEntryPattern() {
    ;定位左右柱子上的黃黑色塊

    result:=0

    leftYellow:=-1
    leftBlock:=-1
    
    rightYellow:=-1
    rightBlock:=-1

    centerLight:=-1


    ;找左門黃色
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 5)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 4.8)
    eX:=sX + (WIN_BLOCK_WIDTH * 0.3)
    eY:=sY + (WIN_BLOCK_HEIGHT * 0.3)
    if(FindPixelRGB(sX, sY, eX, eY, 0x5D3D20, 16) == 1) {
        leftYellow:=findX
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] leftYellow:" leftYellow)
    }
    
    ;找左門黑色
    sY:=sY + (WIN_BLOCK_HEIGHT * 0.4)
    eY:=sY + (WIN_BLOCK_HEIGHT * 0.5)

    if(FindPixelRGB(sX, sY, eX, eY, 0x141520, 16) == 1) {
        leftBlock:=findX
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] leftBlock:" leftBlock)
    }

    if(leftYellow != -1 && leftBlock != -1) {
        result += 1
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] left:" result)
    }


    ;找右門黃色
    sX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 5)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 4.8)
    eX:=sX + (WIN_BLOCK_WIDTH * 0.3)
    eY:=sY + (WIN_BLOCK_HEIGHT * 0.3)
    if(FindPixelRGB(sX, sY, eX, eY, 0x5D3D20, 16) == 1) {
        rightYellow:=findX
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] rightYellow:" rightYellow)
    }
    
    ;找右門黑色
    sY:=sY + (WIN_BLOCK_HEIGHT * 0.4)
    eY:=sY + (WIN_BLOCK_HEIGHT * 0.5)
    if(FindPixelRGB(sX, sY, eX, eY, 0x141520, 16) == 1) {
        rightBlock:=findX
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] rightBlock:" rightBlock)
    }

    if(rightYellow != -1 && rightBlock != -1) {
        result += 2
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] right:" result)
    }

    ;中間燈光
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 0.33)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 5)    ;+ (WIN_BLOCK_HEIGHT//3)
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 0.33)
    eY:= sY + (WIN_BLOCK_HEIGHT * 0.5)
    if(FindPixelRGB(sX, sY, eX, eY, 0x877568, 8) == 1) {
        centerLight:=findX
        result += 4
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] centerLight:" centerLight)
        DumpLogD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] center:" result)
    }
    
    ShowTipD("[BnsDroidAction_GT_SearchFirstBossEntryPattern] final result:" result)
    return result
}

;@Discard
BnsDroidAction_GT_SearchFirstBossEntryPattern_UE3() {
    ;□ ■ ■ □ 中心4點取色比對，中間兩格紅色較高，左右紅色較低為入口特徵
    result := 0

    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 2)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 5)

    avg1 := GetAverageColor(sX, sY, WIN_BLOCK_WIDTH, WIN_BLOCK_HEIGHT / 2)
    ;MouseMove sX+ 30,sY + 30
    ;sleep 1000
    
    sX := WIN_CENTER_X - WIN_BLOCK_WIDTH
    avg2 := GetAverageColor(sX, sY, WIN_BLOCK_WIDTH, WIN_BLOCK_HEIGHT / 2)
    ;MouseMove sX+ 30,sY + 30
    ;sleep 1000
    
    sX := WIN_CENTER_X
    avg3 := GetAverageColor(sX, sY, WIN_BLOCK_WIDTH, WIN_BLOCK_HEIGHT / 2)
    ;MouseMove sX+ 30,sY + 30
    ;sleep 1000
    
    
    sX := WIN_CENTER_X + WIN_BLOCK_WIDTH
    avg4 := GetAverageColor(sX, sY, WIN_BLOCK_WIDTH, WIN_BLOCK_HEIGHT / 2)
    ;MouseMove sX+ 30,sY + 30
    ;sleep 1000

    avgR1 := (avg1 >> 16) & 0xFF
    avgR2 := (avg2 >> 16) & 0xFF
    avgR3 := (avg3 >> 16) & 0xFF
    avgR4 := (avg4 >> 16) & 0xFF


    if avgR1 < 120
    {    
        result += 1
    }

    if avgR2 > 90
    {    
        result += 2
    }

    if avgR3 > 90
    {    
        result += 4
    }

    if avgR4 < 120
    {    
        result += 8
    }

    ;中心以左2格偏紅，畫面偏向為1~2點鐘方位
    if(avgR1 > 120 && avgR2 > 120) {
        result := 16
    }


    ;中心以右2格偏紅，畫面偏向為10~11點鐘方位, 向右旋轉
    if(avgR3 > 120 && avgR4 > 120) {
        result := -16
    }

    ShowTipD("[SearchFirstBossEntryPattern] result:" result ", [" avgR1 ", " avgR2 ", " avgR3 ", " avgR4 "]")
    ;sleep 3000
    
    return result
}

;----------------------------------------------------------------------------
;    Mission2 - 使用技能(非同步計時)
;----------------------------------------------------------------------------
GT_BOSS1_FIGHTING_SKILL_THREAD() {
    DumpLogD("BnsDroidSkill_ProtectInFighting thread start")
    BnsDroidSkill_ProtectInFighting(BnsRoleType())
}


;################################################################################################################
;================================================================================================================
;    Mission3 - Fianl BOSS
;================================================================================================================
;################################################################################################################
BnsDroidMission_GT_KillFinalBoss() {
    ShowTipI("●[Mission3] - Looking for fianl Boss")
    
    BnsActionAdjustCamara(-50, 8)
    
    ;向後轉尋找尾王通道
    if(BnsDroidAction_GT_SearchFinalBossEntry() == 0) {
        BnsDroidMission_GT_Fail("Not detect final BOSS entry, go back dungeon hall")
        return 0
    }
    
    sleep 1000
    ShowTipI("●[Mission3] - Move to final Boss's room")
    

    ;移動到傳點
    if(PARTY_MODE == 3){
        BnsActionWalk(15000)
    }
    else {
        BnsActionSprint(9000)
    }
    sleep 2000

    if(BnsDroidAction_GT_AdjustFinalBossCorridor() == 0){
        ShowTipW("●[Mission3] - Adjust corridor failed!")
    }
    
    ShowTipI("●[Mission3] - Keep move to fight the final Boss")
    ;移動到尾王
    BnsActionSprint(6000)    ;輕功
    BnsActionSprintJump(800)
    sleep 1500

    ;BnsActionWalk(13000)        ;正常走
    ;sleep 600

    ;墜落滑翔
    Send {Space Down}
    sleep 200
    Send {Space Up}
    sleep 400
    Send {Space Down}
    sleep 200
    Send {Space Up}
    sleep 200
    
    BnsActionWalk(1000)


    ;旋轉以面向BOSS
    if(BnsDroidAction_FaceToBoss() == 0) {
        BnsActionWalk(300)
        if(BnsDroidAction_FaceToBoss() == 0) {
            BnsDroidMission_GT_Fail("Face to Boss fail")
            return 0
        }
    }


    ;等前次戰鬥施放的技能CD完成
    ShowTipI("●[Mission3] - Waiting for CD done")
    while(global SkillAsyncLock == 1) {
        sleep 1000
    }

    ;進入戰鬥
    if(BnsIsEnemyDetected() > 0) {
        ShowTipI("●[Mission3] - Fighting final Boss")
        durning=0

        BnsDroidSkill_commonPrepare()

        ;超時計時器 60s
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, -60000

        ;自動戰鬥開啟
        BnsStartStopAutoCombat()

        ;啟動非同步計時，時間到放技能
        SetTimer, GT_FINAL_FIGHTING_SKILL_THREAD, -11000        ;戰鬥中施放(負值表示只執行一次，不需另設off)

        while(BnsIsEnemyDetected() > 0  && CommonTimeout == 0) {
            sleep 100
        }
        
        if(CommonTimeout == 1) {
            BnsDroidMission_GT_Fail("Fight timeout, escape final BOSS fighting program")
            return 0
        }
        
        ;註消計時器
        SetTimer, GT_TIMEOUT_NOTIFY_THREAD, delete                ;未超時, 解除超時計時
        SetTimer, GT_FINAL_FIGHTING_SKILL_THREAD, delete        ;取消來不及放的技能計時器(王死太快)

        ;自動戰鬥關閉
        sleep 400    ;等400ms, 讓自動戰鬥接近箱子
        BnsStartStopAutoCombat()

        ShowTipI("●[Mission3] - Completed")
        sleep 8000    ;等王屍體消失，以免影響判斷
    }
    else {
        BnsDroidMission_GT_Fail("no found first BOSS")
        ;ShowTip("●[Mission2] - Exception, no found first BOSS")
        return 0
    }
    
    return 1
}


;----------------------------------------------------------------------------
;    Mission3 - 使用技能(非同步計時)
;----------------------------------------------------------------------------
GT_FINAL_FIGHTING_SKILL_THREAD() {
    BnsDroidSkill_ProtectInFighting(BnsRoleType())
}

;----------------------------------------------------------------------------
;    Mission3 - 尋找尾王門口
;----------------------------------------------------------------------------
BnsDroidAction_GT_SearchFinalBossEntry() {
    ;尋找傳點花紋上的白色
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 7)
    sY:= WIN_BLOCK_HEIGHT * 0.5
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 7)
    eY:= WIN_BLOCK_HEIGHT * 4
    
    ;先向右小轉，處理門只在右邊一點點避免繞整圈
    ;DumpLogD("[BnsDroidAction_GT_SearchFinalBossEntry] not found pattern, turn left to search")
    ;BnsActionRotationRightAngle(8)

    ;轉向指定角度
    BnsActionAdjustDirectionOnMap(80)


    
    loop, 40 {
        if(FindPixelRGB(sX, sY, eX, eY, 0xD8D7E4, 8) == 1) {
            DumpLogD("[BnsDroidAction_GT_SearchFinalBossEntry] detect Entry, x:" findX ", y:" findY)

            if(findX > WIN_CENTER_X + 8) {
                if((findX - WIN_CENTER_X) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationRightAngle(6)
                }
                else {
                    ;BnsActionRotationRightAngle(1)
                    BnsActionRotationRightPixel(1, 1)
                }
            }
            else if(findX < WIN_CENTER_X - 8) {
                if((WIN_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationLeftAngle(6)
                }
                else {
                    ;BnsActionRotationLeftAngle(1)
                    BnsActionRotationLeftPixel(1, 1)
                }
            }
            else {
                ShowTipD("[BnsDroidAction_GT_SearchFinalBossEntry] targeted")
                return 1
            }
        }
        else {
            DumpLogD("[BnsDroidAction_GT_SearchFinalBossEntry] not found pattern, turn left to search")
            BnsActionRotationLeftAngle(45)
        }

        sleep 20
    }
    
    DumpLogE("[BnsDroidAction_GT_SearchFinalBossEntry] search done, pattern not found.")
    return 0
}

;----------------------------------------------------------------------------
;    Mission3 - 調整尾王走廊定位(過傳點之後)
;----------------------------------------------------------------------------
BnsDroidAction_GT_AdjustFinalBossCorridor() {
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 5.3)
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 8)
    eY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 4.6)


    if(FindPixelRGB(sX, sY, eX, eY, 0xFFFBF2, 10) == 1) {
        DumpLogD("[BnsDroidAction_GT_AdjustFinalBossCorridor] detect Entry, x:" findX ", y:" findY)

        if(findX < WIN_CENTER_X - 10) {
            DumpLogD("[BnsDroidAction_GT_AdjustFinalBossCorridor] Lateral Walk left")
            BnsActionLateralWalkLeft(300)
        }
        else  if(findX > WIN_CENTER_X + 10) {
            DumpLogD("[BnsDroidAction_GT_AdjustFinalBossCorridor] Lateral Walk right")
            BnsActionLateralWalkRight(300)
        }
    }
    
    loop, 30 {
        if(FindPixelRGB(sX, sY, eX, eY, 0xFFFBF2, 10) == 1) {
            if(findX > WIN_CENTER_X + 10) {
                if((findX - WIN_CENTER_X) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationRightAngle(3)
                }
                else {
                    ;BnsActionRotationRightAngle(1)
                    BnsActionRotationRightPixel(1, 1)
                }
            }
            else if(findX < WIN_CENTER_X - 10) {
                if((WIN_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationLeftAngle(3)
                }
                else {
                    ;BnsActionRotationLeftAngle(1)
                    BnsActionRotationLeftPixel(1,1)
                }
            }
            else {
                ShowTipD("[BnsDroidAction_GT_SearchFinalBossEntry] targeted")
                return 1
            }
        }
    }
    
    DumpLogE("[BnsDroidAction_GT_AdjustFinalBossCorridor] search done, pattern not found.")
    return 0
    
}

;@Discard
BnsDroidAction_GT_AdjustFinalBossCorridor2() {
    ;;媽的不知道為什麼左邊貼牆先找，右邊取色就會出錯 0x767676

    ;貼右牆迴避
    sX := WIN_CENTER_X + (WIN_BLOCK_WIDTH *2)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 3)

    colorRaw := GetPixelColor(ssX, sY)
    
    R := GetColorRed(colorRaw)
    G := GetColorGreen(colorRaw)
    B := GetColorBlue(colorRaw)

    if(DBUG == 1) 
        ShowTip("[AdjustFinalBossCorridor] sX" sX ", sY" sY ", color:" pixelColor ", R:" R ", G:" G ", B:" B, sX+10, sY)

    if R between 0x00 and 0x50
    {
        BnsActionLateralWalkLeft(300)
    }

    ;貼左牆迴避
    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 2)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 3)

    colorRaw := GetPixelColor(ssX, sY)
    
    R := GetColorRed(colorRaw)
    G := GetColorGreen(colorRaw)
    B := GetColorBlue(colorRaw)

    if(DBUG == 1) 
        ShowTip("[AdjustFinalBossCorridor] sX" sX ", sY" sY ", color:" pixelColor ", R:" R ", G:" G ", B:" B, sX+10, sY)

    if R between 0x00 and 0x50
    {
        BnsActionLateralWalkRight(300)
    }

    
    ;左側尋標定位
    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 5)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 3) - 10

    scan := WIN_BLOCK_WIDTH * 5

    loop, %scan%
    {
        if(Mod(A_Index, 5) == 0) {
            ssX := sX + A_index
            colorRaw := GetPixelColor(ssX, sY)
            
            R := GetColorRed(colorRaw)
            G := GetColorGreen(colorRaw)
            B := GetColorBlue(colorRaw)

            if(DEBG == 1) 
                ShowTip("[AdjustFinalBossCorridor] i:" A_index ", ssX" ssX ", sY" sY ", color:" pixelColor ", R:" R ", G:" G ", B:" B, ssX+10, sY)

            if R between 0xF0 and 0xFF
            {    
                if G between 0xF0 and 0xFF
                {
                    if B between 0xD0 and 0xF0
                    {
                        if(ssX < (WIN_CENTER_X - 40))
                        {
                            BnsActionLateralWalkLeft(200)
                            ;BnsActionRotationLeftAngle(1)
                        }
                        return 1
                    }
                }
            }
        }
    }

    ;右側尋標定位
    sX := WIN_CENTER_X + (WIN_BLOCK_WIDTH * 4)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 3) - 10
    
    scan := WIN_BLOCK_WIDTH * 5

    loop, %scan%
    {
        if(Mod(A_Index, 5) == 0) {
            ssX := sX + WIN_BLOCK_WIDTH - A_index
            colorRaw := GetPixelColor(ssX, sY)
            
            R := GetColorRed(colorRaw)
            G := GetColorGreen(colorRaw)
            B := GetColorBlue(colorRaw)

            if(DBUG == 1) 
                ShowTip("[AdjustFinalBossCorridor] i:" A_index ", ssX" ssX ", sY" sY ", color:" pixelColor ", R:" R ", G:" G ", B:" B, ssX+10, sY)

            if R between 0xF0 and 0xFF
            {    
                if G between 0xF0 and 0xFF
                {
                    if B between 0xD0 and 0xF0
                    {
                        if(ssX > (WIN_CENTER_X + 40))
                        {
                            BnsActionLateralWalkRight(200)
                            ;BnsActionRotationRightAngle(1)
                        }
                        return 1
                    }
                }
            }
        }    
    }

    return 0
}


;################################################################################################################
;================================================================================================================
;    Mission4 - Reward and Secret store
;================================================================================================================
;################################################################################################################
BnsDroidMission_RewardAndSecret(){
    ShowTipI("●[Mission4] - Pick reward and secret store shoping")

    ;尋找箱子，點擊拾取
    if(LookingRewardBox() == 1) {
        ShowTipI("●[Mission4] - Open reward box")
        Send f
        sleep 200
        
        PickItems("res\pic_pick_reward")
    }
    else {
        ShowTipW("●[Mission4] - Not found reward box")
    }

    if(SECRET_SUPPORT == 1) {    ;如果支援神祕商人
        if(LookingSecretMerchant() == 1) {
            if(VisitSecretStore() == 0) {
                BnsDroidMission_GT_Fail("Talk to merchant failed")
            }
            else {
                ShowTipI("●[Mission4] - Secret store opened")
                
                ScreenShot()
                BuyItem("res\pic_buy_secret")
            }
        }
    }

    ShowTipI("●[Mission4] - Mission completed")
    sleep 500
    
    ShowTipI("●[Mission4] - Go to next mission cycle")
}

