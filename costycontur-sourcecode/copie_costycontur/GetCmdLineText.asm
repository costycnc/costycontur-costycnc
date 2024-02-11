;EasyCodeName=GetCmdLineText,1
.Const

.Data?
;Buffer
szCmdLineBuffer DB MAX_PATH Dup(?)

;Address of Command Line string
ComdLine			DD ?

.Data

.Code

GetCmdLineText Proc

	Invoke GetCommandLine
	Mov ComdLine, Eax

	Mov Eax, ComdLine
	Mov Ecx, 0
	Mov Edx, 1
inceputBucla:
	Mov Ebx, [Eax]
	Cmp Ebx, 022202265H	;" "
	Jne urmatorul
	Cmp Bl, 0
	Je sfarsit
	Inc Edx
	Add Eax, 4
	Mov Ecx, Eax
urmatorul:
	Cmp Bl, 0
	Je sfarsit
	Inc Eax
	Jmp inceputBucla
sfarsit:

	.If Edx == 1
		Mov Eax, 0
		Mov Ecx, 0
	.Else
		Mov Eax, Ecx
		Invoke szCatStr, Addr szCmdLineBuffer, Eax
		Mov Eax, Offset szCmdLineBuffer
		Mov Ecx, 0
startSZ:
		Inc Ecx
		Mov Ebx, [Eax]
		Cmp Ebx, 022H  ;"
		Je fa_stergere
		Inc Eax
		Jmp startSZ
fa_stergere:
		Mov Edx, 0
		Mov [Eax], Edx

		Mov Eax, Offset szCmdLineBuffer
	.EndIf
	
	Ret
GetCmdLineText EndP
