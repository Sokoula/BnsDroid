#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



global FIRST_OPTION_Y :=365        ;手工計算
global OPTION_HIGHT :=32        ;手工計算


global tabDungeonX :=
global tabDungeonY :=

global btnStartX :=
global btnStartY :=


global ArrHeroPreviews := Array()
global ArrAerodromePreviews := Array()

global CONFUSE_PROTECT :=1

global MISSION_ACCEPT := 0    ;是否需要與接廣場NPC交談並接任務

;================================================================================================================
;    Common
;================================================================================================================
;@Discard
BnsOuF8Init() {
    ;建立 f8 副本列表預覽地圖(Hero本時double check用, Aerodrome本用來選取副本)
    ;封魔本出了之後 Hero 本有問題，待修
    loop, 10 {
        ArrHeroPreviews.push("empty" A_index)
    }

    ArrHeroPreviews.push("pic_f8_dungeon_preview_ghostface")    ;11, 鬼面是列表上第11個(不算活動本)
    ArrHeroPreviews.push("")
    ArrHeroPreviews.push("pic_f8_dungeon_preview_sendstorm")    ;13, 沙暴是列表上第13個(不算活動本)


    ArrAerodromePreviews.push("empty" 1)                                        ;1,
    ArrAerodromePreviews.push("empty" 1)                                        ;2,
    ArrAerodromePreviews.push("pic_f8_dungeon_preview_ChaosSupplyChain1")       ;3,
}

;================================================================================================================
;    OPERATION - Go to F8 Dungeon Lobby from earth
;================================================================================================================
BnsOuF8EarthGoLobby() {
    ;按下 F8
    ControlSend,,{f8}, %res_game_window_title%
    sleep 200

    ; TODO: 座標是寫死的, 需要後續改為自適配
    sx := floor(WIN_CENTER_X - WIN_BLOCK_WIDTH * 2.8)
    sy := floor(WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 2.3 + 32)
    rw := floor(WIN_BLOCK_WIDTH * 2.8)
    rh := floor(WIN_BLOCK_HEIGHT * 2.3)
    val := GetTextOCR(sx, sy, rw, rh, res_game_window_title)    ; PaddleOCR 注意參數皆需要 int, 否則報錯

    ; msgbox % sx ", " sy ", " rw ", " rh " : " val

    if(val == res_sys_f8_unicom_dungeon_card_title) {
        MouseClick, left, sx + rw * 0.5, sy + rh * 0.5
        sleep 3000

        return BnsOuF8LobbyWaitingReady()
    }
    else {
        return 0
    }

}

;@Discard
BnsOuF8EarthGoLobbyPic() {
    global findX
    global findY



    if(FindPicList(0, 0, 1920, 1200, 80, "res\pic_f8_entry_pattern") == 1) {


        ShowTipD(findX ", " findY)

        ;點擊 F8 卡片
        MouseMove findX+100, findY+150
        sleep 200

        ;等待飛龍脈動畫
        click
        sleep 3000

        return BnsOuF8LobbyWaitingReady()
    }
    else {
        return 255
    }
}

