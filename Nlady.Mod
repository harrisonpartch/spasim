MODULE Nlady;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVoxNoMirror;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"lady.png");
	vox.tscale:=0;  
	vox.passable:=TRUE;
	vox.register;
END Nlady. 