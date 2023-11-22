#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#include bns_common.ahk
#include bns_strings.ahk
#include bns_OperationUtilsF8.ahk
#include bns_DungeonDispaterF8.ahk
#include bns_DungeonNavigation.ahk
#include bns_Droid_CelestialBasinKeys.ahk
#include bns_Droid_GhostVillage.ahk
#include bns_Droid_HongsilWarehouse.ahk
#include bns_Droid_GhostfaceTheater.ahk
#include bns_Droid_SandstormTemple.ahk
#include bns_Droid_WanderingShip.ahk
#include bns_Droid_ChaosSupplyChain.ahk


;================================================================================================================
;	ACTION - Go into dungeon - Ghost Face
;================================================================================================================
DungeonSelecter(index) {
	ret:=1

	switch index
	{
		case 001:
			ret:=bns_DungeonProcess_CelestialBasinKeys()

		case 101:
			ret:=bns_DungeonProcess_GhostVillage()

		case 102:
			ret:=bns_DungeonProcess_HongsilWarehouse()

		case 201:
			ret:=bns_DungeonProcess_GhostfaceTheater()
			
		case 202:

		case 203:
			ret:=bns_DungeonProcess_WanderingShip()

		case 204:
			ret:=bns_DungeonProcess_ChaosSupplyChain()

	}

	return ret
}


;================================================================================================================
;	001 - CelestialBasinKeys - 天之盆地鑰匙(地表)
;================================================================================================================
bns_DungeonProcess_CelestialBasinKeys() {

	BnsDroidRun_CelestialBasinKeys()
	
	;BnsMoveDungeon_CelestialBasinKeys()
}



;================================================================================================================
;	101 - Ghost Village - 鬼怪村(活動地表)
;================================================================================================================
bns_DungeonProcess_GhostVillage() {
	if( BnsDroidRun_GhostfaceVillage() == 0) {
		;stop Droid internal.
		return 0
	}

	sleep 3000

	return BnsMoveDungeon_GhostVillage()
}


;================================================================================================================
;	102 - Hongsil's Secret Warehouse  - 紅絲秘密倉庫(活動地表)
;================================================================================================================
bns_DungeonProcess_HongsilWarehouse() {

	if(BnsMoveDungeon_HongsilWarehouse() == 0) {
		return 0
	}

	sleep 3000

	return BnsDroidRun_HongsilWarehouse()
	
}


;================================================================================================================
;	201 - GhostfaceTheater - 鬼面劇團(地表)
;================================================================================================================
bns_DungeonProcess_GhostfaceTheater() {
	BnsDroidRun_GhostfaceTheater()

	;BnsGoDungeon_GhostfaceTheater()
	BnsMoveDungeon_GhostfaceTheater()

	;BnsGobackF8Lobby()
}

;================================================================================================================
;	202 - SandstormTemple - 沙暴神殿(F8)
;================================================================================================================
;bns_DungeonProcess_SandstormTemple() {
;	BnsDroidRun_GhostfaceTheater()

	;BnsGoDungeon_GhostfaceTheater()
;	BnsMoveDungeon_GhostfaceTheater()

	;BnsGobackF8Lobby()
;}


;================================================================================================================
;	203 - WanderingShip - 青空流浪船(F8)
;================================================================================================================
bns_DungeonProcess_WanderingShip() {

	BnsGoDungeon_WanderingShip()
	
	BnsDroidRun_WanderingShip()

	BnsGobackF8Lobby()
}


;================================================================================================================
;	204 - ChaosSupplyChain - 混沌補給基地(F8)
;================================================================================================================
bns_DungeonProcess_ChaosSupplyChain() {

	BnsRoomTeamUp()

	BnsGoDungeon_ChaosSupplyChain()
	
	BnsDroidRun_ChaosSupplyChain()

	BnsGobackF8Lobby()
}

