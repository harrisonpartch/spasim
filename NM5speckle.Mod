MODULE NM5speckle;(*anonymous module created by saboteur*)
IMPORT Base, NM2;

TYPE speckle=OBJECT(NM2.cell);

VAR
	speck,vu: Base.Voxel;

PROCEDURE tick;
VAR
	i: LONGINT;
BEGIN
	FOR i:=0 TO 10 DO
		stroke(Base.randPT(),5,Base.EMPTY,vu);
	END;	
	FOR i:=0 TO 100 DO
		stroke(Base.randPT(),25,speck,vu);
	END;	
END tick;

BEGIN
	speck:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667"); 
	register;
END speckle; 

VAR
	vox: speckle;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox);  END;
	RETURN vox
END thisvox;

 END NM5speckle. 