#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;!!!!!!!注意!!!!!!!!!!!!!!!!
;預設參數是以 劍靈 界面大小設為 80 為主，不同設定請重新校準(包含算座標及重新抓圖)
;main.ahk 有設定會覆寫這些值

global ACTIVITY:=0			;當前活動副本(入門才會有)
global PARTY_MODE:=3		;組隊模式: 1:入門, 2:一般, 3:困難 

global DEMONSBANE_LEVEL:=10			

;global CONFUSE_PROTECT:=1

;================================================================================================================
;	■ Hero Dungeon Loader - 英雄
;================================================================================================================
BnsGoDungeon_MoveIntoDungeon() {
	;等待等候室到廣場讀圖完畢
	if(BnsWaitMapLoadDone() == 0) {
		BnsGobackF8Lobby()
	}
	sleep 3000

	ShowTipI("●[System] - Move from square into dungeon " tag "...")

	;輕功跑7秒(進傳點)
	;BnsActionSprint(7000)
	if(CONFUSE_PROTECT == 1) {
		BnsMoveDungeon_RandomConfuseProtection(14000)
	}


	;等待廣場進副本讀圖完畢
	if(BnsWaitMapLoadDone() == 0) {
		BnsGobackF8Lobby()
		return 0
	}

	return 1
}

;================================================================================================================
;	■ Hero Dungeon Loader - 英雄
;================================================================================================================
BnsGoDungeon_HeroLoader(tag, mode, index, scroll) {
	;TODO:封魔錄出來後 英雄 副本大改版，這邊不再適用，待修
	
	global ACTIVITY
	global PARTY_MODE

	ShowTipI("●[System] - Select Hero Dungeon" tag "...")
	DumpLogD("[BnsGoDungeon_HeroLoader] tag:'" tag "', index:" index ", scroll:" scroll)

	;熟練 1: 入門, 2:一般, 3:熟練
	if(mode == 3) {
		BnsF8SelectPartyModeHard()
	}
	else if(mode == 2) {
		BnsF8SelectPartyModeNormal()
	}
	else if(mode == 1) {
		scroll += ACTIVITY	;入門要加上活動(沒人要打入門，這行是打心酸的)
	}
	else {
		ShowTipE("●[Exception] Illegal party mode " mode ", unknown mode.")
		return 0
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
;	■ Demonsbane Dungeon Loader - 封魔錄
;================================================================================================================
BnsGoDungeon_DemonsbaneLoader(tag, level, index, scroll) {
	ShowTipI("●[System] - Select Aerodrome Dungeon " tag "...")
	DumpLogD("[BnsGoDungeon_DemonsbaneLoader] tag:'" tag "', level:" level ", index:" index ", scroll:" scroll)

	;點擊封魔錄 TAB (相對座標計算，不靠擷圖)
	loop, 3 {
		MouseClick, left, WIN_CENTER_X + WIN_BLOCK_WIDTH * 13,  WIN_BLOCK_HEIGHT * 3.3
		sleep 200
	}
	
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
;	■ 鬼面劇團
;================================================================================================================
;================================================================================================================
BnsGoDungeon_GhostfaceTheater() {
	;副本標籤, 副本難度(1,2,3), 選取項目, 滾輪滾動次數
	return BnsGoDungeon_HeroLoader("GhostfaceTheater", PARTY_MODE, 4, 7)
}



;================================================================================================================
;================================================================================================================
;	■ 沙暴神殿
;================================================================================================================
;================================================================================================================
BnsGoDungeon_SandstormTemple() {
	;副本標籤, 副本難度(1,2,3), 選取項目, 滾輪滾動次數
	return BnsGoDungeon_HeroLoader("SandstormTemple", PARTY_MODE, 5, 8)
}



;================================================================================================================
;================================================================================================================
;	■ 青空流浪船 - WanderingShip(Aerodrome)
;================================================================================================================
;================================================================================================================
BnsGoDungeon_WanderingShip() {
	;副本標籤, 副本難度(1,2,3), 選取項目, 滾輪滾動次數
	return BnsGoDungeon_HeroLoader("WanderingShip", PARTY_MODE, 5, 8)
}


;================================================================================================================
;================================================================================================================
;	■ 混沌補給基地 - ChaosSupplyChain
;================================================================================================================
;================================================================================================================
BnsGoDungeon_ChaosSupplyChain() {

	return BnsGoDungeon_DemonsbaneLoader("ChaosSupplyChain", DEMONSBANE_LEVEL, 4, 0)
}


