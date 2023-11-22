#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include cfg_Loader.ahk

;third-party library
#include libs\DesktopSwitcher\WinVirtualDesktopSwitcher.ahk
#include libs\PaddleOCR\PaddleOCR.ahk


;!!Importent for PixelGetColor, PixelSearch, value is screen|Window|Client, 
;if defulat is window, PixelGetColor will return 0x767676 in loop
;CoordMode, Pixel, Client
;CoordMode, Mouse, Client
;CoordMode, ToolTip, Client

;global DBUG=1
global ERR_CAUSE := ""

;the widows size value will be overlay if config.ini has value
global WIN_TITEL_HEIGHT := 32

global WIN_WIDTH := 1920
global WIN_HEIGHT := 1080 + WIN_TITEL_HEIGHT

global WIN_CENTER_X := WIN_WIDTH // 2
global WIN_CENTER_Y := WIN_HEIGHT // 2

global WIN_QUARTER_X := WIN_WIDTH // 4
global WIN_QUARTER_Y := WIN_HEIGHT // 4

global WIN_THREE_QUARTERS_X := WIN_WIDTH - WIN_QUARTER_X
global WIN_THREE_QUARTERS_Y := WIN_HEIGHT - WIN_QUARTER_Y

global WIN_BLOCK_WIDTH  := WIN_WIDTH // 32
global WIN_BLOCK_HEIGHT := WIN_HEIGHT // 16

global findX := 0
global findY := 0
global pixelColor := 0

global mouseOffsetX:=
global mouseOffsetY:=


global pLogfile

;================================================================================================================
;	Mosue Control (系統級API, 應付FPS級的遊戲) 
;================================================================================================================
;https://docs.microsoft.com/zh-tw/windows/win32/api/winuser/nf-winuser-mouse_event?redirectedfrom=MSDN

;滑鼠位置規正
MousePositionAdjust() {
	;計算 Screen 座標與 windows 座標偏移量，進行補正
	
	WinGetPos, X, Y, W, H, 劍靈

	mouseOffsetX := X	;偏差補正(手工調的)
	mouseOffsetY := Y   ;偏差補正(手工調的)
	DumpLogI("[MousePositionAdjust] Mouse Offset X:" mouseOffsetX ", Y:" mouseOffsetY ", winX:" X ", winY:" Y)




/*
	click
	sleep 100
	
	Send {Alt down}
	sleep 200
	
	;移動到螢幕最左上角 0,0 的值置
	DllCall("mouse_event", "UInt", 0x8001, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
	sleep 100

	;取得screen 0,0 在視窗中的座標
	MouseGetPos, mouseOffsetX, mouseOffsetY
	
 	mouseOffsetX -= 7	;偏差補正(手工調的)
	mouseOffsetY -= 7   ;偏差補正(手工調的)
	DumpLogI("[MousePositionAdjust] Mouse Offset x:" mouseOffsetX ", y:" mouseOffsetY)

	MouseMoveA(WIN_CENTER_X, WIN_CENTER_Y)
	sleep 100

	Send {Alt up}
	sleep 100 
*/
}


;滑鼠移動 - 絕對座標
MouseMoveA(x, y) {	;使用 0~65535表示螢幕最左到最右(最上到最下亦同)，需要轉換座標成 pixel 對應(會有換算誤差，盡量以原生的 MouseMove 算視窺內座標比較精準)
    sysX := 65535//A_ScreenWidth
    sysY := 65535//A_ScreenHeight
	
    DllCall("mouse_event", "UInt", 0x8001, "UInt", (x + mouseOffsetX) * sysX, "UInt", (y + mouseOffsetY) * sysY, "UInt", 0, "UPtr", 0)
}

;滑鼠移動 - 相對座標
MouseMoveR(x, y) {	;2倍的x y 才是正確對應視窗座標
	DllCall("mouse_event", "UInt", 0x01, "UInt", x * 2, "UInt", y * 2, "UInt", 0, "UPtr", 0)
}

