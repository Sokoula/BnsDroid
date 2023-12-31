﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;- system -----------------------------------
#include bns_common.ahk
#include bns_strings.ahk
#include bns_CharacterManager.ahk
#include bns_PartyController.ahk
#include bns_OperationUtilsF8.ahk
#include bns_MapTeleportController.ahk
;#include bns_DungeonDispaterF8.ahk
;#include bns_DungeonNavigation.ahk

;- dungeon ---------------------------------
#include bns_Droid_CelestialBasinKeys.ahk           ;天之盆地鑰匙
#include bns_Droid_KaebiVillage.ahk                 ;鬼怪村
#include bns_Droid_HongsilWarehouse.ahk             ;紅絲秘密倉庫
#include bns_Droid_SuspiciousSkyIsland.ahk          ;可疑的空島
#include bns_Droid_GreatWindwalkRace.ahk            ;天下第一輕功大會
#include bns_Droid_GhostfaceTheater.ahk             ;鬼面劇團
#include bns_Droid_SandstormTemple.ahk              ;沙暴神殿
#include bns_Droid_WanderingShip.ahk                ;青空流浪船
#include bns_Droid_ChaosSupplyChain.ahk             ;混沌補給基地
#include bns_Droid_AltarOfTheInfinite.ahk           ;崑崙派本山
#include bns_Droid_ChaosBlackShenmu.ahk             ;混沌黑神木
#include bns_Droid_ChimeraLab.ahk                   ;黑龍教異變研究所
#include bns_Droid_ChaosYetiCave.ahk                ;混沌雪人洞窟
#include bns_Droid_ShroudedAjanara.ahk              ;千手羅漢陣
#include bns_Droid_GiantsHart.ahk                   ;巨神之心
#include bns_Droid_FourInOne.ahk                    ;周任四合一


;!!!!!!!注意!!!!!!!!!!!!!!!!
;預設參數是以 劍靈 界面大小設為 80 為主，不同設定請重新校準(包含算座標及重新抓圖)
;參數設定值的順序為 Config.ini > main.ahk(副本參數)/common.ahk(系統參數)/bns_common.ahk(劍靈參數)

global ACTIVITY := 0          ;當前活動副本(入門才會有)

global PARTY_MODE := 2        ;組隊模式: 1:入門, 2:一般, 3:困難
global DEMONSBANE_LEVEL := 3    ;封魔錄等級

global MISSION_ACCEPT := 0     ;是否需要與接廣場NPC交談並接任務

global PARTY_MEMBERS := "1,0,1,2,3,4"
global FIGHTING_MEMBERS := 1



