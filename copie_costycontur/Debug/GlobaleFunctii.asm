.Const

.Data?

.Data

.Code

ShowManualDebugFocusRect Proc
Local nW:DWord
Local nH:DWord
Local Xnasol:Word
Local Ynasol:Word

	.If !_bDebugFocusRect
		Mov Eax, 0
		Ret
	.EndIf

	Mov Eax, 0
	Mov Ax, _Xbusit
	Mov Xnasol, Ax

	Mov Eax, 0
	Mov Ax, _Ybusit
	Mov Ynasol, Ax

	Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_IMGMANUALPIXEL
	Invoke GetWindowRect, Eax, Addr _patrat

	Mov Eax, _patrat.right
	Mov Ebx, _patrat.left
	Sub Eax, Ebx
	Mov nW, Eax

	Mov Edx, 0
	Mov Eax, nW
	Mov Ecx, 3
	Div Ecx
	Mov nW, Eax

	Mov Eax, _patrat.bottom
	Mov Ebx, _patrat.top
	Sub Eax, Ebx
	Mov nH, Eax

	Mov Edx, 0
	Mov Eax, nH
	Mov Ecx, 3
	Div Ecx
	Mov nH, Eax

	Mov Edx, 0
	Mov Eax, nW
	Mov Ecx, 2
	Div Ecx
	Sub Xnasol, Ax

	Mov Edx, 0
	Mov Eax, nH
	Mov Ecx, 2
	Div Ecx
	Sub Ynasol, Ax

	Mov Ecx, 0
	Mov Cx, Xnasol

	Mov Edx, 0
	Mov Dx, Ynasol

	Mov Eax, Ecx
	Mov _patrat.left, Eax
	Mov Eax, Edx
	Mov _patrat.top, Eax
	Mov Eax, Ecx
	Add Eax, nW
	Mov _patrat.right, Eax
	Mov Eax, Edx
	Add Eax, nH
	Mov _patrat.bottom, Eax

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke GetDC, Eax
	Invoke DrawFocusRect, Eax, Addr _patrat

	Move _dbgFocusRect.left, _patrat.left
	Move _dbgFocusRect.right, _patrat.right
	Move _dbgFocusRect.top, _patrat.top
	Move _dbgFocusRect.bottom, _patrat.bottom

	Ret
ShowManualDebugFocusRect EndP

ClearDgbFocusRect Proc
	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke GetDC, Eax
	Invoke DrawFocusRect, Eax, Addr _dbgFocusRect

	Ret
ClearDgbFocusRect EndP


ManualPixWin Proc
Local nX:DWord
Local nY:DWord
Local nW:DWord
Local nH:DWord

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_BUTTON8
	Invoke EnableWindow, Eax, FALSE

	Invoke GetMenu, _hWnd2
	Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSTARTINTERPRETOR, MF_GRAYED

	Invoke GetWindowRect, _hWnd2, Addr _patrat
	Mov Eax, _patrat.right
	Mov Ebx, _patrat.left
	Sub Eax, Ebx
	Mov nW, Eax

	Mov Eax, _patrat.bottom
	Mov Ebx, _patrat.top
	Sub Eax, Ebx
	Mov nH, Eax

	Mov Edx, 0
	Mov Eax, nW
	Mov Ecx, 2
	Div Ecx
	Sub Eax, 50
	Mov nW, Eax

	Mov Edx, 0
	Mov Eax, nH
	Mov Ecx, 2
	Div Ecx
	Sub Eax, 50
	Mov nH, Eax

	Mov Eax, _patrat.left
	Add Eax, nW
	Mov nX, Eax

	Mov Eax, _patrat.top
	Add Eax, nH
	Mov nY, Eax

	Invoke SetWindowPos, _hWnd3, HWND_TOPMOST, nX, nY, 214, 230, SWP_SHOWWINDOW

	Ret
ManualPixWin EndP

