MODULE Voxel4;
IMPORT Random, Base, XNXLVoxel,  XNXLMath, Math, Raster;

VAR
	rand: Random.Generator;


TYPE PT=Base.PT;
	BOX=Base.BOX;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	Name = Base.Name;

TYPE FuzzVox*=OBJECT(Voxel);
VAR
	fuzzdivisor, fuzzsubtract: REAL;
PROCEDURE & init*;
BEGIN
	passable := TRUE;
	fuzzdivisor := 100;
	fuzzsubtract := 1/(2*fuzzdivisor)
END init;

PROCEDURE setFuzz*(f: REAL);
BEGIN
	fuzzdivisor := f;
	fuzzsubtract := 1/(2*fuzzdivisor)
END setFuzz;

PROCEDURE Shade*(VAR ray: Ray);
BEGIN
	ray.changed := TRUE;
	ray.dxyz.x := ray.dxyz.x + rand.Uniform()/100 - 0.005;
	ray.dxyz.y := ray.dxyz.y + rand.Uniform()/100 - 0.005;
	ray.dxyz.z := ray.dxyz.z + rand.Uniform()/100 - 0.005; 
END Shade;

END FuzzVox;

TYPE Sphere*=OBJECT(Base.Voxel)
VAR
	c: PT;                  
	d,d2: REAL;
	box: BOX;
	outshader, inshader: Voxel;
PROCEDURE rebox;
BEGIN
	box.p.x:=c.x-d; box.p.y:=c.y-d; box.p.z:=c.z-d;
	box.q.x:=c.x+d; box.q.y:=c.y+d; box.q.z:=c.z+d;
END rebox;
PROCEDURE mov(p: PT);
BEGIN
	c.x:=c.x+p.x;
	
	c.y:=c.y+p.y;
	c.z:=c.z+p.z;
	rebox
END mov;
PROCEDURE resize*(s:REAL);
BEGIN
	d:= d+s;
	d2:=d*d;
	rebox
END resize;
PROCEDURE size*(s:REAL);
BEGIN
	d:= d+s;
	d2:=d*d;
	rebox
END size;
END Sphere;

TYPE ImpliciVox=OBJECT(Base.Voxel)
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

TYPE Stripey*=OBJECT(Base.Voxel);

PROCEDURE ctop(x,y,z: REAL; VAR th,ph: REAL);
BEGIN
	x := x - 1/2; y := y-1/2; z := z-1/2;
	Base.normalize(x,y,z);
(*	th := 6.28*XNXLMath.sin(x);
	ph :=  6.28*XNXLMath.cos(y); *)  (*XNXLeal=longreal breaks this for some reason *)
END ctop;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	theta, phi,d, r, g, b: REAL;
BEGIN
	ctop(ray.lxyz.x, ray.lxyz.y, ray.lxyz.z, theta, phi );
	r := (ENTIER(theta*17) MOD 5)/4;
	g := (ENTIER(theta*11) MOD 3)/2;
	b := (ENTIER(phi*17) MOD 5)/4;
	ray.r := ray.r + ray.bla*r;
	ray.g := ray.g + ray.bla*g;
	ray.b := ray.b + ray.bla*b;
	ray.bla := 0;
END Shade;
END Stripey;

TYPE Ellipsoid*=OBJECT(ImpliciVox);
VAR
	A2, B2, C2, D*:REAL;
	shader, inshader: Voxel;
	
PROCEDURE dee2(p:PT):REAL;
BEGIN
	 RETURN((cx-p.x)*(cx-p.x)/A2 + (cy-p.y)*(cy-p.y)/B2 + (cz-p.z)*(cz-p.z)/C2);
END dee2;

PROCEDURE test(p:PT):BOOLEAN;
VAR
	d:REAL;
BEGIN
	 d:=dee2(p);
	 RETURN(d<D);
END test;


PROCEDURE & init*(v,u: Voxel);
BEGIN
	shader := v;
	inshader := u;
	cx :=1/2; cy := 1/2;  cz := 1/2; 
	A2:=1; B2:=1; C2:=1/2; D:=1/7;
END init;

PROCEDURE size*(x: REAL);
BEGIN
 	D:= x*x;
END size;

