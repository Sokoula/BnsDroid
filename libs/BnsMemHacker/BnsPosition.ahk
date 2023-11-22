#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Class BnsPosition {
    baseAddress := 0
    offsetLinkSelfX := 0
    offsetLinkSelfY := 0
    offsetLinkSelfZ := 0

    offsetLinkMainBossX := 0
    offsetLinkMainBossY := 0
    offsetLinkMainBossZ := 0


    memObject := 0


    ;AHK class constructor
    __New(memObject)
    {
        this.memObject := memObject
        
        ;載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, POSITION_BASE_ADDRESS
        this.baseAddress := this.memObject.BaseAddress + offsets

        ;載入角色座標X指針偏移量(X offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_SELF_POSITION_X
        this.offsetLinkSelfX := StrSplit(offsets, ",", "`r`n")

        ;載入角色座標Y指針偏移量(Y offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_SELF_POSITION_Y
        this.offsetLinkSelfY := StrSplit(offsets, ",", "`r`n")
        
        ;載入角色座標Z指針偏移量(Z offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_SELF_POSITION_Z
        this.offsetLinkSelfZ := StrSplit(offsets, ",", "`r`n")



        ;載入主BOSS座標X指針偏移量(X offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_MAIN_BOSS_POS_X
        this.offsetLinkMainBossX := StrSplit(offsets, ",", "`r`n")

        ;載入主BOSS座標Y指針偏移量(Y offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_MAIN_BOSS_POS_Y
        this.offsetLinkMainBossY := StrSplit(offsets, ",", "`r`n")
        
        ;載入主BOSS座標Z指針偏移量(Z offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_MAIN_BOSS_POS_Z
        this.offsetLinkMainBossZ := StrSplit(offsets, ",", "`r`n")


        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }


    ;Get character position X;  [ return ] float
    getPositionX() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkSelfX*) 
    }

    ;Set character posistiion X;  [ x ] float
    setPositionX(x) {
        ;Useless
    }


    ;Get character posistion Y;  [ return ] float
    getPositionY() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkSelfY*) 
    }

    ;Set character posistiion Y;  [ y ] float
    setPositionY(y) {
        ;Useless
    }


    ;Get character position Z;  [ return ] float
    getPositionZ() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkSelfZ*) 
    }

    ;Set character posistiion Z;  [ z ] float
    setPositionZ(z) {
        ;Useless
    }


    getMainBossPosX() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkMainBossX*) 
    }

    getMainBossPosY() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkMainBossY*) 
    }

    getMainBossPosZ() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkMainBossZ*) 
    }


}