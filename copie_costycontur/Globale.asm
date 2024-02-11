;EasyCodeName=Globale,1
.Const
;Bug Workaround
;Setari
nStartTop 				DD 44
nCtrlsW					DD 105
nMargin 				DD 20

.Data?
;GLOBALE
_hWnd1					HWND ?
_hWnd2 					HWND ?
_hWnd3					HWND ?
;_hwnd4					hwnd ? ; E scris mai jos
_hWnd5					HWND ?
_hWnd6					HWND ?
_hMasterDC				HDC ?
_hUndoDC				HDC ?
_hVechiDC				HDC ?

;Depanare manuala
_Xbusit					Word ?
_Ybusit					Word ?

;Debug feature
_bDebugFocusRect		BOOL ?
_bDebugPixelMove		BOOL ?

;Popup menu
_hPopMenuW1				HANDLE ?
_hPopMenuW2				HANDLE ?

;Fisiere dialog
_sNumeFisier			DB MAX_PATH Dup(?)
_sTitluFisier			DB MAX_PATH Dup(?)

;CurDir
_szCurDir				DB MAX_PATH Dup(?)
_szCSMSimPath			DB MAX_PATH Dup(?)

;Settings buffer
_szSettingsBuffer		DB 1024 Dup(?)

;Buffer trimitere compresata port
;********************************
;Vor fi create cu GlobalAlloc
;********************************
_hMemCSMBuffer			DD ?
_hMemCSMCompBuffer		DD ?
_hMemCSMBascom			DD ?
_hMemGCode				DD ?
_pCSMBuffer				DD ?		;DB 10240 Dup(?) ;1000 Kb
_pCSMCompBuffer			DD ?		;DB 10240 Dup(?) ;1000 kb
_pCSMBascom				DD ?		;DB 10240 Dup(?) ;1000 kb
_pGCode					DD ?		;DB 10240 Dup(?) ;1000 kb

_iCSM					DD ?
_iCSMComp				DD ?
_iCSMFile				DD ?
_iGCode					DD ?

;Bascom file
_szCSMBascomFile     	DB MAX_PATH Dup(?)
_szCSMBascomCompFile 	DB MAX_PATH Dup(?)
_szCSMBascomRaw			DB MAX_PATH Dup(?)
_szCSMGCodeFile			DB MAX_PATH Dup(?)
_szCSMDirFisiere		DB MAX_PATH Dup(?)
_szDefaultSCM			DB MAX_PATH Dup(?)		;pt SHELLEXEC
_szGCodeEditorFile		DB MAX_PATH Dup(?)
_szDefaultSettingsFile	DB MAX_PATH Dup(?)

;Buffer citire setari
_szValBuffer			DB 16	Dup(?)

;Directie CSM
_szSens					DB 1 	Dup(?)

;ReadFile / WriteFile var
_nBytesUsed				DD ?

;GCode bugfix 3
_szGCodeZBugFix3	 	DB 64 Dup(?)

.Data
;Fereastra 4 are nevoie de initializare
_hWnd4					HWND 0

;Testare CNC
_hCncDC 				HDC 0
_Xcnc					DWord 0
_Ycnc					DWord 0

;FisierDlg Bmp
_sDefPrestab			DB	"bmp", 0
_sFiltruFisier	 		DB	"BitMap (*.bmp)", 0, "*.bmp", 0, 0

;FisierDlg Ini
_sDefPrestabIni			DB	"cci", 0
_sFiltruFisierIni 		DB	"Setari (*.cci)", 0, "*.cci", 0, 0

;FisierDlg CSM
_sDefPrestabCSM			DB	"csm", 0
_sFiltruFisierCSM 		DB	"Costel si Marius bytes (*.csm)", 0, "*.csm", 0, 0

_sDefPrestabGCode		DB "nc", 0
_sFiltruFisierGCode		DB  "G-code (*.nc)", 0, "*.nc", 0, 0

;Titluri MsgBox
_szSucces				DB "SUCCES!", 0
_szErr					DB "EROARE :(", 0
_szSigur				DB "SIGUR?", 0

;CAI FISIERE
_szDirFisiere			DB "fisiere", 0
_szDebugBmp				DB "\fisiere\debug.bmp", 0
_szBascom				DB "\fisiere\bascom.cbd", 0			;CostyContur Bascom Data
_szBascomRaw			DB "\fisiere\bascomRawBytes.rdb", 0	;Raw Data Bytes
_szBascomComp			DB "\fisiere\test.txt", 0	;Costel si Marius :D ( CostyContur Bascom Bytes )
_szGcode				DB "\fisiere\Gcode.nc", 0			;Gcode
_szDefaultSettings		DB "\Setari.cci", 0					;CCI -> CostyContur Information

_szCSMSimulator 		DB "\CSMSimulator.exe", 0
_szGCodeEditor			DB "\GCodeEditor.html", 0

_szGCodeZBugFix1		DB "G00 Z1", 0				;6 bytes
_szGCodeZBugFix2		DB 13, 10, "G00 Z0", 0		;8 bytes

_nGCodeStart			DD 0

_nLastXGCode			DD 0
_nLastYGCode			DD 0
_nLastZGCode			DD 0

_nIndent				DD 0

;Salvare Bitmp
_nBmpWidth				DWord 0
_nBmpHeight				DWord 0

;Setari CNC
_nCNCMaxLinii 			DD 90
_nCNCMaxColoane			DD 190

;Setari CNC
_nSleep					DWord 40
_nCncTestSleep			DWord 5
_nPasiPerPixelX			Byte 1
_nPasiPerPixelY			Byte 1
_nCom					DWord 3
_nPixelColor			DD White ;0FFFFFFFFH
_nToggleTopMost 		DD HWND_NOTOPMOST
_nMaxX					DWord 640
_nMaxY					DWord 400
_bAskOnExit				BOOL FALSE

;Flag simulat odata macar
_bSimulat				BOOL FALSE

;Undo
_bUndo					BOOL FALSE

;Masura de siguranta
_bFundalCiupit 			BOOL FALSE

;Vechiul X si Y al ferestrei 1 si 3
_MainWinOldX			DD 	0
_MainWinOldY			DD 	0
_Win3OldX				DD  0
_Win3OldY				DD  0

;BUG FIX #2 - Pizda masii de alocare dinamica
;!Problema
;!Daca is mai multe ferestre in aplicatie, (ca in cazul nostru)
;!nu isi aloca cum trebuie memoria pentru variabile (in cazul meu structuri)
;!si prin urmare, in rutina SetRgnFer din Window1
;!la instructiunea { Mov [aRgn + 40], Edx }, va aparea o suprascriere cred
;!ceea ce va duce la problema afisarii dialogului comun pentru fisiere
;?!Solutie:
;?!Am mutat declararea punctelor in modulul cu variabile globale

;Buf bix
_bPrimaData  			BOOL FALSE

;STRUCTURI
punctA  				POINT <>
punctB 	 				POINT <>
punctC  				POINT <>
punctD 					POINT <>
punctE 					POINT <>
punctF  				POINT <>
punctG 					POINT <>
punctH 					POINT <>
punctI  				POINT <>
punctJ  				POINT <>

_patrat       			RECT <>
_dbgFocusRect 			RECT <>

.Code
