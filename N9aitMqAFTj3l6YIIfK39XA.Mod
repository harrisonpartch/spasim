MODULE N9aitMqAFTj3l6YIIfK39XA;
IMPORT Base, FRep;
  

VAR
	w2: Base.Voxel;
	ball: FRep.sphere;
	center: Base.PT;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	IF w2=NIL THEN
		NEW(w2);
		Base.setPT(center,1/2,1/2,1/2);
		NEW(ball,center,1/2);
		ball.setcolor(0,1,0,1);
		w2.FRaster(ball,17); 
		w2.lock;
		w2.frozen:= TRUE; (*engrain and sprout must not recurse inside w2*)
	END;
	w2.copyclear;
	w2.colored:=FALSE;
	RETURN w2
END thisvox;

 END N9aitMqAFTj3l6YIIfK39XA. 