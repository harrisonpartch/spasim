MODULE Retina;
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics, WMRasterScale,  Rect := WMRectangles;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=5;        
	TS=5*32;  (*  TS MUST BE 5 MULTIPLIED BY 2**T *)
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

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE
END go;

PROCEDURE tessad2(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	dtheta:=cam.dtheta/2;
	dphi:=cam.dphi/2;
	theta:=cam.theta;
	FOR i:= 0 TO 1 DO
		phi:=cam.phi;
		FOR j := 0 TO 1 DO 
			ray.clr.ra := 1;
			ray.clr.ga := 1;
			ray.clr.ba := 1;
			ray.clr.alpha:=1;
			ray.scale := 1; 
			ray.tscale:=1;
			ray.dtl:=DETAIL;	
			angletoray(ray,theta,phi);
			Base.world.Shade(ray);	
			IF ray.terminate THEN
				r:=ray.clr.r;
				g:=ray.clr.g;
				b:=ray.clr.b; 
			ELSE
				b:= ray.clr.b + ray.clr.ba;
				r:= ray.clr.r + ray.clr.ra/3;
				g:= ray.clr.g + ray.clr.ga/3 
			END;
			Base.clamp3(r,g,b);
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
			phi:=phi+dphi;
		END;
		theta:=theta+dtheta;
	END;
END tessad2;

PROCEDURE tessad3(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	dtheta:=cam.dtheta/3;
	dphi:=cam.dphi/3;
	theta:=cam.theta;
	FOR i:= 0 TO 2 DO
		phi:=cam.phi;
		FOR j := 0 TO 2 DO 
			ray.clr.ra := 1;
			ray.clr.ga := 1;
			ray.clr.ba := 1;
			ray.clr.alpha:=1;
			ray.scale := 1; 
			ray.tscale:=1;
			ray.dtl:=DETAIL;	
			angletoray(ray,theta,phi);
			Base.world.Shade(ray);	
			IF ray.terminate THEN
				r:=ray.clr.r;
				g:=ray.clr.g;
				b:=ray.clr.b; 
			ELSE
				b:= ray.clr.b + ray.clr.ba;
				r:= ray.clr.r + ray.clr.ra/3;
				g:= ray.clr.g + ray.clr.ga/3 
			END;
			Base.clamp3(r,g,b);
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
			phi:=phi+dphi;
		END;
		theta:=theta+dtheta;
	END;
END tessad3;

PROCEDURE tessaid5(cam:Camera);

	PROCEDURE luma(CONST ca,cb: Base.ray_color):REAL;
	BEGIN
		RETURN (ca.r*ca.r+ca.g+ca.g+ca.g+ca.g)/6
	END luma;
	
	PROCEDURE interpray(CONST ra,rb: Base.Ray): Base.Ray;
	VAR
		r: Base.Ray
	BEGIN
		r.dxyz.x:= (ra.dxyz.x+rb.dxyz.x)/2;
		r.dxyz.y:= (ra.dxyz.y+rb.dxyz.y)/2;		
		r.dxyz.x:= (ra.dxyz.y+rb.dxyz.y)/2;
		RETURN r;
	END interpray;
	


VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 5,5 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 5,5 OF Base.Color;
BEGIN
	dtheta:=cam.dtheta/5;
	dphi:=cam.dphi/5;
	theta:=cam.theta;
	
	(*  establish the ray.dxyz for the corners of the 5x5 patch*)
	
	FOR i:= 0 TO 4 BY 4 DO
		phi:=cam.phi;
		FOR j := 0 TO 4 BY 4 DO 
			angletoray(rays[i,j],theta,phi);
			phi:=phi+dphi*4;
		END;
		theta:=theta+dtheta*4;
	END;	
	
	(* interpolate all rays.dxyz in 5x5 patch before shooting any. wasteful because most of these will never
	be used but whatever*)


	(*  trace the corner rays  *)
	
	FOR i:= 0 TO 4 BY 4 DO
		FOR j := 0 TO 4 BY 4 DO 
			rays[i,j].clr.ra := 1;
			rays[i,j].clr.ga := 1;
			rays[i,j].clr.ba := 1;
			rays[i,j].clr.alpha:=1;
			rays[i,j].scale := 1; 
			rays[i,j].tscale:=1;
			rays[i,j].dtl:=DETAIL;	
			Base.world.Shade(rays[i,j]);
			IF rays[i,j].terminate THEN
				patch[i,j].red:=rays[i,j].clr.r;
				patch[i,j].green:=rays[i,j].clr.g;
				patch[i,j].blue:=rays[i,j].clr.b; 
			ELSE
				patch[i,j].blue:= rays[i,j].clr.b + rays[i,j].clr.ba;
				patch[i,j].red:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				patch[i,j].green:= rays[i,j].clr.g + rays[i,j].clr.ga/3 
			END;
		END;
	END;		
	
	
	
	patch[0,1].red:=(patch[0,0].red+patch[0,2].red)/2;
	patch[0,1].green:=(patch[0,0].green+patch[0,2].green)/2;
	patch[0,1].blue:=(patch[0,0].blue+patch[0,2].blue)/2;
			
	patch[0,3].red:=(patch[0,2].red+patch[0,4].red)/2;
	patch[0,3].green:=(patch[0,2].green+patch[0,4].green)/2;
	patch[0,3].blue:=(patch[0,2].blue+patch[0,4].blue)/2;			
			
	patch[2,1].red:=(patch[2,0].red+patch[2,2].red)/2;
	patch[2,1].green:=(patch[2,0].green+patch[2,2].green)/2;
	patch[2,1].blue:=(patch[2,0].blue+patch[2,2].blue)/2;
			
	patch[2,3].red:=(patch[2,2].red+patch[2,4].red)/2;
	patch[2,3].green:=(patch[2,2].green+patch[2,4].green)/2;
	patch[2,3].blue:=(patch[2,2].blue+patch[2,4].blue)/2;			

	patch[4,1].red:=(patch[4,0].red+patch[4,2].red)/2;
	patch[4,1].green:=(patch[4,0].green+patch[4,2].green)/2;
	patch[4,1].blue:=(patch[4,0].blue+patch[4,2].blue)/2;
			
	patch[4,3].red:=(patch[4,2].red+patch[4,4].red)/2;
	patch[4,3].green:=(patch[4,2].green+patch[4,4].green)/2;
	patch[4,3].blue:=(patch[4,2].blue+patch[4,4].blue)/2;	
		
	FOR i:=1 TO 3 BY 2 DO
		FOR j:= 0 TO 4 DO
			patch[i,j].red:=(patch[i-1,j].red+patch[i+1,j].red)/2;
			patch[i,j].green:=(patch[i-1,j].green+patch[i+1,j].green)/2;		
			patch[i,j].blue:=(patch[i-1,j].blue+patch[i+1,j].blue)/2
		END
	END;
	FOR i:=0 TO 4 DO
		FOR j:= 0 TO 4 DO
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessaid5;




PROCEDURE tessad5(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray,bray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 5,5 OF Base.Color;
BEGIN
	dtheta:=cam.dtheta/5;
	dphi:=cam.dphi/5;
	theta:=cam.theta;
	FOR i:= 0 TO 4 BY 2 DO
		phi:=cam.phi;
		FOR j := 0 TO 4 BY 2 DO 
			ray:=bray;
			angletoray(ray,theta,phi);
			ray.clr.ra := 1;
			ray.clr.ga := 1;
			ray.clr.ba := 1;
			ray.clr.alpha:=1;
			ray.scale := 1; 
			ray.tscale:=1;
			ray.dtl:=DETAIL;	
			Base.world.Shade(ray);
			IF ray.terminate THEN
				patch[i,j].red:=ray.clr.r;
				patch[i,j].green:=ray.clr.g;
				patch[i,j].blue:=ray.clr.b; 
			ELSE
				patch[i,j].blue:= ray.clr.b + ray.clr.ba;
				patch[i,j].red:= ray.clr.r + ray.clr.ra/3;
				patch[i,j].green:= ray.clr.g + ray.clr.ga/3 
			END;
			phi:=phi+dphi*2;
		END;
		theta:=theta+dtheta*2;
	END;
	patch[0,1].red:=(patch[0,0].red+patch[0,2].red)/2;
	patch[0,1].green:=(patch[0,0].green+patch[0,2].green)/2;
	patch[0,1].blue:=(patch[0,0].blue+patch[0,2].blue)/2;
			
	patch[0,3].red:=(patch[0,2].red+patch[0,4].red)/2;
	patch[0,3].green:=(patch[0,2].green+patch[0,4].green)/2;
	patch[0,3].blue:=(patch[0,2].blue+patch[0,4].blue)/2;			
			
	patch[2,1].red:=(patch[2,0].red+patch[2,2].red)/2;
	patch[2,1].green:=(patch[2,0].green+patch[2,2].green)/2;
	patch[2,1].blue:=(patch[2,0].blue+patch[2,2].blue)/2;
			
	patch[2,3].red:=(patch[2,2].red+patch[2,4].red)/2;
	patch[2,3].green:=(patch[2,2].green+patch[2,4].green)/2;
	patch[2,3].blue:=(patch[2,2].blue+patch[2,4].blue)/2;			

	patch[4,1].red:=(patch[4,0].red+patch[4,2].red)/2;
	patch[4,1].green:=(patch[4,0].green+patch[4,2].green)/2;
	patch[4,1].blue:=(patch[4,0].blue+patch[4,2].blue)/2;
			
	patch[4,3].red:=(patch[4,2].red+patch[4,4].red)/2;
	patch[4,3].green:=(patch[4,2].green+patch[4,4].green)/2;
	patch[4,3].blue:=(patch[4,2].blue+patch[4,4].blue)/2;		
	
	FOR i:=1 TO 3 BY 2 DO
		FOR j:= 0 TO 4 DO
			patch[i,j].red:=(patch[i-1,j].red+patch[i+1,j].red)/2;
			patch[i,j].green:=(patch[i-1,j].green+patch[i+1,j].green)/2;		
			patch[i,j].blue:=(patch[i-1,j].blue+patch[i+1,j].blue)/2
		END
	END;
	FOR i:=0 TO 4 DO
		FOR j:= 0 TO 4 DO
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessad5;

PROCEDURE tessax5(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 5,5 OF Base.Color;
BEGIN
	dtheta:=cam.dtheta/5;
	dphi:=cam.dphi/5;
	theta:=cam.theta;
	FOR i:= 0 TO 4 BY 4 DO
		phi:=cam.phi;
		FOR j := 0 TO 4 BY 4 DO 
			ray:=Base.blankray;		
			ray.clr.ra := 1;
			ray.clr.ga := 1;
			ray.clr.ba := 1;
			ray.clr.alpha:=1;
			ray.scale := 1; 
			ray.tscale:=1;
			ray.dtl:=DETAIL;	
			angletoray(ray,theta,phi);
			Base.world.Shade(ray);
			IF ray.terminate THEN
				patch[i,j].red:=ray.clr.r;
				patch[i,j].green:=ray.clr.g;
				patch[i,j].blue:=ray.clr.b; 
			ELSE
				patch[i,j].blue:= ray.clr.b + ray.clr.ba;
				patch[i,j].red:= ray.clr.r + ray.clr.ra/3;
				patch[i,j].green:= ray.clr.g + ray.clr.ga/3 
			END;
			phi:=phi+dphi*4;
		END;
		theta:=theta+dtheta*4;
	END;
	
	patch[0,2].red:=(patch[0,0].red+patch[0,4].red)/2;
	patch[0,2].green:=(patch[0,0].green+patch[0,4].green)/2;
	patch[0,2].blue:=(patch[0,0].blue+patch[0,4].blue)/2;	

	patch[4,2].red:=(patch[4,0].red+patch[4,4].red)/2;
	patch[4,2].green:=(patch[4,0].green+patch[4,4].green)/2;
	patch[4,2].blue:=(patch[4,0].blue+patch[4,4].blue)/2;	
	
	patch[2,0].red:=(patch[0,0].red+patch[4,0].red)/2;
	patch[2,0].green:=(patch[0,0].green+patch[4,0].green)/2;
	patch[2,0].blue:=(patch[0,0].blue+patch[4,0].blue)/2;	
	
	patch[2,4].red:=(patch[0,4].red+patch[4,4].red)/2;
	patch[2,4].green:=(patch[0,4].green+patch[4,4].green)/2;
	patch[2,4].blue:=(patch[0,4].blue+patch[4,4].blue)/2;	
	
	patch[2,2].red:=(patch[0,0].red+patch[4,4].red)/2;
	patch[2,2].green:=(patch[0,0].green+patch[4,4].green)/2;
	patch[2,2].blue:=(patch[0,0].blue+patch[4,4].blue)/2;	
	
	patch[0,1].red:=(patch[0,0].red+patch[0,2].red)/2;
	patch[0,1].green:=(patch[0,0].green+patch[0,2].green)/2;
	patch[0,1].blue:=(patch[0,0].blue+patch[0,2].blue)/2;
			
	patch[0,3].red:=(patch[0,2].red+patch[0,4].red)/2;
	patch[0,3].green:=(patch[0,2].green+patch[0,4].green)/2;
	patch[0,3].blue:=(patch[0,2].blue+patch[0,4].blue)/2;			
			
	patch[2,1].red:=(patch[2,0].red+patch[2,2].red)/2;
	patch[2,1].green:=(patch[2,0].green+patch[2,2].green)/2;
	patch[2,1].blue:=(patch[2,0].blue+patch[2,2].blue)/2;
			
	patch[2,3].red:=(patch[2,2].red+patch[2,4].red)/2;
	patch[2,3].green:=(patch[2,2].green+patch[2,4].green)/2;
	patch[2,3].blue:=(patch[2,2].blue+patch[2,4].blue)/2;			

	patch[4,1].red:=(patch[4,0].red+patch[4,2].red)/2;
	patch[4,1].green:=(patch[4,0].green+patch[4,2].green)/2;
	patch[4,1].blue:=(patch[4,0].blue+patch[4,2].blue)/2;
			
	patch[4,3].red:=(patch[4,2].red+patch[4,4].red)/2;
	patch[4,3].green:=(patch[4,2].green+patch[4,4].green)/2;
	patch[4,3].blue:=(patch[4,2].blue+patch[4,4].blue)/2;		
	
	FOR i:=1 TO 3 BY 2 DO
		FOR j:= 0 TO 4 DO
			patch[i,j].red:=(patch[i-1,j].red+patch[i+1,j].red)/2;
			patch[i,j].green:=(patch[i-1,j].green+patch[i+1,j].green)/2;		
			patch[i,j].blue:=(patch[i-1,j].blue+patch[i+1,j].blue)/2
		END
	END;
	FOR i:=0 TO 4 DO
		FOR j:= 0 TO 4 DO
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessax5;

PROCEDURE tessa5(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(ray,cam.theta+cam.dtheta/2, cam.phi+cam.dphi/2);
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=DETAIL;	
	Base.world.Shade(ray);
	IF ray.terminate THEN
		r:=ray.clr.r;
		g:=ray.clr.g;
		b:=ray.clr.b; 
	ELSE
		b:= ray.clr.b + ray.clr.ba;
		r:= ray.clr.r + ray.clr.ra/3;
		g:= ray.clr.g + ray.clr.ga/3
	END;
	Base.clamp3(r,g,b);
	Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 	
	FOR i:=0 TO 4 DO 
		FOR j:= 0 TO 4 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END 
END tessa5;

PROCEDURE tessa3(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(ray,cam.theta+cam.dtheta/2, cam.phi+cam.dphi/2);
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=DETAIL;	
	Base.world.Shade(ray);
	IF ray.terminate THEN
		r:=ray.clr.r;
		g:=ray.clr.g;
		b:=ray.clr.b; 
	ELSE
		b:= ray.clr.b + ray.clr.ba;
		r:= ray.clr.r + ray.clr.ra/3;
		g:= ray.clr.g + ray.clr.ga/3
	END;
	Base.clamp3(r,g,b);	
	Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
	FOR i := 0 TO 2 DO
		FOR j := 0 TO 2 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;	
END tessa3;

PROCEDURE tessa2(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(ray,cam.theta+cam.dtheta/2, cam.phi+cam.dphi/2);
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=DETAIL;	
	Base.world.Shade(ray);
	IF ray.terminate THEN
		r:=ray.clr.r;
		g:=ray.clr.g;
		b:=ray.clr.b; 
	ELSE
		b:= ray.clr.b + ray.clr.ba;
		r:= ray.clr.r + ray.clr.ra/3;
		g:= ray.clr.g + ray.clr.ga/3
	END;
	Base.clamp3(r,g,b);	
	Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
	FOR i := 0 TO 1 DO
		FOR j := 0 TO 1 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;	
END tessa2;

PROCEDURE atrace(cam: Camera);
VAR

BEGIN

END atrace;

PROCEDURE ztraceu(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			tessa5(a);
			tessa5(b);
			tessa5(c);
			tessa5(d);
	ELSE
		l:=level-1;
		ztraceu(a,l);
		ztraceu(b,l);
		ztraceu(c,l);
		ztraceu(d,l) 	
	END;
END ztraceu;

PROCEDURE ztracef(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			x:=a.imx - W/2;
			y:=a.imy-H/2;		
			IF (~saccade)&((x*x+y*y)<FV) THEN	
				tessad5(a); 
			ELSE
				tessa5(a); 
			END;
			x:=b.imx - W/2;
			y:=b.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN	
				tessad5(b); 
			ELSE
				tessa5(b); 			
			END;			
			x:=c.imx - W/2;
			y:=c.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN		
				tessad5(c); 
			ELSE
				tessa5(c); 
			END;
			x:=d.imx - W/2;
			y:=d.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN	
				tessad5(d); 
			ELSE
				tessa5(d); 
			END; 
	ELSE
		l:=level-1;
		ztracef(a,l);
		ztracef(b,l);
		ztracef(c,l);
		ztracef(d,l) 	
	END;
END ztracef;

PROCEDURE ztraced(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			tessad5(a); 
			tessad5(b); 
			tessad5(c); 
			tessad5(d); 
	ELSE
		l:=level-1;
		ztraced(a,l);
		ztraced(b,l);
		ztraced(c,l);
		ztraced(d,l) 	
	END;
END ztraced;

BEGIN{ACTIVE, PRIORITY(Objects.Low)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		CASE TESSA OF
			  0: ztracef(cam,T); 
			| 1: ztraced(cam,T) 
			| 2: ztraceu(cam,T) 
		ELSE
		END;
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
	EDGE*: REAL;
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
	PATCH*:BOOLEAN;
	DETAIL: REAL;
	
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
(*	ray.dtheta:=dtheta;
	ray.dphi:=dphi;
*)	ray.downxyz:=Base.dward;
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
	ray.dtl:=Base.DTL*ray.dtl;
	ray.texdtl:=1;	
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
	foveaparameter:=ABS(foveaparameter-1);
	FV:=W*W/foveaparameter;
END moredetail;

PROCEDURE lessdetail*;
BEGIN
	foveaparameter:=(foveaparameter+1);
	IF foveaparameter>250 THEN foveaparameter:=250 END;
	FV:=W*W/foveaparameter	;
END lessdetail;

PROCEDURE decdetail*;
BEGIN
	DETAIL:=DETAIL*2/3;
END decdetail;

PROCEDURE incdetail*;
BEGIN
	DETAIL:=DETAIL*3/2;
END incdetail;

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

PROCEDURE lsu*;
BEGIN
	EDGE:=0
END lsu;

PROCEDURE lsd*;
BEGIN
	EDGE:=0.01
END lsd;

BEGIN
	Out.String("Retina loading...");
	Raster.InitMode(copy,Raster.srcCopy);	
	image := Graphics.LoadImage("granite.jpg", FALSE);
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b]);
		END
	END;	
	EDGE:=0.001;
	AFTER:=2;
 	FAST:=3;
 	DETAIL:=2000;
 	lsense:=0.2;
 	aperture.width:=1;
 	aperture.height:=1;
 	foveaparameter:=50;
 	Out.String("loaded...");	
END Retina.
