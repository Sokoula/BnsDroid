#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global SkillAsyncLock := 0
global CommonTimeout:=0


;@Discard

;================================================================================================================
;    Skills
;================================================================================================================
BnsDroidSkill_commonPrepare() {
    ;shift + E 使用 星
    Send +{e}
    sleep 100
    ;"`" 使用 星, "`" backtick 需要特殊寫法
    Send {``}    
    sleep 100
}



BnsDroidSkill_ProtectInFighting(role) {
;role: 0:disable 1:blademaster 2:kungfufighter 3:forcemaster 4:summoner 5:assassin 6:destoryer 7:swordmaster 8:warlock 9:soulfighter 10:shooter 11:warrior 12:archer 13:thunderer 14:dualblader
;職業: 0:不限定    1:劍 2:拳 3:氣 4:召 5:刺 6:力 7:燐劍 8:咒 9:乾坤 10:槍 11:鬥 12:弓 13:天道 14:雙劍
    
    switch role
    {
        case "0":    ;不使用


        case "1":    ;劍士
            loop, 3 {
                Send c
                sleep 100
            }

        case "2":    ;拳士
            loop, 20 {
                DumpLogD("press e to protect")
                Send e
                sleep 30
            }


        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
        case "10":
        case "11":
        case "12":
        case "13":
        case "14":
    }
}


BnsDroidSkill_ProtectBeforeFighting(role) {
    switch role
    {
        case "0":    ;不使用

        case "1":    ;劍士
            Send 1
            sleep 200
            Send f
            sleep 200

        case "2":    ;拳士
            Send c
            sleep 200

        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
        case "10":
        case "11":
        case "12":
        case "13":
        case "14":
    }
}


;-----------------------------------------------------------------------------
WAIT_SKILL_CD_DONE_THREAD() {
    ShowTipI("[WAIT_SKILL_CD_DONE_THREAD] timer wake up!" )
    global SkillAsyncLock := 0
    return
}




;================================================================================================================
;    Common
;================================================================================================================
BnsDroidAction_FaceToBoss() {
    ;左旋尋找
    loop, 10
    {
        if(BnsIsEnemyDetected() > 0) {
            return 1
        }
        
        BnsActionRotationLeftAngle(3)
    }
    
    ;沒找到，歸位
    BnsActionRotationRightAngle(60)

    ;右旋尋找(反向尋找)
    loop, 20
    {
        if(BnsIsEnemyDetected() > 0) {
            return 1
        }
        
        BnsActionRotationRightAngle(3)
    }

    return 0
}


;----------------------------------------------------------------------------
;    BnsDungeonLeave - 使用龍脈離開副本
;----------------------------------------------------------------------------
BnsDungeonLeave(dist) {
    ;dist:=BsnLookingExit()    ;TODO 由BsnLookingExitDistance算出距離再用在這裡取代 dist的參數

    if(dist > 0) {
        BnsActionWalk(dist)

        sleep 200
        loop, 4 {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 130, "res\pic_dungeon_option") == 1) {
                DumpLogD("[BnsDungeonLeave] found dungeon exit")
                
                ;接收任務獎勵
                Send f
                sleep 1000

                Send y
                sleep 200

                Send f
                sleep 2000

                Send f
                sleep 2000
                
                ;點龍脈離開
                Send f
                sleep 3000

                if(BnsWaitMapLoadDone() == 1) {
                    return 1
                }
                else {
                    return 0
                }
            }
            else {
                DumpLogD("[BnsDungeonLeave] not found exit button, move ahead and retry")
                BnsActionWalk(200)
            }
        }
        ;4次都找不到龍脈圖示
        return 0
    }
    else {
        DumpLogD("[BnsDungeonLeave] found dungeon exit")
        return 0 
    }
}

;----------------------------------------------------------------------------
;    BnsDungeonLeave - 尋找離開龍脈
;----------------------------------------------------------------------------
BsnLookingExit() {
    if(BsnLookingExitDirection() == 1) {
        return BsnLookingExitDistance()
    }
    
    return 0
}

BsnLookingExitDirection() {
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 7)
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 8)
    eY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 1)
    
    missRetry:=0
    
    BnsActionRotationRightAngle(15)

    loop, 40 {
        if(FindPixelRGB(sX, sY, eX, eY, 0x00EDF4, 0x30) == 1) {
            DumpLogD("[BsnLookingExit] detect exit, x:" findX ", y:" findY)

            if(findX > WIN_CENTER_X + 10) {
                if((findX - WIN_CENTER_X) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationRightAngle(8)
                }
                else {
                    ;BnsActionRotationRightAngle(1)
                    BnsActionRotationRightPixel(1, 1)
                }
            }
            else if(findX < WIN_CENTER_X - 10) {
                if((WIN_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationLeftAngle(8)
                }
                else {
                    ;BnsActionRotationLeftAngle(1)
                    BnsActionRotationLeftPixel(1, 1)
                }
            }
            else {
                return 1
            }
        }
        else {
            if(missRetry < 3) {
                missRetry++
                DumpLogD("[BsnLookingExit] not found pattern, retry " missRetry)
            }
            else {
                missRetry:=0
                BnsActionRotationLeftAngle(35)
            }
            sleep 60
        }

        sleep 60
        ;ShowTip("↖", findX, findY)            
    }

    return 0
}

