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
BmpBaseID			Equ 222
nPopIDSend2Paint	Equ 277
nPopIDOpenFromPaint Equ 278
nPopIDSave			Equ 279
nPopIDInvert		Equ 280
MnuAboutSysID 		Equ 202

.Data?
;REGIUNE
hRgn 			DD ?
aRgn 			DWord 10 Dup(?)
szNGCode		DB 16 Dup(?)

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
sNormal 	DB "CostyContur 1.0", 0
sCopiat  	DB "CostyContur 1.0 - Ecran copiat" , 0
sAsteptati  DB "CostyContur 1.0 - Asteptati...", 0

;Meniu Despre
szTitluDespre 	DB "Despre noi [i]", 0

;Creare ferestre
sWin2 DB "Window2", 0
sWin3 DB "Window3", 0
sWin5 DB "Window5", 0
sWin6 DB "Window6", 0
sWin7 DB "Window7", 0

;Send 2 Paint
szPopMenuSend2Paint 	DB "Deschide in Paint", 0
szPopMenuOpenFromPaint  DB "Incarca din Paint", 0
szPopMenuSave			DB "Salveaza *.bmp", 0
szPopMenuInvert			DB "Inverseaza culorile", 0

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

		Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
		Mov hIContur, Eax
		Invoke GetDC, Eax
		Mov hIConturDC, Eax
      	Mov hdcpict, Eax

		Invoke Create, Addr sWin2, NULL, NULL, NULL
		Mov _hWnd2, Eax

		Invoke Create, Addr sWin3, NULL, NULL, NULL
		Mov _hWnd3, Eax
		Invoke ShowWindow, _hWnd3, SW_HIDE

		Jmp @F
			szBadCSMBufferAlloc DB "Nu s-a putut aloca atata memorie [_hMemCSMBuffer].", 0
@@:
		Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, 1024000
		Mov _hMemCSMBuffer, Eax
		.If !Eax
			Invoke MessageBox, _hWnd1, Addr szBadCSMBufferAlloc, 0, MB_ICONINFORMATION
			Invoke ExitProcess, 0
		.EndIf
		Invoke GlobalLock, Eax
		Mov _pCSMBuffer, Eax

		Jmp @F
			szBadCSMCompAlloc DB "Nu s-a putut aloca atata memorie [_hMemCSMCompBuffer].", 0
@@:
		Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, 1024000
		Mov _hMemCSMCompBuffer, Eax
		.If !Eax
			Invoke MessageBox, _hWnd1, Addr szBadCSMCompAlloc, 0, MB_ICONINFORMATION
			Invoke ExitProcess, 0
		.EndIf
		Invoke GlobalLock, Eax
		Mov _pCSMCompBuffer, Eax

		Jmp @F
			szBadCSMBascomAlloc DB "Nu s-a putut aloca atata memorie [_hMemCSMBascom].", 0
@@:
		Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, 1024000
		Mov _hMemCSMBascom, Eax
		.If !Eax
			Invoke MessageBox, _hWnd1, Addr szBadCSMBascomAlloc, 0, MB_ICONINFORMATION
			Invoke ExitProcess, 0
		.EndIf
		Invoke GlobalLock, Eax
		Mov _pCSMBascom, Eax

		Jmp @F
			szBadCGCodeAlloc DB "Nu s-a putut aloca atata memorie [_hMemGCode].", 0
@@:
		Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, 1024000
		Mov _hMemGCode, Eax
		.If !Eax
			Invoke MessageBox, _hWnd1, Addr szBadCGCodeAlloc, 0, MB_ICONINFORMATION
			Invoke ExitProcess, 0
		.EndIf
		Invoke GlobalLock, Eax
		Mov _pGCode, Eax

		Invoke InsertSysMenu, hWnd, 0, MnuAboutSysID, Addr szTitluDespre
		Mov Eax, MnuAboutSysID
		Dec Eax
		Invoke InsertSysMenu, hWnd, 1, Eax, 0

		Invoke IncarcaSetari, Addr _szDefaultSettingsFile
		.If Eax
			;Invoke nDebug, 0, _nMaxX
			Invoke UpdateSetari
		.EndIf

		Invoke GetCurrentDirectory, MAX_PATH, Addr _szCurDir
		Invoke szCatStr, Addr _szDefaultSettingsFile, Addr _szCurDir
		Invoke szCatStr, Addr _szDefaultSettingsFile, Addr _szDefaultSettings
		Invoke szCatStr, Addr _szCSMBascomFile, Addr _szCurDir
		Invoke szCatStr, Addr _szCSMBascomFile, Addr _szBascom
		Invoke szCatStr, Addr _szCSMBascomCompFile, Addr _szCurDir
		Invoke szCatStr, Addr _szCSMBascomCompFile, Addr _szBascomComp
		Invoke szCatStr, Addr _szCSMBascomRaw, Addr _szCurDir
		Invoke szCatStr, Addr _szCSMBascomRaw, Addr _szBascomRaw
		Invoke szCatStr, Addr _szCSMGCodeFile, Addr _szCurDir
		Invoke szCatStr, Addr _szCSMGCodeFile, Addr _szGcode
		Invoke szCatStr, Addr _szGCodeEditorFile, Addr _szCurDir
		Invoke szCatStr, Addr _szGCodeEditorFile, Addr _szGCodeEditor
		Jmp @F
			szGhilimele DB 022H, 0
@@:
		Invoke szCatStr, Addr _szDefaultSCM, Addr szGhilimele
		Invoke szCatStr, Addr _szDefaultSCM, Addr _szCSMBascomCompFile
		Invoke szCatStr, Addr _szDefaultSCM, Addr szGhilimele
		Invoke szCatStr, Addr _szCSMDirFisiere, Addr _szCurDir
		Jmp @F
			szFileDir DB "\fisiere", 0
