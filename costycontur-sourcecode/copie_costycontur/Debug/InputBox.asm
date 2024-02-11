      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
WinMain Proto
WndProc Proto :DWord, :DWord, :DWord, :DWord
Paint_Proc Proto :DWord, :DWord
Frame3D Proto :DWord, :DWord,:DWord,:DWord,:DWord,:DWord,:DWord,:DWord
FrameCtrl PROTO :DWORD,:DWORD,:DWORD,:DWORD
FrameWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD

; ----------------------------------
; These are the two controls used on
; the client area of the window
; ----------------------------------
EditSl Proto  :DWord, :DWord, :DWord, :DWord, :DWord, :DWord, :DWord
PushButton Proto :DWord, :DWord, :DWord, :DWord, :DWord, :DWord, :DWord

InputBox Proto :DWord, :DWord
InputBoxPos Proto :DWord, :DWord, :DWord, :DWord
InputBoxWin	Proto :HWND, :DWord, :DWord
SetInputBoxInt Proto :DWord, :BOOL
SetInputBoxText Proto :DWord
GetInputBoxText Proto
GetInputBoxInt Proto :BOOL
CloseInputBox Proto

.Const

.Data?
;Buffer input box text
_inputBoxText		DB 1024 Dup(?)

;Buffer input box int
_inputBoxInt		DD ?

;Buffer dummy
_dummyBuffer		DB 1024 Dup(?)

;Request Args
_reqCallBack 	DD ?
_reqArg1		DD ?
_reqArg2		DD ?
_reqArg3		DD ?

.Data
;Despre
szDespreTitlu DB "Marius InputBox v0.2 - [4:49 AM 6/18/2012]", 0
szDespre 	  DB "http://costycnc.xhost.ro/", 13, 10, 13, 10
			  DB "InputBox   Proc szAddrTitlu:DWord, addrCallback:DWord", 13, 10
			  DB "InputBoxPos    Proc szAddrTitlu:DWord, addrCallback:DWord, nX:DWord, nY:DWord", 13, 10
			  DB "InputBoxWin    Proc :hWindow, szAddrTitlu:DWord, addrRetPoint:DWord", 13, 10
			  DB "SetInputBoxInt    Proc nValue:DWord, bSigned:BOOL", 13, 10
			  DB "SetInputBoxText    Proc szAddrValue:DWord", 13, 10
			  DB "GetInputBoxText    Proc", 13, 10
			  DB "GetInputBoxInt    Proc bSigned:BOOL", 13, 10
			  DB "CloseInputBox    Proc", 13, 10, 13, 10
			  DB "InputBoxWin rets: .x -> uNr, .y -> strAddr", 0

;Fereastra
szDisplayName DB "Marius Input Box v0.1", 0
szClassName	  DB "CMarius_irdiodaATyahooDOTcom", 0

;Meniu Despre
szMenuAboutName DB "Despre o_0 [i]", 0

;Handeluri
hInstIB		  DD 0
hWndIB        DD 0
hMenu		  DD 0
hEdit1        DD 0
hButn1        DD 0
hFont         DD 0

BtnSetID	  DD 500
TxtSetID      DD 700
IconID		  DD 900
MnuAboutID	  DD 202

_InputBoxCallbackProc DD 0

_reqArg4		DD 0
_reqArg5		DD 0
_reqArg6		DD 0

stMenuInfoIB	MENUITEMINFO <>
patratIB		RECT <>

.Code

; #########################################################################

