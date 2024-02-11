;15:21 11/Iulie/2012
;CostyContur v0.9

;VERSIUNI LIBRARI
;dc2bmp v0.3
;FisierDlg v0.1

;ASM FILES
;InputBox.asm
;FadeInOut.asm
;GolesteString.asm
;InsertSysMenu.asm
;npDebug.asm
;dwah.asm

.Const
BmpBaseID		Equ 222

.Data?
;REGIUNE
hRgn 			DD ?
aRgn 			DWord 10 Dup(?)

;Img Contur
hIContur		DD ?
hIConturDC		DD ?

;Drag Files
sDragFile	DB MAX_PATH Dup(?)

;Windows Long Old
nWinLongOld	DD ?

szMenuBuffer DB 1024 Dup(?)

.Data
linie 		DD 0
coloana	 	DD 0
hdcpict 	DD 0
nr 			DD 0
linie1 		DD 0
coloana1 	DD 0
translated  DD 0
scaragri 	DD 0
obj 		DD 0

nBmps		DD 0

;Stari
sNormal 	DB "CostyContur 0.9", 0
sCopiat  	DB "CostyContur 0.9 - Ecran copiat" , 0
sAsteptati  DB "CostyContur 0.9 - Asteptati...", 0

;Meniu Despre
szTitluDespre 	DB "Despre noi d(^_^)b [i]", 0
MnuAboutSysID 	DD 202

;Creare ferestre
sWin2 DB "Window2", 0
sWin3 DB "Window3", 0
sWin5 DB "Window5", 0
sWin6 DB "Window6", 0

;STRUCTURI
patrat 		RECT <>
dimBmp 		POINT <>
punct		POINT <>
infMenu		MENUITEMINFO <>

;bugFix
bugFixTransp DD 0

.Code

Window1Procedure Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_CREATE
		;Invoke GetDlgItem, hWnd, IDC_WINDOW1_PICTURE1
		Mov Eax, hWnd
		Mov _hWnd1, Eax

		;Bug Fix #0 , #1
		Invoke bugFix0, hWnd
		;Invoke bugFix1, hWnd

		Invoke DragAcceptFiles, hWnd, TRUE

      	Invoke GetDC, 0
      	Mov hdcpict, Eax

		Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
		Mov hIContur, Eax
		Invoke GetDC, Eax
		Mov hIConturDC, Eax

		;Incarca icoana
      	Invoke LoadIcon, 0, ICONITA

		Invoke FadeIn, _hWnd1, 1

		;Seteaza cea mai de sus fereastra
;		Mov _nToggleTopMost, HWND_NOTOPMOST
;		Invoke GetWindowRect, hWnd, Offset patrat
;		Invoke SetWindowPos, hWnd, _nToggleTopMost, patrat.left, patrat.top, 0, 0, SWP_NOSIZE

		;Initializeaza dialogul pentru cale fisiere
		;Chemare dll
		Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		Invoke InsertSysMenu, hWnd, 0, MnuAboutSysID, Addr szTitluDespre
		Mov Eax, MnuAboutSysID
		Dec Eax
		Invoke InsertSysMenu, hWnd, 1, Eax, 0

		Invoke Create, Addr sWin2, NULL, NULL, NULL
		Mov _hWnd2, Eax

		Invoke Create, Addr sWin3, NULL, NULL, NULL
		Mov _hWnd3, Eax
		Invoke ShowWindow, _hWnd3, SW_HIDE

		Invoke IncarcaSetari, Addr _szDefaultSettingsFile
		.If Eax
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
			Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELX, TBM_SETPOS, TRUE, Eax

			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
			Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELY, TBM_SETPOS, TRUE, Eax

			Invoke GolesteString, Addr _szSettingsBuffer, 1024
			Jmp @F
				szCom DB "COM", 0
@@:
   			Invoke szCatStr, Addr _szSettingsBuffer, Addr szCom
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

		.EndIf

		Return TRUE

	.ElseIf uMsg == WM_SYSCOMMAND
		Mov Eax, MnuAboutSysID
		.If wParam == Eax
			Invoke SendMessage, hWnd, WM_COMMAND, IDM_WINDOW1_MNUABOUT, 0
		.EndIf

	.ElseIf uMsg == WM_COMMAND
;========================================================================================================================
;====MENIURI===
;========================================================================================================================
		.If wParam == IDM_WINDOW1_MNUOPENBMP
			.If _bFundalCiupit
				Jmp @F
					szLoadNewBmp DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
					szLoadNewBmpTitlu DB "Sunteti sigur(a)", 0
@@:

				Invoke MessageBox, hWnd, Addr szLoadNewBmp, Addr szLoadNewBmpTitlu, MB_YESNO + MB_ICONQUESTION

				.If Eax != 7
					Jmp openBmp
				.Else
					Jmp notOpenBmp
				.EndIf

			.EndIf

openBmp:
			Invoke DeschideFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke bugFix0, hWnd
				Invoke IncarcaImagine, Offset _sNumeFisier, hWnd
				.If !Eax
					Jmp @F
					sErrBmpNotLoaded DB "Fisierul ales nu este un fisier valid", 0
@@:
					Invoke MessageBox, hWnd, Addr sErrBmpNotLoaded, 0, MB_ICONSTOP
				.Else

					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 115
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 310, SWP_NOZORDER

						Invoke RestRgnFer, hWnd

						Sub dimBmp.x, 115
						Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 115
						Add dimBmp.y, 54
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

						Invoke RestRgnFer, hWnd

						Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

					.EndIf

					Invoke SaveMasterDC, _hWnd1
					Mov Eax, _hMasterDC
					Mov _hUndoDC, Eax
					Invoke SetUndoDC, hIContur
					Invoke ToggleUndoMnu, _hWnd1

Invoke GolesteString, Addr szMenuBuffer, 1024
					Jmp @F
						szReincarca DB "Reincarca *.bmp - ", 0
