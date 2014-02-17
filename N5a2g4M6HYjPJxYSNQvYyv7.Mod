MODULE N5a2g4M6HYjPJxYSNQvYyv7;(*anonymous module created by saboteur*)
 
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"lorde.png"); vox.tscale:=100  END;
	
	RETURN vox
END thisvox;

 END N5a2g4M6HYjPJxYSNQvYyv7. 