.Const

.Data?
;Timer pointer
pTimer   	DD ?

;Max litere
nIMax	 	DD ?

;Buffer pentru caratere
szBuffer 	DB MAX_PATH Dup(?)
szNextChar  DB 1 Dup(?)

.Data
;Despre versiune
szAbout 	DB "CostyContur 1.0 - 17:48  31/Iulie/2012", 0

;Contor litere
nI       	DD 0

.Code

Window5Procedure Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_CREATE
		Invoke EnableWindow, _hWnd1, FALSE

		Invoke FadeIn, hWnd, 1
		Invoke GetWindowRect, hWnd, Addr _patrat
		Invoke SetWindowPos, hWnd, _nToggleTopMost, _patrat.left, _patrat.top, 0, 0, SWP_NOSIZE

		Invoke StrLen, Addr szAbout
		Mov nIMax, Eax
		Invoke Scr0113r

	.ElseIf uMsg == WM_COMMAND
		.If wParam == IDC_WINDOW5_BTNCLOSE
			Invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.ElseIf wParam == IDC_WINDOW5_STATIC5
			Jmp @F
				szOpen DB "Open", 0
				szFile DB "http://costycnc.xhost.ro/", 0
@@:

			Invoke ShellExecute, hWnd, Addr szOpen, Addr szFile, NULL, NULL, SW_MAXIMIZE

		.EndIf

	.ElseIf uMsg == WM_KEYUP
		.If wParam == VK_ESCAPE
			Invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.EndIf

	.ElseIf uMsg == WM_TIMER
		Invoke Scr0113r

	.ElseIf uMsg == WM_CLOSE
		Invoke EnableWindow, _hWnd1, TRUE
		Mov _hWnd5, 0
		Invoke FadeOut, hWnd, 1

		Invoke IsModal, hWnd
		.If Eax
			Invoke EndModal, hWnd, IDCANCEL
			Mov Eax, TRUE ;Return TRUE
			Ret
		.EndIf
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window5Procedure EndP

Window5btnClose Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_KEYUP
		.If wParam == VK_ESCAPE
			Invoke SendMessage, _hWnd5, WM_CLOSE, 0, 0
		.EndIf
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window5btnClose EndP

;Window5picCosty Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5picCosty EndP

;Window5PicMarius Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5PicMarius EndP

;Window5Static2 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static2 EndP

;Window5Static3 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static3 EndP

;Window5Static4 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static4 EndP

;Window5Static5 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static5 EndP

;Window5Static6 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static6 EndP

;Window5Static7 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static7 EndP

;Window5Static8 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static8 EndP

;Window5Static9 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static9 EndP

;Window5Static10 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
;	Xor Eax, Eax	;Return FALSE
;	Ret
;Window5Static10 EndP

Scr0113r Proc
	Mov Eax, nIMax
	Mov Ebx, Eax
	Add Ebx, 35
	.If nI >= 0 && nI <= Eax
		Mov Eax, Offset szAbout
		Mov Ebx, 0
		Mov Ecx, nI
		Mov Ebx, [Eax + Ecx]
		And Ebx, 0000000FFH

		Mov Eax, Offset szNextChar
		Mov [Eax], Ebx

		Invoke szCatStr, Addr szBuffer, Addr szNextChar
		Invoke SetDlgItemText, _hWnd5, IDC_WINDOW5_STATIC10, Addr szBuffer
	.ElseIf nI == Ebx
		Mov nI, -1
		Invoke GolesteString, Addr szBuffer, nIMax
	.EndIf

	Inc nI

	Ret
Scr0113r EndP


