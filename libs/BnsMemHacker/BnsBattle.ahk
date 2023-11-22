#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Class BnsBattle {
    baseAddress := 0
    offsetLinkAutoCombat := 0
    offsetLinkBattleIndicator := 0
    offsetLinkMainTargetBlood := 0
    offsetLinkMainTargetName := 0


    memObject := 0


    ;AHK class constructor
    __New(memObject)
    {
        this.memObject := memObject
        
        ;載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, BATTLE_BASE_ADDRESS
        this.baseAddress := this.memObject.BaseAddress + offsets

        ;載入自動戰鬥指針偏移量(AutoCombat state offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_FIGHT_AUTO_COMBAT_STATE
        this.offsetLinkAutoCombat := StrSplit(offsets, ",", "`r`n")

        ;載入戰鬥中狀態指針偏移量(Battle state offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_BATTLE_STATE_INDICATOR
        this.offsetLinkBattleIndicator := StrSplit(offsets, ",", "`r`n")

        ;載入目標血量指針偏移量(Target HP offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFEST_MAIN_TARGET_BLOOD_VALUE
        this.offsetLinkMainTargetBlood := StrSplit(offsets, ",", "`r`n")

        ;載入目標名字指針偏移量(Target name offset) ;TODO
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFEST_MAIN_TARGET_NAME_STRING
        this.offsetLinkMainTargetName := StrSplit(offsets, ",", "`r`n")

        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }

    ;Get auto combat state; @return 0:disable, 1~:enabled
    getAutoCombatState() {
        return this.memObject.read(this.baseAddress, "UInt", this.offsetLinkAutoCombat*) 
    }

    isCurrentInBattling() {
        return this.memObject.read(this.baseAddress, "UInt", this.offsetLinkBattleIndicator*) 
    }

    getMainTargetBlood() {
        return this.memObject.read(this.baseAddress, "Int64", this.offsetLinkMainTargetBlood*) 
    }

    ; getMainTargetName() {
    ;     return this.memObject.readString(this.baseAddress,, "utf-16", this.offsetLinkMainTargetName*)
    ; }

}