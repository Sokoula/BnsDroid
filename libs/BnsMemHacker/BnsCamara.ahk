#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Class BnsCamara {
    baseAddress := 0
    offsetLinkAltitude := 0
    offsetLinkAzimuth := 0
    offsetLinkZoom := 0

    memObject := 0


    ;AHK class constructor
    __New(memObject)
    {
        this.memObject := memObject
        
        ;載入基址(base address)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, CAMARA_BASE_ADDRESS
        this.baseAddress := this.memObject.BaseAddress + offsets

        ;載入仰角指針偏移量(Altitude offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_CAMARA_Y
        this.offsetLinkAltitude := StrSplit(offsets, ",", "`r`n")

        ;載入向位指針偏移量(Azimuth offset)
        IniRead, offsets, libs\BnsMemHacker\config.ini, MEMORY_ADDRESS, OFFSET_CAMARA_X
        this.offsetLinkAzimuth := StrSplit(offsets, ",", "`r`n")

        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }


    ;Get altitude @return: 270.1 - 0 - 89.9
    getAltitude() {
        ;//依據 ClassMemory 的 read 函數的參數3 offsets*, 需要對應在陣列尾部也加上* 才可正常運作, 即傳入 offsetLinkAltitude*
        ;//參數2 為最終輸出的資料格式, 坐標值使用單精度 float(在計算offset 時 x64 需使用 Int64)
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkAltitude*) 
    }

    ;Set altitude #cy: 270.1 - 0 - 89.9
    setAltitude(cy := 0) {
        this.memObject.Write(this.baseAddress, cy, "float", this.offsetLinkAltitude*)
    }


    ;Get azimuth @return: 0 - 360
    getAzimuth() {
        return this.memObject.read(this.baseAddress, "float", this.offsetLinkAzimuth*)
    }

    ;Set Azimuth #cx: 0 - 360
    setAzimuth(cx := 0) {
        this.memObject.Write(this.baseAddress, cx, "float", this.offsetLinkAzimuth*)
    }


    ;Get zoom; TBD
    getZoom() {
    }
}