@@:
					Invoke szCatStr, Addr szMenuBuffer, Addr szReincarca
					Invoke szCatStr, Addr szMenuBuffer, Addr _sNumeFisier

					Mov Eax, SizeOf infMenu
					Mov infMenu.cbSize, Eax
					Mov infMenu.fMask, MIIM_DATA Or MIIM_TYPE
					Mov infMenu.fState, MFS_ENABLED
					Mov infMenu.hSubMenu, NULL
					Mov infMenu.hbmpChecked, NULL
					Mov infMenu.hbmpUnchecked, NULL
					;Mov Eax, Offset szClassName
					Mov Eax, Offset szMenuBuffer
					Mov infMenu.dwItemData, Eax
					Mov Eax, Offset szMenuBuffer
					Mov infMenu.dwTypeData, Eax
					Invoke StrLen, Addr szMenuBuffer
					Mov infMenu.cch, Eax
					Mov Ebx, IDM_WINDOW1_MNURELOADBMP
					;Inc Ebx
					Mov Eax, Ebx
					Mov infMenu.wID, Eax
					Mov infMenu.fMask, MIIM_DATA Or MIIM_TYPE
					Mov infMenu.fType, MFT_STRING
					Mov Eax, Offset szMenuBuffer
					Mov infMenu.dwItemData, Eax
					Mov Eax, Offset szMenuBuffer
					Mov infMenu.dwTypeData, Eax
					Invoke StrLen, Addr szMenuBuffer
					Mov infMenu.cch, Eax

					Invoke GetMenu, _hWnd1
					Invoke SetMenuItemInfo, Eax, IDM_WINDOW1_MNURELOADBMP, 0, Addr infMenu

					Invoke GetMenu, _hWnd1
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_ENABLED

					Invoke EnableControls, hWnd, 1
					Mov _bFundalCiupit, TRUE
					Mov _bPrimaData, FALSE
				.EndIf

			.EndIf
notOpenBmp:

		.ElseIf wParam == IDM_WINDOW1_MNUOPENCAMERA
			.If !_hWnd6
				Invoke Create, Addr sWin6, 0, 0, 0
				Mov _hWnd6, Eax
			.Else
				Invoke SetFocus, _hWnd6
			.EndIf

		.ElseIf wParam == IDM_WINDOW1_MNURELOADBMP
			Invoke IncarcaImagine, Offset _sNumeFisier, hWnd
			Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

			;Invoke nDebug, 0, Eax
			.If dimBmp.y < 260
				Add dimBmp.x, 115
				Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 310, SWP_NOZORDER

				Invoke RestRgnFer, hWnd

				Sub dimBmp.x, 115
				Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
				Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

				Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

			.Else
				;Ia dimensiuni
				Add dimBmp.x, 115
				Add dimBmp.y, 54
				Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

				Invoke RestRgnFer, hWnd

				Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

			.EndIf

			Invoke SaveMasterDC, _hWnd1
			Mov Eax, _hMasterDC
			Mov _hUndoDC, Eax
			Invoke SetUndoDC, hIContur
			Invoke ToggleUndoMnu, _hWnd1

			Invoke EnableControls, hWnd, 1
			Mov _bFundalCiupit, TRUE
			Mov _bPrimaData, FALSE

		.ElseIf wParam == IDM_WINDOW1_MNUINCARCASETARI
			Invoke EnableWindow, hWnd, FALSE
			Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNUINCARCASETARI, 0
			Invoke EnableWindow, hWnd, TRUE

		.ElseIf wParam == IDM_WINDOW1_MNUSALVEAZASETARI
			Invoke EnableWindow, hWnd, FALSE
			Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNUSALVEAZASETARI, 0
			Invoke EnableWindow, hWnd, TRUE

		.ElseIf wParam == IDM_WINDOW1_MNUSAVEGCODE
			Jmp @F
				sNotImpGCode DB "De implementat GCode", 0
@@:
   			Invoke MessageBox, hWnd, Addr sNotImpGCode, Addr sNotImpGCode, MB_ICONEXCLAMATION

		.ElseIf wParam == IDM_WINDOW1_MNUSAVEBMP
			Invoke SalveazaFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke SalveazaBmp, hWnd
			.EndIf

		.ElseIf wParam == IDM_WINDOW1_MNUEXIT
			Invoke SendMessage, hWnd, WM_CLOSE, 0, 0

		.ElseIf wParam == IDM_WINDOW1_MNUCOPYSCREEN
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW1_BUTTON1, 0

		.ElseIf wParam == IDM_WINDOW1_MNURESETIMAGE
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW1_BTNRESET, 0

		.ElseIf wParam == IDM_WINDOW1_MNUDOOUTLINE
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW1_BTNCONTUR, 0

		.ElseIf wParam == IDM_WINDOW1_MNUSETMAXX
			Invoke MaxXWin
			Invoke RefreshProgresMaxXY, hWnd

		.ElseIf wParam == IDM_WINDOW1_MNUSETMAXY
			Invoke MaxYWin
			Invoke RefreshProgresMaxXY, hWnd

		.ElseIf wParam == IDM_WINDOW1_MNUSHOWSETTINGS
			Invoke ArataSetari, hWnd

		.ElseIf wParam == IDM_WINDOW1_MNUSEND2CNC
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW1_BTNSEND2CNC, 0

		.ElseIf wParam == IDM_WINDOW1_MNUUNDOMAINIMG
			Invoke DoUndo, hIContur
			Invoke ToggleUndoMnu, _hWnd1

		.ElseIf wParam == IDM_WINDOW1_TOGGLETOPMOST
			Invoke ToggleTopMost, hWnd

		.ElseIf wParam == IDM_WINDOW1_MNUASKONEXIT
			Invoke ToggleAskOnExit

		.ElseIf wParam == IDM_WINDOW1_MNUHOWTOUSE
			Jmp @F
				sNotImpHowTo DB "De implementat cum se foloseste", 0
@@:
   			Invoke MessageBox, hWnd, Addr sNotImpHowTo, Addr sNotImpHowTo, MB_ICONEXCLAMATION

		.ElseIf wParam == IDM_WINDOW1_MNUABOUT
			Invoke Create, Addr sWin5, 0, 0, 0
			Mov _hWnd5, Eax

;========================================================================================================================
;====BUTOANE===
;========================================================================================================================
		.ElseIf wParam == IDC_WINDOW1_BUTTON1
			Invoke bugFix0, hWnd

			.If _bFundalCiupit
				Jmp @F
					szCiupitSigur DB "Renuntati la fundalul existent pentru copierea noului fundal?", 0
					szCiupitSigurTitlu DB "Sunteti sigur(a)", 0