Class BnsDungeonManager {

    ;AHK class constructor
    __new() {
        return this
    }

    ;AHK class destructor
    __delete() {
    }

;================================================================================================================
;    █ FUNCTION - Dungeon Run
;================================================================================================================
    dungeonRun(index) {
        ret:=1

        switch index
        {
            case 001:
                ret:=this.runnableCelestialBasinKeys()

            case 101:
                ret:=this.runnableKaebiVillage()

            case 102:
                ret:=this.runnableHongsilWarehouse()

            case 103:
                ret:=this.runnableSuspiciousSkyIsland()

            case 104:
                ret:=this.runnableGreatWindwalkRace()

            case 201:
                ret:=this.runnableGhostfaceTheater()

            case 202:
                ;TODO: 未完成

            case 203:
                ;TODO: 青空船已改為普通副本, 需修改腳本
                ret:=this.runnableWanderingShip()

            case 204:
                ret:=this.runnableChaosSupplyChain()

            case 205:
                ret:=this.runnableAltarOfTheInfinite()

            case 206:
                ret:=this.runnableChaosBlackShenmu()

            case 207:
                ret:=this.runnableChimeraLab()

            case 208:
                ;TBD

            case 209:
                ;TBD

            case 210:
                ret:=this.runnableChaosYetiCave()

            case 301:
                ret:=this.runnableShroudedAjanara()

            case 302:
                ret:=this.runnableGiantsHart()

        }

        return ret
    }



;================================================================================================================
;    ■ Hero Dungeon Loader - 英雄
;================================================================================================================
    loadHero(tag, mode, index) {
        ShowTipI("●[System] - Select Hero Dungeon" tag "...")
        DumpLogD("[BnsGoDungeon_HeroLoader] tag:'" tag "', index:" index ", scroll:" scroll)

        MouseClick left     ;切完桌面點一下, 防止後續操作失效

        if(mode < 1 || mode > 3) {
            ShowTipE("●[Exception] Illegal party mode " mode ", unknown mode.")
            return 0
        }

        ;1: 英雄, 2:封魔
        if(BnsOuF8SelectPartyType(1) > 1) {
            sleep 3500
        }

        ;1: 入門, 2:一般, 3:熟練
        if(BnsF8SelectPartyMode(mode) > 1) {
            sleep 3500
        }

        if(mode == 1) {
            index := index + ACTIVITY
        }

        ;計算副本清單捲動(單頁顯示為7個,滾輪一次替換一個)
        if(index > 7) {
            scroll := index - 7
            index := 7
        }

        ;尋找清單項目
        if(BnsOuF8SelectHeroDungeon(index, scroll) == 1) {
            sleep 1000

            ;點擊出發等候室倒數5秒
            BnsOuF8TapStartButton()
            sleep 5000

            return BnsWaitMapLoadDone()
        }
        else {
            ShowTipE("●[Exception] - locate dungeon tab failed")
            return 0
        }
    }


;================================================================================================================
;    ■ Demonsbane Dungeon Loader - 封魔錄
;================================================================================================================
    ;載入封魔錄;  [ tag ] string();  [ level ] 封魔錄等級;  [ index ] 選項卡順序
    loadDemonsbane(tag, level, index) {
        ShowTipI("●[System] - Select Aerodrome Dungeon " tag "...")

        scroll := index > 3 ? mod(index, 3) : 0        ;一次只顯示3個封魔本，超過的要滾輪，一次一個本
        DumpLogD("[BnsGoDungeon_DemonsbaneLoader] tag:'" tag "', level:" level ", index:" index ", scroll:" scroll)

        ;點擊封魔錄標籤
        BnsOuF8SelectPartyType(2)

        ; sleep 4000

        if(BnsOuF8SelectDemonsbaneDungeon(level, index - scroll, scroll) == 1) {
            sleep 1000

            ;點擊出發等候室倒數5秒
            BnsOuF8TapStartButton()
            sleep 5000


            return BnsWaitMapLoadDone()
        }
        else {
            ShowTipE("●[Exception] - locate dungeon tab failed")
            return 0
        }

    }


;================================================================================================================
;    ■ 001 - CelestialBasinKeys - 天之盆地鑰匙(地表)
;================================================================================================================
    runnableCelestialBasinKeys() {

        BnsDroidRun_CelestialBasinKeys()

        ;BnsMoveDungeon_CelestialBasinKeys()
    }



;================================================================================================================
;    ■ 101 - Kaebi Village - 鬼怪村(活動地表)
;================================================================================================================
    runnableKaebiVillage() {
        if(BnsCmIsProfileLoaded() == 0) {
            BnsCmLoadCharProfiles(BnsDroidKaebiVillage.getCharacterProfiles())    ;載入Character Profiles
        }

        if(BnsCmIsProfilesEOF() == 0) {
            if(BnsCmGetName(BnsCmGetProfile(0)) != BnsGetName()) {
                BnsGoCharacterHall()
            }

            BnsCmChangeCharacter(BnsCmGetProfile(0))    ;切換角色, 0:取得當前 profile
        }
        else {
            return 0    ;finish all character profiles, stop
        }

        round := BnsCmGetMissionTimes()

        droid := new BnsDroidKaebiVillage()

        loop %round% {
            ret := 1

            if(droid.dungeonNavigation() == 0) {
                break           ;沒有入場券了
            }

            ret := droid.start()    ;開始執行攻略腳本

            if(ret != 0) {
                droid.finish()        ;腳本收尾
            }
        }

        BnsCmProfileNext()    ;切換到下一個 profile
        return ret
    }


;================================================================================================================
;    ■ 102 - Hongsil's Secret Warehouse  - 紅絲秘密倉庫(活動地表)
;================================================================================================================
    runnableHongsilWarehouse() {

        if(BnsCmIsProfileLoaded() == 0) {
            BnsCmLoadCharProfiles(BnsDroidGetCP_HongsilWarehouse())    ;載入Character Profiles
        }

        if(BnsCmIsProfilesEOF() == 0) {
            BnsGoCharacterHall()

            BnsCmChangeCharacter(BnsCmGetProfile(0))    ;切換角色, 0:取得當前 profile

            BnsCmProfileNext()    ;切換到下一個 profile
        }
        else {
            return 0    ;finish all character profiles, stop
        }

        loop {
            if(BnsDroidNavigation_HongsilWarehouse() == 0) {
                return 1
            }

            sleep 3000

            BnsDroidRun_HongsilWarehouse()
        }
    }


;================================================================================================================
;    ■ 103 - Suspicious Sky Island  - 可疑的空島(活動統合)
;================================================================================================================
    runnableSuspiciousSkyIsland() {

        if(BnsCmIsProfileLoaded() == 0) {
            BnsCmLoadCharProfiles(BnsDroidSuspiciousSkyIsland.getCharacterProfiles())    ;載入Character Profiles
        }

        if(BnsCmIsProfilesEOF() == 0) {
            if(BnsCmGetName(BnsCmGetProfile(0)) != BnsGetName()) {
                BnsGoCharacterHall()
            }
            BnsCmChangeCharacter(BnsCmGetProfile(0))    ;切換角色, 0:取得當前 profile
        }
        else {
            return 0    ;finish all character profiles, stop
        }

        ;地表到F8導航
        BnsOuF8EarthGoLobby()
        sleep 3000

        this.loadHero("SuspiciousSkyIsland", 1, 1)  ;活動只會出現在入門

        droid := new BnsDroidSuspiciousSkyIsland()
        if(droid.dungeonNavigation() == 0) {
            return 0
        }

        ;開始攻略副本
        ret := droid.start()

        if(ret != 0) {
            droid.finish()        ;腳本收尾
        }

        BnsCmProfileNext()    ;切換到下一個 profile

        return ret
    }



;================================================================================================================
;    ■ 104 - Great Windwalk Race  - 輕功傳說大會(活動統合)
;================================================================================================================
    runnableGreatWindwalkRace() {
        ret := 0

        droid := new BnsDroidGreatWindwalkRace()

        loop 20 {

            if(droid.dungeonNavigation() == 1) {
                ret := droid.start()    ;開始執行攻略腳本

                if(ret != 0) {
                    droid.finish()        ;腳本收尾
                }

            }
            else {
                ret := 0    ;超過活動時段
                break
            }

        }

        return ret
    }


;================================================================================================================
;    ■ 201 - GhostfaceTheater - 鬼面劇團(地表)
;================================================================================================================
    runnableGhostfaceTheater() {
        BnsDroidRun_GhostfaceTheater()

        ;BnsGoDungeon_GhostfaceTheater()
        BnsDroidNavigation_GhostfaceTheater()



        ;BnsOuF8GobackLobby()
    }


;================================================================================================================
;    ■ 202 - SandstormTemple - 沙暴神殿(F8)
;================================================================================================================
    ;@Discard
    ;runnableSandstormTemple() {
    ;    this.loadHero("SandstormTemple", PARTY_MODE, 12 + ACTIVITY)

    ;    BnsDroidRun_GhostfaceTheater()

        ;BnsGoDungeon_GhostfaceTheater()
    ;    BnsMoveDungeon_GhostfaceTheater()

        ;BnsOuF8GobackLobby()
    ;}


;================================================================================================================
;    ■ 203 - WanderingShip - 青空流浪船(F8)
;================================================================================================================
    ;@Discard
    runnableWanderingShip() {
        this.loadHero("WanderingShip", PARTY_MODE, 2 + ACTIVITY)

        BnsDroidNavigation_WanderingShip()

        BnsDroidRun_WanderingShip()

        BnsOuF8GobackLobby()
    }


;================================================================================================================
;    ■ 204 - ChaosSupplyChain - 混沌補給基地(F8)
;================================================================================================================
    runnableChaosSupplyChain() {
        ret := 0

        BnsPcRoomTeamUp()

        this.loadDemonsbane("ChaosSupplyChain", DEMONSBANE_LEVEL, 4)

        BnsPcTeamMembersSquareNavigation(2)    ;2:封魔錄進場, 1:只確認最後進場過圖完畢

        droid := new BnsDroidChaosSupplyChain()
        ; droid.isSpecialStageDetected()
        ; droid.dungeonNavigation()

        ret := droid.start()    ;開始執行攻略腳本

        if(ret != 0) {
            droid.finish()        ;腳本收尾
        }

        ;0:確認每個隊員都過完圖回到等候室, 1:只確認最後一個隊員過圖完畢回等候室(預設)
        BnsPcTeamMembersRetreatToLobby()
    }

    runnableChaosSupplyChainLegacy() {
        ; ret := 0

        ; BnsPcRoomTeamUp()

        ; this.loadDemonsbane("ChaosSupplyChain", DEMONSBANE_LEVEL, 4)
        ; sleep 2000
        ; ; BnsDroidNavigation_ChaosSupplyChain()

        ; BnsPcTeamMembersSquareNavigation(2)    ;2:封魔錄進場

        ; ret := BnsDroidRun_ChaosSupplyChain()
        ; sleep 1000
        ; ; BnsOuF8GobackLobby()

        ; ; if(ret == 0) {    ;打手死亡 or 戰鬥超時
        ;     ; BnsPcTeamMembersRetreatToLobby()
        ; ; }
        ; ; else {    ;完成
        ;     ; BnsPcTeamMembersPickReward("BnsDroidMembersPickReward_ChaosSupplyChain")
        ; ; }


        ; if(ret == 1) {    ;完成, 掛機隊友撿箱
        ;     BnsPcTeamMembersPickReward("BnsDroidMembersPickReward_ChaosSupplyChain")
        ; }

        ; BnsPcTeamMembersRetreatToLobby()
    }


;================================================================================================================
;    ■ 205 - AltarOfTheInfinite - 崑崙派本山(F8)
;================================================================================================================
    runnableAltarOfTheInfinite() {
        ret := 0

        BnsPcRoomTeamUp()
        this.loadHero("AltarOfTheInfinite", PARTY_MODE, 3)

        BnsPcTeamMembersSquareNavigation(1, 1)    ;英雄本進場, 1:只確認最後進場過圖完畢

        droid := new BnsDroidAltarInfinite()
        ret := droid.start()    ;開始執行攻略腳本

        if(ret != 0) {
            droid.finish()        ;腳本收尾
        }

        ;0:確認每個隊員都過完圖回到等候室, 1:只確認最後一個隊員過圖完畢回等候室(預設)
        BnsPcTeamMembersRetreatToLobby()

        return ret
    }



;================================================================================================================
;    ■ 206 - ChaosBlackShenmu - 混沌黑神木(F8)
;================================================================================================================
    runnableChaosBlackShenmu() {
        ; 初次以 class 方式實現腳本, 與蘭蘭需要外部操作協助不同, 腳本內已整合多人處理
        ret := 0

        BnsPcRoomTeamUp()

        ; this.loadDemonsbane("ChaosBlackShenmu", DEMONSBANE_LEVEL, 3)
        this.loadHero("ChaosBlackShenmu", PARTY_MODE, 2)

        ; BnsPcTeamMembersSquareNavigation(2, 1)    ;2:封魔錄進場, 1:只確認最後進場過圖完畢
        BnsPcTeamMembersSquareNavigation(1, 1)      ;英雄本進場, 1:只確認最後進場過圖完畢

        droid := new BnsDroidChaosBlackShenmu()
        ; droid.isSpecialStageDetected()
        ; droid.dungeonNavigation()

        ret := droid.start()    ;開始執行攻略腳本

        if(ret != 0) {
            droid.finish()        ;腳本收尾
        }

        ;0:確認每個隊員都過完圖回到等候室, 1:只確認最後一個隊員過圖完畢回等候室(預設)
        BnsPcTeamMembersRetreatToLobby()

        return ret
    }


;================================================================================================================
;    ■ 207 - ChimeraLab - 黑龍教異變研究所(F8)
;================================================================================================================
    runnableChimeraLab() {
        ret := 0
        BnsPcRoomTeamUp()

        ; this.loadDemonsbane("ChimeraLab", DEMONSBANE_LEVEL, 3)
        this.loadHero("ChaosBlackShenmu", PARTY_MODE, 1)

        BnsPcTeamMembersSquareNavigation(2)    ;2:封魔錄進場, 1:只確認最後進場過圖完畢

        droid := new BnsDroidChimeraLab()
        ret := droid.start()    ;開始執行攻略腳本

        if(ret != 0) {
            droid.finish()        ;腳本收尾
        }

        ;0:確認每個隊員都過完圖回到等候室, 1:只確認最後一個隊員過圖完畢回等候室(預設)
        BnsPcTeamMembersRetreatToLobby()

        return ret
    }


;================================================================================================================
;    ■ 208 -  - 黑龍教降臨殿(F8)
;================================================================================================================
    ;TBD




;================================================================================================================
;    ■ 209 -  - 搖風島(F8)
;================================================================================================================
    ;TBD


;================================================================================================================
;    ■ 210 -  - 混沌雪人洞窟(F8)
;================================================================================================================
    runnableChaosYetiCave() {
        ret := 0

        BnsPcRoomTeamUp()
        this.loadDemonsbane("ChaosYetiCave", DEMONSBANE_LEVEL, 2)

        BnsPcTeamMembersSquareNavigation(2)    ;2:封魔錄進場, 1:只確認最後進場過圖完畢

        droid := new BnsDroidChaosYetiCave()
        ret := droid.start()

        if(ret != 0) {
            droid.finish()
        }

        sleep 2000

        ;0:確認每個隊員都過完圖回到等候室, 1:只確認最後一個隊員過圖完畢回等候室(預設)
        BnsPcTeamMembersRetreatToLobby()

        return ret
    }


;================================================================================================================
;    ■ 301 - ShroudedAjanara - 千手羅漢陣(地表)
;================================================================================================================
    runnableShroudedAjanara() {
        ret := 0

        if(BnsCmIsProfileLoaded() == 0) {
            BnsCmLoadCharProfiles(BnsDroidShroudedAjanara.getCharacterProfiles())    ;載入Character Profiles
        }

        if (BnsCmIsProfilesValid()) {
            if(!BnsCmIsProfilesEOF()) {
                if(BnsCmGetName(BnsCmGetProfile(0)) != BnsGetName()) {
                    BnsGoCharacterHall()
                }
                BnsCmChangeCharacter(BnsCmGetProfile(0))    ;切換角色, 0:取得當前 profile
            }
            else {
                ;所有角色跑完了, 停止TASK任務
                return 0
            }
        }

        round := BnsCmGetMissionTimes()

        droid := new BnsDroidShroudedAjanara()

        loop %round% {
            droid.dungeonNavigation()

            ret := droid.start()    ;開始執行攻略腳本

            if(ret != 0) {
                droid.finish()        ;腳本收尾
            }
        }


        BnsCmProfileNext()    ;切換到下一個 profile

        return ret
    }



;================================================================================================================
;    ■ 302 - Giant's Hart  - 巨神之心(偽統合)
;================================================================================================================
    runnableGiantsHart() {

        if(BnsCmIsProfileLoaded() == 0) {
            BnsCmLoadCharProfiles(BnsDroidGiantsHart.getCharacterProfiles())    ;載入Character Profiles
        }

        if(BnsCmIsProfilesEOF() == 0) {
            BnsGoCharacterHall()

            BnsCmChangeCharacter(BnsCmGetProfile(0))    ;切換角色, 0:取得當前 profile

            BnsCmProfileNext()    ;切換到下一個 profile
        }
        else {
            return 0    ;finish all character profiles, stop
        }

        droid := new BnsDroidGiantsHart()

        if(droid.start() != 0) {
            droid.finish()
        }

        return ret
    }

}