MODULE NFLOOP;(*anonymous module created by saboteur*)
 
IMPORT Base,TexVox;
VAR vox: TexVox.FloopVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"film/medley.mpeg",300000);
	vox.register
END NFLOOP. 

Marsh.Rez NFLOOP