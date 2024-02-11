.Const
nPopIDReload		Equ 320
nPopIDSave			Equ 321
nPopIDOpenPaint		Equ 322
nPopIDOpenFromPaint	Equ 323

.Data?
;Handle DC
hDC			DD ?
hDstDC		DD ?
hDst4DC		DD ?
hBmp4DC		DD ?
hTempDC		DD ?

;PathDlg
szFileName	DB	MAX_PATH Dup (?)
szTitleName	DB	MAX_PATH Dup (?)

;Z o0 m
XZoom		DD ?
YZoom		DD ?

;Coordonate pixeli albastrii (cand se muta cnc-ul dar nu scrie)
Xcurent 	DD ?
Ycurent		DD ?

;String Buffer / Z o0 m buffer
szMainBuffer	DB 128 Dup(?)
szBuffer		DB 64 Dup(?)

;buffer port
acom			DB 8 Dup(?)

;Calcul cat tine simularea / rularea cnc
szCalculTimp	DB MAX_PATH Dup(?)

;numar de pixeli facuti
nPixeliScrisi	DD ?
;numar de pasi facuti
nPasiFacuti		DD ?
;numar de obiecte gasite
nObiecteGasite	DD ?

;DEBUG
szDebugText	DB 1024 Dup(?)
szLinie		DB 32 Dup(?)
szColoana	DB 32 Dup(?)

.Data
tmp DD 0
prbchar         DB "caracter invalid", 0
tempchar        DB "a", 0
cosduino        DD 0
hinst 			DD 0
hbmp			DD 0
hndpict 		DD 0
hdcpict			DD 0
linie 			DD 0
coloana 		DD 0
nr 				DD 0
texty 			DB "nu mai e nimic", 0
eu 				DD 0
col 			DD Blue
;acom 			DB "com1", 0
hcom 			DD 0
dreapta 		DB "B", 0
stanga 			DB "A", 0
sus2 			DB "C", 0
jos2 			DB "D", 0
bytesWritten	DD 0
buton7 			DD 0
buton6 			DD 0
tmpcos DB "  ", 0

;CSMBascom strings
szVirgula		DB ",", 0
szDta1			DB "Dta1:", 0
szData			DB 13, 10, "Data ", 0
szZero			DB "0", 0


;Pop-up menu
szPopMenuReload			DB "Reincarca", 0
szPopMenuOpenPaint		DB "Deschide in Paint", 0
szPopMenuFromOpenPaint	DB "Incarca din Paint", 0
szPopMenuSave			DB "Salveaza *.bmp", 0

;Flag interpretare
bInterpretare	BOOL FALSE

;STRUCTURI
dimensiuni 		RECT <>

patrat2 		RECT <>
punct2			POINT <>
popMenuInfo 	MENUITEMINFO <>
hnd DD 0
hnd2 DD 0

;==============================DEBUG==================================
;sTemp DB "E:\marius.bmp", 0
.Code

Window2Procedure Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_CREATE
		Mov Eax, hWnd
		Mov hnd, Eax
		Mov Eax, _hWnd2
		Mov hnd2, Eax

		;===================
		;INITIALIZARI MARIUS
		;===================
		;Transparenta
		Invoke bugFix0_w2, hWnd

		;Ascunde fereastra
		Invoke SetWindowPos, hWnd, NULL, -2000, -2000, 100, 100, TRUE

		;Opreste resul butoanelor
		Invoke EnableControls2, hWnd, 0

		;==================
		;INITIALIZARI COSTY
		;==================
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON6
		Mov buton6, Eax

		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON7
		Mov buton7, Eax

		Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
      	Mov hndpict, Eax

		Invoke GetModuleHandle, NULL
		Mov hinst, Eax

		;Invoke LoadBitmap, Eax, 100
        ;Mov hbmp, Eax

		;Invoke IncarcaImagine2, hWnd, Offset sTemp

		;Invoke SendDlgItemMessage, hWnd, hndpict, STM_SETIMAGE, IMAGE_BITMAP, hbmp
      	;Invoke SendMessage, hndpict, STM_SETIMAGE, IMAGE_BITMAP, hbmp

     	Invoke GetDC, hndpict
      	Mov hdcpict, Eax

		Invoke CreatePopupMenu
		Mov _hPopMenuW2, Eax

		Invoke AppendMenu, _hPopMenuW2, MF_POPUP, nPopIDReload, Addr szPopMenuReload
		Invoke AppendMenu, _hPopMenuW2, MF_SEPARATOR, 0, 0
		Invoke AppendMenu, _hPopMenuW2, MF_POPUP, nPopIDOpenPaint, Addr szPopMenuOpenPaint
		Invoke AppendMenu, _hPopMenuW2, MF_POPUP, nPopIDOpenFromPaint, Addr szPopMenuFromOpenPaint
		Invoke AppendMenu, _hPopMenuW2, MF_SEPARATOR, 0, 0
		Invoke AppendMenu, _hPopMenuW2, MF_POPUP, nPopIDSave, Addr szPopMenuSave

		

		Return TRUE

	.ElseIf uMsg == WM_COMMAND
;==============================================================================================================
;===MENIURI===
;==============================================================================================================
		.If wParam == IDM_WINDOW2_MNURELOADIMG
			;Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON8, 0
			;Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
			Invoke ReincarcaWin2
;			Invoke SendMessage, _hWnd2, WM_CLOSE, 0, 0
;			Invoke Send2CNC

		.ElseIf wParam == IDM_WINDOW2_MNUSEND2PAINT
			Invoke SendMessage, _hWnd1, WM_COMMAND, IDM_WINDOW1_MNUSEND2PAINT, 0

		.ElseIf wParam == IDM_WINDOW2_MNUCSMSIMULATOR
			Jmp @F
				szOpenCSMSimulator DB "Open", 0
				szGhilimele DB 022H, 0
@@:
			Invoke ShellExecute, hWnd, Addr szOpenCSMSimulator, Addr _szCSMSimPath, Addr _szDefaultSCM, 0, SW_SHOW
;			Invoke GetLastError
;			Invoke nDebug, 0, Eax

		.ElseIf wParam == IDM_WINDOW2_MNUOPENFILEDIR
			Jmp @F
				szExploreCurDir DB "Explore", 0
@@:
   			;Invoke MessageBox, 0, Addr _szCSMDirFisiere, 0, 0
			Invoke ShellExecute, _hWnd1, Addr szExploreCurDir, Addr _szCSMDirFisiere, 0, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW2_MNUOPENBASCOMFILE
			Jmp @F
				szOpenBascom DB "Open", 0
				szNotepad DB "notepad", 0
@@:
			Invoke ShellExecute, _hWnd2, Addr szOpenBascom, Addr szNotepad, Addr _szCSMBascomFile, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW2_MNUOPENBASCOMBYTESFILE
			Jmp @F
				szOpenBascomBytes DB "Open", 0
				szNotepadBytes DB "notepad", 0
@@:
   			;Invoke MessageBox, 0, Addr _szCSMBascomCompFile, 0, 0
			Invoke ShellExecute, _hWnd2, Addr szOpenBascomBytes, Addr szNotepadBytes, Addr _szCSMBascomCompFile, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW2_MNUOPENGCODEFILE
			Jmp @F
				szOpenGCode DB "Open", 0
				szNotepadGCode DB "notepad", 0
@@:
   			;Invoke MessageBox, 0, Addr _szCSMBascomCompFile, 0, 0
			Invoke ShellExecute, _hWnd2, Addr szOpenGCode, Addr szNotepadGCode, Addr _szCSMGCodeFile, 0, SW_SHOW

		.ElseIf wParam == IDM_WINDOW2_MNUINCARCASETARI
			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisierIni, Offset _sDefPrestabIni

			Invoke DeschideFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke IncarcaSetari, Addr _sNumeFisier
				.If !Eax
					Jmp @F
						szFisierIniCorupt DB "Fisierul ales este corupt sa nu este un fisier cu setari.", 0
@@:
					Invoke MessageBox, hWnd, Addr szFisierIniCorupt, 0, MB_OK + MB_ICONERROR

				.Else
					Invoke UpdateSetari

				.EndIf

			.EndIf
			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		.ElseIf wParam == IDM_WINDOW2_MNUSALVEAZASETARI
			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisierIni, Offset _sDefPrestabIni

			Invoke SalveazaFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke SalveazaSetari, Addr _sNumeFisier
			.EndIf
			Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab

		.ElseIf wParam == IDM_WINDOW2_MNUCLOSE
			Invoke SendMessage, hWnd, WM_CLOSE, 0, 0

		.ElseIf wParam == IDM_WINDOW2_MNUSTARTINTERPRETOR
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON8, 0

		.ElseIf wParam == IDM_WINDOW2_MNUCNCTEST
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON9, 0

		.ElseIf wParam == IDM_WINDOW2_MNUADDINDENT
			Invoke AddIndent

		.ElseIf wParam == IDM_WINDOW2_MNUSUBINDENT
			Invoke SubIndent

		.ElseIf wParam == IDM_WINDOW2_MNUUNDO
			Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
			Invoke DoUndo, Eax
			Invoke ToggleUndoMnu, _hWnd2

		.ElseIf wParam == IDM_WINDOW2_MNUSLEEP
			Invoke SleepWin, hWnd

		.ElseIf wParam == IDM_WINDOW2_MNUSLEEPCNCTEST
			Invoke SleepCncTestWin

		.ElseIf wParam == IDM_WINDOW2_MNUPASIPERPIXELX
			Invoke PasiPerPixelWinX, hWnd

		.ElseIf wParam == IDM_WINDOW2_MNUPASIPERPIXELY
			Invoke PasiPerPixelWinY, hWnd

		.ElseIf wParam == IDM_WINDOW2_MNUARATASETARI
			Invoke ArataSetari, hWnd

		.ElseIf wParam == IDM_WINDOW2_MNUCONNPORT
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON6, 0

		.ElseIf wParam == IDM_WINDOW2_MNUDECONNPORT
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON7, 0

		.ElseIf wParam == IDM_WINDOW2_MNUPORNESTECNC
			Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON1, 0

;==============================================================================================================
;===BUTOANE===
;==============================================================================================================
		.ElseIf wParam == IDC_WINDOW2_BUTTON1
			.If !_bSimulat
				Jmp @F
					szNoSimlationYet DB "Nu ai simulat imaginea! Sunt sanse sa nu fie 100% sigura.", 13, 10
									 DB "Doresti sa continui oricum?", 0
@@:
				Invoke MessageBox, hWnd, Addr szNoSimlationYet, Addr _szSigur, MB_YESNO + MB_ICONEXCLAMATION

				.If Eax == 6
					.If !_hWnd4
						Invoke CncTestWin
						Invoke ResetSetariInterpretor
						Invoke StartCNC, hWnd
					.Else
						Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
						Invoke CncTestWin
						Invoke ResetSetariInterpretor
						Invoke StartCNC, hWnd
					.EndIf
				.EndIf

			.Else
				.If !_hWnd4
					Invoke CncTestWin
					Invoke ResetSetariInterpretor
					Invoke StartCNC, hWnd
				.Else
					Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
					Invoke CncTestWin
					Invoke ResetSetariInterpretor
					Invoke StartCNC, hWnd
				.EndIf

			.EndIf


		.ElseIf wParam == IDC_WINDOW2_BUTTON6
			Invoke GetDlgItemText, hWnd, IDC_WINDOW2_EDIT5, Addr acom, 5
			Invoke CreateFile, Addr acom, GENERIC_READ Or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL
			.If Eax != INVALID_HANDLE_VALUE
				Mov hcom, Eax
				Mov Ebx, Offset acom
				Add Ebx, 3
				Invoke atol, Ebx
				Mov _nCom, Eax
				Invoke EnableControls2, hWnd, 1
			.Else
				Jmp @F
				sErrConnPort DB "Nu s-a putut conecta la port", 0
