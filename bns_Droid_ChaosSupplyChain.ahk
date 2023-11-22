#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;#include bns_common.ahk
#include bns_Droid_DungeonUtils.ahk

;================================================================================================================
;	Main
;================================================================================================================
BnsDroidRun_ChaosSupplyChain() {
	
	BnsActionFixWeapon()
	
	if(BnsDroidMission_CS_OpenGate() == 0) {
		return 0
	}

	if(BnsDroidMission_CS_KillBoss1() == 0) {
		return 0
	}

	if(BnsDroidMission_CS_KillBoss2() == 0) {
		return 0
	}

	sleep 3000
}

;================================================================================================================
;	Error
;================================================================================================================
BnsDroidMission_CS_Fail(ex) {
	ShowTipE("●[Exception] - " ex)
	CommonTimeout:=0
	sleep 1000
}


CS_TIMEOUT_NOTIFY_THREAD() {
	ShowTipE("[WS_TIMEOIT_NOTIFY_THREAD] Procedure Timeout！！！")
	CommonTimeout:=1
}



;================================================================================================================
;	Common
;================================================================================================================



;################################################################################################################
;================================================================================================================
;	Mission1 - Open Gate
;================================================================================================================
;################################################################################################################
BnsDroidMission_CS_OpenGate() {
	ShowTipI("●[Mission1] - Open Gate")

	BnsActionWalk(5500)
	BnsActionLateralWalkLeft(10000)
	BnsActionWalk(2700)
	BnsActionLateralWalkRight(2000)

	;等待聚怪
	sleep 200

	loop 5 {

		;自動戰鬥開啟
		BnsStartStopAutoCombat()
		sleep 5000

		;進入戰鬥
		if(BnsIsEnemyDetected() > 0) {
			ShowTipI("●[Mission1] - stage" A_index " Fighting")

			if(BnsIsEnemyClear(1000, 60) == 1) {
				sleep 100
				;自動戰鬥關閉
				BnsStartStopAutoCombat()

				ShowTipI("●[MissionA] - stage" A_index " Completed")
				sleep 1000
			}
			else {
				;2分鐘都無法接觸鎖定目標，角色卡住了
				BnsDroidMission_CS_Fail("stage" A_index " timeout")
				;ShowTip("●[Mission1] - Exception, no found gatekeeper")
				return 0
			}
		}
		else {
			sleep 100
			;自動戰鬥關閉
			BnsStartStopAutoCombat()

			;第一輪就找不到怪
			if(A_index == 1) {
				BnsDroidMission_CS_Fail("Not found enemy")
				;ShowTip("●[Mission1] - Exception, no found gatekeeper")
				return 0
			}

			;補正機制，自動戰鬥打漏回補會超過範圍，造成下一輪鎖不到怪，往前走再試著鎖定一次(通常是發生在一二群中間)
			if(A_index < 4) {
				BnsActionAdjustDirectionOnMap(90)
				sleep 100
				;BnsActionLateralWalkLeft(1500)
				BnsActionWalk(12000)
			}
		}
	}

	return 1
}


