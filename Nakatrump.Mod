MODULE Nakatrump;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"akatrump.png")  END;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Nakatrump. 