@@:
				Invoke MessageBox, hWnd, Addr szCiupitSigur, Addr szCiupitSigurTitlu, MB_YESNO + MB_ICONQUESTION

				.If Eax != 7
					;Ciupeste din ecran
					Invoke GetMenu, _hWnd1
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_GRAYED

					Invoke CiupesteFundal, hWnd

					Invoke SaveMasterDC, _hWnd1
					Mov Eax, _hMasterDC
					Mov _hUndoDC, Eax
					Invoke SetUndoDC, hIContur
					Invoke ToggleUndoMnu, _hWnd1

					Mov _bFundalCiupit, TRUE
					Mov _bPrimaData, FALSE

					;Porneste butoanele`
					Invoke EnableControls, hWnd, TRUE
				
				.EndIf

			.Else
				;Ciupeste din ecran
				Invoke GetMenu, _hWnd1
				Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_GRAYED

				;Ciupeste din ecran
				Invoke CiupesteFundal, hWnd
				Mov _bFundalCiupit, TRUE
				Mov _bPrimaData, FALSE

				Invoke SaveMasterDC, _hWnd1
				Mov Eax, _hMasterDC
				Mov _hUndoDC, Eax
				Invoke SetUndoDC, hIContur
				Invoke ToggleUndoMnu, _hWnd1

				;Porneste butoanele`
				Invoke EnableControls, hWnd, TRUE
				
			.EndIf

		.ElseIf wParam == IDC_WINDOW1_BTNRESET
			;Actualizeaza
			Invoke SetWindowText, hWnd, Offset sNormal
			;Reseteaz
			Invoke Reseteaza, hWnd
			;Opreste butoanele
			Invoke EnableControls, hWnd, FALSE

		.ElseIf wParam == IDC_WINDOW1_BTNCONTUR
			Invoke SetWindowText, hWnd, Offset sAsteptati
			Invoke Contureaza, hWnd
			Invoke SetWindowText, hWnd, Offset sNormal

			Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNCONTUR
			Invoke EnableWindow, Eax, FALSE		

		.ElseIf wParam == IDC_WINDOW1_BTNSEND2CNC
			Invoke Send2CNC
			.If !_bPrimaData
				Invoke SendMessage, _hWnd2, WM_CLOSE, 0, 0
				Invoke Send2CNC
				Mov _bPrimaData, TRUE
			.EndIf

			Mov _bSimulat, FALSE

		.EndIf

	.ElseIf uMsg == WM_DROPFILES
		.If _bFundalCiupit
			Jmp @F
				szLoadDBmp DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
				szLoadDBmpTitlu DB "Sunteti sigur(a)", 0
@@:
			Invoke MessageBox, hWnd, Addr szLoadDBmp, Addr szLoadDBmpTitlu, MB_YESNO + MB_ICONQUESTION

			.If Eax != 7
				Jmp openDBmp
			.Else
				Jmp notOpenDBmp
			.EndIf

		.EndIf

openDBmp:
		Invoke DragQueryFile, wParam, 0, Addr sDragFile, SizeOf sDragFile ;return lenght

			.If Eax
				Invoke GolesteString, Addr _sNumeFisier, MAX_PATH
				Invoke szCatStr, Addr _sNumeFisier, Addr sDragFile

				Invoke bugFix0, hWnd
				Invoke IncarcaImagine, Offset sDragFile, hWnd
				.If !Eax
					Invoke MessageBox, hWnd, Addr sErrBmpNotLoaded, 0, MB_ICONSTOP
				.Else
					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 115
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 310, SWP_NOZORDER

						Invoke RestRgnFer, hWnd

						Sub dimBmp.x, 115
						Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 115
						Add dimBmp.y, 54
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

						Invoke RestRgnFer, hWnd

						Invoke IncarcaImagine, Offset _sNumeFisier, hWnd

					.EndIf

					Invoke GetMenu, _hWnd1
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_ENABLED

					Invoke SaveMasterDC, _hWnd1
					Mov Eax, _hMasterDC
					Mov _hUndoDC, Eax
					Invoke SetUndoDC, hIContur
					Invoke ToggleUndoMnu, _hWnd1

					Invoke EnableControls, hWnd, 1
					Mov _bPrimaData, FALSE
				.EndIf

			.EndIf

		;---free memory--
		Invoke DragFinish, wParam

		Mov _bFundalCiupit, TRUE

notOpenDBmp:

	.ElseIf uMsg == WM_MOVE
		Invoke RestRgnFer, hWnd
		Invoke ReposProgresMaxXY, hWnd

	.ElseIf uMsg == WM_SIZE
;		.If !_bFundalCiupit
			Invoke Reseteaza, hWnd
			Invoke SetWindowText, hWnd, Addr sNormal
			Invoke EnableControls, hWnd, FALSE
;		.Else
;			Invoke RestRgnFer, hWnd
;			Invoke GetWindowRect, hIContur, Addr patrat
;			Mov Eax, patrat.bottom
;			Mov Ecx, patrat.top
;			Sub Eax, Ecx

;			Mov Ebx, patrat.right
;			Mov Ecx, patrat.left
;			Sub Ebx, Ecx

;			Invoke BitBlt, hIConturDC, 0, 0, Eax, Ebx, _hMasterDC, 0, 0, SRCCOPY
;		.EndIf

	.ElseIf uMsg == WM_CLOSE
		.If _bAskOnExit
			Jmp @F
			szSigurIesi DB "Inchid aplicatia?", 0
@@:
			Invoke MessageBox, hWnd, Addr szSigurIesi, Addr _szSigur, MB_YESNO
			.If Eax != 6 ;NU
				Ret
			.EndIf

		.EndIf

		Invoke SalveazaSetari, Addr _szDefaultSettingsFile
		Invoke FadeOut, _hWnd1, 1
		Invoke ExitProcess, 0

		Invoke IsModal, hWnd
		.If Eax
			Invoke EndModal, hWnd, IDCANCEL
			Mov Eax, TRUE ;Return TRUE
			Ret
		.EndIf
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window1Procedure EndP