@@:
		Invoke szCatStr, Addr _szCSMDirFisiere, Addr szFileDir
		Invoke GetShortPathName, Addr _szCSMDirFisiere, Addr _szCSMDirFisiere, MAX_PATH
		Invoke szUpper, Addr _szCSMDirFisiere

		Invoke GetShortPathName, Addr _szCurDir, Addr _szCSMSimPath, MAX_PATH
		Invoke szCatStr, Addr _szCSMSimPath, Addr _szCSMSimulator

		Invoke CreateDirectory, Addr _szDirFisiere, 0

		Invoke CreatePopupMenu
		Mov _hPopMenuW1, Eax

		Invoke AppendMenu, _hPopMenuW1, MF_POPUP, nPopIDSend2Paint, Addr szPopMenuSend2Paint
		Invoke AppendMenu, _hPopMenuW1, MF_POPUP, nPopIDOpenFromPaint, Addr szPopMenuOpenFromPaint
		Invoke AppendMenu, _hPopMenuW1, MF_SEPARATOR, 0, 0
		Invoke AppendMenu, _hPopMenuW1, MF_POPUP, nPopIDInvert, Addr szPopMenuInvert
		Invoke AppendMenu, _hPopMenuW1, MF_SEPARATOR, 0, 0
		Invoke AppendMenu, _hPopMenuW1, MF_POPUP, nPopIDSave, Addr szPopMenuSave

		Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		Invoke FadeIn, _hWnd1, 1

		Invoke GetDlgItem, hWnd, IDC_WINDOW1_BUTTON1
		Invoke SetFocus, Eax

		Return TRUE

	.ElseIf uMsg == WM_SYSCOMMAND
		.If wParam == MnuAboutSysID
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

					Invoke StrLen, Offset _sNumeFisier
					Mov Ebx, Eax
					Mov Eax, Offset _sNumeFisier
					Add Eax, Ebx
					Sub Eax, 4
					Mov Ecx, 0
					Mov [Eax], Ecx
					Push Eax

					Mov Ecx, 06963632EH		;.cci
					Mov [Eax], Ecx
					Invoke IncarcaSetari, Offset _sNumeFisier
					.If Eax
						Invoke UpdateSetari
					.EndIf

					Pop Eax
					Mov Ecx, 0706D622EH		;.bmp
					Mov [Eax], Ecx

					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
;					Invoke nDebug, 0, dimBmp.x
;					Invoke nDebug, 0, dimBmp.y

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 124
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 350, SWP_NOMOVE

						Invoke RestRgnFer, hWnd

						Sub dimBmp.x, 122
						Add dimBmp.y, 2
						Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 124
						Add dimBmp.y, 63
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke RestRgnFer, hWnd

						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

					.EndIf

saveBMP:
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
					Push Eax
					Invoke SetMenuItemInfo, Eax, IDM_WINDOW1_MNURELOADBMP, 0, Addr infMenu
					Pop Eax
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_ENABLED

					Invoke EnableControls, hWnd, 1
					Mov _bFundalCiupit, TRUE
					Mov _bPrimaData, FALSE

				.EndIf

			.EndIf
notOpenBmp:

		.ElseIf wParam == IDM_WINDOW1_MNUOPENCSM

			.If _bFundalCiupit
				Jmp @F
					szLoadNewCSM DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
					szLoadNewCSMTitlu DB "Sunteti sigur(a)", 0
@@:
				Invoke MessageBox, _hWnd1, Addr szLoadNewCSM, Addr szLoadNewCSMTitlu, MB_YESNO + MB_ICONQUESTION
				.If Eax == 7
					Ret
				.EndIf

			.EndIf

			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisierCSM, Offset _sDefPrestabCSM
			Invoke DeschideFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke IncarcaCSM, Addr _sNumeFisier

				Invoke StrLen, Offset _sNumeFisier
				Mov Ebx, Eax
				Mov Eax, Offset _sNumeFisier
				Add Eax, Ebx
				Sub Eax, 4
				Mov Ecx, 0
				Mov [Eax], Ecx
				Push Eax

				Mov Ecx, 06963632EH		;.cci
				Mov [Eax], Ecx
				Invoke IncarcaSetari, Offset _sNumeFisier
				.If Eax
					Invoke UpdateSetari
				.EndIf

				Pop Eax
				Mov Ecx, 06D73632EH		;.bmp
				Mov [Eax], Ecx

			.EndIf
			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		.ElseIf wParam == IDM_WINDOW1_MNUOPENGCODE
			.If _bFundalCiupit
				Jmp @F
					szLoadNewGCode DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
					szLoadNewGCodeTitlu DB "Sunteti sigur(a)", 0
@@:
				Invoke MessageBox, _hWnd1, Addr szLoadNewGCode, Addr szLoadNewGCodeTitlu, MB_YESNO + MB_ICONQUESTION
				.If Eax == 7
					Ret
				.EndIf

			.EndIf

			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisierGCode, Offset _sDefPrestabGCode
			Invoke DeschideFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke IncarcaGCode, Addr _sNumeFisier

				Invoke StrLen, Offset _sNumeFisier
				Mov Ebx, Eax
				Mov Eax, Offset _sNumeFisier
				Add Eax, Ebx
				Sub Eax, 4
				Mov Ecx, 0
				Mov [Eax], Ecx
				Push Eax

				Mov Ecx, 06963632EH		;.cci
				Mov [Eax], Ecx
				Invoke IncarcaSetari, Offset _sNumeFisier
				.If Eax
					Invoke UpdateSetari
				.EndIf

				Pop Eax
				Mov Ecx, 06D73632EH		;.bmp
				Mov [Eax], Ecx

			.EndIf

			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		.ElseIf wParam == IDM_WINDOW1_MNUOPENCAMERA
			.If !_hWnd6
				Invoke Create, Addr sWin6, 0, 0, 0
				Mov _hWnd6, Eax
			.Else
				Invoke SetFocus, _hWnd6
			.EndIf

		.ElseIf wParam == IDM_WINDOW1_MNUOPENFILEDIR
			Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNUOPENFILEDIR, 0

		.ElseIf wParam == IDM_WINDOW1_MNUCSMSIMULATOR
			Jmp @F
					szOpenCSMSim DB "Open", 0
@@:
			Invoke ShellExecute, hWnd, Addr szOpenCSMSim, Addr _szCSMSimPath, 0, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW1_MNUGCODEEDITOR
			Jmp @F
					szOpenGCodeEditor DB "Open", 0
@@:
			Invoke ShellExecute, hWnd, Addr szOpenGCodeEditor, Addr _szGCodeEditorFile, 0, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW1_MNUSEND2PAINT

			Jmp @F
				szOpenDebugBmp DB "Open", 0
				szMsPaint DB "mspaint", 0
				szPartition DB "C:", 0
				szDbgBmp DB "debug.bmp", 0
@@:
			Invoke GolesteString, Addr _sNumeFisier, MAX_PATH
			Invoke szCatStr, Addr _sNumeFisier, Addr szPartition
   			Invoke szCatStr, Addr _sNumeFisier, Addr szDbgBmp

			Invoke SalveazaBmp, _hWnd1
			.If Eax
				Invoke ShellExecute, _hWnd1, Addr szOpenDebugBmp, Addr szMsPaint, Addr _sNumeFisier, 0, SW_SHOW
				Jmp saveBMP
			.Else
				Jmp @F
					szErrNoDebugBmp DB "Nu s-a putut salva imaginea pe disc.", 0
