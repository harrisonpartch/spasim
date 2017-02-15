MODULE Nreddot;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;
BEGIN
	NEW(vox,'armjourth.png');
	vox.tscale:=10
END Nreddot. 