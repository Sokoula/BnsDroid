#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include common.ahk


;enemy region = sx, sy, width, height
global ENEMY_BOSS_LEVEL_REGION := 750,100,50,30
global ENEMY_ZAKO_LEVEL_REGION := 780,100,50,30

;blood region = sx, sy, width, height
global STAMINA_INDICATOR_REGION := 1300,1000,268,14

;party form region = sx, sy, width, height
global PARTY_FORM_HEADER_TAB_REGION := 1520,160,370,620

;character list region = sx, sy, width, height, pageX1, pageX2
global CHARATER_LIST_REGION := 1570,380,320,490

;position = cx , cy
global CHARACTER_ARROW_POSITION := 1770,150

;hight speed role = 1
global HIGH_SPEED_ROLE := 0

;role type = 0
global ROLE_TYPE := 0


;character profiles (array list: {[index, role type, hight speed], ...)
global CHARACTER_PROFILES := []
global PROFILES_ITERATOR := 0




;Role enum
;role: 1:blademaster 2:kungfufighter 3:forcemaster 4:summoner 5:assassin 6:destoryer 7:swordmaster
;      8:warlock 9:soulfighter 10:shooter 11:warrior 12:archer 13:thunderer 14:dualblader
global ROLE_UNSPECIFIED     := 0    ;未指定
global ROLE_BLADEMASTER     := 1    ;劍士
global ROLE_KUNGFUFIGHTER   := 2    ;拳士
global ROLE_FORCEMASTER     := 3    ;氣功
global ROLE_SUMMONER        := 4    ;召喚
global ROLE_ASSASSIN        := 5    ;刺客
global ROLE_DESTORYER       := 6    ;力士
global ROLE_SWORDMASTER     := 7    ;燐劍
global ROLE_WARLOCK         := 8    ;咒術
global ROLE_SOULFIGHTER     := 9    ;乾坤
global ROLE_SHOOTER         := 10   ;槍手
global ROLE_WARRIOR         := 11   ;鬥士
global ROLE_ARCHER          := 12   ;弓手
global ROLE_THUNDERER       := 13   ;天道
global ROLE_DUALBLADER      := 14   ;雙劍
global ROLE_MUSICIAN        := 15   ;樂師




;================================================================================================================
;    ACTION - Move
;================================================================================================================
;Move to position;  [ x ] 目的座標X;  [ y ] 目的座標Y;  [ sprint ] 0:走路, 1:輕功;  [ linked ] 0: 不串接, 1~: 串接前後操作;  [ timeout ] ms;  [ accuracy ] 容許誤差(距離)
BnsActionMoveToPosition(tx ,ty, sprint, linked := 0, timeout := 0, accuracy := 10) {
    ; linked:
    ;       0x00 - no linked.
    ;       0x01 - linked head.
    ;       0x02 - linked body.
    ;       0x04 - linked tail.
    ;       0x08 - use sprint.
    
    ret := 0

    ;已在目的地, 無需移動
    dist := BnsMeansureTargetDistDegree(tx, ty)[1]
    if( dist <= 50 ) {
        return 1
    }


    sTick := A_TickCount
    
    if(linked == 0 || linked & 0x01 != 0) {
        ; ControlSend,,{w Down}, %res_game_window_title%
        PostMessage, 0x100, 0x57, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN
        ; SendMessage, 0x100, 0x57, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN

        if(sprint == 1) {
            ; ControlSend,,{shift}, %res_game_window_title%

            ; //TBD: PostMessage 無法正確發送 Shift, 待解
            ; PostMessage, 0x100, 0x57, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN w
            PostMessage, 0x100, 0xA0, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN L-shift 0xA0 (shift 0x10 左右都是，但無效)
            PostMessage, 0x101, 0xA0, 0, , %res_game_window_title%  ;0x101: WM_KEYDOWN L-shift 0xA0
        }
    }


    loop {
        if(timeout != 0 && A_TickCount - sTick >= timeout) {
            break
        }

        targetInfo := BnsMeansureTargetDistDegree(tx, ty)
        dist := targetInfo[1]
        degree := targetInfo[2]

        if(dist <= accuracy) {
            ret := 1
            break
        }

        BnsActionAdjustDirection(degree)

        ;劍靈不加跑速0的條件下, 移動座標1單位花費4ms
        ; time := dist * 4.06

        ; msleep(30)
    }
    
    
    if(linked == 0 || linked & 0x04 != 0) {
        ; ControlSend,,{w Up}, %res_game_window_title%
        PostMessage, 0x101, 0x57, 0, , %res_game_window_title%  ;0x101: WM_KEYUP
        ; SendMessage, 0x101, 0x57, 0, , %res_game_window_title%  ;0x101: WM_KEYUP
        ;sleep 200
    }

    return ret
}


;================================================================================================================
;    ACTION - Walk
;================================================================================================================
BnsActionWalk(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.915
    }

    Send, {w Down}
    msleep(ms)
    Send, {w Up}
}

;Walk to position;  [ x ] 目的座標X;  [ y ] 目的座標Y;  [ linked ] 0: 不串接, 1~: 串接前後操作;  [ timeout ] ms;  [ accuracy ] 容許誤差(距離)
BnsActionWalkToPosition(tx ,ty, linked := 0, timeout := 0, accuracy := 10) {
    return BnsActionMoveToPosition(tx, ty, 0, linked, timeout, accuracy)
}


;================================================================================================================
;    ACTION - Run
;================================================================================================================
BnsActionSprint(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.915
    }

    Send, {w Down}
    sleep 200
    Send {Shift Down}
    sleep 100
    Send {Shift Up}
    msleep(ms)
    Send, {w Up}
}


