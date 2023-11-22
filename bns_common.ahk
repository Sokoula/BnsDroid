#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;enemy region = sx, sy, width, height
global ENEMY_BOSS_LEVEL_REGION := 750,100,50,30
global ENEMY_ZAKO_LEVEL_REGION := 780,100,50,30

;blood region = sx, sy, width, height
global BLOOD_INDICATOR_REGION := 1315,960,10,10

;position = cx , cy
global CHARACTER_ARROW_POSITION := 1770,150

;hight speed role = 1
global HIGHT_SPEED_ROLE := 0

;role type = 0
global ROLE_TYPE := 0

;================================================================================================================
;	ACTION - Walk
;================================================================================================================
BnsActionWalk(ms) {
	if(HIGHT_SPEED_ROLE == 1) {
		ms := ms * 0.92
	}

	Send, {w Down}
	sleep %ms%
	Send, {w Up}
}



;================================================================================================================
;	ACTION - Run
;================================================================================================================
BnsActionSprint(ms) {
	if(HIGHT_SPEED_ROLE == 1) {
		ms := ms * 0.92
	}

	Send, {w Down}
	sleep 200
	Send {Shift}
	sleep ms
	Send, {w Up}
}


;================================================================================================================
;	ACTION - Lateral walk
;================================================================================================================
BnsActionLateralWalkLeft(ms) {
	if(HIGHT_SPEED_ROLE == 1) {
		ms := ms * 0.92
	}

	Send, {a Down}
	sleep %ms%
	Send, {a Up}
}


BnsActionLateralWalkRight(ms) {
	if(HIGHT_SPEED_ROLE == 1) {
		ms := ms * 0.92
	}

	Send, {d Down}
	sleep %ms%
	Send, {d Up}
}


;================================================================================================================
;	ACTION - Sprint jump
;================================================================================================================
BnsActionSprintJump(ms) {
	if(HIGHT_SPEED_ROLE == 1) {
		ms := ms * 0.92
	}

	;輕功跳
	Send, {w Down}
	Send, {Shift}
	sleep 200	;必需 > 200ms, 不然跳不起來
	Send, {Space Down}	;Space 必需拆開寫，不然沒作用
	sleep 50
	Send, {Space Up}
	sleep ms
	Send, {w Up}
}




