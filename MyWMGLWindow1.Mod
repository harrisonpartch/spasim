MODULE MyWMGLWindow1; (** AUTHOR "fnecati"; PURPOSE ""; *)
 (* Uses Vertex Arrays, and lightining *)
IMPORT
	WMRectangles, WMGraphics, Strings, Kernel,
	WM := WMWindowManager,  WMMessages, KernelLog, WMDialogs,
	SYSTEM, GL := OpenGL, GLC := OpenGLConst, GLContext;

CONST waittime=20;
TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow* =  OBJECT(WM.BufferWindow)
	VAR
		 timer: Kernel.MilliTimer; 

		alive, animated: BOOLEAN;		
		context : GLContext.Context;
		width, height: LONGINT;
		eyeposz: LONGREAL;
		drawMode:LONGINT; (* fill, lines, points *)
		light : BOOLEAN;
		angle: REAL;
		vboId, colorId, normalId : GL.GLuint;     (* ID of VBO for vertex arrays*)
		lightKa, lightKd, lightKs, lightPos : ARRAY [4] OF GL.GLfloat;	
		vertices, normals, colors: ARRAY [*] OF REAL ;
				
		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			width := w; height := h;
			Init(w, h, TRUE); (* use alpha, for 32bpp img *)
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});
			SetTitle(Strings.NewString("MyGLWindow1: "));
				
			animated := FALSE;
			angle := 30.0;	
			eyeposz := 1.0;
			drawMode := 0;
			light := TRUE;
		
			InitContext;
			alive := TRUE;
		  END New;
		  
		  PROCEDURE InitContext;
		  BEGIN
			NEW(context);
			context.Init(width, height, "MyGLWindow", FALSE);
			context.MakeCurrent();
				GL.ReadExtensions;
				initGL;
			context.DeActivate();
			DrawMode(0); 
			UpdateImage;			
		END InitContext;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);	     
		BEGIN

		CASE CHR(ucs) OF
			 "a", "A":  animated := ~ animated;   
			| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
			| "l": light := ~ light; 
					context.MakeCurrent();
					IF light THEN GL.glEnable(GLC.GL_LIGHTING ); ELSE  GL.glDisable(GLC.GL_LIGHTING ); END;
					context.DeActivate();					
					UpdateImage;			
			| "-" : angle := angle - 5.0; UpdateImage;
			| "+" : angle := angle+ 5.0; UpdateImage;
			| "s": SaveImage;
			| "q" : Close;
		ELSE	

		END;	
		END KeyEvent;

		PROCEDURE WheelMove*(dz : LONGINT);
		BEGIN
			eyeposz := eyeposz + dz;
			Reshape;
			UpdateImage;
		END WheelMove;		

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;


		PROCEDURE Close*;
		BEGIN
			alive := FALSE;	
			Close^;			
			 context.Close;
			 context := NIL;
			window := NIL;
		END Close;

		PROCEDURE UpdateImage;	
		VAR	rect: WMRectangles.Rectangle;
		BEGIN {EXCLUSIVE}
			context.MakeCurrent();
				displayCB();
			     context.RenderInto(img); 
			context.DeActivate();

			rect := WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight());
			WMRectangles.MoveRel(rect, bounds.l, bounds.t);
			WMRectangles.ClipRect(rect, bounds);
			manager.AddDirty(rect);
			
			(* Invalidate(WMRectangles.MakeRect(0, 0, width, height));*)
		END UpdateImage;

		PROCEDURE SaveImage;
		VAR res: LONGINT;
			fname: ARRAY 128 OF CHAR;
		BEGIN		
			fname:="mywmgltest.bmp";
			IF WMDialogs.QueryString(" Save File name: ",fname)=WMDialogs.ResOk THEN
					WMGraphics.StoreImage(img, fname,res);
			END;	
		END SaveImage;

		PROCEDURE Reshape();
		BEGIN 
			context.MakeCurrent();
			GL.glMatrixMode(GLC.GL_MODELVIEW);
			GL.glLoadIdentity();
			 GL.SetFCR();
				GL.gluLookAt(5, 5, eyeposz,   0, 0, 0,   0, 1, 0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *) 
			GL.DelFCR();
			  context.DeActivate();
		END Reshape;


