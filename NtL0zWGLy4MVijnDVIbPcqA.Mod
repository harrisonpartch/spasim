MODULE NtL0zWGLy4MVijnDVIbPcqA;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
PROCEDURE thisvox*():XNXLBase.Voxel;
VAR
	vox: XNXLTexVox.TexVox;
BEGIN
	NEW(vox,'XNXL.dotz.png'); 
	RETURN vox
END thisvox; END NtL0zWGLy4MVijnDVIbPcqA.