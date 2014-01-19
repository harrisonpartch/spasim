MODULE N5a2g4M6HYjPJxYSNQvYyvw;(*anonymous module created by saboteur*)
 
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"alice.png"); vox.lock()  END;
	vox.tscale:=100;
	RETURN vox
END thisvox;

 END N5a2g4M6HYjPJxYSNQvYyvw. 