@@:
   				.If _hWnd4
					Invoke MessageBox, _hWnd4, Addr sErrConnPort, 0, 0
					Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
   				.Else
					Invoke MessageBox, hWnd, Addr sErrConnPort, 0, 0
   				.EndIf


			.EndIf

		.ElseIf wParam == IDC_WINDOW2_BUTTON7
			Invoke EnableControls2, hWnd, 0
			Invoke CloseHandle, hcom

		.ElseIf wParam == IDC_WINDOW2_BUTTON2

			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			Call readf


		.ElseIf wParam == IDC_WINDOW2_BUTTON3

			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			Call readf


		.ElseIf wParam == IDC_WINDOW2_BUTTON4

			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
		    Call readf

		.ElseIf wParam == IDC_WINDOW2_BUTTON5

			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			Call readf


		.ElseIf wParam == IDC_WINDOW2_BUTTON8
			Invoke ResetSetariInterpretor
			Invoke InterpreteazaImagine, hWnd

		.ElseIf wParam == IDC_WINDOW2_BUTTON9
			.If !_hWnd4
				Mov bInterpretare, FALSE
				Invoke CncTestWin
				Invoke ResetSetariInterpretor
				Invoke SimuleazaInimaCNC, hWnd
				Mov _bSimulat, TRUE
			.EndIf

		.ElseIf wParam == nPopIDSave
			Invoke SalveazaFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
			.If Eax
				Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
				Invoke GetWindowRect, Eax, Addr patrat2
				Fild patrat2.right
				Fild patrat2.left
				Fsub
				Fistp _nBmpWidth
				Sub _nBmpWidth, 4 ;bug fix: scoate barile laterale (right si bottom) care is in plus

				Fild patrat2.bottom
				Fild patrat2.top
				Fsub
				Fistp _nBmpHeight
				Sub _nBmpHeight, 4 ;bug fix: scoate barile laterale (right si bottom) care is in plus

				Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
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

				Mov Ecx, 0696E692EH		;.ini
				Mov [Eax], Ecx
				Invoke SalveazaSetari, Addr _sNumeFisier

				Pop Eax
				Mov Ecx, 0706D622EH		;.bmp
				Mov [Eax], Ecx

			.EndIf

		.ElseIf wParam == nPopIDOpenPaint
			Invoke SendMessage, _hWnd1, WM_COMMAND, IDM_WINDOW1_MNUSEND2PAINT, 0

		.ElseIf wParam == nPopIDOpenFromPaint
			Jmp @F
				szDbgBmp DB "C:\debug.bmp", 0
@@:
			Invoke IncarcaImagine, Offset szDbgBmp, _hWnd1
			Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
			Push Eax
			Invoke GetWindowRect, Eax, Addr patrat2
			Mov Eax, patrat2.right
			Mov Ebx, patrat2.left
			Sub Eax, Ebx
			Mov patrat2.right, Eax

			Mov Eax, patrat2.bottom
			Mov Ebx, patrat2.top
			Sub Eax, Ebx
			Mov patrat2.bottom, Eax

			Pop Eax
			Invoke GetDC, Eax
			Invoke BitBlt, Eax, 0, 0, patrat2.right, patrat2.bottom, _hMasterDC, 0, 0, SRCCOPY

		.ElseIf wParam == nPopIDReload
			Invoke SendMessage, hWnd, WM_COMMAND, IDM_WINDOW2_MNURELOADIMG, 0

		.EndIf


	.ElseIf uMsg == WM_VSCROLL

		Mov Eax, 0
		Mov Eax, wParam
		.If Ax == SB_THUMBPOSITION

	   		Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELX, TBM_GETPOS, TRUE, Eax
			Mov _nPasiPerPixelX, Al

			Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELY, TBM_GETPOS, TRUE, Eax
			Mov _nPasiPerPixelY, Al

			Invoke UpdateProgresMaxXYWin2

;			Mov Edx, 0
;			Mov Ecx, 010000H
;			Div Ecx

;			Mov _nPasiPerPixelX, Al

			;Invoke SetInputBoxInt, Eax, 0
			;Invoke SetDlgItemInt, _hWnd4, IDC_WINDOW4_EDIT1, Eax, 0
		.EndIf


	.ElseIf uMsg == WM_PAINT

	.ElseIf uMsg == WM_SIZE
;		Invoke GetWindowRect, hWnd, Addr patrat2
;		Mov Eax, patrat2.top
;		Sub patrat2.bottom, Eax
;		Mov Eax, patrat2.left
;		Sub patrat2.right, Eax
;		.If patrat2.bottom < 300
;			Invoke SetWindowPos, hWnd, 0, patrat2.left, patrat2.top, patrat2.right, 300, SWP_NOZORDER
;			Ret
;		.EndIf
;		.If patrat2.right < 300
;			Invoke SetWindowPos, hWnd, 0, patrat2.left, patrat2.top, 300, patrat2.bottom, SWP_NOZORDER
;			Ret
;		.EndIf

	.ElseIf uMsg == WM_CLOSE
;		Invoke IsModal, hWnd
;		.If Eax
;			Invoke EndModal, hWnd, IDCANCEL
;			Return TRUE
;		.EndIf
		Invoke ShowWindow, hWnd, FALSE
		Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0
		Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
		Invoke CloseInputBox
;		Invoke ShowWindow, _hWnd1, TRUE
		Invoke SetWindowPos, _hWnd1, _nToggleTopMost, _MainWinOldX, _MainWinOldY, 0, 0, SWP_NOSIZE
		Invoke SetForegroundWindow, _hWnd1
;		Invoke RestRgnFer, _hWnd1
;		Invoke GetWindowRect, _hWnd1, Addr _patrat
;		Mov Eax, _patrat.right
;		Mov Ebx, _patrat.left
;		Sub Eax, Ebx
;		Mov _patrat.right, Eax

;		Mov Eax, _patrat.bottom
;		Mov Ebx, _patrat.top
;		Sub Eax, Ebx
;		Mov _patrat.bottom, Eax

;		Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
;		Invoke GetDC, Eax
;		Invoke BitBlt, Eax, 0, 0, _patrat.right, _patrat.bottom, _hMasterDC, 0, 0, SRCCOPY


		Return TRUE
	.EndIf

	Return FALSE
Window2Procedure EndP


bucla:
Mov Eax, 10 ; 300000000
ssy:
Dec Eax
Jne ssy
	Ret


InimaCNC Proc hWnd:HWND
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Local nXvechi:DWord
Local nYvechi:DWord
Local i:Byte
Local nStartTime:DWord

Invoke GetTickCount
Mov nStartTime, Eax

Mov nPixeliScrisi, 0
Mov nPasiFacuti, 0
Mov nObiecteGasite, 0

Mov i, 0

Mov nXvechi, 0
Mov nYvechi, 0

Mov _Xcnc, 1
Mov _Ycnc, 1

sus:
	.Repeat
		.Repeat
			;Invoke SetDlgItemInt, hWnd, IDC_Window2_EDIT3, coloana, 0
			Invoke GetPixel, hdcpict, linie, coloana
			.If !Eax
				Invoke ProceseazaLinie, nXvechi, nYvechi, linie, coloana, 1
				Mov Eax, linie
				Mov nXvechi, Eax
				Mov Eax, coloana
				Mov nYvechi, Eax
				Inc nObiecteGasite
				Jmp jos
			.EndIf

			Inc linie ;linie
			;Invoke SetDlgItemInt, hWnd, IDC_Window2_EDIT2, linie, 0

		Mov Eax, _nCNCMaxLinii ;_nCNCMaxLinii
		.Until linie == Eax ;linie

	Mov linie, 0 ;linie
	Inc coloana ;coloana

	Mov Eax, _nCNCMaxColoane ;_nCNCMaxColoane
	.Until coloana == Eax ;coloana

	Invoke GolesteString, Addr szCalculTimp, MAX_PATH
	Invoke GolesteString, Addr szMainBuffer, 128

	Invoke GetTickCount
	Mov Ebx, nStartTime
	Sub Eax, Ebx

	Mov Edx, 0
	Mov Ebx, 1000
	Div Ebx
	Push Eax

	Jmp @F
		szObiecteFacute DB " obiecte", 13, 10, 0
		szPixeliFacuti DB " pixeli", 13, 10, 0
		szPasiFacuti DB " pasi", 13, 10
					 DB "in", 13, 10, 0
		szDPFacuti DB ":", 0
		szCapatFacuti DB 13, 10, 13, 10, "Resetati tot?", 0
@@:


	Invoke dw2a, nObiecteGasite, Addr szCalculTimp
	Invoke szCatStr, Addr szCalculTimp, Addr szObiecteFacute
	Invoke dw2a, nPixeliScrisi, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szPixeliFacuti
	Invoke dw2a, nPasiFacuti, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szPasiFacuti

	Invoke GolesteString, Addr szMainBuffer, 128
	Pop Eax
	Mov Edx, 0
	Mov Ebx, 60
	Div Ebx
	Push Edx
	Invoke dw2a, Eax, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szDPFacuti
	Pop Eax
	Invoke dw2a, Eax, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szCapatFacuti

	Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0
	Invoke MessageBox, _hWnd4, Addr szCalculTimp, Addr texty, MB_OKCANCEL + MB_ICONQUESTION
	.If Eax == 1
		Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNURELOADIMG, 0
	.EndIf

	Jmp jos3

jos:

;	Invoke nDebug, 0, nr

	Dec linie ;linie-1
	Dec coloana ;coloana-1
	Mov nr, 0
	Invoke GetPixel, hdcpict, linie, coloana ;19,4 linie-1  coloana-1
	.If !Eax
		Add nr, 1
	.EndIf
	Inc linie

	Invoke GetPixel, hdcpict, linie, coloana ; 20, 4 linie  coloana-1
	.If !Eax
		Add nr, 10
	.EndIf
	Inc linie

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 4 linie+1 coloana-1
	.If !Eax
		Add nr, 100
	.EndIf
	Inc coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 5  linie+1 coloana
	.If !Eax
		Add nr, 1000
	.EndIf
	Inc coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 6 linie+1 coloana+1
	.If !Eax
		Add nr, 10000
	.EndIf
	Dec linie

	Invoke GetPixel, hdcpict, linie, coloana ; 20, 6   linie  coloana+1
	.If !Eax
		Add nr, 100000
	.EndIf
	Dec linie

	Invoke GetPixel, hdcpict, linie, coloana ; 19, 6  linie-1  coloana+1
	.If !Eax
		Add nr, 1000000
	.EndIf
	Dec coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 19, 5  linie-1   coloana
	.If !Eax
		Add nr, 10000000
	.EndIf
	Inc linie

	Call bucla

	.If nr == 101000
		;000
		;0x1
		;010
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf		
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0

		Jmp jos

	.ElseIf nr == 1
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf
		Dec coloana

		.Repeat
			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Dec linie
		Call bucla

		.Repeat
			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 100
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf	
		Dec coloana

		.Repeat
			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0

		Call bucla
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0


		Jmp jos

	.ElseIf nr == 1010000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Call bucla
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos


	;***********************************************************************
;	.ElseIf nr == 111000
;		Invoke SetPixel, hdcpict, linie, coloana, White
;		Inc coloana
;		Invoke SetPixel, hdcpict, linie, coloana, White
;		Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			;call readf
;        Inc linie
;		Invoke SetPixel, hdcpict, linie, coloana, White
;		Dec coloana
;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		Call bucla
;		Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			;call readf

;		Jmp jos

;	.ElseIf nr == 1010000
;		Invoke SetPixel, hdcpict, linie, coloana, White
;		Inc coloana
;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			;call readf
;        Inc linie
;		Jmp jos

;	.ElseIf nr == 10110000
;		;000
;		;0x1
;		;100
;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		Dec linie
;			Invoke SetPixel, hdcpict, linie, coloana, White
;		Inc linie
;		Inc coloana
;			Invoke SetPixel, hdcpict, linie, coloana, White
;		Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0

			;call readf
;		Call bucla
;		Inc linie
;		Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			;call readf
;		Jmp jos

	.ElseIf nr == 1001000
		;000
		;0x1
		;100
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 1000
		;000
		;0x1
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 10000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Call bucla
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0

		Jmp jos

	.ElseIf nr == 11000
		;000
		;0x1
		;001
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 1000000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Call bucla
		Dec linie

		.Repeat
			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 100000
		;000
		;0x0
		;010
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 110000
		;000
		;0x0
		;011
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 1100
		;001
		;0x1
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf	
		Inc linie

		.Repeat
			Invoke WriteFile, hcom, Offset dreapta, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 10
		;010
		;0x0
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec coloana

		.Repeat
			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 11
		;110
		;0x0
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec coloana

		.Repeat
			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 10000000
		;000
		;1x0
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec linie

		.Repeat
			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 10000001
		;100
		;1x0
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec linie

		.Repeat
			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0

		Jmp jos

	.ElseIf nr == 110
		;011
		;0x0
		;000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec coloana

		.Repeat
			Invoke WriteFile, hcom, Offset jos2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0
		 
		Jmp jos

	.ElseIf nr == 1100000
		;000
		;0x0
		;110
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Inc coloana

		.Repeat
			Invoke WriteFile, hcom, Offset sus2, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.Until i == Al
		Mov i, 0

		Jmp jos

	.ElseIf nr == 11000000
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Dec linie

		.Repeat
			Invoke WriteFile, hcom, Offset stanga, 1, Addr bytesWritten, 0
			call readf
			Invoke Sleep, _nSleep
			Inc nPasiFacuti
			Inc i
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Until i == Al
		Mov i, 0		

		Jmp jos

	.ElseIf nr == 0
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nSleep
			Inc nPixeliScrisi
		.EndIf			
		Mov linie, 0
		Mov coloana, 0

		Jmp sus
	.EndIf

