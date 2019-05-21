MODULE Retinax; (* EXPERIMENTAL RETINA WITH EDGEFINDING TILE *)
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics, WMRasterScale,  Rect := WMRectangles;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=2;        
	TS=16*4;  (*  TS MUST BE {size of unit tile} MULTIPLIED BY 2**T *)
	TW=16;
	TH=9;
	W*=TS*TW;
	H*=TS*TH;
	CX=W DIV 2;
	CY=H DIV 2;
	GAMMA=250; 

TYPE Camera= RECORD			(* solid angle *)
	dtheta, dphi, theta, phi,rphi:REAL;
	imx,imy,size: INTEGER;
END;

TYPE Tile=OBJECT
VAR
	GO: BOOLEAN;
	cam: Camera;
	dtl: REAL;
	
PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE
END go;

PROCEDURE angletoray(VAR ray: Ray; theta,phi: REAL);
VAR 
	d: REAL;
BEGIN
	ray.dxyz.x:= Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y:= Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d;	
	ray.downxyz:=Base.dward;
	ray.rightxyz:=Base.rward;
	SPSMMath.orrot(ray.dxyz, Base.dward, rtheta);  
	SPSMMath.orrot(ray.dxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.downxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.rightxyz, Base.dward, rphi);  	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.lxyz:=Base.cameraPT;
	ray.xyz:= Base.cameraPT;
	ray.oxyz:= Base.cameraPT;	
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=Base.DTL;
	ray.texdtl:=1;	
END angletoray;

PROCEDURE interpray(CONST ra,rb: Ray; mix: REAL): Ray;
VAR
	r: Ray;
	mixi: REAL;
BEGIN
	r.lxyz:=Base.cameraPT;
	r.xyz:= Base.cameraPT;
	r.oxyz:= Base.cameraPT;	
	r.clr.ra := 1;
	r.clr.ga := 1;
	r.clr.ba := 1;
	r.clr.alpha:=1;
	r.scale := 1; 
	r.tscale:=1;
	r.dtl:=Base.DTL;	
	mixi:=1-mix;
	r.dxyz.x:= ra.dxyz.x*mixi + rb.dxyz.x*mix;
	r.dxyz.y:= ra.dxyz.y*mixi + rb.dxyz.y*mix;
	r.dxyz.z := ra.dxyz.z*mixi+ rb.dxyz.z*mix;	
	IF r.dxyz.x < 0 THEN r.di := FALSE  ELSE r.di := TRUE END; 
	IF r.dxyz.y < 0 THEN r.dj := FALSE  ELSE r.dj := TRUE END;
	IF r.dxyz.z < 0 THEN r.dk := FALSE  ELSE r.dk := TRUE END;		
	RETURN r;
END interpray;

PROCEDURE interpclr(CONST ra,rb: Base.ray_color): Base.ray_color;
VAR
	r: Base.ray_color;
BEGIN
	r.r:= (ra.r+rb.r)/2;
	r.g:= (ra.g+rb.g)/2;
	r.b:= (ra.b+rb.b)/2;				
	RETURN r;
END interpclr;

PROCEDURE clrd(CONST ra,rb: Base.ray_color): REAL;
BEGIN			
	RETURN ABS(ra.r-rb.r)+ABS(ra.g-rb.g)+ABS(ra.b-rb.b);
END clrd;

PROCEDURE clrd4(CONST ra,rb,rc,rd: Base.ray_color): REAL;
BEGIN			
	RETURN clrd(ra,rb)+clrd(rb,rc)+clrd(rc,rd)+clrd(rd,ra);
END clrd4;

PROCEDURE tessa16(cam:Camera);	

PROCEDURE t2x2a(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y+1]);	
	Base.world.Shade(rays[x+1,y]);	
	Base.world.Shade(rays[x+1,y+1]);		
	tileimage[x,y]:=rays[x,y].clr;
	tileimage[x+1,y]:=rays[x+1,y].clr;
	tileimage[x+1,y+1]:=rays[x+1,y+1].clr;
	tileimage[x,y+1]:=rays[x,y+1].clr;
END t2x2a;

PROCEDURE t2x2b(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x,y+1]);	
	Base.world.Shade(rays[x+1,y+1]);		
	tileimage[x,y]:=rays[x,y].clr;
	tileimage[x+1,y]:=rays[x+1,y].clr;
	tileimage[x+1,y+1]:=rays[x+1,y+1].clr;
	tileimage[x,y+1]:=rays[x,y+1].clr;