ManualPixWinDC Proc Xs:DWord, Ys:DWord, bWrite:BOOL
Local hSrcDC:HDC
Local Xstart:DWord
Local Ystart:DWord
Local nLinie:DWord
Local nColoana:DWord

	Mov Eax, Xs
	Mov nLinie, Eax
	Sub Eax, 8
	Mov Xstart, Eax
	Mov Eax, Ys
	Mov nColoana, Eax
	Sub Eax, 6
	Mov Ystart, Eax

	.If bWrite
		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke GetWindowRect, Eax, Addr _patrat
		Fild _patrat.right   ; Descazut
		Fild _patrat.left    ; Scazator
		Fsub            	; Operatie scadere
		Fistp _patrat.right  ; Salveaza rezultatul in variabila

		Fild _patrat.bottom 	; Descazut
		Fild _patrat.top  	; Scazator
		Fsub            	; Operatie scadere
		Fistp _patrat.bottom ; Salveaza rezultatul in variabila

		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetDC, Eax
		Invoke SetPixel, Eax, nLinie, nColoana, Green

		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_IMGMANUALPIXEL
		Invoke GetDC, Eax
		Push Eax
		;Invoke StretchBlt, Eax, 0, 0, 94, 76, _hMasterDC, Xstart, Ystart, 10, 10, SRCCOPY
		Invoke StretchBlt, Eax, 0, 0, 160, 120, _hMasterDC, Xstart, Ystart, 16, 12, SRCCOPY ;
		Add Xstart, 8
		Add Ystart, 6
		Mov Eax, Xstart
		Mov _Xbusit, Ax
		Mov Eax, Ystart
		Mov _Ybusit, Ax
		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetDC, Eax
		Pop Edx
		Invoke StretchBlt, Edx, 80, 60, 10, 10, Eax, Xstart, Ystart, 1, 1, SRCCOPY

		Mov _bDebugFocusRect, TRUE
		Invoke ShowManualDebugFocusRect

;		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
;		Invoke GetDC, Eax
;		Invoke CopyDC2, Eax, 0, 0, _patrat.right, _patrat.bottom
;		Mov _hVechiDC, Eax

	.Else
		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetDC, Eax
		Mov hSrcDC, Eax

		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_IMGMANUALPIXEL
		Invoke GetDC, Eax
		;Push Eax
		;Invoke StretchBlt, Eax, 0, 0, 94, 76, _hMasterDC, Xstart, Ystart, 10, 10, SRCCOPY
		Invoke StretchBlt, Eax, 0, 0, 160, 120, hSrcDC, Xstart, Ystart, 16, 12, SRCCOPY ;
		Add Xstart, 8
		Add Ystart, 6
		Mov Eax, Xstart
		Mov _Xbusit, Ax
		Mov Eax, Ystart
		Mov _Ybusit, Ax
;		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
;		Invoke GetDC, Eax
;		Pop Edx
;		Invoke StretchBlt, Edx, 80, 60, 10, 10, Eax, Xstart, Ystart, 1, 1, SRCCOPY

	.EndIf


	Ret
ManualPixWinDC EndP

DrawMasterDC Proc hDstWnd:HWND
	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Push Eax
	Invoke GetDC, Eax
	Pop Ebx
	Invoke GetWindowRect, hDstWnd, Addr _patrat
	Fild _patrat.right   ; Descazut
	Fild _patrat.left    ; Scazator
	Fsub            	; Operatie scadere
	Fistp _patrat.right  ; Salveaza rezultatul in variabila

	Fild _patrat.bottom 	; Descazut
	Fild _patrat.top  	; Scazator
	Fsub            	; Operatie scadere
	Fistp _patrat.bottom ; Salveaza rezultatul in variabila

	Invoke GetDC, hDstWnd
	Invoke BitBlt, Eax, 0, 0, _patrat.right, _patrat.bottom, _hMasterDC, 0, 0, SRCCOPY

	Ret
DrawMasterDC EndP

SaveMasterDC Proc hWnd:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Push Eax
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Addr _patrat
	Mov Eax, _patrat.right
	Sub Eax, _patrat.left
	Mov nW, Eax
	Mov Eax, _patrat.bottom
	Sub Eax, _patrat.top
	Mov nH, Eax
	Pop Eax

	Invoke CopyDC, Eax, 0, 0, nW, nH
	Mov _hMasterDC, Eax

	.If !_hMasterDC
		Mov Eax, 0
		Ret 0
	.EndIf

	Invoke BitBlt, _hMasterDC, 0, 0, nW, nH, Eax, 0, 0, SRCCOPY

	Ret
