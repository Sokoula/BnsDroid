#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Class BnsUnifyF8 {
    baseAddress := 0
    offsetLinkRoomNumber := 0
    offsetLinkDemonsbaneLevel := 0

    memObject := 0


    ;AHK class constructor
    __New(memObject)
    {
        this.memObject := memObject
        
        ;載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, F8UNITY_BASE_ADDRESS
        this.baseAddress := this.memObject.BaseAddress + offsets

        ;載入房號指針偏移量(room number offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_F8_ROOM_NUMBER
        this.offsetLinkRoomNumber := StrSplit(offsets, ",", "`r`n")

        ;載入封魔錄等級指針偏移量(demonsbane level offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_F8_DEMONSBANE_LEVEL
        this.offsetLinkDemonsbaneLevel := StrSplit(offsets, ",", "`r`n")


        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }


    ;Get room number @return: integer
    getRoomNumber() {
        return this.memObject.read(this.baseAddress, "UInt", this.offsetLinkRoomNumber*) 
    }

    ;Get demonsbane level @retuen: integer
    getDemonsbaneLevel() {
        this.memObject.read(this.baseAddress, "UInt", this.offsetLinkDemonsbaneLevel*)
    }

}