;################################################################################################################
;================================================================================================================
;	Mission2 - BOSS1
;================================================================================================================
;################################################################################################################
BnsDroidMission_CS_KillBoss1() {

	;等待守護石的加速結束
	sleep 5000

	;對準門口方向
	BnsActionAdjustDirectionOnMap(92)

	;校準點Y軸離地圖邊界位置為85
	BnsDroidAction_CS_MoveAdjustPosition(85)

	sleep 200
	BnsActionLateralWalkRight(6000)
	BnsActionLateralWalkLeft(830)

	if(BnsDroidAction_CS_AdjustGateDirection() == 0) {
		return 0
	}
	
    ;BnsActionWalk(6000)
	;BnsActionAdjustDirectionOnMap(90)

	;BnsActionWalk(15500)
	BnsActionWalk(11000)
	
	;預先面向樓梯側面移動, 到樓梯直接朝花媽前進
	BnsActionLateralWalkLeft(500)
	BnsActionAdjustDirectionOnMap(355)
	BnsActionLateralWalkLeft(5000)
	BnsActionWalk(4800)


	;自動戰鬥開啟, 清雜魚
	BnsStartStopAutoCombat()
	sleep 1000

	;進入戰鬥
	if(BnsIsEnemyDetected() > 0) {
		ShowTipI("●[Mission2] - stage1 Fighting")

		if(BnsIsEnemyClear(1000, 60) == 1) {
			
			;預留走回開戰點的時間(樓梯下)			
			sleep 4000
			
			;自動戰鬥關閉
			BnsStartStopAutoCombat()

			ShowTipI("●[Mission2] - stage1 Completed")
			sleep 1000
		}
		else {
			;1分鐘都無法接觸鎖定目標，角色卡住了
			BnsDroidMission_CS_Fail("stage1 timeout")
			;ShowTip("●[Mission1] - Exception, no found gatekeeper")
			return 0
		}
	}
	else {
		sleep 100
		;自動戰鬥關閉
		BnsStartStopAutoCombat()

		BnsDroidMission_CS_Fail("Not found enemy")
		;ShowTip("●[Mission1] - Exception, no found gatekeeper")
		return 0
	}

	;預防離太遠超過自動戰鬥範圍, 向右側移動
	;BnsActionLateralWalkRight(1000)
	BnsActionWalk(1300)
	

	;自動戰鬥開啟, 打花媽
	BnsStartStopAutoCombat()
	sleep 3000

	;進入戰鬥
	if(BnsIsEnemyDetected() > 0) {
		ShowTipI("●[Mission2] - stage2 Fighting")

		if(BnsIsEnemyClear(200, 60) == 1) {
			
			;預留撿箱時間
			sleep 1000
			
			;自動戰鬥關閉
			BnsStartStopAutoCombat()

			ShowTipI("●[Mission2] - stage2 Completed")
			sleep 1000
		}
		else {
			;2分鐘都無法接觸鎖定目標，角色卡住了
			BnsDroidMission_CS_Fail("stage2 timeout")
			;ShowTip("●[Mission1] - Exception, no found gatekeeper")
			return 0
		}
	}
	else {
		sleep 100
		;自動戰鬥關閉
		BnsStartStopAutoCombat()

		BnsDroidMission_CS_Fail("Not found enemy")
		;ShowTip("●[Mission1] - Exception, no found gatekeeper")
		return 0
	}


}

;----------------------------------------------------------------------------
;	Mission2 - 移動到校準點(能判斷出口的位置)
;----------------------------------------------------------------------------
BnsDroidAction_CS_MoveAdjustPosition(boundary) {
	DBG:=0
	dest:=0

	arrow := StrSplit(CHARACTER_ARROW_POSITION, ",", "`r`n")

	boundY:=0

	;降維掃描(加速定位)
	loop {
		boundY := A_index * 10
		gray:=GetPixelColorGray(arrow[1], arrow[2] - boundY)

		DumpLogD("boundY=" boundY ", gray level=" gray)

		if(gray < 60) {
			boundY := (A_index -1) * 10


			if(DBG == 2) {
				DumpLogD("stage1 boundY=" boundY)

				Send {alt down}
				sleep 200
				MouseMove arrow[1], arrow[2] - boundY
				sleep 5000
				Send {alt up}
				sleep 200
			}

			break
		}
	}

	;細部掃描(精確定位)
	loop {
		gray:=GetPixelColorGray(arrow[1], arrow[2] - (boundY + A_index))

		DumpLogD("boundY=" boundY + A_index ", gray level=" gray)

		if(gray < 60) {
			if(DBG == 2) {
				DumpLogD("stage2 boundY=" boundY + A_index)

				Send {alt down}
				sleep 200
				MouseMove arrow[1], arrow[2] - (boundY  + A_index)
				sleep 5000
				Send {alt up}
				sleep 200
			}

			dest := boundY + A_index
			break
		}
	}

	offset := dest - boundary
	
	if(offset > 0) {
		;離校準點太遠, 要前進
		;BnsActionAdjustDirectionOnMap(90)
		sleep 200
		BnsActionWalk(Abs(offset) * 240)
	}
	else if(offset < 0) {
		;離校準點太近, 要後退
		BnsActionAdjustDirectionOnMap(270)
		sleep 200
		BnsActionWalk(Abs(offset) * 240)
		sleep 200
		BnsActionAdjustDirectionOnMap(90)
	}

	return 1
}



