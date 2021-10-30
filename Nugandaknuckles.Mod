MODULE Nugandaknuckles;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"ugandaknuckles.png"); 
	vox.passable:=FALSE;
END Nugandaknuckles. 

WMRender.Mod