;Sprint to position;  [ x ] 目的座標X;  [ y ] 目的座標Y;  [ linked ] 0: 不串接, 1~: 串接前後操作;  [ timeout ] ms;  [ accuracy ] 容許誤差(距離)
BnsActionSprintToPosition(tx ,ty, linked := 0, timeout := 0, accuracy := 10) {
    return BnsActionMoveToPosition(tx, ty, 1, linked, timeout, accuracy)
}


BnsActionCornerSprintUpLeft(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    Send, {w Down}
    Send, {a Down}
    Send, {shift}
    msleep(ms)
    Send, {a Up}
    Send, {w Up}
}



BnsActionCornerSprintUpRight(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    Send, {w Down}
    Send, {d Down}
    Send, {shift}
    msleep(ms)
    Send, {d Up}
    Send, {w Up}
}



;================================================================================================================
;    ACTION - Lateral walk
;================================================================================================================
BnsActionLateralWalkLeft(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    ControlSend,,{a Down}, %res_game_window_title%
    msleep(ms)
    ControlSend,,{a Up}, %res_game_window_title%
}


BnsActionLateralWalkRight(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    ControlSend,,{d Down}, %res_game_window_title%
    msleep(ms)
    ControlSend,,{d Up}, %res_game_window_title%
}



;================================================================================================================
;    ACTION - Corner walk
;================================================================================================================
BnsActionCornerWalkUpLeft(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    Send, {w Down}
    Send, {a Down}
    msleep(ms)
    Send, {a Up}
    Send, {w Up}
}



BnsActionCornerWalkUpRight(ms) {
    if(HIGH_SPEED_ROLE == 1) {
        ms := ms * 0.92
    }

    Send, {w Down}
    Send, {d Down}
    msleep(ms)
    Send, {d Up}
    Send, {w Up}
}


;以面向目標為中心繞圈移動; [ ox ] 目標 X 座標;  [ oy ] 目標 Y 座標;  [ deltaDegree ] 相對移動角度, 正數: 逆時針, 負數: 順時針;
BnsActionWalkCircle(ox, oy, deltaDegree) {
    targetInfo := BnsMeansureTargetDistDegree(ox, oy) ;以圓心計算方向
    startDegree := targetInfo[2]    ;這邊是面向目標的方向角

    goalDegree := mod(startDegree + deltaDegree + 360, 360)   

    if(deltaDegree >= 0) {
        goalDegree := (goalDegree == startDegree) ? mod(goalDegree - 1 + 360, 360) : goalDegree
        ControlSend,,{d Down}, %res_game_window_title%  ;順時針(向右)    
    }
    else {
        goalDegree := (goalDegree == startDegree) ? mod(goalDegree + 1 + 360, 360) : goalDegree
        ControlSend,,{a Down}, %res_game_window_title%  ;逆時針(向左)
    }
    if(DBUG >= 1) {
        ShowTipD("s: " startDegree ", g: " goalDegree)
    }

    sleep 100   ;起步偏離一點再開始計算, 以免開始就結束，偷懶的邏輯


    loop {
        targetInfo := BnsMeansureTargetDistDegree(ox, oy)
        curtDegree := targetInfo[2]
        BnsActionAdjustDirection(curtDegree)    ;移動中調整面向圓心, 以做繞圓移動
        
        if(DBUG >= 1) {
            ShowTipD("s: " startDegree ", g: " floor(goalDegree) ", c: " floor(curtDegree))
        }

        if(floor(curtDegree) == floor(goalDegree)) {
            break
        }

        sleep -1
    }
    
    if(deltaDegree >= 0) {
        ControlSend,,{d Up}, %res_game_window_title%
    }
    else {
        ControlSend,,{a Up}, %res_game_window_title%
    }
}




;================================================================================================================
;    ACTION - Sprint jump
;================================================================================================================
BnsActionSprintJump(ms := 500) {
    ; if(HIGH_SPEED_ROLE == 1) {
    ;     ms := ms * 0.92
    ; }

    ;輕功跳
    Send, {w Down}
    Send, {Shift}
    dsleep(200)    ;必需 > 200ms, 不然跳不起來
    Send, {Space Down}    ;Space 必需拆開寫，不然沒作用
    dsleep(30)
    Send, {Space Up}
    dsleep(ms)
    Send, {w Up}
}


;================================================================================================================
;    ACTION - Sprint Gliding
;================================================================================================================
;Gliding;  [ ms ] time for Gliding;  [ sprint ] 0:off, 1:on;  [ linked ] 0: 不串接, 1~: 串接前後操作;
BnsActionGliding(ms, sprint := 0, linked := 0) {

    if(linked == 0 || linked & 0x01 != 0) {
        BnsActionSprintJump(600)
        PostMessage, 0x100, 0x20, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN Space
        sleep 30
        PostMessage, 0x101, 0x20, 0, , %res_game_window_title%  ;0x101: WM_KEYUP Space
    }

    if(sprint == 1) {
        PostMessage, 0x100, 0x57, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN w
        PostMessage, 0x100, 0xA0, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN L-shift 0xA0 (shift 0x10 左右都是，但無效)
        PostMessage, 0x101, 0xA0, 0, , %res_game_window_title%  ;0x101: WM_KEYUP L-shift 0xA0
    }

    sleep %ms%

    if(sprint == 1) {
        PostMessage, 0x101, 0x57, 0, , %res_game_window_title%  ;0x100: WM_KEYUP w
    }

    if(linked == 0 || linked & 0x04 != 0) {
        PostMessage, 0x100, 0x20, 0, , %res_game_window_title%  ;0x100: WM_KEYDOWN Space
        sleep 50
        PostMessage, 0x101, 0x20, 0, , %res_game_window_title%  ;0x101: WM_KEYUP Space
        sleep 1000  ;wait for next action
    }
}


