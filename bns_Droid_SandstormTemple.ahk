#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global ST_SkillAsyncLock := 0
global ST_CommonTimeout:=0

;================================================================================================================
;    Main
;================================================================================================================
BnsDroidRun_SandstormTemple() {
    ;校正視角
    ;BnsActionAdjustCamara(-50, 8)

    ;if(BnsActionFixWeapon() == 1) {
        ;ShowTipI("")
    ;}

    ;清除一王前通道
    if(BnsDroidMission_ST_ClearLittleBossCorridor() == 0) {
        return 0
    }

    return

    ;攻略一王
    ;if(BnsDroidMission_GT_KillFirstBoss() == 0) {
    ;    return 0
    ;}

    ;清除二王前通道
    ;if(BnsDroidMission_ClearFinalBossCorridor() == 0) {
    ;    return 0
    ;}

    ;攻略尾王
    ;if(BnsDroidMission_GT_KillFinalBoss() == 0) {
    ;    return 0
    ;}

    ;取得將勵
    ;BnsDroidMission_RewardAndSecret()
}

;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_ST_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
    ST_CommonTimeout:=0
    sleep 1000
}


ST_TIMEOIT_NOTIFY_THREAD() {
    ShowTipE("[GT_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
    ST_CommonTimeout:=1
}



;================================================================================================================
;    Common
;================================================================================================================
BnsDroid_ST_isZakoClear() {
    zakoCheck := 0

    loop 30 {
        if(BnsIsEnemyDetected() == 0) {
            zakoCheck += 1
        }
        else {
            zakoCheck := 0
        }

        if(zakoCheck == 5) {
            return 1
        }
        sleep 100
    }

    return 0
}

;################################################################################################################
;================================================================================================================
;    Mission1 - Gate Keeper
;================================================================================================================
;################################################################################################################
BnsDroidMission_ST_ClearLittleBossCorridor() {
    ShowTipI("●[Mission1] - Clear the corridor before littl Boss")

    BnsActionWalk(6000)
    BnsActionLateralWalkLeft(4000)
    sleep 100
    BnsActionWalk(1000)
    BnsActionLateralWalkLeft(3300)
    sleep 100
    BnsActionWalk(2500)
    BnsActionLateralWalkLeft(1200)
    sleep 100
    BnsActionWalk(2500)
    BnsActionLateralWalkLeft(3000)

    if(BnsDroidMission_ST_TargetCorridor1() == 1) {
        BnsActionAdjustCamara(-50, 8)

        ;跑到長廊樓梯中間(看得到房間內的怪)
        BnsActionSprint(12800)
        sleep 200
    }
    else {
        BnsDroidMission_ST_Fail("Corridor1 targeted failed")
        return 0
    }

    ;開抵抗
    BnsDroidSkill_ProtectBeforeFighting(BnsRoleType())

    ;原地等待雜魚集中
    sleep 10000

    ;自動戰鬥開啟
    BnsStartStopAutoCombat()

    ;確定清完 Stage1 小怪
    if(BnsDroid_ST_isZakoClear() == 1) {
        ShowTipI("●[Mission1] - Corridor stage1 clear")

        ;等自動戰鬥回到定位
        sleep 300

        ;關閉自動戰鬥
        BnsStartStopAutoCombat()
    }


    BnsActionAdjustCamara(-50, 8)

    ;尋找走廊房間
    BnsDroidMission_ST_TargetCorridor2()






    return 1
}



;----------------------------------------------------------------------------
;    Mission1 - 對準走廊
;----------------------------------------------------------------------------
BnsDroidMission_ST_TargetCorridor1() {
    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 7) + 15
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 5)

    hit := 0

    BnsActionAdjustCamara(-50, 11)

    loop, 20 {
        Gray := GetColorGray(GetPixelColor(sX, sY))

        ShowTipD("●[Mission3] - Gray:" Gray ", x:" sX ", y:" sY ", hit:" hit)

        if Gray between 50 and 90
        {
            if(hit == 0) {
                hit := 1    ;採樣點第一次找到左邊柱子
            }
            else if(hit == 1) {
                hit := 2    ;採樣點往右找還是在柱子
            }
        }
        else {
            if(hit != 0) {    ;採樣點往右找已不在柱子上(表示找到柱子右緣)
                ShowTipI("●[Mission1] - Corridor targeted")
                BnsActionRotationLeftPixel(1, 1)
                return 1
            }
        }

        if(hit == 0) {
            BnsActionRotationLeftAngle(3)
        }
        else {
            BnsActionRotationRightPixel(1, 1)
        }

        sleep 30
    }

    ShowTipI("●[E] - Corridor targeted fail!")
    return 0
}




;----------------------------------------------------------------------------
;    Mission2 - 尋找中間方房間
;----------------------------------------------------------------------------
BnsDroidMission_ST_TargetCorridor2() {
    ;尋找傳點花紋上的白色
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
    sY:= WIN_BLOCK_HEIGHT * 1
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 8)
    eY:= WIN_BLOCK_HEIGHT * 5

    if(FindPixelRGB(sX, sY, eX, eY, 0xF06E57, 15) == 1) {
        DumpLogD("[BnsDroidMission_ST_TargetCorridor2] detect Entry, x:" findX ", y:" findY)

        if(findX < WIN_CENTER_X - 10) {
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] Lateral Walk left")
            BnsActionLateralWalkLeft(300)
        }
        else  if(findX > WIN_CENTER_X + 10) {
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] Lateral Walk right")
            BnsActionLateralWalkRight(300)
        }
    }


    loop, 40 {
        if(FindPixelRGB(sX, sY, eX, eY, 0xF06E57, 15) == 1) {
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] detect Entry, x:" findX ", y:" findY)

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
                ShowTipD("[BnsDroidMission_ST_TargetCorridor2] targeted")
                return 1
            }
        }
        else {
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] not found pattern, turn left to search")
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] not found pattern, turn left to start")
            BnsActionRotationLeftAngle(45)
            DumpLogD("[BnsDroidMission_ST_TargetCorridor2] not found pattern, turn left to end")
        }

        sleep 20
    }

    DumpLogE("[BnsDroidMission_ST_TargetCorridor2] search done, pattern not found.")
    return 0


}
