MODULE XNXLVoxel;
IMPORT Base, Random, Math, XNXLMath, XNXLE, XNXLHex, Noise, Streams;

CONST 	
		NL=Base.NL;
TYPE 	PT=Base.PT;
		Ray = Base.Ray;
		Voxel = Base.Voxel;
		
TYPE ColoredVox* = OBJECT(Voxel);
VAR
	r, g, b: REAL;
PROCEDURE setcolor* (red, green, blue, black, alpha: REAL);
BEGIN
	r :=red ;
	g := green;
	b := blue;
END setcolor;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	ray.r := ray.r + r*ray.ra;
	ray.g := ray.g + g*ray.ga;
	ray.b := ray.b + b*ray.ba;
	ray.terminate := TRUE;
END Shade;
END ColoredVox;

TYPE GoorowVox* = OBJECT(Voxel);
VAR
	r, g, b: REAL;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	ray.r := ray.r + ray.lxyz.x*ray.ra;
	ray.g := ray.g + ray.lxyz.y*ray.ga;
	ray.b := ray.b + ray.lxyz.z*ray.ba;
	ray.terminate := TRUE;
END Shade;
END GoorowVox;

TYPE ColoredMVox* = OBJECT(Voxel); (*NOT CORRECT YET *)
VAR
	r, g, b, mf, a: REAL;
PROCEDURE setcolor*(red, green, blue, black, mfraction: REAL);
BEGIN
	mf := mfraction;
	Base.clamp(mf);
	a := mf;
	IF a<0.1 THEN a:=0.1 END;
	r := red*a;
	g := green*a;
	b := blue*a;
END setcolor;
PROCEDURE Shade (VAR ray: Ray);
VAR 
	dr, dg, db: REAL;
BEGIN
	dr :=  r*ray.ra;
	dg :=  g*ray.ga;
	db :=  b*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - a*(dg+db)-0.1;
	ray.ga := ray.ga - a*(dr+db)-0.1;
	ray.ba := ray.ba - a*(dr+dg)-0.1;
	IF (ray.ra<0.1)OR(ray.ga<0.1)OR(ray.ba<0.1) THEN ray.terminate:=TRUE 
	ELSE mirror(ray) END
END Shade;
END ColoredMVox;

TYPE DiffuseMVox* = OBJECT(Voxel);
VAR
	r, g, b, mf, a: REAL;
PROCEDURE Shade (VAR ray: Ray);
VAR 
	nx, ny, nz: INTEGER;
	dot,d: REAL;
	inside: BOOLEAN;
BEGIN
	d := (nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z); 
	ray.ra := ray.ra- 0.1; 
	ray.ga := ray.ga- 0.1; 
	ray.ba := ray.ba- 0.1; 	
	mirror(ray);
END Shade;
END DiffuseMVox;

TYPE DiffuseSphMVox* = OBJECT(ColoredVox);
VAR
	 mf, a: REAL;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	nx, ny, nz: REAL;
	dot: REAL;
	inside: BOOLEAN;
BEGIN
	nx := 1/2 - ray.lxyz.x; ny := 1/2-ray.lxyz.y; nz := 1/2-ray.lxyz.z;
	Base.normalize(nx,ny, nz);
	IF inside THEN dot := 0 ELSE dot := ABS(nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z) END;
	ray.bla := dot*ray.bla/2; 
	ray.ra := dot*ray.ra/2; 
	ray.ga := dot*ray.ga/2; 
	ray.ba := dot*ray.ba/2; 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE 
	ELSE mirror(ray) END
END Shade;
END DiffuseSphMVox;

TYPE DiffuseSphVox* = OBJECT(ColoredVox);
VAR
	 mf, a: REAL;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	nx, ny, nz: REAL;
	dot: REAL;
	p: Base.PT;
	inside: BOOLEAN;
BEGIN
	p.x:= 1/2 - ray.lxyz.x; p.y:= 1/2 - ray.lxyz.y; p.z:= 1/2 - ray.lxyz.z;
	Base.normalizePT(p);
	dot := ABS(p.x*ray.dxyz.x + p.y*ray.dxyz.y+ p.z*ray.dxyz.z); 
	ray.r := ray.r + r * ray.ra*dot;
	ray.g := ray.g + g * ray.ga*dot;
	ray.b := ray.b + b * ray.ba*dot;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END
END Shade;
END DiffuseSphVox;

TYPE AlphaVox* = OBJECT(Voxel);
VAR
	r, g, b,a : REAL;
PROCEDURE setcolor* (red, green, blue, black, alpha  : REAL);
BEGIN
	r := red;
	g := green ;
	b := blue;
	a:=alpha;