;滑鼠滾輪 (1:向上滾，-1:向下滾)
MouseWheel(wheel, times) {
	loop, %times% {
		DllCall("mouse_event", "UInt", 0x0800, "UInt", 0, "UInt", 0, "UInt", wheel, "UPtr", 0)
		sleep 30
	}
}

;================================================================================================================
;	ImageSearch (以前景畫面找圖)
;================================================================================================================
FindPic(x0, y0, x1, y1, s, file) {
	ret := 0

    ImageSearch, getX, getY, x0, y0, x1, y1, *%s% %A_WorkingDir%\%file%
	global findX := getX
	global findY := getY
    
	if(DBUG == 1) {
		ShowTipD("[FindPic] ErrorLevel: " ErrorLevel ",  x:" getX ", y:" getY  "  [ src:" file ", lv:" s " ]")
	}

	;ErrorLeveL
	;0: found
	;1: not found
	;2: exception
	if(ErrorLevel == 0) {
		ret := 1
	}

	return ret
}


FindPicList(x0, y0, x1, y1, s, filelist) {
	Loop %filelist%*.png				;列出工作目錄下所有 file[n].png
	{
	
		;loop 篩出來的只有檔名，所以先分離輸入list帶的路徑，並補上
		SplitPath, fileList,,dir
		file = %dir%\%A_LoopFileName%

		if(FindPic(x0, y0, x1, y1, s, file) == 1) {
			return 1
		}
	}
	return 0
}

;================================================================================================================
;	PixelSearch (以前景畫面區域找色) 
;================================================================================================================
FindPixelRGB(x0, y0, x1, y1, colorHex, s) {
	ret := 0

	PixelSearch, getX, getY, x0, y0, x1, y1, colorHex, s, Fast RGB
	global findX := getX
	global findY := getY

    if(DBUG == 1) {
		ShowTipD("[FindPixelRGB] err: " ErrorLevel "  color:" colorHex ", s:" s ",  getX:" getX ",  getY:" getY)

		;Send {Alt down}
		;sleep 200
		;MouseMove getX, getY
		;sleep 5000
		;Send {Alt up}

		;sleep 3000
	}

	;ErrorLeveL
	;0: found
	;1: not found
	;2: exception
	if(ErrorLevel == 0) {
		ret := 1
	}

	return ret
}


;================================================================================================================
;	PixelGetColor (以前景畫面定點取色)
;================================================================================================================
GetPixelColor(sX, sY) {
	PixelGetColor, pixelColor, sX, sY, RGB
}

GetPixelColorRed(sX, sY) {
	GetPixelColor(sX, sY)
	
	return (pixelColor >> 16) & 0xFF
}

GetPixelColorGreen(sX, sY) {
	GetPixelColor(sX, sY)

	return (pixelColor >> 8) & 0xFF
}

GetPixelColorBlue(sX, sY) {
	GetPixelColor(sX, sY)
	
	return pixelColor & 0xFF 
}


;================================================================================================================
;	PixelGetColor (以前景畫面定點取色)
;================================================================================================================
GetPixelColorGray(sX, sY) {
	GetPixelColor(sX, sY)
	
	R := (pixelColor >> 16) & 0xFF
	G := (pixelColor >>  8) & 0xFF
	B :=  pixelColor        & 0xFF 

	Gray := (R*299 + G*587 + B*114 + 500) / 1000
	
	return Gray
}


