MODULE WMSpaceSim3;

	IMPORT KernelLog := KernelLog, Inputs, Strings, WMRectangles,
	WM := WMWindowManager,  Modules, WMMessages,
	GL:=OpenGL, GLC:=OpenGLConst, WMGL := WMGLWindow,
	ML := Decoder3DS;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

TYPE
	(* our space simulation window object *)
	SpaceWindow = OBJECT(WMGL.Window)
	VAR
		model: ML.Model3D;
		textureId: GL.Uint;
		(* Absolute rotation values (0-359 degrees) and rotation increments for each frame *)
		rotationX, deltaXrotation: REAL;
		rotationY, deltaYrotation: REAL;
		rotationZ, deltaZrotation: REAL;

		(* Flag for rendering as lines or filled polygons *)
		filling: INTEGER;

		object:  ML.Object3D;
		fname: ARRAY 128 OF CHAR;

	PROCEDURE &New();
	BEGIN
		Init(640, 480, FALSE);
		WM.AddWindow(SELF, 100, 100);
		IncCount;
		rotationX := 0.0; deltaXrotation := 0.1;
		rotationY := 0.0;  deltaYrotation := 0.05;
		rotationZ := 0.0;  deltaZrotation := 0.03;
		filling := 1; (*0=OFF 1=ON *)
		NEW(object);


		fname := "opengloberon/spaceship.3ds";
		SetTitle(Strings.NewString(fname));
		IF ~OnLoad() THEN Close; RETURN END;
		UpdateImage();
	END New;

	(* Used to initialize OpenGL and to setup our world *)
	PROCEDURE OnLoad(): BOOLEAN;
	VAR loadok: BOOLEAN;
		ratio: LONGREAL;
	BEGIN
		ratio := GetWidth() / GetHeight();
		MakeCurrent();
		GL.ClearColor(0.0, 0.0, 0.0, 0.0);  (* This clear the background color to black *)
		GL.ShadeModel(GLC.GL_SMOOTH);  (* Type of shading for the polygons *)

		(* Viewport transformation *)
		GL.Viewport(0,0, GetWidth(), GetHeight());

		(* Projection transformation *)
		GL.MatrixMode(GLC.GL_PROJECTION);  (* Specifies which matrix stack is the target for matrix operations  *)
		GL.LoadIdentity;  (* We initialize the projection matrix as identity *)

		GL.Ortho(-50, 50, -50, 50, -1000, 1000);
	(*	GLU.Perspective(45.0, ratio,1.0,10000.0);  (* We define the "viewing volume" *)*)


		GL.Enable(GLC.GL_DEPTH_TEST);  (* We enable the depth test (also called z buffer) *)
		GL.PolygonMode (GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);  (* Polygon rasterization mode (polygon filled) *)

		GL.Enable(GLC.GL_TEXTURE_2D);  (* This Enable the Texture mapping *)

		loadok := ML.Import3DS(model, fname);
		IF ~loadok THEN
			KernelLog.String(fname);  KernelLog.String(' model file not loaded'); KernelLog.Ln;
			RETURN FALSE;
		END;

		textureId:=ML.LoadImage('opengloberon/spaceshiptexture.bmp');  (* The Function LoadImage() return the current texture ID *)

		(* If the last function returns -1 it means the file was not found so we exit from the program *)
		IF (textureId = -1) THEN
			KernelLog.String('Image file: spaceshiptexture.bmp not found'); KernelLog.Ln;
			RETURN FALSE;
		END;
		DeActivate();
		RETURN TRUE;
	END OnLoad;

	(* This routine must be called everytime we resize our window.*)
	PROCEDURE Reshape (w, h: LONGINT);
	VAR ratio: LONGREAL;
	BEGIN
		ratio := w /h;
		MakeCurrent();
		GL.Clear (GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);  (* We clear both the color and the depth buffer so to draw the next frame *)
		GL.Viewport(0,0,w, h);  (* Viewport transformation *)

		GL.MatrixMode(GLC.GL_PROJECTION);  (* Projection transformation *)
		GL.LoadIdentity;  (* We initialize the projection matrix as identity *)
		GL.Ortho(-50, 50, -50, 50, -1000, 1000);
	(*	GLU.Perspective(45.0, ratio,1.0,10000.0);*)

		DeActivate();
	END Reshape;

	(* Used to handle the keyboard input *)
	PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
	BEGIN
		CASE CHR(ucs) OF
			"q": Close;

			| ' ':
				deltaXrotation := 0.0;
				deltaYrotation := 0.0;
				deltaZrotation := 0.0;
				  UpdateImage();
			| 'r', 'R':
				IF filling = 0 THEN filling := 1 ELSE filling := 0; END;
				  UpdateImage();
		ELSE
			CASE keysym OF
				Inputs.KsLeft:       deltaYrotation := deltaYrotation + 0.05;   UpdateImage();
				| Inputs.KsRight:   deltaYrotation := deltaYrotation - 0.05;   UpdateImage();
				| Inputs.KsUp:      deltaXrotation := deltaXrotation + 0.05;   UpdateImage();
				| Inputs.KsDown:  deltaXrotation := deltaXrotation - 0.05; 	  UpdateImage();

			ELSE
			END;
		END;

	END KeyEvent;

	PROCEDURE Close;
	BEGIN
		Close^;
		DecCount
	END Close;

	PROCEDURE Handle(VAR m: WMMessages.Message);
	BEGIN
		IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
			Close;
		ELSE Handle^(m)
		END
	END Handle;

	PROCEDURE DrawObjectVert(object: ML.Object3D );
		VAR  i: LONGINT;
	BEGIN
		GL.Color3f(1.0, 0.0, 0.0);
		GL.Begin(GLC.GL_TRIANGLES);  (* glBegin and glEnd delimit the vertices that define a primitive (in our case triangles) *)

		IF object.numFaces > 0 THEN
			FOR i:=0 TO object.numVerts-1 DO
				(*----------------- FIRST VERTEX ----------------- *)
				(* Coordinates of the first vertex *)
				GL.Vertex3f(object.verts[i].x, object.verts[ i ].y, object.verts[ i].z);  (*Vertex definition *)

				(*----------------- SECOND VERTEX ----------------- *)
				(* Coordinates of the second vertex *)
				GL.Vertex3f(object.verts[i ].x, object.verts[i].y, object.verts[i].z);

				(*----------------- THIRD VERTEX ----------------- *)
				(* Coordinates of the Third vertex *)
				GL.Vertex3f(object.verts[i].x, object.verts[i].y, object.verts[i].z);

			END;
		END;

		GL.End;

	END DrawObjectVert;

	PROCEDURE DrawObjectTextured(object: ML.Object3D );
	VAR i: LONGINT;
	BEGIN
		GL.BindTexture(GLC.GL_TEXTURE_2D, textureId);  (* We set the active texture  *)
		GL.Begin(GLC.GL_TRIANGLES);  (* glBegin and glEnd delimit the vertices that define a primitive (in our case triangles) *)

			FOR i:=0 TO object.numFaces-1 DO
				(*----------------- FIRST VERTEX ----------------- *)
				(* Texture coordinates of the first vertex *)
				GL.TexCoord2f(object.texVerts[ object.faces[i].a].x, object.texVerts[ object.faces[i].a ].y);
				(* Coordinates of the first vertex *)
				GL.Vertex3f(object.verts[ object.faces[i].a ].x, object.verts[ object.faces[i].a ].y, object.verts[ object.faces[i].a ].z);  (*Vertex definition *)

				(*----------------- SECOND VERTEX ----------------- *)
				(* Texture coordinates of the second vertex *)
				GL.TexCoord2f(object.texVerts[ object.faces[i].b ].x, object.texVerts[ object.faces[i].b ].y);
				(* Coordinates of the second vertex *)
				GL.Vertex3f(object.verts[ object.faces[i].b ].x, object.verts[ object.faces[i].b ].y, object.verts[ object.faces[i].b ].z);

				(*----------------- THIRD VERTEX ----------------- *)
				(* Texture coordinates of the third vertex *)
				GL.TexCoord2f(object.texVerts[ object.faces[i].c ].x, object.texVerts[ object.faces[i].c ].y);
				(* Coordinates of the Third vertex *)
				GL.Vertex3f(object.verts[ object.faces[i].c ].x, object.verts[ object.faces[i].c ].y, object.verts[ object.faces[i].c ].z);
		END;

		GL.End;

	END DrawObjectTextured;

	(* This is our main rendering subroutine, called each frame *)
	PROCEDURE Display;
	VAR j: LONGINT;
	BEGIN
		IF filling = 1 THEN
			GL.PolygonMode (GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);  (* Polygon rasterization mode (polygon filled) *)
		ELSE
			GL.PolygonMode (GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);  (* Polygon rasterization mode (polygon outlined) *)
		END;

		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);  (* This clear the background color to dark blue *)
		GL.MatrixMode(GLC.GL_MODELVIEW);  (* Modeling transformation *)
		GL.LoadIdentity;  (* Initialize the model matrix as identity *)

		GL.Translatef(0.0, 0.0, -300);  (* We move the object forward (the model matrix is multiplied by the translation matrix) *)

		rotationX := rotationX + deltaXrotation;
		rotationY := rotationY + deltaYrotation;
		rotationZ := rotationZ + deltaZrotation;

		IF rotationX > 359.0 THEN
			rotationX := 0.0;
		END;
		IF rotationY > 359.0 THEN
			rotationY := 0.0;
		END;
		IF rotationZ > 359.0 THEN
			rotationZ := 0.0;
		END;

		GL.Rotatef(rotationX, 1.0, 0.0, 0.0);  (* Rotations of the object (the model matrix is multiplied by the rotation matrices) *)
		GL.Rotatef(rotationY, 0.0,1.0, 0.0);
		GL.Rotatef(rotationZ, 0.0, 0.0,1.0);



		FOR j := 0 TO model.objects.GetCount()-1 DO
			object := model.objects.GetItem(j)(ML.Object3D);
			IF object.numTexVerts = 0  THEN
				DrawObjectVert(object)
			ELSE
				DrawObjectTextured(object);
			END;
		END;
	END Display;

	(** *)
	PROCEDURE UpdateImage;
	VAR
	BEGIN
		MakeCurrent();
			Display;
		SwapGLBuffer();
		DeActivate();
		Swap();
		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

BEGIN

END SpaceWindow;

VAR
	nofWindows : LONGINT;

(** Open window command procedure *)
PROCEDURE Open*;
VAR win : SpaceWindow;
BEGIN
	NEW(win);
END Open;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows)
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows)
END DecCount;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN {EXCLUSIVE}
	NEW(die);
	msg.ext := die;
	msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0)
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup);
END WMSpaceSim3.


WMSpaceSim3.Open ~


System.Free WMSpaceSim3 ~

System.FreeDownTo OpenGLConst ~


