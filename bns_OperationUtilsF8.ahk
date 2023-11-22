#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



global FIRST_OPTION_Y:=365		;手工計算
global OPTION_HIGHT:=32			;手工計算


global tabDungeonX:=
global tabDungeonY:=

global btnStartX:=
global btnStartY:=


global ArrHeroPreviews:=Array()
global ArrAerodromePreviews:=Array()

global CONFUSE_PROTECT:=1

;================================================================================================================
;	Common
;================================================================================================================
BnsF8Init() {
	;建立 f8 副本列表預覽地圖(Hero本時double check用, Aerodrome本用來選取副本)
	;封魔本出了之後 Hero 本有問題，待修
	loop, 10 {
		ArrHeroPreviews.push("empty" A_index)
	}

	ArrHeroPreviews.push("pic_f8_dungeon_preview_ghostface")	;11, 鬼面是列表上第11個(不算活動本)
	ArrHeroPreviews.push("")
	ArrHeroPreviews.push("pic_f8_dungeon_preview_sendstorm")	;13, 沙暴是列表上第13個(不算活動本)


	ArrAerodromePreviews.push("empty" 1)										;1, 
	ArrAerodromePreviews.push("empty" 1)										;2,
	ArrAerodromePreviews.push("pic_f8_dungeon_preview_ChaosSupplyChain1")		;3, 
}

;================================================================================================================
;	OPERATION - Go to F8 Dungeon Lobby from earth
;================================================================================================================
BnsEarthGoF8Lobby() {
	;按下 F8
	Send, {F8}
	sleep 200

	sx := floor(WIN_CENTER_X - WIN_BLOCK_WIDTH * 2.8)
	sy := floor(WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 2.3 + 32)
	rw := floor(WIN_BLOCK_WIDTH * 2.8)
	rh := floor(WIN_BLOCK_HEIGHT * 2.3)
	val := GetTextOCR(sx, sy, rw, rh, res_game_window_title)	; PaddleOCR 注意參數皆需要 int, 否則報錯

	if(val == res_sys_f8_unicom_dungeon_card_title) {
		MouseClick, left, sx + rw * 0.5, sy + rh * 0.5
		sleep 3000
		
		return BnsF8LobbyWaitingReady()
	}
	else {
		return 255
	}

}

BnsEarthGoF8LobbyPic() {
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

		return BnsF8LobbyWaitingReady()
	}
	else {
		return 255
	}
}

