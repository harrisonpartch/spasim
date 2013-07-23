MODULE XNXLgeomobj; (** AUTHOR "fnecati"; PURPOSE "Adjusted for commandline run"; *)

IMPORT
	XNXLBase, GL:=OpenGL, GLC := OpenGLConst, XNXLGL,  Random;

TYPE 
	Voxel=XNXLBase.Voxel;
	PT=XNXLBase.PT;

TYPE gobj*=OBJECT(XNXLBase.V)
VAR
	dlist*: LONGINT;
	rot, drot: REAL;
	
PROCEDURE tick*;
BEGIN
	rot:=rot+drot;
END tick;	
	
PROCEDURE draw*(p: PT; scale: LONGINT; rot: REAL);
BEGIN
	XNXLGL.dlpush(p,scale,rot,dlist); 
END draw;
	
END gobj;


TYPE pcursor*=OBJECT(gobj)

PROCEDURE &init*;
VAR
	i:LONGINT;
	p,n,center: PT;
	r: REAL;
BEGIN
	center.x:=0; center.y:=0; center.z:=0;
	GL.SetFCR();
	dlist:=GL.glGenLists(1);
	GL.glNewList(dlist, GLC.GL_COMPILE); 
	GL.glDisable(GLC.GL_LIGHTING); 
	GL.glPointSize(3);
	GL.glBegin( GLC.GL_POINTS);	
	GL.glColor3f(0.0,0.0,0.0);
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2;
		GL.SetFCR();
		GL.glVertex3f(r,0,0);
	END;
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2;
		GL.SetFCR();
		GL.glVertex3f(0,0,r);	
	END;
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2;
		GL.SetFCR();
		GL.glVertex3f(0,r,0);	
	END;	
	GL.glColor3f(1.0,1.0,1.0);
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2+1/100;
		GL.SetFCR();
		GL.glVertex3f(r,0,0);
	END;
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2+1/100;
		GL.SetFCR();
		GL.glVertex3f(0,0,r);	
	END;
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		r:=i/49-1/2+1/100;
		GL.SetFCR();
		GL.glVertex3f(0,r,0);	
	END;		

	GL.glEnd();
	GL.glEndList();	
 GL.DelFCR();	
END init;

END pcursor;

TYPE psphere*=OBJECT(gobj)

PROCEDURE &init*;
VAR
	i:LONGINT;
	p,n,center: PT;
	r: REAL;
BEGIN
	center.x:=0; center.y:=0; center.z:=0;
	GL.SetFCR();
	dlist:=GL.glGenLists(1);
	GL.glNewList(dlist, GLC.GL_COMPILE); 
	GL.glDisable(GLC.GL_LIGHTING);	
	GL.glPointSize(10);
	GL.glBegin( GLC.GL_POINTS);	
	GL.glColor3f(1.0,0.0,0.0);
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		p:=XNXLBase.randPT();
		GL.SetFCR();
		GL.glVertex3f(p.x,p.y,p.z);
	END;
(*	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		XNXLBase.randsphPT(p,n,center,1/2);
		GL.SetFCR();
		GL.glVertex3f(p.x,p.y,p.z);
	END;
	GL.glColor3f(0.0,1.0,0.0);
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		XNXLBase.randsphPT(p,n,center,1/2);
		GL.SetFCR();
		GL.glVertex3f(p.x,p.y,p.z);
	END;
	GL.glColor3f(0.0,0.0,1.0);
	FOR i:=0 TO 50 DO	
		GL.DelFCR();
		XNXLBase.randsphPT(p,n,center,1/2);
		GL.SetFCR();
		GL.glVertex3f(p.x,p.y,p.z);
	END;
*)	
	GL.glEnd();
	GL.glEndList();	
 GL.DelFCR();	
END init;

END psphere;

TYPE sphere*=OBJECT(gobj)
VAR
	qObj: GL.TGLUQuadricObj;
		
PROCEDURE & init*;

BEGIN
	dlist:=GL.glGenLists(1);
	qObj := GL.gluNewQuadric();
	GL.gluQuadricCallback(qObj, GLC.GLU_ERROR, 0 );
	GL.gluQuadricDrawStyle(qObj, GLC.GLU_FILL); 
	GL.gluQuadricNormals(qObj, GLC.GLU_SMOOTH);
	GL.glNewList(dlist, GLC.GL_COMPILE);
		GL.gluSphere(qObj, 0.7, 15, 15);
	GL.glEndList();	
END init;
	
END sphere;

VAR
	rand*:Random.Generator;


BEGIN
	NEW(rand)
END XNXLgeomobj.