;================================================================================================================
;	ACTION - Rotation body
;================================================================================================================
BnsActionRotationDuring(pxX, times) {

	if(DBG == 1) {
		ShowTipD("[BnsActionRotationDuring]" scrWidth "," scrHeight)
	}

	;滑鼠回到正中間	
	Send {Alt down}
	sleep 200

	MouseMove WIN_CENTER_X, WIN_CENTER_Y
	sleep 20

	Send {Alt up}
    sleep 200
	
	;橫移滑鼠轉向 負值:向左旋 正:向右旋
	loop %times% {
		MouseMoveR(pxX, 0)
		sleep 20
	}

	;滑鼠偏移補正
	;if( pxX > 0) {
	;	Send, {Right Down}
	;	sleep 10
	;	Send, {Right Up}
	;}
	;else {
	;	Send, {Left Down}
	;	sleep 10
	;	Send, {Left Up}
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
;	ACTION - Adjust direction on Map (大略位置)
;================================================================================================================
BnsActionAdjustDirectionOnMap(targetDegree) {
		DBG:=0
		arrow := StrSplit(CHARACTER_ARROW_POSITION, ",", "`r`n")
		block:=0

		DumpLogD("first round degrade search")

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

			;GetPixelColor(px, py)
			gray := GetPixelColorGray(px, py)
			blue := GetPixelColorBlue(px, py)
			
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

		DumpLogD("second round search")
		
		prevGray:=0
		leftEdge:=0
		rightEdge:=0
		
		;區域尋邊, 找出箭頭邊緣
		sDegree := block * 30 - 45
		
		r:=11
		loop 60 {
			px := arrow[1] + r * cos((sDegree + A_index * 2) * 3.1415926535 / 180)
			py := arrow[2] - r * sin((sDegree + A_index * 2) * 3.1415926535 / 180)

			gray := GetPixelColorGray(px, py)
			blue := GetPixelColorBlue(px, py)

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
;	ACTION - Adjuset camara angle
;================================================================================================================
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
		sleep 48
	}

	sleep 200
	
	loop %times% {
		MouseMoveR(0, pxY)
		sleep 48
	}
}


;================================================================================================================
;	ACTION - Auto combat
;================================================================================================================
BnsStartStopAutoCombat() {
	Send, <+{F4}	
}


BnsStartCheatEngineSpeed() {
	Send, {NumpadMult Down}
	sleep 100
	Send, {NumpadMult Up}
	DumpLogD("●[System] - CE Start")

	;loop, 3 {
	;	Send, {NumpadMult}
		;Send, ^{F11}
		;Send, {RCtrl Down} {F11} {RCtrl Up}
	;	sleep 200
	;}
}

BnsStopCheatEngineSpeed() {
	Send, {NumpadMult Down}
	sleep 100
	Send, {NumpadMult Up}
	DumpLogD("●[System] - CE Stop")

	;loop, 3 {
	;	Send, {NumpadMult}
		;Send, ^{F12}
		;Send, {RCtrl Down} {F12} {RCtrl Up}
	;	sleep 200
	;}
	
}


;================================================================================================================
;	ACTION - Leave party
;================================================================================================================
BnsIsPartyWork() {
	partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
	
	if(partyCtrl[1] > 1) {
		return partyCtrl[1]
	}

	return 0
}


;================================================================================================================
;	ACTION - Fix Weapon
;================================================================================================================
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
			send {5}	;TODO: set your key
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
;	ACTION - Back to Character Hall
;================================================================================================================
BnsSelectCharacter() {

	;Esc 叫系統選單
	Send {Esc}
	sleep 200
	
	if(FindPicList(WIN_THREE_QUARTERS_X, WIN_THREE_QUARTERS_Y, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_menu_select_character") == 1) {
		exitX := findX+20
		exitY := findY+5
		
		MouseMove exitX, exitY
		sleep 200
		
		click
		sleep 1000

		if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_btn_select_character") == 1) {
			MouseMove findX + 20, findY + 5
			sleep 200

			click
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
;	ACTION - Teleport on map
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
;	ACTION - Load map done
;================================================================================================================
BnsIsIntoMapLoad() {
	if(FindPixelRGB(0, WIN_THREE_QUARTERS_Y, 50, WIN_HEIGHT, 0x00D500, 10) == 1) {
		return 0
	}

	if(FindPixelRGB(0, WIN_THREE_QUARTERS_Y, 50, WIN_HEIGHT, 0xC38D06, 10) == 1) {
		return 0
	}

	return 1
}

;================================================================================================================
;	ACTION - Load map done
;================================================================================================================
BnsWaitMapLoadDone() {
	;偵測血條判定是否過圖完成
	ShowTipI("●[System] - Loading...")

	loop, 300 {
		
		if(BnsIsIntoMapLoad() == 0) {
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
;	ACTION - Check Enemy alive
;================================================================================================================
BnsIsEnemyDetected() {
	ret:=0

	if( BnsIsBossDetected() == 1) {
		ret := 1
		DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(BOSS)")
	}
	else if(BnsIsZakoDetected() == 1) {
		ret := 2
		DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(MOB)")
	}
	else {
		DumpLogD("[BnsIsEnemyDetected] Enemy detected: " ret "(NONE)")
	}

	return ret
}




BnsIsBossDetected() {	;主要Boss - 紅色
	ret:=0

	regions := StrSplit(ENEMY_BOSS_LEVEL_REGION, ",", "`r`n")

	sx := regions[1]
	sy := regions[2]
	width := regions[3]
	height := regions[4]

	;ShowTipD("[System] - BnsIsBossDetected sx:" sx + width * 0.7 ", sy:" sy ", ex:"  sx + width ", ey:" sy + height)

	isCheck1 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF0F0F0, 0x08)
	isCheck2 := FindPixelRGB(sx + width * 0.7, sy, sx + width, sy + height, 0xF2DA8A, 0x08)

	
	if(isCheck1 == 1 && isCheck2 == 1) {
		ret:=1
		
		if(DBUG == 1) {
			DumpLogD("[BnsIsBossDetected] BOSS detected!")
		}
	}

	return ret
}


BnsIsZakoDetected() {	;副Boss - 藍色
	ret:=0

	regions := StrSplit(ENEMY_ZAKO_LEVEL_REGION, ",", "`r`n")

	sx := regions[1]
	sy := regions[2]
	width := regions[3]
	height := regions[4]

	;ShowTipD("[System] - BnsIsZakoDetected sx:" sx ", sy:" sy ", ex:"  sx + width ", ey:" sy + height)

	isCheck1 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xF0F0F0, 0x08)	;高亮等級(比玩家等級高)
	isCheck2 := FindPixelRGB(sx, sy, sx + width, sy + height, 0xA9A9A9, 0x08) 	;低亮等級(比玩家等級低)
	isCheck3 := FindPixelRGB(sx + width * 0.7, sy, sx + width, sy + height, 0x828D9C, 0x08)
	
	if((isCheck1 == 1 || isCheck2 == 1 )&& isCheck3 == 1) {
		ret:=1

		if(DBUG == 1) {
			DumpLogD("[BnsIsBossDetected] ZAKO detected!")
		}
	}

	return ret
}


;================================================================================================================
;	ACTION - Check Enemy clear
;================================================================================================================
BnsIsEnemyClear(retain, timeout) {
	enemyCheck := 0
	;目標丟失容許時間(最小單位 ms)
	r := retain / 100
	;總超時時間(最小單位 s)
	t := timeout * 10

	loop, %t% {
		if(BnsIsEnemyDetected() == 0) {
			enemyCheck += 1
		}
		else {
			enemyCheck := 0
		}
		
		if(enemyCheck == r) {
			return 1
		}
		sleep 100
		
		if(A_index == (t * 0.8)) {
			BnsActionAdjustCamaraZoom(27)
		}
	}
	
	return 0
}


;================================================================================================================
;	ACTION - Check Character Death
;================================================================================================================
BnsIsCharacterDead() {
	ret := 0

	regions := StrSplit(BLOOD_INDICATOR_REGION, ",", "`r`n")

	sx := regions[1]
	sy := regions[2]
	width := regions[3]
	height := regions[4]

	loop, 3 {
		if(FindPixelRGB(sx, sy, sx + width, sy + height, 0xF27E32, 0x08) == 1) {
			ret := 0
			break
		}
		else {
			ret += 1
		}

		sleep 100
	}

	if(ret > 0) {
		if(DBUG == 1) {
			DumpLogD("[BnsIsCharacterDead] Charator Dead!")
		}

		return 1
	}

	return 0
}
