MODULE XNXLNoise;

IMPORT SYSTEM, BIT;

CONST
	
	NOISE_MAGIC_X = 1619;
	NOISE_MAGIC_Y = 31337;
	NOISE_MAGIC_Z= 52591;
	NOISE_MAGIC_SEED = 1013;
	coslookup = [1.0,0.9238,0.7071,0.3826,0,-0.3826,-0.7071,-0.9238,
	1.0,-0.9238,-0.7071,-0.3826,0,0.3826,0.7071,0.9238]

PROCEDURE dot(vx,vy,wx,wy:LONGREAL):LONGREAL;
BEGIN
	RETURN(vx*wx+vy*wy)
END dot;

PROCEDURE easecurve*(t:LONGREAL):LONGREAL;
BEGIN
	RETURN ((6*t*t*t*t*t)-(15*t*t*t*t)+(10*t*t*t))
END easecurve;

PROCEDURE linearinterpolation(x,y,t:LONGREAL):LONGREAL;
BEGIN
	RETURN(x+(y-x)*t)
END linearinterpolation;

PROCEDURE bilinearinterpolation(x0y0,x1y0,x0y1,x1y1,x,y:LONGREAL):LONGREAL;
VAR
	tx,ty,u,v: LONGREAL;
BEGIN
	tx:=easecurve(x);
	ty:=easecurve(y);
	u:=linearinterpolation(x0y0,x1y0,tx);
	v:=linearinterpolation(x0y1,x1y1,tx);
	RETURN linearinterpolation(u,v,ty);
END bilinearinterpolation;

PROCEDURE trilinearinterpolation(v000,v100,v010,v110,v001,v101,v011,v111,x,y,z:LONGREAL):LONGREAL;
VAR
	tx,ty,tz:LONGREAL;
BEGIN
	tx:=x; ty:=y; tz:=z;
	RETURN(v000*(1-tx)*(1-ty)*(1-tz) +
		v100*tx*(1-ty)*(1-tz) +
		v010*(1-tx)*ty*(1-tz) +
		v110*tx*ty*(1-tz) +
		v001*(1-tx)*(1-ty)*tz +
		v101*tx*(1-ty)*tz +
		v011*(1-tx)*ty*tz +
		v111*tx*ty*tz)
END trilinearinterpolation;

PROCEDURE noise2d(x,y,seed:LONGINT):LONGREAL;
VAR	
	n:LONGINT;
	s,m:SET;
BEGIN
	s:=SYSTEM.VAL(SET,NOISE_MAGIC_X * x + NOISE_MAGIC_Y * y
			+ NOISE_MAGIC_SEED * seed);
	m:=SYSTEM.VAL(SET,7FFFFFFFH);
	s:= s*m; 
	n:=SYSTEM.VAL(LONGINT,s);
	n:=BIT.LXOR(n DIV 8192,n);
	s:=SYSTEM.VAL(SET,(n * (n*n*60493+19990303) + 1376312589) );
	s:= s*m; 
	n:=SYSTEM.VAL(LONGINT,s);
	RETURN 1.0 - n/1073741824;
END noise2d;

PROCEDURE noise3d*(x,y,z,seed:LONGINT):LONGREAL;
VAR	
	n:LONGINT;
	s,m:SET;
BEGIN
	s:=SYSTEM.VAL(SET,NOISE_MAGIC_X * x + NOISE_MAGIC_Y * y + NOISE_MAGIC_Z * z
			+ NOISE_MAGIC_SEED * seed);
	m:=SYSTEM.VAL(SET,7FFFFFFFH);
	s:= s*m; 
	n:=SYSTEM.VAL(LONGINT,s);
	n:=BIT.LXOR(n DIV 8192,n);	
	s:=SYSTEM.VAL(SET,(n * (n*n*60493+19990303) + 1376312589) );
	s:= s*m; 
	n:=SYSTEM.VAL(LONGINT,s);
	RETURN 1.0 - n/1073741824;
END noise3d;

PROCEDURE noise2dgradient*(x, y:LONGREAL; seed:LONGINT):LONGREAL;
VAR
	x0,y0:LONGINT;
	xl,yl,v00,v10,v01,v11:LONGREAL;
