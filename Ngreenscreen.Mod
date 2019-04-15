MODULE Ngreenscreen;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'greenscreen.png')  END;
	vox.tscale:=64;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Ngreenscreen. 