MODULE NOEsqXX7r2l7FZGfkcgoCXw;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
PROCEDURE thisvox*():XNXLBase.Voxel;
VAR
	vox: M2.cell;
BEGIN
	NEW(vox);
	vox.setcolor(0,0,0,10,0);
	RETURN vox
END thisvox; END NOEsqXX7r2l7FZGfkcgoCXw. 