PROCEDURE tick;
BEGIN
	IF rand.Dice(100) = 0 THEN
		cx := rand.Uniform();
		cy := rand.Uniform();
		cz := rand.Uniform();
	END 
END tick;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	A,B,C: PT;
	a,b,c: REAL;
	i:INTEGER;
BEGIN
	A:=ray.lxyz;
	B:=Base.Exit(ray);
	IF test(A) THEN IF inshader # NIL THEN inshader.Shade(ray) END
	ELSIF test(B) THEN
		FOR i:=0 TO 12 DO
			C:=Base.midPT(A,B);
			IF test(C) THEN B:=C ELSE A:=C
		END
	END;
	IF ABS(dee2(C)-D) < 0.001 THEN
		ray.lxyz:=C;
		IF shader # NIL THEN shader.Shade(ray) END
	END
	END 
END Shade;

END Ellipsoid;

TYPE Hyperboloid*=OBJECT(ImpliciVox);
VAR
	A2, B2, C2, D*:REAL;
	V: Voxel;
	
PROCEDURE d2(x,y,z: REAL): REAL;
BEGIN
	 RETURN(-(cx-x)*(cx-x)/A2 - (cy-y)*(cy-y)/B2 + (cz-z)*(cz-z)/C2);
END d2; 

PROCEDURE & init*(v: Voxel);
BEGIN
	V := v;
	cx := 1/2; cy := 1/2;  cz := 1/2; 
	A2:=1; B2:=1; C2:=1; D:=1/2;
END init;

PROCEDURE set*(v: Voxel);
BEGIN
 	V := v;
END set;

PROCEDURE size*(x: REAL);
BEGIN
 	D:= x*x;
END size;

PROCEDURE tick;
BEGIN
	D:= 1/4 + rand.Uniform()/200 ; 
END tick;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,blue,alpha: REAL;
	a,b,c,n: Base.PT;
	i: INTEGER;
	hit: BOOLEAN;
	dott: REAL;
BEGIN
	a.x := ray.lxyz.x; a.y := ray.lxyz.y; a.z := ray.lxyz.z;
	d := d2(a.x, a.y, a.z);
	IF d < D THEN	
		IF V # NIL THEN 
			V.Shade(ray) 
		ELSE
(*			volshader.Shade(x,y,z,r,g,blue,ray.bla);
			ray.r:=r*dott; ray.g:=g*dott; ray.b:=blue*dott; ray.bla:=0; *)
		END
	ELSE		
		b:= Base.Exit(ray);
		x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		d := d2(a.x, a.y, a.z);		
		IF d > D THEN
			FOR i := 0 TO 12 DO
				d := d2(x,y,z);
				IF d < D THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END;
		ELSE
			FOR i := 0 TO 12 DO
				d := d2(x,y,z);
				IF d > D THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END
		END
	END;
	IF (ABS(d-D) < 0.01) THEN 
		ray.lxyz.x := x; ray.lxyz.y := y; ray.lxyz.z :=  z;
		n.x:= cx-x; n.y:=cy-y; n.z:=cz-z;
		Base.normalizePT(n);
		ray.normal:=n;
		dott := ABS(n.x*ray.dxyz.x + n.y*ray.dxyz.y+ n.z*ray.dxyz.z);
		IF V # NIL THEN 
			V.Shade(ray) 
		ELSE
	(*		volshader.Shade(x,y,z,r,g,blue,ray.bla);
			ray.r:=r*dott; ray.g:=g*dott; ray.b:=blue*dott; ray.bla:=0; *)
		END
	END
END Shade;
END Hyperboloid;

TYPE SphereInVox*=OBJECT(ImpliciVox);
VAR
	D2*:REAL;
	V,V2: Voxel;
	Normal: Base.PT;
	red,green: Base.Color;
PROCEDURE & init*(v,v2: Voxel; size: REAL);
BEGIN
	V := v;
	V2:=v2;
	setCenter(1/2,1/2,1/2);
	D2 := size*size;
END init;

PROCEDURE tick;
BEGIN
	D2:= 1/4 + rand.Uniform()/200 ; 
END tick;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,blue,alpha: REAL;
	a,b,c,n: Base.PT;
	i: INTEGER;
	hit: BOOLEAN;
	dott:REAL;