SaveMasterDC EndP

Send2CNC Proc
Local hSrcDC:HDC
Local hDstDC:HDC
Local hSrc:HWND
Local hDst:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Mov hSrc, Eax
	Invoke GetWindowRect, hSrc, Addr _patrat
	Fild _patrat.right   ; Descazut
	Fild _patrat.left  	; Scazator
	Fsub     			; Operatie scadere
	Fistp nW 			; Salveaza rezultatul in variabila
	Fild _patrat.bottom  ; Descazut
	Fild _patrat.top  	; Scazator
	Fsub     			; Operatie scadere
	Fistp nH 			; Salveaza rezultatul in variabila

	Mov Eax, nW
	Mov _nCNCMaxLinii, Eax
	Mov Eax, nH
	Mov _nCNCMaxColoane, Eax

	Invoke GetDC, hDst
	Mov hSrcDC, Eax

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Mov hDst, Eax
	Invoke GetDC, hDst
	Mov hDstDC, Eax

	;Redimensioneaza fereastra + controlul cu imaginea
	Mov Eax, nCtrlsW
	Add Eax, nMargin
	Add Eax, 75
	Invoke SetWindowPos, hDst, HWND_TOP, Eax, nMargin, nW, nH, SWP_NOZORDER

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESX
	Mov Ebx, nCtrlsW
	Add Ebx, nMargin
	Add Ebx, 75
	Invoke SetWindowPos, Eax, HWND_TOP, Ebx, 7, nW, 12, SWP_NOZORDER
	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESY
	Mov Ebx, nH
	Add Ebx, nMargin
	Mov Ecx, nCtrlsW
	Add Ecx, nMargin
	Add Ecx, nW
	Add Ecx, 76
	Invoke SetWindowPos, Eax, HWND_TOP, Ecx, nMargin, 12, nH, SWP_NOZORDER

	Invoke UpdateProgresMaxXYWin2

;	Push nW
;	Push nH

	;Noile marimi pentru fereastra
	Fild nW
	Fild nCtrlsW
	Fadd
	Fistp nW
	Fild nW
	Fild nMargin
	Fadd
	Fistp nW
	Fild nW
	Fild nMargin
	Fadd
	Fistp nW
	Add nW, 10

	Fild nH
	Fild nStartTop
	Fadd
	Fistp nH
	Fild nH
	Fild nMargin
	Fadd
	Fistp nH
	Fild nH
	Fild nMargin
	Fadd
	Fistp nH	
	Add nW, 65

	.If nH < 535
		Mov nH, 535
	.EndIf

	Invoke GetDesktopWindow
	Invoke GetWindowRect, Eax, Addr _patrat
	Push _patrat.right		;W
	Push _patrat.bottom		;H
	Add nW, 12
	Add nH, 12

	Mov Eax, nW
	.If _patrat.right > Eax			;DescktopW > nW
		Mov Eax, nW
		Sub _patrat.right, Eax
		Mov Eax, _patrat.right
		Mov Edx, 0
		Mov Ebx, 2
		Div Ebx
		Mov _patrat.left, Eax
	.Else
		Mov _patrat.left, 0
	.EndIf

	Mov Eax, nH
	.If _patrat.bottom > Eax		;DesktopH > nH
		Mov Eax, nH
		Sub _patrat.bottom, Eax
		Mov Eax, _patrat.bottom
		Mov Edx, 0
		Mov Ebx, 2
		Div Ebx
		Mov _patrat.top, Eax
	.Else
		Mov _patrat.top, 0
	.EndIf

	Invoke SetWindowPos, _hWnd2, HWND_NOTOPMOST, _patrat.left, _patrat.top, nW, nH, SWP_SHOWWINDOW

;	Pop Ebx
;	Pop Eax
	;Invoke BitBlt, hDstDC, 0, 0, Ebx, Eax, hSrcDC, 0, 0, SRCCOPY

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke DrawMasterDC, Eax

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke DrawMasterDC, Eax

	;Invoke nDebug, 0, 0

	Invoke GetWindowRect, _hWnd1, Addr _patrat
	Mov Eax, _patrat.left
	Mov Ebx, _patrat.top
	.If _patrat.left != -3000
		Mov _MainWinOldX, Eax
		Mov _MainWinOldY, Ebx
	.EndIf

	Invoke SetWindowPos, _hWnd1, _nToggleTopMost, -3000, -3000, 0, 0, SWP_NOSIZE

	Ret