;================================================================================================================
;	PixelGetAvgColor (以前景畫面取區域平均色)
;================================================================================================================
GetAverageColor(sX, sY, widthX, heightY) {
	VDBUG := 1

	;取樣9個點
	pX := widthX / 5
	pY := heightY / 5

	pArray := Array(9)

	i := 1

	loop, 3 {
		getY := sY + (pY * A_index)		
		
		loop 3 {
			getX := sX + (pX * A_Index)

			GetPixelColor(getX, getY)
			pArray[i] := pixelColor

			if(VDBUG == 1)
				ShowTipD("[GetAverageColor] index:" i ", getX:" getX ", getY:" getY ", color:" pArray[i])

			i++
		}
	}
	
	avgR := 0
	avgG := 0
	avgB := 0 
	
	for i, pColor in pArray	{
		R := (pColor >> 16) & 0xFF
		G := (pColor >>  8) & 0xFF
		B :=  pColor        & 0xFF 
		
		avgR += R
		avgG += G
		avgB += B

		if(VDBUG == 1) {
			ShowTipD("i:" i ", average color:" avgR )
		}
	}
	
	avgR := avgR / 9
	avgG := avgG / 9
	avgB := avgB / 9
	
	avgColor := ((avgR << 16) | (avgG << 8) | avgB)
	
	if(VDBUG == 1) {
		ShowTipD("[GetAverageColor] average color: 0x" ToBase(avgColor,16))
	}

	return avgColor
}


;Base converter
ToBase(n,b){  
	return (n < b ? "" : ToBase(n//b,b)) . ((d:=Mod(n,b)) < 10 ? d : Chr(d+55))  
}


;================================================================================================================
;	OCR (使用三方Lib PaddleOCR 做文字辦識)
;================================================================================================================
GetTextOCR(sX, sY, width, hight, hName) {
	;PaddleOCR 使用的是螢幕的絕對座標，需要對輸入的相對座標進行位移補正

	;取得視窗在螢幕上的絕對座標起始位置; 字串必需 % 包住才可使用
	WinGetPos, X, Y, W, H, %hName%

	;轉換為視窗內座標並文字辦識
	textOCR := PaddleOCR([X + sX, Y + sY, width, hight])

	if(DBUG == 1) {
		DumpLogD("[GetTextOCR] button text:" textOCR)
	}

	return textOCR
}


;================================================================================================================
;	Debug functions
;================================================================================================================
ShowTip(msg, x, y) {
	ToolTip, %msg%, %x%, %y%
}

;show debug & dump
ShowTipD(msg) {
	if(global LOGABLE >= 4) {
		ShowTip(msg, 80, 10)
		DumpFileLog("  D  " msg, 4)	;priority very low
	}
}

;show info & no dump
ShowTipI(msg) {
	if(global LOGABLE >= 3) {
		ShowTip(msg, 80, 10)
		DumpFileLog("  I  " msg, 3)	;priority low
	}
}

;show warning & dump
ShowTipW(msg) {
	if(global LOGABLE >= 2) {
		ShowTip(msg, 80, 10)
		DumpFileLog("  W  " msg, 2)	;priority middle
	}
}

;show error & dump
ShowTipE(msg) {
	if(global LOGABLE >= 1) {
		ShowTip(msg, 80, 10)
		DumpFileLog("  E  " msg, 1)	;priority high
	}
}

ShowMouseTip(msg) {
	ToolTip, %msg%
}


;only dump debug
DumpLogD(msg) {
	DumpFileLog("  D  " msg, 4)
}

;only dump info
DumpLogI(msg) {
	DumpFileLog("  I  " msg, 3)
}

;only dump warning
DumpLogW(msg) {
	DumpFileLog("  W  " msg, 2)
}

;only dump error
DumpLogE(msg) {
	DumpFileLog("  E  " msg, 1)
}


DumpFileLog(msg, lv) {
	global logfile
	global LOGABLE

	if(DUMPLOG == 1 && LOGABLE >= Abs(lv)) {
		dump := getTimeStamp() "  " msg "`r`n"
		pLogfile.Write(dump)
	}
}

DumpFileOpen() {
	global pLogfile
	global LOGABLE
	global LOGPATH

	if(DUMPLOG == 1 && LOGABLE > 0) {
		pLogfile := FileOpen(LOGPATH, "a", "UTF-8-RAW")
	}
}

DumpFileClose() {
	global plogfile
	global LOGABLE
	
	if(DUMPLOG == 1 && LOGABLE > 0) {
		pLogfile.close()
	}
}

ScreenShot() {
	Send {PrintScreen}
}


getTimeStamp() {
	return A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec "." A_msec
}
