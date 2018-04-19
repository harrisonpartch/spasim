MODULE Ntensor;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'schoolgrilfred2.png')  END;
	vox.tscale:=0;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END Ntensor. 