Send2CNC EndP

fl00dFill Proc nX:DWord, nY:DWord, nColor:DWord, hTarget:HWND
Local vBrush:DWord
Local vPreviouseBrush:DWord
Local nW:DWord
Local nH:DWord

		Invoke CreateSolidBrush, nColor
		Mov vBrush, Eax
	    Invoke SelectObject, _hMasterDC, vBrush
		Mov vPreviouseBrush, Eax
		Invoke GetPixel, _hMasterDC, nX, nY
	    Invoke ExtFloodFill, _hMasterDC, nX, nY, Eax, FLOODFILLSURFACE
	    Invoke SelectObject, _hMasterDC, vPreviouseBrush
	    Invoke DeleteObject, vBrush

		Invoke GetWindowRect, hTarget, Addr _patrat
		Fild _patrat.right
		Fild _patrat.left
		Fsub
		Fistp nW

		Fild _patrat.bottom
		Fild _patrat.top
		Fsub
		Fistp nH

	    Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	    Invoke GetDC, Eax
	    Invoke BitBlt, Eax, 0, 0, nW, nH, _hMasterDC, 0, 0, SRCCOPY
	    Invoke GetDC, hTarget
	    Invoke BitBlt, Eax, 0, 0, nW, nH, _hMasterDC, 0, 0, SRCCOPY

	    Invoke ReleaseDC, hTarget, _hMasterDC

	Ret
fl00dFill EndP

SetUndoDC Proc, hWnd:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetWindowRect, hWnd, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp nW

	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp nH

	;Invoke GetDC, hWnd
	Invoke CopyDC2, _hMasterDC, 0, 0, nW, nH
	.If Eax
		Mov _hUndoDC, Eax
		Mov _bUndo, TRUE
	.EndIf

	Ret
SetUndoDC EndP

DoUndo Proc hWnd:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetWindowRect, hWnd, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp nW

	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp nH

    Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
    Invoke GetDC, Eax
    Invoke BitBlt, Eax, 0, 0, nW, nH, _hUndoDC, 0, 0, SRCCOPY
    Invoke GetDC, hWnd
   	Invoke BitBlt, Eax, 0, 0, nW, nH, _hUndoDC, 0, 0, SRCCOPY
   	Invoke BitBlt, _hMasterDC, 0, 0, nW, nH, _hUndoDC, 0, 0, SRCCOPY

;	Invoke GetDC, 0
;   	Invoke BitBlt, Eax, 0, 0, nW, nH, _hUndoDC, 0, 0, SRCCOPY

	Mov _bUndo, FALSE

	Ret
DoUndo EndP

ToggleUndoMnu Proc hWnd:HWND
	Mov Eax, hWnd
	.If Eax == _hWnd1
		Invoke GetMenu, _hWnd1
		.If _bUndo
			Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUUNDOMAINIMG, MF_ENABLED
		.Else
			Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUUNDOMAINIMG, MF_GRAYED
		.EndIf

	.ElseIf Eax == _hWnd2
		Invoke GetMenu, _hWnd2
		.If _bUndo
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUUNDO, MF_ENABLED
		.Else
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUUNDO, MF_GRAYED
		.EndIf

	.EndIf

	Ret
ToggleUndoMnu EndP

IncarcaSetari Proc pFile:DWord
Local hF:DWord

	Invoke CreateFile, pFile, GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL
	.If Eax == INVALID_HANDLE_VALUE
		;Invoke CloseHandle, Eax
		Mov Eax, 0
		Ret
	.EndIf
	Mov hF, Eax

	Invoke GolesteString, Addr _szSettingsBuffer, 1024

	Invoke GetFileSize, hF, NULL
	Invoke ReadFile, hF, Addr _szSettingsBuffer, Eax, Addr _nBytesUsed, 0
	Invoke CloseHandle, hF

	Mov Eax, Offset _szSettingsBuffer