END setcolor;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	dr, dg, db,dot: REAL;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	dr :=  r*a*ray.ra;
	dg :=  g*a*ray.ga;
	db :=  b*a*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra -dr;
	ray.ga := ray.ga -dg;
	ray.ba := ray.ba -db;
	ray.bla := ray.bla ;
	IF (ray.ra<0.1)OR(ray.ga<0.1)OR(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;
END AlphaVox;

TYPE TransparaVox*=OBJECT(Voxel);
VAR
	r, g, b, black: REAL;	
PROCEDURE setcolor* (red, green, blue,bl, alpha  : REAL); 
BEGIN
	r := red;
	g := green;
	b := blue;
	black:=bl;
	passable := TRUE;
END setcolor;

PROCEDURE Shade (VAR ray: Ray);
VAR 
	depth: REAL;
	exit:PT;
	dr,dg,db,dbl: REAL;
BEGIN
	exit:=Base.Exit(ray);
	depth:=Base.distsquared(ray.lxyz,exit)/ray.scale;
	dr := r*depth;
	dg := g*depth;
	db := b*depth;
	dbl:=black*depth;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db; 
	ray.ra := (ray.ra - dr)-dbl;
	ray.ga := (ray.ga - dg)-dbl;
	ray.ba := (ray.ba - db)-dbl; 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

PROCEDURE engrain(w: Streams.Writer);
BEGIN
	w.Bytes(code,0,NL);	
	w.RawReal(r);
	w.RawReal(g);
	w.RawReal(b);	
	w.RawReal(black);	
END engrain;

PROCEDURE sprout(rdr: Streams.Reader);
BEGIN
	rdr.RawReal(r);
	rdr.RawReal(g);
	rdr.RawReal(b);	
	rdr.RawReal(black);	
END sprout;

END TransparaVox;

TYPE OutlineVox*=OBJECT(ColoredVox);
VAR
	or, og, ob: REAL;
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
	X:REAL;
PROCEDURE&init*;
BEGIN
	setoutline(1/2,1/2,0);
END init;	
PROCEDURE setoutline* (red, green, blue: REAL);
BEGIN
	or := red ;
	og := green ;
	ob := blue;
END setoutline;
PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot, e: REAL;
	inside: BOOLEAN;
	ecount:INTEGER;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	IF (ray.lxyz.x< 0.001) OR (ray.lxyz.x > 0.999) THEN INC(ecount) END;
	IF (ray.lxyz.y <0.001) OR (ray.lxyz.y > 0.999) THEN INC(ecount) END;
	IF (ray.lxyz.z < 0.001) OR (ray.lxyz.z > 0.999) THEN INC(ecount) END;
	IF (ecount > 1) THEN
		ray.r := ray.r + or * ray.ra*dot;
		ray.g := ray.g + og * ray.ga*dot;
		ray.b := ray.b + ob * ray.ba*dot;
		ray.terminate := TRUE;
	ELSE	
		ray.r := ray.r + r * ray.ra*dot ;
		ray.g := ray.g + g * ray.ga*dot;
		ray.b := ray.b + b * ray.ba*dot;	
		ray.terminate := TRUE;
	END
END Shade;
END OutlineVox;

TYPE COutlineVox*=OBJECT(ColoredVox);
VAR
	or, og, ob: REAL;
	flt,fgt: REAL;
PROCEDURE&init*;
BEGIN
	setoutline(1/8,1/8,0,1/20);
END init;	
PROCEDURE setoutline* (red, green, blue,f: REAL);
BEGIN
	or := red ;
	og := green ;
	ob := blue;
	fgt:=f;
	flt:=1-f;
END setoutline;
PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot, e: REAL;
	inside: BOOLEAN;
	ecount:INTEGER;
	exit:PT;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	IF (ray.lxyz.x< fgt) OR (ray.lxyz.x > flt) THEN INC(ecount) END;
	IF (ray.lxyz.y <fgt) OR (ray.lxyz.y > flt) THEN INC(ecount) END;
	IF (ray.lxyz.z < fgt) OR (ray.lxyz.z > flt) THEN INC(ecount) END;
	IF (ecount > 1) THEN
		ray.r := ray.r + or * ray.ra*dot;
		ray.g := ray.g + og * ray.ga*dot;
		ray.b := ray.b + ob * ray.ba*dot;
		ray.terminate := TRUE;
	ELSE
		ecount:=0;
		exit:=Base.Exit(ray);
		IF (exit.x< fgt) OR (exit.x > flt) THEN INC(ecount) END;
		IF (exit.y <fgt) OR (exit.y > flt) THEN INC(ecount) END;
		IF (exit.z < fgt) OR (exit.z > flt) THEN INC(ecount) END;		
		IF (ecount > 1) THEN
			ray.r := ray.r + or * ray.ra*dot;
			ray.g := ray.g + og * ray.ga*dot;
			ray.b := ray.b + ob * ray.ba*dot;
			ray.terminate := TRUE
		END
	END		
END Shade;

END COutlineVox; 

TYPE DiffuseVox* = OBJECT(ColoredVox)

PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	ray.r := ray.r + (r*dot)*ray.ra;
	ray.g := ray.g + (g*dot)*ray.ga;
	ray.b := ray.b + (b*dot)*ray.ba;
	ray.terminate := TRUE;	
END Shade;

END DiffuseVox;

TYPE NoiseVox* =OBJECT(ColoredVox)
PROCEDURE Shade (VAR ray: Ray);
VAR
	lx,ly,lz,dot: REAL;
	rr:REAL;
	inside: BOOLEAN;
BEGIN
	lx := ray.xyz.x;
	ly := ray.xyz.y;
	lz := ray.xyz.z;
	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	rr:=	Noise.noise3dperlinabs(lx,lz,ly, 666,4,2);
	ray.r := ray.r + (rr*dot)*ray.ra;
	ray.g := ray.g + (rr*dot)*ray.ga;
	ray.b := ray.b + (rr*dot)*ray.ba;
	ray.r := 1/2;
	ray.terminate := TRUE;	
END Shade;

END NoiseVox;

TYPE Diffuse2Vox* = OBJECT(ColoredVox)
VAR
	rr,gg,bb: REAL;
	
PROCEDURE setcolor2* (red, green, blue : REAL);
BEGIN
	rr := red;
	gg := green;
	bb := blue;
END setcolor2;

PROCEDURE Shade (VAR ray: Ray);
VAR
	dot,reciprodot: REAL;
	inside: BOOLEAN;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	reciprodot:=1-dot*dot;
	ray.r := ray.r + (r*dot+rr*reciprodot)*ray.ra/2;
	ray.g := ray.g + (g*dot+gg*reciprodot)*ray.ga/2;
	ray.b := ray.b + (b*dot+bb*reciprodot)*ray.ba/2;
	ray.terminate := TRUE;	
END Shade;

END Diffuse2Vox;

TYPE DiffuseNouraudVox* = OBJECT(ColoredVox);
VAR
	rr,gg,bb: REAL;
	
PROCEDURE setcolor2* (red, green, blue : REAL);
BEGIN
	rr := red;
	gg := green;
	bb := blue;
END setcolor2;

PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot,reciprodot: REAL;
	inside: BOOLEAN;
	l, x, y, z: REAL;
	ecount: INTEGER;
BEGIN
	l := 2*(ABS(1/2-ray.lxyz.x) + ABS(1/2-ray.lxyz.y) + ABS(1/2-ray.lxyz.z))/3;
	CASE ray.face OF
		0: inside := TRUE
		|1: nx := -1
		|2: ny := -1
		|3: nz := -1
		|4: nx := 1
		|5: ny := 1
		|6: nz := 1
	ELSE
	END;
	IF inside THEN dot := l ELSE dot := l*(1/3+2*ABS(nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z)/2) END;
	reciprodot:=1-dot*dot;
	ray.r := ray.r + (r*dot+rr*reciprodot)*ray.ra/2;
	ray.g := ray.g + (g*dot+gg*reciprodot)*ray.ga/2;
	ray.b := ray.b + (b*dot+bb*reciprodot)*ray.ba/2;
	ray.terminate := TRUE;
END Shade;

END DiffuseNouraudVox;

TYPE GridVox* = OBJECT(Voxel);
VAR
	r, g, b, a, gr, gg, gb, ga, Z: REAL;
	
PROCEDURE&init*;
BEGIN
	setcolor(1,1,1,0,0);
	setgridcolor(0,1,0,1/2);
	setgrid(3.0);
END init;

PROCEDURE setcolor* (red, green, blue, black, alpha: REAL);
BEGIN
	r := red * alpha;
	g := green * alpha;
	b := blue * alpha;
	a := alpha;
END setcolor;

PROCEDURE setgridcolor* (red, green, blue, alpha: REAL);
BEGIN
	gr := red * alpha;
	gg := green * alpha;
	gb := blue * alpha;
	ga := alpha;
END setgridcolor;

PROCEDURE setgrid*(z: REAL);
BEGIN
	Z := z;
END setgrid;

PROCEDURE Shade (VAR ray: Ray);
VAR
	lx, ly, x,y, d: REAL;
	i, j, k: LONGINT;
	ecount: INTEGER;
BEGIN
	CASE ray.face OF
		 0: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|1: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
		|3: lx := ray.lxyz.y; ly := ray.lxyz.z; 
		|4: lx := ray.lxyz.x; ly := ray.lxyz.z; 
		|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
	ELSE
	END;
	x := lx*Z; y := ly*Z;
	i := ENTIER(x); j := ENTIER(y); 
	x := x - i; y := y - j; 
	IF ((x<0.1) OR (y<0.1)) THEN 
		ray.r := ray.r + gr;
		ray.g := ray.g + gg;
		ray.b := ray.b + gb;
		ray.ra := ray.ra - (gg+gb);
		ray.ga := ray.ga - (gr+gb);
		ray.ba := ray.ba - (gr+gg);
	ELSE
		ray.r := ray.r + r;
		ray.g := ray.g + g;
		ray.b := ray.b + b;
		ray.ra := ray.ra - (g+b);
		ray.ga := ray.ga - (r+b);
		ray.ba := ray.ba - (r+g);
	END;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END
END Shade;

END GridVox;

TYPE BiVox* = OBJECT(Voxel);
VAR
	v1*, v2*: Voxel;

PROCEDURE set*(x,y: Voxel);
BEGIN
	v1 := x;
	v2 := y;
END set;

PROCEDURE Shade (VAR ray: Ray);
BEGIN
	IF v1# NIL THEN v1.Shade(ray) END;
	IF ~ray.terminate THEN IF v2# NIL THEN v2.Shade(ray) END END
END Shade;

END BiVox;

TYPE FuzzyTVox*=OBJECT(AlphaVox);
VAR
	fuzzdivisor, fuzzsubtract: REAL;
PROCEDURE & init*;
BEGIN
	passable := TRUE;
	fuzzdivisor := 100;
	fuzzsubtract := 0.005;
END init;

PROCEDURE setFuzz*(f: REAL);
BEGIN
	fuzzdivisor := f;
	fuzzsubtract := 1/(2*fuzzdivisor)
END setFuzz;

PROCEDURE Shade*(VAR ray: Ray);
VAR 
	dr, dg, db: REAL;
BEGIN
	ray.xyz.x := ray.xyz.x + Base.rand.Uniform()/fuzzdivisor-fuzzsubtract;
	ray.xyz.y := ray.xyz.y + Base.rand.Uniform()/fuzzdivisor-fuzzsubtract;
	ray.xyz.z:= ray.xyz.z + Base.rand.Uniform()/fuzzdivisor-fuzzsubtract; 
	dr :=  r*ray.ra;
	dg :=  g*ray.ga;
	db :=  b*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db);
	ray.ga := ray.ga - (dr+db);
	ray.ba := ray.ba - (dr+dg);
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END
END Shade;

