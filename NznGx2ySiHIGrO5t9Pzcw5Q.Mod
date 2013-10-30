MODULE NznGx2ySiHIGrO5t9Pzcw5Q;
IMPORT Base, TexVox;
  
VAR
	vox: TexVox.TexVox; 
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	IF vox=NIL THEN NEW(vox,"lobster.png");
	vox.tscale:=64
 END;
	RETURN vox
END thisvox;

 END NznGx2ySiHIGrO5t9Pzcw5Q. 