MODULE Narevclock;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'arevclock.png')  END;
	vox.tscale:=81;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Narevclock. 