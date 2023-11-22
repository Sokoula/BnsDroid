#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;third-party library
;#include libs\DesktopSwitcher\WinVirtualDesktopSwitcher.ahk
;#include libs\PaddleOCR\PaddleOCR.ahk
;#include libs\BnsTelepoter\BnsTeleport.ahk


;================================================================================================================
;    METHOD - get party info
;================================================================================================================
;Get number of people of party; @return: integer
BsnPcGetPartyPeopleNum() {
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    return partyCtrl[1]
}

;Get member ids in party; @return: array
BnsPcGetPartyMemberList() {
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    people := partyCtrl[1]

    mids := Array()

    loop %people% {
        mids.push(partyCtrl[2 + A_index])
    }

    return mids
}

;@discard
;Get teleport desktop id; @return - integer
BsnPcGetTeleporterDid() {    
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    return partyCtrl[2]
}


;Get leader desktop id; @return - integer
BnsPcGetLeaderDid() {    ;desktop id
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    return partyCtrl[3]
}


;Get current desktop id; @return - integer
BnsPcGetCurrentDid() {    ;desktop id
    return queryDesktopId(getCurrentUUID())
}

;================================================================================================================
;    ACTION - send party invite
;================================================================================================================
BnsPcSendPartyInvite(name, dId) {
    send {Enter}
    sleep 100
    Send /invite %name%
    sleep 100
    send {Enter}
    sleep 1000

    switchDesktopByNumber(dId)
    sleep 1000

    WinActivate, %res_game_window_title%
    Send {y}
    sleep 100
    


    switchDesktopByNumber(1)
    sleep 1000

    WinActivate, %res_game_window_title%

    info:=GetTextOCR(165, 1030, 300, 30, res_game_window_title)
    
    if(RegExMatch(info, "加.了.+隊伍") != 0) {    
        if(DBUG == 1) {
            DumpLogD("[BnsPcSendPartyInvite] party member " name " joined")
        }

        return 1
    }
    
    return 0
}



;================================================================================================================
;    ACTION - enter room and team party 
;================================================================================================================
BnsPcRoomTeamUp() {
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")

    members := partyCtrl[1] - 1
    memberTp := partyCtrl[2]
    leaderId := partyCtrl[3]

    if(DBUG == 1) {
        DumpLogD("[BnsPcRoomTeamUp] members:" members ", memberTp:" memberTp ", leaderId:" leaderId)
    }

    if(members >= 1 ) {
        DumpLogI("[BnsPcRoomTeamUp] Enabled team work!")
    }
    else {
        return 0
    }

    ;切到 leader 桌面, 取得 room id
    switchDesktopByNumber(leaderId)
    sleep 1000
    
    if(DBUG == 3) {
        ScreenShot()
    }

    WinActivate, %res_game_window_title%
    roomId := BnsOuF8GetRoomNumber()

    if(roomId == "") {
        DumpLogE("[BnsPcRoomTeamUp] OCR room number failed")
        return 0
    }

    loop, %members% {
        member := partyCtrl[3 + A_index]
        switchDesktopByNumber(member)
        sleep 1000
        WinActivate, %res_game_window_title%

        BnsOuF8EnterRoomAndReady(roomId)
        sleep 1000

        if(DBUG == 3) {
            ScreenShot()
        }

    }

    switchDesktopByNumber(leaderId)
    sleep 1000

    return 1
}



;================================================================================================================
;    ACTION - Square Navigation 
;================================================================================================================
;團隊副本廣場導航; [ cate ] 1=英雄, 2=封魔;  [ onlyLastConfirm ] 0=確認每個都過完圖, 1=只確認最後一個過完圖(default)
BnsPcTeamMembersSquareNavigation(cate, onlyLastConfirm := 1) {  ;cate(1英雄/2封魔), onlyLastConfirm(0認過每個圖/1只確認最後一個過圖)
    ret := 0

    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    ; members := partyCtrl[1] - 1
    members := partyCtrl[1]
    leaderId := partyCtrl[3]

    ;換角色
    loop, %members% {
        ; member := partyCtrl[3 + A_index]
        member := partyCtrl[2 + A_index]
        switchDesktopByNumber(member)
        ; sleep 2000
        sleep 500
        WinActivate, %res_game_window_title%
        sleep 500
        
        ;預設只檢查最後一個組員進副本讀完圖(前面不檢查以節省時間)
        confirm := (onlyLastConfirm) ? ((A_index == members) ? 1 : 0) : 1

        ;進入副本
        if(BnsOuF8DefaultGoInDungeon(cate, confirm) == 1) {        
            ret++
        }

        sleep 1000
    }

    DumpLogD("[BnsPcTeamMembersSquareNavigation] party mebmers ready " ret)

    ;切到 leader 桌面
    switchDesktopByNumber(leaderId)
    sleep 500
    WinActivate, %res_game_window_title%

    return ret
}



