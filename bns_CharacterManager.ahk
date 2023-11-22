#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Character Profile 格式:
;role: 0:disable 1:blademaster 2:kungfufighter 3:forcemaster 4:summoner 5:assassin 6:destoryer 7:swordmaster
;      8:warlock 9:soulfighter 10:shooter 11:warrior 12:archer 13:thunderer 14:dualblader 15:musician
;職業: 0:不限定    1:劍 2:拳 3:氣 4:召 5:刺 6:力 7:燐劍 8:咒 9:乾坤 10:槍 11:鬥 12:弓 13:天道 14:雙劍 15:樂師

;Format: character index, role, category, accept mission, time of leave battle, arg1, arg2
;格式: 角色順位編號, 職業, 系別, 接取任務, 脫戰時間(ms), 參數1(Optinal), 參數2(Optinal)

;defiend in bns_common.ahk
; global ROLE_UNSPECIFIED     := 0    ;未指定
; global ROLE_BLADEMASTER     := 1    ;劍士
; global ROLE_KUNGFUFIGHTER   := 2    ;拳士
; global ROLE_FORCEMASTER     := 3    ;氣功
; global ROLE_SUMMONER        := 4    ;召喚
; global ROLE_ASSASSIN        := 5    ;刺客
; global ROLE_DESTORYER       := 6    ;力士
; global ROLE_SWORDMASTER     := 7    ;燐劍
; global ROLE_WARLOCK         := 8    ;咒術
; global ROLE_SOULFIGHTER     := 9    ;乾坤
; global ROLE_SHOOTER         := 10   ;槍手
; global ROLE_WARRIOR         := 11   ;鬥士
; global ROLE_ARCHER          := 12   ;弓手
; global ROLE_THUNDERER       := 13   ;天道
; global ROLE_DUALBLADER      := 14   ;雙劍
; global ROLE_MUSICIAN        := 15   ;樂師



global CHARACTER_PROFILES        ;defined in bns_common.ahk
global PROFILES_ITERATOR := 0    ;-1: EOF, 0: defualt, not load,  1~N: iterator of profiles

global HIGH_SPEED_ROLE
global ROLE_TYPE
global SKILL_CATE
global MISSION_ACCEPT

global currProfile := []

;================================================================================================================
;    Method - Init
;================================================================================================================
BnsCcInit() {
}

;================================================================================================================
;    Method - Load Character Profiles
;================================================================================================================
BnsCcLoadCharProfiles(path) {
    if(path == "") {
        PROFILES_ITERATOR := -1
        return 0
    }

    charProfiles := FileOpen(path,"r", "UTF-8-RAW")

    while(charProfiles.AtEOF != 1) {
        cpLine := charProfiles.ReadLine()

        if(RegExMatch(cpLine, "^((#|;|//|/\*).*|\s*)$") == 0) {    ;過濾注解及空行
            ;RegExReplace(split_array[3], ", "")
            CHARACTER_PROFILES.push(StrCfgTrim(cpLine))
        }
    }

    charProfiles.close()

    if(CHARACTER_PROFILES.length() > 0) {
        PROFILES_ITERATOR := 1  ;cp檔中有設定
    }
    else {
        PROFILES_ITERATOR := -1 ;cp檔中沒有設定
    }

    return CHARACTER_PROFILES.length()
}

;================================================================================================================
;    ACTION - Change Character
;================================================================================================================
BnsCcChangeCharacter(profile) {
    currProfile := []
    currProfile := StrSplit(profile, ",", "`r`n")

    ROLE_TYPE := BnsCcGetRole("")    ;2
    SKILL_CATE := BnsCcGetCate("")    ;3
    MISSION_ACCEPT := BnsCcIsMissionAccept("")    ;4
    HIGH_SPEED_ROLE := BnsCcIsHighSpeed("")    

    DumpLogD("[BnsCcChangeCharacter] [" profile "], cid:" currProfile[1] ", role:" ROLE_TYPE ", cate:" SKILL_CATE)
    DumpLogD("[BnsCcChangeCharacter] isHighSpeed: " HIGH_SPEED_ROLE ", Leave Battle Time: " currProfile[5])

    BnsSelectCharacter(currProfile[1])
}



;================================================================================================================
;    ACTION - Change to Next Character
;================================================================================================================
BnsCcProfileNext() {
    if(PROFILES_ITERATOR > 0) {        ;0:不使用
        PROFILES_ITERATOR++
    }

    if(PROFILES_ITERATOR > CHARACTER_PROFILES.length()) {
        ;out of bound, EOF
        PROFILES_ITERATOR := -1
    }

    return PROFILES_ITERATOR
}



;================================================================================================================
;    Method - Get Current Character Profile
;================================================================================================================
BnsCcGetProfile(iterator) {
    profile := ""
    
    if(iterator == 0) {        ;沒指定哪一筆就傳回當前的 profile
        profile := CHARACTER_PROFILES[PROFILES_ITERATOR]
    }
    else {
        profile := CHARACTER_PROFILES[iterator]
    }

    return profile
}


;================================================================================================================
;    Method - Get Current Character Profile
;================================================================================================================
BnsCcGetCid(profile:="") {
    if(profile == "") {
        return currProfile[1]
    }

    p := StrSplit(profile, ",", "`r`n")
    return p[1]
}


;================================================================================================================
;    Method - Get Current Character Profile
;================================================================================================================
BnsCcGetRole(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[2])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[2])
}


