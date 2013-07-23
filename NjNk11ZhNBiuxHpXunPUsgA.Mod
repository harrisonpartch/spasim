MODULE NjNk11ZhNBiuxHpXunPUsgA;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M2.cell;
BEGIN
	NEW(vox); 
	vox.setcolor(0,0,0,3,0);
	RETURN vox
END thisvox;
 END NjNk11ZhNBiuxHpXunPUsgA. 