BEGIN
	a.x := ray.lxyz.x; a.y := ray.lxyz.y; a.z := ray.lxyz.z;
	d := d2(a.x, a.y, a.z);
	IF d < D2 THEN	
		IF V # NIL THEN 
			V.Shade(ray) 
		END
	ELSE		
		b:= Base.Exit(ray);
		x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		d := d2(a.x, a.y, a.z);
		IF d > D2 THEN
			FOR i := 0 TO 24 DO
				d := d2(x,y,z);
				IF d < D2 THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END;
		ELSE
			FOR i := 0 TO 24 DO
				d := d2(x,y,z);
				IF d > D2 THEN 
					b.x := x; b.y := y; b.z := z
				ELSE
					a.x := x; a.y := y; a.z := z
				END;
				x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
			END;
		END;
		IF (ABS(d-D2) < 0.0001) THEN 
			ray.lxyz.x := x; ray.lxyz.y := y; ray.lxyz.z :=  z;
			IF ray.di THEN
				ray.xyz.x := ray.xyz.x+x/ray.scale
			ELSE
				ray.xyz.x := ray.xyz.x-x/ray.scale
			END;
			IF ray.dj THEN
				ray.xyz.y := ray.xyz.y+y/ray.scale
			ELSE
				ray.xyz.y := ray.xyz.y-y/ray.scale
			END;
			IF ray.dk THEN
				ray.xyz.z := ray.xyz.z+z/ray.scale
			ELSE
				ray.xyz.z := ray.xyz.z-z/ray.scale
			END;
			n.x:= cx-x; n.y:=cy-y; n.z:=cz-z;
			normalize(n.x,n.y,n.z);
			ray.normal.x:=n.x;
			ray.normal.y:=n.y;
			ray.normal.z:=n.z;
			dott := ABS(n.x*ray.dxyz.x + n.y*ray.dxyz.y+ n.z*ray.dxyz.z);
			IF V2 # NIL THEN 
				V2.Shade(ray) 
			ELSIF V # NIL THEN 
				V.Shade(ray) 
			END
		END 
	END
END Shade;
END SphereInVox;

TYPE MirrorSphereInVox*=OBJECT(ImpliciVox);

VAR
	D2*:REAL;
PROCEDURE &init*;
BEGIN
	setCenter(1/2,1/2,1/2);
	D2 := 1/5;
(*	register; *)
END init;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,blue,alpha: REAL;
	dx, dy, dz , dista, distb: REAL;
	a,b,c,n: Base.PT; 
	i: INTEGER;
	hit: BOOLEAN;
	nx,ny,nz: REAL;
