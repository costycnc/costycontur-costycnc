;EasyCodeName=InsertSysMenu,1
.Const

.Data?

.Data

stMenuInfo	MENUITEMINFO <>

.Code

InsertSysMenu Proc, hWnd:DWord, nPos:DWord, nID:DWord, szAddrString:DWord
Local hParentMenu:HANDLE

	Invoke GetSystemMenu, hWnd, FALSE
	Mov hParentMenu, Eax

	Mov Eax, SizeOf stMenuInfo
	Mov stMenuInfo.cbSize, Eax
	Mov stMenuInfo.fMask, MIIM_STATE Or MIIM_ID Or MIIM_TYPE
	Mov stMenuInfo.fState, MFS_ENABLED
	Mov stMenuInfo.hSubMenu, NULL
	Mov stMenuInfo.hbmpChecked, NULL
	Mov stMenuInfo.hbmpUnchecked, NULL
	;Mov Eax, Offset szClassName
	Mov stMenuInfo.dwItemData, NULL
	Mov Eax, szAddrString
	Mov stMenuInfo.dwTypeData, Eax
;	Mov Eax, nTextLength
;	Mov stMenuInfo.cch, Eax
	Mov Eax, nID
	Mov stMenuInfo.wID, Eax

	.If !szAddrString
		Mov stMenuInfo.fType, MIIM_ID Or MIIM_TYPE
		Mov stMenuInfo.fType, MFT_SEPARATOR
	.Else
		Mov stMenuInfo.fMask, MIIM_STATE Or MIIM_ID Or MIIM_TYPE
		Mov stMenuInfo.fType, MFT_STRING
	.EndIf

    Invoke InsertMenuItem, hParentMenu, nPos, TRUE, Addr stMenuInfo

	Ret
InsertSysMenu EndP
