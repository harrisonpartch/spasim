MODULE Retina;
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics, WMRasterScale,  Rect := WMRectangles;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=3;        
	TS=9*8;  (*  TS MUST BE {size of unit tile} MULTIPLIED BY 2**T *)
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

PROCEDURE interpray(CONST ra,rb: Ray): Ray;
VAR
	r: Ray;
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
	r.texdtl:=1;	
	r.dxyz.x:= (ra.dxyz.x + rb.dxyz.x)/2;
	r.dxyz.y:= (ra.dxyz.y + rb.dxyz.y)/2;
	r.dxyz.z := (ra.dxyz.z + rb.dxyz.z)/2;	
	IF r.dxyz.x < 0 THEN r.di := FALSE  ELSE r.di := TRUE END; 
	IF r.dxyz.y < 0 THEN r.dj := FALSE  ELSE r.dj := TRUE END;
	IF r.dxyz.z < 0 THEN r.dk := FALSE  ELSE r.dk := TRUE END;		
	RETURN r;
END interpray;

PROCEDURE interpclr(CONST ra,rb: Base.Color): Base.Color;
VAR
	r: Base.Color;
BEGIN
	r.red:= (ra.red+rb.red)/2;
	r.green:= (ra.green+rb.green)/2;
	r.blue:= (ra.blue+rb.blue)/2;				
	RETURN r;
END interpclr;

PROCEDURE tessatile9(cam:Camera);	
VAR
	i,j,k,ia,ja: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 2,2 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 9,9 OF Base.Color;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[1,0],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[0,1],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[1,1],cam.theta+cam.dtheta,cam.phi+cam.dphi);			
	FOR ia:= 0 TO 1  DO
		FOR ja := 0 TO 1 DO 
			i:=ia*8; j:=ja*8;	
			Base.world.Shade(rays[ia,ja]);	
			IF rays[ia,ja].terminate THEN
				patch[i,j].red:=rays[ia,ja].clr.r;
				patch[i,j].green:=rays[ia,ja].clr.g;
				patch[i,j].blue:=rays[ia,ja].clr.b; 
			ELSE
				patch[i,j].blue:= rays[ia,ja].clr.b + rays[ia,ja].clr.ba;
				patch[i,j].red:= rays[ia,ja].clr.r + rays[ia,ja].clr.ra/3;
				patch[i,j].green:= rays[ia,ja].clr.g + rays[ia,ja].clr.ga/3 
			END
		END;
	END;		
	patch[0,4]:=interpclr(patch[0,0],patch[0,8]);
	patch[0,2]:=interpclr(patch[0,0],patch[0,4]); 
	patch[0,1]:=interpclr(patch[0,0],patch[0,2]);  
	patch[0,3]:=interpclr(patch[0,2],patch[0,4]);  	
	patch[0,6]:=interpclr(patch[0,4],patch[0,8]);  
	patch[0,5]:=interpclr(patch[0,4],patch[0,6]);  
	patch[0,7]:=interpclr(patch[0,6],patch[0,8]);  				
	patch[8,4]:=interpclr(patch[8,0],patch[8,8]);
	patch[8,2]:=interpclr(patch[8,0],patch[8,4]); 
	patch[8,1]:=interpclr(patch[8,0],patch[8,2]);  
	patch[8,3]:=interpclr(patch[8,2],patch[8,4]);  	
	patch[8,6]:=interpclr(patch[8,4],patch[8,8]);  
	patch[8,5]:=interpclr(patch[8,4],patch[8,6]);  
	patch[8,7]:=interpclr(patch[8,6],patch[8,8]);  			
	FOR j := 0 TO 8 DO
		patch[4,j]:= interpclr(patch[0,j],patch[8,j]);		
		patch[2,j]:= interpclr(patch[0,j],patch[4,j]);				
		patch[1,j]:= interpclr(patch[0,j],patch[2,j]);						
		patch[3,j]:= interpclr(patch[2,j],patch[4,j]);		
		patch[6,j]:= interpclr(patch[4,j],patch[8,j]);				
		patch[5,j]:= interpclr(patch[4,j],patch[6,j]);						
		patch[7,j]:= interpclr(patch[6,j],patch[8,j]);													
	END;												
	FOR i:=0 TO 8 DO
		FOR j:= 0 TO 8 DO	
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessatile9;