jos1:
	Invoke SetDlgItemInt, hWnd, IDC_WINDOW2_EDIT1, nr, 0

	Jmp @F
		szHeadLinie DB "X: ", 0
		szHeadColoana DB " , Y: ", 0
@@:

	Invoke GolesteString, Addr szDebugText, 1024

	Invoke dw2a, linie, Addr szLinie
	Invoke dw2a, coloana, Addr szColoana

	Invoke szCatStr, Addr szDebugText, Addr szHeadLinie
	Invoke szCatStr, Addr szDebugText, Addr szLinie
	Invoke szCatStr, Addr szDebugText, Addr szHeadColoana
	Invoke szCatStr, Addr szDebugText, Addr szColoana

	Invoke SetWindowText, _hWnd3, Addr szDebugText
	Invoke ManualPixWin

	Mov Eax, linie
	Mov Ebx, coloana
	Invoke ManualPixWinDC, Eax, Ebx, 1

	.If _nPixelColor != White
		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_PICCULOARE
		Invoke GetDC, Eax
		Invoke BitBlt, Eax, 0, 0, 30, 20, Eax, 0, 0, SRCINVERT
	.EndIf

	Mov Eax, 300000000

jos3:
	Ret
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
InimaCNC EndP


SimuleazaInimaCNC Proc hWnd:HWND
Local nXvechi:DWord
Local nYvechi:DWord
Local nStartTime:DWord
Local i:DWord

Invoke GolesteString, _pCSMBuffer, 1024000
Invoke GolesteString, _pCSMCompBuffer, 1024000
Invoke GolesteString, _pCSMBascom, 1024000
Invoke GolesteString, _pGCode, 1024000
Invoke GolesteString, Addr _szGCodeZBugFix3, 64

Mov linie, 0
Mov coloana, 0

Mov i, 0

Mov Eax, _pCSMBuffer
Mov _iCSM, Eax
Mov _iCSMFile, 0
Mov _iGCode, 0

Mov _nGCodeStart, 0

Mov _nLastXGCode, 0
Mov _nLastYGCode, 0
Mov _nLastZGCode, 0

Invoke GetTickCount
Mov nStartTime, Eax

Mov nObiecteGasite, 0

Mov nPixeliScrisi, 0

Mov nXvechi, 0
Mov nYvechi, 0

Mov _Xcnc, 0
Mov _Ycnc, 0


sus:
	.Repeat
		.Repeat
			;Invoke SetDlgItemInt, hWnd, IDC_Window2_EDIT3, coloana, 0
			Invoke GetPixel, hdcpict, linie, coloana
			.If !Eax
				;.If !bInterpretare
					Invoke ProceseazaLinie, nXvechi, nYvechi, linie, coloana, 0
				;.EndIf

				Mov Eax, linie
				Mov nXvechi, Eax
				Mov Eax, coloana
				Mov nYvechi, Eax
				Inc nObiecteGasite
				Jmp jos
			.EndIf

			Inc linie
			;Invoke SetDlgItemInt, hWnd, IDC_Window2_EDIT2, linie, 0

		Mov Eax, _nCNCMaxLinii
		.Until linie == Eax

	Mov linie, 0
	Inc coloana

	Mov Eax, _nCNCMaxColoane
	.Until coloana == Eax


	.If nObiecteGasite == 1 		;DOAR 1 singur obiect, alfel va fi nasol
		;Invoke mata
		Invoke CreateFile, Addr _szCSMBascomFile, GENERIC_WRITE Or GENERIC_READ, 0, NULL, CREATE_ALWAYS, 0, NULL
		Push Eax
		Invoke GetLastError
		Pop Ebx
		Push Ebx
		.If Eax == 0
			Jmp noERRBascom
		.ElseIf Eax == ERROR_ALREADY_EXISTS
noERRBascom:
			;[COD GRESIT - IN PLUS]
;			Mov Eax, _pCSMBuffer
;			Mov _iCSM, Eax
;			Mov Eax, _pCSMCompBuffer
;			Mov _iCSMComp, Eax


			Invoke szCatStr, _pCSMBascom, Addr szDta1
	;==========================================================
			Invoke StrLen, _pCSMBuffer
			Mov Ebx, _pCSMBuffer
			Add Ebx, Eax
			Mov Ecx, _pCSMBuffer
			Mov _iCSM, Ebx			;MAX LITERE
			Mov _iCSMComp, 1
			Mov i, 0
	startCompresie:
			Cmp _iCSM, Ecx
			Je sfarsit

			Mov Eax, Ecx			;Citeste litera
			Mov Eax, [Eax]
			Mov Ebx, 0
			Mov Bl, Al				;BL = Litera

			Inc Ecx					;i++

			Mov Eax, Ecx			;Citeste litera IAR
			Mov Eax, [Eax]
			Mov Edx, 0
			Mov Dl, Al				;DL = Litera

			Cmp Dl, Bl				;L1 == L2 ?
			Je adaugaRepetare
			Cmp Dl, Bl				;L1 != L2 ?
			Jne faraRepetare

			Jmp startCompresie

	adaugaRepetare:
			Inc _iCSMComp			;nr. repetare

			Mov Edx, 62
			Cmp _iCSMComp, Edx			;i < iMax
			Je faraRepetare

			Jmp startCompresie

	faraRepetare:
			;ALGORITMU`
			Push Ecx					;contoru`
			Push Ebx					;litera

			Mov Eax, 041H				;A
			Cmp Bl, Al
			Je literaA
			Mov Eax, 042H				;B
			Cmp Bl, Al
			Je literaB
			Mov Eax, 043H				;C
			Cmp Bl, Al
			Je literaC
			Mov Eax, 044H				;D
			Cmp Bl, Al
			Je literaD

	sfarsitFaraRepetare:
			Inc i
			Pop Ebx
			Pop Ecx
			Mov _iCSMComp, 1
			Jmp startCompresie

	literaA:
			Cmp _iCSMComp, 1
			Jg multA						;Se repeta mai multe?
			Mov _iCSMComp, 1
	multA:
			Mov Eax, 040H					;100 0000 bin
			Mov Edx, 0						;cod litera A
			IMul Edx
			Mov Ebx, _iCSMComp
			Or Eax, Ebx						;!!REZULTATUL DE MULT ASTEPTAT!!
											;12345678 - 8 biti - 1 Byte
											;00 		 - A B C D  {A00 B01 C10 D11}
											;000000 - Numarul de repetat [0-64]
			Push Eax
			Mov Eax, i
			Mov Edx, 0
			Mov Ecx, 20
			Div Ecx
			Cmp Edx, 0
			Jne faraSzDataA
			Invoke szCatStr, _pCSMBascom, Addr szData
	faraSzDataA:
			Pop Eax
			Invoke dwtoa, Eax, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szVirgula

			Jmp sfarsitFaraRepetare


	literaB:
			Cmp _iCSMComp, 1
			Jg multB						;Se repeta mai multe?
			Mov _iCSMComp, 1
	multB:
			Mov Eax, 040H					;100 0000 bin
			Mov Edx, 1						;cod Litera B
			IMul Edx
			Mov Ebx, _iCSMComp
			Or Eax, Ebx						;!!REZULTATUL DE MULT ASTEPTAT!!
											;12345678 - 8 biti - 1 Byte
											;00 		 - A B C D  {A00 B01 C10 D11}
											;  000000 - Numarul de repetat [0-64]
			Push Eax
			Mov Eax, i
			Mov Edx, 0
			Mov Ecx, 20
			Div Ecx
			Cmp Edx, 0
			Jne faraSzDataB
			Invoke szCatStr, _pCSMBascom, Addr szData
	faraSzDataB:
			Pop Eax
			Invoke dwtoa, Eax, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szVirgula

			Jmp sfarsitFaraRepetare


	literaC:
			Cmp _iCSMComp, 1
			Jg multC						;Se repeta mai multe?
			Mov _iCSMComp, 1
	multC:
			Mov Eax, 040H					;100 0000 bin
			Mov Edx, 2						;cod Litera C
			IMul Edx
			Mov Ebx, _iCSMComp
			Or Eax, Ebx						;!!REZULTATUL DE MULT ASTEPTAT!!
											;12345678 - 8 biti - 1 Byte
											;00 		 - A B C D  {A00 B01 C10 D11}
											;  000000 - Numarul de repetat [0-64]
			Push Eax
			Mov Eax, i
			Mov Edx, 0
			Mov Ecx, 20
			Div Ecx
			Cmp Edx, 0
			Jne faraSzDataC
			Invoke szCatStr, _pCSMBascom, Addr szData
	faraSzDataC:
			Pop Eax
			Invoke dwtoa, Eax, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szVirgula

			Jmp sfarsitFaraRepetare


	literaD:
			Cmp _iCSMComp, 1
			Jg multD						;Se repeta mai multe?
			Mov _iCSMComp, 1
	multD:
			Mov Eax, 040H					;100 0000 bin
			Mov Edx, 3						;cod Litera D
			IMul Edx
			Mov Ebx, _iCSMComp
			Or Eax, Ebx						;!!REZULTATUL DE MULT ASTEPTAT!!
											;12345678 - 8 biti - 1 Byte
											;00 		 - A B C D  {A00 B01 C10 D11}
											;  000000 - Numarul de repetat [0-64]
			Push Eax
			Mov Eax, i
			Mov Edx, 0
			Mov Ecx, 20
			Div Ecx
			Cmp Edx, 0
			Jne faraSzDataD
			Invoke szCatStr, _pCSMBascom, Addr szData
	faraSzDataD:
			Pop Eax
			Invoke dwtoa, Eax, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szBuffer
			Invoke szCatStr, _pCSMBascom, Addr szVirgula

			Jmp sfarsitFaraRepetare


	sfarsit:
			Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
			Invoke GetWindowRect, Eax, Addr patrat2
			Mov Eax, patrat2.right
			Mov Ebx, patrat2.left
			Sub Eax, Ebx
			Mov patrat2.right, Eax

			Mov Eax, patrat2.bottom
			Mov Ebx, patrat2.top
			Sub Eax, Ebx
			Mov patrat2.bottom, Eax

			;Invoke pDebug, 0

			Mov Eax, _pCSMCompBuffer
			Add Eax, _iCSMFile

			Mov Ebx, patrat2.right					;SALVEAZA Width
			Mov [Eax], Bx
			Mov Ebx, patrat2.bottom					;SALVEAZA Height
			Mov [Eax + 2], Bx
			Mov Ebx, 4
			Add _iCSMFile, Ebx

			;Invoke nDebug, 0, i

			Invoke StrLen, _pCSMBascom
			Mov Ebx, _pCSMBascom
			Add Ebx, Eax
			Mov Ecx, Offset szZero
			Mov Ecx, [Ecx]
			Mov [Ebx], Ecx
			Inc Ebx
			Mov Ecx, 0
			Mov [Ebx], Ecx

	;==========================================================
	;		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	;		Invoke GetWindowRect, Eax, Addr patrat2
	;		Mov Eax, patrat2.right
	;		Mov Ebx, patrat2.left
	;		Sub Eax, Ebx
	;		Mov patrat2.right, Eax

	;		Mov Eax, patrat2.bottom
	;		Mov Ebx, patrat2.top
	;		Sub Eax, Ebx
	;		Mov patrat2.bottom, Eax


	;		;** SCRIE Pasi Per Pixel **
	;		Mov Eax, 0
	;		Mov Al, i
	;		Mov Ebx, 0 						;i = ultima pozitie a lui _szCSMCompBuffer
	;		Mov Bl, Al
	;		Mov Eax, 03EH					;Pasi per pixel flag
	;		Mov [Ebx], Eax					;Scrie flag-ul
	;		Mov Eax, 0
	;		Mov Al, _nPasiPerPixelX
	;		Mov Edx, 0
	;		Mov Ecx, 010H
	;		IMul Ecx						;Al = HighByte Pasi per pixel X
	;		Mov Ecx, 0
	;		Mov Cl, _nPasiPerPixelY			;CL = LowByte Pasi per pixel Y
	;		Or Eax, Ecx
	;		Mov [Ebx], Eax					;SALVEAZA Pasi Per Pixel

	;		Inc Ebx

	;		Mov Edx, 0
	;		Mov Eax, patrat2.right
	;		Mov Ecx, 010000H				;W
	;		IMul Ecx
	;		Mov [Ebx], Eax					;SALVEAZA Width
	;		Add Ebx, 2
	;		Mov Eax, patrat2.bottom
	;		Mov Ecx, 010000H
	;		IMul Ecx
	;		Mov [Ebx], Eax					;SALVEAZA Height
	;										;Nu mai pun terminator de string
	;										;pentru ca deja low wordul contine 0-uri

			;FISIER BASCOM
			Invoke StrLen, _pCSMBascom
			Pop Ebx
			Push Ebx
			Invoke WriteFile, Ebx, _pCSMBascom, Eax, Addr bytesWritten, 0
			Pop Ebx
			Invoke CloseHandle, Ebx

			;FISIER BASCOM COMPRIMAT (raw data)
			Invoke CreateFile, Addr _szCSMBascomRaw, GENERIC_WRITE Or GENERIC_READ, 0, NULL, CREATE_ALWAYS, 0, NULL
			.If Eax == INVALID_HANDLE_VALUE
				Jmp @F
					szErrCompBascomRaw DB "Nu s-a putut deschide bascomRawData.rdb", 0
	@@:
				Invoke MessageBox, 0, Addr szErrCompBascomRaw, 0, 0
			.Else
				Push Eax
		;		Invoke StrLen, Addr _szCSMCompBuffer
	;			Pop Ebx
	;			Push Ebx
				Invoke WriteFile, Eax, _pCSMBuffer, i, Addr bytesWritten, 0
				Pop Eax
				Invoke CloseHandle, Eax
			.EndIf

			;FISIER CSM
			Invoke CreateFile, Addr _szCSMBascomCompFile, GENERIC_WRITE Or GENERIC_READ, 0, NULL, CREATE_ALWAYS, 0, NULL
	;		Invoke GetLastError
	;		Invoke nDebug, 0, Eax
	;		Ret
			.If Eax == INVALID_HANDLE_VALUE
				Jmp @F
					szErrCompBascom DB "Nu s-a putut deschide bascomBytes.csm", 0
	@@:
				Invoke MessageBox, 0, Addr szErrCompBascom, 0, 0
			.Else
				Push Eax