END t2x2b;

PROCEDURE t2x2c(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+1,y]);	
	Base.world.Shade(rays[x,y+1]);		
	tileimage[x,y]:=rays[x,y].clr;
	tileimage[x+1,y]:=rays[x+1,y].clr;
	tileimage[x+1,y+1]:=rays[x+1,y+1].clr;
	tileimage[x,y+1]:=rays[x,y+1].clr;	
END t2x2c;

PROCEDURE t2x2d(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+1,y]);	
	Base.world.Shade(rays[x+1,y+1]);		
	tileimage[x,y]:=rays[x,y].clr;
	tileimage[x+1,y]:=rays[x+1,y].clr;
	tileimage[x+1,y+1]:=rays[x+1,y+1].clr;
	tileimage[x,y+1]:=rays[x,y+1].clr;
END t2x2d;

PROCEDURE t4x4fill(CONST x,y: INTEGER);
VAR
	i,j: INTEGER;
BEGIN
	IF clrd4(rays[x,y].clr, rays[x+3,y].clr, rays[x+3,y+3].clr, rays[x,y+3].clr) >THRESH THEN
		t2x2a(x,y);
		t2x2b(x+2,y);
		t2x2c(x+2,y+2);
		t2x2d(x,y+2); 
	ELSE
		FOR i:=x TO x+3 DO
			FOR j:=y TO y+3 DO
				tileimage[i,j]:=rays[x,y].clr;
			END
		END
	END
END t4x4fill;

PROCEDURE t4x4a(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x,y+3]);	
	Base.world.Shade(rays[x+3,y+3]);	
	t4x4fill(x,y)
END t4x4a;

PROCEDURE t4x4b(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x,y+3]);	
	Base.world.Shade(rays[x+3,y+3]);		
	t4x4fill(x,y)	
END t4x4b;

PROCEDURE t4x4c(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x,y+3]);		
	t4x4fill(x,y)
END t4x4c;

PROCEDURE t4x4d(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x+3,y+3]);		
	t4x4fill(x,y)	
END t4x4d;

PROCEDURE t8x8fill(CONST x,y: INTEGER);
VAR
	i,j: INTEGER;
BEGIN
	IF clrd4(rays[x,y].clr, rays[x+7,y].clr, rays[x+7,y+7].clr, rays[x,y+7].clr) > THRESH THEN
		t4x4a(x,y);
		t4x4b(x+4,y);
		t4x4c(x+4,y+4);
		t4x4d(x,y+4); 
	ELSE
		FOR i:=x TO x+7 DO
			FOR j:=y TO y+7 DO
				tileimage[i,j]:=rays[x,y].clr;
			END
		END
	END
END t8x8fill;

PROCEDURE t8x8a(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x,y+7]);	
	Base.world.Shade(rays[x+7,y+7]);	
	t8x8fill(x,y)
END t8x8a;

PROCEDURE t8x8b(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x,y+7]);	
	Base.world.Shade(rays[x+7,y+7]);		
	t8x8fill(x,y)	
END t8x8b;

PROCEDURE t8x8c(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x,y+7]);		
	t8x8fill(x,y)
END t8x8c;

PROCEDURE t8x8d(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x+7,y+7]);		
	t8x8fill(x,y)	
END t8x8d;

PROCEDURE t16x16fill();
VAR
	i,j: INTEGER;
BEGIN
	IF clrd4(rays[0,0].clr, rays[15,0].clr, rays[15,15].clr, rays[0,15].clr) > THRESH THEN
		t8x8a(0,0);
		t8x8b(8,0);
		t8x8c(8,8);
		t8x8d(0,8); 
	ELSE
		FOR i:= 0 TO 15 DO
			FOR j:= 0 TO 15 DO
				tileimage[i,j]:=rays[0,0].clr;
			END
		END
	END
END t16x16fill;

VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 16,16 OF Base.Ray;
	tileimage: ARRAY 16,16 OF Base.ray_color;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[0,15],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[15,0],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[15,15],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	FOR i := 1 TO 15 DO
		rays[i,0]:= interpray(rays[0,0],rays[15,0],i/16);
		rays[i,15]:= interpray(rays[0,15],rays[15,15],i/16);
	END;	
	FOR i := 0 TO 15 DO
		FOR j:= 1 TO 14 DO
			rays[i,j]:= interpray(rays[i,0],rays[i,15],j/16);
		END
	END;		
	Base.world.Shade(rays[0,0]);	
	Base.world.Shade(rays[15,0]);		
	Base.world.Shade(rays[15,15]);		
	Base.world.Shade(rays[0,15]);		
	t16x16fill;	
	FOR i:= 0 TO 15 DO
		FOR j := 0 TO 15 DO 
			Raster.SetRGB(pixel,ENTIER(tileimage[i,j].r*GAMMA),ENTIER(tileimage[i,j].g*GAMMA),ENTIER(tileimage[i,j].b*GAMMA)); 
			Raster.Put(image,cam.imx+j,cam.imy+i,pixel,copy);
		END
	END;		
END tessa16;

PROCEDURE tessa16d4(cam:Camera);	

PROCEDURE t4x4fill(CONST x,y: INTEGER);
VAR
	i,j: INTEGER;
BEGIN	
	FOR i:=x TO x+3 DO
		FOR j:=y TO y+3 DO
			tileimage[i,j]:=rays[x,y].clr;
		END
	END
END t4x4fill;

PROCEDURE t4x4a(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x,y+3]);	
	Base.world.Shade(rays[x+3,y+3]);	
	t4x4fill(x,y)
END t4x4a;

PROCEDURE t4x4b(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x,y+3]);	
	Base.world.Shade(rays[x+3,y+3]);		
	t4x4fill(x,y)	
END t4x4b;

PROCEDURE t4x4c(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x,y+3]);		
	t4x4fill(x,y)
END t4x4c;

PROCEDURE t4x4d(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+3,y]);	
	Base.world.Shade(rays[x+3,y+3]);		
	t4x4fill(x,y)	
END t4x4d;

PROCEDURE t8x8fill(CONST x,y: INTEGER);
VAR
	i,j: INTEGER;
BEGIN
	IF clrd4(rays[x,y].clr, rays[x+7,y].clr, rays[x+7,y+7].clr, rays[x,y+7].clr) > THRESH THEN
		t4x4a(x,y);
		t4x4b(x+4,y);
		t4x4c(x+4,y+4);
		t4x4d(x,y+4); 
	ELSE
		FOR i:=x TO x+7 DO
			FOR j:=y TO y+7 DO
				tileimage[i,j]:=rays[x,y].clr;
			END
		END
	END
END t8x8fill;

PROCEDURE t8x8a(CONST x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x,y+7]);	
	Base.world.Shade(rays[x+7,y+7]);	
	t8x8fill(x,y)
END t8x8a;

PROCEDURE t8x8b(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x,y+7]);	
	Base.world.Shade(rays[x+7,y+7]);		
	t8x8fill(x,y)	
END t8x8b;

PROCEDURE t8x8c(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x,y+7]);		
	t8x8fill(x,y)
END t8x8c;

PROCEDURE t8x8d(x,y: INTEGER);
BEGIN
	Base.world.Shade(rays[x,y]);	
	Base.world.Shade(rays[x+7,y]);	
	Base.world.Shade(rays[x+7,y+7]);		
	t8x8fill(x,y)	
END t8x8d;

PROCEDURE t16x16fill();
VAR
	i,j: INTEGER;
BEGIN
	IF clrd4(rays[0,0].clr, rays[15,0].clr, rays[15,15].clr, rays[0,15].clr) > THRESH THEN
		t8x8a(0,0);
		t8x8b(8,0);
		t8x8c(8,8);
		t8x8d(0,8); 
	ELSE
		FOR i:= 0 TO 15 DO
			FOR j:= 0 TO 15 DO
				tileimage[i,j]:=rays[0,0].clr;
			END
		END
	END
END t16x16fill;

VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 16,16 OF Base.Ray;
	tileimage: ARRAY 16,16 OF Base.ray_color;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[0,15],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[15,0],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[15,15],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	FOR i := 1 TO 15 DO
		rays[i,0]:= interpray(rays[0,0],rays[15,0],i/16);
		rays[i,15]:= interpray(rays[0,15],rays[15,15],i/16);
	END;	
	FOR i := 0 TO 15 DO
		FOR j:= 1 TO 14 DO
			rays[i,j]:= interpray(rays[i,0],rays[i,15],j/16);
		END
	END;		
	Base.world.Shade(rays[0,0]);	
	Base.world.Shade(rays[15,0]);		
	Base.world.Shade(rays[15,15]);		
	Base.world.Shade(rays[0,15]);		
	t16x16fill;	
	FOR i:= 0 TO 15 DO
		FOR j := 0 TO 15 DO 
			Raster.SetRGB(pixel,ENTIER(tileimage[i,j].r*GAMMA),ENTIER(tileimage[i,j].g*GAMMA),ENTIER(tileimage[i,j].b*GAMMA)); 
			Raster.Put(image,cam.imx+j,cam.imy+i,pixel,copy);
		END
	END;		
