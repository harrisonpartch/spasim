MODULE NMRR8eVl6DBZXeJLNZ0KC6g;
IMPORT Base:=XNXLBase, XNXLTexVox;
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'etile0.png')  END;
	RETURN vox
END thisvox;

 END NMRR8eVl6DBZXeJLNZ0KC6g. 