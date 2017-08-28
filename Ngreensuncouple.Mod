MODULE Ngreensuncouple;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'greensuncouple.png')  END;
	vox.tscale:=81;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Ngreensuncouple. 