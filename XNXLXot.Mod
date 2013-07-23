MODULE XNXLXot;

IMPORT Base:=XNXLBase,  M3:=XNXLM3Space;
TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
	TexCube= Base.TexCube;	
	
TYPE Xot*=OBJECT(M3.cell);
VAR
	texcube*: TexCube;

PROCEDURE & init*;
BEGIN
	NEW(texcube,"sand",TRUE);
	setcolor(0,0,0,1000,0);
	passable:=TRUE;
	copyonstroke:=TRUE; 
	nbloxTF[1,1,0]:=TRUE;
	nbloxTF[1,1,2]:=TRUE;
	nbloxTF[0,1,1]:=TRUE;
	nbloxTF[2,1,1]:=TRUE;
	nbloxTF[1,0,1]:=TRUE;
	nbloxTF[1,2,1]:=TRUE;
	nblox[1,1,0].normal.x:=0;
	nblox[1,1,0].normal.y:= 0;
	nblox[1,1,0].normal.z:= -1;		
	nblox[1,1,2].normal.x:= 0;
	nblox[1,1,2].normal.y:= 0;
	nblox[1,1,2].normal.z:= 1;			
	nblox[0,1,1].normal.x:= -1;
	nblox[0,1,1].normal.y:= 0;
	nblox[0,1,1].normal.z:= 0;		
	nblox[2,1,1].normal.x:= 1;
	nblox[2,1,1].normal.y:= 0;
	nblox[2,1,1].normal.z:= 0;			
	nblox[1,0,1].normal.x:= 0;
	nblox[1,0,1].normal.y:= -1;
	nblox[1,0,1].normal.z:= 0;		
	nblox[1,2,1].normal.x:= 0;
	nblox[1,2,1].normal.y:= 1;
	nblox[1,2,1].normal.z:= 0;							
END init;

PROCEDURE xotcolor* (r, g, b : REAL);
VAR
	c: Base.Color;
BEGIN
	c.red:=r;
	c.green:=g;
	c.blue:=b;
	nblox[1,1,0].color:=c;
	nblox[1,1,2].color:=c;
	nblox[0,1,1].color:=c;
	nblox[2,1,1].color:=c;
	nblox[1,0,1].color:=c;
	nblox[1,2,1].color:=c;
END xotcolor;

PROCEDURE nshade*(CONST nc: NCube; VAR ray: Ray);
VAR
	lx,ly,mix,dot,dot1,dot2: REAL;
	dtl:LONGINT;	
	color: Color;
BEGIN
	CASE ray.face OF
		 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
		|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
		|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
		|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
		|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
		|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
	END;
	dtl:=ENTIER(ray.length*ray.scale/ray.dtl);	
	color:=texcube.side[ray.face].pixelT(lx,ly,dtl);
	dot1:= ABS(nc.normal.x*ray.dxyz.x + nc.normal.y*ray.dxyz.y+ nc.normal.z*ray.dxyz.z); 
	dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	dot2:=dot2*0.7+0.3;
	IF ray.length*ray.scale<3 THEN mix:=1-(ray.length*ray.scale/6) ELSE mix:=0 END;
	dot:=mix*dot2+(1-mix)*dot1;
	ray.r := ray.r + color.red * ray.ra*dot;
	ray.g := ray.g + color.green * ray.ga*dot;
	ray.b := ray.b + color.blue * ray.ba*dot; 		
	ray.terminate:=TRUE
END nshade;

END Xot;


END XNXLXot.