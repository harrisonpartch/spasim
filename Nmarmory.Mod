MODULE Nmarmory;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'marmory.png')  END;
	vox.tscale:=64;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Nmarmory. 