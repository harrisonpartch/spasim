MODULE NSIEolLKc0l8QF4ru8aTEuA;

IMPORT Base, TexVox;
PROCEDURE  thisvox*():Base.Voxel;
VAR
	vox:  TexVox.TexVox;
BEGIN
	NEW(vox,'XNXL.dotz.png'); 
	vox.passable:=TRUE;
	RETURN vox
END thisvox; END NSIEolLKc0l8QF4ru8aTEuA.