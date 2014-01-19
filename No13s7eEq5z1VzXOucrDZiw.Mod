MODULE No13s7eEq5z1VzXOucrDZiw;IMPORT Base, TexVox ;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'dieone.png')  END;
	RETURN vox
END thisvox;

 END No13s7eEq5z1VzXOucrDZiw. 