PROCEDURE tessax9(cam:Camera);	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 5,5 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 9,9 OF Base.Color;
	ia,ib: LONGINT;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[4,0],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[0,4],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[4,4],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	rays[2,0]:=interpray(rays[0,0],rays[4,0]);
	rays[1,0]:=interpray(rays[0,0],rays[2,0]);	
	rays[3,0]:=interpray(rays[2,0],rays[4,0]);	
	rays[2,4]:=interpray(rays[0,4],rays[4,4]);
	rays[1,4]:=interpray(rays[0,4],rays[2,4]);	
	rays[3,4]:=interpray(rays[2,4],rays[4,4]);		
	FOR i := 0 TO 4 DO
		rays[i,2]:= interpray(rays[i,0],rays[i,4]);
		rays[i,1]:= interpray(rays[i,0],rays[i,2]);
		rays[i,3]:= interpray(rays[i,2],rays[i,4]);
	END;			
	FOR i:= 0 TO 4  DO
		FOR j := 0 TO 4 DO 
			Base.world.Shade(rays[i,j]);
			ia:=i*2; ib:=j*2;		
			IF rays[i,j].terminate THEN
				patch[ia,ib].red:=rays[i,j].clr.r;
				patch[ia,ib].green:=rays[i,j].clr.g;
				patch[ia,ib].blue:=rays[i,j].clr.b; 
			ELSE
				patch[ia,ib].blue:= rays[i,j].clr.b + rays[i,j].clr.ba;
				patch[ia,ib].red:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				patch[ia,ib].green:= rays[i,j].clr.g + rays[i,j].clr.ga/3 
			END
		END;
	END;		
	FOR i:= 0 TO 6 BY 2 DO 
		FOR j := 0 TO 6 BY 2 DO
			patch[i+1,j]:=interpclr(patch[i,j],patch[i+2,j]);
			patch[i+1,j+2]:=interpclr(patch[i,j+2],patch[i+2,j+2]);
		  	FOR k := 0 TO 2 DO
				patch[i+k,j+1]:= interpclr(patch[i+k,j],patch[i+k,j+2]);					
			END;				
		END;	 
	END;
	FOR i:=0 TO 8 DO
		FOR j:= 0 TO 8 DO	
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessax9;

PROCEDURE tessaxd9(cam:Camera);	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 9,9 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 9,9 OF Base.Color;
	ia,ib: LONGINT;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[8,0],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[0,8],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[8,8],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	rays[4,0]:=interpray(rays[0,0],rays[8,0]);
	rays[2,0]:=interpray(rays[0,0],rays[4,0]);
	rays[1,0]:=interpray(rays[0,0],rays[2,0]);	
	rays[3,0]:=interpray(rays[2,0],rays[4,0]);	
	rays[6,0]:=interpray(rays[4,0],rays[8,0]);
	rays[5,0]:=interpray(rays[4,0],rays[6,0]);	
	rays[7,0]:=interpray(rays[6,0],rays[8,0]);		
	rays[4,8]:=interpray(rays[0,8],rays[8,8]);
	rays[2,8]:=interpray(rays[0,8],rays[4,8]);
	rays[1,8]:=interpray(rays[0,8],rays[2,8]);	
	rays[3,8]:=interpray(rays[2,8],rays[4,8]);	
	rays[6,8]:=interpray(rays[4,8],rays[8,8]);
	rays[5,8]:=interpray(rays[4,8],rays[6,8]);	
	rays[7,8]:=interpray(rays[6,8],rays[8,8]);			
	FOR i := 0 TO 8 DO
		rays[i,4]:= interpray(rays[i,0],rays[i,8]);
		rays[i,2]:= interpray(rays[i,0],rays[i,4]);
		rays[i,1]:= interpray(rays[i,0],rays[i,2]);
		rays[i,3]:= interpray(rays[i,2],rays[i,4]);
		rays[i,6]:= interpray(rays[i,4],rays[i,8]);
		rays[i,5]:= interpray(rays[i,4],rays[i,6]);
		rays[i,7]:= interpray(rays[i,6],rays[i,8]);		
	END;			
	FOR i:= 0 TO 8  DO
		FOR j := 0 TO 8 DO 
			Base.world.Shade(rays[i,j]);	
			IF rays[i,j].terminate THEN
				patch[i,j].red:=rays[i,j].clr.r;
				patch[i,j].green:=rays[i,j].clr.g;
				patch[i,j].blue:=rays[i,j].clr.b; 
			ELSE
				patch[i,j].blue:= rays[i,j].clr.b + rays[i,j].clr.ba;
				patch[i,j].red:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				patch[i,j].green:= rays[i,j].clr.g + rays[i,j].clr.ga/3 
			END
		END;
	END;		
	FOR i:=0 TO 8 DO
		FOR j:= 0 TO 8 DO	
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessaxd9;