CiupesteFundal Proc hWnd:HWND
Local hDeskDC:HDC
Local hCompatDC:HDC
Local hRegiune:HDC
Local hImg:HWND
Local hImgDC:HDC
Local nW:DWord
Local nH:DWord
Local Xsrc:DWord
Local Ysrc:DWord
Local n:DWord

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Mov hImg, Eax

	;Calcule aicisa
	Invoke GetWindowRect, hImg, Offset patrat
	Fild patrat.right   ; Descazut
	Fild patrat.left    ; Scazator
	Fsub            	; Operatie scadere
	Fistp nW     		; Salveaza rezultatul in variabila

	Fild patrat.bottom 	; Descazut
	Fild patrat.top  	; Scazator
	Fsub            	; Operatie scadere
	Fistp nH     		; Salveaza rezultatul in variabila
	;Sub nH, 52

	Invoke GetWindowRect, hWnd, Offset patrat
	Fild patrat.left    ; Descazut
	Fild nCtrlsW		; Scazator
	Fadd           		; Operatie scadere
	Fistp Xsrc     		; Salveaza rezultatul in variabila

	Fild patrat.top	 	; Descazut
	Fild nStartTop		; Scazator
	Fadd            	; Operatie scadere
	Fistp Ysrc     		; Salveaza rezultatul in variabila

	Mov Eax, patrat.bottom
	Mov Ebx, patrat.top
	Sub Eax, Ebx

	.If Eax < 260
		Push Eax
		Invoke GetWindowRect, _hWnd1, Addr _patrat
		Mov Eax, _patrat.right
		Mov Ebx, _patrat.left
		Sub Eax, Ebx
		Sub Eax, 110
		Mov _patrat.right, Eax

		Mov Ebx, _patrat.bottom
		Mov Ecx, _patrat.top
		Sub Ebx, Ecx
		Sub Ebx, 50
		Mov _patrat.bottom, Ebx

		Pop Eax
		Mov Eax, patrat.right
		Mov Ecx, patrat.left
		Sub Eax, Ecx
		Add Eax, 12
		Invoke SetWindowPos, hWnd, _nToggleTopMost, patrat.left, patrat.top, Eax, 310, SWP_NOMOVE
		;Restaureaza Regiunea
		Invoke RestRgnFer, hWnd

		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke SetWindowPos, Eax, HWND_TOP, 0, 0, _patrat.right, _patrat.bottom, SWP_NOMOVE

	.Else
		;Restaureaza Regiunea
		Invoke RestRgnFer, hWnd

	.EndIf

	;Ascunde fereastra temporar
	Invoke SetLayeredWindowAttributes, hWnd, 10, 1, LWA_ALPHA

	;Decupeaza hDC desktop
	Invoke GetDC, 0
	Mov hDeskDC, Eax

	;Lipeste hDc desktop in imagine
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Mov hImg, Eax

	;Invoke nDebug, 0, nH
	;Desenare
	Invoke GetDC, hImg
	Invoke BitBlt, Eax, 0, 0, nW, nH, hDeskDC, Xsrc, Ysrc, SRCCOPY

	;Invoke nDebug, 0, nW

	;Arata fereastra iar
	;Invoke Sleep, 1000
	Invoke SetLayeredWindowAttributes, hWnd, 10, 255, LWA_ALPHA

	Invoke SetWindowText, hWnd, Offset sCopiat

	Ret
CiupesteFundal EndP


Contureaza Proc hWnd:HWND
Local X1:DWord
Local X2:DWord
Local Y1:DWord
Local Y2:DWord

	Mov X1, 0
	Mov Y1, 0

	;Calcule aicisa
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Offset patrat
	Fild patrat.right ; Descazut
	Fild X1  	  	  ; Scazator
	Fadd        	  ; Operatie scadere
	Fistp X2     	  ; Salveaza rezultatul in variabila

	Fild patrat.bottom	; Descazut
	Fild Y1			 	; Scazator
	Fadd             	; Operatie scadere
	Fistp Y2      	 	; Salveaza rezultatul in variabila

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Mov hdcpict, Eax


	;Mov X2, 200
    ;Mov Y2, 200
	;Invoke nDebug, hWnd, X2

	Invoke GetDlgItemInt, hWnd, IDC_WINDOW1_EDIT1, Addr translated, 0
	And Al, 0F0H
	Mov Ebx, 0
	Mov Bl, Al
	Rol Ebx, 8
	Mov Bl, Al
          Rol Ebx, 8
          Mov Bl, Al
	Mov scaragri, Ebx


Jmp ffd
;**********************************inceput nou

	Mov Eax, X1
	Mov linie, Eax
	Mov Eax, Y1
	Mov coloana, Eax

	.Repeat
		.Repeat
Mov nr, 0
			Push linie
			Pop linie1
			Push coloana
			Pop coloana1

			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 1
            .EndIf
Inc coloana1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 10
            .EndIf

Inc coloana1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 100
            .EndIf

Inc coloana1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 1000
            .EndIf

.If nr == 1001
	Dec coloana1
		Invoke SetPixel, hdcpict, linie1, coloana1, 0

	Dec coloana1
		Invoke SetPixel, hdcpict, linie1, coloana1, 0
.EndIf

			Inc coloana

		Mov Eax, Y2
		.Until coloana == Eax

		Mov Eax, Y1
		Mov coloana, Eax
		Inc linie

	Mov Eax, X2
	.Until linie == Eax


;**********************************

;**********************************

	Mov Eax, X1
	Mov linie, Eax
	Mov Eax, Y1
	Mov coloana, Eax

	.Repeat
		.Repeat
Mov nr, 0
			Push linie
			Pop linie1
			Push coloana
			Pop coloana1

			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 1
            .EndIf
Inc linie1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 10
            .EndIf

Inc linie1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 100
            .EndIf

Inc linie1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri
			.If !Eax
				Add nr, 1000
            .EndIf

.If nr == 1001
	Dec linie1
		Invoke SetPixel, hdcpict, linie1, coloana1, 0

	Dec linie1
		Invoke SetPixel, hdcpict, linie1, coloana1, 0
.EndIf

			Inc linie

		Mov Eax, X2
		.Until linie == Eax

		Mov Eax, X1
		Mov linie, Eax
		Inc coloana

	Mov Eax, Y2
	.Until coloana == Eax

ffd:
;**********************************sfarsit nou

	Mov Eax, X1
	Mov linie, Eax
	Mov Eax, Y1
	Mov coloana, Eax
	.Repeat
		.Repeat



			Push linie
			Pop linie1
			Push coloana
			Pop coloana1
			Invoke GetPixel, hdcpict, linie1, coloana1
			And Eax, scaragri

			.If !Eax

				Dec linie1
				Dec coloana1

