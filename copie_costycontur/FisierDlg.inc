;==================
;FisierDlg lib v0.1
;==================

DeschideFisierDlg Proto :HWND, :DWord, :DWord
SalveazaFisierDlg Proto :HWND, :DWord, :DWord
SetFiltruFisierDlg Proto :HWND, :DWord, :DWord

;[DeschideFisierDlg]
;===EXEMPLU===
;.Data?
;_sNumeFisier 	DB MAX_PATH Dup(?)
;_sTitluFisier	DB MAX_PATH Dup(?)
;.code
;Invoke DeschideFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
;===PARAMETRII===
;hWnd 		- handle fereastra care cheama dialogul
;&dWord 	- Nume fisier
;&dWord 	- Titlu Fisier
;===REZULTAT===
;DA -> Iti salveaza in cele 2 dWord-uri valorile caii fisierului
;NU -> Returneaza 0

;[SalveazaFisierDlg]
;===EXEMPLU===
;.Data?
;_sNumeFisier 	DB MAX_PATH Dup(?)
;_sTitluFisier	DB MAX_PATH Dup(?)
;.code
;Invoke SalveazaFisierDlg, hWnd, Offset _sNumeFisier, Offset _sTitluFisier
;===PARAMETRII===
;hWnd 		- handle fereastra care cheama dialogul
;&dWord 	- Nume fisier
;&dWord 	- Titlu Fisier
;===REZULTAT===
;DA -> Iti salveaza in cele 2 dWord-uri valorile caii fisierului
;NU -> Returneaza 0

;[SetFiltruFisierDlg]
;===EXEMPLU===
;Jmp @F
;_sFiltruFisier  	DB	"BitMap (*.bmp)", 0, "*.bmp", 0, 0
;_sDefPrestab		DB	"bmp", 0
;@@:
;Invoke SetFiltruFisierDlg, hWnd, Offset _sFiltruFisier, Offset _sDefPrestab
;===PARAMETRII===
;hWnd 		- handle fereastra care cheama dialogul
;&dWord 	- addr String filtru fisier
;&dWord 	- addr String tipuri de fisiere prestabilite
;===REZULTAT===
;DA -> Iti salveaza in cele 2 dWord-uri valorile caii fisierului
;NU -> Returneaza 0
