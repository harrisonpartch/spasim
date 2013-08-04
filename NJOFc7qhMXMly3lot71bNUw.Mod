MODULE NJOFc7qhMXMly3lot71bNUw;
IMPORT  Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"hktarot.png")  END;
	RETURN vox
END thisvox;

 END NJOFc7qhMXMly3lot71bNUw.  