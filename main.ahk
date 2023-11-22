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
global DBUG := 1
global LOGABLE := 4        ;1:only Error, 2:E|Warning, 3:E|W|Debug, 4:all

;---系統環境設定---
;劍靈設定 界面大小85, 橫軸速度:60, 縱軸速度:60

;(覆寫 common.ahk 預設值)
global WIN_WIDTH := 1920                ;視窗的寬度 pixel
global WIN_HEIGHT := 1080 + 30          ;視窗的高度 pixel (需補上標題列的高度)



;---F8副本選單設定---
;(覆寫 bns_DungeonDispater.ahk 預設值)
global ACTIVITY:=1         ;當前活動副本(入門才會有)        
global PARTY_MODE:=2       ;組隊模式: 1:入門, 2:一般, 3:困難


;-------------------------
; 001 - 天之盆地鑰匙        - 地表
; 101 - 鬼怪村活動          - 地表
; 102 - 紅絲倉庫            - 地表
; 103 - 可疑的空島          - F8
; 104 - 巨神之心            - F8
; 201 - 鬼面劇團            - 地表
; 202 - 沙暴神殿            - f8
; 203 - 青空船              - f8
; 204 - 混沌補給基地        - f8
global DUNGEON_INDEX:=102           ;最後會被 config.ini 複蓋


;---地表副本選單設定---

;================================================================================================================
;    ACTION - Go into dungeon - Ghost Face
;================================================================================================================
EngageDungeon() {
    return BnsDungeonManager.dungeonRun(DUNGEON_INDEX)
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
        droid := new BnsDroidChaosBlackShenmu()

        ; droid.circledAroundAltar(-360,1)
        ; droid.runStageClearAltar()
        ; droid.navigateToFinalBoss()

        ; ShowTipI("find way:" droid.judgeVine())


        ; sleep 3000

        ; return 1
        


        BnsActionAdjustDirection(90)

        loop {
            memHack := GetMemoryHack()
            ; ShowTipD("isAutoCombat: " memHack.getAutoCombatState())
            ; ShowTip(memHack.infoDump(1))
            ; ShowTipD(memHack.infoDump(2))
            ; ShowTipD("autocombat: " memHack.getAutoCombatState())
            ; ShowTipD("isDead: " (memHack.getPosture() == 1))
            ; ShowTipD("Posture: " memHack.getPosture())
            ; ShowTipD("isBattle: " memHack.isInBattling() ", isLeaveBattle: " BnsIsLeaveBattle())
            ; ShowTipD("Target: " memHack.getMainTargetName())
            ShowTipD("isDead: " BnsIsCharacterDead() ", posture: " GetMemoryHack().getPosture())
            ; ShowTipD("HP: " memHack.getHpValue())
            ; ShowTipD("Speed " memHack.getSpeed())
            ; ShowTipD("room:" memHack.getF8RoomNumber())
            ; ShowTipD("talk:" memHack.isAvailableTalk())
            ; ShowTipD("blood:" memHack.getMainTargetBlood() "`n" memHack.infoDump(3))
            ; blood := memHack.getMainTargetBlood()
            ; pecent := floor(memHack.getMainTargetBlood() / 6520000000 * 100)
            ; ShowTipD("BOSS: " blood "(" pecent  "%)" )
            sleep 100
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
        ; scroll := "1,500;2,500;3,500;4,500;5,500;6,500;7,200;r,300;1,500;2,500;3,500;4,500;5,500;6,500;7,200;r,300;1,500;"
        ; scroll := "6,300;2,300;2,300;6,300;5,600;4,250;3,900;; 1,300;1,300;1,600;1,300;L,300;6,250;R,250;2,600;;2,300;3,300;4,300;4,300;4,300;2,300;1,300;2,200;L,250;5,250;R,300;1,350;L,250;6,300"
        ; scroll := "2,300;3,300;4,300;4,300;4,300;2,300;1,300;2,200;L,250;5,250;R,300;1,350;L,250;6,300"
        
        ;萬里の長城
        ; scroll := "2,300;4,300;5,600;6,600;2,600;1,600;2,600;0,600;;2,300;4,300;5,600;6,600;5,200;R,400;1,200;L,400;6,600;0,600;;2,300;4,300;5,600;6,600;2,600;1,600;2,600;0,800;;L,400;6,200;R,300;1,600;2,600;4,600;3,200;4,200;3,300;2,300;1,600;2,600"
        
        ; scroll := RegExReplace(scroll, "5,", "z,")
        ; scroll := RegExReplace(scroll, "6,", "x,")
        ; scroll := RegExReplace(scroll, "7,", "c,")
        ; scroll := RegExReplace(scroll, "L,", "LButton,")
        ; scroll := RegExReplace(scroll, "R,", "RButton,")
    
        
        ; ShowTipD( scroll )
        
        ; nodes := StrSplit(scroll, ";", "`r`n")
        
        ; loop 100 {
            ; node := StrSplit(nodes[A_index], ",", "`r`n")

            ; ShowTipD(A_ndex " node=" node[1] ", t=" node[2])
            
            ; key := node[1]

            ; if( key == "RButton" ) {
                ; DllCall("mouse_event", "UInt", 0x0008, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
                ; send { %key% Down }
                ; sleep 60
                ; keywait RButton, "D"
                ; send { %key% Up }
                ; DllCall("mouse_event", "UInt", 0x0010, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
                ; keywait RButton
            ; }
            ; else if (key == "LButton" ) {
                ; DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
                ; sleep 60
                ;;keywait LButton, "D"
                ; DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
                ; keywait LButton
            ; }
            ; else {
                ; send { %key% }
            ; }

            ; sleep node[2]
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
;Start Key
;^F1::




; ImportExternIniConfig()        ;載入外部 ini 設置, 取得 Hotkey 設定鍵(這邊需要 Reload 才會套用)
LoadExternIniConfig()

Hotkey, %HKEY%, main        ;主要啟動熱鍵
Hotkey, !%HKEY%, main        ;多加 alt 聯動，防止 alt 鍵壓住時沒反應

Hotkey, %PRKEY%, onPauseResume    ;暫停熱鍵
