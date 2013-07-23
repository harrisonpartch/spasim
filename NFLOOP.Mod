MODULE NFLOOP;(*anonymous module created by saboteur*)
 
IMPORT Base,TexVox;
VAR vox: TexVox.FloopVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,"pdome.mpg");
	vox.copyonstroke:=TRUE;
	RETURN vox
END thisvox;
END NFLOOP. 