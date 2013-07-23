MODULE NnpPaNU5wEKlp0Ji1XWMhGg;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM2Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
PROCEDURE  thisvox*():XNXLBase.Voxel;
VAR
	vox:  M2.torus;
BEGIN
	NEW(vox); 
	vox.setcolor(0,0,0,3,0);
	RETURN vox
END thisvox;
 END NnpPaNU5wEKlp0Ji1XWMhGg. 