;================================================================================================================
;    ACTION - open the Dragon Pulse by teleporter
;================================================================================================================
;@Discard;
BnsPcOpenDragonPulse(ms) {
    ; ret := 0

    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    teleporter := partyCtrl[2]
    leaderId := partyCtrl[3]

    switchDesktopByNumber(teleporter)
    sleep 1000

    ;第一次踩點觸發讀圖
    ; BnsTeleport()
    sleep 2000

    ;第二次踩點開龍脈
    ; BnsTeleport()
    sleep 500
    send {Tab}
    sleep 3000
    send {s}
    sleep 30
    send {s}
    sleep 2000
    
    ;歸回原位
    BnsActionWalk(ms)
    sleep 500
    
    ;切到 leader 桌面
    switchDesktopByNumber(leaderId)
    sleep 500
    WinActivate, %res_game_window_title%
}




;================================================================================================================
;    ACTION - Excute common action for specific members (function ptr callback)
;================================================================================================================
;團隊批次行動; [ fnAction ] 執行函數(funtion pointer);  [ mids ] 組員id array, 默認全員; [ feedback ] 回傳執行 mid 給 fnAction 當參數;  [ backleader ] 完成時是否切回隊長(默認);  [ delay ] 桌面切換 dealy
BnsPcTeamMemberAction(fnAction, mids := 0, feedback := 0, backleader := 1, delay := 800) {    ;mids 預期是陣列型別, 要執行的 member 要放入, mids = 0 表示 null

    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    leaderId := partyCtrl[3]

    ;mids 為空時, 套用所有 member
    ; AHK 以下狀況視用 null, mids := ;  mids := 0
    if(!mids)
    {
        ; ShowTipI("[BnsPcTeamMemberAction] - mids is null, load all members")
        mids := BnsPcGetPartyMemberList()
    }

    ;切換換角色視窗
    For i, m in mids {
        ; member := partyCtrl[2 + A_index]
        ; switchDesktopByNumber(member)
        switchDesktopByNumber(m)
        sleep 500
        WinActivate, %res_game_window_title%

        action := (fnAction.name == "") ? "BindObject function" : fnAction.name
        DumpLogD("[BnsPcTeamMemberAction] action " action ", mid:" m)

        if(feedback) {
            ret += fnAction.call(m)         ;執行傳進來的 action, 並回帶被執行的 mId
        }
        else {
            ret += fnAction.call()            ;執行傳進來的 action
        }

        sleep %delay%
    }


    if(backleader)
    {
        ;切回 leader 視窗
        switchDesktopByNumber(leaderId)
        sleep 500
        WinActivate, %res_game_window_title%
        sleep %delay%
    }
}



;================================================================================================================
;    ACTION - Team Bidding 
;================================================================================================================
BnsPcTeamMembersBidding(bidId) {
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    members := partyCtrl[1]
    leaderId := partyCtrl[3]
    
    loop %members% {
        mid := partyCtrl[2 + A_index]

        switchDesktopByNumber(mid)
        sleep 800
        WinActivate, %res_game_window_title%
        sleep 500

        if(mid == bidId) {
            send {y down}
            sleep 30
            send {y up}
            DumpLogD("[BnsPcTeamMembersBidding] mid: " mid " bid the item")
        }
        else {
            send {n down}
            sleep 30
            send {n up}
        }
    }
}




;================================================================================================================
;    ACTION - Members Pick Reward
;================================================================================================================
;團隊撿取戰利品 @return: 執行完成次數
BnsPcTeamMembersPickReward(funcName) {
    cbPtr := func(funcName)
    
    ret := 0

    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    members := partyCtrl[1] - 1
    leaderId := partyCtrl[3]
    
    ;換角色
    loop, %members% {
        member := partyCtrl[3 + A_index]
        switchDesktopByNumber(member)
        sleep 2000
        WinActivate, %res_game_window_title%

        ret += cbPtr.call(member)
    }

    ;切回到 leader 桌面
    switchDesktopByNumber(leaderId)
    sleep 2000
    WinActivate, %res_game_window_title%
    
    DumpLogD("[BnsPcTeamMembersPickReward] ret= " ret)    
    return ret
}



;================================================================================================================
;    ACTION - Retreat to F8 Lobby (most mission failed)
;================================================================================================================
;#onlyLastConfirm - 0:驗證每個組員過完圖, 1:只驗證最後一個組員過完圖(default)
BnsPcTeamMembersRetreatToLobby(onlyLastConfirm := 1) {
    ret := 0
    
    partyCtrl := StrSplit(PARTY_MEMBERS, ",", "`r`n")
    ; members := partyCtrl[1] - 1
    members := partyCtrl[1]
    
    ;換角色
    loop, %members% {
        ; member := partyCtrl[3 + A_index]
        member := partyCtrl[2 + A_index]
        switchDesktopByNumber(member)
        sleep 100
        WinActivate, %res_game_window_title%

        ;預設只檢查最後一個組員進副本讀完圖(前面不檢查以節省時間)
        confirm := (onlyLastConfirm) ? ((A_index == members) ? 1 : 0) : 1

        ret += BnsOuF8GobackLobby(confirm)
        sleep 100
    }

    DumpLogD("[BnsPcTeamMembersRetreatToLobby] ret= " ret)        
    return ret
}