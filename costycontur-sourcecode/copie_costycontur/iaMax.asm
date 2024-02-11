;EasyCodeName=iaMinMax,1
.Const

.Data?

.Data

.Code

iaMax Proc pArray:DWord, nMember:DWord
Local iMember:DWord

	Mov iMember, 0

	Mov Ecx, pArray
	Mov Eax, [Ecx]
startCMP:
 	Mov Ebx, [Ecx]
	Add Ecx, 4

	Cmp Eax, Ebx
	Jge primulEMare
	Mov Eax, Ebx
primulEMare:

	Inc iMember
	Mov Edx, nMember
	Cmp iMember, Edx
	Jne startCMP

	Ret
iaMax EndP

iaMin Proc pArray:DWord, nMember:DWord
Local iMember:DWord

	Mov iMember, 0

	Mov Ecx, pArray
	Mov Eax, [Ecx]
startCMP:
 	Mov Ebx, [Ecx]
	Add Ecx, 4

	Cmp Eax, Ebx
	Jbe primulEMare
	Mov Eax, Ebx
primulEMare:

	Inc iMember
	Mov Edx, nMember
	Cmp iMember, Edx
	Jne startCMP

	Ret
iaMin EndP