;		;		Invoke StrLen, Addr _szCSMCompBuffer
;				Pop Ebx
;				Push Ebx
				Invoke WriteFile, Eax, _pCSMCompBuffer, _iCSMFile, Addr bytesWritten, 0
				Pop Eax
				Invoke CloseHandle, Eax

				;SALVEAZA CFG
				Invoke StrLen, Addr _szCSMBascomCompFile
				Mov Ebx, Eax
				Mov Eax, Offset _szCSMBascomCompFile
				Add Eax, Ebx
				Sub Eax, 4
				Mov Ecx, 0
				Mov [Eax], Ecx
				Push Eax

				Mov Ecx, 06963632EH		;.cci
				Mov [Eax], Ecx
				;Invoke MessageBox, 0, Addr _szCSMBascomCompFile, 0, 0
				Invoke SalveazaSetari, Offset _szCSMBascomCompFile

				Pop Eax
				Mov Ecx, 06D7E632EH		;.bmp
				Mov [Eax], Ecx
			.EndIf



	;FISIER BASCOM
			Invoke StrLen, _pCSMBascom
			Pop Ebx
			Push Ebx
			Invoke WriteFile, Ebx, _pCSMBascom, Eax, Addr bytesWritten, 0
			Pop Ebx
			Invoke CloseHandle, Ebx

			;FISIER BASCOM COMPRIMAT (raw data)
			Invoke CreateFile, Addr _szCSMBascomRaw, GENERIC_WRITE Or GENERIC_READ, 0, NULL, CREATE_ALWAYS, 0, NULL
			.If Eax == INVALID_HANDLE_VALUE
				Jmp @F
					szErrBascomRaw DB "Nu s-a putut deschide bascomRawData.rdb", 0
	@@:
				Invoke MessageBox, 0, Addr szErrBascomRaw, 0, 0
			.Else
				Push Eax
		;		Invoke StrLen, Addr _szCSMCompBuffer
	;			Pop Ebx
	;			Push Ebx
				Invoke WriteFile, Eax, _pCSMBuffer, i, Addr bytesWritten, 0
				Pop Eax
				Invoke CloseHandle, Eax
				;Invoke SetDlgItemInt, _hWnd2, IDC_WINDOW2_EDIT2, bytesWritten, 0
			.EndIf

			;FISIER GCode
			Invoke CreateFile, Addr _szCSMGCodeFile, GENERIC_WRITE Or GENERIC_READ, 0, NULL, CREATE_ALWAYS, 0, NULL
			.If Eax == INVALID_HANDLE_VALUE
				Jmp @F
					szErrGCode DB "Nu s-a putut deschide Gcode.nc", 0
	@@:
				Invoke MessageBox, 0, Addr szErrGCode, 0, 0
			.Else
				Push Eax
				;Invoke MessageBox, 0, _pGCode, 0, 0

				Mov Ebx, _pGCode
				Add Ebx, _iGCode
				Push Ebx

				Mov Ecx, Offset _szGCodeZBugFix3
				Add Ecx, 6
				Invoke szCatStr, Ebx, Ecx
				Invoke StrLen, _pGCode
				Mov _iGCode, Eax

				Pop Ebx
				Invoke szCatStr, Ebx, Addr _szGCodeZBugFix2
				Add _iGCode, 8

				Pop Eax
				Push Eax
				Invoke WriteFile, Eax, _pGCode, _iGCode, Addr bytesWritten, 0
				Pop Eax
				Invoke CloseHandle, Eax
			.EndIf

			Invoke GetMenu, _hWnd2
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMFILE, MF_ENABLED
			Pop Eax
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMBYTESFILE, MF_ENABLED
			Pop Eax
			Push Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUCSMSIMULATOR, MF_ENABLED
			Pop Eax
			Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENGCODEFILE, MF_ENABLED

		.Else
			Jmp @F
				szNasol DB "nasol :(", 0
	@@:
			Invoke MessageBox, _hWnd1, Addr szNasol, 0, 0

		.EndIf

	.Else
		Invoke GetMenu, _hWnd2
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMFILE, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENBASCOMBYTESFILE, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUCSMSIMULATOR, MF_GRAYED
		Pop Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUOPENGCODEFILE, MF_GRAYED

		Jmp @F
			szMulteObiecte DB "Fisierul *.csm nu se poate salva pentru ca exista mai multe obiecte", 0
@@:
   			.If _hWnd4
				Mov Eax, _hWnd4
   			.ElseIf _hWnd3
				Mov Eax, _hWnd3
   			.Else
				Mov Eax, _hWnd2
   			.EndIf
			Invoke MessageBox, Eax, Addr szMulteObiecte, 0, MB_ICONINFORMATION
			Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNURELOADIMG, 0

			Jmp jos3
	.EndIf
;	Pop Ebx
;	Invoke CloseHandle, Ebx

	Invoke GolesteString, Addr szCalculTimp, MAX_PATH
	Invoke GolesteString, Addr szMainBuffer, 128

	Invoke GetTickCount
	Mov Ebx, nStartTime
	Sub Eax, Ebx

	Mov Edx, 0
	Mov Ebx, 1000
	Div Ebx
	Push Eax

	Jmp @F
		szObiecteSimulare DB " obiecte", 13, 10, 0
		szPixeliSimulare DB " pixeli", 13, 10
					     DB "in", 13, 10, 0
		szDPSimulare DB ":", 0
		szCapatSimulare DB 13, 10, 13, 10, "Resetati tot?", 0
@@:

	Invoke dw2a, nObiecteGasite, Addr szCalculTimp
	Invoke szCatStr, Addr szCalculTimp, Addr szObiecteSimulare
	Invoke dw2a, nPixeliScrisi, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szPixeliSimulare
	Pop Eax ;nr secunde
	Mov Edx, 0
	Mov Ebx, 60
	Div Ebx
	;eax minute, edx secunde
	Push Edx
	Invoke dw2a, Eax, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szDPSimulare
	Pop Eax
	Invoke dw2a, Eax, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szMainBuffer
	Invoke szCatStr, Addr szCalculTimp, Addr szCapatSimulare

	Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0
	Invoke MessageBox, _hWnd4, Addr szCalculTimp, Addr texty, MB_OKCANCEL + MB_ICONQUESTION
	.If Eax == 1
		Invoke SendMessage, _hWnd2, WM_COMMAND, IDM_WINDOW2_MNURELOADIMG, 0
	.EndIf

	Jmp jos3

jos:

	;Invoke nDebug, 0, nr

	Dec linie ;linie-1
	Dec coloana ;coloana-1
	Mov nr, 0
	Invoke GetPixel, hdcpict, linie, coloana ;19,4 linie-1  coloana-1
	.If !Eax
		Add nr, 1
	.EndIf
	Inc linie

	Invoke GetPixel, hdcpict, linie, coloana ; 20, 4 linie  coloana-1
	.If !Eax
		Add nr, 10
	.EndIf
	Inc linie

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 4 linie+1 coloana-1
	.If !Eax
		Add nr, 100
	.EndIf
	Inc coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 5  linie+1 coloana
	.If !Eax
		Add nr, 1000
	.EndIf
	Inc coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 21, 6 linie+1 coloana+1
	.If !Eax
		Add nr, 10000
	.EndIf
	Dec linie

	Invoke GetPixel, hdcpict, linie, coloana ; 20, 6   linie  coloana+1
	.If !Eax
		Add nr, 100000
	.EndIf
	Dec linie

	Invoke GetPixel, hdcpict, linie, coloana ; 19, 6  linie-1  coloana+1
	.If !Eax
		Add nr, 1000000
	.EndIf
	Dec coloana

	Invoke GetPixel, hdcpict, linie, coloana ; 19, 5  linie-1   coloana
	.If !Eax
		Add nr, 10000000
	.EndIf
	Inc linie

	Call bucla

	.If nr == 101000
		;000
		;0x1
		;010
		Mov Eax, Offset dreapta
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx
		Call doPixelSimulare
		Inc linie

		Mov Al, "B"
		Mov Ah, 0

		Call doScrieFisiere
		;Inc nPixeliScrisi
		Jmp jos

	.ElseIf nr == 1
		Mov Eax, Offset stanga
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx
		Call doPixelSimulare

		Dec coloana
		Dec linie
		Call bucla

;		;Probabil
		Mov Ecx, _iCSM
		Mov Ebx, Offset jos2
		Mov Edx, [Ebx]
		Mov [Ecx], Edx
		Inc _iCSM

		Mov Al, "D"
		Mov Ah, "A"

		Call doScrieFisiere

		Jmp jos

	.ElseIf nr == 100
		Mov Eax, Offset jos2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx
		Call doPixelSimulare

		Dec coloana
		Call bucla
		Inc linie

		Mov Ecx, _iCSM
		Mov Ebx, Offset dreapta
		Mov Edx, [Ebx]
		Mov [Ecx], Edx
		Inc _iCSM

		Mov Al, "D"
		Mov Ah, "B"

		Call doScrieFisiere

		Jmp jos

	.ElseIf nr == 1010000
		Mov Eax, Offset _szSens
		Mov Ebx, [Eax]
		Mov Ecx, Offset dreapta
		Mov [Ecx], Ebx
		Call doPixelSimulare

		Inc coloana
		Call bucla
		Inc linie

		;PROBABIL
		Mov Ecx, _iCSM
		Mov Ebx, Offset dreapta
		Mov Edx, [Ebx]
		Mov [Ecx], Edx
		Inc _iCSM

		Mov Al, "C"
		Mov Ah, "B"

		Call doScrieFisiere

		Jmp jos

	;***********************************************************************
	.ElseIf nr == 1001000
		;000
		;0x1
		;100
		Mov Eax, Offset dreapta
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc linie

		Mov Al, "B"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc linie
;		Jmp jos

	.ElseIf nr == 1000
		;000
		;0x1
		;000
		Mov Eax, Offset dreapta
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc linie

		Mov Al, "B"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc linie
