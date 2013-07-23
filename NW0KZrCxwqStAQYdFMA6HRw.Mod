MODULE NW0KZrCxwqStAQYdFMA6HRw;IMPORT Math, XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'escherfiretile0.png')  END;
	RETURN vox
END thisvox;

 END NW0KZrCxwqStAQYdFMA6HRw. 