start:
	Mov Ebx, [Eax]
	Cmp Ebx, "=pls"
	Je go2Slp
	Cmp Ebx, "=cnc"
	Je go2SCnc
	Cmp Ebx, "=xpp"
	Je go2PPX
	Cmp Ebx, "=ypp"
	Je go2PPY
	Cmp Ebx, "=moc"
	Je go2Com
	;Cmp Ebx, "=xip"
	;Je go2Pix
	Cmp Ebx, "=pot"
	Je go2Top
	Cmp Ebx, "=xpm"
	Je go2MPX
	Cmp Ebx, "=ypm"
	Je go2MPY
	Cmp Ebx, "=eoa"
	Je go2AOE

;	Mov Ecx, Eax
;	Mov Ebx, 16
;	Mov Edx, 0
;	Div Ebx
;	Cmp Al, 0
;	Jmp sfarsit
;	Mov Eax, Ecx

	Inc Eax
	Jmp start

go2Slp:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 4
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 4
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 0 && Eax <= 9000
		Mov _nSleep, Eax
		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start

go2SCnc:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 4
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 4
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 0 && Eax <= 9000
		Mov _nCncTestSleep, Eax
		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start

go2PPX:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 2
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 2
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 0 && Eax <= 10
		Mov _nPasiPerPixelX, Al
   		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start

go2PPY:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 2
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 2
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 0 && Eax <= 10
		Mov _nPasiPerPixelY, Al
   		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start


go2Com:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 2
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 2
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 0 && Eax <= 99
		Mov _nCom, Eax
		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start

;go2Pix:
;	Add Eax, 4
;	Mov Ecx, 0
;	Mov Edx, Offset _szValBuffer
;	Mov Ebx, [Eax]
;	Mov [Edx + Ecx], Ebx
;	Add Ecx, 4
;	Push Ebx
;	Mov Ebx, 0
;	Mov [Edx + Ecx], Ebx
;	Pop Ebx
;	Sub Ecx, 4
;	Push Eax
;	Push Ebx
;	Push Ecx
;	Push Edx
;	Invoke atol, Offset _szValBuffer
;	Pop Edx
;	Pop Ecx
;	Pop Ebx
;	.If Eax == 1677
;		Mov _nPixelColor, White
;			;Invoke MessageBox, 0, Addr _szValBuffer, 0, 0
;			;Invoke ExitProcess, 0
;		Pop Eax
;	.Else
;		;Invoke CloseHandle, hF
;		Mov _nPixelColor, Black
;		Pop Eax
;		Mov Eax, 0
;		Ret
;	.EndIf
;	Jmp start

go2Top:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 4
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 4
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax == 1
		Mov _nToggleTopMost, HWND_TOPMOST
		Pop Eax
	.Else
		Mov _nToggleTopMost, HWND_NOTOPMOST
		Pop Eax
	.EndIf
	Jmp start


go2MPX:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 4
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 4
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 10 && Eax <= 3000
		Mov _nMaxX, Eax
		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start

go2MPY:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 4
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 4
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax > 10 && Eax <= 3000
		Mov _nMaxY, Eax
		Pop Eax
	.Else
		;Invoke CloseHandle, hF
		Pop Eax
		Mov Eax, 0
		Ret
	.EndIf
	Jmp start


go2AOE:
	Add Eax, 4
	Mov Ecx, 0
	Mov Edx, Offset _szValBuffer
	Mov Ebx, [Eax]
	Mov [Edx + Ecx], Ebx
	Add Ecx, 1
	Push Ebx
	Mov Ebx, 0
	Mov [Edx + Ecx], Ebx
	Pop Ebx
	Sub Ecx, 1
	Push Eax
	Push Ebx
	Push Ecx
	Push Edx
	Invoke atol, Offset _szValBuffer
	Pop Edx
	Pop Ecx
	Pop Ebx
	.If Eax
		Mov _bAskOnExit, TRUE
		Pop Eax
	.Else
		Mov _bAskOnExit, FALSE
		Pop Eax
	.EndIf
;	;Jmp start


sfarsit:
	Mov Eax, 1
	
