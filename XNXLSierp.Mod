MODULE XNXLSierp;
IMPORT Base, XNXLM3Space, Random;

TYPE PT = Base.PT;
TYPE Color = Base.Color;
TYPE Ray = Base.Ray;
TYPE Voxel = Base.Voxel;

TYPE cell*=OBJECT(XNXLM3Space.cell);
	
PROCEDURE sierp*(solid,hole: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	fill(solid);
	blox[1,1,0]:=hole;
	blox[1,1,2]:=hole;
	blox[0,1,1]:=hole;
	blox[2,1,1]:=hole;
	blox[1,0,1]:=hole;
	blox[1,2,1]:=hole;
	blox[1,1,1]:=hole;	
END sierp;

PROCEDURE sierptop*(solid,bump,hole: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i :=0 TO 2 DO FOR j:=0 TO 2 DO FOR k:=0 TO 2 DO
		blox[i,j,k]:=solid
	END END END; 
	FOR i :=0 TO 2 DO FOR j:=0 TO 2 DO FOR k:= 1 TO 1 DO
		blox[i,j,k]:=hole
	END END END; 	
	blox[1,1,1]:=bump
END sierptop;

PROCEDURE tick;
VAR	
	v:Voxel;
	a,b,c,d,e,f:LONGINT;

BEGIN
	a:=rand.Dice(3);
	b:=rand.Dice(3);	
	c:=rand.Dice(3);	
	d:=rand.Dice(3);	
	e:=rand.Dice(3);	
	f:=rand.Dice(3);	
	v:=blox[a,b,c];
	blox[a,b,c]:=blox[d,e,f];
	blox[d,e,f]:=v
END tick;

PROCEDURE passprobe*(p:PT):BOOLEAN;
BEGIN
	RETURN FALSE
END passprobe;

END cell;

VAR
	rand: Random.Generator;
BEGIN
	NEW(rand);
END XNXLSierp.