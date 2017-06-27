MODULE NmOgKSH5ZXYP3DODELOkO7g;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'galaxy.png'); END;
	vox.tscale:=81;
	RETURN vox
END thisvox;

 END NmOgKSH5ZXYP3DODELOkO7g. 