PROCEDURE tessaxhd9(cam:Camera);	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 9,9 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 9,9 OF Base.Color;
	ia,ib: LONGINT;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[8,0],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[0,8],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[8,8],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	rays[4,0]:=interpray(rays[0,0],rays[8,0]);
	rays[2,0]:=interpray(rays[0,0],rays[4,0]);
	rays[1,0]:=interpray(rays[0,0],rays[2,0]);	
	rays[3,0]:=interpray(rays[2,0],rays[4,0]);	
	rays[6,0]:=interpray(rays[4,0],rays[8,0]);
	rays[5,0]:=interpray(rays[4,0],rays[6,0]);	
	rays[7,0]:=interpray(rays[6,0],rays[8,0]);		
	rays[4,8]:=interpray(rays[0,8],rays[8,8]);
	rays[2,8]:=interpray(rays[0,8],rays[4,8]);
	rays[1,8]:=interpray(rays[0,8],rays[2,8]);	
	rays[3,8]:=interpray(rays[2,8],rays[4,8]);	
	rays[6,8]:=interpray(rays[4,8],rays[8,8]);
	rays[5,8]:=interpray(rays[4,8],rays[6,8]);	
	rays[7,8]:=interpray(rays[6,8],rays[8,8]);			
	FOR i := 0 TO 8 BY 2 DO
		rays[i,4]:= interpray(rays[i,0],rays[i,8]);
		rays[i,2]:= interpray(rays[i,0],rays[i,4]);
		rays[i,1]:= interpray(rays[i,0],rays[i,2]);
		rays[i,3]:= interpray(rays[i,2],rays[i,4]);
		rays[i,6]:= interpray(rays[i,4],rays[i,8]);
		rays[i,5]:= interpray(rays[i,4],rays[i,6]);
		rays[i,7]:= interpray(rays[i,6],rays[i,8]);		
	END;			
	FOR i:= 0 TO 8  BY 2 DO
		FOR j := 0 TO 8 DO 
			Base.world.Shade(rays[i,j]);	
			IF rays[i,j].terminate THEN
				patch[i,j].red:=rays[i,j].clr.r;
				patch[i,j].green:=rays[i,j].clr.g;
				patch[i,j].blue:=rays[i,j].clr.b; 
			ELSE
				patch[i,j].blue:= rays[i,j].clr.b + rays[i,j].clr.ba;
				patch[i,j].red:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				patch[i,j].green:= rays[i,j].clr.g + rays[i,j].clr.ga/3 
			END
		END;
	END;	
	FOR i:= 1 TO 7 BY 2 DO
		FOR j := 0 TO 8 DO 
			patch[i,j]:=interpclr(patch[i-1,j],patch[i+1,j]);	
		END
	END;	
	FOR i:=0 TO 8 DO
		FOR j:= 0 TO 8 DO	
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessaxhd9;

