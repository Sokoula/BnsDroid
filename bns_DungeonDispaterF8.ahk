#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;!!!!!!!注意!!!!!!!!!!!!!!!!
;預設參數是以 劍靈 界面大小設為 80 為主，不同設定請重新校準(包含算座標及重新抓圖)
;main.ahk 有設定會覆寫這些值

global ACTIVITY:=0            ;當前活動副本(入門才會有)
global PARTY_MODE:=3        ;組隊模式: 1:入門, 2:一般, 3:困難 

global DEMONSBANE_LEVEL:=3    ;封魔錄等級            

global MISSION_ACCEPT := 0    ;是否需要與接廣場NPC交談並接任務

;global CONFUSE_PROTECT:=1

;================================================================================================================
;    ■ Hero Dungeon Loader - 英雄
;================================================================================================================
BnsGoDungeon_MoveIntoDungeon() {
    ;等待等候室到廣場讀圖完畢
    if(BnsWaitMapLoadDone() == 0) {
        BnsGobackF8Lobby()
    }
    sleep 3000

    ShowTipI("●[System] - Move from square into dungeon " tag "...")

    if(MISSION_ACCEPT == 0) {
        ;無需對話接任務, 直接進入副本

        ;輕功跑7秒(進傳點)
        ;BnsActionSprint(7000)
        if(CONFUSE_PROTECT == 1) {
            BnsMoveDungeon_RandomConfuseProtection(14000)
        }
    }
    else {
        ;先與NPC對話接任務, 再進入副本
        Send {w Down}
        Send {a Down}
        sleep 2300
        Send {a Up}
        sleep 1500
        Send {w Up}
        sleep 100
        
        Send {f}

        loop ,3 {
            sleep 1000
            Send {f}
        }
        Send {Esc}
        sleep 100

        Send {w Down}
        Send {d Down}
        sleep 3000
        Send {d Up}
        Send {w Up}
    }

    sleep 3000
    
    ;等待廣場進副本讀圖完畢
    if(BnsWaitMapLoadDone() == 0) {
        BnsGobackF8Lobby()
        return 0
    }

    return 1
}

;================================================================================================================
;    ■ Hero Dungeon Loader - 英雄
;================================================================================================================
BnsGoDungeon_HeroLoader(tag, mode, index) {
    ShowTipI("●[System] - Select Hero Dungeon" tag "...")
    DumpLogD("[BnsGoDungeon_HeroLoader] tag:'" tag "', index:" index ", scroll:" scroll)


    if(mode < 1 || mode > 3) {
        ShowTipE("●[Exception] Illegal party mode " mode ", unknown mode.")
        return 0
    }

    ;1: 英雄, 2:封魔
    BnsF8SelectPartyType(1)
    sleep 3500

    ;1: 入門, 2:一般, 3:熟練
    BnsF8SelectPartyMode(mode)
    sleep 3500

    ;計算副本清單捲動(單頁顯示為7個,滾輪一次替換一個)
    if(index > 7) {
        scroll := index - 7
        index := 7
    }

    ;尋找清單項目
    if(BnsF8SelectHeroDungeon(index, scroll) == 1) {
        sleep 1000
        
        ;點擊出發等候室倒數5秒
        BnsF8TapStartButton()
        sleep 5000

        return BnsGoDungeon_MoveIntoDungeon()
    }
    else {
        ShowTipE("●[Exception] - locate dungeon tab failed")
        return 0
    }
}


;================================================================================================================
;    ■ Demonsbane Dungeon Loader - 封魔錄
;================================================================================================================
BnsGoDungeon_DemonsbaneLoader(tag, level, index) {
    ShowTipI("●[System] - Select Aerodrome Dungeon " tag "...")
    DumpLogD("[BnsGoDungeon_DemonsbaneLoader] tag:'" tag "', level:" level ", index:" index ", scroll:" scroll)

    ;點擊封魔錄標籤
    BnsF8SelectPartyType(2)
    
    sleep 4000

    
    if(BnsF8SelectDemonsbaneDungeon(level, index, scroll) == 1) {
        sleep 1000
        
        ;點擊出發等候室倒數5秒
        BnsF8TapStartButton()
        sleep 5000


        return BnsGoDungeon_MoveIntoDungeon()
    }
    else {
        ShowTipE("●[Exception] - locate dungeon tab failed")
        return 0
    }

}


;================================================================================================================
;================================================================================================================
;    ■ 可疑的空島(活動) - SuspiciousSkyIsland
;================================================================================================================
;================================================================================================================
BnsGoDungeon_SuspiciousSkyIsland() {
    ;副本標籤, 副本難度(1,2,3), 選取項目
    return BnsGoDungeon_HeroLoader("SuspiciousSkyIsland", PARTY_MODE, 1)
}



;================================================================================================================
;================================================================================================================
;    ■ 沙暴神殿
;================================================================================================================
;================================================================================================================
BnsGoDungeon_SandstormTemple() {
    ;副本標籤, 副本難度(1,2,3), 選取項目
    return BnsGoDungeon_HeroLoader("SandstormTemple", PARTY_MODE, 12 + ACTIVITY)
}



;================================================================================================================
;================================================================================================================
;    ■ 青空流浪船 - WanderingShip(Aerodrome)
;================================================================================================================
;================================================================================================================
BnsGoDungeon_WanderingShip() {
    ;副本標籤, 副本難度(1,2,3), 選取項目
    return BnsGoDungeon_HeroLoader("WanderingShip", PARTY_MODE, 2 + ACTIVITY)
}


;================================================================================================================
;================================================================================================================
;    ■ 混沌補給基地 - ChaosSupplyChain
;================================================================================================================
;================================================================================================================
BnsGoDungeon_ChaosSupplyChain() {

    return BnsGoDungeon_DemonsbaneLoader("ChaosSupplyChain", DEMONSBANE_LEVEL, 4)
}