;================================================================================================================
;    ACTION - Confuse Move
;================================================================================================================
BnsActionRandomConfuseMove(ms) {
    ;跑速0的移動比率
    ;輕功:走路:倒退 = 0.5:1:2.5

    if(ms <= 1) {
        return
    }

    Random, rand, 1, 10
    DumpLogD("[BnsActionRandomConfuseMove] rand=" rand)
    
    switch Mod(rand, 3)
    {
        case 0:
            BnsActionSprint(ms * 0.5)    ;輕功跑進傳點
        
        case 1:
            BnsActionWalk(ms)            ;走進傳點
            
        case 2:
            BnsActionSprintJump(ms * 0.5)    ;輕功跳進傳點
    }

}




;================================================================================================================
;    ACTION - Meansure point properties
;================================================================================================================
;取得目前與指定座標的距離 [ tx ] 目的 x 座標 double;  [ ty ] 目的 y 座標 double;  [ ox ] 指定原點 x 座標;  [ oy ] 指定原點 y 座標;  [ return ] array(distance, degree)
BnsMeansureTargetDistDegree(tx ,ty, ox := 0, oy := 0) {
    ox := (ox == 0) ? GetMemoryHack().getPosX() : ox
    oy := (oy == 0) ? GetMemoryHack().getPosY() : oy

    dx := tx - ox
    dy := ty - oy
    
    if(DBUG >= 2) {
        ShowTipD("ox: " ox ", oy: " oy ", tx: " tx ", ty: " ty)
    }

    ;坐標兩點距離公式: dst = ((ox-tx)^2 + (oy-ty)^2)^1/2
    distance := sqrt(dx**2 + dy**2)
    
    ;計算目標座標方向角: 先計算目標點與X軸的夾角，再依正負座標值補償象限
    theta := abs(asin(dy / distance)) / 3.1415926535 * 180
    degree := (dx < 0 && dy < 0) ? theta + 180 : (dx < 0) ? 180 - theta : (dy < 0) ? 360 - theta : theta
    
    if(DBUG >= 2) {
        ShowTipD("dx: " dx ", dy: " dy ", theta: " theta ", degree: " degree ", dist:" distance)
    }

    property := Array()
    property.push(distance)
    property.push(degree)

    return property
}



;================================================================================================================
;    ACTION - Rotation Related by pixel
;================================================================================================================
BnsActionRotationDuring(pxX, times) {

    if(DBG == 1) {
        ShowTipD("[BnsActionRotationDuring]" scrWidth "," scrHeight)
    }

    ;滑鼠回到正中間    
    Send {Alt down}
    sleep 100

    MouseMove WIN_CENTER_X, WIN_CENTER_Y
    sleep 20

    Send {Alt up}
    sleep 100
    
    ;橫移滑鼠轉向 負值:向左旋 正:向右旋
    loop %times% {
        MouseMoveR(pxX, 0)
        dsleep(20)
    }

    ;滑鼠偏移補正
    ;if( pxX > 0) {
    ;    Send, {Right Down}
    ;    sleep 10
    ;    Send, {Right Up}
    ;}
    ;else {
    ;    Send, {Left Down}
    ;    sleep 10
    ;    Send, {Left Up}
    ;
    ;}
}


;向右轉每次 1度角(非精準)
BnsActionRotationRightAngle(times) {
    BnsActionRotationDuring(2.755, times)
}

;向左轉每次 1度角(非精準)
BnsActionRotationLeftAngle(times) {
    BnsActionRotationDuring(-2.755, times)
}

;向右轉每次 1 pixel
BnsActionRotationRightPixel(px,times) {
    BnsActionRotationDuring(px, times)
}

;向左轉每次 1 pixel
BnsActionRotationLeftPixel(px, times) {
    BnsActionRotationDuring(-1 * px, times)
}



;================================================================================================================
;    ACTION - Rotation Related by Memory degree
;================================================================================================================
BnsActionRotationRelated(degree := 0) {
    ;劍靈座標系是向右旋轉(直角座標系是向左旋轉)

    if(isObject(GetMemoryHack())) {
        curtCamAzimuth := GetMemoryHack().getCamAzimuth()
        
        ; convertDegree := 360 - targetDegree + 90
        relatedCamAzimuth := curtCamAzimuth + degree

        GetMemoryHack().setCamAzimuth(relatedCamAzimuth)
    }
}


;向右轉90
BnsActionRotationDegree90() {
    ; BnsActionRotationDuring(-2.755 * 90, 1)
    BnsActionRotationRelated(90)
}

;向後轉
BnsActionRotationDegree180() {
    ; BnsActionRotationDuring(-2.755 * 180, 1)
    BnsActionRotationRelated(180)
}

;轉右向270(左轉90)
BnsActionRotationDegree270() {
    ; BnsActionRotationDuring(-2.755 * 270, 1)
    BnsActionRotationRelated(270)
}


;================================================================================================================
;    ACTION - Adjust direction(azimuth)
;================================================================================================================
;設定遊戲引擎方位角(遊戲memory hack使用值);  [ targetDegree ] 角度(float);
BnsActionAdjustEngineDirection(targetDegree) {
    BnsActionAdjustDirection(targetDegree, 1)
}


;設定方位角;  [ targetDegree ] 角度(float);  [ mode ] 0:直角座標, 1:UE座標
BnsActionAdjustDirection(targetDegree, mode := 0) {
    ;            90         (直角坐標系)                          0            (劍靈坐標系)
    ;            |                                                |
    ;      二    |     一                                   四    |     一
    ;            |                    座標/象限轉換               |
    ; 180 -------+------- 0         <----------->      270 -------+------- 90
    ;            |  *小地圖上為正北方                             |  *小地圖上為正北方 
    ;      三    |     四                                   三    |     二
    ;            |                                                |
    ;          270                                               180

    if(isObject(GetMemoryHack())) {
        degree := (mode == 0) ? 360 - targetDegree + 90 : targetDegree
        GetMemoryHack().setCamAzimuth(degree)
    }
    else {
        BnsActionAdjustDirectionOnMap(targetDegree)
    }
}


