#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

global HW_ExcuteRoundTimes := -1		;-1: unlimited
global HW_PickRewardsSecond := 4


;================================================================================================================
;	Main
;================================================================================================================
BnsDroidRun_HongsilWarehouse() {
	
	if(BnsDroidMission_HW_ClearB2HallWay() == 0) {
		return 0
	}


	if(BnsDroidMission_HW_ClearB3Corridor() == 0) {
		return 0
	}

	if(BnsDroidMission_HW_ClearB3BossRoom() == 0) {
		return 0
	}
	
	if(HW_ExcuteRoundTimes > 0) {
		ShowTipI("●[Mission] - execute round count: " HW_ExcuteRoundTimes)
		return 1
	}
	else if(HW_ExcuteRoundTimes != -1) {
		ShowTipI("●[Mission] - execute round done")
		return 0
	}

	return 1
}




;================================================================================================================
;	Error
;================================================================================================================
BnsDroidMission_HW_Fail(ex) {
	ShowTipE("●[Exception] - " ex)
	CommonTimeout:=0
	sleep 1000
}


HW_TIMEOIT_NOTIFY_THREAD() {
	ShowTipE("[GT_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
	CommonTimeout:=1
}



;################################################################################################################
;================================================================================================================
;	Mission1 - Clear B2 hallway
;================================================================================================================
;################################################################################################################
BnsDroidMission_HW_ClearB2HallWay(){
	ShowTipI("●[Mission1] - Clear B2 hallway")

	BnsActionWalk(20000)
	BnsActionWalk(2500)			;被打到進入戰鬥姿態會降跑速，補償損失時間
	
	;等待 B1 走廊的木頭人跟上
	ShowTipI("●[Mission1] - Stage1 - Waiting for pull enemy")
	sleep 5000

	;開啟自動戰鬥
	ShowTipI("●[Mission1] - Stage1 - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 1000

	while(BnsIsEnemyDetected() > 0) {
		sleep 100
	}

	;停止自動戰鬥
	ShowTipI("●[Mission1] - Stage1 - Auto combat stop")
	BnsStartStopAutoCombat()
		
	;等待 B2 小房間門後的木頭人集中
	ShowTipI("●[Mission1] - Stage2 - Waiting for pull back door enemy")
	sleep 15000

	;開啟自動戰鬥
	ShowTipI("●[Mission1] - Stage2 - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 1000

	while(BnsIsEnemyDetected() > 0) {
		sleep 200
	}

	;撿取戰勵品
	sleep 6000

	;停止自動戰鬥
	ShowTipI("●[Mission1] - Stage2 - Auto combat stop")
	BnsStartStopAutoCombat()

	ShowTipI("●[Mission1] - Completed")

	return 1
}



;################################################################################################################
;================================================================================================================
;	Mission2 - Clear B3 corridor
;================================================================================================================
;################################################################################################################
BnsDroidMission_HW_ClearB3Corridor(){
	ShowTipI("●[Mission1] - Clear B3 Corridor")
	
	sleep 1000
	
	BnsActionAdjustDirectionOnMap(6)
	sleep 1000

	if(BnsDroidAction_HW_SearchB3CorriderEntry() == 0) {
		return 0
	}

	BnsActionWalk(9000)


	;等待聚怪
	sleep 2000

	;開啟自動戰鬥
	ShowTipI("●[Mission2] - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 1000
	
	while(BnsIsEnemyDetected() > 0) {
		sleep 100
	}

	;撿箱預留時間
	sleep 5000

	;停止自動戰鬥
	ShowTipI("●[Mission2] - Auto combat stop")
	BnsStartStopAutoCombat()
	
	ShowTipI("●[Mission2] - Completed")
	

	return 1
}


;----------------------------------------------------------------------------
;	Mission2 - 移動角色回地圖中心
;----------------------------------------------------------------------------
BnsDroidAction_HW_AdjustToAlignCenter(){
	;DBG:=1
	dest:=0

	arrow := StrSplit(CHARACTER_ARROW_POSITION, ",", "`r`n")

	arrowY := arrow[2]

	loop, %arrowY% {
		gray:=GetPixelColorGray(arrow[1], arrow[2] - A_index)

		if(gray < 60) {

			if(DBG == 1) {
				ShowTipD("i=" A_index ", gray level=" gray)
				
				Send {alt down}
				sleep 200
				MouseMove arrow[1], arrow[2] - A_index
				sleep 5000
				Send {alt up}
				sleep 200
			}

			dest:=A_index
			break
		}

	}

	if(dest > 84) {
		ShowTipI("[BnsDroidAction_HW_AdjustToAlignCenter] dest=" dest ", lateral left")
		BnsActionLateralWalkLeft(Abs(dest - 84) * 160)
	}
	else if(dest < 84) {
		ShowTipI("[BnsDroidAction_HW_AdjustToAlignCenter] dest=" dest ", lateral right")
		BnsActionLateralWalkRight(Abs(dest - 84) * 150)		;向右橫移速度較快
	}
}


;----------------------------------------------------------------------------
;	Mission2 - 尋找走廊門口
;----------------------------------------------------------------------------
BnsDroidAction_HW_SearchB3CorriderEntry() {
	;擺盪限制
	swing:=1
	
	BnsDroidAction_HW_AdjustToAlignCenter()
	
	BnsActionAdjustCamara(-50, 7)
	
	;尋找門口右上方的單掛燈
	sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 8)
	sY:= WIN_BLOCK_HEIGHT * 0
	eX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 2)
	eY:= WIN_QUARTER_Y

	;校準中心
	OFFSET_CENTER_X:= WIN_CENTER_X - WIN_BLOCK_WIDTH * 4.7

	
	;先向右小轉，處理門只在右邊一點點避免繞整圈
	;DumpLogD("[BnsDroidAction_HW_SearchB3CorriderEntry] not found pattern, turn left to search")
	;BnsActionRotationRightAngle(8)
	
	loop, 40 {
		if(FindPixelRGB(sX, sY, eX, eY, 0xF0FFFF, 7) == 1) {
			DumpLogD("[BnsDroidAction_HW_SearchB3CorriderEntry] detect Entry, x:" findX ", y:" findY)

			if(Abs(swing) > 18) {
				;擺盪限制, 來回對不準6次便放行
				ShowTipD("[BnsDroidAction_HW_SearchB3CorriderEntry] targeted (swing)" )
				return 1
			}

			if(findX > OFFSET_CENTER_X + 10) {
				if((findX - OFFSET_CENTER_X) > WIN_BLOCK_WIDTH) {
					BnsActionRotationRightAngle(5)
				}
				else {
					BnsActionRotationRightPixel(1, 1)
					if(swing < 0) {
						swing:=(Abs(swing) + 1) * 1
						DumpLogD("[BnsDroidAction_HW_SearchB3CorriderEntry] swing  o---->, " swing)
					}
				}
				
			}
			else if(findX < OFFSET_CENTER_X - 10) {
				if((OFFSET_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
					BnsActionRotationLeftAngle(5)
				}
				else {
					BnsActionRotationLeftPixel(1, 1)
					if(swing > 0) {
						swing:=(Abs(swing) + 2) * -1
						DumpLogD("[BnsDroidAction_HW_SearchB3CorriderEntry] swing <----o, " swing)
					}
				}
			}
			else {
				ShowTipD("[BnsDroidAction_HW_SearchB3CorriderEntry] targeted")
				return 1
			}
		}
		else {
			DumpLogD("[BnsDroidAction_HW_SearchB3CorriderEntry] not found pattern, turn left to search")
			BnsActionRotationLeftAngle(45)
		}

		sleep 20
	}
	
	DumpLogE("[BnsDroidAction_HW_SearchB3CorriderEntry] search done, pattern not found.")
	return 0
}




;################################################################################################################
;================================================================================================================
;	Mission3 - Clear B3 boss room
;================================================================================================================
;################################################################################################################
BnsDroidMission_HW_ClearB3BossRoom(){

	BnsActionAdjustDirectionOnMap(6)
	sleep 1000

	if(BnsDroidAction_HW_SearchB3BossRoom() == 0) {
		return 0
	}

	BnsActionWalk(10500)
	BnsActionWalk(2000)			;被打到進入戰鬥姿態會降跑速，補償損失時間

	;等待 B3 Boss房的木頭人集中1
	ShowTipI("●[Mission3] - Stage1 - Waiting for pull enemy")
	sleep 5000
	
	;開啟自動戰鬥
	ShowTipI("●[Mission3] - Stage1 - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 1000
	

	if(BnsIsEnemyDetected() > 0) {
		sleep 100
	}

	sleep 500

	;停止自動戰鬥
	ShowTipI("●[Mission3] - Stage1 - Auto combat stop")
	BnsStartStopAutoCombat()




	;等待 B3 Boss房小房間門後的木頭人集中2
	ShowTipI("●[Mission3] - Stage2 - Waiting for pull back door enemy")
	sleep 13000

	;開啟自動戰鬥
	ShowTipI("●[Mission3] - Stage2 - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 1000
	
	if(BnsIsEnemyDetected() > 0) {
		sleep 100
	}


	sleep 500

	;停止自動戰鬥
	ShowTipI("●[Mission3] - Stage2 - Auto combat stop")
	BnsStartStopAutoCombat()

	;等待 B3 Boss房小房間門後的金木頭人集中3
	ShowTipI("●[Mission3] - Stage3 - Waiting for pull back door gold enemy")
	sleep 15000

	ShowTipI("●[Mission3] - Stage3 - Auto combat start")
	BnsStartStopAutoCombat()
	sleep 5000

	;偵測是否撿箱
	disengage:=HW_PickRewardsSecond

	while(disengage >= 0) {
		sleep 200

		disengage-=1

		;if(BnsIsEnemyDetected() > 0) {
		;	disengage:=HW_PickRewardsSecond
		;}
		
		if(BnsIsEnemyDetected() > 0 || FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_pick_box") == 1) {
			disengage:=HW_PickRewardsSecond * 5
			;disengage:=HW_PickRewardsSecond
		}

		Send {f}
		
		;msg:="●[Mission3]  - Stage3 - Out of battle count: "  disengage
		msg:="●[Mission3]  - Stage3 - Out of battle count: "  Ceil(disengage / 5)
		ShowTip(msg, 80, 10) 
	}

	;停止自動戰鬥
	ShowTipI("●[Mission3]  - Stage3 - Auto combat stop")
	BnsStartStopAutoCombat()
	
	ShowTipI("●[Mission3]  - Stage3 - Complete")

	if(BnsMapTeleport(1, WIN_BLOCK_WIDTH * 7.5, WIN_BLOCK_HEIGHT * 3.3) == 0) {
		return 0
	}
}


;----------------------------------------------------------------------------
;	Mission3 - 移動到走廊正中間
;----------------------------------------------------------------------------
BnsDroidAction_HW_AlignCenterB3BossRoom() {
	DBG:=0
	dest:=0

	arrow := StrSplit(CHARACTER_ARROW_POSITION, ",", "`r`n")
	
	arrowY:=arrow[2]
	
	loop, %arrowY% {
		gray:=GetPixelColorGray(arrow[1], arrow[2] - A_index)

		if(gray < 60) {

			if(DBG >= 1) {
				ShowTipD("i=" A_index ", gray level=" gray)
			}
			
			if(DBG == 2) {
				Send {alt down}
				sleep 200
				MouseMove arrow[1], arrow[2] - A_index
				sleep 5000
				Send {alt up}
				sleep 200
			}

			dest:=A_index
			break
		}

	}

	if(dest > 22) {
		DumpLogI("[BnsDroidAction_HW_SearchB3BossRoom] dest=" dest ", lateral left")
		BnsActionLateralWalkLeft(Abs(dest - 22) * 160)
	}
	else if(dest < 22) {
		DumpLogI("[BnsDroidAction_HW_SearchB3BossRoom] dest=" dest ", lateral right")
		BnsActionLateralWalkRight(Abs(dest - 22) * 150)
	}

	BnsActionLateralWalkRight(2 * 150)
}



;----------------------------------------------------------------------------
;	Mission3 - 尋找尾王房門口
;----------------------------------------------------------------------------
BnsDroidAction_HW_SearchB3BossRoom() {
	swing:=1

	;移動到走廊正中間
	BnsDroidAction_HW_AlignCenterB3BossRoom()

	;尋找尾王房的木頭人頭上紅色ID
	sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 7)
	sY:= 0
	eX:= WIN_CENTER_X
	eY:= WIN_CENTER_Y

	;校準中心
	OFFSET_CENTER_X := WIN_CENTER_X - WIN_BLOCK_WIDTH * 0.8
	
	loop, 40 {
		if(FindPixelRGB(sX, sY, eX, eY, 0xF36A56, 24) == 1) {
			DumpLogD("[BnsDroidAction_HW_SearchB3BossRoom] detect Entry, x:" findX ", y:" findY)

			if(Abs(swing) > 18) {
				;擺盪限制, 來回對不準6次便放行
				ShowTipD("[BnsDroidAction_HW_SearchB3CorriderEntry] targeted (swing)")
				return 1
			}

			if(findX > OFFSET_CENTER_X + 10) {
				if((findX - OFFSET_CENTER_X) > WIN_BLOCK_WIDTH) {
					BnsActionRotationRightAngle(5)
				}
				else {
					BnsActionRotationRightPixel(1, 1)
					if(swing < 0) {
						swing:=(Abs(swing) + 1) * 1
						DumpLogD("[BnsDroidAction_HW_SearchB3BossRoom] swing o---->, " swing)
					}
				}
			}
			else if(findX < OFFSET_CENTER_X - 10) {
				if((OFFSET_CENTER_X - findX) > WIN_BLOCK_WIDTH) {
					BnsActionRotationLeftAngle(5)
				}
				else {
					BnsActionRotationLeftPixel(1, 1)
					if(swing > 0) {
						swing:=(Abs(swing) + 2) * -1
						DumpLogD("[BnsDroidAction_HW_SearchB3BossRoom] swing <----o, " swing)
					}
				}
			}
			else {
				ShowTipD("[BnsDroidAction_HW_SearchB3BossRoom] targeted")
				return 1
			}
		}
		else {
			DumpLogD("[BnsDroidAction_HW_SearchB3BossRoom] not found pattern, turn left to search")
			BnsActionRotationRightAngle(10)
		}

		sleep 20
	}

	return 0
}