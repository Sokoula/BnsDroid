#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.





getCurrentUUID() {
    ;取得當前桌面的 UUID
    RegRead, currentUUID, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, CurrentVirtualDesktop
    
    return currentUUID
}


getListUUID() {
    ;取得所有桌面的UUID清單(串接為一個字串)
    RegRead, listUUID, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs

    return listUUID
}


queryDesktopId(UUID) {
    listUUID := getListUUID()
    
    lenUUID := strlen(getCurrentUUID())

    desktops := strlen(listUUID) / lenUUID

    
    loop %desktops% {
        desktopUUID := substr(listUUID, (A_index - 1) * lenUUID + 1, lenUUID)
        
        if(UUID == desktopUUID ) {
            return A_index
        }
    }

    return 0
}


getCurrentDesktopId() {
    return queryDesktopId(getCurrentUUID())
}


switchDesktopByNumber(targetId) {

    ;目標桌面就是當前桌面, 不做任何事
    if(targetId == queryDesktopId(getCurrentUUID())) {
        return
    }
    
    ;當前桌面ID小於目標桌面, 向右切換
    while(queryDesktopId(getCurrentUUID()) < targetId) {
        Send ^#{Right}
        sleep 60
    }


    ;當前桌面ID大於目標桌面, 向左切換
    while(queryDesktopId(getCurrentUUID()) > targetId) {
        Send ^#{Left}
        sleep 60
    }
}