;================================================================================================================
;	OPERATION - Go back to F8 hall from dungeon
;================================================================================================================
BnsGobackF8Lobby() {
	
	;先接收任務獎勵
	;Esc 叫系統選單
	Send {Esc}
	sleep 200
	
	if(FindPicList(WIN_THREE_QUARTERS_X, WIN_THREE_QUARTERS_Y, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_f8_menu_exit") == 1) {
		exitX := findX + WIN_BLOCK_WIDTH * 0.3
		exitY := findY + WIN_BLOCK_HEIGHT * 0.07
		
		MouseMove exitX, exitY
		sleep 200
		
		click
		sleep 200

		Send y
		sleep 2000

		if(FindPicList(WIN_CENTER_X, WIN_CENTER_Y, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_reward_button") == 1) {
			
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
		
	
		return BnsF8LobbyWaitingReady()
		
	}
	
	return 0
}


;================================================================================================================
;	OPERATION - enter room and team party 
;================================================================================================================
BnsRoomTeamUp() {
	partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")

	members := partyCtrl[1] - 1
	memberTp := partyCtrl[2]
	leaderId := partyCtrl[3]

	if(DBUB == 1) {
		DumpLogD("[BnsRoomTeamUp] members:" members ", memberTp:" memberTp ", leaderId:" leaderId)
	}

	if(members > 1 ) {
		DumpLogI("[BnsRoomTeamUp] Enabled team work!")
	}
	else {
		return 0
	}

	switchDesktopByNumber(leaderId)
	sleep 1000

	WinActivate, %res_game_window_title%
	roomId := BnsGetRoomNumber()

	if(roomId == "") {
		DumpLogE("[BnsRoomTeamUp] OCR room number failed")
		return 0
	}

	loop, %members% {
		member := partyCtrl[3 + A_index]
		switchDesktopByNumber(member)
		sleep 1000
		WinActivate, %res_game_window_title%
		BnsEnterRoomAndReady(roomId)
		sleep 1000
	}

	switchDesktopByNumber(leaderId)
	sleep 1000

	return 1
}


BnsGetRoomNumber() {
	return GetTextOCR(170, 50, 100, 30, res_game_window_title)
}



BnsEnterRoomAndReady(number) {
	MouseClick, left, WIN_THREE_QUARTERS_X , WIN_THREE_QUARTERS_Y
	sleep 1000
	Send {F8}
	sleep 1000
	Send %number%
	sleep 500
	Send {Enter}
	sleep 2000

	;Tap Ready Button
	BnsF8TapStartButton()
	sleep 1000

	loop, 3 {
		btnText := GetTextOCR(WIN_CENTER_X - WIN_BLOCK_WIDTH, WIN_HEIGHT - WIN_BLOCK_HEIGHT, WIN_BLOCK_WIDTH * 2, WIN_BLOCK_HEIGHT, res_game_window_title)
		DumpLogD("[BnsEnterRoomAndReady] button text:" btnText)

		if(btnText == res_lobby_btn_member_cancel) {
			DumpLogD("[BnsEnterRoomAndReady] prepare ready!!")
			return 1
		}
		else {
			DumpLogD("[BnsEnterRoomAndReady] retry " A_index " tap ready button")
			BnsF8TapStartButton()
		}
		sleep 1000
	}

	DumpLogE("[BnsEnterRoomAndReady] Error! failed to prepare ready")
	return 0
}


;================================================================================================================
;	OPERATION - locat direct start button(deactive)
;================================================================================================================
BnsF8SearchDeactiveStartButton(){
	;定位出發按鈕
	if(FindPicList(WIN_CENTER_X, WIN_THREE_QUARTERS_Y, WIN_THREE_QUARTERS_X, WIN_HEIGHT, 80, "res\pic_f8_button_dungeon_start_deactive") == 1) {
		global btnStartX := findX + WIN_BLOCK_WIDTH * 0.8
		global btnStartY := findY + WIN_BLOCK_HEIGHT * 0.3

		DumpLogD("[BnsF8SearchDeactiveStartButton] btn start_deactive x:" btnStartX ", y:" btnStartY)

		return 1
	}
	else {
		ShowTipE("●[Operating] - Exception: locate dungeon start button failed")
		return 0
	}
}


;================================================================================================================
;	OPERATION - Tap direct start button
;================================================================================================================
BnsF8TapStartButton() {
	loop, 3 {	;多次點擊, 以防遊戲沒有響應
		MouseClick left, WIN_CENTER_X + WIN_BLOCK_WIDTH, WIN_HEIGHT - WIN_BLOCK_HEIGHT * 0.5
		sleep 100
	}
}


;================================================================================================================
;	OPERATION - Select party mode tab
;================================================================================================================
;easy
BnsF8SelectPartyModeEasy() {
	;TODO: 入門沒東西是要掛個啥
}

;normal
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


BnsF8SelectHeroDungeon(index, scroll) {
	;先定位出發按鈕
	if(BnsF8SearchDeactiveStartButton() == 0) {
		DumpLogE("[BnsF8SelectHeroDungeon] can't find start button!")
		return 0
	}

	DumpLogD("[BnsF8SelectHeroDungeon] tab_dungeon x:" tabDungeonX ", y:" tabDungeonY)

	;尋找副本清單項目
	loop, 3 {
		if(tabDungeonX != 0 && tabDungeonY !=0) {
			click
			sleep 100
			
			;先定位副本tab，再移動到副本列表第 index 列
			oX:=tabDungeonX + 100
			oY:=tabDungeonY + FIRST_OPTION_Y + ((index - 1) * OPTION_HIGHT)
			
			;loop, 3 {
				DumpLogD("[BnsF8SelectHeroDungeon] option x:" oX ", y:" oY " [index:" index ", FIRST_OPTION_Y:" FIRST_OPTION_Y ", OPTION_HIGHT:" OPTION_HIGHT "]")
				MouseMove oX, oY
				sleep 100
				MouseGetPos, xpos, ypos 	
				DumpLogD("[BnsF8SelectHeroDungeon] get pos x:" xpos ", y:" ypos )
				
				;if(Abs(oy - ypos) < 2) {	;檢查是否確實點到想要的位置, 沒有就重做
				;	break
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
			if(ArrHeroPreviews[prevIndex] != "") {	;擁有圖資才執行確認
				if(FindPicList(WIN_THREE_QUARTER_X, WIN_QUARTER_Y, WIN_WIDTH, WIN_CENTER_Y, 80, "res\" ArrHeroPreviews[prevIndex]) != 1) {

					DumpLogI("[BnsF8SelectHeroDungeon] index:" index ", scroll:" scroll ", select incorrect, re-work!")
					continue
				}

				DumpLogI("[BnsF8SelectHeroDungeon] index:" index ", scroll:" scroll ", select success!")
			}

			return 1
		}
	}

	DumpLogE("[BnsF8SelectHeroDungeon] index:" index ", scroll:" scroll ", tab_dungeon not located!!")

	return 0
}


BnsF8SelectDemonsbaneDungeon(level, index, scroll) {
	;選擇副本
	;if(FindPicList(WIN_QUARTER_X, WIN_CENTER_Y, WIN_WIDTH, WIN_HEIGHT, 150, "res\"ArrAerodromePreviews[index]) == 1) {
	;	loop, 3 {
	;		MouseClick, left, findX + WIN_BLOCK_WIDTH * 0.3, findY + WIN_BLOCK_HEIGHT * 0.3
	;		sleep 500
	;	}
	;	sleep 1000
	;}
	;else {
	;	DumpLogE("[BnsF8SelectDemonsbaneDungeon] index:" index ", scroll:" scroll ", select incorrect!")
	;	return 0
	;}
	
	;選擇副本(座標定位)
	loop, 3 {
		MouseClick, left, WIN_THREE_QUARTERS_X + WIN_BLOCK_WIDTH * 4, WIN_CENTER_Y - (WIN_BLOCK_HEIGHT * 0.15) + (WIN_BLOCK_HEIGHT * index)
		sleep 500
	}

	;點擊段數
	MouseClick, left, WIN_CENTER_X + WIN_BLOCK_WIDTH * 13,  WIN_CENTER_Y - WIN_BLOCK_HEIGHT * 1.3
	sleep 1000
	
	;輸入段數
	Send {Shift down}{Right 3}{Shift up}
	sleep 500
	Send %level%
	sleep 1000

	DumpLogI("[BnsF8SelectDemonsbaneDungeon] index:" index ", scroll:" scroll ", level:" level ", select Success!")

	return 1
}



;================================================================================================================
;	OPERATION - Wait loading before go into dungeon
;================================================================================================================
BnsF8LobbyWaitingReady() {
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