BnsActionAdjustDirectionOnMap(targetDegree) {
        DBG:=0
        arrow := StrSplit(CHARACTER_ARROW_POSITION, ",", "`r`n")
        block:=0

        if(DBG >= 1) {
            DumpLogD("first round degrade search")
        }

        if(DBG == 2) {
            send {alt down}
            sleep 200
            MouseMove arrow[1], arrow[2]
            sleep 3000
            send {alt up}
            sleep 200
        }

        ;第一次降維篩選, 找出大概方向 gray 值217~219 (360度圓切12區分), 從0度開始找出第一次掃到箭頭本體的區塊
        loop 12 {
            r:=6
            px := arrow[1] + r * cos(A_index * 30 * 3.1415926535 / 180)
            py := arrow[2] - r * sin(A_index * 30 * 3.1415926535 / 180)

            colorRaw := GetPixelColor(px, py)
            gray := GetColorGray(colorRaw)
            blue := GetColorBlue(colorRaw)

            if(DBG >= 1) {
                DumpLogD("d:"A_index ", px:" px ", py:" py ", color:" pixelColor ", gray:" gray)
            }

            if(DBG == 2) {
                send {alt down}
                sleep 200
                MouseMove px, py
                sleep 3000
                send {alt up}
                sleep 200
            }
            
            if(gray >= 200 && blue >= 220) {
                DumpLogD("block:" A_index ", px:" px ", py:" py ", color:" pixelColor ", gray:" gray ", blue:" blue)
                block:=A_index
                break
            }
        }

        if(DBG >= 1) {
            DumpLogD("second round search")
        }
        
        prevGray:=0
        leftEdge:=0
        rightEdge:=0
        
        ;區域尋邊, 找出箭頭邊緣
        sDegree := block * 30 - 45
        
        r:=11
        loop 60 {
            px := arrow[1] + r * cos((sDegree + A_index * 2) * 3.1415926535 / 180)
            py := arrow[2] - r * sin((sDegree + A_index * 2) * 3.1415926535 / 180)

            colorRaw := GetPixelColor(px, py)
            gray := GetColorGray(colorRaw)
            blue := GetColorBlue(colorRaw)

            if(DBG >= 1) {
                DumpLogD("degree:" sDegree + A_index * 2 ", px:" px ", py:" py ", color:" pixelColor ", gray:" gray ", blue:" blue)
            }
            
            if(gray >= 210 && blue >= 220 && leftEdge == 0) {
                leftEdge := sDegree + (A_index - 1) * 2

                if(DBG == 2) {
                    send {alt down}
                    sleep 200
                    MouseMove px, py
                    sleep 3000
                    send {alt up}
                    sleep 200
                }
            }

            if(rightEdge == 0 && leftEdge != 0 && gray < 210) {
                rightEdge := sDegree + (A_index - 1) * 2
                
                if(DBG == 2) {
                    send {alt down}
                    sleep 200
                    MouseMove px, py
                    sleep 3000
                    send {alt up}
                    sleep 200
                }
            }
        }
        
        arrow := Abs(Mod((rightEdge + leftEdge) / 2 + 180, 360))

        if(DBG >= 1) {
            DumpLogD("start edge engle:" leftEdge ", end edge engle:" rightEdge ", arrow:" arrow)
        }

        offsetDegree := arrow - targetDegree
        
        if(offsetDegree > 180) {
            offsetDegree := offsetDegree - 360
        }

        DumpLogD("adjuest direction, rotate:" offsetDegree)
        
        BnsActionRotationDuring(2.755 * offsetDegree, 1)
}

;================================================================================================================
;    ACTION - Adjuset camara angle
;================================================================================================================
BnsActionAdjustCamaraAltitude(altitude) {
    GetMemoryHack().setCamAltitude(altitude)
}

;@Discard
BnsActionAdjustCamara(pxY, times) {

    DumpLogD("[BnsActionAdjustCamara] pxY:" pxY ", times:" times)

    ;視距規正
    BnsActionAdjustCamaraZoom(27)

    ;視距規正
    ;Send {Wheelup 50}
    ;sleep 1000
    ;Send {Wheeldown 30}
    ;sleep 1000

    sleep 500

    ;拉到固定俯角
    BnsActionAdjustCamaraAngle(pxY, times)
    
    sleep 200
}

;調整縮放(滾輪向下)
BnsActionAdjustCamaraZoom(zoom) {
    ;滑鼠回到正中間    
    Send {Alt down}
    sleep 200

    MouseMove WIN_CENTER_X, WIN_CENTER_Y
    sleep 200

    Send {Alt up}
    sleep 200


    MouseWheel( 1, 40)
    sleep 100
    MouseWheel(-1, zoom)

}

;調整俯角
BnsActionAdjustCamaraAngle(pxY, times) {
    ;滑鼠回到正中間    
    Send {Alt down}
    sleep 200

    MouseMove WIN_CENTER_X, WIN_CENTER_Y
    sleep 200

    Send {Alt up}
    sleep 200

    ;滑鼠向下移動拉到垂直視角，規0校正
    loop, 10 {
        MouseMoveR(0, 100)
        dsleep(48)
    }

    sleep 200
    
    loop %times% {
        MouseMoveR(0, pxY)
        dsleep(48)
    }
}


;================================================================================================================
;    ACTION - Available talk type
;================================================================================================================
;Get talk type; [ return ] 0:none, 18:對話, 20:祈禱/採集/蒐集/記錄祕境, 23:搭龍脈, 40:修理, 61:觸發
BnsIsAvailableTalk() {
    return GetMemoryHack().isAvailableTalk()
}


