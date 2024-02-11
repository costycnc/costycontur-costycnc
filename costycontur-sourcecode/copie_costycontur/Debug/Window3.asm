.Const

.Data?
Xvechi  	Word ?
Yvechi  	Word ?
Xrelativ	Word ?
Yrelativ	Word ?
Xnou		Word ?
Ynou		Word ?
hDC1		DD 	 ?
hDC2		DD   ?
hDC3		DD   ?

.Data

;STRUCTURI
punct3  POINT <>
patrat3 RECT <>

.Code

Window3Procedure Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_CREATE
		Invoke bugFix0_w3, hWnd

	.ElseIf uMsg == WM_COMMAND
		.If wParam == IDC_WINDOW3_BTNINTERPRETEAZA
;			Invoke ShowManualDebugFocusRect

			.If _bDebugFocusRect || _bDebugPixelMove
				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

				Mov _bDebugFocusRect, 0
				Mov _bDebugPixelMove, 0

			.EndIf

			Invoke SendMessage, _hWnd2, WM_COMMAND, IDC_WINDOW2_BUTTON8, 0
		.ElseIf wParam == IDC_WINDOW3_BTNSUS
			Mov Eax, 0
			Mov Ax, _Xbusit
			Mov Ebx, 0
			Mov Bx, _Ybusit
			Dec Ebx

			.If Ebx >= 6
				Invoke ManualPixWinDC, Eax, Ebx, 0
				Mov _bDebugFocusRect, FALSE

				.If !_bDebugFocusRect
					Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
					Invoke GetDC, Eax
					Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

					Mov Eax, 0
					Mov Ax, _Xbusit
					Sub Eax, 26
					Mov Ebx, 0
					Mov Bx, _Ybusit
					Sub Ebx, 20
					Mov _dbgFocusRect.left, Eax
					Mov _dbgFocusRect.top, Ebx
					Mov _dbgFocusRect.right, Eax
					Mov _dbgFocusRect.bottom, Ebx
					Add _dbgFocusRect.right, 53
					Add _dbgFocusRect.bottom, 40

					Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
					Invoke GetDC, Eax
					Invoke DrawFocusRect, Eax, Addr _dbgFocusRect
					Mov _bDebugPixelMove, TRUE

				.EndIf


			.EndIf

		.ElseIf wParam == IDC_WINDOW3_BTNJOS
			Mov Eax, 0
			Mov Ax, _Xbusit
			Mov Ebx, 0
			Mov Bx, _Ybusit
			Inc Ebx
			Invoke ManualPixWinDC, Eax, Ebx, 0
			Dec _Ybusit

			.If !_bDebugFocusRect
				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

				Mov Eax, 0
				Mov Ax, _Xbusit
				Sub Eax, 26
				Mov Ebx, 0
				Mov Bx, _Ybusit
				Sub Ebx, 20
				Mov _dbgFocusRect.left, Eax
				Mov _dbgFocusRect.top, Ebx
				Mov _dbgFocusRect.right, Eax
				Mov _dbgFocusRect.bottom, Ebx
				Add _dbgFocusRect.right, 53
				Add _dbgFocusRect.bottom, 40

				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect
				Mov _bDebugPixelMove, TRUE

			.EndIf

			Inc _Ybusit
			Mov _bDebugFocusRect, FALSE

		.ElseIf wParam == IDC_WINDOW3_BTNSTANGA
			Mov Eax, 0
			Mov Ax, _Xbusit
			Dec Eax
			Mov Ebx, 0
			Mov Bx, _Ybusit
			.If Eax >= 8
				Invoke ManualPixWinDC, Eax, Ebx, 0
				Mov _bDebugFocusRect, FALSE

				.If !_bDebugFocusRect
					Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
					Invoke GetDC, Eax
					Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

					Mov Eax, 0
					Mov Ax, _Xbusit
					Sub Eax, 26
					Mov Ebx, 0
					Mov Bx, _Ybusit
					Sub Ebx, 20
					Mov _dbgFocusRect.left, Eax
					Mov _dbgFocusRect.top, Ebx
					Mov _dbgFocusRect.right, Eax
					Mov _dbgFocusRect.bottom, Ebx
					Add _dbgFocusRect.right, 53
					Add _dbgFocusRect.bottom, 40

					Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
					Invoke GetDC, Eax
					Invoke DrawFocusRect, Eax, Addr _dbgFocusRect
					Mov _bDebugPixelMove, TRUE
				.EndIf

			.EndIf

		.ElseIf wParam == IDC_WINDOW3_BTNDREAPTA
			Mov Eax, 0
			Mov Ax, _Xbusit
			Inc Eax
			Mov Ebx, 0
			Mov Bx, _Ybusit
			Invoke ManualPixWinDC, Eax, Ebx, 0

			.If !_bDebugFocusRect
				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

				Mov Eax, 0
				Mov Ax, _Xbusit
				Sub Eax, 26
				Mov Ebx, 0
				Mov Bx, _Ybusit
				Sub Ebx, 20
				Mov _dbgFocusRect.left, Eax
				Mov _dbgFocusRect.top, Ebx
				Mov _dbgFocusRect.right, Eax
				Mov _dbgFocusRect.bottom, Ebx
				Add _dbgFocusRect.right, 53
				Add _dbgFocusRect.bottom, 40

				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect
				Mov _bDebugPixelMove, TRUE
			.EndIf

			Mov _bDebugFocusRect, FALSE

		.EndIf

	.ElseIf uMsg == WM_PAINT
