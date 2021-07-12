MODULE Nwstar;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'armchillecmt.png')  END;
	vox.tscale:=100;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Nwstar. 