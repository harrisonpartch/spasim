MODULE Narchillect;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"archillect.png") END;
	RETURN vox
END thisvox;

END Narchillect. 