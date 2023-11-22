#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global CHARACTER_PROFILES    ;defined in bns_common.ahk
global PROFILES_ITERATOR

;================================================================================================================
;    █ Interface - Get Character Profiles 
;================================================================================================================
BnsDroidGetCP_ShroudedAjanara() {
    return "SuspiciousSkyIsland.cp"
}


;================================================================================================================
;    █ Interface - Navigation into dungeon
;================================================================================================================
BnsDroidNavigation_ShroudedAjanara() {
    return BnsOuF8DefaultGoInDungeon(1)
}


;================================================================================================================
;    █ Main
;================================================================================================================
BnsDroidRun_ShroudedAjanara() {
    
    ;校正視角
    ;BnsActionAdjustCamara(-50, 8)

    BnsActionFixWeapon()

    ;自動執行戰鬥
    BnsDroidMission_SI_AutoFighting()

    return 1
}


;================================================================================================================
;    Error
;================================================================================================================
BnsDroidMission_SA_Fail(ex) {
    ShowTipE("●[Exception] - " ex)
}


;################################################################################################################
;================================================================================================================
;    Mission1 - Auto Fighting
;================================================================================================================
;################################################################################################################
BnsDroidMission_SA_AutoFighting(){
        attackMode := 0
        
        ; BnsActionLateralWalkRight(800)
        ; BnsActionWalk(4500)
        ; return 1

        BnsStartAutoCombat()    ;start

        sleep 1000
        
        ; bossSkillShift(2500)
        bossSkillShift(2000)


        loop {
            x := 790
            y := 120
            w := 360
            h := 18

            x80 := x + floor(w * 0.795)
            y80 := y + floor(h * 0.5)

            
            g := GetColorGray(GetPixelColor(x80, y80))

            if((g > 148 && g < 151) || g < 50) {
                ShowTipD("偵測血量到達 80%, g=" g )
                
        
                ShowTipD("進入機制, 遠離王等待模式判定")
                ; BnsStartStopAutoCombat()    ;stop
                ; msleep(30)
                ; BnsStartStopAutoCombat()    ;start    調整視角
                ; msleep(30)
                ; BnsStartStopAutoCombat()    ;stop
                ; msleep(30)
                BnsStopAutoCombat()    ;stop
                BnsStartHackSpeed()
                BnsActionRotationDegree180()
                BnsActionWalk(1500)
                BnsActionRotationDegree180()
                BnsStopHackSpeed()

                ; msleep(350)
                dsleep(900)
                
                ax := 790 + floor(w * 0.8)
                ay := 120 - floor(h * 0.8)
                
                c := GetPixelColor(ax, ay)
                
                r := GetColorRed(c)
                g := GetColorGreen(c)
                b := GetColorBlue(c)
                 
                if (abs(r - g) < 0x10 &&  abs(g - b) < 0x10 && abs(r - b) < 0x10 && r > 0x50) {
                    ShowTipD("偵測到BOSS進行 A 類攻擊 ")
                    attackMode := 1
                }
                else {
                    ShowTipD("偵測到BOSS進行 B 類攻擊 ")
                    attackMode := 2
                }
                break
            }
        }

        THFight(attackMode)
        
        ShowTipD("繼續戰鬥至 40%")
        sleep 13000     ;視機體而定

        bossSkillShift(3000)

        loop {
            x := 790
            y := 120
            w := 360
            h := 18

            x40 := 932          ;x + floor(w * 0.41)
            y40 := 123          ;y + floor(h * 0.2)

            g := GetColorGray(GetPixelColor(x40, y40))

            if(g < 40 || g > 130) {
                ShowTipD( "偵測血量到達 40%, g=" g )
                ShowTipD("進入機制, 遠離王準備應對")
                BnsStartStopAutoCombat()    ;stop
                BnsStartHackSpeed()
                BnsActionRotationDegree180()
                BnsActionWalk(1500)
                BnsStopHackSpeed()
                ; BnsActionRotationDegree180()
                BnsActionRotationDuring(-2.755 * 178, 1)
                dsleep(300)

                if(attackMode == 1) {
                    ShowTipD("偵測到 BOSS 將進行 B 類攻擊 ")
                    attackMode := 2
                    ; msleep(1000)
                }
                else {
                    ShowTipD("偵測到 BOSS 將進行 A 類攻擊 ")
                    attackMode := 1
                    ; msleep(2000)
                }

                break
            }
        }    

        
        THFight(attackMode)
        
        ShowTipD("繼續戰鬥結束")
        
        if(BnsIsEnemyClear(3000,0) == 1) {
            ShowTipD("戰鬥結束")
        }

        ; BnsActionAdjustDirectionOnMap(303)
        ; BnsActionWalk(4500)

        ; send {f}

        return 0

        ;FindPixelRGB(WIN_CENTER_X, 0, WIN_CENTER_X, A_ScreenHeight, 0x535E68, 0x08)

        ; sY := findY
        ; FindPixelRGB(WIN_CENTER_X, sY + A_ScreenHeight // 5 , WIN_CENTER_X, A_ScreenHeight, 0x697883, 0x08)
        ; cY := sY + (findY - sY) // 2

        ; FindPixelRGB(0, cY, WIN_CENTER_X, cY, 0x535E68, 0x08)
        ; sX := findX
        ; FindPixelRGB(WIN_CENTER_X, cY, A_ScreenWidth, cY, 0x576469, 0x08)
        ; width := findX - sX
        
        ; t:=2

        ; MouseMove sX + (width // 4) * t - ( width // 8), cY
}

THFight(attackMode) {
        if(attackMode == 1) {    ;特殊攻擊 type A, 從天而降的掌法
            reactionTypeA()
        }
        else {    ;特殊攻擊 type B, 飛高高
            reactionTypeB()
        }
}


reactionTypeA() {
    ; BnsStartStopAutoCombat()    ;stop
    ShowTipD("TYPE A: 原地硬吃6層")
    ; msleep(4300)    ;ori
    ; dsleep(4000)        ;劍
    dsleep(3800)      ;拳

    ShowTipD("TYPE A: 起身")
    send {1} ;劍士起身
    dsleep(500)

    ShowTipD("TYPE A: CE 離開第7掌範圍")    ;可以省下起身的3秒
    BnsStartHackSpeed()        ;speed on
    BnsActionWalk(1200)
    BnsActionRotationDegree180()
    dsleep(1000)
    ShowTipD("TYPE A: CE 回去吃第7層")    ;可以省下起身的3秒
    BnsActionWalk(1200)
    ; BnsStopHackSpeed()


    ; ShowTipD("起身吃第7層")
    ; BnsActionLateralWalkRight(600)
    ; Send {w Down} {a Down}
    ; msleep(600)
    ; Send {w Up} {a Up}

    ; BnsActionRotationDegree180()
    ; BnsStartHackSpeed()
    ; BnsActionWalk(300)
    ; msleep(300)
    ; BnsActionRotationDegree180()
    ; BnsActionLateralWalkRight(100)
    ; BnsActionWalk(500)
    ; BnsStopHackSpeed()

    ; ShowTipD("硬吃第7掌")
    ; msleep(2900)

    BnsActionRotationDegree180()
    ; msleep(700)
    dsleep(400)
    ; BnsActionWalk(400)
    BnsActionWalk(400)
    BnsActionRotationDegree180()
    BnsStopHackSpeed()        ;speed off


    ShowTipD("TYPE A: SS抵抗")
    send {s 2}
    dsleep(30)
    send {s 2}
    ; send {1 3}
    ; msleep(200)
    ; send {f 3}
    ; msleep(100)

    dsleep(500)
    BnsStartStopAutoCombat()    ;start
}



reactionTypeB() {
    ; BnsStartStopAutoCombat()    ;stop

    ShowTipD("TYPE B: 等待崩拳放完")
    ; msleep(2000)    ;ori
    dsleep(1900)

    BnsStartHackSpeed()    ;speed on
    ; ShowTipD("TYPE B: CE 離開第1次崩拳的範圍")    ;拉遠距離比較好處理
    ; BnsStartStopAutoCombat()    ;stop
    ; msleep(10)
    ; BnsStartStopAutoCombat()    ;start    調整視角
    ; msleep(10)
    ; BnsStartStopAutoCombat()    ;stop
    ; msleep(10)
    ; BnsActionRotationDegree180()
    ; BnsActionWalk(1200)
    ; BnsActionRotationDegree180()
    ; msleep(200)

    ; ShowTipD("TYPE B: 踩前3圈後站第4圈")
    ShowTipD("TYPE B: 踩前3圈")
    ; BnsActionWalk(1200)
    BnsActionWalk(1250)
    ;BnsActionRotationDegree180()

    BnsStopHackSpeed()    ;speed off
    ShowTipD("TYPE B: 輕功起跳躲飛高高")
    Send, {w Down}
    Send, {Shift}
    dsleep(200)    ;必需 > 200ms, 不然跳不起來
    Send, {Space Down}    ;Space 必需拆開寫，不然沒作用
    dsleep(50)
    Send, {Space Up}
    dsleep(400)            ;不要動這個, 需要 400ms 才能到最高點
    Send, {w Up}
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
    dsleep(200)

    BnsStartHackSpeed()

    ; ShowTipD("TYPE B: 飛高高")
    ; msleep(3000)

    ; ShowTipD("TYPE B: 起身")
    ; send {1} ;劍士起身
    ; msleep(600)

    ; ShowTipD("TYPE B: CE 繞背閃避2次崩拳的範圍")    ;拉遠距離比較好處理
    ; BnsActionWalk(600)
    ; BnsActionRotationDegree180()
    ; msleep(1500)

    ShowTipD("TYPE B: 遠離第2次崩拳的範圍")    ;拉遠距離比較好處理
    ; BnsActionRotationDegree180()
    BnsActionWalk(1400)
    BnsActionRotationDegree180()

    dsleep(2100)
    ShowTipD("TYPE A: 踩後3圈")
    ; BnsActionWalk(1200)
    BnsActionWalk(1000)
    ; BnsActionRotationDegree180()


    ; ShowTipD("TYPE A: 繞背躲避")
    ; BnsActionWalk(300)
    ; BnsStartStopAutoCombat()    ;stopd
    ; BnsActionRotationDegree180()
    ; msleep(2800)

    ; ShowTipD("TYPE A: 踩前3圈")
    ; BnsActionWalk(700)
    ; BnsActionRotationDegree180()
    ; ShowTipD("TYPE A: 前往第4圈")
    ; BnsActionWalk(800)
    ; BnsActionRotationDegree180()

    ; ShowTipD("TYPE A: 飛高高")
    ; msleep(3000)

    ; ShowTipD("TYPE A: 繞背躲避")
    ; BnsActionWalk(400)
    ; BnsActionRotationDegree180()
    ; msleep(2800)

    ; ShowTipD("TYPE A: 踩後3圈")
    ; BnsActionWalk(700)
    ; BnsActionRotationDegree180()

    ShowTipD("TYPE B: 貼王給3控")
    ; ShowTipD("TYPE B: 劍士3控")
    ; send {z}
    ; msleep(300)
    ; ShowTipD("TYPE B: 下斷斬1")
    ; send {3, 3}
    ; msleep(300)
    ; ShowTipD("TYPE B: 下斷斬2")
    ; send {3, 3}
    BnsStopHackSpeed()
    ShowTipD("TYPE B: 突進貼王")
    send {2 Down}
    dsleep(100)
    send {2 Up}
    dsleep(500)
    ShowTipD("TYPE B: 飛燕劍1")
    send {z Down}
    dsleep(100)
    send {z Up}
    dsleep(500)
    ShowTipD("TYPE B: 下斷斬2")
    send {3 Down}
    dsleep(100)
    send {3 Up}
    dsleep(500)
    ShowTipD("TYPE B: 下斷斬3")
    send {3 Down}
    dsleep(100)
    send {3 Up}

    dsleep(500)
    BnsStartStopAutoCombat()    ;start
}

;================================================================================================================
;█ Functions - ACTIONS
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------
    ;■ 時間差避讓時間
    ;* @return - none
    ;------------------------------------------------------------------------------------------------------------
    bossSkillShift(delay := 100) {
        BnsStopAutoCombat()
        sleep %delay%
        BnsStartAutoCombat()
    }