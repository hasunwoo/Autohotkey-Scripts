#Requires AutoHotkey v2.0

; exe: 실행할 프로그램 경로
; arg: (선택) 전달할 인자
RunEx(exe, arg := "") {
    pid := 0
    Run('"' exe '" ' arg, , , &pid)   ; PID 반환
    if(pid == 0) {
        MsgBox("프로세스 실행 실패")
        return
    }
    WinWait("ahk_pid " pid)        ; 윈도우 뜰 때까지 대기
    return WinExist("ahk_pid " pid) ; 핸들 반환
}

; 정확한 위치/크기 얻기 https://www.autohotkey.com/boards/viewtopic.php?t=121430
WinGetPosEx(&X?, &Y?, &W?, &H?, hwnd*) {
    static DWMWA_EXTENDED_FRAME_BOUNDS := 9
    hwnd := WinExist(hwnd*)
    DllCall("dwmapi\DwmGetWindowAttribute"
        , "ptr" , hwnd
        , "uint", DWMWA_EXTENDED_FRAME_BOUNDS
        , "ptr" , RECT := Buffer(16, 0)
        , "uint", RECT.size
        , "uint")
    X := NumGet(RECT, 0, "int")
    Y := NumGet(RECT, 4, "int")
    W := NumGet(RECT, 8, "int") - X
    H := NumGet(RECT, 12, "int") - Y
}

; 정확한 이동 https://www.autohotkey.com/boards/viewtopic.php?t=121430
WinMoveEx(X?, Y?, W?, H?, hwnd*) {
    hwnd := WinExist(hwnd*)
    if WinGetMinMax("ahk_id " hwnd) != 0
        WinRestore("ahk_id " hwnd)

    ; 프레임 오프셋 계산
    WinGetPosEx(&fX, &fY, &fW, &fH, hwnd)
    WinGetPos(&wX, &wY, &wW, &wH, hwnd)
    xDiff := fX - wX
    hDiff := wH - fH

    ; 새 좌표/크기 계산
    IsSet(X) && nX := X - xDiff
    IsSet(Y) && nY := Y
    IsSet(W) && nW := W + (xDiff * 2)
    IsSet(H) && nH := H + hDiff

    WinMove(nX?, nY?, nW?, nH?, hwnd?)
}

; 화면 분할
VerticalSplitWindows(win1, win2) {
    L := 0, T := 0, R := 0, B := 0
    MonitorGetWorkArea(1, &L, &T, &R, &B)

    Width  := R - L
    Height := B - T
    halfW  := Floor(Width / 2)

    WinMoveEx(L,         T, halfW, Height, win1)
    WinMoveEx(L + halfW, T, halfW, Height, win2)
}

; 실행
win1 := RunEx("explorer.exe")
win2 := RunEx("bandizip.exe")

VerticalSplitWindows(win1, win2)
