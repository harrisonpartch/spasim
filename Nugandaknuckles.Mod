MODULE Nugandaknuckles;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"ugandaknuckles.png");
	vox.tscale:=500;  
	vox.passable:=TRUE;
END Nugandaknuckles. 