PROCEDURE initLights();
BEGIN	
    (* set up light colors (ambient, diffuse, specular) *)

    lightKa := [0.2, 0.2, 0.2, 1.0];  (* ambient light*)
    lightKd := [0.7, 0.7, 0.7, 1.0];  (* diffuse light *)
    lightKs := [1.0, 1.0, 1.0, 1.0];  (* specular light *)
    lightPos := [1.0, 1.0, 1.0, 0.0]; (* positional light *)

  (*  lightKa[0] := 0.2; lightKa[1] := 0.2;  lightKa[2] := 0.2;  lightKa[3] := 1.0; 
    lightKd[0] := 0.7; lightKd[1] := 0.7; lightKd[2] := 0.7; lightKd[3] := 1.0;
    lightKs[0] := 1.0; lightKs[1] := 1.0; lightKs[2] := 1.0; lightKs[3] := 1.0; 
    lightPos[0] := 1.0; lightPos[1] := 1.0; lightPos[2] := 1.0; lightPos[3] := 0.0;
  *)  
    GL.glLightfv(GLC.GL_LIGHT0, GLC.GL_AMBIENT, SYSTEM.ADR(lightKa[0]));
    GL.glLightfv(GLC.GL_LIGHT0, GLC.GL_DIFFUSE, SYSTEM.ADR(lightKd[0]));
    GL.glLightfv(GLC.GL_LIGHT0, GLC.GL_SPECULAR, SYSTEM.ADR(lightKs[0]));

    (* position the light*)
    GL.glLightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, SYSTEM.ADR(lightPos[0]));

    GL.glEnable(GLC.GL_LIGHT0);       (* MUST enable each light source after configuration*)
   GL.glEnable(GLC.GL_LIGHTING);
END initLights;

PROCEDURE initGL();
BEGIN 
(* cube 
    v6------ v5
   /|             /|
  v1------v0 |
  | |            |  |
  | |v7-----|-|v4
  |/            | /
  v2------v3
*)

(* vertex coords array*)
	 vertices := [1.0,1.0,1.0,  -1.0,1.0,1.0,  -1.0,-1.0, 1.0 ,  1.0,-1.0,1.0,        (* v0-v1-v2-v3 *)
                      1.0,1.0,1.0,  1.0,-1.0,1.0,  1.0,-1.0,-1.0,  1.0,1.0,-1.0,        (* v0-v3-v4-v5 *)
                      1.0,1.0,1.0,  1.0,1.0,-1.0,  -1.0,1.0,-1.0,  -1.0,1.0,1.0,        (* v0-v5-v6-v1*)
                      -1.0,1.0,1.0,  -1.0,1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,-1.0,1.0,    (* v1-v6-v7-v2 *)
                      -1.0,-1.0,-1.0,  1.0,-1.0,-1.0,  1.0,-1.0,1.0,  -1.0,-1.0,1.0,    (* v7-v4-v3-v2 *)
                      1.0,-1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,1.0,-1.0,  1.0,1.0,-1.0];   (* v4-v7-v6-v5 *)

(* normal array *)
	normals := [0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0 ,  0.0, 0.0, 1.0,             (* v0-v1-v2-v3 *)
                     1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0, 1.0, 0.0, 0.0,              (* v0-v3-v4-v5 *)
                     0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0, 0.0, 1.0, 0.0,              (* v0-v5-v6-v1*)
                     -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,          (* v1-v6-v7-v2 *)
                     0.0, -1.0, 0.0,  0.0, -1.0, 0.0,  0.0, -1.0, 0.0,  0.0, -1.0, 0.0,         (* v7-v4-v3-v2 *)
                     0.0, 0.0, -1.0,  0.0, 0.0, -1.0,  0.0, 0.0, -1.0,  0.0, 0.0, -1.0];        (* v4-v7-v6-v5 *)

