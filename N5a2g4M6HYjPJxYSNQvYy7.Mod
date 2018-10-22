MODULE N5a2g4M6HYjPJxYSNQvYy7;(*anonymous module created by saboteur*)
 
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'sky.png')  END;
	RETURN vox
END thisvox;

 END N5a2g4M6HYjPJxYSNQvYy7. 