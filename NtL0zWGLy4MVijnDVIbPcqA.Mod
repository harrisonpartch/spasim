MODULE NtL0zWGLy4MVijnDVIbPcqA;
IMPORT Base, TexVox;
PROCEDURE thisvox*():Base.Voxel;
VAR
	vox: TexVox.TexVox;
BEGIN
	NEW(vox,'whiteblock.png'); 
	RETURN vox
END thisvox; END NtL0zWGLy4MVijnDVIbPcqA.