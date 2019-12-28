MODULE Nwaterdrops;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"forest.png");
	vox.tscale:=180;  
END Nwaterdrops. 