;================================================================================================================
;    Method - Get Current Character Profile
;================================================================================================================
BnsCcGetCate(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[3])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[3])
}


;================================================================================================================
;    Method - Get ARG1(OPTINAL)
;================================================================================================================
BnsCcGetArg1(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[6])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[6])
}



;================================================================================================================
;    Method - Get ARG2(OPTINAL)
;================================================================================================================
BnsCcGetArg2(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[7])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[7])
}




;================================================================================================================
;    Method - Is Mission Accept
;================================================================================================================
BnsCcIsMissionAccept(profile) {
    if(profile == "") {
        return StrCfgTrim(currProfile[4])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[4])
}


;================================================================================================================
;    Method - Get Mission Loop Times
;================================================================================================================
BnsCcGetMissionTimes(profile:="") {
    t := 0
    if(profile == "") {
        t := StrCfgTrim(currProfile[5])
    }
    else {
        p := StrSplit(profile, ",", "`r`n")
        t := StrCfgTrim(p[5])
    }

    if(t == 0 || t == "") {
        t := 2147483647     ;不限制
    }

    return t
}


;================================================================================================================
;    Method - Is High Speed Role
;================================================================================================================
BnsCcIsHighSpeed(profile:="") {
    ;role: 0:disable 1:blademaster 2:kungfufighter 3:forcemaster 4:summoner 5:assassin 6:destoryer 7:swordmaster
    ;      8:warlock 9:soulfighter 10:shooter 11:warrior 12:archer 13:thunderer 14:dualblader
    ;職業: 0:不限定    1:劍 2:拳 3:氣 4:召 5:刺 6:力 7:燐劍 8:咒 9:乾坤 10:槍 11:鬥 12:弓 13:天道 14:雙劍 15:樂師
    
    switch BnsCcGetRole(profile) {
        case ROLE_SWORDMASTER:
            if(BnsCcGetCate(profile) == 2) {
                return 1
            }

        case ROLE_WARRIOR:
            if(BnsCcGetCate(profile) == 1) {
                return 1
            }
    }

    return 0
}



;================================================================================================================
;    Method - Is Profile Loaded
;================================================================================================================
BnsCcIsProfileLoaded() {
    ret := (PROFILES_ITERATOR != 0) ? 1 : 0
    
    DumpLogD("[BnsCcIsProfileLoaded] status = " ret)

    return ret
}



;================================================================================================================
;    Method - Is Profile EOF
;================================================================================================================
BnsCcIsProfilesEOF() {
    ret := (PROFILES_ITERATOR == -1) ? 1 : 0    ;out of bound will set as -1

    DumpLogD("[BnsCcIsProfilesEOF] EOF = " ret)

    return ret
}



;================================================================================================================
;    Method - Is Profiles Valid
;================================================================================================================
BnsCcIsProfilesValid() {
    ret := (PROFILES_ITERATOR == -1 && CHARACTER_PROFILES.length() == 0) ? 0 : 1

    DumpLogD("[BnsCcIsProfilesValid] valid = " ret)

    return ret
}