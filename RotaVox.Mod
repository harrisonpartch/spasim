MODULE RotaVox;

IMPORT Base, SPSMMath, Math;

TYPE Voxel=Base.Voxel;
TYPE PT=Base.PT;
TYPE Ray=Base.Ray;
TYPE SREAL=REAL;

TYPE RVox*=OBJECT(Voxel); 
VAR
	child: Voxel;
	xphi,zphi: REAL; (* rotation angle inradians *);
	X,Z: PT;
	dxtick,dztick: REAL;
	center:PT;

PROCEDURE&init*(c:Voxel; x,z: PT; dx,dz: REAL);
BEGIN
	child:=c;
	dxtick:=dx;
	dztick:=dz;
	passable:=TRUE;
	register;
	X:=x;
	Z:=z;
	center.x:=1/2; center.y:=1/2; center.z:=1/2;
END init;

PROCEDURE tick;
BEGIN
	xphi:=xphi+dxtick;
	IF xphi > 6.2832 THEN xphi:=0 END;
	zphi:=zphi+dztick;
	IF zphi > 6.2832 THEN zphi:=0 END;
END tick;

PROCEDURE d2(x,y,z:REAL):REAL;
BEGIN
	 RETURN((center.x-x)*(center.x-x)+ (center.y-y)*(center.y-y) + (center.z-z)*(center.z-z));
END d2;

PROCEDURE dia(a,b:PT):SREAL;
BEGIN
	 RETURN Math.sqrt((a.x-b.x)*(a.x-b.x)+ (a.y-b.y)*(a.y-b.y) + (a.z-b.z)*(a.z-b.z));
END dia;

PROCEDURE Shade(VAR oray: Ray);
VAR
	rpop, a,b,c,dxyz,rayxyz, exit:PT;
	d, dc,x,y,z, raylength: REAL;
	i: INTEGER;
	ray: Ray;
BEGIN
	ray:=oray; (* ray is a RECORD not an OBJECT *)
	a:=ray.lxyz;
	(* advance ray to its intersection with the sphere of radius 1/2 centered in the voxel *)
	b:= Base.Exit(ray);
	rpop:=b;
	x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
	d := d2(a.x, a.y, a.z);
	IF d > 1/4 THEN
		FOR i := 0 TO 12 DO
			d := d2(x,y,z);
			IF d < 1/4 THEN 
				b.x := x; b.y := y; b.z := z
			ELSE
				a.x := x; a.y := y; a.z := z
			END;
			x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		END;
	ELSE
		FOR i := 0 TO 12 DO
			d := d2(x,y,z);
			IF d > 1/4 THEN 
				b.x := x; b.y := y; b.z := z
			ELSE
				a.x := x; a.y := y; a.z := z
			END;
			x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		END;
	END;
	IF (ABS(d-1/4) < 0.001) THEN 
		a.x := x; a.y := y; a.z := z;
		a.x:=(x-1/2)*2; a.y:=(y-1/2)*2; a.z:=(z-1/2)*2;      (* we know that the vector from (1/2,1/2,1/2) to (x,y,z) has length 1/2 so this translates and normalizes it *)
		SPSMMath.orrot(a,X,xphi);	
		SPSMMath.orrot(a,Z,zphi);	
		a.x:=a.x/2+1/2; a.y:=a.y/2+1/2; a.z:=a.z/2+1/2; 	(* denormalize and translate back*)
		SPSMMath.orrot(ray.dxyz,X,xphi); 
		SPSMMath.orrot(ray.dxyz,Z,zphi); 
		IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
		IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
		IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;		
		ray.lxyz:=a; 
		child.Shade(ray); 
	END;
	oray.clr.r:=ray.clr.r;
	oray.clr.g:=ray.clr.g;
	oray.clr.b:=ray.clr.b;
	oray.clr.ra:=ray.clr.ra;
	oray.clr.ga:=ray.clr.ga;
	oray.clr.ba:=ray.clr.ba;
	oray.terminate:=ray.terminate; 
END Shade;

END RVox;

END RotaVox.