;		Invoke PastreazaDCVechi


	.ElseIf uMsg == WM_CLOSE
		Invoke GetWindowRect, _hWnd3, Addr patrat3
		Mov Eax, patrat3.left
		Mov _Win3OldX, Eax
		Mov Eax, patrat3.top
		Mov _Win3OldY, Eax

		Invoke ShowWindow, hWnd, FALSE
		Invoke SetForegroundWindow, _hWnd2

		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_BUTTON8
		Invoke EnableWindow, Eax, TRUE

		Invoke GetMenu, _hWnd2
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSTARTINTERPRETOR, MF_ENABLED

		Invoke ShowManualDebugFocusRect
		Mov _bDebugFocusRect, FALSE

		.If _bDebugPixelMove
			Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
			Invoke GetDC, Eax
			Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

			Mov _bDebugPixelMove, FALSE

		.EndIf

		Return TRUE
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window3Procedure EndP

Window3imgManualPixel Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN || uMsg == WM_RBUTTONDOWN
		;X
		Mov Eax, lParam
		Mov Xvechi, Ax

		;Y
		Mov Edx, 0
		Mov Eax, 0
		Mov Eax, lParam
		Mov Ecx, 010000H
		Div Ecx
		Mov Yvechi, Ax

		;Rest X (pixel actual X)
		Mov Edx, 0
		Mov Eax, 0
		Mov Ax, Xvechi
		Mov Ecx, 10
		Div Ecx
		Mov Xrelativ, Ax

		;Rest Y (pixel actual Y)
		Mov Edx, 0
		Mov Eax, 0
		Mov Ax, Yvechi
		Mov Ecx, 10
		Div Ecx
		Mov Yrelativ, Ax

		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke GetDC, Eax
		Mov hDC1, Eax

		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetDC, Eax
		Mov hDC2, Eax

		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_IMGMANUALPIXEL
		Invoke GetDC, Eax
		Mov hDC3, Eax

		Mul Ecx
		Mov Edx, 0
		Mov Eax, 0
		Mov Ax, Xrelativ
		Mov Ecx, 10
		Mov Ebx, Eax

		Mov Edx, 0
		Mov Eax, 0
		Mov Ax, Yrelativ
		Mul Ecx

		Mov Eax, 0
		Mov Ax, _Xbusit
		Mov Ebx, 0
		Mov Bx, _Ybusit
		.If Ax >= 8
			Sub Ax, 8
;		.Else
;			Sub Ax, 3
		.EndIf

		.If Bx >= 6
			Sub Bx, 6