@@:
   				Invoke MessageBox, _hWnd1, Addr szErrNoDebugBmp, 0, MB_ICONINFORMATION
			.EndIf
			;ion

		.ElseIf wParam == IDM_WINDOW1_MNURELOADBMP
			Invoke IncarcaImagine, Offset _sNumeFisier, hWnd
			Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

			;Invoke nDebug, 0, Eax
			.If dimBmp.y < 260
				Add dimBmp.x, 124
				Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 350, SWP_NOMOVE

				Invoke RestRgnFer, hWnd

				Sub dimBmp.x, 122
				Add dimBmp.y, 2	
				Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
				Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

				Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
				.If !Eax
					Ret
				.EndIf
				Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

			.Else
				;Ia dimensiuni
				Add dimBmp.x, 124
				Add dimBmp.y, 63
				Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

				Invoke RestRgnFer, hWnd

				Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
				.If !Eax
					Ret
				.EndIf
				Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

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

;		.ElseIf wParam == IDM_WINDOW1_MNUSAVEGCODE
;			Jmp @F
;				sNotImpGCode DB "De implementat GCode", 0
;@@:
;   			Invoke MessageBox, hWnd, Addr sNotImpGCode, Addr sNotImpGCode, MB_ICONEXCLAMATION

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

		.ElseIf wParam == IDM_WINDOW1_MNUINVERTCOLORS
			Invoke InverseazaCulori

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
			Mov _nIndent, 0

			Invoke SaveMasterDC, _hWnd1
			Mov Eax, _hMasterDC
			Mov _hUndoDC, Eax


			Invoke ReincarcaWin2
			;Invoke Send2CNC
			.If !_bPrimaData
				;Invoke ReincarcaWin2
				;Invoke SendMessage, _hWnd2, WM_CLOSE, 0, 0
				;Invoke Send2CNC
				Mov _bPrimaData, TRUE
			.EndIf
			Invoke GetMenu, _hWnd2
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMFILE, MF_GRAYED
			Pop Eax
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMBYTESFILE, MF_GRAYED
			Pop Eax
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENGCODEFILE, MF_GRAYED
			Pop Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSUBINDENT, MF_GRAYED

			;Invoke ShowWindow, hWnd, FALSE

			Mov _bSimulat, FALSE

		.ElseIf wParam == nPopIDSend2Paint
			Invoke SendMessage, _hWnd1, WM_COMMAND, IDM_WINDOW1_MNUSEND2PAINT, 0

		.ElseIf wParam == nPopIDOpenFromPaint
			Jmp @F
				szDebugBmp DB "C:\debug.bmp", 0
@@:
			Invoke IncarcaImagine, Offset szDebugBmp, _hWnd1
			Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
			Push Eax
			Invoke GetWindowRect, Eax, Addr patrat
			Mov Eax, patrat.right
			Mov Ebx, patrat.left
			Sub Eax, Ebx
			Mov patrat.right, Eax

			Mov Eax, patrat.bottom
			Mov Ebx, patrat.top
			Sub Eax, Ebx
			Mov patrat.bottom, Eax

			Pop Eax
			Invoke GetDC, Eax
			Invoke BitBlt, Eax, 0, 0, patrat.right, patrat.bottom, _hMasterDC, 0, 0, SRCCOPY

		.ElseIf wParam == nPopIDSave
			Invoke SendMessage, hWnd, WM_COMMAND, IDM_WINDOW1_MNUSAVEBMP, 0

		.ElseIf wParam == nPopIDInvert
			Invoke SendMessage, hWnd, WM_COMMAND, IDM_WINDOW1_MNUINVERTCOLORS, 0

		.EndIf

	.ElseIf uMsg == WM_DROPFILES
		.If _bFundalCiupit
			Jmp @F
				szLoadDBmp DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
				szLoadDBmpTitlu DB "Sunteti sigur(a)", 0
@@:
			Invoke MessageBox, hWnd, Addr szLoadDBmp, Addr szLoadDBmpTitlu, MB_YESNO + MB_ICONQUESTION

			.If Eax != 7
				Jmp openFile
			.Else
				Jmp notOpenFile
			.EndIf

		.EndIf

openFile:
		Invoke DragQueryFile, wParam, 0, Addr sDragFile, SizeOf sDragFile ;return lenght
		Invoke StrLen, Addr sDragFile
		Mov Ebx, Offset sDragFile
		Add Eax, Ebx
		Sub Eax, 4
		Mov Eax, [Eax]

		Mov Edx, 0FFFFFF00H
		And Edx, Eax
		.If Eax == "msc."
			Jmp openCsm
		.ElseIf Edx == 0636E2E00H 	;"cn."
			Jmp openGCode
		.Else
			Mov Eax, 1
			Jmp openBmpFile
		.EndIf


openBmpFile:
			.If Eax
				Invoke GolesteString, Addr _sNumeFisier, MAX_PATH
				Invoke szCatStr, Addr _sNumeFisier, Addr sDragFile

				Invoke bugFix0, hWnd
				Invoke IncarcaImagine, Offset sDragFile, hWnd
				.If !Eax
					Invoke MessageBox, hWnd, Addr sErrBmpNotLoaded, 0, MB_ICONSTOP
				.Else
					Invoke StrLen, Offset _sNumeFisier
					Mov Ebx, Eax
					Mov Eax, Offset _sNumeFisier
					Add Eax, Ebx
					Sub Eax, 4
					Mov Ecx, 0
					Mov [Eax], Ecx
					Push Eax

					Mov Ecx, 06963632EH		;.cci
					Mov [Eax], Ecx
					Invoke IncarcaSetari, Offset _sNumeFisier
					.If Eax
						Invoke UpdateSetari
					.EndIf

					Pop Eax
					Mov Ecx, 0706D622EH		;.bmp
					Mov [Eax], Ecx

					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 124
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 350, SWP_NOMOVE

						Invoke RestRgnFer, hWnd

						Sub dimBmp.x, 122
						Add dimBmp.y, 2
						Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 124
						Add dimBmp.y, 63
						Invoke SetWindowPos, hWnd, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke RestRgnFer, hWnd

						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

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

					Invoke GolesteString, Addr szMenuBuffer, 1024
					Jmp @F
						szReincarcaBmp DB "Reincarca *.bmp - ", 0
@@:
					Invoke szCatStr, Addr szMenuBuffer, Addr szReincarcaBmp
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

			Jmp notOpenFile

openCsm:
		Invoke IncarcaCSM, Addr sDragFile
		Invoke StrLen, Offset _sNumeFisier
		Mov Ebx, Eax
		Mov Eax, Offset _sNumeFisier
		Add Eax, Ebx
		Sub Eax, 4
		Mov Ecx, 0
		Mov [Eax], Ecx
		Push Eax

		Mov Ecx, 06963632EH		;.cci
		Mov [Eax], Ecx
		Invoke IncarcaSetari, Offset _sNumeFisier
		.If Eax
			Invoke UpdateSetari
		.EndIf

		Pop Eax
		Mov Ecx, 06D73632EH		;.csm
		Mov [Eax], Ecx

		Jmp notOpenFile

