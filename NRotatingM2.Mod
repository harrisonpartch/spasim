MODULE NRotatingM2;(*anonymous module created by saboteur [ideally] *)
  
IMPORT Base, NM2;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
TYPE rm2=OBJECT(NM2.cell);

PROCEDURE&init;
BEGIN
	register;
END init;

PROCEDURE tick;
BEGIN
	r90z;
END tick;

END rm2;
	
PROCEDURE thisvox*():Base.Voxel;
VAR
	v: rm2;
BEGIN
	NEW(v);
	RETURN v
END thisvox;

BEGIN

END NRotatingM2. 