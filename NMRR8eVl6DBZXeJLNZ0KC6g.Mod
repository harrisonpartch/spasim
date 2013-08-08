MODULE NMRR8eVl6DBZXeJLNZ0KC6g;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'die.1.png')  END;
	RETURN vox
END thisvox;

 END NMRR8eVl6DBZXeJLNZ0KC6g. 