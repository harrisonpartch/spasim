MODULE NWdMWLJtPzMMIp2UEA2iYwQ;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'diethree.png')  END;
	RETURN vox
END thisvox;

 END NWdMWLJtPzMMIp2UEA2iYwQ. 