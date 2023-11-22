#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;遁地導航; [ id ] 1:武神塔; 2:鋼鐵; 3:永生; 4:天盆; 5:咒法寺; 6:泰天; 7:夏曼
BnsMtcMapNavigate(id) {
    ;格式(比例*寬度): x1,y1;x2,y2; ...;xN,yN
    path := ""

    switch id {
        ;-- 東方大陸 --------
        case 1:     ;武神會堂 - 武神塔
            path := "0.74,0.67;0.57,0.50"

        case 2:     ;白青山脈 - 鋼鐵堡壘
            path := "0.81,0.44;0.19,0.29"

        ;-- 南方大陸 --------
        case 3:     ;天命宮 - 永生寺
            path := "0.31,0.8;0.27,0.51"

        case 4:     ;建元成道 - 天之盆地
            path := "0.41,0.8;0.72,0.72"

        ;-- 西洛 ------------
        case 5:     ;咒法寺
            path := "0.24,0.59;0.45,0.22"

        case 6:     ;泰天王陵
            path := "0.24,0.59;0.46,0.49"

        ;-- 北方大陸 --------
        case 7:     ;東部島 - 白花樹
            path := "0.52,0.16;0.59,0.51"

    }

    return path
}


;地圖遁地; [ id ] 1:武神塔; 2:鋼鐵; 3:永生; 4:天盆; 5:咒法寺; 6:泰天; 7:夏曼
BnsMtcTeleport(id) {
    attr := BnsMtcMeansureMapGUI()
    ; attr := RegionSearch(0xD0C2A5, 0xD0C2A5)

    if(!isObject(attr)) {
        return 0
    }

    path := BnsMtcMapNavigate(id)

    ops := StrSplit(path, ";")

    ;滾輪拉到最大地圖
    loop 3 {
        ControlClick,, %res_game_window_title% ,,WheelUp
    }
    sleep 100


    ; loop ops.length() {
    loop 2 {

        tx := StrSplit(ops[A_index], ",")[1] * attr[5] + attr[1]
        ty := StrSplit(ops[A_index], ",")[2] * attr[6] + attr[2]
        
        MouseMove tx, ty
        sleep 100
        MouseClick, left, tx, ty

        sleep 300
    }

    ControlSend,,{y}, %res_game_window_title%
}



;偵測地圖視窗中地圖本圖範圍; [ return ] Array[左上X, 左上Y, 右下X, 右下Y, width, height]
BnsMtcMeansureMapGUI() {
    xblock := floor(1920 / 6)
    yblock := floor(1080 / 6)

    mapAttr := Array()

    ; DBUG := 2

    ;尋找地圖視窗內的地圖本圖左上角
    ret := 0
    loop 6 {
        y0 := yblock * (A_index - 1)
        y1 := yblock * A_index

        loop 6 {
            x0 := xblock * (A_index - 1)
            x1 := xblock * A_index

            ; ShowTip("pos: " x0 ", " y0 " -  " x1 ", " y1)

            ;找到疑似目標
            if(FindPixelRGB(x0,y0,x1,y1, 0xD0C2A5, 5)) {
                tx := findX
                ty := findY
                
                ;偏移確認是否為地圖本圖
                if(FindPixelRGB(findX+10, findY, findX + 20, findY, 0xD0C2A5, 5)) {
                    mapAttr.push(tx - 5)
                    mapAttr.push(ty)

                    ret := 1
                    break
                }
            }
        }

        if(ret == 1) {
            break
        }
    }

    if(ret == 0) {
        return 0
    }

    if(DBUG >= 2) {
        ShowTip("↖ left top corner", tx - 5, ty)
        sleep 1000
    }

    ;尋找地圖視窗內的地圖本圖右下角
    ret := 0
    loop 6 {
        y0 := 1080 - (yblock * (A_index - 1))
        y1 := 1080 - (yblock * A_index)

        loop 6 {
            x0 := 1920 - (xblock * (A_index - 1))
            x1 := 1920 - (xblock * A_index)

            ; ShowTip("pos: " x0 ", " y0 " -  " x1 ", " y1)

            ;找到疑似目標
            if(FindPixelRGB(x0,y0,x1,y1, 0xD0C2A5, 5)) {
                tx := findX
                ty := findY

                ;偏移確認是否為地圖本圖
                if(FindPixelRGB(findX - 10, findY, findX - 20, findY, 0xD0C2A5, 5)) {
                    mapAttr.push(tx + 5)
                    mapAttr.push(ty)

                    ret := 1
                    break
                }
            }
        }

        if(ret == 1) {
            break
        }
    }

    if(ret == 0) {
        return 0
    }

    if(DBUG >= 2) {
        ShowTip("↖ right bottom corner", tx + 5, ty)
        sleep 1000
    }

    mapAttr.push(mapAttr[3] - mapAttr[1])   ;width
    mapAttr.push(mapAttr[4] - mapAttr[2])   ;height

    return mapAttr
}