;================================================================================================================
;    ACTION - Auto combat
;================================================================================================================
BnsStartStopAutoCombat() {
    Send, <+{F4}    
}

BnsStartAutoCombat() {
    if(GetMemoryHack().getAutoCombatState() == 0) {
        DumpLogD("●[System] - AutoCombat Start")
        BnsStartStopAutoCombat()
        sleep 200
    }
}

BnsStopAutoCombat() {
    if(GetMemoryHack().getAutoCombatState() != 0) {
        DumpLogD("●[System] - AutoCombat Stop")
        BnsStartStopAutoCombat()
        sleep 200
    }
}



;================================================================================================================
;    ACTION - Speed Hack
;================================================================================================================
BnsStartHackSpeed() {
    if(GetMemoryHack().getSpeed() == 1) {
        Send, {NumpadMult Down}
        sleep 100
        Send, {NumpadMult Up}

        ;plugin 失效時
        if(GetMemoryHack().getSpeed() == 1) {
            GetMemoryHack().setSpeed(4)
        }

        DumpLogD("●[System] - CE Start")
    }
}

BnsStopHackSpeed() {
    if(GetMemoryHack().getSpeed() != 1) {
        Send, {NumpadMult Down}
        sleep 100
        Send, {NumpadMult Up}

        ;plugin 失效時
        if(GetMemoryHack().getSpeed() == 4) {
            GetMemoryHack().setSpeed(1)
        }


        DumpLogD("●[System] - CE Stop")
    }
}


;================================================================================================================
;    ACTION - Resurrection
;================================================================================================================
;復活
BnsActionResurrection() {
    BnsStopAutoCombat()
    loop 3 {
        ControlSend,,{4}, %res_game_window_title%
        sleep 100
    }
}

;================================================================================================================
;    ACTION - Fix Weapon
;================================================================================================================
;修理武器
BnsActionFixWeapon() {
    ShowTipD("[BnsActionFixWeapon] check weapon")

    if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 80, "res\pic_backpack") == 0) {
        ShowTipD("[BnsActionFixWeapon] no detect backpack window, open backpack")
        Send {i}
        sleep 2000
    }

    if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 100, "res\pic_backpack") == 1) {
        ShowTipD("[BnsActionFixWeapon] backpack window found")
        
        if(FindPixelRGB(findX - 30, findY, findX + 30, findY + 200, 0x4AB6FF, 0) == 0) {
            ShowTipD("[BnsActionFixWeapon] detect weapon need to be fixed")
            send {5}    ;TODO: set your key
            sleep 5200

            if(FindPixelRGB(findX - 30, findY, findX + 30, findY + 200, 0x42B1FF, 0) == 1) {
                ShowTipD("[BnsActionFixWeapon] weapon fixed done, close backpack")
                send {ESC}
                sleep 1000

                return 1
            }
        }
        else {
            ShowTipD("[BnsActionFixWeapon] detect weapon still fine")
        }
    }
    
    send {ESC}
    sleep 1000

    return 0
}



;================================================================================================================
;    ACTION - Back to Character Hall
;================================================================================================================
BnsGoCharacterHall() {

    ;Esc 叫系統選單
    Send {Esc}
    sleep 200
    
    if(FindPicList(WIN_THREE_QUARTERS_X, WIN_THREE_QUARTERS_Y, WIN_WIDTH, WIN_HEIGHT, 80, "res\pic_menu_select_character") == 1) {
        exitX := findX+20
        exitY := findY+5
        
        MouseMove exitX, exitY
        sleep 200
        
        click
        sleep 1000

        Send y
        sleep 1000

        if(FindPicList(WIN_CENTER_X, WIN_CENTER_Y, WIN_WIDTH, WIN_HEIGHT, 80, "res\pic_reward_button") == 1) {
            Send f
            sleep 1000

            Send f
            sleep 200

            ;重新 Esc 叫系統選單
            Send {Esc}
            sleep 200

            MouseMove exitX, exitY
            sleep 200
            
            click
            sleep 600
            
            Send y
            sleep 1000
        }

        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_btn_select_character") == 1) {
            MouseMove findX + 20, findY + 5
            sleep 500

            click, 2
            sleep 500
        }
        
        ShowTipI("●[System] - Loading...")

        loop, 300 {
            if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_btn_exit_game") == 1) {
                ShowTipI("●[System] - Loading Done...Enter to character hall")
                return 1
            }

            if(DBUG == 1) {
                ShowTipD("●[System] - Loading...")
            }
            sleep 200
        }
        
        ShowTipE("●[Exception] - Loading timeout...")
    }

    return 0
}


;================================================================================================================
;    ACTION - Select Character
;================================================================================================================
BnsSelectCharacter(index) {
    if(index < 1 || index > 14) {
        DumpLogD("[BnsSelectCharacter] Illigal index, do nothing")
        return 1
    }

    regions := StrSplit(CHARATER_LIST_REGION, ",", "`r`n")
    
    ;角色卡片9個 + 分頁標籤 0.6 個卡片高度
    cardH := regions[4] / 9.6    ;單個角色卡高度
    
    pageX1 := regions[5]
    pageX2 := regions[6]
    pageY  := regions[2] + cardH * 9.3    ;分頁標籤在第9個角色卡下方, 0.6 個角色卡高度, 取置中 0.3 的Y位值

    if(index > 9) {    
        if(DBUG == 1) {
            DumpLogD("[BnsSelectCharacter] " index " - page 2")
        }

        index := index - 9 + 4    ;目前是最大14個角色卡, 超過9的放置在第二頁的對應第5角色卡的位置開始(需隨改版調整)
        if(FindPixelRGB(pageX2 - 1, pageY - 1, pageX2 + 1, page + 1, 0x65f082, 0x08) == 0) {
            MouseClick, left, pageX2, pageY
        }
    }
    else {
        if(DBUG == 1) {
            DumpLogD("[BnsSelectCharacter] " index " - page 1")
        }

        if(FindPixelRGB(pageX1 - 1, pageY - 1, pageX1 + 1, page + 1, 0x65f082, 0x08) == 0) {
            MouseClick, left, pageX1, pageY
        }
    }

    sleep 1000

    mX := regions[1] + (regions[3] * 0.5)
    mY := regions[2] + (cardH * ((index - 1) + 0.5))
    
    MouseClick, left, mX, mY
    sleep 200
    
    MouseMove, WIN_CENTER_X, WIN_CENTER_Y
    sleep 3000
    
    Send {Enter}
    sleep 1000

    ret := BnsWaitMapLoadDone()
    
    ; Send {Esc}     ;關閉 F10 龍銀廣告
    BnsActionWalk(10)
    sleep 1000
    
    return ret
}


