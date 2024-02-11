.Const

.Data?

.Data

patrat4 RECT <>

.Code

Window4Procedure Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_CREATE
		Invoke GetDlgItem, hWnd, IDC_WINDOW4_PICTURE1
		Invoke GetDC, Eax
		Mov _hCncDC, Eax

		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetWindowRect, Eax, Addr patrat4
		Fild patrat4.right
		Fild patrat4.left
		Fsub
		Fistp patrat4.right

		Fild patrat4.bottom
		Fild patrat4.top
		Fsub
		Fistp patrat4.bottom

		Invoke GetDlgItem, hWnd, IDC_WINDOW4_PICTURE1
		Invoke SetWindowPos, Eax, HWND_TOPMOST, 0, 0, patrat4.right, patrat4.bottom, SWP_NOZORDER
		Add patrat4.right, 6
		Add patrat4.bottom, 24
		Invoke SetWindowPos, hWnd, HWND_TOPMOST, patrat4.left, patrat4.top, patrat4.right, patrat4.bottom, SWP_SHOWWINDOW

		Invoke bugFix0_w4, hWnd

		Invoke EnableWindow, _hWnd2, FALSE

	.ElseIf uMsg == WM_COMMAND

	.ElseIf uMsg == WM_CLOSE
		Mov _hWnd4, 0
		Mov _hCncDC, 0
		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_BUTTON9
		Invoke EnableWindow, Eax, TRUE
		Invoke EnableWindow, _hWnd2, TRUE

;		Invoke IsModal, hWnd
;		.If Eax
;			Invoke EndModal, hWnd, IDCANCEL
;			Mov Eax, TRUE ;Return TRUE
;			Ret
;		.EndIf
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window4Procedure EndP

bugFix0_w4 Proc hWnd:DWord
	;bugFix #1
		Invoke GetWindowLong, hWnd, GWL_EXSTYLE
		Or Eax, WS_EX_LAYERED
		Invoke SetWindowLong, hWnd, GWL_EXSTYLE, Eax
		;Invoke CiupesteFundal, hWnd
		;Invoke RestRgnFer2, hWnd
		Invoke SetLayeredWindowAttributes, hWnd, 10, 255, LWA_ALPHA

	Ret
bugFix0_w4 EndP