END tessa16d4;

PROCEDURE ztrace(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y,D: REAL;
	FVV:REAL;
BEGIN
	FVV:=10*FV*FV;
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			x:=a.imx-W/2;
			y:=a.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa16(a); 
			ELSE
				tessa16d4(a); 
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN
				tessa16(b); 
			ELSE 
				tessa16d4(b);
			END;
			x:=c.imx-W/2;
			y:=c.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa16(c); 
			ELSE
				tessa16d4(c)
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa16(d); 
			ELSE
				tessa16d4(d); 
			END;		
	ELSE
		l:=level-1;
		ztrace(a,l);
		ztrace(b,l);
		ztrace(c,l);
		ztrace(d,l) 	
	END;
END ztrace;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		ztrace(cam,T); 
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
		incTD; 
		END;
	UNTIL ~Base.worldalive; 
END Tile;

VAR
	tile: ARRAY TW,TH OF Tile;
	TESSA: INTEGER;
	frameasteps*,framebsteps*:LONGINT;
	a,b: LONGINT;
	tilesdone:INTEGER;

	AFTER*: INTEGER;
	FAST*:INTEGER;
	lsense,ls2:REAL;
	FGUAARD,FRAMEBOORT:BOOLEAN;
	saccade*,SACCADE1*,DTLRAYS*:BOOLEAN;
	cameratheta*,cameraphi*:REAL;
	aperture*: Base.Aperture;
	image*,fimage*: Raster.Image;
	rtheta,rphi: REAL; (* camera pitch,roll. global variables because they are the same for all rays in a frame *)
	fward*, dward*, rward*,camrward*: PT;  
	foveaparameter:INTEGER;
	FV: REAL;
	copy: Raster.Mode;
	THRESH: REAL;
	
PROCEDURE Res*;
BEGIN
	INC(TESSA);
	TESSA:=TESSA MOD 3;
END Res;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;
	
PROCEDURE mirror(VAR ray: Ray);
BEGIN
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;
	
PROCEDURE angletoray(VAR ray: Base.Ray; theta,phi: REAL);
VAR 
	d: REAL;
BEGIN
	ray.dxyz.x:= Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y:= Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d;	
	ray.downxyz:=Base.dward;
	ray.rightxyz:=Base.rward;
	SPSMMath.orrot(ray.dxyz, Base.dward, rtheta);  
	SPSMMath.orrot(ray.dxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.downxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.rightxyz, Base.dward, rphi);  	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.lxyz:=Base.cameraPT;
	ray.xyz:= Base.cameraPT;
	ray.oxyz:= Base.cameraPT;		
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.scale := 1; 
	ray.dtl:=Base.DTL;
END angletoray;

PROCEDURE splitcam(cam: Camera; VAR a,b,c,d: Camera);
VAR
	dt,dp:REAL;
	dimx, dimy,s: INTEGER;
BEGIN
	dt:=cam.dtheta/2;
	dp:=cam.dphi/2;
	s:=cam.size DIV 2;

	a.dtheta:=dt;
	a.dphi:=dp;
	a.theta:=cam.theta;
	a.phi:=cam.phi+dp;
	a.imx:=cam.imx;
	a.imy:=cam.imy+s;
	a.size:=s;	

	b.dtheta:=dt;
	b.dphi:=dp;
	b.theta:=cam.theta+dt;
	b.phi:=cam.phi+dp;
	b.imx:=cam.imx+s;
	b.imy:=cam.imy+s;
	b.size:=s;		
	
	c.dtheta:=dt;
	c.dphi:=dp;
	c.theta:=cam.theta;
	c.phi:=cam.phi;
	c.imx:=cam.imx;
	c.imy:=cam.imy;
	c.size:=s;			
	
	d.dtheta:=dt;
	d.dphi:=dp;
	d.theta:=cam.theta+dt;
	d.phi:=cam.phi;
	d.imx:=cam.imx+s;
	d.imy:=cam.imy;
	d.size:=s;			
	
END splitcam;

PROCEDURE moredetail*;
BEGIN
	foveaparameter:=foveaparameter-1;
	IF foveaparameter<11 THEN foveaparameter:=11 END;
(*	Out.Int(foveaparameter,4); *)
	FV:=W/foveaparameter;
END moredetail;

PROCEDURE lessdetail*;
BEGIN
	foveaparameter:=(foveaparameter+1);
	IF foveaparameter>50 THEN foveaparameter:=50 END;
	FV:=W/foveaparameter;
END lessdetail;

PROCEDURE decdetail*;
BEGIN
	Base.DTL:=Base.DTL*2/3;
END decdetail;

PROCEDURE incdetail*;
BEGIN
	Base.DTL:=Base.DTL*3/2;
END incdetail;

PROCEDURE decthresh*;
BEGIN
	THRESH:=THRESH*2/3;
END decthresh;

PROCEDURE incthresh*;
BEGIN
	THRESH:=THRESH*3/2;
END incthresh;

PROCEDURE incTD;
BEGIN{EXCLUSIVE}
	INC(tilesdone);
END incTD;

PROCEDURE zeroTD;
BEGIN{EXCLUSIVE}
	tilesdone:=0;
END zeroTD;

PROCEDURE gotiles;
VAR
	i,j: INTEGER;
BEGIN
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			tile[i,j].go;
		END
	END
END gotiles;

PROCEDURE go*(theta,phi,apw,aph: REAL);
VAR
	i,j: INTEGER;
	ctheta,cphi,dtheta,dphi: REAL;
	pixel: Raster.Pixel;
	sr: Ray;
	r14,r11: Rect.Rectangle;
BEGIN
	zeroTD;
	frameasteps:=0;
	framebsteps:=0;
	dtheta:=apw/TW;
	dphi:=aph/TH;
	ctheta:=-apw/2;	
	FOR i:= 0 TO TW-1  DO	
		cphi:=-aph/2;
		FOR j:= 0 TO TH-1 DO
			tile[i,j].cam.theta:=ctheta;
			tile[i,j].cam.phi:=cphi;
			tile[i,j].cam.dtheta:=dtheta;
			tile[i,j].cam.dphi:=dphi;
			tile[i,j].cam.imx:=i*TS;
			tile[i,j].cam.imy:=j*TS;
			tile[i,j].cam.size:=TS;			
			cphi:=cphi+dphi;		
		END;
		ctheta:=ctheta+dtheta;
	END;
	dward:= Base.dward;
	fward:= Base.fward;
	rward:=Base.rward;
	rtheta:=phi;
	rphi:=theta;	
	SPSMMath.orrot(fward, Base.dward,rtheta);   
	SPSMMath.orrot(rward, Base.dward,rtheta);   		
	SPSMMath.orrot(fward, Base.rward,rphi);  	
	SPSMMath.orrot(dward, Base.rward,rphi);  
	sr:=Base.blankray;
	sr.clr.ra := 1;
	sr.clr.ga := 1;
	sr.clr.ba := 1;
	sr.clr.alpha:=1;
	sr.scale := 1; 
	sr.dtl:=Base.DTL;
	angletoray(sr,0,0);	
	Base.sniperay:=sr;
	BEGIN{EXCLUSIVE}
		gotiles;
		AWAIT((tilesdone=TW*TH) OR FRAMEBOORT)
	END;
	Raster.SetRGB(pixel,255,255,255);
	Raster.Put(image,CX+2,CY+2,pixel,copy);	
	Raster.Put(image,CX-2,CY+2,pixel,copy);	
	Raster.Put(image,CX-2,CY-2,pixel,copy);	
	Raster.Put(image,CX+2,CY-2,pixel,copy);
	Raster.SetRGB(pixel,0,0,0);
	Raster.Put(image,CX+1,CY+1,pixel,copy);	
	Raster.Put(image,CX-1,CY+1,pixel,copy);	
	Raster.Put(image,CX-1,CY-1,pixel,copy);	
	Raster.Put(image,CX+1,CY-1,pixel,copy);	
END go;

BEGIN
	Out.String("Retina loading...");
	Raster.InitMode(copy,Raster.srcCopy);	
	image := Graphics.LoadImage("granite.jpg", FALSE);
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b]);
		END
	END;	
	AFTER:=2;
 	FAST:=3;
 	THRESH:=0.1;
 	lsense:=0.2;
 	aperture.width:=1;
 	aperture.height:=1;
 	foveaparameter:=13;
 	Out.String("loaded...");	
END Retinax.
