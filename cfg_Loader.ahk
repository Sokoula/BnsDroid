#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



;================================================================================================================
;    Default Configuration
;================================================================================================================
;---環境設定---
;劍靈設定 界面大小85, 橫軸速度:60, 縱軸速度:60
global WIN_WIDTH := 1920			;視窗的寬度 pixel
global WIN_HEIGHT := 1080 + 30		;視窗的高度 pixel (需補上標題列的高度)

global WIN_CENTER_X := WIN_WIDTH // 2
global WIN_CENTER_Y := WIN_HEIGHT // 2

global WIN_QUARTER_X := WIN_WIDTH // 4
global WIN_QUARTER_Y := WIN_HEIGHT // 4

global WIN_THREE_QUARTERS_X := WIN_WIDTH - WIN_QUARTER_X
global WIN_THREE_QUARTERS_Y := WIN_HEIGHT - WIN_QUARTER_Y

global WIN_BLOCK_WIDTH  := WIN_WIDTH // 32
global WIN_BLOCK_HEIGHT := WIN_HEIGHT // 16



;---系統設定---
global HKEY := ^F1
global PRKEY := ^F2
global DBUG := 1
global DUMPLOG := 1
global LOGABLE := 4		;1:only Error, 2:E|Warning, 3:E|W|Info, 4:E|W|I|Debug (ALL)
global LOGPATH := log.txt

;---F8副本選單設定---
;(覆寫 bns_DungeonDispater.ahk 預設值)
global ACTIVITY := 1		;當前活動副本(入門才會有)		
global PARTY_MODE := 2		;組隊模式: 1:入門, 2:一般, 3:困難
global PARTY_MEMBERS := 0,1,2,3	;組隊人數(桌面使用個數)

;---腳本選擇--------
; 101 - 鬼怪村活動 		- 地表
; 102 - 紅絲倉庫   		- 地表
; 201 - 鬼面劇團   		- 地表
; 202 - 沙暴神殿   		- f8
; 203 - 青空船     		- f8
; 204 - 混沌補給基地	- f8
global DUNGEON_INDEX := 201


;================================================================================================================
;	Load Overlay Config from INI file
;================================================================================================================
LoadExternConfig() {
	configfile := FileOpen("config.ini","r", "UTF-8-RAW")
	
	while(configfile.AtEOF != 1) {
		cfgline := configfile.ReadLine()
		split_array := StrSplit(cfgline, A_Space, "`r`n")	;去除開頭及結尾的換行字元crlf後再分割字串

		if(RegExMatch(split_array[1], "^((#|;|//|/\*).*|\s*)$") == 0) {	;過濾注解及空行
			;RegExReplace(split_array[3], ", "")
			SetConfigValue(split_array[1], split_array[3])
		}
	}
	configfile.close()
}

;================================================================================================================
;	Assign Overlay value to variable
;================================================================================================================
SetConfigValue(key, value) {
	
	switch key
	{
		;--System Environment(環境&系統)----------------------------------
		case "start_hotkey":
			HKEY := value
		
		case "pause_resume_hotkey":
			PRKEY := value

		case "debug_enable":
			DBUG := value
		
		case "dump_log_enable":
			DUMPLOG := value

		case "logable_level":
			LOGABLE := value

		case "logfile_patch":
			LOGPATH := value

		case "windows_width":
			WIN_WIDTH := value + 2

		case "windows_height":
			WIN_HEIGHT := value + 32


		;--Autopilot Configuration(自動駕使&腳本)---------------------------------------
		case "activity_ongoing":
			ACTIVITY := value

		case "party_mode":
			PARTY_MODE := value

		case "dungeon_select":
			DUNGEON_INDEX := value

		case "demonsbane_level":
			DEMONSBANE_LEVEL:= value

		case "confuse_protect":
			CONFUSE_PROTECT:=value
			
		case "enemy_boss_level_indicator_region":
			ENEMY_BOSS_LEVEL_REGION := value

		case "enemy_zako_level_indicator_region":
			ENEMY_ZAKO_LEVEL_REGION := value

		case "blood_indicator_region":
			BLOOD_INDICATOR_REGION := value

		case "character_arrow_map_position":
			CHARACTER_ARROW_POSITION := value

		case "role_type":
			ROLE_TYPE := value

		case "is_hight_speed_role":
			HIGHT_SPEED_ROLE := value

		case "party_members":
			PARTY_MEMBERS := value

		;--Autopilot GhostfaceVillage(自動駕使&鬼怪村)----------------------------------
		case "gv_execute_round_times":
			GV_ExcuteRoundTimes := value

		case "gv_pick_rewards_second":
			GV_PickRewardsSecond := value


		;--Autopilot HongsilSecretWarehouse(自動駕使&紅絲秘密倉庫)----------------------------------
		case "hw_execute_round_times":
			HW_ExcuteRoundTimes := value

		case "hw_pick_rewards_second":
			HW_PickRewardsSecond := value

		;--Autopilot GhostfaceTheater(自動駕使&鬼面劇團)--------------------------------
		case "gt_boss1_jump_protect_timer":
			GT_BOSS1_JUMP_PROTECT_TIMER := (-1 * value)

		;--Autopilot WanderingShip(自動駕使&封魔錄)-------------------------------------


		Default:
			DumpLogW("[SetConfigValue] LoadExternConfig - Illegal config!! key: " key ", value:" value)
			return
	}
	
	DumpLogD("[SetConfigValue] LoadExternConfig - key: " key ", value:" value)
}




;================================================================================================================
;	Dump configuration
;================================================================================================================
DumpSystemConfig() {
	DumpLogI("[System] HKEY:" HKEY)
	DumpLogI("[System] PRKEY:" PRKEY)
	DumpLogI("[System] DBUG:" DBUG)
	DumpLogI("[System] LOGABLE:" LOGABLE)
	DumpLogI("[System] LOGPATH:" LOGPATH)
	DumpLogI("[System] Resolution: width:" WIN_WIDTH " height:" WIN_HEIGHT)
	DumpLogI("[System] Activity:" ACTIVITY)
	DumpLogI("[System] Party mode:" PARTY_MODE)
	DumpLogI("[System] Aerodrome level:" DEMONSBANE_LEVEL)
}