;		Jmp jos

	.ElseIf nr == 10000
		Mov Eax, Offset sus2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx
		Call doPixelSimulare

		Inc coloana
		Call bucla
		Inc linie

		;PROBABIL
		Mov Ecx, _iCSM
		Mov Ebx, Offset dreapta
		Mov Edx, [Ebx]
		Mov [Ecx], Edx
		Inc _iCSM

		Mov Al, "C"
		Mov Ah, "B"

		Call doScrieFisiere

		Jmp jos

	.ElseIf nr == 11000
		;000
		;0x1
		;001
		Mov Eax, Offset dreapta
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc linie

		Mov Al, 0
		Mov Ah, "B"

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc linie
;		Jmp jos

	.ElseIf nr == 1000000
		Mov Eax, Offset sus2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx
		Call doPixelSimulare

		Inc coloana
		Call bucla
		Dec linie

		;PROBABIL
		Mov Ecx, _iCSM
		Mov Ebx, Offset stanga
		Mov Edx, [Ebx]
		Mov [Ecx], Edx
		Inc _iCSM

		Mov Al, "C"
		Mov Ah, "A"

		Call doScrieFisiere

		Jmp jos

	.ElseIf nr == 100000
		;000
		;0x0
		;010
		Mov Eax, Offset sus2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc coloana

		Mov Al, "C"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc coloana
;		Jmp jos

	.ElseIf nr == 110000
		;000
		;0x0
		;011
		Mov Eax, Offset sus2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc coloana

		Mov Al, "C"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc coloana
;		Jmp jos

	.ElseIf nr == 1100
		;001
		;0x1
		;000
		Mov Eax, Offset dreapta
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc linie

		Mov Al, 0
		Mov Ah, "B"

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc linie
;		Jmp jos

	.ElseIf nr == 10
		;010
		;0x0
		;000
		Mov Eax, Offset jos2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec coloana

		Mov Al, "D"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec coloana
;		Jmp jos

	.ElseIf nr == 11
		;110
		;0x0
		;000

		Mov Eax, Offset jos2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec coloana

		Mov Al, "D"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec coloana
;		Jmp jos


	.ElseIf nr == 10000000
		;000
		;1x0
;		;000
		Mov Eax, Offset stanga
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec linie

		Mov Al, "A"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec linie
;		Jmp jos


	.ElseIf nr == 10000001
		;100
		;1x0
		;000
		Mov Eax, Offset stanga
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec linie

		Mov Al, "A"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos
;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec linie
;		Jmp jos

	.ElseIf nr == 110
		;011
		;0x0
		;000
		Mov Eax, Offset jos2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec coloana

		Mov Al, "D"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec coloana
;		Jmp jos


	.ElseIf nr == 1100000
		;000
		;0x0
		;110
		Mov Eax, Offset sus2
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Inc coloana

		Mov Al, "C"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos
;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Inc coloana
;		Jmp jos

	.ElseIf nr == 11000000
		Mov Eax, Offset stanga
		Mov Ebx, [Eax]
		Mov Ecx, Offset _szSens
		Mov [Ecx], Ebx

		Call doPixelSimulare
		Dec linie

		Mov Al, "A"
		Mov Ah, 0

		Call doScrieFisiere
		Jmp jos

;		Invoke SetPixel, hdcpict, linie, coloana, 255
;		.If _hCncDC
;			Invoke SetPixel, _hCncDC, linie, coloana, Red
;			Mov Eax, linie
;			Mov _Xcnc, Eax
;			Mov Eax, coloana
;			Mov _Ycnc, Eax
;			Invoke Sleep, _nCncTestSleep
;		.EndIf
;		Inc nPixeliScrisi
;		Dec linie
;		Jmp jos



	.ElseIf nr == 0
		Invoke SetPixel, hdcpict, linie, coloana, 255
		.If _hCncDC
			Invoke SetPixel, _hCncDC, linie, coloana, Red
			Mov Eax, linie
			Mov _Xcnc, Eax
			Mov Eax, coloana
			Mov _Ycnc, Eax
			Invoke Sleep, _nCncTestSleep
		.EndIf
		Inc nPixeliScrisi
		Mov linie, 0
		Mov coloana, 0
		Jmp sus
	.EndIf

jos1:

	.If _hWnd4
		Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
	.EndIf

	Invoke SetDlgItemInt, hWnd, IDC_WINDOW2_EDIT1, nr, 0

	Jmp @F
		szHeadLinie1 DB "X: ", 0
		szHeadColoana1 DB " , Y: ", 0
@@:

	Invoke GolesteString, Addr szDebugText, 1024

	Invoke dw2a, linie, Addr szLinie
	Invoke dw2a, coloana, Addr szColoana

	Invoke szCatStr, Addr szDebugText, Addr szHeadLinie1
	Invoke szCatStr, Addr szDebugText, Addr szLinie
	Invoke szCatStr, Addr szDebugText, Addr szHeadColoana1
	Invoke szCatStr, Addr szDebugText, Addr szColoana

	Invoke SetWindowText, _hWnd3, Addr szDebugText
	Invoke ManualPixWin

	Mov Eax, linie
	Mov Ebx, coloana
	Invoke ManualPixWinDC, Eax, Ebx, 1

	.If _nPixelColor != White
		Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_PICCULOARE
		Invoke GetDC, Eax
		Invoke BitBlt, Eax, 0, 0, 30, 20, Eax, 0, 0, SRCINVERT
	.EndIf

	Mov Eax, 300000000

jos3:

	Ret
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SimuleazaInimaCNC EndP


InterpreteazaImagine Proc hWnd:HWND
	Mov bInterpretare, TRUE
	Invoke SimuleazaInimaCNC, hWnd
	Mov _bSimulat, TRUE
	Ret
InterpreteazaImagine EndP

StartCNC Proc hWnd:HWND
	Invoke CloseHandle, hcom
	Mov hcom, NULL
	Invoke SendMessage, hWnd, WM_COMMAND, IDC_WINDOW2_BUTTON6, 0
	.If hcom != NULL
		Invoke InimaCNC, hWnd
	.EndIf
	Ret
StartCNC EndP

IaDimensiuniFereastra Proc Private hWnd:HWND
	Invoke GetWindowRect, hWnd, Addr dimensiuni

	;W = Right - Left
	;H = top - bottom
	Mov Eax, dimensiuni.left
	Sub dimensiuni.right, Eax

	Mov Eax, dimensiuni.top
	Sub dimensiuni.bottom, Eax

	;Invoke nDebug, hWnd, dimensiuni.left

	Ret
IaDimensiuniFereastra EndP

EnableControls2 Proc hWnd:HWND, bVal:BOOL

	.If bVal
		;disable
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_EDIT5
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON6
		Invoke EnableWindow, Eax, FALSE

		Invoke GetMenu, hWnd
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUCONNPORT, MF_GRAYED

		;enable
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUDECONNPORT, MF_ENABLED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPORNESTECNC, MF_ENABLED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSLEEP, MF_ENABLED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPASIPERPIXELX, MF_ENABLED
		Pop Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPASIPERPIXELY, MF_ENABLED

		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON1
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON2
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON3
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON4
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON5
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON7
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_SLIDERPASIPERPIXELX
		Invoke EnableWindow, Eax, TRUE		
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_SLIDERPASIPERPIXELY
		Invoke EnableWindow, Eax, TRUE	

	.Else
		;enable
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_EDIT5
		Invoke EnableWindow, Eax, TRUE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON6
		Invoke EnableWindow, Eax, TRUE


		Invoke GetMenu, hWnd
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUCONNPORT, MF_ENABLED

		;disable
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUDECONNPORT, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPORNESTECNC, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSLEEP, MF_GRAYED
		Pop Eax
		Push Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPASIPERPIXELX, MF_GRAYED
		Pop Eax
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUPASIPERPIXELY, MF_GRAYED

		;enable
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON1
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON2
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON3
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON4
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON5
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_BUTTON7
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_SLIDERPASIPERPIXELX
		Invoke EnableWindow, Eax, FALSE
		Invoke GetDlgItem, hWnd, IDC_WINDOW2_SLIDERPASIPERPIXELY
		Invoke EnableWindow, Eax, FALSE

	.EndIf

	Ret
EnableControls2 EndP

ResetSetariInterpretor Proc
	;Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
	;Mov hndpict, Eax
   	;Invoke GetDC, hndpict
    ;Mov hdcpict, Eax

	Mov linie, 0
	Mov coloana, 0
	Mov nr, 0
	Mov eu, 0
	Mov bytesWritten, 0

	Ret
ResetSetariInterpretor EndP

PasiPerPixelWinX Proc hWnd:HWND
Local nX:DWord
Local nY:DWord
Local nW:DWord
Local nH:DWord

;	Invoke GetWindowRect, _hWnd2, Addr patrat2

;	Mov Eax, patrat2.right
;	Mov Ebx, patrat2.left
;	Sub Eax, Ebx
;	Mov nW, Eax

;	Mov Eax, patrat2.bottom
;	Mov Ebx, patrat2.top
;	Sub Eax, Ebx
;	Mov nH, Eax

;	Mov Edx, 0
;	Mov Eax, nW
;	Mov Ecx, 2
;	Div Ecx
;	Sub Eax, 50
;	Mov nW, Eax

;	Mov Edx, 0
;	Mov Eax, nH
;	Mov Ecx, 2
;	Div Ecx
;	Sub Eax, 50
;	Mov nH, Eax

;	Mov Eax, patrat2.left
;	Add Eax, nW
;	Mov nX, Eax

;	Mov Eax, patrat2.top
;	Add Eax, nH
;	Mov nY, Eax

	Mov Eax, 0
	Mov Al, _nPasiPerPixelX

	Invoke SetInputBoxInt, Eax, 0
	;Invoke SetDlgItemInt, _hWnd4, IDC_WINDOW4_EDIT1, Eax, 0
	Jmp @F
		szPasiPerPixelX DB "Pasi / Pixel X", 0
@@:

	Invoke InputBoxWin, _hWnd2, Addr szPasiPerPixelX, Addr punct2
	Mov Eax, 0
	Mov Eax, punct2.x

	.If Eax > 10
		Jmp @F
			szNrPreaMare DB "Numarul e prea mare. [1-10]", 0
@@:
		Invoke MessageBox, _hWnd2, Addr szNrPreaMare, 0, 0

		Mov Eax, 0
		Ret
	.EndIf

	Mov _nPasiPerPixelX, Al
    Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELX, TBM_SETPOS, TRUE, Eax

    Invoke UpdateProgresMaxXYWin2

;	Invoke SetForegroundWindow, _hWnd2
;	Invoke CloseInputBox
;	;Invoke SetWindowPos, _hWnd4, HWND_TOPMOST, nX, nY, 130, 84, SWP_SHOWWINDOW

	Ret
PasiPerPixelWinX EndP


PasiPerPixelWinY Proc hWnd:HWND
Local nX:DWord
Local nY:DWord
Local nW:DWord
Local nH:DWord

	Mov Eax, 0
	Mov Al, _nPasiPerPixelY

	Invoke SetInputBoxInt, Eax, 0

	Jmp @F
		szPasiPerPixelY DB "Pasi / Pixel Y", 0
@@:

	Invoke InputBoxWin, _hWnd2, Addr szPasiPerPixelY, Addr punct2
	Mov Eax, 0
	Mov Eax, punct2.x

	.If Eax > 10
		Jmp @F
			szNrPreaMareY DB "Numarul e prea mare. [1-10]", 0
@@:
		Invoke MessageBox, _hWnd2, Addr szNrPreaMareY, 0, 0

		Mov Eax, 0
		Ret
	.EndIf

	Mov _nPasiPerPixelY, Al
    Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELY, TBM_SETPOS, TRUE, Eax

    Invoke UpdateProgresMaxXYWin2

	Ret
PasiPerPixelWinY EndP


SleepWin Proc hWnd:HWND
	Invoke SetInputBoxInt, _nSleep, 0

	Jmp @F
		szSleep DB "Sleep (Porneste)", 0
@@:

	Invoke InputBoxWin, _hWnd2, Addr szSleep, Addr punct2
	Mov Eax, punct2.x

	.If Eax > 9000
		Jmp @F
			szNrPreaMareSleep DB "Numarul e prea mare. [1-9000]", 0
@@:
		Invoke MessageBox, _hWnd2, Addr szNrPreaMareSleep, 0, 0

		Mov Eax, 0
		Ret
	.Else
		Mov _nSleep, Eax
	.EndIf

	;Invoke SetForegroundWindow, _hWnd2

	Ret
SleepWin EndP

SleepCncTestWin Proc
Local nX:DWord
Local nY:DWord
Local nW:DWord
Local nH:DWord