openGCode:
		Invoke IncarcaGCode, Addr sDragFile

notOpenFile:

		;---free memory--
		Invoke DragFinish, wParam

		Mov _bFundalCiupit, TRUE


	.ElseIf uMsg == WM_MOVE
;		Invoke RestRgnFer, hWnd
;		Invoke ReposProgresMaxXY, hWnd

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

		Invoke GlobalUnlock, _hMemCSMBuffer
		Invoke GlobalFree, _hMemCSMBuffer
		Invoke GlobalUnlock, _hMemCSMCompBuffer
		Invoke GlobalFree, _hMemCSMCompBuffer
		Invoke GlobalUnlock, _hMemCSMBascom
		Invoke GlobalFree, _hMemCSMBascom
		Invoke GlobalUnlock, _hMemGCode
		Invoke GlobalFree, _hMemGCode

		Invoke SalveazaSetari, Addr _szDefaultSettingsFile
		Invoke FadeOut, _hWnd1, 1
		Invoke ExitProcess, 0

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
		Sub Eax, 124
		Mov _patrat.right, Eax

		Mov Ebx, _patrat.bottom
		Mov Ecx, _patrat.top
		Sub Ebx, Ecx
		Sub Ebx, 64
		Mov _patrat.bottom, Ebx

		Pop Eax
		Mov Eax, patrat.right
		Mov Ecx, patrat.left
		Sub Eax, Ecx
		;Add Eax, 12
		Invoke SetWindowPos, hWnd, _nToggleTopMost, patrat.left, patrat.top, Eax, 350, SWP_NOMOVE
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

	Invoke SaveMasterDC, _hWnd1
	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke SetUndoDC, Eax
	Invoke ToggleUndoMnu, _hWnd1

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
	Invoke SaveMasterDC, _hWnd1
	Mov Eax, _hMasterDC
	Mov _hUndoDC, Eax

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke DrawMasterDC, Eax

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke DrawMasterDC, Eax

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
	Sub nW, 122
	Mov Ebx, nCtrlsW
	Sub Ebx, 5
	Mov Ecx, _nMaxX
	Mov Edx, nH
	Sub Edx, 58
	.If nW <= Ecx
		Push Eax

		Invoke SetWindowPos, Eax, HWND_TOP, Ebx, Edx, nW, 12, SWP_NOZORDER
		;Invoke nDebug, 0, nW
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
	Add nW, 122

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_PROGRESMAXY
	Sub nH, 60
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
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSEND2PAINT, MF_ENABLED
		Pop Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUINVERTCOLORS, MF_ENABLED


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
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUSEND2PAINT, MF_GRAYED
		Pop Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUINVERTCOLORS, MF_GRAYED


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

;	Invoke GetWindowRect, hDestWnd, Addr patrat
;	Mov Eax, dimBmp.x
;	Add Eax, nCtrlsW
;	Add Eax, nMargin
;	Mov dimBmp.x, Eax
;	Mov Eax, dimBmp.y
;	Add Eax, nStartTop
;	Add Eax, nMargin
;	Mov dimBmp.y, Eax

	;Dec dimBmp.x
	;Dec dimBmp.y
	;Invoke SetWindowPos, hDestWnd, HWND_TOP, patrat.left, patrat.top, 100, 100, SWP_NOZORDER
	;Inc dimBmp.x
	;Inc dimBmp.y

	;Mareste obiectul cu imaginea
	Invoke GetDlgItem, hDestWnd, IDC_WINDOW1_IMGCONTUR
;	Push Eax
;	Invoke GetWindowRect, Eax, Addr patrat
;	Fild patrat.bottom  ; Descazut
;	Fild patrat.top  	; Scazator
;	Fsub     			; Operatie scadere
;	Fistp patrat.top 	; Salveaza rezultatul in variabila
;	Fild patrat.right  	 ; Descazut
;	Fild patrat.left   	 ; Scazator
;	Fsub     			 ; Operatie scadere
;	Fistp patrat.left	 ; Salveaza rezultatul in variabila
;	Pop Eax
;	Push Eax
;	Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOZORDER

	;Invoke RestRgnFer, hDestWnd

	;Copiaza memoria
;	Pop Eax
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
	Sub _nBmpWidth, 2 ;bug fix: scoate barile laterale (right si bottom) care is in plus

	Fild patrat.bottom
	Fild patrat.top
	Fsub
	Fistp _nBmpHeight
	Sub _nBmpHeight, 2 ;bug fix: scoate barile laterale (right si bottom) care is in plus

	Invoke GetDlgItem, hWnd, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Invoke CopyDC, Eax, 0, 0, _nBmpWidth, _nBmpHeight
	Mov _hMasterDC, Eax
	Invoke Dc2Bmp, _hMasterDC, Offset _sNumeFisier, 0, 0, _nBmpWidth, _nBmpHeight

	Invoke StrLen, Offset _sNumeFisier
	Mov Ebx, Eax
	Mov Eax, Offset _sNumeFisier
	Add Eax, Ebx
	Sub Eax, 4
	Mov Ecx, 0
	Mov [Eax], Ecx
	Push Eax

	Mov Ecx, 06963632EH		;.cci
	Mov [Eax], Ecx
	;Invoke MessageBox, 0, Addr _sNumeFisier, 0, 0
	Invoke SalveazaSetari, Addr _sNumeFisier

	Pop Eax
	Mov Ecx, 0706D622EH		;.bmp
	Mov [Eax], Ecx

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
	Invoke ReincarcaWin2
	;Invoke Send2CNC
	;Invoke SendMessage, _hWnd2, WM_CLOSE, 0, 0
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
		.Else
			Invoke GetCursorPos, Addr punct
			Invoke TrackPopupMenu, _hPopMenuW1, TPM_LEFTALIGN, punct.x, punct.y, 0, _hWnd1, NULL
		.EndIf

	.ElseIf uMsg == WM_DROPFILES
		.If _bFundalCiupit
			Jmp @F
				szLoadDragBmp DB "Renuntati la fundalul existent si incarcati noua imagine?", 0
				szLoadDragBmpTitlu DB "Sunteti sigur(a)", 0
@@:
			Invoke MessageBox, hWnd, Addr szLoadDragBmp, Addr szLoadDragBmpTitlu, MB_YESNO + MB_ICONQUESTION

			.If Eax != 7
				Jmp openDragFile
			.Else
				Mov Eax, 1
				Jmp notOpenDragFile
			.EndIf

		.EndIf

