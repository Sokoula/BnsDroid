#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;global CONFUSE_PROTECT:=1

;================================================================================================================
;    ■ Common
;================================================================================================================
;----------------------------------------------------------------------------
;    BnsMoveDungeon_RandomConfuseProtection - 副本進場混淆保護(不要每次進場都同一個方式)
;----------------------------------------------------------------------------
BnsMoveDungeon_RandomConfuseProtection(ms) {
    ;跑速0的移動比率
    ;輕功:走路:倒退 = 0.5:1:2.5
    
    
    Random, rand, 1, 10
    DumpLogD("[BnsMoveDungeon_RandomConfuseProtection] rand=" rand)
    
    switch Mod(rand, 3)
    {
        case 0:
            BnsActionSprint(ms * 0.5)    ;輕功跑進傳點
        
        case 1:
            BnsActionWalk(ms)            ;走進傳點
            
        case 2:
            BnsActionSprintJump(ms * 0.5)    ;輕功跳進傳點
    }
    
    
}


;================================================================================================================
;================================================================================================================
;    ■ Ghost village - 鬼怪村
;================================================================================================================
;================================================================================================================
BnsMoveDungeon_GhostVillage() {
    
    ShowTipI("●[System] - Move into dungeon GhostVillage ...")
    
    ;關閉人物
    Send, ^f
    sleep 200
    
    ;左側移後向前走800ms
    BnsActionLateralWalkLeft(180)
    sleep 300
    BnsActionWalk(800)
    sleep 1000
    
    if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 120, "res\pic_dungeon_option") == 1) {
        loop 3 {
            ;按3次,防lag
            Send f
            sleep 200
        }

        sleep 2000

        if(BnsWaitMapLoadDone() == 0) {
            return 0
        }

    }
    else {
        ShowTipI("●[System] - ticket empty ...")
        ERR_CAUSE:="Ticket Empty"
        return 0
    }
}


;================================================================================================================
;================================================================================================================
;    ■ Hongsil's Secret Warehouse - 紅絲祕密倉庫
;================================================================================================================
;================================================================================================================
BnsMoveDungeon_HongsilWarehouse() {
    ShowTipI("●[System] - Move into dungeon HongsilWarehouse ...")

    loop, 3 {
        if(CONFUSE_PROTECT == 1) {
            ;向後轉180度(一次性)
            BnsActionRotationDuring(-2.755 * 180, 1)

            BnsActionLateralWalkRight(1600)
            BnsMoveDungeon_RandomConfuseProtection(3400)
        } 
        else {
            ;倒退到入口
            BnsActionLateralWalkLeft(1700)
            
            Send {s down}
            sleep 10000
            Send {s up}
        }

        sleep 1000

        if(FindPicList(0, 0, WIN_WIDTH, WIN_HEIGHT, 24, "res\pic_dungeon_option") == 1) {
            loop 3 {
                ;按3次,防lag
                Send f
                sleep 200
            }

            sleep 2000

            if(BnsWaitMapLoadDone() == 0) {
                return 0
            }
            
            return 1
        }
        else {
            ;沒對到入口，重飛龍脈
            BnsMapTeleport(0, WIN_BLOCK_WIDTH * 7.5, WIN_BLOCK_HEIGHT * 3.3)
        }
    }
    return 0
}

;================================================================================================================
;================================================================================================================
;    ■ Ghostface Theater - 鬼面劇團
;================================================================================================================
;================================================================================================================
BnsMoveDungeon_GhostfaceTheater() {
    ;向後轉180度(一次性)
    BnsActionRotationDuring(-2.755 * 180, 1)

    ShowTipI("●[System] - Move into dungeon GhostfaceTheater ...")

    if(CONFUSE_PROTECT == 1) {
        BnsMoveDungeon_RandomConfuseProtection(3500)
    }
    else {
        BnsActionSprint(2200)
    }

    sleep 1500

    if(BnsWaitMapLoadDone() == 0) {
        return 0
    }

    
}