;				Invoke GetPixel, hdcpict, linie1, coloana1
;				And Eax, scaragri
;				.If Eax
;					Invoke SetPixel, hdcpict, linie1, coloana1, Red
;				.EndIf
				Inc linie1
;*************************************************************
				Invoke GetPixel, hdcpict, linie1, coloana1
				And Eax, scaragri
				.If Eax
					Invoke SetPixel, hdcpict, linie1, coloana1, Red
				.EndIf
				Inc linie1
;********************************************************************
;				Invoke GetPixel, hdcpict, linie1, coloana1
;				And Eax, scaragri
;				.If Eax
;					Invoke SetPixel, hdcpict, linie1, coloana1, Red
;				.EndIf
				Inc coloana1
;****************************************************************
				Invoke GetPixel, hdcpict, linie1, coloana1
				And Eax, scaragri
				.If Eax
					Invoke SetPixel, hdcpict, linie1, coloana1, Red
				.EndIf
				Inc coloana1
;*********************************************************************
;				Invoke GetPixel, hdcpict, linie1, coloana1
;				And Eax, scaragri
;				.If Eax
;					Invoke SetPixel, hdcpict, linie1, coloana1, Red
;				.EndIf
				Dec linie1

				Invoke GetPixel, hdcpict, linie1, coloana1
				And Eax, scaragri
				.If Eax
					Invoke SetPixel, hdcpict, linie1, coloana1, Red
				.EndIf
				Dec linie1

;				Invoke GetPixel, hdcpict, linie1, coloana1
;				And Eax, scaragri
;				.If Eax
;					Invoke SetPixel, hdcpict, linie1, coloana1, Red
;				.EndIf
				Dec coloana1

				Invoke GetPixel, hdcpict, linie1, coloana1
				And Eax, scaragri
				.If Eax
					Invoke SetPixel, hdcpict, linie1, coloana1, Red
				.EndIf

			.EndIf
			Inc linie

		Mov Eax, X2
		.Until linie == Eax

		Mov Eax, X1
		Mov linie, Eax
		Inc coloana

	Mov Eax, Y2
	.Until coloana == Eax
;*************************************************************

	Mov Eax, X1
	Mov linie, Eax
	Mov Eax, Y1
	Mov coloana, Eax

	.Repeat
		.Repeat
			Invoke GetPixel, hdcpict, linie, coloana
			.If Eax == Red
				Invoke SetPixel, hdcpict, linie, coloana, 0
			.Else
				Invoke SetPixel, hdcpict, linie, coloana, White
			.EndIf

			Inc linie

		Mov Eax, X2
		.Until linie == Eax

		Mov Eax, X1
		Mov linie, Eax
		Inc coloana

	Mov Eax, Y2
	.Until coloana == Eax
;*****************************************************************
jos:

	Ret
Contureaza EndP

RestRgnFer Proc hWnd:HWND
Local nW:DWord
Local nH:DWord

	;Ia marimea ferestrei
	Invoke GetWindowRect, hWnd, Offset patrat

	;Calculeaza dimensiuni
	Fild patrat.right   ; Descazut
	Fild patrat.left    ; Scazator
	Fsub            	; Operatie scadere
	Fistp nW     		; Salveaza rezultatul in variabila

	Fild patrat.bottom 	; Descazut
	Fild patrat.top  	; Scazator
	Fsub            	; Operatie scadere
	Fistp nH     		; Salveaza rezultatul in variabila

	Invoke CreateRectRgn, 0, 0, nW, nH
	Invoke SetWindowRgn, hWnd, Eax, TRUE

	Ret
RestRgnFer EndP


SetRgnFer Proc hWnd:HWND
Local nW:DWord
Local nH:DWord
Local n:DWord

;* O fereastra (XP style) are head-du de 31 pixeli

	;Ia marimea ferestrei
	Invoke GetWindowRect, hWnd, Offset patrat

	;Calculeaza dimensiuni
	Fild patrat.right   ; Descazut
	Fild patrat.left    ; Scazator
	Fsub            	; Operatie scadere
	Fistp nW     		; Salveaza rezultatul in variabila

	Fild patrat.bottom 	; Descazut
	Fild patrat.top  	; Scazator
	Fsub            	; Operatie scadere
	Fistp nH     		; Salveaza rezultatul in variabila


	;Seteaza punctlele
	;0, 0
	Mov punctA.x, 0
	Mov punctA.y, 0
	;W,0
	Mov Eax, nW
	Mov punctB.x, Eax
	Mov punctB.y, 0
	;W, H
	Mov punctC.x, Eax
	Mov Eax, nH
	Mov punctC.y, Eax
	;W-margin,H
	Mov punctD.y, Eax
		Fild nW
		Fild nMargin
		Fsub
		Fistp n
	Mov Eax, n
	Inc Eax
	Mov punctD.x, Eax
	;W-margin,StartTop
	Mov punctE.x, Eax
	Mov Eax, nStartTop
	Mov punctE.y, Eax
	;CtrlsW,StartTop
	Mov punctF.y, Eax
	Mov Eax, nCtrlsW
	Mov punctF.x, Eax
	;CtrlsW,H-margin
	Mov punctG.x, Eax
		Fild nH
		Fild nMargin
		Fsub
		Fistp n
	Mov Eax, n
	Inc Eax
	Mov punctG.y, Eax
	;W-margin,H-margin
	Mov punctH.y, Eax
		Fild nW
		Fild nMargin
		Fsub
		Fistp n
	Mov Eax, n
	Inc Eax
;	Sub Eax, 2    ;AICI MODIFICA pt marime gol colt dreapta jos
	Mov punctH.x, Eax
	;W-margin,H
	Mov punctI.x, Eax
	Mov Eax, nH
	Mov punctI.y, Eax
	;0,H
	Mov punctJ.x, 0
	Mov Eax, nH
	Mov punctJ.y, Eax

	;pA[0] = punctA
	Mov Edx, Offset punctA
	Mov [aRgn], Edx
	;pA[1] = punctB
	Mov Edx, Offset punctB
	Mov [aRgn + 8], Edx
	;pA[2] = punctC
	Mov Edx, Offset punctC
	Mov [aRgn + 16], Edx
	;pA[3] = punctD
	Mov Edx, Offset punctD
	Mov [aRgn + 24], Edx
	;pA[4] = punctE
	Mov Edx, Offset punctE
	Mov [aRgn + 32], Edx
	;pA[5] = punctF
	Mov Edx, Offset punctF
	Mov [aRgn + 40], Edx
	;pA[6] = punctG
	Mov Edx, Offset punctG
	Mov [aRgn + 48], Edx
	;pA[7] = punctH
	Mov Edx, Offset punctH
	Mov [aRgn + 56], Edx
	;pA[8] = punctI
	Mov Edx, Offset punctI
	Mov [aRgn + 64], Edx
	;pA[9] = punctJ
	Mov Edx, Offset punctJ
	Mov [aRgn + 72], Edx


	;Mov Eax, Offset aRgn
	Invoke CreatePolygonRgn, aRgn, 10, WINDING
	Mov hRgn, Eax


	Invoke SetWindowRgn, hWnd, hRgn, TRUE
	;Invoke nDebug, 0, hWnd
	;Invoke GlobalFree, pArray

	Ret
