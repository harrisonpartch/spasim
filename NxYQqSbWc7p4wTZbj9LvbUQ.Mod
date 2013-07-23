MODULE NxYQqSbWc7p4wTZbj9LvbUQ;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'dietwo.png')  END;
	RETURN vox
END thisvox;

 END NxYQqSbWc7p4wTZbj9LvbUQ. 