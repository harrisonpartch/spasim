MODULE Nbottlepossum;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'bottlepossum.png')  END;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Nbottlepossum. 