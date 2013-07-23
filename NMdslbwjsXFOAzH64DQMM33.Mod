MODULE NMdslbwjsXFOAzH64DQMM33
;IMPORT XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M3.torus;
BEGIN
	NEW(vox); 
	RETURN vox
END thisvox;
 END NMdslbwjsXFOAzH64DQMM33. 