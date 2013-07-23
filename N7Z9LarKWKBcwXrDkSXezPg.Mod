MODULE N7Z9LarKWKBcwXrDkSXezPg;

IMPORT Base:=Base, TexVox;  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'pigdestroyer.jpg')  END;
	RETURN vox
END thisvox;

 END N7Z9LarKWKBcwXrDkSXezPg. 