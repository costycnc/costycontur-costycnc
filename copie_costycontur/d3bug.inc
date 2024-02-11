nDebug Proto :HWND, :DWord
;:HWND == 0
;	Messagebox
;:HWND > 0 
;	SetWindowText
pDebug Proto :HWND
;:HWND == 0
;	Messagebox
;:HWND > 0 
;	SetWindowText

;InputBox
InputBox Proto :DWord, :DWord
	;InputBox Proc szAddrTitlu:DWord, addrCallback:DWord
InputBoxPos Proto :DWord, :DWord, :DWord, :DWord
	;InputBoxPos Proc szAddrTitlu:DWord, addrCallback:DWord, nX:DWord, nY:DWord
InputBoxWin Proto :HWND,:dword,:dword
	;InputBoxWin Proc hWindow:HWND,szAddrTitlu:dword, addrRetPoint:dword
	;rets: .x -> uNr, .y -> addrStr
SetInputBoxInt Proto :DWord, :BOOL
	;SetInputBoxInt Proc nValue:DWord, bSigned:BOOL
SetInputBoxText Proto :DWord
	;SetInputBoxText Proc szAddrValue:DWord
GetInputBoxText Proto
	;GetInputBoxText Proc
GetInputBoxInt Proto :BOOL
	;GetInputBoxInt Proc bSigned:BOOL
CloseInputBox Proto
	;CloseInputBox Proc
