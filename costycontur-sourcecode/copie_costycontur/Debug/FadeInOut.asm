.Const

.Data?

.Data

fadeRect RECT <>

.Code

FadeIn Proc hWndTarget:HWND, bFastSlow:BOOL
Local i:DWord
Local hDC:DWord
Local nLongOld:DWord
Local n:DWord

	Mov i, 1
	.If !bFastSlow
		Mov n, 5
	.Else
		Mov n, 15
	.EndIf

	Invoke GetWindowLong, hWndTarget, GWL_EXSTYLE
	Mov nLongOld, Eax
	Or Eax, WS_EX_LAYERED
	Invoke SetWindowLong, hWndTarget, GWL_EXSTYLE, Eax

	Invoke SetLayeredWindowAttributes, hWndTarget, 10, 1, LWA_ALPHA
	Invoke ShowWindow, hWndTarget, SW_SHOW

	.Repeat
		Invoke SetLayeredWindowAttributes, hWndTarget, 10, i, LWA_ALPHA
		Invoke UpdateWindow, hWndTarget
		Invoke Sleep, 10
	Mov Eax, n
	Add i, Eax
	.Until i >= 255

	Invoke SetLayeredWindowAttributes, hWndTarget, 10, 255, LWA_ALPHA
	Invoke SetWindowLong, hWndTarget, GWL_EXSTYLE, nLongOld

	Ret
FadeIn EndP

FadeOut Proc hWndTarget:HWND, bFastSlow:DWord
Local i:DWord
Local hDC:DWord
Local nLongOld:DWord
Local n:DWord

	Mov i, 255
	.If !bFastSlow
		Mov n, 5
	.Else
		Mov n, 15
	.EndIf

	Invoke GetWindowLong, hWndTarget, GWL_EXSTYLE
	Mov nLongOld, Eax

	Or Eax, WS_EX_LAYERED
	.If Eax != nLongOld
		Invoke SetWindowLong, hWndTarget, GWL_EXSTYLE, Eax
	.EndIf

	.Repeat
		Invoke SetLayeredWindowAttributes, hWndTarget, 10, i, LWA_ALPHA
		Invoke UpdateWindow, hWndTarget
		Invoke Sleep, 10
	Mov Eax, n
	Sub i, Eax
	.Until i <= Eax

	Invoke SetLayeredWindowAttributes, hWndTarget, 10, 1, LWA_ALPHA
	;Invoke SetWindowLong, hWndTarget, GWL_EXSTYLE, nLongOld

	Ret
FadeOut EndP

;RoundFadeIn Proc hWnd:HWND
;Local i:DWord
;Local CurX:DWord
;Local CurY:DWord

;	Mov i, 0

;	Invoke GetWindowRect, hWnd, Addr fadeRect
;	Mov Eax, fadeRect.right
;	Mov Edx, fadeRect.left
;	Sub Eax, Edx
;	Mov CurX, Eax
;	Mov Edx, 0
;	Mov Eax, CurX
;	Mov Ebx, 2
;	Div Ebx
;	Mov CurX, Eax

;	Mov Eax, fadeRect.bottom
;	Mov Edx, fadeRect.top
;	Sub Eax, Edx
;	Mov CurY, Eax
;	Mov Edx, 0
;	Mov Eax, CurY
;	Mov Ebx, 2
;	Div Ebx
;	Mov CurY, Eax

;	.Repeat
;		.If i == 1
;			Invoke ShowWindow, hWnd, SW_SHOW
;		.EndIf
;		Mov Eax, CurX
;		Mov Ebx, i
;		Add Ebx, 5
;		Sub Eax, Ebx
;		Mov fadeRect.left, Eax

;		Mov Eax, CurX
;		Mov Ebx, i
;		Add Ebx, 5
;		Add Eax, Ebx
;		Mov fadeRect.right, Eax

;		Mov Eax, CurY
;		Mov Ebx, i
;		Add Ebx, 5		
;		Sub Eax, Ebx
;		Mov fadeRect.top, Eax

;		Mov Eax, CurY
;		Mov Ebx, i
;		Add Ebx, 5		
;		Add Eax, Ebx
;		Mov fadeRect.bottom, Eax
;		Invoke CreateEllipticRgn, fadeRect.left, fadeRect.top, fadeRect.right, fadeRect.bottom
;		Invoke SetWindowRgn, hWnd, Eax, 1
;		Invoke UpdateWindow, hWnd
;		;Invoke Sleep, 10

;	Inc i
;	Mov Eax, i
;	.Until fadeRect.left == -45

;	Ret
;RoundFadeIn EndP

;RoundFadeOut Proc hWnd:HWND
;Local i:DWord
;Local CurX:DWord
;Local CurY:DWord

;	Mov i, 0

;	Invoke ShowWindow, hWnd, SW_SHOW

;	Invoke GetWindowRect, hWnd, Addr fadeRect
;	Mov Eax, fadeRect.right
;	Mov Edx, fadeRect.left
;	Sub Eax, Edx
;	Mov CurX, Eax
;	Mov fadeRect.right, Eax
;	Mov Edx, 0
;	Mov Eax, CurX
;	Mov Ebx, 2
;	Div Ebx
;	Mov CurX, Eax
;	Mov Eax, fadeRect.bottom
;	Mov Edx, fadeRect.top
;	Sub Eax, Edx
;	Mov CurY, Eax
;	Mov fadeRect.bottom, Eax
;	Mov Edx, 0
;	Mov Eax, CurY
;	Mov Ebx, 2
;	Div Ebx
;	Mov CurY, Eax

;	Move fadeRect.left, 0
;	Move fadeRect.top, 0

;	.Repeat
;		Mov Eax, fadeRect.left
;		;Mov Ebx, i
;;		Add Ebx, 2
;		Add Eax, 2
;		Mov fadeRect.left, Eax

;		Mov Eax, fadeRect.right
;		;Mov Ebx, i
;		;Sub Ebx, 2
;		Sub Eax, 2
;		Mov fadeRect.right, Eax

;		Mov Eax, fadeRect.top
;		;Mov Ebx, i
;		;Add Ebx, 2
;		Add Eax, 2
;		Mov fadeRect.top, Eax

;		Mov Eax, fadeRect.bottom
;		;Mov Ebx, i
;		;Add Ebx, 2
;		Sub Eax, 2
;		Mov fadeRect.bottom, Eax

;		;Invoke CreateRectRgn, 100, 100, 200, 200
;		Invoke CreateEllipticRgn, fadeRect.left, fadeRect.top, fadeRect.right, fadeRect.bottom
;		Invoke SetWindowRgn, hWnd, Eax, 1
;		Invoke UpdateWindow, hWnd
;		Invoke Sleep, 10

;	Inc i
;	Mov Eax, CurX
;	.Until fadeRect.left >= Eax



;	Ret
;RoundFadeOut EndP