;	Invoke nDebug, 0, _nSleep
;	Invoke nDebug, 0, _nCncTestSleep
;	Mov Eax, 0
;	Mov al, _nPasiPerPixelX
;	Invoke nDebug, 0, Eax
;	Mov Eax, 0
;	Mov Al, _nPasiPerPixelY
;	Invoke nDebug, 0, Eax
;	Invoke nDebug, 0, _nCom
;	Invoke nDebug, 0, _nPixelColor
;	Invoke nDebug, 0, _nToggleTopMost

	Ret
IncarcaSetari EndP

SalveazaSetari Proc pFile:DWord
Local hF:HANDLE

	Invoke CreateFile, pFile, GENERIC_READ Or GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL
	.If Eax == INVALID_HANDLE_VALUE
		Mov Eax, 0
		Ret
	.EndIf
	Mov hF, Eax

	Invoke GolesteString, Addr _szSettingsBuffer, 1024
	Invoke GolesteString, Addr _szValBuffer, 16

	Jmp @F
		szSlp DB "slp=", 0
		szSCnc DB 13, 10, "scnc=", 0
		szPPX DB 13, 10, "ppx=", 0
		szPPY DB 13, 10, "ppy=", 0
		szCom DB 13, 10, "com=", 0
		;szPixel DB 13, 10, "pix=", 0
		szTopMost DB 13, 10, "top=", 0
		szMaxPixX DB 13, 10, "mpx=", 0
		szMaxPixY DB 13, 10, "mpy=", 0
		szAskOnExit DB 13, 10, "aoe=", 0

@@:

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szSlp
	Invoke dw2a, _nSleep, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szSCnc
	Invoke dw2a, _nCncTestSleep, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szPPX
	Mov Eax, 0
	Mov Al, _nPasiPerPixelX
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szPPY
	Mov Eax, 0
	Mov Al, _nPasiPerPixelY
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szCom
	Invoke dw2a, _nCom, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	;Invoke szCatStr, Addr _szSettingsBuffer, Addr szPixel
	;Invoke dw2a, _nPixelColor, Addr _szValBuffer
	;Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szTopMost
	.If _nToggleTopMost == HWND_TOPMOST
		Mov Eax, 1
	.Else
		Mov Eax, 0
	.EndIf
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szMaxPixX
	Invoke dw2a, _nMaxX, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szMaxPixY
	Invoke dw2a, _nMaxY, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szAskOnExit
	Invoke dw2a, _bAskOnExit, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke StrLen, Addr _szSettingsBuffer
	Invoke WriteFile, hF, Addr _szSettingsBuffer, Eax, Addr _nBytesUsed, 0

	Invoke CloseHandle, hF

	Ret
SalveazaSetari EndP


ArataSetari Proc hWnd:HWND
	Jmp @F
		szSleep DB "Sleep: ", 0
		szSleepCNC DB 13, 10, "Sleep CNC: ", 0
		szPasiPerX DB 13, 10, "Pasi / Pixel X: ", 0
		szPasiPerY DB 13, 10, "Pasi / Pixel Y: ", 0
		szComNr DB 13, 10, "COM port: ", 0
		szPixelColor DB 13, 10, "Culoare pixel: ", 0

		szTopMostVal DB 13, 10, 13, 10, "Tot timpul deasupra: ", 0
		szAOE DB 13, 10, "Comfirma iesirea din aplicatie: ", 0
		szMPX DB 13, 10, "Pixeli lungime: ", 0
		szMPY DB 13, 10, "Pixeli latinme: ", 0

		szSetari DB "Setari", 0
@@:

	Invoke GolesteString, Addr _szSettingsBuffer, 1024

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szSleep
	Invoke dw2a, _nSleep, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szSleepCNC
	Invoke dw2a, _nCncTestSleep, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szPasiPerX
	Mov Eax, 0
	Mov Al, _nPasiPerPixelX
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szPasiPerY
	Mov Eax, 0
	Mov Al, _nPasiPerPixelY
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szComNr
	Invoke dw2a, _nCom, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szPixelColor
	.If _nPixelColor == White
		Jmp @F
			szAlb DB "Alb", 0
@@:
   		Mov Eax, Offset szAlb
	.Else
		Jmp @F
			szNegru DB "Negru", 0
