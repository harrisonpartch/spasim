MODULE Njealouscthulhu;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'jealouscthulhu.png')  END;
	vox.tscale:=0;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Njealouscthulhu. 