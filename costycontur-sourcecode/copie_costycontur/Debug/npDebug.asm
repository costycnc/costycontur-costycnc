nDebug Proto :HWND, :DWord
pDebug Proto :HWND

.Const

.Data?
s_nDebugText 	DB 1024 Dup(?)
s_pDebugText	DB 256  Dup(?)
s_pDebugBuffer	DB 32	Dup(?)

.Data
;DEBUG
s_nDebugTitlu DB "nD3bug v0.1", 0
s_pDebugTitlu DB "pD3bug v0.1", 0

.Code

nDebug Proc hWndN:HWND, nVal:DWord

	Invoke dw2a, nVal, Offset s_nDebugText
	.If hWndN == 0
		Invoke MessageBox, hWndN, Offset s_nDebugText, Offset s_nDebugTitlu, 0
	.Else
		Invoke SetWindowText, hWndN, Offset s_nDebugText
	.EndIf

	Ret
nDebug EndP

pDebug Proc hWndP:HWND
	Push Esp
Jmp @F
	szEIP DB "EIP: ", 0
	szESP1 DB 13, 10, "ESP: ", 0
	szESP2 DB "ESP: ", 0
@@:

	Invoke GolesteString, Addr s_pDebugText, 256
	Invoke GolesteString, Addr s_pDebugBuffer, 32
	Invoke szCatStr, Addr s_pDebugText, Addr szEIP
	Pop Eax
	Push Eax
	Mov Eax, [Eax + 4]
	Invoke dw2ah, Eax, Offset s_pDebugBuffer
	Invoke szCatStr, Addr s_pDebugText, Addr s_pDebugBuffer

	.If hWndP == 0
		Invoke szCatStr, Addr s_pDebugText, Addr szESP1
		Pop Eax
		Add Eax, 4
		Invoke dw2ah, Eax, Offset s_pDebugBuffer
		Invoke szCatStr, Addr s_pDebugText, Addr s_pDebugBuffer

		Invoke MessageBox, hWndP, Offset s_pDebugText, Offset s_pDebugTitlu, 0
	.Else
		Invoke szCatStr, Addr s_pDebugText, Addr szESP1
		Pop Eax
		Add Eax, 4	
		Invoke dw2ah, Esp, Offset s_pDebugBuffer
		Invoke szCatStr, Addr s_pDebugText, Addr s_pDebugBuffer

		Invoke SetWindowText, hWndP, Offset s_pDebugText
	.EndIf

	Ret
pDebug EndP

