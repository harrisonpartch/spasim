MODULE NXEiQzXqJDWKQte5u3hATyA;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLFRep,  M3:=XNXLM2Space;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball: M3.cell;
	center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	XNXLBase.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,0.48);
	ball.setcolor(0,1,0.2);
	NEW(n3ball);
	n3ball.FRaster(ball,129);
END NXEiQzXqJDWKQte5u3hATyA. 