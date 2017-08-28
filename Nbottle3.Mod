MODULE Nbottle3;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'bottle3.png')  END;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

END Nbottle3. 