BEGIN
	
	IF x>0 THEN x0:=ENTIER(x) ELSE x0:=ENTIER(x)-1 END;
	IF y>0 THEN y0:=ENTIER(y) ELSE y0:=ENTIER(y)-1 END;	
	xl := x - x0;
	yl := y - y0;
	v00 := noise2d(x0, y0, seed);
	v10 := noise2d(x0+1, y0, seed);
	v01 := noise2d(x0, y0+1, seed);
	v11 := noise2d(x0+1, y0+1, seed);
	RETURN SHORT(bilinearinterpolation(v00,v10,v01,v11,xl,yl));
END noise2dgradient;

PROCEDURE noise3dgradient*(x, y, z:LONGREAL; seed:LONGINT):LONGREAL;
VAR
	x0,y0,z0:LONGINT;
	xl,yl,zl,v000,v001,v010,v011,v100,v101,v110,v111:LONGREAL;
BEGIN
	IF x>0 THEN x0:=ENTIER(x) ELSE x0:=ENTIER(x)-1 END;
	IF y>0 THEN y0:=ENTIER(y) ELSE y0:=ENTIER(y)-1 END;	
	IF z>0 THEN z0:=ENTIER(z) ELSE z0:=ENTIER(z)-1 END;		
	xl := x - x0;
	yl := y - y0;
	zl:= z - z0;
	v000 := noise3d(x0, y0, z0, seed);
	v100 := noise3d(x0+1, y0, z0, seed);
	v010 := noise3d(x0, y0+1, z0, seed);
	v110 := noise3d(x0+1, y0+1, z0, seed);
	v001 := noise3d(x0, y0, z0+1, seed);
	v101 := noise3d(x0+1, y0, z0+1, seed);
	v011 := noise3d(x0, y0+1, z0+1, seed);
	v111 := noise3d(x0+1, y0+1, z0+1, seed);
	RETURN SHORT(trilinearinterpolation(v000,v100,v010,v110,v001,v101,v011,v111,xl,yl,zl));
END noise3dgradient;

PROCEDURE noise2dperlin*(x,y:LONGREAL; seed: LONGINT; octaves: INTEGER; persistence:LONGREAL):REAL;
VAR
	a,f,g:LONGREAL;
	i: INTEGER;
BEGIN
	a:=0;
	f := 1.0;
	g := 1.0;
	FOR i:=0 TO octaves-1 DO
		a := a+ (g * noise2dgradient(x*f, y*f, seed+i));
		f := f*2.0;
		g := g*persistence;
	END;
	RETURN SHORT(a);
END noise2dperlin;

PROCEDURE noise2dperlinabs*(x,y:LONGREAL; seed: LONGINT; octaves: INTEGER; persistence:LONGREAL):REAL;
VAR
	a,f,g:LONGREAL;
	i: INTEGER;
BEGIN
	a:=0;
	f := 1.0;
	g := 1.0;
	FOR i:=0 TO octaves-1 DO
		a := a+ (g * ABS(noise2dgradient(x*f, y*f, seed+i)));
		f := f*2.0;
		g := g*persistence;
	END;
	RETURN SHORT(a);
END noise2dperlinabs;

PROCEDURE noise3dperlin*(x,y,z:LONGREAL; seed: LONGINT; octaves: INTEGER; persistence:LONGREAL):REAL;
VAR
	a,f,g:LONGREAL;
	i: INTEGER;
BEGIN
	a:=0;
	f := 1.0;
	g := 1.0;
	FOR i:=0 TO octaves-1 DO
		a := a+ (g * noise3dgradient(x*f, y*f, z*f, seed+i));
		f := f*2.0;
		g := g*persistence;
	END;
	RETURN SHORT(a);
END noise3dperlin;

PROCEDURE noise3dperlinabs*(x,y,z:LONGREAL; seed: LONGINT; octaves: INTEGER; persistence:LONGREAL):REAL;
VAR
	a,f,g:LONGREAL;
	i: INTEGER;
BEGIN
	a:=0;
	f := 1.0;
	g := 1.0;
	FOR i:=0 TO octaves-1 DO
		a := a+ (g * ABS(noise3dgradient(x*f, y*f, z*f, seed+i)));
		f := f*2.0;
		g := g*persistence;
	END;
	RETURN SHORT(a);
END noise3dperlinabs;

END XNXLNoise.

