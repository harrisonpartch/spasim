MODULE XNXLScrim;
IMPORT  XNXL, Base:=XNXLBase, Objects, Out:=KernelLog;

CONST	
	X=200; 
	Y=200;
	
TYPE SPixel=RECORD
	t:Base.Time;
	color: Base.Color
END;

TYPE Scrim= OBJECT(Base.Voxel);
VAR
	box: ARRAY X,Y,6 OF SPixel;
PROCEDURE Shade (VAR ray: Ray);

END Shade;

END Scrim;


END XNXLScrim.	