@@:
   		Mov Eax, Offset szNegru
	.EndIf

	Invoke szCatStr, Addr _szSettingsBuffer, Eax
	Invoke szCatStr, Addr _szSettingsBuffer, Addr szTopMostVal
	.If _nToggleTopMost == HWND_TOPMOST
		Mov Eax, 1
	.Else
		Mov Eax, 0
	.EndIf
	Invoke dw2a, Eax, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szAOE
	Invoke dw2a, _bAskOnExit, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szMPX
	Invoke dw2a, _nMaxX, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke szCatStr, Addr _szSettingsBuffer, Addr szMPY
	Invoke dw2a, _nMaxY, Addr _szValBuffer
	Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer

	Invoke MessageBox, hWnd, Addr _szSettingsBuffer, Addr szSetari, MB_OK

	Ret
ArataSetari EndP

UpdateSetari Proc
	Mov Eax, 0
	Mov Al, _nPasiPerPixelX
	Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELX, TBM_SETPOS, TRUE, Eax

	Mov Eax, 0
	Mov Al, _nPasiPerPixelY
	Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELY, TBM_SETPOS, TRUE, Eax

	Invoke GolesteString, Addr _szSettingsBuffer, 1024
	Jmp @F
		szStringCom DB "COM", 0
@@:
		Invoke szCatStr, Addr _szSettingsBuffer, Addr szStringCom
		Invoke dw2a, _nCom, Addr _szValBuffer
		Invoke szCatStr, Addr _szSettingsBuffer, Addr _szValBuffer
		Invoke SetDlgItemText, _hWnd2, IDC_WINDOW2_EDIT5, Addr _szSettingsBuffer

	.If _nToggleTopMost == HWND_TOPMOST
		Mov _nToggleTopMost, HWND_NOTOPMOST
		Invoke ToggleTopMost, _hWnd1
	.EndIf

	.If _bAskOnExit
		Mov _bAskOnExit, FALSE
		Invoke ToggleAskOnExit
	.EndIf

	Ret
UpdateSetari EndP

UpdateProgresMaxXYWin2 Proc
Local nW:DWord
Local nH:DWord

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Addr _patrat
	Fild _patrat.right   ; Descazut
	Fild _patrat.left  	; Scazator
	Fsub     			; Operatie scadere
	Fistp nW 			; Salveaza rezultatul in variabila
	Fild _patrat.bottom  ; Descazut
	Fild _patrat.top  	; Scazator
	Fsub     			; Operatie scadere
	Fistp nH 			; Salveaza rezultatul in variabila

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESX
	Push Eax

	Mov Eax, 0
	Mov Al, _nPasiPerPixelX
	Mov Ebx, nW
	IMul Ebx
	Mov Ecx, _nMaxX
	.If Eax <= Ecx		; pasi sunt pana in maxim

		;calcul lungime
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
			Mov Ebx, nW
			IMul Ebx
		Mov Edx, _nMaxX
		;Mov Ebx, nW
		Sub Edx, Eax
		Mov Ecx, _nMaxX
		Sub Ecx, Edx

		;calcul procentaj
		Mov Ebx, 100
		Mov Eax, Ecx
		Mov Edx, 0
		IMul Ebx
		Mov Edx, 0
		Mov Ebx, _nMaxX
		Div Ebx
		Mov Ecx, Eax

		;Push Ecx
		;Invoke nDebug, 0, Ecx
		;Pop Ecx

		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, Ecx, 0
	.Else
		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, 0, 0

	.EndIf


	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESY
	Push Eax

	Mov Eax, 0
	Mov Al, _nPasiPerPixelY
	Mov Ebx, nH
	IMul Ebx
	Mov Ecx, _nMaxY
	.If Eax <= Ecx		; pasi sunt pana in maxim

		;calcul lungime
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
			Mov Ebx, nH
			IMul Ebx
		Mov Edx, _nMaxY
		;Mov Ebx, nH
		Sub Edx, Eax
		Mov Ecx, _nMaxY
		Sub Ecx, Edx

		;calcul procentaj
		Mov Ebx, 100
		Mov Eax, Ecx
		Mov Edx, 0
		IMul Ebx
		Mov Edx, 0
		Mov Ebx, _nMaxY
		Div Ebx
		Mov Ecx, Eax

		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, Ecx, 0
	.Else
		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, 0, 0

	.EndIf

	Ret
UpdateProgresMaxXYWin2 EndP