openDragFile:
		Invoke DragQueryFile, wParam, 0, Addr sDragFile, SizeOf sDragFile ;return lenght
		Invoke StrLen, Addr sDragFile
		Mov Ebx, Offset sDragFile
		Add Eax, Ebx
		Sub Eax, 4
		Mov Eax, [Eax]

		Mov Edx, 0FFFFFF00H
		And Edx, Eax

		.If Eax == "msc."
			Jmp openDragCsm
		.ElseIf Edx == 0636E2E00H 	;"cn."
			Jmp openDragGCode
		.Else
			Mov Eax, 1
			Jmp openDragBmp
		.EndIf

openDragBmp:
			.If Eax
				Invoke GolesteString, Addr _sNumeFisier, MAX_PATH
				Invoke szCatStr, Addr _sNumeFisier, Addr sDragFile
				
				Invoke bugFix0, _hWnd1
				Invoke IncarcaImagine, Offset sDragFile, _hWnd1
				.If !Eax
					;Invoke MessageBox, 0, Addr sDragFile, 0, 0
					Invoke MessageBox, _hWnd1, Addr sErrBmpNotLoaded, 0, MB_ICONSTOP
				.Else
					Invoke StrLen, Offset _sNumeFisier
					Mov Ebx, Eax
					Mov Eax, Offset _sNumeFisier
					Add Eax, Ebx
					Sub Eax, 4
					Mov Ecx, 0
					Mov [Eax], Ecx
					Push Eax

					Mov Ecx, 0696E692EH		;.ini
					Mov [Eax], Ecx
					Invoke IncarcaSetari, Offset _sNumeFisier
					.If Eax
						Invoke UpdateSetari
					.EndIf

					Pop Eax
					Mov Ecx, 0706D622EH		;.bmp
					Mov [Eax], Ecx

					Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp

					;Invoke nDebug, 0, Eax
					.If dimBmp.y < 260
						Add dimBmp.x, 124
						Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 350, SWP_NOMOVE

						Invoke RestRgnFer, _hWnd1

						Sub dimBmp.x, 122
						Add dimBmp.y, 2
						Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
						Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						;Invoke IncarcaImagine, Offset _sNumeFisier, _hWnd1
						;Ia dimensiuni
						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

					.Else
						;Ia dimensiuni
						Add dimBmp.x, 124
						Add dimBmp.y,63
						Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

						Invoke RestRgnFer, _hWnd1

						Invoke GetBmpDims, Addr _sNumeFisier, Addr dimBmp
						.If !Eax
							Ret
						.EndIf
						Invoke BitBlt, hIConturDC, 0, 0, dimBmp.x, dimBmp.y, _hMasterDC, 0, 0, SRCCOPY

					.EndIf

					Invoke GetMenu, _hWnd1
					Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNURELOADBMP, MF_ENABLED	

					Invoke SetUndoDC, hIContur
					Invoke ToggleUndoMnu, _hWnd1

					Invoke GolesteString, Addr szMenuBuffer, 1024
					Jmp @F
						szReincarcaBitmap DB "Reincarca *.bmp - ", 0
@@:
					Invoke szCatStr, Addr szMenuBuffer, Addr szReincarcaBitmap
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

					Invoke EnableControls, _hWnd1, 1
					Mov _bFundalCiupit, TRUE
					Mov _bPrimaData, FALSE
				.EndIf

			.EndIf

			Jmp notOpenDragFile

openDragCsm:
		Invoke IncarcaCSM, Addr sDragFile
		Invoke StrLen, Offset _sNumeFisier
		Mov Ebx, Eax
		Mov Eax, Offset _sNumeFisier
		Add Eax, Ebx
		Sub Eax, 4
		Mov Ecx, 0
		Mov [Eax], Ecx
		Push Eax

		Mov Ecx, 06963632EH		;.cci
		Mov [Eax], Ecx
		Invoke IncarcaSetari, Offset _sNumeFisier
		.If Eax
			Invoke UpdateSetari
		.EndIf

		Pop Eax
		Mov Ecx, 06D73632EH		;.csm
		Mov [Eax], Ecx

		Jmp notOpenDragFile

openDragGCode:
		Invoke IncarcaGCode, Addr sDragFile

notOpenDragFile:
		;---free memory--
		Invoke DragFinish, wParam

		Mov _bFundalCiupit, TRUE

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


IncarcaCSM Proc addrFisier:DWord
Local iOffset:DWord
Local iRepeat:DWord
Local hDCPic:HDC
Local hFile:HANDLE
Local nW:DWord
Local nH:DWord
Local vBrush:DWord
Local vPreviouseBrush:DWord
Local nFileSize:DWord

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Mov hDCPic, Eax

	Invoke CreateFile, addrFisier, GENERIC_READ, 0, 0, OPEN_ALWAYS, 0, 0
	Mov hFile, Eax
	.If !Eax
		Jmp @F
			szErr DB "Nu s-a putut citi fisierul", 0
@@:
		Invoke MessageBox, _hWnd1, Addr szErr, 0, 0
		Ret
	.Else
		Invoke GolesteString, _pCSMCompBuffer, 10240

		Invoke GetFileSize, hFile, 0
		Mov nFileSize, Eax
		Invoke ReadFile, hFile, _pCSMCompBuffer, nFileSize, Addr _nBytesUsed, NULL
		Invoke CloseHandle, hFile

;		Invoke StrLen, Addr _szCSMCompBuffer
		Mov Ebx, _pCSMCompBuffer
		Mov Eax, nFileSize
		Add Eax, Ebx
		Sub Eax, 4

		Mov Ecx, 0
		Mov Cx, [Eax]
		Mov nW, Ecx
		Add Eax, 2
		Mov Ecx, 0
		Mov Cx, [Eax]
		Mov nH, Ecx
	.EndIf

	Mov Eax, nW
	Mov dimBmp.x, Eax
	Mov Eax, nH
	Mov dimBmp.y, Eax
	.If dimBmp.y < 260
		Add dimBmp.x, 124
		Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, 350, SWP_NOMOVE

		Invoke RestRgnFer, _hWnd1

		Sub dimBmp.x, 122
		Add dimBmp.y, 2
		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke SetWindowPos, Eax, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

	.Else
		;Ia dimensiuni
		Add dimBmp.x, 124
		Add dimBmp.y, 63
		Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, dimBmp.x, dimBmp.y, SWP_NOMOVE

		Invoke RestRgnFer, _hWnd1
	.EndIf

