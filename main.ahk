#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;version 1.0.20230108

#include common.ahk
#include bns_DungeonManager.ahk

;================================================================================================================
;    Configuration (this config will be overlay if config.ini has value)
;================================================================================================================
;---系統設定---
global DBUG := 0
global LOGABLE := 4        ;1:only Error, 2:E|Warning, 3:E|W|Debug, 4:all


;---敵動熱鍵---
global HKEY := "^F1"
global PRKEY := "^F2"


;---系統環境設定---
;劍靈設定 界面大小85, 橫軸速度:60, 縱軸速度:60

;(覆寫 common.ahk 預設值)
global WIN_WIDTH := 1920                ;視窗的寬度 pixel
global WIN_HEIGHT := 1080 + 30          ;視窗的高度 pixel (需補上標題列的高度)



;---副本難度設定---
;(覆寫 bns_DungeonDispater.ahk 預設值)
global ACTIVITY := 0         ;當前活動副本(入門才會有)
global PARTY_MODE := 1       ;組隊模式: 1:入門, 2:一般, 3:困難


;--- Dungeon Selector(副本選擇) ------------------------------------------
; 001 - 天之盆地鑰匙      - 地表
; 101 - 鬼怪村活動        - 地表
; 102 - 紅絲倉庫          - 地表
; 103 - 可疑的空島        - 統合
; 104 - 輕功傳說大會      - 外界
; 201 - 鬼面劇團          - 地表
; 202 - 沙暴神殿          - 地表    (x)
; 203 - 青空船            - 地表    (x)
; 204 - 混沌補給基地      - 統合
; 205 - 崑崙派本山        - 統合
; 206 - 混沌黑神木        - 統合
; 207 - 黑龍教異變研究所  - 統合
; 208 - 黑龍教降臨殿      - 統合    (-)
; 209 - 搖風島            - 統合    (-)
; 210 - 混沌雪人洞窟      - 統合
; 301 - 千手羅漢陣        - 地表
; 302 - 巨神之心          - 外界
global DUNGEON_INDEX := 301           ;最後會被 config.ini 複蓋


;---地表副本選單設定---

;================================================================================================================
;    ACTION - Go into dungeon - Ghost Face
;================================================================================================================
EngageDungeon() {
    return BnsDungeonManager.dungeonRun(DUNGEON_INDEX)
}


SetupWizard() {
    loop {
        MouseGetPos gx, gy
        ToolTip % "x: " gx ", y: " gy

        sleep 30
    }

}


;================================================================================================================
;    System Event
;================================================================================================================
onStart() {
    tooltip                             ;清掉tooltip
    global v_Enable:=!v_Enable
}


onInit() {
    global pLogfile

    ; ImportExternIniConfig()    ;載入外部 config.ini 設定
    LoadExternIniConfig()

    DumpFileOpen()
    DumpLogI("=== Script cycle start ==============================================================================================================================")
    DumpSystemConfig()

    BnsOuF8Init()

    sleep 500
    MousePositionAdjust()
}

onPauseResume() {
    v_Pause := !v_Pause
    if(v_Pause == 1) {
        ShowTipI("●[Script] Pause!!")
        pauseTick := A_TickCount
    }
    else {
        ShowTipI("●[Script] Resume!!")
    }

    Pause
}


onReset() {
    tooltip                             ;清掉tooltip

    ;釋放按鍵
    Send {w Up}
    Send {a Up}
    Send {s Up}
    Send {d Up}
    Send {Alt up}
    Send {Shift Up}

    ;Pause
    ;EXITAPP
}


onDestory() {
    ;tooltip                             ;清掉tooltip
    global v_Enable:=0
    global v_pause:=0
    global pLogfile

    DumpLogI("=== Script cycle stop ===============================================================================================================================")
    DumpFileClose()

    ;重設AHK
    Reload
}


onFinish(msg) {
    DumpLogI("●[FINISH] reason: " msg)
    onDestory()
}