PROCEDURE tessaix9(cam:Camera);
	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 3,3 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
	patch: ARRAY 9,9 OF Base.Color;
	ia,ib: LONGINT;
	
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[2,0],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[0,2],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[2,2],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	rays[1,0]:=interpray(rays[0,0],rays[2,0]);
	rays[1,2]:=interpray(rays[0,2],rays[2,2]);	
	FOR i := 0 TO 2 DO
		rays[i,1]:= interpray(rays[i,0],rays[i,2]);
	END;			
	FOR i:= 0 TO 2  DO
		FOR j := 0 TO 2 DO 
			Base.world.Shade(rays[i,j]);
			ia:=i*4; ib:=j*4;		
			IF rays[i,j].terminate THEN
				patch[ia,ib].red:=rays[i,j].clr.r;
				patch[ia,ib].green:=rays[i,j].clr.g;
				patch[ia,ib].blue:=rays[i,j].clr.b; 
			ELSE
				patch[ia,ib].blue:= rays[i,j].clr.b + rays[i,j].clr.ba;
				patch[ia,ib].red:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				patch[ia,ib].green:= rays[i,j].clr.g + rays[i,j].clr.ga/3 
			END
		END;
	END;	
	FOR i:= 0 TO 4 BY 4 DO 
		FOR j := 0 TO 4 BY 4 DO
			patch[i+2,j]:=interpclr(patch[i,j],patch[i+4,j]);
			patch[i+1,j]:=interpclr(patch[i,j],patch[i+2,j]);  
 			patch[i+3,j]:=interpclr(patch[i+2,j],patch[i+4,j]);	
			patch[i+2,j+4]:=interpclr(patch[i,j+4],patch[i+4,j+4]);
			patch[i+1,j+4]:=interpclr(patch[i,j+4],patch[i+2,j+4]);  
 			patch[i+3,j+4]:=interpclr(patch[i+2,j+4],patch[i+4,j+4]);	
		  	FOR k := 0 TO 4 DO
				patch[i+k,j+2]:= interpclr(patch[i+k,j],patch[i+k,j+4]);
				patch[i+k,j+1]:= interpclr(patch[i+k,j],patch[i+k,j+2]);		
				patch[i+k,j+3]:= interpclr(patch[i+k,j+2],patch[i+k,j+4]);						
			END;				
		END;	 
	END;			
	FOR i:=0 TO 8 DO
		FOR j:= 0 TO 8 DO	
			Base.clamp3(patch[i,j].red,patch[i,j].green, patch[i,j].blue); 
			Raster.SetRGB(pixel,ENTIER(patch[i,j].red*GAMMA),ENTIER(patch[i,j].green*GAMMA),ENTIER(patch[i,j].blue*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END;		
END tessaix9;

PROCEDURE tessa9(cam: Camera);
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
	FOR i:=0 TO 8 DO 
		FOR j:= 0 TO 8 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END 
END tessa9;

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
			tessatile9(a);
			tessatile9(b);
			tessatile9(c);
			tessatile9(d);
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
	x,y,D: REAL;
	FVV:REAL;
BEGIN
	FVV:=5.5*FV;
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			x:=a.imx-W/2;
			y:=a.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FV THEN	
				tessaxhd9(a); 
			ELSIF D<FVV THEN
				tessax9(a);
			ELSE
				tessaix9(a); 
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FV THEN	
				tessaxhd9(b); 
			ELSIF D<FVV THEN
				tessax9(b);
			ELSE
				tessaix9(b); 
			END;
			x:=c.imx-W/2;
			y:=c.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FV THEN	
				tessaxhd9(c); 
			ELSIF D<FVV THEN
				tessax9(c);
			ELSE
				tessaix9(c); 
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FV THEN	
				tessaxhd9(d); 
			ELSIF D<FVV THEN
				tessax9(d);
			ELSE
				tessaix9(d); 
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
			tessaxhd9(a); 
			tessaxhd9(b); 
			tessaxhd9(c); 
			tessaxhd9(d); 
	ELSE
		l:=level-1;
		ztraced(a,l);
		ztraced(b,l);
		ztraced(c,l);
		ztraced(d,l) 	
	END;
END ztraced;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		CASE TESSA OF
			  0: ztraceu(cam,T); 
			| 1: IF ~saccade THEN ztraced(cam,T) ELSE ztraceu(cam,T) END;
			| 2: IF ~saccade THEN ztracef(cam,T) ELSE ztraceu(cam,T) END;
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
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=Base.DTL;
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
	foveaparameter:=foveaparameter-10;
	IF foveaparameter<1 THEN foveaparameter:=1 END;
	FV:=(W*W)/foveaparameter;
END moredetail;

PROCEDURE lessdetail*;
BEGIN
	foveaparameter:=(foveaparameter+10);
	IF foveaparameter>130 THEN foveaparameter:=130 END;
	FV:=(W*W)/foveaparameter;
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