;		.Else
;			Sub Bx, 3
		.EndIf
		
		Add Ax, Xrelativ
		Add Bx, Yrelativ
		Mov Xrelativ, Ax
		Mov Yrelativ, Bx

		.If uMsg == WM_LBUTTONDOWN
			Invoke SetPixel, hDC1, Eax, Ebx, _nPixelColor
			Mov Eax, 0
			Mov Ax, Xrelativ
			Mov Ebx, 0
			Mov Bx, Yrelativ
			Invoke SetPixel, hDC2, Eax, Ebx, _nPixelColor
			Mov Eax, 0
			Mov Ax, Xrelativ
			Mov Ebx, 0
			Mov Bx, Yrelativ
			Invoke SetPixel, _hMasterDC, Eax, Ebx, _nPixelColor

		.ElseIf uMsg == WM_RBUTTONDOWN
			Mov Ecx, _nPixelColor
			Not Ecx
			Invoke SetPixel, hDC1, Eax, Ebx, Ecx
			Mov Eax, 0
			Mov Ax, Xrelativ
			Mov Ebx, 0
			Mov Bx, Yrelativ
			Mov Ecx, _nPixelColor
			Not Ecx
			Invoke SetPixel, hDC2, Eax, Ebx, Ecx
			Mov Eax, 0
			Mov Ax, Xrelativ
			Mov Ebx, 0
			Mov Bx, Yrelativ
			Mov Ecx, _nPixelColor
			Not Ecx
			Invoke SetPixel, _hMasterDC, Eax, Ebx, Ecx
		.EndIf

		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke UpdateWindow, Eax
		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke UpdateWindow, Eax

		Mov Eax, 0
		Mov Ax, _Xbusit
		.If Ax >= 8
			Sub Ax, 8
;		.Else
;			Sub Ax, 3
		.EndIf

		Mov Ebx, 0
		Mov Bx, _Ybusit
		.If Bx >= 6
			Sub Bx, 6
;		.Else
;			Sub Bx, 3
		.EndIf

		Invoke StretchBlt, hDC3, 0, 0, 160, 120, hDC2, Eax, Ebx, 16, 12, SRCCOPY
		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_IMGMANUALPIXEL
		Invoke UpdateWindow, Eax

;	Invoke nDebug, 0, _nIndent
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window3imgManualPixel EndP

;PastreazaDCVechi Proc
;	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
;	Push Eax
;	Invoke GetDC, Eax
;	Pop Edx
;	Push Eax
;	Invoke GetWindowRect, Edx, Addr patrat3
;	Mov Eax, patrat3.right
;	Mov Edx, patrat3.left
;	Sub Eax, Edx
;	Mov Ecx, Eax

;	Mov Eax, patrat3.bottom
;	Mov Edx, patrat3.top
;	Sub Eax, Edx
;	Mov Edx, Eax

;	Pop Eax
;	;Invoke BitBlt, Eax, 0, 0, patrat3.right, patrat3.bottom, _hVechiDC, 0, 0, SRCCOPY
;	Invoke BitBlt, Eax, 0, 0, Ecx, Edx, _hVechiDC, 0, 0, SRCCOPY

;	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
;	Invoke UpdateWindow, Eax

;	Ret
;PastreazaDCVechi EndP


bugFix0_w3 Proc hWnd:DWord
	;bugFix #1
		Invoke GetWindowLong, hWnd, GWL_EXSTYLE
		Or Eax, WS_EX_LAYERED
		Invoke SetWindowLong, hWnd, GWL_EXSTYLE, Eax
		;Invoke CiupesteFundal, hWnd
		;Invoke RestRgnFer2, hWnd
		Invoke SetLayeredWindowAttributes, hWnd, 10, 255, LWA_ALPHA

	Ret
bugFix0_w3 EndP


Window3picCuloare Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN
;		Invoke nDebug, 0, _nPixelColor
;		Not _nPixelColor
;		Invoke nDebug, 0, _nPixelColor
		Not _nPixelColor
		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_PICCULOARE
		Invoke GetDC, Eax
		Invoke BitBlt, Eax, 0, 0, 30, 20, Eax, 0, 0, NOTSRCCOPY
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window3picCuloare EndP

Window3btnSus Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN
	 	Invoke SendMessage, _hWnd3, WM_COMMAND, IDC_WINDOW3_BTNSUS, 0
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window3btnSus EndP

Window3btnDreapta Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN
	 	Invoke SendMessage, _hWnd3, WM_COMMAND, IDC_WINDOW3_BTNDREAPTA, 0
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window3btnDreapta EndP

Window3btnStanga Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN
	 	Invoke SendMessage, _hWnd3, WM_COMMAND, IDC_WINDOW3_BTNSTANGA, 0
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window3btnStanga EndP

Window3btnJos Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONDOWN
	 	Invoke SendMessage, _hWnd3, WM_COMMAND, IDC_WINDOW3_BTNJOS, 0
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window3btnJos EndP
