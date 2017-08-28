MODULE Nbottle1;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'bottle1.png')  END;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END Nbottle1. 