;	Invoke GetWindowRect, _hWnd1, Addr patrat
;	Invoke SetWindowPos, _hWnd1, HWND_TOP, patrat.left, patrat.top, nW, nH, SWP_NOZORDER
;	Invoke RestRgnFer, _hWnd1

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Push Eax
	Invoke ShowWindow, Eax, SW_HIDE
	Pop Eax
	Push Eax
	Invoke ShowWindow, Eax, SW_SHOW
	Invoke SaveMasterDC, _hWnd1
	Pop Eax
	Invoke fl00dFill, 0, 0, White, Eax


	Mov iOffset, 0
inceput:
;	Mov Eax, iOffset
;	Mov Edx, 0
;	Mov Ebx, 4
;	Div Ebx
;	Invoke nDebug, _hWnd1, Eax
;	Invoke Sleep, 5

	Mov Ecx, _pCSMCompBuffer
	Add Ecx, iOffset

	Mov Eax, iOffset
	Mov Ebx, nFileSize
	Sub Ebx, 4

	.If Eax > Ebx
		Jmp sfarsit

	.Else
		Mov Ebx, [Ecx]
		Mov Eax, 0
		Mov Ax, Bx					;Y
		Push Eax

		Mov Eax, Ebx
		Mov Edx, 0
		Mov Ebx, 010000H
		Div Ebx
		Mov Ebx, Eax				; ebx = Y
		;Rol Ebx, 8
		Pop Eax						; eax = X

		Invoke SetPixel, hIConturDC, Eax, Ebx, Black

		Add iOffset, 4
		Jmp inceput
	.EndIf

	Invoke SaveMasterDC, _hWnd1
	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke SetUndoDC, Eax

sfarsit:
	Invoke EnableControls, _hWnd1, 1
	Mov _bFundalCiupit, TRUE
	Mov _bPrimaData, FALSE

	Ret
IncarcaCSM EndP


IncarcaGCode Proc pFileAddress:DWord
Local hFileGC:DWord
Local nFileSize:DWord
Local hDCPic:HDC
Local hMemory:DWord
Local hMemoryNou:DWord
Local nBytesUsed:DWord
Local nLastX:DWord
Local nLastY:DWord
Local nLastZ:DWord
Local isX:DWord
Local isY:DWord
;Local sfarsit:DWord
Local costyGC:DWord
Local pMem:DWord
Local pMemNou:DWord
Local sfarsitGC:DWord
Local xMareGC:DWord
Local xMicGC:DWord
Local yMareGC:DWord
Local yMicGC:DWord
Local zMareGC:DWord
Local zMicGC:DWord

	Mov costyGC, 0
	Mov sfarsitGC, 0
	Mov xMareGC, 0
	Mov xMicGC, 0
	Mov yMareGC, 0
	Mov yMicGC, 0
	Mov zMareGC, 0
	Mov zMicGC, 0
	Mov nLastX, 0
	Mov nLastY, 0
;	Mov nLastZ, 1


	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke GetDC, Eax
	Mov hDCPic, Eax

	Invoke StrLen, pFileAddress
	Sub Eax, 4
	Mov Ebx, pFileAddress
	Add Ebx, Eax
	Mov Ebx, [Ebx]
	And Ebx, 0FFFFFF00H

	.If Ebx == 0636E2E00H || Ebx == 0434E2E00H 		;"cn."  / "CN."
		;Fa nimic
	.Else
		Jmp @F
			szBadGcode DB "Fisierul nu este de tip *.nc", 0
@@:
   		Invoke MessageBox, _hWnd1, Addr szBadGcode, 0, MB_ICONINFORMATION
		Ret

	.EndIf

	Invoke CreateFile, pFileAddress, GENERIC_READ Or GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0
	Mov hFileGC, Eax

	.If Eax == INVALID_HANDLE_VALUE
		Jmp @F
			szBadGCode DB "Fisierul nu a putut fi deschis", 0
@@:
   		Invoke MessageBox, _hWnd1, Addr szBadGCode, 0, MB_ICONINFORMATION
		Ret
	.EndIf

	Jmp @F
		szBadAlloc DB "Nu s-a putut aloca atata memorie.", 0
@@:
	Invoke GetFileSize, hFileGC, 0
	Mov nFileSize, Eax

	Inc nFileSize

	Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, nFileSize
	Mov hMemory, Eax
	.If !Eax
		Invoke MessageBox, _hWnd1, Addr szBadAlloc, 0, MB_ICONINFORMATION
		Invoke CloseHandle, hFileGC
		Mov Eax, 0
		Ret
	.EndIf
	Invoke GlobalLock, Eax
	Mov pMem, Eax

	;Invoke nDebug, 0, 2
	Mov Eax, nFileSize
	Mov Ebx, 5
	IMul Ebx
	Invoke GlobalAlloc, GMEM_MOVEABLE Or GMEM_ZEROINIT, Eax
	Mov hMemoryNou, Eax
	.If !Eax
		Invoke MessageBox, _hWnd1, Addr szBadAlloc, 0, MB_ICONINFORMATION
		Invoke CloseHandle, hFileGC
		Invoke GlobalUnlock, hMemory
		Invoke GlobalFree, hMemory
		Mov Eax, 0
		Ret
	.EndIf
	Invoke GlobalLock, Eax
	Mov pMemNou, Eax

	Dec nFileSize
	Invoke ReadFile, hFileGC, pMem, nFileSize, Addr nBytesUsed, 0
	Invoke CloseHandle, hFileGC
	Inc nFileSize


	;============================================================
	;================ Verificari inainnte =======================
	;============================================================
	Mov Eax, [pMem]
	Add Eax, nFileSize					;FileSize
	Mov sfarsitGC, Eax

	Mov Eax, [pMem]
	.Repeat
		Mov Bl, [Eax]

		.If Bl == "I" || Bl == "i"
			Jmp @F
				szAreI DB "Instructiune 'I' gasita... abandonam", 0
@@:
			Invoke MessageBox, 0, Addr szAreI, 0, MB_ICONINFORMATION
			Jmp golesteMemoria

		.ElseIf Bl == "J" || Bl == "j"
			Jmp @F
				szAreJ DB "Instructiune 'J' gasita... abandonam", 0