;	Invoke GetWindowRect, _hWnd2, Addr patrat2
;	Mov Eax, patrat2.right
;	Mov Ebx, patrat2.left
;	Sub Eax, Ebx
;	Mov nW, Eax

;	Mov Eax, patrat2.bottom
;	Mov Ebx, patrat2.top
;	Sub Eax, Ebx
;	Mov nH, Eax

;	Mov Edx, 0
;	Mov Eax, nW
;	Mov Ecx, 2
;	Div Ecx
;	Sub Eax, 50
;	Mov nW, Eax

;	Mov Edx, 0
;	Mov Eax, nH
;	Mov Ecx, 2
;	Div Ecx
;	Sub Eax, 50
;	Mov nH, Eax

;	Mov Eax, patrat2.left
;	Add Eax, nW
;	Mov nX, Eax

;	Mov Eax, patrat2.top
;	Add Eax, nH
;	Mov nY, Eax

	Invoke SetInputBoxInt, _nCncTestSleep, 0

	Jmp @F
		szSleepCncTest DB "Sleep (Cnc Test) - milisecunde", 0
@@:

	Invoke InputBoxWin, _hWnd2, Addr szSleepCncTest, Addr punct2
	Mov Eax, punct2.x
	.If Eax >= 5 && Eax <= 9000
		Mov _nCncTestSleep, Eax
	.Else
		Jmp @F
			szSleepNrErr DB "Valoarea trebuie sa fie in intervalul [5,9000]", 0
@@:
		Invoke MessageBox, _hWnd2, Addr szSleepNrErr, 0, MB_OK + MB_ICONEXCLAMATION
	.EndIf

	Ret
SleepCncTestWin EndP


bugFix0_w2 Proc hWnd:DWord
	;bugFix #1
		Invoke GetWindowLong, hWnd, GWL_EXSTYLE
		Or Eax, WS_EX_LAYERED
		Invoke SetWindowLong, hWnd, GWL_EXSTYLE, Eax
		;Invoke CiupesteFundal, hWnd
		;Invoke RestRgnFer2, hWnd
		Invoke SetLayeredWindowAttributes, hWnd, 10, 255, LWA_ALPHA

	Ret
bugFix0_w2 EndP

;Send2Save Proc hWnd:HWND
;Local nW:DWord
;Local nH:DWord

;	Invoke GetDlgItem, hWnd, IDC_WINDOW2_PICTURE1
;	Push Eax
;	Invoke GetWindowRect, Eax, Addr patrat2
;	Fild patrat2.right   ; Descazut
;	Fild patrat2.left    ; Scazator
;	Fsub            	; Operatie scadere
;	Fistp nW  ; Salveaza rezultatul in variabila

;	Fild patrat2.bottom 	; Descazut
;	Fild patrat2.top  	; Scazator
;	Fsub            	; Operatie scadere
;	Fistp nH ; Salveaza rezultatul in variabila

;	Pop Eax
;	Invoke GetDC, Eax
;	Invoke CopyDC, Eax, 0, 0, nW, nH
;	Mov _hMasterDC, Eax

;	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
;	Invoke GetDC, Eax
;	Invoke BitBlt, Eax, 0, 0, nW, nH, _hMasterDC, 0, 0, SRCCOPY
;	Invoke SendMessage, hWnd, WM_CLOSE, 0, 0

;	Ret
;Send2Save EndP

;Msgbox Proc Public hWnd:HWND, szTitlu:DWord, szCaption:DWord, nTip:DWord
;;NU E FOLOSITA INCA, si probabil nu o sa fie folosita, dar o sa o revizuiesc si o sa vad daca o sa o folosesc pana la urma
;Local nL1:DWord
;Local nL2:DWord
;Local nT1:DWord
;Local nT2:DWord

;Jmp mar

;	Invoke GetWindowRect, _hWnd1, Addr _patrat
;	Mov Eax, _patrat.left
;	Mov nL1, Eax
;	Mov Eax, _patrat.top
;	Mov nT1, Eax
;	Invoke SetWindowPos, _hWnd1, HWND_NOTOPMOST, nL1, nT1, 0, 0, SWP_NOSIZE

;	Invoke GetWindowRect, _hWnd2, Addr _patrat
;	Mov Eax, _patrat.left
;	Mov nL2, Eax
;	Mov Eax, _patrat.top
;	Mov nT2, Eax
;	Invoke SetWindowPos, _hWnd2, HWND_NOTOPMOST, nL2, nT2, 0, 0, SWP_NOSIZE

;mar:
;	.If !szTitlu
;		Invoke MessageBox, hWnd, Addr _sDespreTitlu, szCaption, 0
;	.Else
;		Invoke MessageBox, hWnd, szTitlu, szCaption, 0
;	.EndIf

;Ret
;	Invoke SetWindowPos, _hWnd1, _nToggleTopMost, nL1, nT1, 0, 0, SWP_NOSIZE
;	Invoke SetWindowPos, _hWnd2, _nToggleTopMost, nL2, nT2, 0, 0, SWP_NOSIZE


;	Ret
;Msgbox EndP

Window2Picture1 Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_RBUTTONDOWN
		.If wParam == 6  	;shift
			.If _nIndent
				Ret
			.EndIf
			Invoke SetUndoDC, hndpict
			Invoke ToggleUndoMnu, _hWnd2

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
			Invoke fl00dFill, Ecx, Edx, Eax, hndpict
		.Else
			Invoke GetCursorPos, Addr punct2
			Invoke TrackPopupMenu, _hPopMenuW2, TPM_LEFTALIGN, punct2.x, punct2.y, 0, _hWnd2, NULL

		.EndIf

	.ElseIf uMsg == WM_LBUTTONDOWN
		.If !_nIndent
			Invoke SetUndoDC, hndpict
			Invoke ToggleUndoMnu, _hWnd2
		.EndIf

		.If wParam == 5		;shift
			.If _nIndent
				Ret
			.EndIf
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
			Invoke fl00dFill, Ecx, Edx, _nPixelColor, hndpict

		.Else
			Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_BUTTON8
			Invoke EnableWindow, Eax, FALSE

			Invoke GetWindowRect, _hWnd3, Addr patrat2
			.If patrat2.top == 0
				Invoke ManualPixWin
			.Else
				Invoke IsWindowVisible, _hWnd3
				.If !Eax
					Invoke SetWindowPos, _hWnd3, HWND_TOPMOST, _Win3OldX, _Win3OldY, 214, 230, SWP_SHOWWINDOW
				.EndIf
			.EndIf

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
			Invoke ManualPixWinDC, Ecx, Edx, 0

	;		;X
	;		Mov Eax, lParam
	;		Mov Edx, 0
	;		Mov Dx, Ax
	;		;Sub Edx, 8
	;		Push Edx

	;		;Y
	;		Mov Edx, 0
	;		Mov Eax, 0
	;		Mov Eax, lParam
	;		Mov Ecx, 010000H
	;		Div Ecx
	;		Mov Edx, 0
	;		Mov Dx, Ax
	;		;Sub Edx, 6

	;		Pop Ecx

	;		Mov Eax, linie
	;		Mov Ebx, coloana
	;		Mov linie, Ecx
	;		Mov coloana, Edx
	;		Invoke ProceseazaLinie, Eax, Ebx, Ecx, Edx, 0

			.If _nPixelColor != White
				Invoke GetDlgItem, _hWnd3, IDC_WINDOW3_PICCULOARE
				Invoke GetDC, Eax
				Invoke BitBlt, Eax, 0, 0, 30, 20, Eax, 0, 0, SRCINVERT
			.EndIf

			;Invoke SendMessage, _hWnd3, WM_COMMAND, IDC_WINDOW3_BTNJOS, 0

			.If _bDebugFocusRect || _bDebugPixelMove
				Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
				Invoke GetDC, Eax
				Invoke DrawFocusRect, Eax, Addr _dbgFocusRect
			.EndIf

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

			.If _bDebugFocusRect
				Mov _bDebugFocusRect, FALSE
			.EndIf

		.EndIf

	.ElseIf uMsg == WM_MOUSEMOVE
		;X
		Mov Eax, lParam
		Mov Edx, 0
		Mov Dx, Ax
		Mov XZoom, Edx

		;Y
		Mov Edx, 0
		Mov Eax, 0
		Mov Eax, lParam
		Mov Ecx, 010000H
		Div Ecx
		Mov Edx, 0
		Mov Dx, Ax
		Mov YZoom, Edx

		Invoke GolesteString, Addr szMainBuffer, 128
		Invoke GolesteString, Addr szBuffer, 64

		Jmp @F
			sX DB "X: ", 0
			sY DB " | Y: ", 0
@@:
		Invoke szCatStr, Addr szMainBuffer, Offset sX
		Invoke dw2a, XZoom, Addr szBuffer
		Invoke szCatStr, Addr szMainBuffer, Addr szBuffer
		Invoke szCatStr, Addr szMainBuffer, Offset sY
		Invoke dw2a, YZoom, Addr szBuffer
		Invoke szCatStr, Addr szMainBuffer, Addr szBuffer

		Invoke SetDlgItemText, _hWnd2, IDC_WINDOW2_TXTZOOMPIXELSCOORD, Addr szMainBuffer

		Mov Eax, 16
		Sub XZoom, Eax
		Mov Eax, 12
		Sub YZoom, Eax

		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE2
		Invoke GetDC, Eax
		Push Eax
		Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		Invoke GetDC, Eax
		Pop Edx
		Invoke StretchBlt, Edx, 0, 0, 160, 120, Eax, XZoom, YZoom, 32, 24, SRCCOPY
		;Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
		;Invoke UpdateWindow, Eax

	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window2Picture1 EndP

ProceseazaLinie Proc nX1:DWord, nY1:DWord, nX2:DWord, nY2:DWord, bSend2Port:BOOL
Local nXDif:DWord
Local nYDif:DWord
Local nCat:DWord
Local nRest:DWord
Local nImpartitor:DWord
Local nF:DWord

	;=================
	;CALCULEAZA SETARI
	;=================
	Mov Eax, nX1
	.If nX2 > Eax
	;CADRAN X POZITIV

		;difX = X2 - X1
		Mov Eax, nX2
		Mov nXDif, Eax
		Mov Eax, nX1
		Sub nXDif, Eax

		Mov Eax, nY1
		.If nY2 > Eax
			;DREAPTA JOS
			;00
			;01
			Mov Eax, nY2
			Mov nYDif, Eax
			Mov Eax, nY1
			Sub nYDif, Eax

			Mov Eax, nYDif
			.If nXDif > Eax
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F1======
	;==============
				;Invoke MessageBox, 0, 0, 0, 0
				;===========================================================
				;Impartim X(nr mare) la Y(nr mic) sa vedem cate linii scriem
				;nCat	= Lungimea unei linii din liniile egale
				;nRest	= Lungimea unei linii in plus (diferita de liniile egale)
				;===========================================================
				Mov nF, 1				;Setam functia de sens
				Mov Eax, nYDif
				.If Eax == 0
					Mov nYDif, 1
					Mov Eax, 1
				.EndIf
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa Y)

				Mov Eax, nXDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa X)
				Mov Edx, 0
				Div nImpartitor 		;nXdif/nYdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax


;			Invoke nDebug, 0, nX1
;			Invoke nDebug, 0, nY1
;			Invoke nDebug, 0, nX2
;			Invoke nDebug, 0, nY2