BEGIN       
	a := ray.lxyz;
	b:= Base.Exit(ray);
	x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
	d := d2(a.x, a.y, a.z);
	IF d > D2 THEN
		FOR i := 0 TO 24 DO
			d := d2(x,y,z);
			IF d < D2 THEN 
				b.x := x; b.y := y; b.z := z
			ELSE
				a.x := x; a.y := y; a.z := z
			END;
			x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		END;
	ELSE
		FOR i := 0 TO 24 DO
			d := d2(x,y,z);
			IF d > D2 THEN 
				b.x := x; b.y := y; b.z := z
			ELSE
				a.x := x; a.y := y; a.z := z
			END;
			x := (a.x+b.x)/2; y := (a.y+b.y)/2; z := (a.z + b.z)/2;
		END;
	END;
	IF (ABS(d-D2) < 0.001) THEN 
		n.x := cx-x; n.y := cy - y; n.z := cz - z;
		Base.normalizePT(n);
		reflect(ray.dxyz.x,ray.dxyz.y,ray.dxyz.z, n.x,n.y,n.z);
		ray.lxyz.x :=  x; ray.lxyz.y :=  y; ray.xyz.z := z; 
		ray.changed := TRUE;
		ray.ra := ray.ra - 0.1;
		ray.ga := ray.ga - 0.1;
		ray.ba := ray.ba - 0.1;
		ray.bla := ray.bla - 0.1;
	END;
	IF ray.changed & (enclosingvoxel#NIL) THEN
		ray.changed:=FALSE;
		enclosingvoxel.Shade(ray);
	END; 
END Shade;

PROCEDURE tick;
BEGIN
	D2:= 1/3 + rand.Uniform()/50 ; 
END tick;

END MirrorSphereInVox;

TYPE CylInVox*=OBJECT(ImpliciVox);
VAR
	D2*:REAL;

PROCEDURE & init*;
BEGIN
	cx := 1/2; cy := 1/2;   cz := 1/2;
	D2 := 1/3;
END init;

PROCEDURE Shade*(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,b,a: REAL;
	ax, ay, az, bx, by, bz : REAL;
	iter, i,j: LONGINT;
	hit: BOOLEAN;
	nx,ny,nz, lat, long: REAL;
	p: Raster.Pixel;
BEGIN
	ax := ray.lxyz.x; ay := ray.lxyz.y; az := ray.lxyz.z;
	bx := ray.lxyz.x + ray.dxyz.x; by := ray.lxyz.y+ ray.dxyz.y; bz := ray.lxyz.z+ ray.dxyz.z; 
	x := (ax+bx)/2; y := (ay+by)/2; z := (az + bz)/2;
	IF d2(x,y,cz) < D2 THEN
		FOR i := 0 TO 8 DO
			IF d2(x,y,1/2) < D2 THEN 
				bx := x; by := y; bz := z
			ELSE
				ax := x; ay := y; az := z
			END;
			x := (ax+bx)/2; y := (ay+by)/2; z := (az + bz)/2
		END;
(*		ctop(x,y,z,lat,long,d);
		r := ABS(XNXLMath.sin(lat)); g := ABS(XNXLMath.sin(long));
		ray.r := ray.r + r*ray.bla;
		ray.g := ray.g + g*ray.bla;
		ray.b := ray.b + b*ray.bla;
	    ray.bla :=0; *)
	    nx := cx-x; ny := cy - y; nz := 0;
	    normalize(nx,ny,nz);
		reflect(ray.dxyz.x,ray.dxyz.y,ray.dxyz.z, nx,ny,nz);
		ray.xyz.x := ray.xyz.x + x; ray.xyz.y := ray.xyz.y  + y; ray.xyz.z := ray.xyz.z + z; 
		ray.changed := TRUE;
		ray.bla := ray.bla - 1/5;
	 END;
END Shade;

END CylInVox;

TYPE cube = RECORD
	r,g,b,a: REAL;
END;

TYPE ArVox*=OBJECT(Voxel);

VAR
	ar: ARRAY 20,20,20 OF cube;
	
PROCEDURE&init*;
VAR
	i,j,k: INTEGER;
	a: REAL;
BEGIN
	FOR i := 0 TO 19 DO FOR j:= 0 TO 19 DO FOR k:= 0 TO 19 DO
		IF (ABS(10-i)+ABS(10-j)+ABS(10-k) < 25 )THEN 
			ar[i,j,k].r := 1;
			ar[i,j,k].g := 0;
			ar[i,j,k].b :=  0;
			ar[i,j,k].a := 1/3;
		ELSE
			ar[i,j,k].r := 0;
			ar[i,j,k].g := 0;
			ar[i,j,k].b :=  1;
			ar[i,j,k].a := 1/10;
		END			
	END END END
END init;

PROCEDURE bounds* (i, j, k: INTEGER; VAR out: BOOLEAN);
BEGIN
	IF (i < 0) OR (i > 19) OR (j < 0) OR (j > 19) OR (k < 0) OR (k > 19) THEN
		out := TRUE
	ELSE
		out := FALSE
	END
END bounds;

PROCEDURE Shade (VAR ray: Ray);
VAR
	x, y, z, dx, dy, dz: REAL;
	i, j, k: INTEGER;
	c: cube;
	out: BOOLEAN;
BEGIN
	x := ray.lxyz.x * 20 ; y := ray.lxyz.y * 20 ; z := ray.lxyz.z * 20 ;
	dx := ray.dxyz.x/20; dy := ray.dxyz.y/20; dz := ray.dxyz.z/20;
	REPEAT
		x := x + dx; y := y + dy; z := z + dz;
		bounds(i, j, k, out);
		IF ~out THEN
			c := ar[i, j, k];
			ray.r := ray.r + c.r;
			ray.g := ray.g + c.g;
			ray.b := ray.b + c.b;
			ray.bla := ray.bla - c.a;
		END;
	UNTIL  (ray.bla < 0.1) OR out;
END Shade;

END ArVox;

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

BEGIN
	NEW(rand);
END Voxel4.