SetRgnFer EndP


RedimImg Proc hWnd:HWND
Local hCtrlHead:DWord
Local hBtnInchide:DWord
Local hImgContur:DWord
Local nW:DWord
Local nH:DWord
Local n:DWord

	;Ia handle
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Mov hImgContur, Eax

	;Ia marimea ferestrei
	Invoke GetWindowRect, hWnd, Offset patrat

	;Calculeaza dimensiuni
	Fild patrat.right   ; Descazut
	Fild patrat.left    ; Scazator
	Fsub            	; Operatie scadere
	Fistp nW     		; Salveaza rezultatul in variabila

	Fild patrat.bottom 	; Descazut
	Fild patrat.top  	; Scazator
	Fsub            	; Operatie scadere
	Fistp nH     		; Salveaza rezultatul in variabila

	Mov n, 122	; 105 + margine (10) ;122
	Fild nW   ; Descazut
	Fild n    ; Scazator
	Fsub      ; Operatie scadere
	Fistp nW   ; Salveaza rezultatul in variabila

	Mov n, 61
	Fild nH  		 ; Descazut
	Fild n   		 ; Scazator
	Fsub     		 ; Operatie scadere
	Fistp nH  		 ; Salveaza rezultatul in variabila

	;Actualizeaza pozitiile
	Invoke SetWindowPos, hImgContur, HWND_TOP, 100, 1, nW, nH, SWP_NOZORDER

	Ret
RedimImg EndP

ReposProgresMaxXY Proc hWnd:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetWindowRect, hIContur, Addr patrat
	Mov Eax, patrat.right
	Mov Ebx, patrat.left
	Sub Eax, Ebx
	Mov nW, Eax
	;Sub nW, 122

	Mov Eax, patrat.bottom
	Mov Ebx, patrat.top
	Sub Eax, Ebx
	Mov nH, Eax
	;Sub nH, 60

	;Actualizeaza pozitiile
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_PROGRESMAXX
	;Sub patrat.bottom, 212
	Mov Ebx, nCtrlsW
	Sub Ebx, 5
	Mov Ecx, _nMaxX
	Mov Edx, nH
	Sub Edx, 58
	.If nW <= Ecx
		Push Eax
		Invoke SetWindowPos, Eax, HWND_TOP, Ebx, Edx, 30, 12, SWP_NOZORDER
		;calcul lungime
		Mov Edx, _nMaxX
		Mov Ebx, nW
		Sub Edx, Ebx
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

		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, Ecx, 0
	.Else
		Push Eax
		Invoke SetWindowPos, Eax, HWND_TOP, Ebx, Edx, _nMaxX, 12, SWP_NOZORDER
		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, 100, 0
	.EndIf

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_PROGRESMAXY
	Sub patrat.right, 295
	Mov Ecx, _nMaxY
	Mov Edx, nW
	Sub Edx, 20
	.If nH <= Ecx
		Push Eax
		Invoke SetWindowPos, Eax, HWND_TOP, Edx, 1, 12, nH, SWP_NOZORDER

		;calcul lungime
		Mov Edx, _nMaxY
		Mov Ebx, nH
		Sub Edx, Ebx
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
		Push Eax
		Invoke SetWindowPos, Eax, HWND_TOP, Edx, 1, 12, _nMaxY, SWP_NOZORDER
		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, 100, 0
	.EndIf

	Ret
ReposProgresMaxXY EndP

RefreshProgresMaxXY Proc hWnd:HWND
Local nW:DWord
Local nH:DWord

	Invoke GetWindowRect, hIContur, Addr patrat
	Mov Eax, patrat.right
	Mov Ebx, patrat.left
	Sub Eax, Ebx
	Mov nW, Eax
	Sub nW, 122

	Mov Eax, patrat.bottom
	Mov Ebx, patrat.top
	Sub Eax, Ebx
	Mov nH, Eax
	Sub nH, 60

	;Actualizeaza pozitiile
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_PROGRESMAXX
	Sub patrat.bottom, 212
	Mov Ebx, nCtrlsW
	Sub Ebx, 5
	Mov Ecx, _nMaxX
	.If nW <= Ecx
		Push Eax
		;calcul lungime
		Mov Edx, _nMaxX
		Mov Ebx, nW
		Sub Edx, Ebx
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

		Pop Eax
		Invoke SendMessage, Eax, PBM_SETPOS, Ecx, 0
	.EndIf


	Invoke GetDlgItem, hWnd, IDC_WINDOW1_PROGRESMAXY
	Sub patrat.right, 295
	Mov Ecx, _nMaxY
	.If nH <= Ecx
		Push Eax

		;calcul lungime
		Mov Edx, _nMaxY
		Mov Ebx, nH
		Sub Edx, Ebx
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
	.EndIf

	Ret
RefreshProgresMaxXY EndP


Reseteaza Proc hWnd:HWND
	Invoke SetRgnFer, hWnd
	Invoke RedimImg, hWnd
	Invoke ReposProgresMaxXY, hWnd

	.If _bUndo
		Invoke GetMenu, _hWnd1
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUUNDOMAINIMG, MF_GRAYED
	.EndIf

	Mov _bFundalCiupit, FALSE
	Ret
Reseteaza EndP