@@:
			Invoke MessageBox, 0, Addr szAreJ, 0, MB_ICONINFORMATION
			Jmp golesteMemoria

		.ElseIf Bl == "("
	@@:
	        Mov Dl, "."
	        Mov [Eax], Dl
			Inc Eax
			.If Eax > sfarsitGC
				Jmp @F
			.EndIf
			Mov Bl, [Eax]
			Mov Dl, "."
			Mov [Eax], Dl
			Cmp Bl, 13
			Jne @B
		.EndIf

	Inc Eax
	.Until Eax > sfarsitGC

	@@:

	;======================================================================
	;pMem   	= offset Buffer fisier
	;hDCPic 	= hDC pictura
	;nFileSize  = lungime fisier (bytes)
	;======================================================================

	;===================================================================
	;START PRELUCRARE
	;===================================================================

	Mov Eax, [pMem]
	Add Eax, nFileSize							;Marime fisier
	Mov sfarsitGC, Eax
	Mov Eax, [pMem]

	.Repeat
		Mov Bl, [Eax]
	    .If Eax > sfarsitGC
	    	Jmp prelucrare2
	    .EndIf

		.If Bl == "X" || Bl == "x"
			Mov Bl, "X"
			Mov [Eax], Bl
		@@:
		    Inc Eax
			Mov Bl, [Eax]
		    Cmp Bl, "-"
		    Je @B
		    Cmp Bl, 039H
		    Jg fgh
		    Cmp Bl, 030H
		    Jb fgh
		    Jmp @B

		.ElseIf Bl == "Y" || Bl == "y"
			Mov Bl, "Y"
			Mov [Eax], Bl

		@@:
		    Inc Eax
			Mov Bl, [Eax]
		    Cmp Bl, "-"
		    Je @B
		    Cmp Bl, 039H
		    Jg fgh
		    Cmp Bl, 030H
		    Jb fgh
		    Jmp @B

		.ElseIf Bl == "Z" || Bl == "z"
			Mov Bl, "Z"
			Mov [Eax], Bl

		@@:
		    Inc Eax
			Mov Bl, [Eax]
		    Cmp Bl, "-"
		    Je @B
		    Cmp Bl, 039H
		    Jg fgh
		    Cmp Bl, 030H
		    Jb fgh
		    Jmp @B
		   .Else
		fgh:
		   	Mov Bl, 0
		    Mov [Eax], Bl
		   	Inc Eax

		.EndIf

	.Until Eax > sfarsitGC

	;========================================================
	;Initial:
	;...X100..Y5678
	;Rezultat:
	;Buffer nou : X[100n]Y[5678n]
	;========================================================
	;Mov Eax, 0
	;Mov Eax, 0
	;Mov Eax, 0
	;Mov Eax, 0


prelucrare2:

	Mov Eax, [pMem] ;veche
	Add Eax, nFileSize						;Marime fisier
	Mov sfarsitGC, Eax
	Mov Edx, [pMemNou]
	Mov Eax, [pMem] ;veche

	.Repeat
		Mov Bl, [Eax]
		.If Bl == "X"
			Mov [Edx], Bl
			Inc Edx
			Inc Eax
			Push Eax
			Push Edx
			Invoke atol, Eax
			Pop Edx
			Mov [Edx], Eax
			Pop Eax
			Add Edx, 4
		.ElseIf Bl == "Y"
			Mov [Edx], Bl
			Inc Edx
			Inc Eax
			Push Eax
			Push Edx
			Invoke atol, Eax
			Pop Edx
			Mov [Edx], Eax
			Pop Eax
			Add Edx, 4

		.ElseIf Bl == "Z"
			Mov [Edx], Bl
			Inc Edx
			Inc Eax
			Push Eax
			Push Edx
			Invoke atol, Eax
			Pop Edx
			Mov [Edx], Eax
			Pop Eax
			Add Edx, 4

		.EndIf
		Inc Eax

	.Until Eax > sfarsitGC

	;====================================================================
	;Initial:
	;Incarca xMareGC si xMicGC cu prima valoare gasita a X-ului
	;====================================================================
	Mov Eax, [pMemNou]

	@@:
		Mov Bl, [Eax]
		.If Bl == "X"
			Inc Eax
			Mov Ebx, [Eax]
			Mov xMareGC, Ebx
			Mov xMicGC, Ebx
			Jmp @F
		.EndIf
		Inc Eax
	Jmp @B


	;====================================================================
	;Initial:
	;Incarca yMareGC si yMicGC cu prima valoare gasita a Y-ului
	;====================================================================
	Mov Eax, [pMemNou]

	@@:
		Mov Bl, [Eax]
		.If Bl == "Y"
			Inc Eax
			Mov Ebx, [Eax]
			Mov yMareGC, Ebx
			Mov yMicGC, Ebx
			Jmp @F
		.EndIf
		Inc Eax
	Jmp @B
	@@:

	Mov Eax, [pMemNou]

	@@:
		Mov Bl, [Eax]
		.If Bl == "Z"
			Inc Eax
			Mov Ebx, [Eax]
			Mov zMareGC, Ebx
			Mov zMicGC, Ebx
			Jmp @F
		.EndIf
		Inc Eax
	Jmp @B
	@@:


	;===============================================================
	;Reintoare in xMareGC, xMicGC, yMareGC,yMicGC minimum si maximum
	;===============================================================
	Mov Eax, [pMemNou]
	Add Eax, nFileSize
	Mov sfarsitGC, Eax
	Mov Eax, [pMemNou]

	.Repeat
		Mov Bl, [Eax]
		.If Bl == "X"
		    Inc Eax
			Mov Ebx, [Eax]
			Cmp Ebx, xMareGC
			Jng @F
			Mov xMareGC, Ebx
			@@:
			Cmp Ebx, xMicGC
			Jg @F
			Mov xMicGC, Ebx
			@@:
			Add Eax, 3

		.ElseIf Bl == "Y"
			Inc Eax
			Mov Ebx, [Eax]
			Cmp Ebx, yMareGC
			Jng @F
			Mov yMareGC, Ebx
			@@:
			Cmp Ebx, yMicGC
			Jg @F
			Mov yMicGC, Ebx
			@@:
			Add Eax, 3

		.ElseIf Bl == "Z"
			Inc Eax
			Mov Ebx, [Eax]
			Cmp Ebx, zMareGC
			Jng @F
			Mov zMareGC, Ebx
			@@:
			Cmp Ebx, zMicGC
			Jg @F
			Mov zMicGC, Ebx
			@@:
			Add Eax, 3

		.EndIf
		Inc Eax

	.Until Eax > sfarsitGC

;===============================================================
;pMemNou = string prelucrat {X[100n]Y[1234n]}
;===============================================================

@@:
	Mov Eax, xMareGC
	.If xMicGC > Eax					;X este negativ
		Mov Ebx, 0
		Sub Ebx, xMicGC
		Mov xMicGC, Ebx
		Add xMareGC, Ebx
	.Else
		Cmp Eax, 07FFFFFFFH
		Jb @F
			Mov Ebx, 0
			Sub Ebx, yMicGC
			Mov yMicGC, Ebx
			Add yMareGC, Ebx
		Jmp iesireXMare
@@:
		Mov xMicGC, 0
	.EndIf