;----------------------------------------------------------------------------
;	Mission2 - 出口方位校準
;----------------------------------------------------------------------------
BnsDroidAction_CS_AdjustGateDirection() {
	DBG:=0

	BnsActionAdjustCamaraZoom(8)
	BnsActionAdjustCamaraAngle(-50,8)

	;找出口左邊門框黑色
	sX:= WIN_CENTER_X - (WIN_BLOCK_WIDTH * 3)
	sY:= WIN_BLOCK_HEIGHT * 2
	eX:= WIN_CENTER_X + (WIN_BLOCK_WIDTH * 3)
	
	;降素掃描
	xScan:= (eX - sX) / 3

	loop 30 {
		leftSide:=0
		rightSide:=0

		loop %xScan% {
			;先掃出出口的左右邊框

			pX:=sX + A_index * 3
			gray:=GetPixelColorGray(pX, sY)
			
			if(DBG == 2) {
				ShowTip("↖" gray, pX, sY + 10)
			}

			if(gray > 11 && gray < 18)
			{
				;再採樣另一垂直點，判定是否為門框
				gray:=GetPixelColorGray(pX, sY + 5)
				if(DBG >= 1) {
					DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] get px:" px ", gray:" gray)
				}
				
				if(gray < 12 || gray > 17) {
					continue
				}
			
				if(leftSide == 0) {
					leftSide := pX

					if(DBG >= 1) {
						DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] get leftSide:" leftSide)
					}

					if(DBG == 2) {
						send {alt down}
						sleep 200
						MouseMove pX, sY
						sleep 3000
						send {alt up}
						sleep 200
					}

				}
				else if((pX - leftSide) > (WIN_BLOCK_WIDTH * 1.8))
				{
					rightSide := pX

					if(DBG >= 1) {
						DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] get rightSide:" rightSide)
					}
					
					if(DBG == 2) {
						send {alt down}
						sleep 200
						MouseMove pX, sY
						sleep 3000
						send {alt up}
						sleep 200
					}

					break
				}
			}
			
		}

		if(DBG >= 1) {
			DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] leftSide:" leftSide ", rightSide:" rightSide)
		}

		if(leftSide > WIN_CENTER_X || rightSide == 0) {
			;門在偏右邊，要向右轉
			BnsActionRotationRightAngle(3)
		}
		else if(rightSide != 0 && rightSide < WIN_CENTER_X) {
			;門在偏左邊，要向左轉
			BnsActionRotationLeftAngle(3)
		}
		else {
			;已經對準出口
			cDoor := leftSide + (rightSide - leftSide) / 2

			if(DBG >= 1) {
				DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] cDoor:" cDoor)
			}

			if(DBG == 2) {
				send {alt down}
				sleep 200
				MouseMove cDoor, sY
				sleep 3000
				send {alt up}
				sleep 200
			}

			if(WIN_CENTER_X - cDoor > (WIN_BLOCK_WIDTH * 0.3)) {
				BnsActionRotationLeftAngle(1)
			}
			else if(cDoor - WIN_CENTER_X > (WIN_BLOCK_WIDTH * 0.3)) {
				BnsActionRotationRightAngle(1)
			}
			else {
				DumpLogD("[BnsDroidAction_CS_AdjustGateDirection] adjuset center of gate")
				return 1
			}
		}

		sleep 200
	}

	return 0
}