(* color array *)
	 colors := [1.0,1.0,1.0,  1.0,1.0,0.0,  1.0,0.0,0.0,  1.0,0.0,1.0 ,              (* v0-v1-v2-v3 *)
                    1.0,1.0,1.0,  1.0,0.0,1.0,  0.0,0.0,1.0,  0.0,1.0,1.0,              (* v0-v3-v4-v5 *)
                    1.0,1.0,1.0,  0.0,1.0,1.0,  0.0,1.0,0.0,  1.0,1.0,0.0,              (* v0-v5-v6-v1 *)
                    1.0,1.0,0.0,  0.0,1.0,0.0,  0.0,0.0,0.0,  1.0,0.0,0.0,              (* v1-v6-v7-v2 *)
                    0.0,0.0,0.0,  0.0,0.0,1.0,  1.0,0.0,1.0,  1.0,0.0,0.0,              (* v7-v4-v3-v2 *)
                    0.0,0.0,1.0,  0.0,0.0,0.0,  0.0,1.0,0.0,  0.0,1.0,1.0];             (* v4-v7-v6-v5 *)


 	(* create buffers *)        
        GL.glGenBuffersARB(1, SYSTEM.ADR(vboId));
        GL.glGenBuffersARB(1, SYSTEM.ADR(colorId));
        GL.glGenBuffersARB(1, SYSTEM.ADR(normalId)); 
          
        GL.glBindBufferARB(GLC.GL_ARRAY_BUFFER, vboId);
        GL.glBufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(vertices,0)*4, SYSTEM.ADR(vertices[0]), GLC.GL_STATIC_DRAW);
        GL.glVertexPointer(3, GLC.GL_FLOAT, 0, 0);
        
       
        GL.glBindBufferARB(GLC.GL_ARRAY_BUFFER, colorId);
        GL.glBufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(colors,0)*4, SYSTEM.ADR(colors[0]), GLC.GL_STATIC_DRAW);
        GL.glColorPointer(3, GLC.GL_FLOAT, 0, 0);
        
       
        GL.glBindBufferARB(GLC.GL_ARRAY_BUFFER, normalId);
        GL.glBufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(normals,0)*4, SYSTEM.ADR(normals[0]), GLC.GL_STATIC_DRAW);
         GL.glNormalPointer(GLC.GL_FLOAT, 0, 0);       


	GL.glClearColor(0.2, 0.1, 0.4, 1.0);                   (*  background color *)
    GL.glClearStencil(0);                          (* clear stencil buffer *)
    GL.glClearDepth(1.0);                         (*  0 is near, 1 is far *)
    GL.glDepthFunc(GLC.GL_LEQUAL);
	initLights();

   GL.glShadeModel(GLC.GL_SMOOTH);                    (* shading mathod: GL_SMOOTH or GL_FLAT*)
    GL.glPixelStorei(GLC.GL_UNPACK_ALIGNMENT, 4);     (* 4-byte pixel alignment *)

    (* enable /disable features *)
    GL.glHint(GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST);
    (* GL.glHint(GLC.GL_LINE_SMOOTH_HINT, GLC.GL_NICEST);*)
    (* GL.glHint(GLC.GL_POLYGON_SMOOTH_HINT, GLC.GL_NICEST); *)
    GL.glEnable(GLC.GL_DEPTH_TEST);
    GL.glEnable(GLC.GL_LIGHTING);
    GL.glEnable(GLC.GL_TEXTURE_2D);
    GL.glEnable(GLC.GL_CULL_FACE);

     (* track material ambient and diffuse from surface color, call it before glEnable(GL_COLOR_MATERIAL) *)
    GL.glColorMaterial(GLC.GL_FRONT_AND_BACK, GLC.GL_AMBIENT_AND_DIFFUSE);
    GL.glEnable(GLC.GL_COLOR_MATERIAL);

	 GL.glMatrixMode(GLC.GL_PROJECTION);
	 GL.glLoadIdentity();

(*GL.SetFCR();	 *)
	 GL.gluPerspective(45, 1, 1, 1000);
 
	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity();
	
GL.SetFCR();
	GL.gluLookAt(5, 5, eyeposz,   0, 0, 0,   0, 1, 0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *) 
GL.DelFCR();

END initGL;

PROCEDURE DrawMode(dm: LONGINT);
VAR drawMode: LONGINT;
BEGIN
	context.MakeCurrent();
	
	drawMode := dm;
        IF drawMode = 0 THEN       (* fill mode*)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
            GL.glEnable(GLC.GL_DEPTH_TEST);
            GL.glEnable(GLC.GL_CULL_FACE);
        ELSIF drawMode = 1 THEN  (* wireframe mode *)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
        ELSE                    (* point mode *)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
	  END;
context.DeActivate();	  
END DrawMode;

PROCEDURE displayCB();
BEGIN

    (* clear buffer *)
    GL.glClear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );

   (* draw a cube using vertex array method *)
    (* notice that only difference between VBO and VA is binding buffers and offsets *)
   
        (* enable vertex arrays *)
        GL.glEnableClientState(GLC.GL_VERTEX_ARRAY);        
        GL.glEnableClientState(GLC.GL_COLOR_ARRAY);
        GL.glEnableClientState(GLC.GL_NORMAL_ARRAY); 
        
		GL.glPushMatrix();
		GL.SetFCR();
			GL.glRotatef(angle, 0,0,1);
		GL.DelFCR(); 
	        GL.glDrawArrays(GLC.GL_QUADS, 0, 24); 
		GL.glPopMatrix();

        GL.glDisableClientState(GLC.GL_NORMAL_ARRAY);
        GL.glDisableClientState(GLC.GL_COLOR_ARRAY);
        GL.glDisableClientState(GLC.GL_VERTEX_ARRAY);  (* disable vertex arrays *)


  	GL.glFinish();
END displayCB;


BEGIN { ACTIVE } 
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		IF animated THEN			 
			 IF Kernel.Expired(timer) THEN  
			 	 UpdateImage();
			 	  angle := angle + 5.0;
				Kernel.SetTimer(timer, waittime);
			END;	
		END;
	END;	

END GLWindow;
	    		
VAR 
	window: GLWindow;
     
PROCEDURE Open*;
BEGIN
  IF window = NIL THEN
	NEW(window, 300, 300);
 END;	
END Open;

BEGIN
END MyWMGLWindow1.

SystemTools.Free  MyWMGLWindow1 GLContext ~

MyWMGLWindow1.Open ~
