#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Character Profile 格式:
;role: 0:disable 1:blademaster 2:kungfufighter 4:shooter 3:forcemaster 6:summoner 7:assassin 5:destoryer
;      8:swordmaster 9:warlock 10:soulfighter 11:warrior 12:archer 14:thunderer 15:dualblader 16:musician
;職業: 0:不限定  1:劍 2:拳 3:氣 4:槍 5:力 6:召 7:刺 8:燐劍 9:咒 10:乾坤  11:鬥 12:弓 14:天道 15:雙劍 16:樂師

;Format: character index, role, category, accept mission, time of leave battle, arg1, arg2
;格式: 角色順位編號, 職業, 系別, 接取任務, 脫戰時間(ms), 參數1(Optinal), 參數2(Optinal)

; global ROLE_UNSPECIFIED     := 0    ;未指定
; global ROLE_BLADEMASTER     := 1    ;劍士
; global ROLE_KUNGFUFIGHTER   := 2    ;拳士
; global ROLE_FORCEMASTER     := 3    ;氣功
; global ROLE_SHOOTER         := 4    ;槍手
; global ROLE_DESTORYER       := 5    ;力士
; global ROLE_SUMMONER        := 6    ;召喚
; global ROLE_ASSASSIN        := 7    ;刺客
; global ROLE_SWORDMASTER     := 8    ;燐劍
; global ROLE_WARLOCK         := 9    ;咒術
; global ROLE_SOULFIGHTER     := 10   ;乾坤
; global ROLE_WARRIOR         := 11   ;鬥士
; global ROLE_ARCHER          := 12   ;弓手
; global ROLE_THUNDERER       := 14   ;天道
; global ROLE_DUALBLADER      := 15   ;雙劍
; global ROLE_MUSICIAN        := 16   ;樂師



global CHARACTER_PROFILES        ;defined in bns_common.ahk
global PROFILES_ITERATOR := 0    ;-1: EOF, 0: defualt, not load,  1~N: iterator of profiles

global HIGH_SPEED_ROLE
global SKILL_CATE
global MISSION_ACCEPT

global currProfile := []

;================================================================================================================
;    Method - Init
;================================================================================================================
BnsCmInit() {
}

;================================================================================================================
;    Method - Load Character Profiles
;================================================================================================================
BnsCmLoadCharProfiles(path) {
    if(path == "" || !FileExist(path)) {
        PROFILES_ITERATOR := -1
        return 0
    }

    charProfiles := FileOpen(path,"r", "UTF-8-RAW")

    while(charProfiles.AtEOF != 1) {
        cpLine := charProfiles.ReadLine()

        if(RegExMatch(cpLine, "^((#|;|//|/\*).*|\s*)$") == 0) {    ;過濾注解及空行, 支持 #, ;, //, /* 為開頭的註解
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
BnsCmChangeCharacter(profile) {
    currProfile := []
    currProfile := StrSplit(profile, ",", "`r`n")

    SKILL_CATE := BnsCmGetCate("")    ;column 3
    MISSION_ACCEPT := BnsCmIsMissionAccept("")    ;column 4
    HIGH_SPEED_ROLE := BnsCmIsHighSpeed("")

    ;當前角色已是 profile, 無需操作角色大廳界面
    if(BnsCmGetName(BnsCmGetProfile(0)) != BnsGetName()) {
        BnsSelectCharacter(currProfile[1])
    }

    DumpLogD("[BnsCmChangeCharacter] [" profile "], cid:" currProfile[1] ", role:" BnsRoleType() ", cate:" SKILL_CATE)
    DumpLogD("[BnsCmChangeCharacter] isHighSpeed: " HIGH_SPEED_ROLE ", Leave Battle Time: " currProfile[5])

}



;================================================================================================================
;    ACTION - Change to Next Character
;================================================================================================================
BnsCmProfileNext() {
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
BnsCmGetProfile(iterator) {
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
;    Method - Get Index
;================================================================================================================
BnsCmGetCid(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[1])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[1])
}


;================================================================================================================
;    Method - Get Name
;================================================================================================================
BnsCmGetName(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[2])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[2])
}


;================================================================================================================
;    Method - Get Skill Category
;================================================================================================================
BnsCmGetCate(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[3])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[3])
}


;================================================================================================================
;    Method - Is Mission Accept
;================================================================================================================
BnsCmIsMissionAccept(profile) {
    if(profile == "") {
        return StrCfgTrim(currProfile[4])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[4])
}


;================================================================================================================
;    Method - Get Mission Loop Times
;================================================================================================================
BnsCmGetMissionTimes(profile:="") {
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
;    Method - Get ARG1(OPTINAL)
;================================================================================================================
BnsCmGetArg1(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[6])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[6])
}



;================================================================================================================
;    Method - Get ARG2(OPTINAL)
;================================================================================================================
BnsCmGetArg2(profile:="") {
    if(profile == "") {
        return StrCfgTrim(currProfile[7])
    }

    p := StrSplit(profile, ",", "`r`n")
    return StrCfgTrim(p[7])
}


;================================================================================================================
;    Method - Is High Speed Role
;================================================================================================================
BnsCmIsHighSpeed(profile:="") {
    ;role: 0:disable 1:blademaster 2:kungfufighter 4:shooter 3:forcemaster 6:summoner 7:assassin 5:destoryer
    ;      8:swordmaster 9:warlock 10:soulfighter 11:warrior 12:archer 14:thunderer 15:dualblader 16:musician
    ;職業: 0:不限定  1:劍 2:拳 3:氣 4:槍 5:力 6:召 7:刺 8:燐劍 9:咒 10:乾坤  11:鬥 12:弓 14:天道 15:雙劍 16:樂師

    switch BnsRoleType() {
        case ROLE_SWORDMASTER:
            if(BnsCmGetCate(profile) == 2) {
                return 1
            }

        case ROLE_WARRIOR:
            if(BnsCmGetCate(profile) == 1) {
                return 1
            }
    }

    return 0
}



;================================================================================================================
;    Method - Is Profile Loaded
;================================================================================================================
BnsCmIsProfileLoaded() {
    ret := (PROFILES_ITERATOR != 0) ? 1 : 0

    DumpLogD("[BnsCmIsProfileLoaded] status = " ret)
    return ret
}



;================================================================================================================
;    Method - Is Profile EOF
;================================================================================================================
BnsCmIsProfilesEOF() {
    ret := (PROFILES_ITERATOR == -1) ? 1 : 0    ;out of bound will set as -1

    DumpLogD("[BnsCmIsProfilesEOF] EOF = " ret)
    return ret
}



;================================================================================================================
;    Method - Is Profiles Valid
;================================================================================================================
BnsCmIsProfilesValid() {
    ret := (PROFILES_ITERATOR == -1 && CHARACTER_PROFILES.length() == 0) ? 0 : 1

    DumpLogD("[BnsCmIsProfilesValid] valid = " ret)

    return ret
}