MODULE NFLOOP;(*anonymous module created by saboteur*)
 
IMPORT Base,TexVox;
VAR vox: TexVox.FloopVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"medley.mpeg",300000);
	vox.tscale:=27;
END NFLOOP. 

Marsh.Rez NFLOOP