;================================================================================================================
;    ACTION - Teleport on map
;================================================================================================================
BnsMapTeleport(level, offsetX, offsetY) {
    loop, 3 {
        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 80, "res\pic_map") == 1) {
            MouseMove findX + offsetX, findY + offsetY
            
            ;調整地圖層級, 先調到最底再往上一層調
            MouseWheel(-1, 4)
            sleep 500
            MouseWheel( 1, level)
            sleep 1000

            MouseClick, left, findX + offsetX, findY + offsetY
            sleep 1000

            Send y
            sleep 200

            if(FindPixelRGB(WIN_BLOCK_WIDTH * 8, WIN_BLOCK_HEIGHT * 13, WIN_BLOCK_WIDTH * 10, WIN_BLOCK_HEIGHT * 14, 0x6AFF8A, 10) == 1) {
                ShowTipD("●[System] - Open map")
                
                ;領取斬首任務獎勵，如果有
                Send f
                sleep 2000

                Send f
                sleep 2000

                continue
            }

            
            sleep 5000
            if(BnsWaitMapLoadDone() == 1) {
                return 1
            }
            else {
                return 0
            }

        }
        else {
            ShowTipD("●[System] - Open map")
            Send, m
            sleep 1000
        }
    }
}



;================================================================================================================
;    STATUS - Popsition
;================================================================================================================
;取得角色座標 X(MemHack);  [ return ] float: 座標值; empty: MemHack 無效
BnsGetPosX() {
    return (GetMemoryHack().isMemHackWork() == 1) ? GetMemoryHack().getPosX() : ""
}

;取得角色座標 Y(MemHack);  [ return ] float: 座標值; empty: MemHack 無效
BnsGetPosY() {
    return (GetMemoryHack().isMemHackWork() == 1) ? GetMemoryHack().getPosY() : ""
}

;取得角色座標 Z(MemHack); [ return ] float: 座標值; empty: MemHack 無效
BnsGetPosZ() {
    return (GetMemoryHack().isMemHackWork() == 1) ? GetMemoryHack().getPosZ() : ""
}




;================================================================================================================
;    CHECK - Is party with members
;================================================================================================================
BnsIsPartyWork() {
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")

    if(partyCtrl[1] > 1) {
        return partyCtrl[1]
    }

    return 0
}


;================================================================================================================
;    CHECK - Is load map done
;================================================================================================================
BnsIsMapLoading() {
    if(WinActive(res_game_window_title)) {
        
        pColor:=GetPixelColor(10, WIN_HEIGHT - 5)

        pR:=GetColorRed(pColor)
        pG:=GetColorGreen(pColor)
        pB:=GetColorBlue(pColor)

        ;綠色經驗條
        if(Abs(pR - pB) < 0x10 && pG - pR > 0xA0) {
            return 0
        }

        ;黃色經驗條
        if(pR - pB > 0x50 && pG - pB > 0x50) {
            return 0
        }


        ; ;綠色經驗條
        ; if(FindPixelRGB(0, WIN_HEIGHT - 5, 50, WIN_HEIGHT, 0x00D500, 0x5) == 1) {
        ;     return 0
        ; }
        ; if(FindPixelRGB(0, WIN_HEIGHT - 5, 50, WIN_HEIGHT, 0x00E000, 0x5) == 1) {
        ;     return 0
        ; }

        ; ;黃色經驗條
        ; if(FindPixelRGB(0, WIN_HEIGHT - 5, 50, WIN_HEIGHT, 0xF3AB00, 0x5) == 1) {
        ;     return 0
        ; }        
        ; if(FindPixelRGB(0, WIN_HEIGHT - 5, 50, WIN_HEIGHT, 0xC38D06, 0x5) == 1) {
        ;     return 0
        ; }
    }

    return 1
}

;================================================================================================================
;    CHECK - Waitting load map done (Block API)
;================================================================================================================
BnsWaitMapLoadDone() {
    ;偵測經驗條判定是否過圖完成
    ShowTipI("●[System] - Loading...")

    loop, 300 {
        
        if(BnsIsMapLoading() == 0) {
            ShowTipI("●[System] - Loading Done...")
            return 1
        }

        if(DBUG == 1) {
            ShowTipD("●[System] - Loading...")
        }
        sleep 200
    }

    ShowTipE("●[Exception] - Loading timeout...")
    return 0
}


;================================================================================================================
;    CHECK - Check Enemy alive
;================================================================================================================
;是否偵測到敵人; [ return ] 0:失去目標(NONE); 1:紅標(BOSS); 2:藍標(MOB)
BnsIsEnemyDetected() {
    ret:=0

    if(BnsIsBossDetected() == 1) {
        ret := 1
        if(DBUG >= 2) {
            DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(BOSS)")
        }
    }
    else if(BnsIsZakoDetected() == 1) {
        ret := 2
        if(DBUG >= 2) {
            DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(MOB)")
        }
    }
    else {
        if(DBUG >= 2) {
            DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(NONE)")
        }
    }

    return ret
}


