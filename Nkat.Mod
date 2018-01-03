MODULE Nkat;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"fractaljackal.png")  END;
	vox.tscale:=81;
	RETURN vox
END thisvox;

END Nkat. 