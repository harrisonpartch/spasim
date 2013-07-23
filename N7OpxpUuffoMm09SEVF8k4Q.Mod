MODULE N7OpxpUuffoMm09SEVF8k4Q;
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'diefive.png')  END;
	RETURN vox
END thisvox;

 END N7OpxpUuffoMm09SEVF8k4Q. 