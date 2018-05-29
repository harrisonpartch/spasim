MODULE Narkilekt;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"arkilekt.png")  END;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Narkilekt. 