BnsIsBossDetected() {    ;主要Boss - 紅色
    ret:=0

    regions := StrSplit(ENEMY_BOSS_LEVEL_REGION, ",", "`r`n")

    sx := regions[1]
    sy := regions[2]
    width := regions[3]
    height := regions[4]

    ;ShowTipD("[System] - BnsIsBossDetected sx:" sx + width * 0.7 ", sy:" sy ", ex:"  sx + width ", ey:" sy + height)

    isCheck1 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF0F0F0, 0x08)
    isCheck2 := FindPixelRGB(sx + width * 0.7, sy, sx + width, sy + height, 0xF2DA8A, 0x10)
    isCheck2 := isCheck2 | FindPixelRGB(sx + width * 0.7, sy, sx + width, sy + height, 0xDBB968, 0x10)

    if(isCheck1 == 1 && isCheck2 == 1) {
        ret:=1
        
        if(DBUG == 1) {
            DumpLogD("[BnsIsBossDetected] BOSS detected!")
        }
    }

    return ret
}


BnsIsZakoDetected() {    ;副Boss - 藍色
    ret:=0

    regions := StrSplit(ENEMY_ZAKO_LEVEL_REGION, ",", "`r`n")

    sx := regions[1]
    sy := regions[2]
    width := regions[3]
    height := regions[4]

    ;ShowTipD("[System] - BnsIsZakoDetected sx:" sx ", sy:" sy ", ex:"  sx + width ", ey:" sy + height)

    isCheck1 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF0F0F0, 0x08)    ;高亮等級(比玩家等級高)
    isCheck2 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xA9A9A9, 0x08)     ;低亮等級(比玩家等級低)
    isCheck3 := FindPixelRGB(sx + width * 0.7, sy, sx + width, sy + height, 0x828D9C, 0x10)

    if((isCheck1 == 1 || isCheck2 == 1 ) && isCheck3 == 1) {
        ret:=1

        if(DBUG == 1) {
            DumpLogD("[BnsIsBossDetected] ZAKO detected!")
        }
    }

    return ret
}



;================================================================================================================
;    CHECK - Check Enemy clear (block API)
;================================================================================================================
;阻塞式API [ retain ] 丟失目標容許時間(ms);  [ timeout ] 總戰鬥超時(s);  [ fnAction ] 重複性動作(cb);  [ fnEscape ] 脫離戰鬥條件(cb);
BnsIsEnemyClear(retain, timeout, fnAction := 0, fnEscape := 0) {
    return BnsIsEnemyClearCount(retain, timeout, fnAction, fnEscape)
}

;阻塞式API [ retain ] 丟失目標容許時間(ms);  [ timeout ] 總戰鬥超時(s);  [ fnAction ] 重複性動作(cb);  [ fnEscape ] 脫離戰鬥條件(cb);
BnsIsEnemyClearTick(retain, timeout, fnAction := 0, fnEscape := 0) {    ;沒有指定 fnEscape 則以 角色死亡 為條件
    tickStartTime := A_TickCount       ;開機到現在的 milliseconds
    lastActiveTime := tickStartTime    ;最後有效時間 milliseconds
    duringInactiveTime := 0            ;暫停經過的 milliseconds
    totalInactiveTime := 0             ;總暫停的 milliseconds

    actionCostTime := 0
    escapeCostTime := 0

    watchDogTime := lastActiveTime

    charactorDeadCount := 0

    t := timeout * 1000    ;換算s 成 ms, //TODO: 之後要統一成 ms

    if( t == 0 ) {
        t := 2147483647    ;不限時間
    }
    
    loop {
        if((A_TickCount - tickStartTime - totalInactiveTime - actionCostTime - escapeCostTime) > t) {    ;timout
            return 0
        }

        if(WinActive(res_game_window_title)) {
            ShowTipI("●[System] - windows active, resume caculate")
            totalInactiveTime += duringInactiveTime    ;記算非啟動補償時間(第一次啟動都是0, 需要進入非啟動狀態才有值)
            duringInactiveTime := 0

            lastActiveTime := A_TickCount
            DumpLogD("[DBG] totalInactiveTime:" totalInactiveTime ", duringInactiveTime:" duringInactiveTime ", lastActiveTime:" lastActiveTime)

            if(fnEscape) {    ;如果 fnEscape != null
                escapeCostTime := A_TickCount
                ret := fnEscape.call()
                escapeCostTime := A_TickCount - escapeCostTime 

                if(ret != 0) {    ;達成脫離條件
                    return ret
                }
            }
            else {    ;沒有指定 escape 條件就以角色死亡為脫出條件
                if(BnsIsCharacterDead() == 1) {
                    charactorDeadCount += 1
                }
                else {
                    charactorDeadCount := 0
                }

                if(charactorDeadCount == 5) {     ;dead judgement 500ms
                    return -1     ;you dead
                }
            }


            if(fnAction) {    ;如果 fnAction != null
                actionCostTime := A_TickCount
                fnAction.call()
                actionCostTime := A_TickCount - actionCostTime 
            }

            if(BnsIsEnemyDetected() == 0) {
                ;確認是否超過丟失目標容許值(確認找不到怪)
                delta := (A_TickCount - watchDogTime - totalInactiveTime - actionCostTime - escapeCostTime)

                if(DBUG == 2) {
                    DumpLogD("[BnsIsEnemyClear] miss target, watchDog:" watchDogTime "," totalInactiveTime "," actionCostTime "," escapeCostTime  ", delta:" delta)
                }

                if(delta >= retain) {
                    return 1
                }
            }
            else {
                ;歸零計數器
                watchDogTime := lastActiveTime
                if(DBUG >= 1) {
                    DumpLogD("[BnsIsEnemyClear] lock on tartget, watchDog:" watchDogTime)
                }
            }
        }
        else {
            ShowTipI("●[System] - windows inactive, ignore caculate")
            duringInactiveTime := A_TickCount - lastActiveTime
        }

        sleep 100
    }

    return 0    ;detect enemy but timeout to fight
}

