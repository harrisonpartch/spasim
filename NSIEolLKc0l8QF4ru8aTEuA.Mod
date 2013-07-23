MODULE NSIEolLKc0l8QF4ru8aTEuA;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  XNXLTexVox.TexVox;
BEGIN
	NEW(vox,'XNXL.dotz.png'); 
	vox.passable:=TRUE;
	RETURN vox
END thisvox; END NSIEolLKc0l8QF4ru8aTEuA.