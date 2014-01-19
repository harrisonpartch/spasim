MODULE NNwW44Z6Y65O0pLKvYWsn3Q;
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'diefour.png')  END;
	RETURN vox
END thisvox;

 END NNwW44Z6Y65O0pLKvYWsn3Q. 