MODULE NJOFc7qhMXMly3lot71bNUw;
IMPORT  Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"rock.png")  END;
	vox.tscale:=10000;
	RETURN vox
END thisvox;

 END NJOFc7qhMXMly3lot71bNUw.  