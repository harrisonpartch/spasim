MODULE No13s7eEq5z1VzXOucrDZiw;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'dieone.png')  END;
	RETURN vox
END thisvox;

 END No13s7eEq5z1VzXOucrDZiw. 