ToggleTopMost Proc hWnd:HWND
Local nL1:DWord
Local nL2:DWord
Local nT1:DWord
Local nT2:DWord

	Invoke GetMenu, hWnd
	.If _nToggleTopMost == HWND_TOPMOST
		Mov _nToggleTopMost, HWND_NOTOPMOST
		Invoke CheckMenuItem, Eax, IDM_WINDOW1_TOGGLETOPMOST, MF_UNCHECKED
	.Else
		Mov _nToggleTopMost, HWND_TOPMOST
		Invoke CheckMenuItem, Eax, IDM_WINDOW1_TOGGLETOPMOST, MF_CHECKED
	.EndIf


	Invoke GetWindowRect, _hWnd1, Addr patrat
	Mov Eax, patrat.left
	Mov nL1, Eax
	Mov Eax, patrat.top
	Mov nT1, Eax
	Invoke SetWindowPos, _hWnd1, _nToggleTopMost, nL1, nT1, 0, 0, SWP_NOSIZE

	Invoke GetWindowRect, _hWnd2, Addr patrat
	Mov Eax, patrat.left
	Mov nL2, Eax
	Mov Eax, patrat.top
	Mov nT2, Eax
	Invoke SetWindowPos, _hWnd2, _nToggleTopMost, nL2, nT2, 0, 0, SWP_NOSIZE

	.If _hWnd6
		Invoke GetWindowRect, _hWnd6, Addr patrat
		Mov Eax, patrat.left
		Mov nL2, Eax
		Mov Eax, patrat.top
		Mov nT2, Eax
		Invoke SetWindowPos, _hWnd6, _nToggleTopMost, nL2, nT2, 0, 0, SWP_NOSIZE
	.EndIf

	Ret
ToggleTopMost EndP

EnableControls Proc hWnd:HWND, bVal:BOOL
	.If bVal
		Invoke GetMenu, hWnd
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSAVEBMP, MF_ENABLED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURESETIMAGE, MF_ENABLED
		Pop Eax
		Push Eax		
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUDOOUTLINE, MF_ENABLED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSEND2CNC, MF_ENABLED
		Pop Eax

		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNRESET
		Invoke EnableWindow, Eax, TRUE	
		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNCONTUR
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNSEND2CNC
		Invoke EnableWindow, Eax, TRUE			

	.Else
		Invoke GetMenu, hWnd
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSAVEBMP, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURESETIMAGE, MF_GRAYED
		Pop Eax
		Push Eax		
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUDOOUTLINE, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSEND2CNC, MF_GRAYED
		Pop Eax
		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNRESET
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNCONTUR
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BTNSEND2CNC
		Invoke EnableWindow, Eax, FALSE
	.EndIf

	Ret
EnableControls EndP

IncarcaImagine Proc szFilePath:DWord, hDestWnd:HWND
Local hSrcDC:DWord
Local hSrcBmp:DWord
Local n:DWord

	Invoke CreateCompatibleDC, 0
	Mov hSrcDC, Eax

	.If hSrcDC < 1
		Ret 0
	.EndIf

	Invoke LoadImage, 0, szFilePath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE Or LR_CREATEDIBSECTION
	Mov hSrcBmp, Eax

	.If hSrcBmp == 0
		Invoke DeleteDC, hSrcDC
		Mov Eax, 0
		Ret 0
	.EndIf

	;Incarca DC creat cu imaginea
	Invoke SelectObject, hSrcDC, hSrcBmp

	;Elibereaza memoria de imagine
	Invoke DeleteObject, hSrcBmp

	;Ia dimensiuni
	Invoke GetBmpDims, szFilePath, Addr dimBmp
	.If !Eax
		Ret
	.EndIf

	Invoke GetWindowRect, hDestWnd, Addr patrat
	Mov Eax, dimBmp.x
	Add Eax, nCtrlsW
	Add Eax, nMargin
	Mov dimBmp.x, Eax
	Mov Eax, dimBmp.y
	Add Eax, nStartTop
	Add Eax, nMargin
	Mov dimBmp.y, Eax

	Dec dimBmp.x
	Dec dimBmp.y
	Invoke SetWindowPos, hDestWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

	;Mareste obiectul cu imaginea
	Invoke GetDlgItem, hDestWnd, IDC_WINDOW1_IMGCONTUR
	Push Eax
	Invoke GetWindowRect, Eax, Addr patrat
	Fild patrat.bottom  ; Descazut
	Fild patrat.top  	; Scazator
	Fsub     			; Operatie scadere
	Fistp patrat.top 	; Salveaza rezultatul in variabila
	Fild patrat.right  	 ; Descazut
	Fild patrat.left   	 ; Scazator
	Fsub     			 ; Operatie scadere
	Fistp patrat.left	 ; Salveaza rezultatul in variabila
	Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

	Invoke RestRgnFer, hDestWnd

	;Copiaza memoria
	Pop Eax
	Invoke GetDC, Eax
	;Invoke MessageBox, hWnd, Offset sSuccesDC, Offset sSucces, 0
	Invoke BitBlt, Eax, 0, 0, dimBmp.x, dimBmp.y, hSrcDC, 0, 0, SRCCOPY

	Invoke CopyDC, hSrcDC, 0, 0, dimBmp.x, dimBmp.y
	Mov _hMasterDC, Eax

	Ret
IncarcaImagine EndP

SalveazaBmp Proc hWnd:HWND
	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Addr patrat
	Fild patrat.right
	Fild patrat.left
	Fsub
	Fistp _nBmpWidth
	Sub _nBmpWidth, 4 ;bug fix: scoate barile laterale (right si bottom) care is in plus

	Fild patrat.bottom
	Fild patrat.top
	Fsub
	Fistp _nBmpHeight
	Sub _nBmpHeight, 4 ;bug fix: scoate barile laterale (right si bottom) care is in plus

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Invoke CopyDC, Eax, 0, 0, _nBmpWidth, _nBmpHeight
	Mov _hMasterDC, Eax
	Invoke Dc2Bmp, _hMasterDC, Offset _sNumeFisier, 0, 0, _nBmpWidth, _nBmpHeight
	;Invoke WndDc2Bmp, hWnd, Offset _sNumeFisier

	Ret
SalveazaBmp EndP

bugFix0 Proc Public hWnd:DWord
	;bugFix #1
	.If bugFixTransp == 0
		Invoke GetWindowLong, hWnd, GWL_EXSTYLE
		Or Eax, WS_EX_LAYERED
		Invoke SetWindowLong, hWnd, GWL_EXSTYLE, Eax
		Invoke CiupesteFundal, hWnd
		Invoke RestRgnFer, hWnd
		Invoke SetLayeredWindowAttributes, hWnd, 10, 255, LWA_ALPHA

		;Ciupeste din ecran
		Mov bugFixTransp, 1
	.EndIf

	Ret