WinMain Proc

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        Local Wtx:DWord
        LOCAL Wty  :DWORD

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================
		Invoke GetModuleHandle, NULL
		Mov hInstIB, Eax

        mov wc.cbSize,         sizeof WNDCLASSEX
        Mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               Or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance, hInstIB   ;<< NOTE: macro not mnemonic
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName
          ;Invoke LoadIcon, hInstIB, IconID    ; icon ID
        Mov wc.hIcon, 0 ;eax
          invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc

        ;================================
        ; Centre window at following size
        ;================================

        Mov Wwd, 155
        Mov Wht, 90

        Invoke GetSystemMetrics, SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        Mov Wty, Eax

        Invoke CreateWindowEx, WS_EX_LEFT,
                              Addr szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPED or WS_SYSMENU,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInstIB, NULL
        Mov hWndIB, Eax

        Invoke GetSystemMenu, hWndIB, FALSE
        Mov hMenu, Eax
        Invoke DeleteMenu, hMenu, 0, MF_BYPOSITION
        Invoke DeleteMenu, hMenu, 1, MF_BYPOSITION
        Invoke DeleteMenu, hMenu, 1, MF_BYPOSITION
        Invoke DeleteMenu, hMenu, 1, MF_BYPOSITION

		Mov Eax, SizeOf stMenuInfoIB
		Mov stMenuInfoIB.cbSize, Eax
		Mov stMenuInfoIB.fMask, MIIM_STATE Or MIIM_ID Or MIIM_TYPE
		Mov stMenuInfoIB.fState, MFS_ENABLED
		Mov stMenuInfoIB.hSubMenu, NULL
		Mov stMenuInfoIB.hbmpChecked, NULL
		Mov stMenuInfoIB.hbmpUnchecked, NULL
		;Mov Eax, Offset szClassName
		Mov stMenuInfoIB.dwItemData, NULL
		Mov Eax, Offset szMenuAboutName
		Mov stMenuInfoIB.dwTypeData, Eax
		Mov Eax, SizeOf szMenuAboutName
		Mov stMenuInfoIB.cch, Eax

		Mov Eax, MnuAboutID
		Mov stMenuInfoIB.wID, Eax
		Mov stMenuInfoIB.fMask, MIIM_STATE Or MIIM_ID Or MIIM_TYPE
		Mov stMenuInfoIB.fType, MFT_STRING
        Invoke InsertMenuItem, hMenu, 0, TRUE, Addr stMenuInfoIB

		Mov Eax, MnuAboutID
		Inc Eax
		Mov stMenuInfoIB.wID, Eax
		Mov stMenuInfoIB.fType, MIIM_ID Or MIIM_TYPE
		Mov stMenuInfoIB.fType, MFT_SEPARATOR
        Invoke InsertMenuItem, hMenu, 1, TRUE, Addr stMenuInfoIB

		Call _reqCallBack
		.If !_reqArg6
			Invoke SetDlgItemInt, hWndIB, TxtSetID, _reqArg4, _reqArg5
		.Else
			Invoke SetDlgItemText, hWndIB, TxtSetID, _reqArg6
		.EndIf

        Invoke ShowWindow, hWndIB, SW_SHOWNORMAL
        Invoke GetWindowRect, hWndIB, Addr patratIB
		Invoke SetWindowPos, hWndIB, HWND_TOPMOST, patratIB.left, patratIB.top, 0, 0, SWP_NOSIZE
        Invoke UpdateWindow, hWndIB

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain EndP

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL hDC  :DWORD
    LOCAL Ps   :PAINTSTRUCT

    .If uMsg == WM_COMMAND
    	Mov Eax, BtnSetID
        .If wParam == Eax  ;<<<< The button
            .If _InputBoxCallbackProc
            	Invoke ShowWindow, hWndIB, FALSE

				Mov Eax, Offset _InputBoxWin
				.If _reqCallBack != Eax
					Call _InputBoxCallbackProc
				.EndIf

				Invoke SendMessage, hWin, WM_CLOSE, 0, 0
			.EndIf
		.EndIf

	.ElseIf uMsg == WM_SYSCOMMAND
		Mov Eax, MnuAboutID
		.If wParam == Eax
			Invoke MessageBox, hWndIB, Addr szDespre, Addr szDespreTitlu, 0
		.EndIf

    .ElseIf uMsg == WM_CREATE
        szText font1, "Tahoma"
        Invoke CreateFont, 14, 5, 0, 0, 500, 0, 0, 0, DEFAULT_CHARSET, 0, 0, 0, DEFAULT_PITCH, Addr font1
        Mov hFont, Eax

        szText adrTxt, 0
        Invoke EditSl, Addr adrTxt, 5, 5, 140, 23, hWin, TxtSetID
        Mov hEdit1, Eax

        szText ButnTxt, "Seteaza"
        Invoke PushButton, Addr ButnTxt, hWin, 25, 30, 100, 25, BtnSetID
        Mov hButn1, Eax

    .elseif uMsg == WM_PAINT
        Invoke BeginPaint,hWin,Addr Ps
         ; mov hDC, eax
         ; invoke Paint_Proc,hWin,hDC
        Invoke EndPaint,hWin,Addr Ps
        return 0

	.ElseIf uMsg == WM_KEYUP
		.If wParam == VK_ESCAPE
			Invoke SendMessage, hWndIB, WM_CLOSE, 0, 0
		.ElseIf wParam == VK_RETURN
			Invoke SendMessage, hWndIB, WM_COMMAND, BtnSetID, 0
		.EndIf

    .elseif uMsg == WM_CLOSE
        Invoke DeleteObject, hFont

		Mov Eax, Offset _InputBoxWin
		.If _reqCallBack == Eax
			Invoke EnableWindow, _reqArg1, TRUE
			Call _InputBoxCallbackProc
		.EndIf

	   	Mov hWndIB, 0

    .ElseIf uMsg == WM_DESTROY
        Invoke PostQuitMessage, NULL
		Return 0

    .EndIf

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

PushButton Proc lpText:DWord, hParent:DWord,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke PushButton,ADDR szText,hWnd,20,20,100,25,500

    LOCAL hndle:DWORD

    szText btnClass,"BUTTON"

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstIB, NULL

    mov hndle, eax

    invoke SendMessage,hndle,WM_SETFONT,hFont, 0

    mov eax, hndle

    ret

PushButton EndP

; ########################################################################

EditSl Proc szMsg:DWord,a:DWord,b:DWord,
               wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