;			Invoke nDebug, 0, nCat
;			Invoke nDebug, 0, nRest

			.Else
			;nXDif < nDYdif
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F2======
	;==============
				Mov nF, 2				;Setam functia de sens
				Mov Eax, nXDif
				.If Eax == 0
					Mov nXDif, 1
					Mov Eax, 1
				.EndIf				
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa X)

				Mov Eax, nYDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa Y)
				Mov Edx, 0
				Div nImpartitor 		;nYdif/nXdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.EndIf
	;***************************************************************************************************************************
	;***************************************************************************************************************************

		.Else
			;DREAPTA SUS
			;01
			;00
			Mov Eax, nY1
			Mov nYDif, Eax
			Mov Eax, nY2
			Sub nYDif, Eax

			Mov Eax, nYDif
			.If nXDif > Eax
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F3======
	;==============
				Mov nF, 3				;Setam functia de sens
				Mov Eax, nYDif
				.If Eax == 0
					Mov nYDif, 1
					Mov Eax, 1
				.EndIf
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa Y)

				Mov Eax, nXDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa X)
				Mov Edx, 0
				Div nImpartitor 		;nXdif/nYdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.Else
			;nXdif < nYDif
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F4======
	;==============
				Mov nF, 4				;Setam functia de sens
				Mov Eax, nXDif
				.If Eax == 0
					Mov nXDif, 1
					Mov Eax, 1
				.EndIf				
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa X)

				Mov Eax, nYDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa Y)
				Mov Edx, 0
				Div nImpartitor 		;nXdif/nYdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.EndIf
	;***************************************************************************************************************************
	;***************************************************************************************************************************

		.EndIf


	.ElseIf
	;CADRAN X NEGATIV

		;difX = X1 - X2
		Mov Eax, nX1
		Mov nXDif, Eax
		Mov Eax, nX2
		Sub nXDif, Eax

		Mov Eax, nY1
		.If nY2 > Eax
			;STANGA JOS
			;00
			;10
			Mov Eax, nY2
			Mov nYDif, Eax
			Mov Eax, nY1
			Sub nYDif, Eax

			Mov Eax, nYDif
			.If nXDif > Eax
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F5======
	;==============
				Mov nF, 5				;Setam functia de sens
				Mov Eax, nYDif
				.If Eax == 0
					Mov nYDif, 1
					Mov Eax, 1
				.EndIf				
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa Y)

				Mov Eax, nXDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa X)
				Mov Edx, 0
				Div nImpartitor 		;nXdif/nYdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.Else
			;nXDif < nYDif
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F6======
	;==============
				Mov nF, 6				;Setam functia de sens
				Mov Eax, nXDif
				.If Eax == 0
					Mov nXDif, 1
					Mov Eax, 1
				.EndIf				
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa X)

				Mov Eax, nYDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa Y)
				Mov Edx, 0
				Div nImpartitor 		;nYdif/nXdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.EndIf
	;***************************************************************************************************************************
	;***************************************************************************************************************************

		.Else
			;STANGA SUS
			;10
			;00
			Mov Eax, nY1
			Mov nYDif, Eax
			Mov Eax, nY2
			Sub nYDif, Eax

			Mov Eax, nYDif
			.If nXDif > Eax
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F7======
	;==============
				Mov nF, 7				;Setam functia de sens
				Mov Eax, nYDif
				.If Eax == 0
					Mov nYDif, 1
					Mov Eax, 1
				.EndIf				
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa Y)

				Mov Eax, nXDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa X)
				Mov Edx, 0
				Div nImpartitor 		;nXdif/nYdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.Else
			;nXDif < nYDif
	;***************************************************************************************************************************
	;***************************************************************************************************************************
	;==============
	;======F8======
	;==============
				Mov nF, 8				;Setam functia de sens
				Mov Eax, nXDif
				.If Eax == 0
					Mov nXDif, 1
					Mov Eax, 1
				.EndIf
				Mov nImpartitor, Eax	;Impartitorul ia valoare diferenta mica de puncte (axa X)

				Mov Eax, nYDif			;Deimpartirul ia valoarea diferenta mare de puncte (axa Y)
				Mov Edx, 0
				Div nImpartitor 		;nYdif/nXdif
				Mov nCat, Eax
				Mov nRest, Edx
				;Invoke nDebug, 0, Eax

			.EndIf
	;***************************************************************************************************************************
	;***************************************************************************************************************************

		.EndIf

	.EndIf

linieDreapta:
	Mov Eax, nX1
	Mov Xcurent, Eax
	Mov Eax, nY1
	Mov Ycurent, Eax
	Invoke DeseneazaLinie, nCat, nRest, nImpartitor, nF, bSend2Port

	Ret
ProceseazaLinie EndP

DeseneazaLinie Proc Cat:DWord, Rest:DWord, Impartitor:DWord, F:DWord, bSend2Port:BOOL
Local A:HWND
Local B:HWND
Local L:HWND
Local D:HWND
Local nCat:DWord
Local nRest:DWord
Local nImpartitor:DWord
Local nF:DWord

	Mov Eax, Cat
	Mov nCat, Eax
	Mov Eax, Rest
	Mov nRest, Eax
	Mov Eax, Impartitor
	Mov nImpartitor, Eax
	Mov Eax, F
	Mov nF, Eax

	;==REST > CAT==
	Mov D, 0
	Mov A, 0
	Mov Eax, nCat
	.If nRest > Eax
		Sub nRest, Eax
		Mov Eax, nRest
		Mov A, Eax
	.EndIf

;======================
;START BUCLA PRINCIPALA
;======================
Mov B, 0
startB:
	Mov Eax, nImpartitor
	Cmp B, Eax
	Je stopB

	;=================
	;Start bucla linie
	;=================
	Mov L, 0
startL:
	Mov Eax, nCat
	Cmp L, Eax
	Je stopL
		;OPERATIE TRASARE LINIE AXA MARE
		.If nF == 1 || nF == 3
			Invoke LinieIncX, bSend2Port
		.ElseIf nF == 2 || nF == 6
			Invoke LinieIncY, bSend2Port
		.ElseIf nF == 4 || nF == 8
			Invoke LinieDecY, bSend2Port
		.ElseIf nF == 5 || nF == 7
			Invoke LinieDecX, bSend2Port
		.EndIf

	Inc L
	Jmp startL
stopL:


	;==REST de adaugat ?==
	Mov Eax, A
	.If D < Eax && Eax != 0
		;Mov D, 0
		;ADAUGARE PUNCT PENTRU REST
		.If nF == 1 || nF == 3
			Invoke LinieIncX, bSend2Port
		.ElseIf nF == 2 || nF == 6
			Invoke LinieIncY, bSend2Port
		.ElseIf nF == 4 || nF == 8
			Invoke LinieDecY, bSend2Port
		.ElseIf nF == 5 || nF == 7
			Invoke LinieDecX, bSend2Port
		.EndIf

	.EndIf
	Inc D


	;==OPERATIE INCREMENTARE AXA MICA==
	.If nF == 1 || nF == 5
		Invoke LinieIncY, bSend2Port
	.ElseIf nF == 2 || nF == 4
		Invoke LinieIncX, bSend2Port
	.ElseIf nF == 3 || nF == 7
		Invoke LinieDecY, bSend2Port
	.ElseIf nF == 6 || nF == 8
		Invoke LinieDecX, bSend2Port
	.EndIf

	Inc B
	Jmp startB
stopB:

	Mov Eax, nCat
	.If nRest <= Eax
		Mov Eax, nRest
		Mov nCat, Eax
	.EndIf

Mov L, 0
startL2:
		Mov Eax, nCat
		Cmp L, Eax
		Je stopL2
			;OPERATIE TRASARE LINIE AXA MARE
			.If nF == 1 || nF == 3
				Invoke LinieIncX, bSend2Port
			.ElseIf nF == 2 || nF == 6
				Invoke LinieIncY, bSend2Port
			.ElseIf nF == 4 || nF == 8
				Invoke LinieDecY, bSend2Port
			.ElseIf nF == 5 || nF == 7
				Invoke LinieDecX, bSend2Port
			.EndIf

		Inc L
		Jmp startL2
stopL2:


	Ret
DeseneazaLinie EndP

LinieIncX Proc bSend2Port:BOOL
	Inc Xcurent
	Mov Eax, Xcurent

	.If !bSend2Port

;		.If bInterpretare
;			Mov Ecx, _iCSM
;			Mov Ebx, Offset dreapta
;			Mov Edx, [Ebx]
;			Mov [Ecx], Edx
;			inc _iCSM

;		.EndIf

		Invoke Send2Port, 0
	.Else
		Invoke Send2Port, Offset dreapta
	.EndIf

	Inc _Xcnc

	Ret
LinieIncX EndP

LinieDecX Proc bSend2Port:BOOL
	Dec Xcurent
	Mov Eax, Xcurent

	.If !bSend2Port
;		.If bInterpretare
;			Mov Ecx, _iCSM
;			Mov Ebx, Offset stanga
;			Mov Edx, [Ebx]
;			Mov [Ecx], Edx
;			Inc _iCSM
;		.EndIf

		Invoke Send2Port, 0
	.Else
		Invoke Send2Port, Offset stanga
	.EndIf

	Dec _Xcnc

	Ret
LinieDecX EndP

LinieIncY Proc bSend2Port:BOOL
	Inc Ycurent
	Mov Eax, Ycurent

	.If !bSend2Port
;		.If bInterpretare
;			Mov Ecx, _iCSM
;			Mov Ebx, Offset sus2
;			Mov Edx, [Ebx]
;			Mov [Ecx], Edx
;			inc _iCSM

;		.EndIf

		Invoke Send2Port, 0
	.Else
		Invoke Send2Port, Offset sus2
	.EndIf

	Inc _Ycnc

	Ret
LinieIncY EndP

LinieDecY Proc bSend2Port:BOOL
	Dec Ycurent
	Mov Eax, Ycurent

	.If !bSend2Port
;		.If bInterpretare
;			Mov Ecx, _iCSM
;			Mov Ebx, Offset jos2
;			Mov Edx, [Ebx]
;			Mov [Ecx], Edx
;			Inc _iCSM

;		.EndIf

		Invoke Send2Port, 0
	.Else
		Invoke Send2Port, Offset jos2
	.EndIf

	Dec _Ycnc

	Ret
LinieDecY EndP

Send2Port Proc addrSens:DWord
Local i:Byte

	Mov i, 0

	.If !bInterpretare
		Invoke GetDC, _hWnd4
		Invoke SendMessage, _hWnd4, WM_PAINT, Eax, 0

		Invoke GetPixel, hdcpict, Xcurent, Ycurent
		.If Eax == White
			Invoke SetPixel, hdcpict, Xcurent, Ycurent, Blue
			.If _hCncDC
				Invoke SetPixel, _hCncDC, _Xcnc, _Ycnc, Blue
				Invoke Sleep, _nCncTestSleep
			.EndIf		
		.EndIf

		Inc nPixeliScrisi

	.EndIf

	.If addrSens
		.Repeat
			.If hcom != INVALID_HANDLE_VALUE
				Invoke WriteFile, hcom, addrSens, 1, Addr bytesWritten, 0
			     call readf
				Invoke Sleep, _nSleep
				Inc nPasiFacuti
			.EndIf

		Inc i
		Mov Eax, Offset stanga
		Mov Ebx, Offset dreapta
		.If addrSens == Eax || addrSens == Ebx
			Mov Eax, 0
			Mov Al, _nPasiPerPixelX
		.Else
			Mov Eax, 0
			Mov Al, _nPasiPerPixelY
		.EndIf
 		.Until i == Al

	.EndIf

	Ret
Send2Port EndP

CncTestWin Proc
	Jmp @F
		sWin4 DB "Window4", 0
@@:
	Invoke Create, Addr sWin4, NULL, NULL, NULL
	Mov _hWnd4, Eax

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_BUTTON9
	Invoke EnableWindow, Eax, FALSE

	Ret
CncTestWin EndP

Window2sliderPasiPerPixelX Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONUP || uMsg == WM_RBUTTONUP || uMsg == WM_KEYUP
	    Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELX, TBM_GETPOS, TRUE, Eax
		Mov _nPasiPerPixelX, Al

		Invoke UpdateProgresMaxXYWin2

		;Invoke SetInputBoxInt, Eax, 0
		;Invoke SetDlgItemInt, _hWnd4, IDC_WINDOW4_EDIT1, Eax, 0
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window2sliderPasiPerPixelX EndP

Window2sliderPasiPerPixelY Proc hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_LBUTTONUP || uMsg == WM_RBUTTONUP || uMsg == WM_KEYUP
	    Invoke SendDlgItemMessage, _hWnd2, IDC_WINDOW2_SLIDERPASIPERPIXELY, TBM_GETPOS, TRUE, Eax
		Mov _nPasiPerPixelY, Al

		Invoke UpdateProgresMaxXYWin2

		;Invoke SetInputBoxInt, Eax, 0
	.EndIf

	Xor Eax, Eax	;Return FALSE
	Ret
Window2sliderPasiPerPixelY EndP

ReincarcaWin2 Proc
	Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0
	Invoke SendMessage, _hWnd4, WM_CLOSE, 0, 0
	Invoke CloseInputBox

	Mov _nIndent, 0
	Invoke Send2CNC
	Invoke Send2CNC

	Invoke GetMenu, _hWnd2
	Push Eax
	Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSUBINDENT, MF_GRAYED
	Pop Eax
	Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUUNDO, MF_GRAYED

;	Invoke SaveMasterDC, _hWnd1
;	Mov Eax, _hMasterDC
;	Mov _hUndoDC, Eax

;	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
;	Invoke DrawMasterDC, Eax

;	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
;	Invoke DrawMasterDC, Eax

	Ret
ReincarcaWin2 EndP