;================================================================================================================
;    OPERATION - Go back to F8 hall from dungeon
;================================================================================================================
BnsOuF8GobackLobby(confirm := 1) {
    BnsStopAutoCombat()

    loop, 5 {
        ;先接收任務獎勵
        ;Esc 叫系統選單
        ControlSend,,{ESC}, %res_game_window_title%
        sleep 200

        ;if(FindPicList(WIN_THREE_QUARTERS_X, WIN_THREE_QUARTERS_Y, WIN_WIDTH, WIN_HEIGHT, 100, "res\pic_f8_menu_exit") == 1) {
            ; exitX := findX + WIN_BLOCK_WIDTH * 0.3
            ; exitY := findY + WIN_BLOCK_HEIGHT * 0.07

        if(GetMemoryHack().getMenuStatus() == 1) {
            exitX := 1770
            exitY := 860

            MouseMove exitX, exitY
            sleep 200

            ; MouseClick
            ControlClick, x%exitX% y%exitY%, %res_game_window_title%,, Left     ;ControlClick 一定要在指定的位置才能做用, 滑鼠游標不會移動
            sleep 500

            ControlSend,,{y}, %res_game_window_title%
            sleep 1200

            if(FindPicList(WIN_CENTER_X, WIN_CENTER_Y, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_reward_button") == 1) {

                ControlSend,,{f}, %res_game_window_title%
                sleep 500

                ControlSend,,{f}, %res_game_window_title%
                sleep 1000

                ControlSend,,{f}, %res_game_window_title%
                sleep 300

                ; ;重新 Esc 叫系統選單
                ; ControlSend,,{ESC}, %res_game_window_title%
                ; sleep 300

                ; MouseMove exitX, exitY
                ; sleep 300

                ; ; MouseClick
                ; ControlClick, x%exitX% y%exitY%, %res_game_window_title%,, Left, 2     ;ControlClick 一定要在指定的位置才能做用, 滑鼠游標不會移動
                ; sleep 1500

                ; ControlSend,,{f}, %res_game_window_title%
                ; sleep 300
            }

            if(BnsIsMapLoading() == 1) {
                if(DBUG == 1) {
                    DumpLogD("[BnsOuF8GobackLobby] Operation success, map loading")
                }
                break
            }
        }
    }

    ;有確認就等待判定是否進等候室, 否則直接略過
    return (confirm) ? BnsOuF8LobbyWaitingReady() : 1
}


;================================================================================================================
;    OPERATION - Get Room Number
;================================================================================================================
;Get F8 room number; [ return ] integer
BnsOuF8GetRoomNumber() {
    return BnsOuF8GetRoomNumberMem()
}

;Memory method
BnsOuF8GetRoomNumberMem() {
    return GetMemoryHack().getF8RoomNumber()
}

;OCR method
BnsOuF8GetRoomNumberOCR() {
    posNumTail := 230

    loop {
        ;尋找房號尾碼邊界, 條件是 5個 pixel 的寬度內找不到白色
        if(FindPixelRGB(posNumTail, 70, posNumTail + 7, 80, 0xFFFFFF, 0) == 0) {    ;posistion
            if(DBUG == 1) {
                DumpLogD("[BnsOuF8GetRoomNumber] tail position of number:" posNumTail)
            }
            break
        }

        posNumTail += A_index
    }

    width := posNumTail - 168 + 5

    return GetTextOCR(168, 45, width, 25, res_game_window_title)    ;region
}


;================================================================================================================
;    OPERATION - Enter Room and Ready
;================================================================================================================
BnsOuF8EnterRoomAndReady(number) {
    if(BnsOuF8GetRoomNumber() != number) {
        MouseClick, left, WIN_THREE_QUARTERS_X , WIN_THREE_QUARTERS_Y
        sleep 1000
        Send {F8}
        sleep 1000
        Send %number%
        sleep 500
        Send {Enter}
        sleep 3500
    }

    ;Tap Ready Button
    ; BnsOuF8TapStartButton()
    ; sleep 1000

    loop, 5 {
        btnText := GetTextOCR(WIN_CENTER_X - WIN_BLOCK_WIDTH, WIN_HEIGHT - WIN_BLOCK_HEIGHT, WIN_BLOCK_WIDTH * 2, floor(WIN_BLOCK_HEIGHT * 2 / 3), res_game_window_title)
        DumpLogD("[BnsOuF8EnterRoomAndReady] button text:" btnText)

        if (RegExMatch(btnText, res_lobby_btn_member_cancel) != 0) {
            DumpLogD("[BnsOuF8EnterRoomAndReady] prepare ready!!")
            return 1
        }
        else {
            DumpLogD("[BnsOuF8EnterRoomAndReady] retry " A_index " tap ready button")
            BnsOuF8TapStartButton()
        }
        sleep 2000
    }

    DumpLogE("[BnsOuF8EnterRoomAndReady] Error! failed to prepare ready")
    return 0
}



;================================================================================================================
;    OPERATION - locat direct start button(deactive)
;================================================================================================================
BnsOuF8SearchDeactiveStartButton(){
    ;定位出發按鈕
    if(FindPicList(WIN_CENTER_X, WIN_THREE_QUARTERS_Y, WIN_THREE_QUARTERS_X, WIN_HEIGHT, 80, "res\pic_f8_button_dungeon_start_deactive") == 1) {
        global btnStartX := findX + WIN_BLOCK_WIDTH * 0.8
        global btnStartY := findY + WIN_BLOCK_HEIGHT * 0.3

        DumpLogD("[BnsOuF8SearchDeactiveStartButton] btn start_deactive x:" btnStartX ", y:" btnStartY)

        return 1
    }
    else {
        ShowTipE("●[Operating] - Exception: locate dungeon start button failed")
        return 0
    }
}


;================================================================================================================
;    OPERATION - Tap direct start button
;================================================================================================================
BnsOuF8TapStartButton() {
    MouseClick left, WIN_CENTER_X + WIN_BLOCK_WIDTH, WIN_HEIGHT - WIN_BLOCK_HEIGHT * 0.5
    sleep 200
    MouseMove, WIN_CENTER_X, WIN_CENTER_Y
}


;================================================================================================================
;    OPERATION - Party Form selection
;================================================================================================================
BnsOuF8SelectPartyType(t) {
    regions := StrSplit(PARTY_FORM_HEADER_TAB_REGION, ",", "`r`n")
    ret := 0

    ;PARTY_FORM_HEADER_TAB_REGION
    ;[    副本    |    戰場    ]
    ;[    :  英雄 : 封魔  :    ]

    unitW := regions[3] / 4        ;[     |英雄|封魔|     ]
    unitH := regions[4] / 2


    mX := regions[1] + (unitW * (t + 0.5))
    mY := regions[2] + (unitH * 1.5)


    loop {
        if (t == 1) {    ;英雄副本
            str := GetTextOCR(regions[1], regions[2] + floor(unitH * 2), floor(unitW), floor(unitH), res_game_window_title)
            if(DBUG > 1) {
                DumpLogD("[BnsOuF8SelectPartyType] str:" str ", t:" t ", pattern:" res_lobby_labal_party_setting)
            }

            if (RegExMatch(str, res_lobby_labal_party_setting) != 0) {  ;隊伍設定
                DumpLogD("[BnsOuF8SelectPartyType] type:" t " select success")
                ret := A_index
                break
            }
        }

        if(t == 2) {    ;封魔錄
            str := GetTextOCR(regions[1], regions[2] + floor(unitH * 6.3), floor(unitW), floor(unitH), res_game_window_title)
            if(DBUG > 1) {
                DumpLogD("[BnsOuF8SelectPartyType] str:" str ", t:" t ", pattern:" res_lobby_labal_level_select)
            }

            if (RegExMatch(str, res_lobby_labal_level_select) != 0) {   ;段位選擇
                DumpLogD("[BnsOuF8SelectPartyType] type:" t " select success")
                ret := A_index
                break
            }
        }

        MouseClick, Left, mX, mY
        sleep 2000
    }

    DumpLogD("[BnsOuF8SelectPartyType] type:" t " select failed")
    return ret
}


BnsF8SelectPartyMode(m) {
    ;PARTY_FORM_HEADER_TAB_REGION 包含
    ;[     副本      |      戰場     ]
    ;[        英雄   |   封魔        ]
    regions := StrSplit(PARTY_FORM_HEADER_TAB_REGION, ",", "`r`n")
    ret := 0

    unitW := regions[3] / 3         ;[入門|一般|熟鍊]
    unitH := regions[4] / 2

    mX := regions[1] + (unitW * ((m - 1) + 0.5))
    mY := regions[2] + (unitH * 3.5)


    loop, 3 {
        if(FindPixelRGB(mX, mY + unitH * 0.3, mX + unitW // 2, mY + unitH * 0.5, 0x2E5E86, 0x18) == 1) {
            DumpLogD("[BnsF8SelectPartyMode] mode:" m " select success")
            ret := A_index
            break
        }

        MouseClick, Left, mX, mY
        sleep 2000
    }


    DumpLogD("[BnsF8SelectPartyMode] mode:" m " select failed")
    return ret
}






;easy
;@Discard
BnsF8SelectPartyModeEasy() {
    ;TODO: 入門沒東西是要掛個啥
}

;normal
;@Discard
BnsF8SelectPartyModeNormal() {
    if(FindPicList(WIN_THREE_QUARTERS_X, 0, WIN_WIDTH, WIN_QUARTER_Y, 80, "res\pic_f8_tab_dungeon") == 1) {
        tabDungeonX := findX
        tabDungeonY := findY
    }

    if(FindPicList(WIN_THREE_QUARTERS_X, 0, WIN_WIDTH, WIN_CENTER_Y, 20, "res\pic_f8_tab_normal") == 1) {
        MouseMove findX + 50, findY + 20
        sleep 200

        ;切換模式
        click
        sleep 200

        return 1
    }
    else {
        ShowTipW("●[Operating] - Exception: locate hard tab failed")
        return 0
    }

}

;hard
;@Discard
BnsF8SelectPartyModeHard() {
    if(FindPicList(WIN_THREE_QUARTERS_X, 0, WIN_WIDTH, WIN_THREE_QUARTERS_Y, 80, "res\pic_f8_tab_dungeon") == 1) {
        tabDungeonX := findX
        tabDungeonY := findY
    }

    if(FindPicList(WIN_THREE_QUARTERS_X, 0, WIN_WIDTH, WIN_CENTER_Y, 20, "res\pic_f8_tab_hard") == 1) {
        MouseMove findX + 50, findY + 20
        sleep 200

        ;切換模式
        click
        sleep 200

        return 1
    }
    else {
        ShowTipW("●[Operating] - Exception: locate hard tab failed")
        return 0
    }
}

;================================================================================================================
;    OPERATION - Select Hero Dungeon
;================================================================================================================
BnsOuF8SelectHeroDungeon(index, scroll := 0) {
    ;PARTY_FORM_HEADER_TAB_REGION 包含
    ;[     副本      |      戰場     ]
    ;[        英雄   |   封魔        ]
    regions := StrSplit(PARTY_FORM_HEADER_TAB_REGION, ",", "`r`n")

    ;以 HEADER 的 1/2 為單位算出各部比例
    ;副本/戰場  : 1
    ;英雄/封魔  : 1
    ;中間雜項   : 7.38
    ;副本卡片   : 0.71
    ;副本卡片   : 0.83
    ;副本卡片   : 0.71
    ;副本卡片   : 0.71
    ;副本卡片   : 0.83
    ;副本卡片   : 0.83
    ;不結最尾篩選鍵一共14

    unitH := regions[4] / 2

    mX := regions[1] + (regions[3] * 0.5)
    mY := regions[2] + (unitH * (9.38 - 0.38)) + (index * unitH * 0.77)
    ;9.38 - 0.38 預算把滑鼠點擊位置置於卡片中間
    ;0.77 = (0.71 + 0.83 ) / 2 -- 30 ~ 35 間取平均卡片高度

    MouseMoveA(mX, mY)

    ;將副本表拉到最頂以歸0校準
    ; MouseWheel(1, 20)
    ; sleep 200

    ; MouseWheel(-1, scroll)
    ; sleep 200

    MouseClick, Left, mX, mY

    return 1
}

;@Discard
BnsOuF8SelectHeroDungeonPic(index, scroll) {
    ;先定位出發按鈕
    if(BnsOuF8SearchDeactiveStartButton() == 0) {
        DumpLogE("[BnsOuF8SelectHeroDungeon] can't find start button!")
        return 0
    }

    DumpLogD("[BnsOuF8SelectHeroDungeon] tab_dungeon x:" tabDungeonX ", y:" tabDungeonY)

    ;尋找副本清單項目
    loop, 3 {
        if(tabDungeonX != 0 && tabDungeonY !=0) {
            click
            sleep 100

            ;先定位副本tab，再移動到副本列表第 index 列
            oX:=tabDungeonX + 100
            oY:=tabDungeonY + FIRST_OPTION_Y + ((index - 1) * OPTION_HIGHT)

            ;loop, 3 {
                DumpLogD("[BnsOuF8SelectHeroDungeon] option x:" oX ", y:" oY " [index:" index ", FIRST_OPTION_Y:" FIRST_OPTION_Y ", OPTION_HIGHT:" OPTION_HIGHT "]")
                MouseMove oX, oY
                sleep 100
                MouseGetPos, xPos, yPos
                DumpLogD("[BnsOuF8SelectHeroDungeon] get pos x:" xPos ", y:" yPos )

                ;if(Abs(oy - ypos) < 2) {    ;檢查是否確實點到想要的位置, 沒有就重做
                ;    break
                ;}
            ;}
            sleep 1000

            ;將副本表拉到最頂以歸0校準
            MouseWheel(1, 20)
            sleep 200

            MouseWheel(-1, scroll)
            sleep 200

            ;點擊選取選項
            click
            sleep 1000

            ;確認是否是正確的項目(檢查預先建立的preview清單)
            prevIndex:=index + scroll
            if(ArrHeroPreviews[prevIndex] != "") {    ;擁有圖資才執行確認
                if(FindPicList(WIN_THREE_QUARTER_X, WIN_QUARTER_Y, WIN_WIDTH, WIN_CENTER_Y, 80, "res\" ArrHeroPreviews[prevIndex]) != 1) {

                    DumpLogI("[BnsOuF8SelectHeroDungeon] index:" index ", scroll:" scroll ", select incorrect, re-work!")
                    continue
                }

                DumpLogI("[BnsOuF8SelectHeroDungeon] index:" index ", scroll:" scroll ", select success!")
            }

            return 1
        }
    }

    DumpLogE("[BnsOuF8SelectHeroDungeon] index:" index ", scroll:" scroll ", tab_dungeon not located!!")

    return 0
}

;================================================================================================================
;    OPERATION - Select Demonsbane Dungeon
;================================================================================================================
BnsOuF8SelectDemonsbaneDungeon(level, index, scroll) {
    regions := StrSplit(PARTY_FORM_HEADER_TAB_REGION, ",", "`r`n")

    unitH := regions[4] / 2        ;整個封魔表單為 16.33 單位((副本/戰場+英雄/封魔錄)/2)
    itemH := floor(unitH * 4.69 * 0.33)        ;封魔副本選項卡

    mx := regions[1] + regions[3] * 0.68
    my := regions[2] + floor(unitH * 11.64 + (itemH * ((index - 1) + 0.5)))
    MouseMove mx, my

    ;選擇副本(座標定位)
    MouseClick, left, mx, my
    sleep 1000


    ;將副本表拉到最頂以歸0校準
    MouseWheel(1, 20)
    sleep 1000

    ; MouseWheel(-1, scroll)
    MouseWheel(-1, scroll * 10)
    sleep 200

    ;選擇副本(座標定位)
    MouseClick, left, mx, my
    sleep 1000

    ;點擊段數
    MouseClick, left, mx, regions[2] + unitH * 7
    sleep 1000

    ;輸入段數
    Send {Shift down}{Left 3}{Shift up}
    sleep 500
    Send %level%
    sleep 1000

    DumpLogI("[BnsOuF8SelectDemonsbaneDungeon] index:" index ", scroll:" scroll ", level:" level ", select Success!")

    return 1
}

;@Discard
BnsOuF8SelectDemonsbaneDungeon_R(level, index, scroll) {
    ;選擇副本
    ;if(FindPicList(WIN_QUARTER_X, WIN_CENTER_Y, WIN_WIDTH, WIN_HEIGHT, 150, "res\"ArrAerodromePreviews[index]) == 1) {
    ;    loop, 3 {
    ;        MouseClick, left, findX + WIN_BLOCK_WIDTH * 0.3, findY + WIN_BLOCK_HEIGHT * 0.3
    ;        sleep 500
    ;    }
    ;    sleep 1000
    ;}
    ;else {
    ;    DumpLogE("[BnsOuF8SelectDemonsbaneDungeon] index:" index ", scroll:" scroll ", select incorrect!")
    ;    return 0
    ;}

    ;選擇副本(座標定位)
    MouseClick, left, WIN_THREE_QUARTERS_X + WIN_BLOCK_WIDTH * 4, WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 0.15) + (WIN_BLOCK_HEIGHT * index)
    sleep 1000

    ;點擊段數
    MouseClick, left, WIN_CENTER_X + WIN_BLOCK_WIDTH * 13,  WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 1.3
    sleep 1000

    ;輸入段數
    Send {Shift down}{Right 3}{Shift up}
    sleep 500
    Send %level%
    sleep 1000

    DumpLogI("[BnsOuF8SelectDemonsbaneDungeon] index:" index ", scroll:" scroll ", level:" level ", select Success!")

    return 1
}



;================================================================================================================
;    OPERATION - Wait loading before go into dungeon
;================================================================================================================
BnsOuF8LobbyWaitingReady() {
    regions := StrSplit(PARTY_FORM_HEADER_TAB_REGION, ",", "`r`n")

    loop, 300 {
        ShowTipI("●[System] - Loading...")
        val := GetTextOCR(regions[1], regions[2], floor(regions[3] * 0.5), floor(regions[4] * 0.6), res_game_window_title)
        if(val == res_lobby_label_tab_dungeon) {
            ShowTipI("●[System] Entre F8 hall")
            return 1
        }

        sleep 200
    }

    return 0
}

;@Discard
BnsOuF8LobbyWaitingReadyPic() {
    ;確認已進到 F8 等候室
    loop, 300 {
        ShowTipI("●[System] - Loading...")

        if(FindPicList(WIN_THREE_QUARTERS_X, 0, WIN_WIDTH, WIN_QUARTER_Y, 80, "res\pic_f8_tab_dungeon") == 1) {
            ShowTipI("●[System] Entre F8 hall")
            return 1
        }

        sleep 200
    }

    ShowTipE("●[Exception] - Loading timeout...")
    return 0
}



;================================================================================================================
;    ACTION -
;================================================================================================================
;F8 square navigation; [ cate ] 1:英雄; 2:封魔(demonsbane);  [ accept ] 0:不接任務; 1:接任務;  [ confirm ] 0:不等待過圖完畢立即返回; 1:等待過圖完畢反回
BnsOuF8DefaultGoInDungeon(cate, accept := 0, confirm := 1) {
    if(GetMemoryHack().isMemHackWork() == 1) {

        switch cate {
            case 1:    ;Hero
                px1 := 77644, py1 := 716
                px2 := 77970, py2 := 840
                px3 := 78030, py3 := 1200

            case 2:    ;Demonsbane
                px1 := 77575, py1 := 685
                px2 := 78025, py2 := 980
                px3 := 78025, py3 := 2250
        }

        if(accept ==1 || MISSION_ACCEPT == 1) { ;accept 有值就強制蓋掉 MISSION_ACCEPT 的設置

            BnsActionSprintToPosition(px1, py1)
            ; BnsActionAdjustDirection(90)
            sleep 1200

            ControlSend,,{f}, %res_game_window_title%
            loop ,2 {
                sleep 1000
                ControlSend,,{f}, %res_game_window_title%
                sleep 100
                ControlSend,,{f}, %res_game_window_title%
            }

            if() {
                ControlSend,,{ESC}, %res_game_window_title%
                sleep 100
            }

            BnsActionSprintToPosition(px2, py2)
        }


        BnsActionSprintToPosition(px3, py3)

        if(confirm == 1) {
            sleep 3000

            ;等待廣場進副本讀圖完畢
            if(BnsWaitMapLoadDone() == 0) {
                BnsOuF8GobackLobby()
                return 0
            }
        }

        return 1
    }
    else {
        return BnsOuF8DefaultGoInDungeonLegacy(cate, accept, confirm)
    }
}


BnsOuF8DefaultGoInDungeonLegacy(cate, accept := 0, confirm := 1) {
    sleep 1000
    ShowTipI("●[System] - Move from square into dungeon")

    switch cate
    {
        case 1:    ;Hero
            duration1 := 2300
            duration2 := 0
            duration3 := 5500

        case 2:    ;Demonsbane
            duration1 := 2600
            duration2 := 6000
            duration3 := 12000

    }

    if(HIGH_SPEED_ROLE == 1) {
        duration1 := duration1 * 0.92
        duration2 := duration2 * 0.92
        duration3 := duration3 * 0.92
    }

    if(accept ==1 || MISSION_ACCEPT == 1) { ;accept 有值就強制蓋掉 MISSION_ACCEPT 的設置

        ;先與NPC對話接任務, 再進入副本
        Send {w Down} {a Down}
        sleep duration1
        Send {a Up}
        sleep 1400
        Send {w Up}
        sleep 100

        Send {f}
        loop ,2 {
            sleep 1000
            Send {f} {f}
        }
        Send {Esc}
        sleep 100

        Send {d Down}
        sleep 300
        Send {w Down}
        sleep duration1
        Send {w Up} {d Up}

        if(CONFUSE_PROTECT == 1) {
            BnsActionRandomConfuseMove(duration2)
        }
        else {
            BnsActionSprint(floor(duration2 / 2))
        }
    }
    else {
        ;無需對話接任務, 直接進入副本
        if(CONFUSE_PROTECT == 1) {
            BnsActionRandomConfuseMove(duration3)
        }
        else {
            BnsActionSprint(floor(duration3 / 2))
        }
    }

    if(confirm == 1) {
        sleep 3000

        ;等待廣場進副本讀圖完畢
        if(BnsWaitMapLoadDone() == 0) {
            BnsOuF8GobackLobby()
            return 0
        }
    }

    return 1
}