; EditSl PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke EditSl,ADDR adrTxt,200,10,150,25,hWnd,700

    LOCAL hndle:DWORD

    szText slEdit,"EDIT"

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR slEdit,szMsg,
                WS_VISIBLE or WS_CHILDWINDOW or \
                ES_AUTOHSCROLL or ES_NOHIDESEL,
              a, b, wd, ht, hParent, ID, hInstIB, NULL

    mov hndle, eax

    invoke SendMessage,hndle,WM_SETFONT,hFont,1

    mov eax, hndle

    ret

EditSl endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY EndP

InputBox Proc szAddrTitlu:DWord, addrCallback:DWord
	.If !hWndIB
		Mov Eax, addrCallback
		Mov _InputBoxCallbackProc, Eax

		Mov Eax, Offset _InputBox
		Mov _reqCallBack, Eax

		Mov Eax, szAddrTitlu
		Mov _reqArg1, Eax

		Invoke WinMain
	.EndIf

	Ret
InputBox EndP

_InputBox Proc
	Invoke SetWindowText, hWndIB, _reqArg1
	Ret
_InputBox EndP

InputBoxPos Proc szAddrTitlu:DWord, addrCallback:DWord, nX:DWord, nY:DWord
	.If !hWndIB
		Mov Eax, addrCallback
		Mov _InputBoxCallbackProc, Eax

		Mov Eax, Offset _InputBoxPos
		Mov _reqCallBack, Eax

		Mov Eax, szAddrTitlu
		Mov _reqArg1, Eax
		Mov Eax, nX
		Mov _reqArg2, Eax
		Mov Eax, nY
		Mov _reqArg3, Eax

		Invoke WinMain
	.EndIf

	Ret
InputBoxPos EndP

_InputBoxPos Proc
	Invoke SetWindowText, hWndIB, _reqArg1
	Invoke SetWindowPos, hWndIB, HWND_TOPMOST, _reqArg2, _reqArg3, 155, 90, SWP_SHOWWINDOW
	Ret
_InputBoxPos EndP

InputBoxWin Proc hWindow:HWND, szAddrTitlu:DWord, addrRetPoint:DWord
	.If !hWndIB
		Mov Eax, Offset _InputBoxWin
		Mov _reqCallBack, Eax

		Mov Eax, Offset _InputBoxWin2
		Mov _InputBoxCallbackProc, Eax

		Mov Eax, hWindow
		Mov _reqArg1, Eax
		Mov Eax, szAddrTitlu
		Mov _reqArg2, Eax

		Mov Eax, addrRetPoint
		Mov _reqArg3, Eax

		Invoke WinMain
	.EndIf

	Ret
InputBoxWin EndP

_InputBoxWin Proc
	Invoke SetWindowText, hWndIB, _reqArg2
	Invoke EnableWindow, _reqArg1, FALSE
	Ret
_InputBoxWin EndP

_InputBoxWin2 Proc
	Invoke EnableWindow, _reqArg1, TRUE
	Invoke SetForegroundWindow, _reqArg1

	.If _reqArg3
		;eax: nr
		;ebx; addr string
		Invoke GetInputBoxInt, 0
		Mov Ebx, _reqArg3
		Mov [Ebx], Eax

		Invoke GetInputBoxText
		Mov Ebx, _reqArg3
		Mov [Ebx + 4], Eax
	.EndIf

	Ret
_InputBoxWin2 EndP


SetInputBoxInt Proc nValue:DWord, bSigned:BOOL
	.If hWndIB
		Invoke SetDlgItemInt, hWndIB, TxtSetID, nValue, bSigned
	.Else
		Mov Eax, nValue
		Mov _reqArg4, Eax
		Mov Eax, bSigned
		Mov _reqArg5, Eax
		Mov _reqArg6, 0
	.EndIf
	Ret
SetInputBoxInt EndP

SetInputBoxText Proc szAddrValue:DWord
	.If hWndIB
		Invoke SetDlgItemText, hWndIB, TxtSetID, szAddrValue
	.Else
		Mov _reqArg4, 0
		Mov _reqArg5, 0
		Mov Eax, szAddrValue
		Mov _reqArg6, Eax
	.EndIf

	Ret
SetInputBoxText EndP

GetInputBoxText Proc
	Invoke GolesteString, Addr _inputBoxText, 1024
	Invoke GetDlgItem, hWndIB, TxtSetID
	Invoke GetWindowTextLength, Eax
	Invoke GetDlgItemText, hWndIB, TxtSetID, Addr _inputBoxText, Eax
	Mov Eax, Offset _inputBoxText
	Ret
GetInputBoxText EndP

GetInputBoxInt Proc bSigned:BOOL
	Invoke GetDlgItemInt, hWndIB, TxtSetID, Addr _dummyBuffer, bSigned
	Mov _inputBoxInt, Eax
	Ret
GetInputBoxInt EndP

CloseInputBox Proc
	Invoke SendMessage, hWndIB, WM_CLOSE, 0, 0
	Ret
CloseInputBox EndP
