MODULE NuDxZaSfDCnI8xZnbp6c5ew;(*anonymous module created by saboteur*)
  
IMPORT Base, TexVox ;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'cthulhu.png')  END;
	RETURN vox
END thisvox;

 END NuDxZaSfDCnI8xZnbp6c5ew. 