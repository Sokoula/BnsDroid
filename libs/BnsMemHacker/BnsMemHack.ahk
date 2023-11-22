#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#include libs\BnsMemHacker\ClassMemory.ahk
#include libs\BnsMemHacker\BnsPosition.ahk
#include libs\BnsMemHacker\BnsCamara.ahk
#include libs\BnsMemHacker\BnsBattle.ahk
#include libs\BnsMemHacker\BnsCharacter.ahk
#include libs\BnsMemHacker\BnsUnifyF8.ahk


Class BnsMemHack {
    DEBUG := 1

    TAG := 0

    memHackObject := 0

    camaraObject := 0
    positionObject := 0
    battleObject := 0
    characterObject := 0
    f8Object := 0


    ;AHK class constructor
    __New(dId)
    {
        this.TAG := dId
        this.memHackObject := this.bindProcessByName("BNSR.exe")
        this.camaraObject := new BnsCamara(this.memHackObject)
        this.positionObject := new BnsPosition(this.memHackObject)
        this.battleObject := new BnsBattle(this.memHackObject)
        this.characterObject := new BnsCharacter(this.memHackObject)
        this.f8Object := new BnsUnifyF8(this.memHackObject)

        return this
    }

    ;AHK class destructor
    __Delete()
    {
        ; nothing to do
    }



;================================================================================================================
;█ Functions
;================================================================================================================
    ;Bind process memory; #exec: process name; @return: memory object
    bindProcessByName(exeName := "BNSR.exe") {
        if(_ClassMemory.__Class != "_ClassMemory") {
            if(this.DEBUG == 1) {
                Msgbox,,%APPNAME%, class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
                return
            }
        }

        ;新建記憶體對像
        this.memHackObject := new _ClassMemory("ahk_exe BNSR.exe", "", hProcessCopy) 

        if(!isObject(this.memHackObject)) {
            if(this.DEBUG == 1) {
                Msgbox,,%APPNAME%, failed to open a handle
                return
            }
        }
        
        if(!hProcessCopy) {
            if(this.DEBUG == 1) {
                Msgbox,,%APPNAME%, failed to open a handle. Error Code = %hProcessCopy%
                return
            }
        }
        
        return this.memHackObject
    }

    ;Bind process memory; #pid: process id; @return: memory object
    bindProcessByPid(pid := "") {
        ;TBD
    }



;================================================================================================================
;█ Interface
;================================================================================================================
    ;------------------------------------------------------------------------------------------------------------    
    ;■ Memory Hacker(BnsMemHack) 
    ;------------------------------------------------------------------------------------------------------------
    ;Get current memory Object; @return: memHackObject
    getMemHackObject() {
        return this.memHackObject
    }


    ;Check memhack is worked; [ return ] 0:expired; 1:worked
    isMemHackWork() {
        if(this.getPosY() == "") {
            ;DumpLogE("[ERROR] Memory Hack not work, please check base address")
            return 0
        }

        return 1
    }

    ;Dump memory informations; #type: 0(null) = all; 1 = camara + posistion; 2 = enermy
    infoDump(type := 0) {
        posInfo := "POS-XYZ:[" this.getPosX() ", " this.getPosY() ", " this.getPosZ() "]"
        
        camInfo := "CAM-XYZ:[" this.getCamAzimuth() "(" this.getCamAzimuthH() "), " this.getCamAltitude() "]"

        targetName := "TarGet Name: " this.getMainTargetName()
        targetBlood := "Target HP: " this.getMainTargetBlood()
        targetPos := "M-Target-POS-XYZ:[" this.getMainBossPosX() ", " this.getMainBossPosY() ", " this.getMainBossPosZ() "]"

        switch type
        {
            case 0:


            case 1: ;角色資訊
                return posInfo "`n" camInfo 

            case 2: ;目標資訊
                return targetName "`n" targetBlood "`n" targetPos

            case 4:
                return "not support"
        }
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ Position(positionObject) 
    ;------------------------------------------------------------------------------------------------------------
    ;Telepot to indicate position;  [ x ] float x;  [ y ] float y;  [ z ] float z
    setPosition(x, y, z) {
        ;Useless
    }

    ;Get current self position X; [ return ] float x
    getPosX() {
        return this.positionObject.getPositionX()
    }

    ;Get current self position X; [ return ] float y
    getPosY() {
        return this.positionObject.getPositionY()
    }

    ;Get current self position X; [ return ] float z
    getPosZ() {
        return this.positionObject.getPositionZ()
    }

    ;Get current position;  [ return ] array[x, y, z]
    getPosition() {
        position := Array()
        position.push(this.getPosX())
        position.push(this.getPosY())
        position.push(this.getPosZ())
        
        return position
    }


    ;Get main boss position X; [ return ] float x
    getMainBossPosX() {
        return this.positionObject.getMainBossPosX()
    }

    ;Get main boss position Y; [ return ] float y
    getMainBossPosY() {
        return this.positionObject.getMainBossPosY()
    }

    ;Get main boss position Z; [ return ] float z
    getMainBossPosZ() {
        return this.positionObject.getMainBossPosZ()
    }

    ;Get current position;  [ return ] array[x, y, z]
    getMainBossPosition() {
        position := Array()
        position.push(this.getMainBossPosX())
        position.push(this.getMainBossPosY())
        position.push(this.getMainBossPosZ())

        return position
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ Camara Attribute(camaraObject) 
    ;------------------------------------------------------------------------------------------------------------
    ;Get current camara attributes; @return: array[ax, ay, az]
    getCamaraAttr() {
        attrs := Array()
        attrs.push(this.getCamAltitude())
        attrs.push(this.getCamAzimuth())

        return attrs
    }

    ;Get current camara azimuth; @return: cx
    getCamAzimuth() {
        return this.camaraObject.getAzimuth()
    }

    getCamAzimuthH() {
        aH := 450 - this.camaraObject.getAzimuth()
        return (aH > 360) ? aH - 360: aH
    }


    ;Set current camara azimuth; @cx: azimuth(0 - 360)
    setCamAzimuth(cx := 0) {
        this.camaraObject.setAzimuth(cx)
    }

    ;Get current camara altitude; @return: cy
    getCamAltitude() {
        return this.camaraObject.getAltitude()
    }

    ;Set current camara altitude; @return: cy(feet:270.1 - head:89.9)
    setCamAltitude(cy := 0) {
        this.camaraObject.setAltitude(cy)
    }


    ;------------------------------------------------------------------------------------------------------------
    ;■ Battle Control(battleObject) 
    ;------------------------------------------------------------------------------------------------------------
    getAutoCombatState() {
        return this.battleObject.getAutoCombatState()
    }

    getMainTargetBlood() {
        return this.battleObject.getMainTargetBlood()
    }

    ; getMainTargetName() {
    ;     return this.battleObject.getMainTargetName()
    ; }

    isInBattling() {
        return this.battleObject.isCurrentInBattling()
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ Character Info(characterObject) 
    ;------------------------------------------------------------------------------------------------------------
    getHpValue() {
        return this.characterObject.getHealthPoints()
    }

    ;Get posture indicator; [ return ] 0:正常 1:死透 6:瀕死 11:暈 13:倒 15:浮 18:跪 21:擊退 26:擊飛 28:?
    getPosture() {
        return this.characterObject.getPostureStatus()
    }


    
    ;Get value of speed hack; [ return ] float
    getSpeed() {
        return this.characterObject.getSpeedValue()
    }

    ;Set value of speed hack;  [ s ] float 1,2,3,4,5,...
    setSpeed(s := 1) {
        return this.characterObject.setSpeedValue(s)
    }

    ;Get talk type; [ return ] 0:none, 18:對話, 20:祈禱/採集/蒐集/記錄祕境, 23:搭龍脈, 40:修理, 61:觸發
    isAvailableTalk() {
        talktype := this.characterObject.getAvailableTalkType()
        return (talktype == "") ? 0 : talktype
    }

    ;------------------------------------------------------------------------------------------------------------
    ;■ F8 Unify(f8Object) 
    ;------------------------------------------------------------------------------------------------------------
    ;Get current room number in f8; @return: integer
    getF8RoomNumber() {
        return this.f8Object.getRoomNumber()
    }

    ;Get current level of demonsbane; @return: integer
    getDemonsbaneLevel() {
        return this.f8Object.getDemonsbaneLevel()
    }

}


