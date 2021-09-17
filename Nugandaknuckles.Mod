MODULE Nugandaknuckles;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"foxbreadtemplate.png");
	vox.tscale:=1;  
	vox.passable:=TRUE;
END Nugandaknuckles. 