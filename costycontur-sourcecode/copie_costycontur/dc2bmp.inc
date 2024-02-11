;===============
;dc2bmp lib v0.2
;===============

Dc2Bmp Proto :HDC, :DWord , :DWord, :DWord, :DWord, :DWord
WndDc2Bmp Proto :HWND, :DWord
GetBmpDims Proto :DWord, :DWord
CopyDC Proto :HDC, :DWord, :DWord, :DWord, :DWord
CopyDC2 Proto :HDC, :DWord, :DWord, :DWord, :DWord


;[Dc2Bmp]
;hDC care vrei sa salvezi
;addr Calea unde vrei sa salvezi pe disk
;Left
;Top
;Width
;Height
;===REZULTAT===
;DA -> Iti salveaza pe disc hDC-ul cerut
;NU -> Returneaza 0

;[WndDc2Bmp]
;hWnd ferestrei care vrei sa-i salvezi hDC-ul
;addr Calea unde vrei sa salvezi pe disk
;===REZULTAT===
;DA -> Iti salveaza pe disc hDC-ul ferestrei cerute
;NU -> Returneaza 0


;[GetBmpDims]
;addr Cale fisier bmp
;addr stuctura punct (Point) in care sa iti salvezi
;===REZULTAT===
;DA -> Reintoarce in structura punct selectata, dimesiunile bitmapului
;NU -> Reintoarce 0

;[CopyDC]
;hDC care vrei sa salvezi
;Left
;Top
;Width
;Height
;===REZULTAT===
;DA -> Iti reintoarce-n eax hDC-ul copiat
;NU -> Returneaza 0
