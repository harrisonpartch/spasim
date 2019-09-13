MODULE SPSMMath;
IMPORT Math:=MathL, Base;

CONST
	R = 100000;
	N = 1000;
	twopi = 2*Math.pi;
	dx = twopi/R;
	dtp = twopi/N;
	
TYPE 	
	PT=Base.PT;
	SPT=Base.SPT;
		
TYPE Quaternion*=RECORD
   x,y,z,w: REAL
 END;
	
VAR
	Sin,Cos: ARRAY R OF REAL;
	Norm: ARRAY N,N OF Base.PT;
	i, j: INTEGER;
	x,d, theta, phi: REAL;
	
PROCEDURE qlength(q: Quaternion):REAL;
BEGIN
	RETURN(Math.sqrt(q.x*q.x+q.y*q.y+q.z*q.z+q.w*q.w))
END qlength;

PROCEDURE qnorm(VAR q: Quaternion);
VAR
	l:REAL;
BEGIN
	l:=qlength(q);
	q.x:=q.x/l;
	q.y:=q.y/l;
	q.z:=q.z/l;
	q.w:=q.w/l
END qnorm;

PROCEDURE qconjugate(VAR q: Quaternion);
BEGIN
	q.x:= -q.x;
	q.y:=-q.y;
	q.z:=-q.z;
END qconjugate;

PROCEDURE qmul(VAR a,b,c: Quaternion);
BEGIN
     c.x := a.w*b.x	+a.x*b.w	+a.y*b.z		-a.z*b.y;
     c.y := a.w*b.y	-a.x*b.z	+a.y*b.w	+a.z*b.x;
     c.z:= 	a.w*b.z		+a.x*b.y	-a.y*b.x	+a.z*b.w;
     c.w:=a.w*b.w	-a.x*b.x	-a.y*b.y	-a.z-b.z;
END qmul;

PROCEDURE sin*(x: REAL): REAL;
VAR i: SIZE;
BEGIN
	i := ENTIER(x/dx) MOD R;
	RETURN Sin[i];	
END sin;

PROCEDURE cos*(x: REAL): REAL;
VAR i: SIZE;
BEGIN
	i := ENTIER(x/dx) MOD R;
	RETURN Cos[i];	
END cos;

PROCEDURE norm*(theta, phi: REAL):Base.PT;
BEGIN
	i := ENTIER(theta/dtp) MOD N;
	j := ENTIER(phi/dtp) MOD N;
	RETURN Norm[i,j];	
END norm;

PROCEDURE arccos*(x: REAL): REAL;
BEGIN
	RETURN(Math.arctan(Math.sqrt(ABS((1-x*x)/x))));
END arccos;

PROCEDURE arcsin*(x: REAL): REAL;
BEGIN
	RETURN(Math.arctan(Math.sqrt(ABS(x/(1-x*x)))));
END arcsin;

PROCEDURE orrot*(VAR a: Base.PT; b: Base.PT; theta: REAL);

(* ROTATION OF VECTORS. A ABOUT B. A,B ARE POINTS ON THE UNIT SPHERE. *)
VAR
	costheta, sintheta: REAL;
	x,y,z: REAL;
	u,v,w: REAL;
	uvula: REAL;	
BEGIN
(*	Base.normalizePT(a);
	Base.normalizePT(b); 
*)	costheta := Math.cos(theta); sintheta := Math.sin(theta);
	x:=a.x; y:=a.y; z:=a.z; 
	u:=b.x; w:=b.y; v:=b.z;
	uvula:= u*x+v*y+w*z;
	a.x := u*uvula + costheta*(x*(v*v+w*w)-u*(v*y+w*z))+ sintheta*(-w*y+v*z);
	a.y := v*uvula + costheta*(y*(u*u+w*w)-v*(u*x+w*z))+ sintheta*(w*x-u*z);
	a.z := w*uvula + costheta*(z*(u*u+v*v)-w*(u*x+v*y))+ sintheta*(-v*x+u*y);
END orrot;	

PROCEDURE Atan2* (x, y: REAL): REAL;
	VAR phi: REAL;
BEGIN
	IF (ABS(x) < 1.0) & (ABS(y) >= ABS(x * MAX(REAL))) THEN	(* y/x would overflow *)
		IF y >= 0.0 THEN phi := Math.pi/2
		ELSE phi := -Math.pi/2
		END
	ELSIF x > 0.0 THEN	(* 1st or 4th quadrant *)
		phi := Math.arctan(y/x)
	ELSIF x < 0.0 THEN	(* 2nd or 3rd quadrant *)
		phi := Math.arctan(y/x) + Math.pi
	END;
	RETURN phi
END Atan2;

PROCEDURE c2sph*(p: PT):SPT;  
VAR
	sp: SPT;
	x,y,z,r,s: REAL;
BEGIN
	x:= p.x-1/2;
	y:=p.y-1/2;
	z:=p.z-1/2;
	r:=Math.sqrt(x*x+y*y+z*z);
	s:=Math.sqrt(x*x+y*y);
	sp.len := r;
	sp.phi:=arccos(z/r);
	IF x<0 THEN
		sp.theta:=arcsin(y/s)
	ELSE
		sp.theta:=arcsin(y/s)
	END;
	RETURN sp
END c2sph;

BEGIN
	x := 0;  
	FOR i := 0 TO R-1 DO
		Sin[i] := Math.sin(x);
		IF Sin[i] = 0 THEN Sin[i] := 0.0000001 END;  (* Because we must avoid ever dividing by zero *)
		Cos[i] := Math.cos(x);
		IF Cos[i] = 0 THEN Cos[i] := 0.0000001 END;	(* in shaders                                                  *)
		x := x+dx;
	END;
	FOR i := 0 TO N-1 DO
		theta := twopi*i/N;
		FOR j := 0 TO N-1 DO
			phi := twopi*j/N;
			Norm[i,j].x := cos(theta)*sin(phi);
			Norm[i,j].y := sin(theta)*sin(phi);
			Norm[i,j].z := cos(theta);
		END
	END
END SPSMMath.