MODULE NIqy3HQ4ZK8iRwAXelYYnsQ;
IMPORT Math, XNXLBase, XNXLVoxel, XNXLVoxel4, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;


VAR
	rand: Random.Generator;


TYPE PT=XNXLBase.PT;
	BOX=XNXLBase.BOX;
	Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;
	Name = XNXLBase.Name;

TYPE ImpliciVox=OBJECT(XNXLBase.Voxel)
VAR
	c: PT;
	cx*,cy*,cz*: REAL; (* center of polar coordinates *)
	enclosingvoxel: Voxel;

PROCEDURE SetEnclosingVoxel*(v: Voxel);
BEGIN
	enclosingvoxel:=v;
END SetEnclosingVoxel;

PROCEDURE d2(x,y,z:REAL):REAL;
BEGIN
	 RETURN((c.x-x)*(c.x-x)+ (c.y-y)*(c.y-y) + (c.z-z)*(c.z-z));
END d2;

PROCEDURE dee2(p:PT):REAL;
BEGIN
	 RETURN((c.x-p.x)*(c.x-p.x)+ (c.y-p.y)*(c.y-p.y) + (c.z-p.z)*(c.z-p.z));
END dee2;

PROCEDURE in(x,y,z:REAL):BOOLEAN;
BEGIN
	IF x < 0 THEN RETURN(FALSE) END;
	IF x >1 THEN RETURN(FALSE) END;
	IF y < 0 THEN RETURN(FALSE) END;
	IF y >1 THEN RETURN(FALSE) END;
	IF z < 0 THEN RETURN(FALSE) END;
	IF z >1 THEN RETURN(FALSE) END;
	RETURN(TRUE);
END in;

PROCEDURE ctop(p:PT; VAR th,ph,d: REAL);
BEGIN
(*	d := MathL.sqrt(dee2(p));
	th := 6.28*XNXLMath.sin((x-cx)/d);
	ph :=  6.28*XNXLMath.cos((y-cy)/d); *)
END ctop;

PROCEDURE ctop1(p:PT; VAR th,ph,d: REAL);
BEGIN
	d := Math.sqrt(dee2(p));
(*	th := (1+XNXLMath.sin((x-cx)/d))/2;
	ph := (1+XNXLMath.cos((y-cy)/d))/2; *)
END ctop1;

PROCEDURE setCenter*(x,y,z: REAL);
BEGIN
	c.x:=x; c.y:=y; c.z:=z;
END setCenter;

END ImpliciVox;

TYPE SphereInVox*=OBJECT(ImpliciVox);
VAR
	D2*:REAL;
	Normal: XNXLBase.PT;
PROCEDURE & init*;
BEGIN
	setCenter(1/2,1/2,1/2);
	D2 :=8/40;
END init;

PROCEDURE setSize*(x: REAL);
BEGIN
 	D2 := x*x;
END setSize;

PROCEDURE tick;
BEGIN
	D2:= 1/4 + rand.Uniform()/200 ; 
END tick;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,blue,alpha: REAL;
	a,b,c,n: XNXLBase.PT;
	i: INTEGER;
	hit: BOOLEAN;
	dot:REAL;
BEGIN
	a.x := ray.lxyz.x; a.y := ray.lxyz.y; a.z := ray.lxyz.z;
	d := d2(a.x, a.y, a.z);
	IF d < D2 THEN	
		dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
		ray.r := ray.r + dot*ray.ra; 
		ray.g := ray.g + dot*ray.ga;
		ray.b := ray.b +dot*ray.ba; 
		ray.terminate := TRUE;		
	ELSE		
		b:= XNXLBase.Exit(ray);
		x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		d := d2(a.x, a.y, a.z);
		IF d > D2 THEN
			FOR i := 0 TO 12 DO
				d := d2(x,y,z);
				IF d < D2 THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END;
		ELSE
			FOR i := 0 TO 12 DO
				d := d2(x,y,z);
				IF d > D2 THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END;
		END;
		IF (ABS(d-D2) < 0.01) THEN 
			ray.lxyz.x := x; ray.lxyz.y := y; ray.lxyz.z :=  z;
			n.x:= cx-x; n.y:=cy-y; n.z:=cz-z;
			normalize(n.x,n.y,n.z);
			ray.normal:=n;
			dot := 1-ABS(n.x*ray.dxyz.x + n.y*ray.dxyz.y+ n.z*ray.dxyz.z);
	(*		ray.r := ray.r + (0*dot)*ray.ra; *)
	(*		ray.g := ray.g + (0*dot)*ray.ga; *)
			ray.b := ray.b + (1*dot)*ray.ba;
			ray.terminate := TRUE;	
		END 
	END
END Shade;
END SphereInVox;

VAR
	sphere:SphereInVox;

PROCEDURE normalize(VAR x,y,z: REAL);
VAR d: REAL;
BEGIN
	d := Math.sqrt(x*x+y*y+z*z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	x := x/d; y := y/d; z:=z/d;
END normalize;

PROCEDURE reflect(VAR x,y,z: REAL; nx,ny,nz:REAL);
VAR 
	dot: REAL;
BEGIN
	dot := x*nx+y*ny+z*nz;
	nx := 2*nx*dot; ny := 2*ny*dot; nz := 2*nz*dot;
	x := x-nx; y := y-ny; z := z-nz; 
END reflect;

PROCEDURE  thisvox*():XNXLBase.Voxel;
BEGIN
	IF sphere=NIL THEN
		NEW(sphere); 
	END;
	RETURN sphere
END thisvox;

END NIqy3HQ4ZK8iRwAXelYYnsQ. 