BsnLookingExitDistance() {
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 0.5)
    sY:= WIN_BLOCK_HEIGHT * 0.5
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 0.5)
    eY:= WIN_BLOCK_HEIGHT * 5

    ;拉到垂直視角
    BnsActionAdjustCamara(-50, 0)
    sleep 200
    
    ;調整俯角計算距離
    loop {
        MouseMoveR(0, -10)
        sleep 30
        
        if(FindPixelRGB(sX, sY, eX, eY, 0x00EDF4, 0x30) == 1) {
            ;以直線踓離計算，龍脈為0%，場中為100%

            if(A_index <= 10) {
                ;5%, 直接在畫面中
                dist := A_index * 90
            }
            else if(A_index <= 15) {
                ;10%
                dist := A_index * 110
            }
            else if(A_index <= 20) {
                ;20%
                dist := A_index * 40
            }
            else if(A_index <= 25) {
                ;30%
                dist := A_index * 80
            }
            else if(A_index <= 28) {
                ;50%
                dist := A_index * 105
            }
            else if(A_index <= 31 ) {
                ;70%
                dist := A_index * 135
            }
            else if(A_index <= 33 ) {
                ;100%
                dist := A_index * 165
            }
            else {
                ;over 100%, 踓離過遠，需要二次定位
                dist := A_index* 200
            }

            DumpLogD("[BsnLookingExit] targeted distance " A_index " : " dist)
            return dist
        }
    }
    
}


BsnLookingExitX() {
    sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
    sY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 7)
    eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 8)
    eY:= WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 1)
    
    missRetry:=0
    
    BnsActionRotationRightAngle(15)

    loop, 40 {
        if(FindPixelRGB(sX, sY, eX, eY, 0x00EDF4, 0x30) == 1) {
            DumpLogD("[BsnLookingExit] detect exit, x:" findX ", y:" findY)

            if(findX > WIN_CENTER_X + 10) {
                if((findX - WIN_CENTER_X) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationRightAngle(8)
                }
                else {
                    ;BnsActionRotationRightAngle(1)
                    BnsActionRotationRightPixel(1, 1)
                }
            }
            else if(findX < WIN_CENTER_X - 10) {
                if((WIN_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
                    BnsActionRotationLeftAngle(8)
                }
                else {
                    ;BnsActionRotationLeftAngle(1)
                    BnsActionRotationLeftPixel(1, 1)
                }
            }
            else {
                ;TODO:將Y軸偏差轉換為移動秒數，待研究

                ;龍脈距離較近
                if(WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 2) < findY) {
                    ret:=1
                }

                ;龍脈距離較遠
                if(WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 2) > findY) {
                    ret:=2
                }

                
                ShowTipD("[BsnLookingExit] targeted distance " ret)
                return ret
            }
        }
        else {
            if(missRetry < 3) {
                missRetry++
                DumpLogD("[BsnLookingExit] not found pattern, retry " missRetry)
            }
            else {
                missRetry:=0
                BnsActionRotationLeftAngle(35)
            }
            sleep 60
        }

        sleep 60
        ;ShowTip("↖", findX, findY)            
    }

    return 0
}

;----------------------------------------------------------------------------
;    RewardBox - 立即脫離副本(回地表)
;----------------------------------------------------------------------------
BnsDungeonRetreat() {
    if(BnsGoCharacterHall() == 1) {
        sleep 1000
        Send, {ENTER}
        sleep 2000

        ret:=BnsWaitMapLoadDone()
        
        sleep 1000
        BnsActionWalk(200)
        
        return ret
    }
}

;----------------------------------------------------------------------------
;    RewardBox - 尋找王掉獎勵箱
;----------------------------------------------------------------------------
LookingRewardBox() {
    loop, 2
    {
        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_pick_box") == 0) {
            BnsActionWalk(200)
        }
        else {
            return 1
        }

        loop, 3
        {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_pick_box") == 0) {
                BnsActionRotationLeftAngle(1)
            }
            else {
                return 1
            }
        }
        
        BnsActionRotationRightAngle(3)
        
        loop, 3
        {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_pick_box") == 0) {
                BnsActionRotationRightAngle(1)
            }
            else {
                return 1
            }
        }
    }
    
    return 0
}


