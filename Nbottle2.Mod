MODULE Nbottle2;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'bottle2.png')  END;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END Nbottle2. 