;可支援AHK系統pause 
;阻塞式API [ retain ] 丟失目標容許時間(ms);  [ timeout ] 總戰鬥超時(s);  [ fnAction ] 重複性動作(cb);  [ fnEscape ] 脫離戰鬥條件(cb);
BnsIsEnemyClearCount(retain, timeout, fnAction := 0, fnEscape := 0) {    ;沒有指定 fnEscape 則以 角色死亡 為條件
    charactorDeadCount:=0
    enermyCleanCount := 0
    ;目標丟失容許時間(最小單位 ms)
    r := floor(retain / 100)
    ;總超時時間(最小單位 s)
    t := timeout * 10
    
    if( t == 0 ) {
        t := 2147483647    ;不限時間
    }

    loop, %t% {
        if(WinActive(res_game_window_title)) {

            if(fnEscape) {    ;如果 fnEscape != null
                ret := fnEscape.call()

                if(DBUG >=1) {
                    ShowTipD("●[Debug] - BnsIsEnemyClearCount - escape: " ret)
                }

                if(ret != 0) {    ;達成脫離條件
                    return ret
                }
            }
            else {    ;沒有指定 escape 條件就以角色死亡為脫出條件
                if(BnsIsCharacterDead() == 1) {
                    return -1
                }
            }

            if(fnAction) {    ;如果 fnAction != null
                ret := fnAction.call()

                if(DBUG >=1) {
                    ShowTipD("●[Debug] - BnsIsEnemyClearCount - exec action,  : " ret)
                }
            }


            if(BnsIsEnemyDetected() == 0) {
                enermyCleanCount += 1
            }
            else {
                enermyCleanCount := 0
            }

            if(DBUG >=1) {
                ShowTipD("●[Debug] - BnsIsEnemyClearCount - count:" enermyCleanCount ", r: " r "; t: " A_index "; tout: " t)
            }

            if(enermyCleanCount == r) {
                return 1    ;enermy clear
            }

        }
        else {
            ShowTipI("●[System] - windows inactive, ignore caculate")
        }

        sleep 100

        if(A_index == floor(t * 0.8)) {
            BnsActionAdjustCamaraZoom(27)
        }
    }

    return 0    ;detect enemy but timeout to fight
}



;================================================================================================================
;    CHECK - Is Leave Battle
;================================================================================================================
;是否為脫戰狀態; [ maxTime ] 最大判定時間 ms;  [ return ] 0:戰鬥狀態; 1:脫戰狀態
BnsIsLeaveBattle(maxTime := 1) {    ;ms
    return (GetMemoryHack().isMemHackWork() == 1) ? !GetMemoryHack().isInBattling() : BnsIsLeaveBattleLegacy(maxTime)
}

BnsIsLeaveBattleLegacy(maxTime) {    ;ms
    ret := 0

    regions := StrSplit(STAMINA_INDICATOR_REGION, ",", "`r`n")
    ;血條, 內力, 輕功 面板是以 輕功為主移動UI.
    ;血條 1
    ;內力 1.785, 鬥士沒有此項
    ;輕功 1

    width := floor(regions[3] // 20)
    hight := regions[4]

    sx := regions[1]
    sy := regions[2]

    if(maxTime == 0) {    ;infinity block
        t := 2147483647    ;int max value
    }
    else if(maxTime == 1) {    ;non block, run once only
        t := 1
    }
    else {    ;block until detect or timeout
        t := floor(maxTime // 1000)
    }

    loop, %t% {
        ret := FindPixelRGB(sx, sy, sx + width, sy + hight, 0xC6D44D, 0x0F)

        if(ret == 1) {
            break
        }

        sleep 200
    }

    if(DBUG >= 1) {
        DumpLogD("[BnsIsLeaveBattle] ret: " ret)
    }
    
    return ret
}



;================================================================================================================
;    CHECK - Check Character Death
;================================================================================================================
;Get character wether dead;  @return - 1: dead; 0: alive
BnsIsCharacterDead() {  ;有bug, 隔離狀態也是1
    return (GetMemoryHack().isMemHackWork() == 1) ? BnsIsCharacterDeadMem() : BnsIsCharacterDeadLegcy()
}

BnsIsCharacterDeadMem() {
    return (GetMemoryHack().getPosture() == 1)
}

BnsIsCharacterDeadLegcy() {

    regions := StrSplit(STAMINA_INDICATOR_REGION, ",", "`r`n")    ;使用輕功當基準,推算血條位置
    ;血條 1
    ;內力 1.785, 鬥士沒有此項
    ;輕功 1


    width := floor(regions[3] // 20)    ;取前 1/20 部份
    height := regions[4]

    sx := regions[1] + floor(width // 4)
    sy := regions[2] - height
    
    c1 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF27E32, 0x18)    ;鬥士血條位置

    sy := sy - floor(height * 1.785)
    c2 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF27E32, 0x18)    ;非鬥士血條位置

    ; send {alt down}
    ; sleep 200
    ; MouseMove sx, sy

    ; sleep 10000
    ; send {alt up}

    if((c1 | c2) == 0) {
        if(DBUG == 1) {
            DumpLogD("[BnsIsCharacterDead] Charator Dead!")
        }
        return 1    ;you dead
    }

    return 0    ;alive
}