;----------------------------------------------------------------------------
;    RewardBox - 撿取獎勵
;----------------------------------------------------------------------------
PickItems(filelist) {
    ShowTipI("●[System] - pick item:" filelist)
    
    loop, 3
    {
        Loop, %filelist%*.png                ;列出工作目錄下所有 file[n].png
        {
            ;loop 篩出來的只有檔名，所以先分離輸入list帶的路徑，並補上
            SplitPath, fileList,,dir
            file = %dir%\%A_LoopFileName%

            if(FindPic(0, 0, WIN_WIDTH, WIN_HEIGHT, 100, file) == 1) {
                ShowTipI("●[System] - pick item:" file)

                Send {Alt down}
                sleep 200
                
                MouseMove findX + 20, findY + 20
                sleep 200

                click, right
                sleep 200
                
                Send {Alt up}
                sleep 200
                
                Send {y}    ;某些東西會詢問
                sleep 200

            }
        }
    }
    
    Send {s Down}
    sleep 50
    Send {s Up}
    sleep 2000
}


;----------------------------------------------------------------------------
;    SecretMerchant - 尋找神秘商人
;----------------------------------------------------------------------------
LookingSecretMerchant() {
    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 5)
    
    if(FindPixelRGB(sX, sY, sX + WIN_BLOCK_WIDTH * 16, sY + WIN_BLOCK_HEIGHT + WIN_BLOCK_HEIGHT * 5, 0x45be58, 0x10) == 1) {
        ShowTipI("●[System] - found Secret Merchant!!")
        return 1
    }
    
    ShowTipI("●[System] - not found Secret Merchant")
    return 0
}

;----------------------------------------------------------------------------
;    SecretMerchant - 開啟神秘商店
;----------------------------------------------------------------------------
VisitSecretStore() {
    sX := WIN_CENTER_X - (WIN_BLOCK_WIDTH * 10)
    sY := WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 7)

    loop, 20
    {
        if(FindPixelRGB(sX, sY, sX + WIN_BLOCK_WIDTH * 20, sY + WIN_BLOCK_HEIGHT * 8, 0x45be58, 0x10) == 1) {
            
            ShowTipD("[VisitSecretStore] find x:" findX)
            
            if(findX > WIN_CENTER_X + 5) {    ;目標在右邊
                if((findX - WIN_CENTER_X) > WIN_BLOCK_WIDTH) {
                    DumpLogD("[VisitSecretStore] turn right angle 8")
                    BnsActionRotationRightAngle(8)    ;差太遠，大幅轉動
                }
                else {
                    DumpLogD("[VisitSecretStore] turn right angle 1")
                    ;BnsActionRotationRightAngle(1)    ;進入範圍，微調轉動
                    BnsActionRotationRightPixel(1, 1)    ;進入範圍，微調轉動
                }
            }
            else if(findX < WIN_CENTER_X - 5) { ;目標在左邊
                if((WIN_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
                    DumpLogD("[VisitSecretStore] turn left angle 8")
                    BnsActionRotationLeftAngle(8)
                }
                else {
                    DumpLogD("[VisitSecretStore] turn left angle 1")
                    ;BnsActionRotationRightAngle(1)
                    BnsActionRotationRightPixel(1, 1)
                }
            }
            else {
                DumpLogD("[VisitSecretStore] targeted")
                break
            }
        }

        sleep 20
    }

    BnsActionWalk(4000)

    loop, 2 {
        loop, 3 {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_secret_visit") == 0) {
                BnsActionRotationRightAngle(1)
            }
            else {
                Send f
                sleep 1000

                return 1
            }
        }
        
        BnsActionRotationLeftAngle(3)
        
        loop, 3 {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_secret_visit") == 0) {
                BnsActionRotationLeftAngle(1)
            }
            else {
                Send f
                sleep 1000

                return 1
            }
        }
        
        BnsActionRotationRightAngle(3)
        sleep 200
        
        BnsActionWalk(500)
    }

    return 0
}

;----------------------------------------------------------------------------
;    SecretMerchant - 購買神秘商品
;----------------------------------------------------------------------------
BuyItem(filelist) {
    Loop, %filelist%*.png                ;列出工作目錄下所有 file[n].png
    {
        ;loop 篩出來的只有檔名，所以先分離輸入list帶的路徑，並補上
        SplitPath, fileList,,dir
        file = %dir%\%A_LoopFileName%

        if(FindPic(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, file) == 1) {
            ShowTipI("●[System] - buy item:" file)

            Send {Alt down}
            sleep 200
            
            MouseMove findX + 20, findY + 20
            sleep 200

            click, right
            sleep 200
            
            Send y
            sleep 200
            
            Send {Alt up}
            sleep 200
        }
    }

    Send {Esc}
    sleep 200
}



