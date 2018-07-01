MODULE SPSME;
IMPORT SYSTEM, Base;

(* procedure for casting real array to integer array. From Patrik Reali ETHZ 2000*)


PROCEDURE E*(VAR p: Base.PT; VAR ijk: Base.IPT);

BEGIN
	ijk.i:=SHORT(ENTIER(p.x)); ijk.j:=SHORT(ENTIER(p.y)); ijk.k:=SHORT(ENTIER(p.z));
END E;

(*

PROCEDURE E*(VAR p: Base.PT; VAR ijk: Base.IPT);
VAR
	in: ARRAY 3 OF REAL;
	out: ARRAY 3 OF INTEGER;
BEGIN
	in[0]:=p.x;in[1]:=p.y; in[2]:=p.z;
	Eprime(in,out);
	ijk.i:=out[0]; ijk.j:=out[1]; ijk.k:=out[2];
END E;

PROCEDURE Eprime(VAR in:ARRAY OF REAL; VAR out: ARRAY OF INTEGER);
CODE {SYSTEM.i386, SYSTEM.FPU}
   MOV   EDI, [EBP+8]         ; dest   = ADR(out)
   MOV   ECX, [EBP+12]       ; count  = LEN(out)
   MOV   ESI, [EBP+16]        ; source = ADR(in)
   CMP   ECX, [EBP+20]
   JGE   Ok
   PUSH  99                  ; LEN(in) > LEN(out)  then TRAP(99)
   INT   3
Ok:
   SUB   ESP, 8              ; change FPU rounding to "chop"
   FSTCW [ESP]
   FWAIT
   MOV   EBX, [ESP]
   OR    EBX, 0400H          ; clear bit 10,11 (chop/truncate toward zero)
   MOV   [ESP+4], EBX
   FLDCW [ESP+4]
   JMP   Check
Loop:
   DEC   ECX
   FLD   DWORD [ESI+ECX*4]  ; in: REAL
   FISTP WORD [EDI+ECX*2]   ; out: INTEGER
   FWAIT
Check:
   CMP   ECX, 0
   JG    Loop
   FLDCW [ESP]               ; restore original FPU configuration
   ADD   ESP, 8
END Eprime;

PROCEDURE E2*(in: Base.PT; VAR out: Base.IPT);
(*
BEGIN
	ROUND(in[0], out[0]);
	ROUND(in[1], out[1]);
	ROUND(in[2], out[2]); *)
END E2;

(* PROCEDURE ROUND(x: REAL; VAR y: LONGINT);
CODE {SYSTEM.i386, SYSTEM.FPU}
       FLD x[EBP]
       MOV EAX, y[EBP]
       FISTP DWORD 0[EAX]
END ROUND;

PROCEDURE ROUND(x: LONGREAL; VAR y: LONGINT);
CODE {SYSTEM.i386, SYSTEM.FPU}
       FLD [EBP+x]
       MOV EAX, [EBP+y]
       FISTP DWORD [EAX]
END ROUND; *)

PROCEDURE -ROUND*(x: REAL; VAR y: LONGINT);
CODE {SYSTEM.i386, SYSTEM.FPU}
       POP EAX
       FLD DWORD [EBP]
       ADD ESP, 4
       FISTP DWORD [EAX]
END ROUND;

(* PROCEDURE -ROUND(x: LONGREAL; VAR y: LONGINT);
CODE {SYSTEM.i386, SYSTEM.FPU}
       POP EAX
       FLD QWORD [EBP]
       ADD ESP, 8
       FISTP DWORD [EAX]
END ROUND;
*)
*)

END SPSME.