AddIndent Proc
Local nW:DWord
Local nH:DWord
Local nNewW:DWord
Local nNewH:DWord

	Add _nIndent, 10

	Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0

	Invoke GetWindowRect, _hWnd2, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp _patrat.right
	Add _patrat.right, 20
	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp _patrat.bottom
	Add _patrat.bottom, 20
	Invoke SetWindowPos, _hWnd2, HWND_TOP, 0, 0, _patrat.right, _patrat.bottom, SWP_NOMOVE

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Push Eax
;	Invoke ShowWindow, Eax, SW_HIDE
;	Pop Eax
;	Push Eax
;	Invoke ShowWindow, Eax, SW_SHOW
;	Pop Eax
;	Push Eax
	Invoke GetWindowRect, Eax, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp _patrat.right
	Add _patrat.right, 20
	Move nNewW, _patrat.right
	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp _patrat.bottom
	Add _patrat.bottom, 20
	Move nNewH, _patrat.bottom
	Pop Eax
	Push Eax
	Invoke SetWindowPos, Eax, HWND_TOP, 0, 0, _patrat.right, _patrat.bottom, SWP_NOMOVE
	Pop Eax
	Invoke Update, Eax

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Addr patrat2
	Fild patrat2.right
	Fild patrat2.left
	Fsub
	Fistp nW
	Sub nW, 2
	Fild patrat2.bottom
	Fild patrat2.top
	Fsub
	Fistp nH
	Sub nH, 2
	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke GetDC, Eax
	Invoke BitBlt, Eax, _nIndent, _nIndent, nW, nH, _hMasterDC, 0, 0, SRCCOPY

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESX
	Mov Ebx, nCtrlsW
	Add Ebx, nMargin
	Add Ebx, 75
	Invoke SetWindowPos, Eax, HWND_TOP, Ebx, 7, nNewW, 12, SWP_SHOWWINDOW
	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESY
	Mov Ebx, nNewH
	Add Ebx, nMargin
	Mov Ecx, nCtrlsW
	Add Ecx, nMargin
	Add Ecx, nNewW
	Add Ecx, 76
	Invoke SetWindowPos, Eax, HWND_TOP, Ecx, nMargin, 12, nNewH, SWP_SHOWWINDOW

	Invoke UpdateProgresMaxXYWin2

	Invoke GetMenu, _hWnd2
	Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSUBINDENT, MF_ENABLED

	Ret
AddIndent EndP

SubIndent Proc
Local nW:DWord
Local nH:DWord	
Local nNewW:DWord
Local nNewH:DWord

	.If !_nIndent
		Ret
	.EndIf

	Sub _nIndent, 10

	Invoke SendMessage, _hWnd3, WM_CLOSE, 0, 0

	Invoke GetWindowRect, _hWnd2, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp _patrat.right
	Sub _patrat.right, 20
	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp _patrat.bottom
	Sub _patrat.bottom, 20
	Invoke SetWindowPos, _hWnd2, HWND_TOP, 0, 0, _patrat.right, _patrat.bottom, SWP_NOMOVE

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Push Eax
;	Invoke ShowWindow, Eax, SW_HIDE
;	Pop Eax
;	Push Eax
;	Invoke ShowWindow, Eax, SW_SHOW
;	Pop Eax
;	Push Eax
	Invoke GetWindowRect, Eax, Addr _patrat
	Fild _patrat.right
	Fild _patrat.left
	Fsub
	Fistp _patrat.right
	Sub _patrat.right, 20
	Move nNewW, _patrat.right
	Fild _patrat.bottom
	Fild _patrat.top
	Fsub
	Fistp _patrat.bottom
	Sub _patrat.bottom, 20
	Move nNewH, _patrat.bottom
	Pop Eax
	Push Eax
	Invoke SetWindowPos, Eax, HWND_TOP, 0, 0, _patrat.right, _patrat.bottom, SWP_NOMOVE
	Pop Eax
	Invoke Update, Eax

	Invoke GetDlgItem, _hWnd1, IDC_WINDOW1_IMGCONTUR
	Invoke GetWindowRect, Eax, Addr patrat2
	Fild patrat2.right
	Fild patrat2.left
	Fsub
	Fistp nW
	Sub nW, 2

	Fild patrat2.bottom
	Fild patrat2.top
	Fsub
	Fistp nH
	Sub nH, 2

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PICTURE1
	Invoke GetDC, Eax
	Invoke BitBlt, Eax, _nIndent, _nIndent, nW, nH, _hMasterDC, 0, 0, SRCCOPY

	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESX
	Mov Ebx, nCtrlsW
	Add Ebx, nMargin
	Add Ebx, 75
	Invoke SetWindowPos, Eax, HWND_TOP, Ebx, 7, nNewW, 12, SWP_SHOWWINDOW
	Invoke GetDlgItem, _hWnd2, IDC_WINDOW2_PROGRESY
	Mov Ebx, nNewH
	Add Ebx, nMargin
	Mov Ecx, nCtrlsW
	Add Ecx, nMargin
	Add Ecx, nNewW
	Add Ecx, 76
	Invoke SetWindowPos, Eax, HWND_TOP, Ecx, nMargin, 12, nNewH, SWP_SHOWWINDOW

	Invoke UpdateProgresMaxXYWin2

	.If !_nIndent
		Invoke GetMenu, _hWnd2
		Invoke EnableMenuItem, Eax, IDM_WINDOW2_MNUSUBINDENT, MF_GRAYED
	.EndIf

	Ret
SubIndent EndP


doPixelSimulare:
	Invoke SetPixel, hdcpict, linie, coloana, 255
	.If _hCncDC
		Invoke SetPixel, _hCncDC, linie, coloana, Red
		Mov Eax, linie
		Mov _Xcnc, Eax
		Mov Eax, coloana
		Mov _Ycnc, Eax
		Invoke Sleep, _nCncTestSleep
	.EndIf
	Inc nPixeliScrisi

Ret

doScrieFisiere:
	Call scriePunctCosduino
	Mov Ecx, _iCSM
	Mov Ebx, Offset _szSens
	Mov Edx, [Ebx]
	Mov [Ecx], Edx
	Inc _iCSM

	;Call scriePunctCSM
	Call scriePunctGCode



Ret


scriePunctCSM:
	Mov Ecx, _pCSMCompBuffer
	Mov Ebx, _iCSMFile

	Add Ebx, Ecx
	Mov Eax, linie
	Mov [Ebx], Ax

	Add _iCSMFile, 2
	Mov Ebx, _iCSMFile
	Add Ebx, Ecx

	Mov Eax, coloana
	Mov [Ebx], Ax
	Add _iCSMFile, 2
Ret


scriePunctGCode:
;	Jmp @F
;		szG00 DB 13, 10, "G00", 0
;		szGCodeX DB " X", 0
;		szGCodeY DB " Y", 0
;		szPauza DB " ", 0
;@@:

	.If _iGCode == 0
		Invoke szCatStr, _pGCode, Addr _szGCodeZBugFix1
		Add _iGCode, 6 ;GCode ZBug-fix
		Mov _nGCodeStart, 1
		;Invoke MessageBox, 0, 0, 0, 1
		;Invoke nDebug, 0, _iGCode

		;Ret
	.EndIf

	Mov Eax, linie
	Mov Ebx, coloana

	.If _nLastXGCode != Eax || _nLastYGCode != Ebx

		Mov Ecx, _pGCode
		Mov Ebx, _iGCode
		Add Ecx, Ebx

		Mov Edx, 030470A0DH			;13,10,"00"
		Mov [Ecx], Edx
		Add Ecx, 4
		Mov Edx, 030H				;"G"
		Mov [Ecx], Edx
		Inc Ecx

		Mov Edx, linie
		.If _nLastXGCode != Edx
			Mov Edx, "X "
			Mov [Ecx], Edx
			Add Ecx, 2

			Invoke dw2a, linie, Ecx
			Invoke StrLen, _pGCode
			Add Eax, _pGCode
			Mov Ecx, Eax

;			.Repeat
;				Mov Ebx, [Ecx]
;				Inc Ecx
;			.Until !Ebx
;			Dec Ecx

			Move _nLastXGCode, linie
		.EndIf

		Mov Edx, coloana
		.If _nLastYGCode != Edx
			Mov Edx, "Y "
			Mov [Ecx], Edx
			Add Ecx, 2

			Invoke dw2a, coloana, Ecx
			Invoke StrLen, _pGCode
			Add Eax, _pGCode
			Mov Ecx, Eax

			Move _nLastYGCode, coloana
		.EndIf

		Sub Ecx, _pGCode
		Mov _iGCode, Ecx
	.EndIf

	Mov Eax, _nGCodeStart
	Cmp Eax, 1
	Jne @F
		Mov Eax, _pGCode
		Add Eax, _iGCode
		Push Eax
		Invoke szCatStr, Addr _szGCodeZBugFix3, _pGCode
		Pop Eax
		Invoke szCatStr, Eax, Addr _szGCodeZBugFix2
		Invoke StrLen, _pGCode
		Mov _iGCode, Eax
		Mov _nGCodeStart, 3
		;Invoke nDebug, 0, _iGCode
		;Ret
		;Invoke MessageBox, 0, Addr _szGCodeZBugFix3, 0, 0
	
@@:

 ;  Invoke MessageBox, 0, _pGCode, 0, 0

Ret

scriePunctCosduino:
;data direct ABCD
Mov Ecx, _pCSMCompBuffer
	Mov Ebx, _iCSMFile

	Add Ebx, Ecx

    .If Al

	Mov [Ebx], Al
    Add _iCSMFile, 1
    ;Inc Ebx
    ;Mov Al, ","
    ;Mov [Ebx], Al
    ;Add _iCSMFile, 1

    	.EndIf

	Mov Ecx, _pCSMCompBuffer
	Mov Ebx, _iCSMFile

	Add Ebx, Ecx

    .If Ah
	Mov [Ebx], Ah
    Add _iCSMFile, 1
    ;Inc Ebx
    ;Mov Al, ","
    ;Mov [Ebx], Al
    ;Add _iCSMFile, 1
    	.EndIf



;scrie data bascom---nu's ce are!

;	Mov Ecx, _pCSMCompBuffer
;	Mov Ebx, _iCSMFile

;	Add Ebx, Ecx
;.If cosduino == 0
;		Mov Cx, 0A0DH
;	Mov [Ebx], Cx
;	Add Ebx, 2
;    Add _iCSMFile, 2
;	Mov Ecx, "ATAD"
;	Mov [Ebx], Ecx
;	Add Ebx, 4
;    Mov Ecx, "    "
;    Mov [Ebx], Ecx
;    Add Ebx, 4
;        Add _iCSMFile, 8
;	.EndIf
;	.If Al
;    .If Al == "A"
;    	Mov Al, "1"
;    	.Else
;    		Mov Al, "2"
;    		.EndIf

;    Inc cosduino
;	Mov [Ebx], Al
;    Add _iCSMFile, 1
;    Inc Ebx
;    	Mov Cl, ","
;    Mov [Ebx], Cl
;    Inc Ebx
;        Add _iCSMFile, 1
;    	.EndIf

;	Mov Ecx, _pCSMCompBuffer
;	Mov Ebx, _iCSMFile

;	Add Ebx, Ecx

;    .If Ah
;    	    .If Ah == "A"
;    	Mov Ah, "3"
;    	.Else
;    		Mov Ah, "4"
;    		.EndIf
;    Inc cosduino
;	Mov [Ebx], Ah
;    Add _iCSMFile, 1
;    Inc Ebx
;    	Mov Cl, ","
;    Mov [Ebx], Cl
;    Inc Ebx
;    Add _iCSMFile, 1
;    	.EndIf
;.If cosduino > 20


;	Mov cosduino, 0

;	.EndIf
	;****************************************************************************
;Mov Ebx, Offset _szSens
;Invoke SetDlgItemInt, _hWnd2, IDC_WINDOW2_EDIT2, Ebx, 0
;Invoke Sleep, 1000
				   Ret
readf:

			Lea Eax, tempchar
			Mov Bl, 71
			Mov [Eax], Bl
			Invoke ReadFile, hcom, Addr tempchar, 1, Addr tmp, 0
            Invoke SetDlgItemText, _hWnd2, IDC_WINDOW2_EDIT2, Addr tempchar
			Lea Eax, tempchar
			Mov Bl, [Eax]
			.If Bl == 70
				;Invoke MessageBox, hnd, Addr prbchar, Addr prbchar, 1
			Invoke EnableControls2, hnd, 0
			Invoke CloseHandle, hcom
			.EndIf
Ret