bugFix0 EndP

bugFix1 Proc hWnd:HWND
	Invoke Send2CNC
	Invoke SendMessage, _hWnd2, WM_CLOSE, 0, 0
	Ret
bugFix1 EndP

Window1ImgContur Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONUP
		.If wParam == 4		;shift
			;Invoke ToggleUndoMnu
			Invoke SetUndoDC, hIContur
			Invoke ToggleUndoMnu, _hWnd1

			;X
			Mov Eax, lParam
			Mov Edx, 0
			Mov Dx, Ax
			;Sub Edx, 8
			Push Edx

			;Y
			Mov Edx, 0
			Mov Eax, 0
			Mov Eax, lParam
			Mov Ecx, 010000H
			Div Ecx
			Mov Edx, 0
			Mov Dx, Ax
			;Sub Edx, 6

			Pop Ecx
			Invoke fl00dFill, Ecx, Edx, _nPixelColor, hIContur
		.EndIf

	.ElseIf uMsg == WM_RBUTTONUP
		.If wParam == 4  	;shift
			;Invoke ToggleUndoMnu
			Invoke SetUndoDC, hIContur
			Invoke ToggleUndoMnu, _hWnd1

			;X
			Mov Eax, lParam
			Mov Edx, 0
			Mov Dx, Ax
			;Sub Edx, 8
			Push Edx

			;Y
			Mov Edx, 0
			Mov Eax, 0
			Mov Eax, lParam
			Mov Ecx, 010000H
			Div Ecx
			Mov Edx, 0
			Mov Dx, Ax
			;Sub Edx, 6

			Pop Ecx
			Mov Eax, _nPixelColor
			Not Eax
			Invoke fl00dFill, Ecx, Edx, Eax, hIContur
		.EndIf

	.ElseIf uMsg == WM_DROPFILES
		.If _bFundalCiupit
			Jmp @F
				szLoadDragBmp DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
				szLoadDragBmpTitlu DB "Sunteti sigur(a)", 0
@@:
			Invoke MessageBox, hWnd, Addr szLoadDragBmp, Addr szLoadDragBmpTitlu, MB_YESNO + MB_ICONQUESTION

			.If Eax != 7
				Jmp openDragBmp
			.Else
				Jmp notOpenDragBmp
			.EndIf

		.EndIf

openDragBmp:
		Invoke DragQueryFile, wParam, 0, Addr sDragFile, SizeOf sDragFile ;return lenght

			.If Eax
				Invoke GolesteString, Addr _sNumeFisier, MAX_PATH
				Invoke szCatStr, Addr _sNumeFisier, Addr sDragFile
				
				Invoke bugFix0, _hWnd1
				Invoke IncarcaImagine, Offset sDragFile, _hWnd1
				.If !Eax
					Invoke MessageBox, 0, Addr sDragFile, 0, 0
					Invoke MessageBox, _hWnd1, Addr sErrBmpNotLoaded, 0, MB_ICONSTOP
				.Else

					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 115
						Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 310, SWP_NOZORDER

						Invoke RestRgnFer, _hWnd1

						Sub dimBmp.x, 115
						Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke IncarcaImagine, Offset _sNumeFisier, _hWnd1

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 115
						Add dimBmp.y, 54
						Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

						Invoke RestRgnFer, _hWnd1

						Invoke IncarcaImagine, Offset _sNumeFisier, _hWnd1

					.EndIf

					Invoke GetMenu, _hWnd1
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_ENABLED	

					Invoke SetUndoDC, hIContur
					Invoke ToggleUndoMnu, _hWnd1

					Invoke EnableControls, _hWnd1, 1
					Mov _bFundalCiupit, TRUE
					Mov _bPrimaData, FALSE
				.EndIf

			.EndIf

		;---free memory--
		Invoke DragFinish, wParam

		Mov _bFundalCiupit, TRUE

notOpenDragBmp:

	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window1ImgContur EndP

Window1progresMaxX Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_DROPFILES
		Invoke SendMessage, _hWnd1, WM_DROPFILES, wParam, lParam
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window1progresMaxX EndP

Window1progresMaxY Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_DROPFILES
		Invoke SendMessage, _hWnd1, WM_DROPFILES, wParam, lParam
	.EndIf
	Xor Eax, Eax	;Return FALSE
	Ret
Window1progresMaxY EndP

MaxXWin Proc
	Invoke SetInputBoxInt, _nMaxX, 0

	Jmp @F
		szMaxX DB "Lungime ( X )", 0
@@:

	Invoke InputBoxWin, _hWnd1, Addr szMaxX, Addr punct
	Mov Eax, punct.x

	.If Eax > 3000
		Jmp @F
			szXPreaMare DB "Numarul e prea mare. [1-3000]", 0
@@:
		Invoke MessageBox, _hWnd1, Addr szXPreaMare, 0, 0

		Mov Eax, 0
		Ret
	.Else
		Mov _nMaxX, Eax
	.EndIf

	Ret
MaxXWin EndP


MaxYWin Proc
	Invoke SetInputBoxInt, _nMaxY, 0

	Jmp @F
		szMaxY DB "Latime ( Y )", 0
@@:

	Invoke InputBoxWin, _hWnd1, Addr szMaxY, Addr punct
	Mov Eax, punct.x

	.If Eax > 3000
		Jmp @F
			szYPreaMare DB "Numarul e prea mare. [1-3000]", 0
@@:
		Invoke MessageBox, _hWnd1, Addr szYPreaMare, 0, 0

		Mov Eax, 0
		Ret
	.Else
		Mov _nMaxY, Eax
	.EndIf

	Ret
MaxYWin EndP

ToggleAskOnExit Proc
	.If _bAskOnExit
		Mov _bAskOnExit, FALSE
		Invoke GetMenu, _hWnd1
		Invoke CheckMenuItem, Eax, IDM_WINDOW1_MNUASKONEXIT, MF_UNCHECKED
	.Else
		Mov _bAskOnExit, TRUE
		Invoke GetMenu, _hWnd1
		Invoke CheckMenuItem, Eax, IDM_WINDOW1_MNUASKONEXIT, MF_CHECKED
	.EndIf

	Ret
ToggleAskOnExit EndP
