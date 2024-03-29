﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ToolTipVisible := 0

;Gui, Add, Text, , TextHere
;Gui, Show, W100, H100
;Gui, +Resize

; Helper functions

; Converts rgb colors to HSV object
RGBtoHSV(red,green,blue)
{
    r := red/255
    g := green/255 
    b := blue/255
    cMax := Max(r,g,b)
    cMin := Min(r,g,b) 
    delta := cMax - cMin

    hue := 0
    if (delta > 0 ){
        if( cMax = r ){
            hue := 60 * Mod((g - b)/delta,6)       
        } else if( cMax = g ){
            hue := 60 * ((b - r)/delta + 2)
        } else if( cMax = b ){
            hue := 60 * ((r-g)/delta + 4)
        }
    }

    if(cMax = 0){
        sat := 0
    } else {
        sat := delta / cMax
    }
    
    return {h:hue,s:sat,v:cMax} 
}

; Converts a hex number in the form of 0xFFFFFF to RGB object
HexToRGB(hexVal)
{
    r := % Format("{1:d}","0x" . SubStr(hexVal, 3, 2))
    g := % Format("{1:d}","0x" . SubStr(hexVal, 5, 2))
    b := % Format("{1:d}","0x" . SubStr(hexVal, 7, 2)) 
    return {r:r,g:g,b:b}
}

; Gets the name of an RGB hex color, i.e. 0xFFFFFF returns white
GetHexColorName(h,s,v)
{
    ; Construct the color string
    ; Prefixes: Dark, Light, Bright (or no prefix)
    ; Bases: White, Black, Grey, ROYGCBVM
    
    ;special case 1
    if(v = 0)
    {
        return "Black"
    }

    if(s = 0)
    {
        if(v > .95) {
            return "White"
        } else if( v > .75){
            return "Silver"
        } else if(v > .5){
            return "Grey"
        } else if(v > .15){
            return "Dark Grey"
        } else {
            return "Black"
        }
    }

    prefix := ""
    if(v > 0 and v < .75)
    {
        prefix := "Light"
    } 
    else if(s >= .85)
    {
        prefix := "Bright"
    }

    
    
    if(True) 
    {
        if(h < 0)
        {
            h := 360 + h
        }

        if(h < 15)
        {
            return prefix " " "Red"
        } else if(h < 45){
            return "Orange"
        } else if(h < 75){
            return "Yellow"
        } else if(h < 105){
            return "Yellow-Green"
        } else if(h < 135){
            return "Green"
        } else if(h < 165){
            return "Cyan-Green"
        } else if(h < 195){
            return "Cyan"
        } else if(h < 225){
            return "Blue"
        } else if(h < 255){
            return "Royal Blue"
        } else if(h < 285){
            return "Violet"
        } else if(h < 315){
            return "Magenta"
        } else if(h < 345){
            return "Dark Magenta"
        } else {
            return "Red"
        }
    }
}

; Run on the CTRL + ` (left of 1 key on US keyboard)
^`::
if TooltipVisible > 0
{
    ToolTipVisible := 0
    ToolTip
}
else
{   
    ToolTipVisible := 1
    MouseGetPos, MouseX, MouseY
    PixelGetColor, color, %MouseX%, %MouseY%, RGB
    ;ToolTip, Color is %color%, %MouseX%, %MouseY%
    rgb := HexToRGB(color)
    hsv := RGBtoHSV(rgb.r,rgb.g,rgb.b)
    colorName := GetHexColorName(hsv.h,hsv.s,hsv.v) ": " . hsv.h "," hsv.s "," hsv.v
    Tooltip, %colorName%, %MouseX%, %MouseY% 
    ;TrayTip, , %colorName%, 1, 17
}
return

^F1::
FileRead, rgbFileContents, rgb.txt
if not ErrorLevel
{
    MouseGetPos, MouseX, MouseY
    PixelGetColor, color, %MouseX%, %MouseY%, RGB
    
    regex := "O)(.*).#" SubStr(color,3,6)
    FoundPos := RegExMatch(rgbFileContents, regex, OutputVar,1)
    MsgBox, % OutputVar.Value(1)`
}
else
{
    MsgBox, %A_LastError%
} 
return