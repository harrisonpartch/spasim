MODULE NiHWuC6tiaYe9Qxl3e1DNqw;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'etile2.png')  END;
	RETURN vox
END thisvox;

 END NiHWuC6tiaYe9Qxl3e1DNqw. 