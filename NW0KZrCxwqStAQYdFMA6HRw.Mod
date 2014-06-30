MODULE NW0KZrCxwqStAQYdFMA6HRw;
IMPORT Base, TexVox;

VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'escherfiretile0.png')  END;
	RETURN vox
END thisvox;

 END NW0KZrCxwqStAQYdFMA6HRw. 