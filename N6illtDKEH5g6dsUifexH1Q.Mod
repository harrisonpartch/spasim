MODULE N6illtDKEH5g6dsUifexH1Q;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'europia.png')  END;
	RETURN vox
END thisvox;

 END N6illtDKEH5g6dsUifexH1Q. 