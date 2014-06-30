MODULE NFLOOP;(*anonymous module created by saboteur*)
 
IMPORT Base,TexVox;
VAR vox: TexVox.FloopVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"ket.mpg");
	vox.tscale:=50;
	vox.copyonstroke:=FALSE
END NFLOOP. 