END FuzzyTVox;

VAR
	rand: Random.Generator;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE normalize*(VAR p: PT);
VAR
	d: REAL;
BEGIN
	d := Math.sqrt(p.x*p.x + p.y*p.y+p.z*p.z);
	IF d = 0 THEN 
		p.x := 1;
		d := 1;
	END;	
	p.x := p.x/d; p.y := p.y/d; p.z:= p.z/d
END normalize;	

PROCEDURE greatest(a,b,c: REAL):REAL;
BEGIN
	IF a>b THEN
		IF a>c THEN
			RETURN(a)
		ELSE
			RETURN(c)
		END
	ELSE
		IF b>c THEN
			RETURN(b)
		ELSE
			RETURN(c)
		END
	END
END greatest;

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.hitdxyz:=ray.dxyz;	
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;
	reflect(ray.dxyz, ray.normal);		
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;

PROCEDURE smirror(VAR ray: Ray);
VAR
	x,y,z, th,ph,d,r,g,b,a: REAL;
	ax, ay, az, bx, by, bz : REAL;
	i: INTEGER;
	hit: BOOLEAN;
	n:PT;
BEGIN
		ray.changed := TRUE;
		ray.mirrortf:=TRUE;
		ray.hitmirrorTF := TRUE;
		ray.hitxyz:=ray.xyz;
		ray.hitdxyz:=ray.dxyz;
		n.x := 1/2-ray.xyz.x; n.y := 1/2 - ray.xyz.y; n.z := 1/2 -ray.xyz.z;
		Base.normalizePT(n);
		reflect(ray.dxyz,n);
		ray.xyz.x := ray.xyz.x + x; ray.xyz.y := ray.xyz.y  + y; ray.xyz.z := ray.xyz.z + z; 
		IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
		IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
		IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;			
END smirror;

BEGIN
	NEW(rand)
END XNXLVoxel.