;EasyCodeName=GolesteString,1
.Code
GolesteString Proc sString:DWord, sLungimeBytes:DWord
	Mov Eax, sString
	Mov Ebx, 0
	Mov Ecx, 0
ResetLogBuffer:
	Mov [Eax + Ecx], Ebx
	Add Ecx, 8
	Cmp Ecx, sLungimeBytes
	Jbe ResetLogBuffer

	Ret
GolesteString EndP