;================================================================================================================
;    Test
;================================================================================================================
singleStepTest() {
    ; testMode := 1

    if(testMode == 1)
    {

        ; sleep 15000

        ;///背景 滑鼠 點擊測試
        ; SetControlDelay -1
        ; ControlClick,,%res_game_window_title%,, Left,, NA X968 Y559   ;O  可移動, 但是沒有點擊
        ; ControlClick,,%res_game_window_title%,, Left, 10, NA X968 Y559  ;O
        ; ControlClick,,%res_game_window_title%,, Left, 10, NA x968 y559  ;O
        ; ControlClick,,%res_game_window_title%,,     , 10, NA x968 y559  ;O
        ; ControlClick, x968 y559 ,%res_game_window_title%,, ,, POS NA   ;O

        ; ControlClick, x968 y559 ,%res_game_window_title%,, ,, POS NA d  ;X
        ; ControlClick,,%res_game_window_title%,, LEFT,, NA x968 y559   ;O
        ; ControlClick, x968 y559, %res_game_window_title%,, LEFT,, POS   ;X
        ; ControlClick, x968 y559, %res_game_window_title%,, LEFT,, NA POS   ;O




        ; ControlClick, 1 ,%res_game_window_title%,, Left, 10, NA x968 y559
        ; ControlClick,,%res_game_window_title%, "", Left, 10, NA x968 y559
        ; sleep 500



        ; lParam := 800 & 0xFFFF | (560 & 0xFFFF) << 16
        ; PostMessage, 0x200, 0, %lParam%, , %res_game_window_title% ;WM_MOUSEMOVE
        ; sleep 500
        ; PostMessage, 0x201,  , %lParam%, , %res_game_window_title% ;WM_LBUTTONDOWN
        ; sleep 500
        ; PostMessage, 0x202,  , %lParam%, , %res_game_window_title% ;WM_LBUTTONUP
        ; sleep 500
        ; ControlClick,, %res_game_window_title%,, Left,, NA  x968 y559   ;O

        ; return 1

        ; loop 10 {
        ;     BnsActionSprintToPosition(-13236, 53598)   ;入口轉向點
        ;     sleep 1000
        ;     BnsActionAdjustDirection(50)
        ;     sleep 3000
        ;     BnsActionSprintToPosition(-14624, 52844)   ;入口轉向點
        ;     sleep 1000
        ;     BnsActionAdjustDirection(50)
        ;     sleep 3000
        ;     BnsActionSprintToPosition(-13274, 52050)   ;入口轉向點
        ;     sleep 1000
        ;     BnsActionAdjustDirection(50)
        ;     sleep 3000

        ; }

        ; return 1

        ; ShowTip("Searching...")aw
        ; FindPixelRGB(1920,1080,0,0, 0x45291F, 5)

        ; ShowTip("↖", findX, findY)
        ; msgbox % "findX: " findX ", findY: " findY
        ; return 1

        ; BnsMtcTeleport(7)
        ; return 1

        ; tick := A_TickCount
        ; BnsMtcMeansureMapGUI()
        ; msgbox % "End: " (A_TickCount - tick)
        ; return 1

        ; BnsPcTeamMembersRetreatToLobby()

        ; droid := new BnsDroidShroudedAjanara()
        ; droid.brokeShield()

        ; droid := new BnsDroidSuspiciousSkyIsland()


        ; droid := new BnsDroidGhostVillage()
        ; droid.dungeonNavigation()
        ; droid.start()
        ; droid.finish()
        ; return 1



        ; BnsPcSendPartyInvite("芙莉雅丶康奈埃", 3)

        ; droid := new BnsDroidFourInOne()
        ; droid.runStageTranquilCourtyard()
        ; droid.start()
        ; droid.leaveTeam(1)

        ; droid := new BnsDroidChaosYetiCave()
        ; droid.actionGoToFinalRoom()
        ; droid.moveToBossRoom(2)
        ; BnsActionWalkCircle(5000, 5000, -145)
        ; if(!BnsIsEnemyDetected()) {      ;開戰點沒有目標, 表示這是復活後撿箱
        ;     BnsStartAutoCombat()
        ; }
        ; return 1


        ; droid := new BnsDroidChimeraLab()
        ; droid.runnableSpecific()
        ; droid.takeDragonPulse(3)
        ; return 1

        ; BnsActionAdjustDirection(90)

        ; ControlSend,,{w down}, %res_game_window_title%
        ; memHack := GetMemoryHack()

;=================================== 魷魚遊戲
        ; ShowTip("●[待命中] 進場準備中...")
        ; ground := 39916 ;BnsGetPosZ()
        ; target := 25760


        ; ; loop {
        ; ;     x := BnsGetPosX()
        ; ;     y := BnsGetPosY()
        ; ;     ; if(x > -7500) {
        ; ;     ;     S+789   \owTip("●[待命中] 反場模式...")
        ; ;     ;     break
        ; ;     ; }

        ;     ; if(x > -12730 && y < 50350) {
        ;         BnsActionAdjustDirection(0)
        ;         BnsActionAdjustCamaraAltitude(300)
        ;         ShowTip("●[待命中] 已就彈射位置，等待起跳彈射觸發...")
        ; ;         break
        ; ;     }
        ; ;     sleep 100
        ; ; }


        ; loop {
        ;     ; if(BnsGetPosZ() > -8666 && (BnsGetPosZ() - ground > 50) && jump == 0) {
        ;     if(BnsGetPosZ() > 39960 && (BnsGetPosZ() - ground > 30)) {
        ;         ShowTip("●[爬升中] 到達巡航中高度...")
        ;         ; GetMemoryHack().setPosition(,, -8620)   ;8666
        ;         ; GetMemoryHack().setPosition(,, 39975)     ;39916
        ;         dsleep(770)
        ;         ; GetMemoryHack().setPosition(,, -8620)   ;8666
        ;         send {w down}
        ;         send {space down}
        ;         ; GetMemoryHack().setPosition(,, 39975)     ;39916
        ;         dsleep(70)
        ;         GetMemoryHack().setPosition(,, 39975)     ;39916
        ;         send {space up}
        ;         loop {
        ;             dst := floor(abs(target - BnsGetPosX()) / 5450 * 100)
        ;             if(dst > 100 ) {
        ;                 target := -7280
        ;             }


        ;             ShowTip("●[巡航中] 剩餘航程 " dst "%")
        ;             if(abs(dst) > 5 && abs(dst) < 15) {
        ;                 ShowTip("●[降落中] 剩餘航程 " dst "%, 即將著陸")
        ;             }

        ;             if(dst >= 3 && dst <= 3) {
        ;                 BnsActionAdjustDirection(40)
        ;             }
        ;             else if(abs(dst) < 1) {
        ;                 ShowTip("●[著陸] 命中目標")
        ;                 send {w up}
        ;                 send {space}
        ;                 sleep 2000
        ;                 return 1
        ;             }
        ;             ; GetMemoryHack().setPosition(,, -8620)   ;8666
        ;             GetMemoryHack().setPosition(,, 39975)     ;39916
        ;             dsleep(50)
        ;         }
        ;     }
        ; }
        ; return 1



;=================================== BnsInfo
        loop {
            memHack := GetMemoryHack()
            ; ShowTip("form: " memHack.getFormPosX())

            ShowTip(memHack.funcCheck(), 40, 50)
            ; ShowTip(memHack.getF8RoomNumber(), 40, 50)
            ; ShowTip("blood: " memHack.getMainTargetBlood() "`n過圖中: " ((memHack.getMainTargetBlood() == "" || memHack.getMainTargetBlood() == 0) ? 1 : 0))

            ; ShowTip("Bidding count: " BnsIsBidding())

            ; memHack.setPosition(memHack.getPosX(), memHack.getPosY() , memHack.getPosZ() - 50)

            ; ShowTip("name: " memHack.getName())
            ; ShowTip("distance: " BnsMeansureTargetDistDegree( -15712, 57864)[1] ", " BnsGetPosX() ", " BnsGetPosY() ", " BnsGetPosZ())
            ; ShowTipD("isNpcTalking: " BnsIsNpcTalking() ", " BnsIsMapLoading())
            ; ShowTipD("isAutoCombat: " memHack.getAutoCombatState())
            ; ShowTip(memHack.infoDump(1))
            ; ShowTipD(memHack.infoDump(2))
            ; ShowTipD("isDead: " (memHack.getPosture() == 1)); ShowTipD("Posture: " memHack.getPosture())
            ; ShowTipD("isBattle: " memHack.isInBattling() ", isLeaveBattle: " BnsIsLeaveBattle())
            ; ShowTipD("Target: " memHack.getMainTargetName())
            ; ShowTipD("isDead: " BnsIsCharacterDead() ", posture: " GetMemoryHack().getPosture())
            ; ShowTipD("HP: " memHack.getHpValue())
            ; ShowTipD("Speed " memHack.getSpeed())
            ; ShowTipD("room:" memHack.getF8RoomNumber())
            ; ShowTipD("talk:" memHack.isAvailableTalk())
            ; ShowTipD("blood:" memHack.getMainTargetBlood() "`n" memHack.infoDump(3))
            ; blood := memHack.getMainTargetBlood()
            ; pecent := floor(memHack.getMainTargetBlood() / 6520000000 * 100)
            ; ShowTipD("BOSS: " blood "(" pecent  "%)" )
            dsleep(200)
        }

;=================================== 領符
        ; loop {
        ;     MouseClick left, 576, 265
        ;     sleep 1000
        ;     MouseClick left, 605, 845
        ;     sleep 500
        ;     Send {y}
        ;     sleep 7000
        ; }

        ; return 1

;=================================== 找基址一個一個點

        ; loop {
        ;     send {down}
        ;     sleep 30
        ;     send {F5}
        ;     sleep 1000
        ;     send {enter}
        ;     sleep 30
        ;     send {enter}
        ;     sleep 30

        ; }


;=================================== 樂師
        ; scroll := "5,500;3,500;3,1000;4,500;2,500;2,1000;1,500;2,500;3,500;4,500;5,500;5,500;5,500;"
        ; scroll := "1,500;2,500;3,500;4,500;5,500;6,500;7,200;r,300;1,500;2,500;3,500;4,500;5,500;6,500;7,200;r,300;1,500;"+789    \        ; scroll := "6,300;2,300;2,300;6,300;5,600;4,250;3,900;; 1,300;1,300;1,600;1,300;L,300;6,250;R,250;2,600;;2,300;3,300;4,300;4,300;4,300;2,300;1,300;2,200;L,250;5,250;R,300;1,350;L,250;6,300"
        ; scroll := "2,300;3,300;4,300;4,300;4,300;2,300;1,300;2,200;L,250;5,250;R,300;1,350;L,250;6,300"

        ; ; 萬里の長城
        ; scroll := "2,300;4,300;5,600;6,600;2,600;1,600;2,600;0,600;;2,300;4,300;5,600;6,600;5,200;R,400;1,200;L,400;6,600;0,600;;2,300;4,300;5,600;6,600;2,600;1,600;2,600;0,800;;L,400;6,200;R,300;1,600;2,600;4,600;3,200;4,200;3,300;2,300;1,600;2,600"

        ; scroll := RegExReplace(scroll, "5,", "z,")
        ; scroll := RegExReplace(scroll, "6,", "x,")
        ; scroll := RegExReplace(scroll, "7,", "c,")
        ; scroll := RegExReplace(scroll, "L,", "LButton,")
        ; scroll := RegExReplace(scroll, "R,", "RButton,")


        ; ShowTipD( scroll )

        ; nodes := StrSplit(scroll, ";", "`r`n")

        ; loop 100 {+789]\        ;     node := StrSplit(nodes[A_index], ",", "`r`n")wert   qwert   qwertiopuy[iopuy[iopu+7899]\
        ;     ShowTipD(A_ndex " node=" node[1] ", t=" node[2])

        ;     key := node[1]

        ;     if( key == "RButton" ) {
        ;         DllCall("mouse_event", "UInt", 0x0008, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
        ;         send { %key% Down }
        ;         dsleep(60)
        ;         keywait RButton, "D"
        ;         send { %key% Up }
        ;         DllCall("mouse_event", "UInt", 0x0010, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
        ;         keywait RButton
        ;     }
        ;     else if (key == "LButton" ) {
        ;         DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
        ;         dsleep(60)
        ;         ;keywait LButton, "D"
        ;         DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
        ;         keywait LButton
        ;     }
        ;     else {
        ;         send { %key% }
        ;     }

        ;     dsleep(node[2])
        ; }
        ; return 1

    }

    return testMode
}


;================================================================================================================
;================================================================================================================
;    Main
;================================================================================================================
main() {
    onStart()

    if(v_Enable == 1) {
        onInit()
        sleep 300
    }
    if(DBUG == 1) {
        ShowTipD("[System] Scritp flag:" v_Enable)
        sleep 500
    }

    if(v_Enable == 0) {
        onReset()                        ;重設腳本
        onDestory()

        return
    }


    ShowTipI("●[System] - Staring...")
    if(singleStepTest() == 1) {
        onDestory()
        return
    }


    ; sleep 40 * 60 * 1000

    loop
    {
        DumpLogI("[Script] Start Next Round -------------------------------------")

        if(EngageDungeon() == 0) {
            break
        }

        sleep 3000
    }

    onFinish(ERR_CAUSE)
    return
}


;================================================================================================================
;================================================================================================================
;    Preloader
;================================================================================================================
;================================================================================================================

#MaxThreadsPerHotkey 2              ;設置從此開始為 multi-thread (最大2個thead)
SetKeyDelay, 36, 36                 ;設置滑鼠點擊
SetMouseDelay, 36                   ;設置滑鼠移動之後到點擊間的delay時間, 防止 MouseClick 之類包含移動的點擊沒反應
global v_Enable := 0                ;腳本啟動狀態
global v_Pause :=0                  ;腳本暫停狀態
SetBatchLines, -1                   ;腳本多久讓出 CPU 時間, 可設為 ms 或是 line, ex: SetBatchLines, 20ms  or SetBatchLines, 1000, -1 表示全速


;以管理者權限執行
if(!A_IsAdmin) {
    Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
    ExitApp
 }

; ImportExternIniConfig()        ;載入外部 ini 設置, 取得 Hotkey 設定鍵(這邊需要 Reload 才會套用)i
LoadExternIniConfig()

Hotkey, %HKEY%, main            ;主要啟動熱鍵
Hotkey, !%HKEY%, main           ;多加 alt 聯動，防止 alt 鍵壓住時沒反應

Hotkey, %PRKEY%, onPauseResume    ;暫停熱鍵

; singleStepTest()
; InitUiPosition()