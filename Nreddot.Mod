MODULE Nreddot;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;
BEGIN
	NEW(vox,'ravenmatrix.png');
	vox.tscale:=30
END Nreddot. 