;################################################################################################################
;================================================================================================================
;	Mission3 - BOSS2
;================================================================================================================
;################################################################################################################
BnsDroidMission_CS_KillBoss2() {
	;走道導航
	BnsActionAdjustDirectionOnMap(355)
	sleep 200
	BnsActionLateralWalkRight(300)
	sleep 200
	BnsActionWalk(12000)
	sleep 200
	
	BnsActionAdjustDirectionOnMap(270)
	sleep 200
	BnsActionLateralWalkRight(900)
	sleep 200
	
	BnsActionWalk(8000)
	sleep 200
	
	
	loop 3 {

		;自動戰鬥開啟
		BnsStartStopAutoCombat()
		sleep 5000

		;進入戰鬥
		if(BnsIsEnemyDetected() > 0) {
			ShowTipI("●[Mission3] - stage" A_index " Fighting")

			if(BnsIsEnemyClear(800, 60) == 1) {
				sleep 100
				;自動戰鬥關閉
				BnsStartStopAutoCombat()

				ShowTipI("●[Mission3] - stage" A_index " Completed")
				sleep 1000
			}
			else {
				;2分鐘都無法接觸鎖定目標，角色卡住了
				BnsDroidMission_CS_Fail("stage" A_index " timeout")
				;ShowTip("●[Mission1] - Exception, no found gatekeeper")
				return 0
			}
		}
		else {
			sleep 100
			;自動戰鬥關閉
			BnsStartStopAutoCombat()

			;第一輪就找不到怪
			if(A_index == 1) {
				BnsDroidMission_CS_Fail("Not found enemy")
				;ShowTip("●[Mission1] - Exception, no found gatekeeper")
				return 0
			}

			;補正機制，自動戰鬥打漏回補會超過範圍，造成下一輪鎖不到怪，往前走再試著鎖定一次(通常是發生在一二群中間)
			if(A_index < 4) {
				BnsActionAdjustDirectionOnMap(3)
				sleep 100
				BnsActionWalk(10000)
			}
		}
	}
	
	;傳點後導航
	BnsActionAdjustDirectionOnMap(3)
	sleep 100
	BnsActionWalk(12000)
	BnsActionLateralWalkRight(8000)
	BnsActionWalk(7000)



	;----- 對戰最終BOSS -----------------------------------------------------------------------------------------------------
	;自動戰鬥開啟
	BnsStartStopAutoCombat()
	sleep 5000


	;進入戰鬥
	if(BnsIsEnemyDetected() > 0) {
		ShowTipI("●[Mission3] - stage Fighting")

		;啟動非同步計時，時間到放技能
		SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, 4300

		if(BnsIsEnemyClear(5000, 600) == 1) {
			;註消計時器
			SetTimer, CS_FINAL_FIGHTING_SKILL_THREAD, delete

			;預留撿箱時間
			sleep 2000

			;自動戰鬥關閉
			BnsStartStopAutoCombat()

			ShowTipI("●[Mission3] - stage Completed")
			sleep 1000
		}
		else {
			;10分鐘都無法接觸鎖定目標，角色卡住了
			BnsDroidMission_CS_Fail("stage timeout")
			;ShowTip("●[Mission1] - Exception, no found gatekeeper")
			return 0
		}
	}
	else {
		sleep 100
		;自動戰鬥關閉
		BnsStartStopAutoCombat()

		;第一輪就找不到怪
		if(A_index == 1) {
			BnsDroidMission_CS_Fail("Not found enemy")
			;ShowTip("●[Mission1] - Exception, no found gatekeeper")
			return 0
		}
	}

	;等待脫戰
	sleep 2000

	return 1
}


;----------------------------------------------------------------------------
;	Mission2 - 自動戰鬥輔助使用技能(非同步計時)
;----------------------------------------------------------------------------
CS_FINAL_FIGHTING_SKILL_THREAD() {
	;劍士專用
	loop, 1 {
		;一閃位移(躲地火)
		Send {v}
		sleep 100

		;放雷斬, 倒地格擋(炸飛後地上等LL下來，不要再踩地火)
		Send {4}
		sleep 100

		;放掉御劍飛散, 放地裂
		Send {z}
		sleep 100
		
		;放星
		Send {``}
		sleep 100
	}

}