iesireXMare:


	Mov Eax, yMareGC
	.If yMicGC > Eax					;Y este negativ
		Mov Ebx, 0
		Sub Ebx, yMicGC
		Mov yMicGC, Ebx
		Add yMareGC, Ebx
	.Else
		Cmp Eax, 07FFFFFFFH
		Jb @F
			Mov Ebx, 0
			Sub Ebx, yMicGC
			Mov yMicGC, Ebx
			Add yMareGC, Ebx

		Jmp iesireYMax
@@:

		Mov yMicGC, 0
	.EndIf
iesireYMax:

	Mov Eax, zMareGC
	.If zMicGC > Eax					;Z este negativ
		Mov Ebx, 0
		Sub Ebx, zMicGC
		Mov zMicGC, Ebx
		Add zMareGC, Ebx
	.Else
		Cmp Eax, 07FFFFFFFH
		Jb @F
			Mov Ebx, 0
			Sub Ebx, zMicGC
			Mov zMicGC, Ebx
			Add zMareGC, Ebx

		Jmp iesireZMax
@@:

		Mov zMicGC, 0
	.EndIf
iesireZMax:

;	Invoke nDebug, 0, xMicGC
;	Invoke nDebug, 0, yMicGC
;	Invoke nDebug, 0, xMareGC
;	Invoke nDebug, 0, yMareGC
;	Invoke nDebug, 0, zMicGC
;	Invoke nDebug, 0, zMareGC

	Mov Eax, xMareGC
	Mov dimBmp.x, Eax
	Add dimBmp.x, 10
	Mov Eax, yMareGC
	Mov dimBmp.y, Eax
	Add dimBmp.y, 10
	.If dimBmp.y < 260
		Add dimBmp.x, 124
		Invoke SetWindowPos, _hWnd1, HWND_TOP, 0, 0, dimBmp.x, 350, SWP_NOMOVE

		Invoke RestRgnFer, _hWnd1

		Sub dimBmp.x, 122
		Add dimBmp.y, 2
		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
		Invoke SetWindowPos, Eax, HWND_TOP, 0, 0, dimBmp.x, dimBmp.y, SWP_NOMOVE

	.Else
		;Ia dimensiuni
		Add dimBmp.x, 124
		Add dimBmp.y, 63
		Invoke SetWindowPos, _hWnd1, HWND_TOP, 0, 0, dimBmp.x, dimBmp.y, SWP_NOMOVE

		Invoke RestRgnFer, _hWnd1
	.EndIf

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Push Eax
	Invoke ShowWindow, Eax, SW_HIDE
	Pop Eax
	Push Eax
	Invoke ShowWindow, Eax, SW_SHOW
	Invoke SaveMasterDC, _hWnd1
	Pop Eax
	Invoke fl00dFill, 0, 0, White, Eax

	Mov nLastX, 2
	Mov nLastY, 2
	;Move nLastZ, zMareGC
	;Invoke MoveToEx, hDCPic, nLastX, nLastY, 0
	;Invoke LineTo, hDCPic, nLastX, nLastY

	Mov Eax, pMemNou
	.Repeat
		Mov isX, 0
		Mov isY, 0

		Mov Ebx, [Eax]
		.If Bl == "Z"
			Inc Eax

			Mov Ebx, [Eax]
			Mov nLastZ, Ebx

			Mov Ecx, zMicGC
			Add nLastZ, Ecx

			Add Eax, 4
			Mov isY, 1					;Flag fals ca sa treaca
		.EndIf

		Mov Ebx, [Eax]
		.If Bl == "X"
			Inc Eax

			Mov Ebx, [Eax]
			Add Ebx, 2
			Mov nLastX, Ebx

			Mov Ecx, xMicGC
			Add nLastX, Ecx

			Add Eax, 4
			Mov isX, 1
		.EndIf

		Mov Ebx, [Eax]
		.If Bl == "Y"
			Inc Eax

			Mov Ebx, [Eax]
			Add Ebx, 2
			Mov nLastY, Ebx

			Mov Ecx, yMicGC
			Add nLastY, Ecx

			Add Eax, 4
			Mov isY, 1
		.EndIf

;		Push Eax
;			Invoke nDebug, 0, nLastX
;			Invoke nDebug, 0, nLastY
;		Pop Eax

		Mov Ebx, zMareGC
		.If nLastZ < Ebx
			Push Eax
	;		Invoke nDebug, 0, nLastX
	;		Invoke nDebug, 0, nLastY
			Invoke LineTo, hDCPic, nLastX, nLastY
			;Invoke MoveToEx, hDCPic, nLastX, nLastY, 0
			Pop Eax
		.Else
			Push Eax
			Invoke MoveToEx, hDCPic, nLastX, nLastY, 0
			Pop Eax
		.EndIf

	Mov Ebx, isX
	Or Ebx, isY
	.Until !Ebx

	Invoke SaveMasterDC, _hWnd1
	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke SetUndoDC, Eax

	Invoke EnableControls, _hWnd1, 1

;	Jmp @F
;		szStr1 DB "C:\cncTest.txt", 0
;@@:
;    ;Invoke MessageBox, 0, pMem, 0, 0
;	Invoke CreateFile, Addr szStr1, GENERIC_READ Or GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
;	Mov hFileGC, Eax
;	Invoke WriteFile, hFileGC, pMemNou, nFileSize, Addr nBytesUsed, 0
;	;Invoke GetLastError
;	Invoke nDebug, 0, nBytesUsed
;	Invoke CloseHandle, hFileGC
;=======================================================================

golesteMemoria:
	Invoke GlobalUnlock, hMemory
	Invoke GlobalFree, hMemory
	Invoke GlobalUnlock, hMemoryNou
	Invoke GlobalFree, hMemoryNou

	Mov _bFundalCiupit, TRUE

	Ret
IncarcaGCode EndP


InverseazaCulori Proc
Local hIC:DWord
Local nW:DWord
Local nH:DWord

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Mov hIC, Eax

	Invoke SaveMasterDC, _hWnd1
	Invoke SetUndoDC, hIC

	Invoke GetWindowRect, hIC, Addr patrat
	Fild patrat.right
	Fild patrat.left
	Fsub
	Fistp nW

	Fild patrat.bottom
	Fild patrat.top
	Fsub
	Fistp nH

	Invoke GetDC, hIC
	Invoke BitBlt, Eax, 0, 0, nW, nH, _hMasterDC, 0, 0, DSTINVERT

	Invoke GetMenu, _hWnd1
	Invoke EnableMenuItem, Eax, IDM_WINDOW1_MNUUNDOMAINIMG, MF_ENABLED

	Invoke SaveMasterDC, _hWnd1
	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke SetUndoDC, Eax

	Ret
InverseazaCulori EndP
