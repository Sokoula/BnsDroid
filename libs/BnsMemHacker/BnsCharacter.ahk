#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Class BnsCharacter {
    baseAddress1 := 0
    baseAddress2 := 0
    offsetLinkHealthPoints := 0
    offsetLinkPostureStatus := 0
    offsetLinkSpeedValue := 0
    offsetLinkAvailableTalkType := 0

    memObject := 0


    ;AHK class constructor
    __New(memObject)
    {
        this.memObject := memObject
        
        ;■載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, CHARACTER_BASE_ADDRESS1
        this.baseAddress1 := this.memObject.BaseAddress + offsets

        ;載入生命值針偏移量(Health Points offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_CHARACTER_HP_VALUE
        this.offsetLinkHealthPoints := StrSplit(offsets, ",", "`r`n")

        ;載入對話類別指針偏移量(Available talk type offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_AVAILABLE_TALK_TYPE
        this.offsetLinkAvailableTalkType := StrSplit(offsets, ",", "`r`n")

        ;載入姿態狀態針偏移量(Posture state offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_CHARACTER_POSTURE
        this.offsetLinkPostureStatus := StrSplit(offsets, ",", "`r`n")


        ;■載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, CHARACTER_BASE_ADDRESS2
        this.baseAddress2 := this.memObject.BaseAddress + offsets

        ;載入加速狀態針偏移量(Death state offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_CHARACTER_SPEED
        this.offsetLinkSpeedValue := StrSplit(offsets, ",", "`r`n")


        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }


    ;Get self health points; [ return ] 4bytes
    getHealthPoints() {
        return this.memObject.read(this.baseAddress1, "UInt", this.offsetLinkHealthPoints*) 
    }


    ;Get posture indicator; [ return ] 0:正常 1:死透 6:瀕死 11:暈 13:倒 15:浮 18:跪 21:擊退 26:擊飛
    getPostureStatus() {
        ;0  - 活著站著
        ;1  - 完全死亡
        ;6  - 瀕死狀態(可爬行可打座)
        ;11 - 眩暈中(會被其他狀態覆蓋)
        ;13 - 被擊倒地躺地中(可繳解控)
        ;15 - 浮空中
        ;18 - 虛弱(可繳解控),強制跪地(不可解控)
        ;21 - 擊退後趴地(可繳解控)
        ;26 - 擊退中(不可解控)
        ;28 - ?
        ;48 - 壓制(擒龍功,抓舉)
        return this.memObject.read(this.baseAddress1, "UInt", this.offsetLinkPostureStatus*) 
    }



    getSpeedValue() {
        return this.memObject.read(this.baseAddress2, "float", this.offsetLinkSpeedValue*) 
    }


    setSpeedValue(s) {
        return this.memObject.write(this.baseAddress2, s, "float", this.offsetLinkSpeedValue*) 
    }


    getAvailableTalkType() {
        ;0  - none
        ;18 - npc 對話
        ;20 - 祈禱/採集/蒐集/記錄祕境
        ;23 - 騰龍駕脈
        ;40 - 修理
        ;61 - 入場/觸發
        return this.memObject.read(this.baseAddress1, "UInt", this.offsetLinkAvailableTalkType*)
    }

}