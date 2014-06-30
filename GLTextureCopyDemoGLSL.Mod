MODULE GLTextureCopyDemoGLSL; (** AUTHOR "fnecati"; PURPOSE "Demo for Raster.Image to opengl texture transfer"; *)

IMPORT
	X11, Api := X11Api, GL:=OpenGL, GLC := OpenGLConst,  GLSL := GLShaderUtils, 
	KS := X11KeySymDef, Kernel, Commands, Strings, StdIO, Streams, Raster, Math, SYSTEM ;
	
(*
Opens a native X11 window and renders.
From command line, linux terminal, run with : aos  -x  GLTextureCopyDemoGLSL.Open
or
 from oberon window:   GLTextureCopyDemoGLSL.Open ~
*)

CONST
	debug = FALSE; (* for window creation/closing *)
	debugevents = FALSE; (* for testing events *)

TYPE
	Float = GL.Float;
	Uint = GL.Uint;
    	Int = GL.Int;
    	Ushort = GL.Ushort;
    	
VAR
	positionLocation, texcoordsLocation: Uint;
	passthroughProgram: Uint;
	
	
	timer : Kernel.MilliTimer;

	context: Commands.Context; (* StdIO context *)

	(* window variables *)
	display : X11.DisplayPtr;
	win : X11.Window ;
	visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)
	glctx : GL.GLXContext;  (* GL context *)

	gwa : Api.XWindowAttributes; (* get window attributes *)
	swa : Api.XSetWindowAttributes; (* set window attributes*)
	cmap : X11.Colormap; (* colormap for window *)
	compstatus: Api.ComposeStatus;

	width, height : LONGINT; (* size of window *)
	alive : BOOLEAN; (* for main loop control *)
	paused: BOOLEAN;

		textureimg: Raster.Image;
		
		anglez: REAL;
		freq: REAL;
		curprogram: Uint; (* current active program *)
		progname: ARRAY 32 OF CHAR;
		image: Uint; (* image texture name *)		

PROCEDURE MyVertexSource():Strings.String;
VAR sw: Streams.StringWriter;
      buf: Strings.String;
BEGIN
	NEW(sw,256);

	sw.String("attribute vec4 Position;"); sw.Ln;
	sw.String("attribute vec2 Texcoords;"); 	sw.Ln;
	sw.String("varying vec2 v_Texcoords;"); 	sw.Ln;
	
	sw.String("void main(void) {"); 		sw.Ln;
	sw.String("  v_Texcoords = Texcoords;"); 	sw.Ln;
	sw.String("  gl_Position = Position;"); 		sw.Ln;
	sw.String("}"); sw.Ln;
	
	NEW(buf, sw.Pos());
	sw.Get(buf^);
	RETURN buf;
END MyVertexSource;

PROCEDURE MyFragmentSource():Strings.String;
VAR sw: Streams.StringWriter;
      buf: Strings.String;
BEGIN
	NEW(sw,256);

	sw.String("varying vec2 v_Texcoords;"); sw.Ln;
	sw.String("uniform sampler2D u_image;"); 	sw.Ln;

	sw.String("void main(void) { "); 	sw.Ln;
	sw.String("  gl_FragColor = texture2D(u_image, v_Texcoords);"); sw.Ln;	
	sw.String("} "); 	sw.Ln;
	NEW(buf, sw.Pos());
	sw.Get(buf^);
	RETURN buf;
END MyFragmentSource;
		
PROCEDURE Display();
BEGIN

			GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT) ;
			
			GL.ActiveTexture(GLC.GL_TEXTURE0);
			GL.BindTexture(GLC.GL_TEXTURE_2D, image);

			GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);  (*  only first two can be used *)
			GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);  (* all of the above can be used*)
			
			 GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, textureimg.width, textureimg.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(textureimg.mem[0]));
			 GL.UseProgram(curprogram);
			 
			 (* VAO, shader program, and texture already bound *)
			GL.DrawElements(GLC.GL_TRIANGLES, 6, GLC.GL_UNSIGNED_SHORT, 0);
			
     GL.glXSwapBuffers(display, win);
END Display;


	PROCEDURE InitShader(CONST vertexShaderPath, fragmentShaderPath: ARRAY OF CHAR): Uint;
	VAR program: Uint;
		location: Int;
		w, h: REAL;
	BEGIN
		program := GLSL.LoadShaders(vertexShaderPath, fragmentShaderPath);
		GL.UseProgram(program);

		location := GL.GetUniformLocation(program, "u_image");
		IF location # -1 THEN GL.Uniform1i(location, 0); END;

		location := GL.GetUniformLocation(program, "u_step") ;
		w :=1.0/width; h := 1.0/height;
		IF location # -1 THEN GL.Uniform2f(location, w, h);  END;

		RETURN program;
	END InitShader;


	PROCEDURE InitTheseShaders(vertexShader, fragmentShader: Strings.String): Uint;
	VAR program: Uint;
		location: Int;
		w, h: REAL;
	BEGIN
		IF  ~GLSL.LoadTheseShaders(vertexShader, fragmentShader, program) THEN RETURN 0 END;
		GL.UseProgram(program);

		location := GL.GetUniformLocation(program, "u_image");
		IF location # -1 THEN GL.Uniform1i(location, 0); END;

		location := GL.GetUniformLocation(program, "u_step") ;
		w :=1.0/width; h := 1.0/height;
		IF location # -1 THEN GL.Uniform2f(location, w, h);  END;

		RETURN program;
	END InitTheseShaders;

	PROCEDURE InitVAO();
	VAR
		vertices, texcoords: ARRAY [8] OF Float;
		indices: ARRAY [6] OF Ushort;
		vao:  Uint;
		vertexBufferObjID: ARRAY [3] OF Uint;
		
	BEGIN
		(* A2 Image origin is top-left, opengl's image left-bottom; so, flip it *)
		vertices := [-1.0, -1.0, 	1.0, -1.0, 1.0, 1.0, -1.0, 1.0  ];
		texcoords := [1.0, 1.0,  0.0, 1.0,  0.0, 0.0,	1.0, 0.0 ]; 
		(*texcoords := [0.0, 1.0,  1.0, 1.0,  1.0, 0.0,	0.0, 0.0 ];*)
		
		indices := [ 0, 1, 3, 3, 1, 2 ]; 
		
		GL.GenVertexArrays(1, ADDRESSOF(vao));
		GL.BindVertexArray(vao);

		GL.GenBuffers(3, ADDRESSOF(vertexBufferObjID[0]));

		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, vertexBufferObjID[0]);
		GL.BufferData(GLC.GL_ARRAY_BUFFER, LEN(vertices,0)*SIZEOF(Float), ADDRESSOF(vertices[0]), GLC.GL_STATIC_DRAW);
		GL.VertexAttribPointer(positionLocation, 2, GLC.GL_FLOAT, GLC.GL_FALSE, 0, 0);
		GL.EnableVertexAttribArray(positionLocation);

		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, vertexBufferObjID[1]);
		GL.BufferData(GLC.GL_ARRAY_BUFFER, LEN(texcoords,0)*SIZEOF(Float), ADDRESSOF(texcoords[0]), GLC.GL_STATIC_DRAW);
		GL.VertexAttribPointer(texcoordsLocation, 2, GLC.GL_FLOAT, GLC.GL_FALSE, 0, 0);
		GL.EnableVertexAttribArray(texcoordsLocation);

		GL.BindBuffer(GLC.GL_ELEMENT_ARRAY_BUFFER, vertexBufferObjID[2]);
		GL.BufferData(GLC.GL_ELEMENT_ARRAY_BUFFER, LEN(indices,0)*SIZEOF(Ushort), ADDRESSOF(indices[0]), GLC.GL_STATIC_DRAW);


	END InitVAO;

		PROCEDURE InitGL(): BOOLEAN;
		VAR vs, fs: Strings.String; 
		BEGIN
		
			freq:= 10.0;
			
			anglez := 0.0; 
			
		GL.ReadExtensions();

 		GL.ReadCoreVersion;
 		IF ~GL.GL_VERSION_2_0 THEN
 			context.out.String("Error: your graphic card does not support OpenGL 2.0"); context.out.Ln; context.out.Update;
		 	RETURN FALSE;
		 END;
		
		positionLocation := 0;
		texcoordsLocation := 1;
		
		
		InitVAO();

			(* create Raster.Image object *)
			NEW(textureimg);
			Raster.Create(textureimg, 300, 300, Raster.BGRA8888);
			(* fill data *)
			ChangeData;
					
		(* create texture object for image *)
	 	GL.GenTextures(1, ADDRESSOF(image));
		GL.BindTexture(GLC.GL_TEXTURE_2D, image); 
	  	(* These determine how interpolation is made when image scaled down on up *)
		GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);
		GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);
		GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, textureimg.width, textureimg.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(textureimg.mem[0]));


	(*	passthroughProgram := InitShader("MyDemos/blur2/passthroughVS.glsl", "MyDemos/blur2/passthroughFS.glsl");*)
		vs := MyVertexSource();
		fs := MyFragmentSource();
		passthroughProgram := InitTheseShaders(vs, fs);
		IF passthroughProgram = 0 THEN		
			RETURN FALSE;
		END;
		progname:="passthroughProgram";
		curprogram := passthroughProgram;
						
		GL.UseProgram(curprogram);
		GL.ActiveTexture(GLC.GL_TEXTURE0);
		RETURN TRUE;
		END InitGL;

PROCEDURE Reshape(w, h: LONGINT);
BEGIN
	GL.Viewport(0, 0, w, h);
END Reshape;

(* close the window and its resources *)
 PROCEDURE Close;
  VAR res: LONGINT;
 BEGIN
	(* do we have a rendering context *)
	IF glctx # 0 THEN
		(* Release the context *)
	    	res := GL.glXMakeCurrent(display, 0, 0);
	    	(* Delete the context *)
		GL.glXDestroyContext(display, glctx);
		glctx := 0;
		IF debug THEN context.out.String("context deleted"); context.out.Ln; context.out.Update; END;
	END;

	(* do we have a window *)
	IF win # 0 THEN
		(* Unmap the window*)
		Api.UnmapWindow(display, win);
		(* Destroy the window *)
		res:= Api.DestroyWindow(display, win);
		win := 0;
		IF debug THEN context.out.String("window deleted"); context.out.Ln; context.out.Update; END;
	END;

	(* do we have a display *)
	IF display # 0 THEN
		res := Api.CloseDisplay(display);
		display := 0;
		IF debug THEN context.out.String("display deleted"); context.out.Ln; context.out.Update; END;
	END;

 END Close;

PROCEDURE  CreateWindow(w, h: LONGINT; CONST title: ARRAY OF CHAR);
VAR
	res: LONGINT;
	masks: LONGINT;
	buf: X11.Buffer;
	attrib : ARRAY [*] OF GL.Int;  (* attributes of GL window *)

BEGIN
 display := X11.OpenDisplay(0);
 IF display =0 THEN
 	context.out.String(" cannot connect to X server"); context.out.Ln; context.out.Update;
	Close;
     RETURN;
END;

(*  NEW(attrib, 7);
  attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DEPTH_SIZE; attrib[2] := 24;
  attrib[3] := GLC.GLX_STENCIL_SIZE; attrib[4] := 8;
  attrib[5] := GLC.GLX_DOUBLEBUFFER; attrib[6] := 0 ;
*)
(*
 attrib := [GLC.GLX_RGBA, GLC.GLX_DOUBLEBUFFER, GLC.GLX_DEPTH_SIZE,  24, 0];
 *)
  NEW(attrib, 13);
  attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DOUBLEBUFFER;
  attrib[2] := GLC.GLX_DEPTH_SIZE;	attrib[3] := 24;
  attrib[4] := GLC.GLX_STENCIL_SIZE;	attrib[5] := 8;
  attrib[6] := GLC.GLX_RED_SIZE;  	attrib[7] := 8;
  attrib[8] := GLC.GLX_GREEN_SIZE;	attrib[9] := 8;
  attrib[10] := GLC.GLX_RED_SIZE;	attrib[11] := 8;
  attrib[12] := 0 ;

 (* try to find a visual with this attribs *)
 visinfoptr := GL.glXChooseVisual(display, 0 , ADDRESSOF(attrib[0]));

 IF visinfoptr = NIL THEN
  	IF debug THEN context.out.String(" NO appropriate visual found"); context.out.Ln; context.out.Update; END;
  	Close;
     RETURN;
 ELSE
	 IF debug THEN
		 context.out.String("visinfoptr.depth= "); context.out.Int(visinfoptr.depth,0); context.out.Ln;
	 	context.out.String("visinfoptr.visual ");  context.out.Int(visinfoptr.visualID, 0); context.out.Ln;
	 	context.out.Update;
	END;
END;

 cmap := X11.CreateColormap(display, X11.DefaultRootWindow(display), visinfoptr.visual, X11.AllocNone);
 IF cmap = 0 THEN
 	IF debug THEN
	 	context.out.String(" cannot create colormap"); context.out.Ln;
	 	X11.GetErrorText(display, cmap, buf, LEN(buf));
	 	context.out.String("ERROR: CreateColormap = "); context.out.String(buf); context.out.Ln;
	 	context.out.Update;
 	END;
 END;

 (* window event masks *)
 masks :=  Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask + Api.ButtonReleaseMask + Api.PointerMotionMask +
 Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask;

  (* window attributes *)
 swa.backgroundPixel := 0;
 swa.borderPixel := 0;
 swa.colormap := cmap;
 swa.eventMask := masks;

 masks := Api.CWBackPixel + Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask;

 win := Api.CreateWindow(display, X11.DefaultRootWindow(display), 0, 0, w, h,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);

 (* show window *)
  Api.MapWindow(display, win);

 (* set title of window *)
 res := Api.StoreName(display, win, title);

(* create GL context *)
 (* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
 glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
	 IF debug THEN context.out.String("glXCreateContext glctx= "); context.out.Int(glctx, 0); context.out.Ln; END;

 res := GL.glXMakeCurrent(display, win, glctx);
	IF debug THEN  context.out.String("glXMakeCurrent res= "); context.out.Int(res, 0); context.out.Ln; END;

END CreateWindow;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN context.out.String(str); context.out.Ln; context.out.Update; END;
END Wr;

		PROCEDURE ChangeData;
		VAR i, j: LONGINT;
			z: REAL;
			pix : Raster.Pixel;
			mode : Raster.Mode;
			val: LONGINT;
		BEGIN
			Raster.InitMode(mode, Raster.srcCopy);
			
			freq := freq+1.0; IF freq > 30 THEN freq := 0.0; END;
			
			FOR j := 0 TO textureimg.height-1 DO
				FOR i:=0 TO textureimg.width-1 DO
					z := Math.sin(i*2*Math.pi*freq/textureimg.width);
					val := ENTIER(z*z*255);
					Raster.SetRGBA(pix, val, 255-val, val, 255);
					Raster.Put(textureimg, j, i, pix, mode);
				END;
			END;
		END ChangeData;



(* process pending X11 events *)
PROCEDURE LoopForEvents;
VAR xev: Api.XEvent;
	res: LONGINT;
	 ke: Api.XKeyEvent;
	 		 keysym: X11.KeySym;
		 buffer: ARRAY 32 OF CHAR;
		keycount: LONGINT;
BEGIN
 WHILE Api.Pending(display)>0 DO
	Api.NextEvent(display, xev);
			CASE xev.typ OF
			Api.Expose:
					res := Api.GetWindowAttributes(display, win, gwa);
					Reshape(gwa.width, gwa.height);
					Wr("Expose");
				| Api.KeyPress: Wr("KeyPress");
								ke := SYSTEM.VAL(Api.XKeyEvent, xev);
								keycount := Api.LookupString(ke, buffer, X11.BufferSize, keysym, compstatus );
	

								CASE keysym OF
									KS.XK_Escape, KS.XK_q1, KS.XK_Q: alive := FALSE;
							

								| KS.XK_Up:  anglez := anglez + 1.0; 
								| KS.XK_Down:  anglez := anglez - 1.0; 

								| KS.XK_plus: freq := freq+1.0; IF freq > 50 THEN freq := 50; END;ChangeData;
								| KS.XK_minus:  freq := freq - 1.0; IF freq<1 THEN freq := 1; END; ChangeData;
								| KS.XK_space: paused := ~ paused;
							

								ELSE
								END;
			| Api.SelectionNotify: Wr("SelectionNotify");


			ELSE
			END;
	   	END;
END LoopForEvents;

(* windows main loop *)
PROCEDURE MainLoop;
VAR	frames : LONGINT;
BEGIN
frames := 0;
Kernel.SetTimer(timer, 5000);
alive := TRUE;

WHILE  TRUE  DO
		(* process X11 events *)
		LoopForEvents;
		IF ~ paused THEN
			ChangeData();
			anglez := anglez + 1.0;
		END;	
		Display();


	 (* 	measure timing info
		INC(frames);
		IF Kernel.Expired(timer) THEN
			context.out.Int(frames,0); context.out.String(" frames in 5 secs.");
			context.out.String(" FPS = "); context.out.Int(frames DIV 5,0);
			context.out.Ln; context.out.Update;
			Kernel.SetTimer(timer,5000);
			frames := 0;
		END;*)
END;

END MainLoop;


PROCEDURE Open*;
BEGIN
	context := StdIO.env;

	width := 300; height := 300;
	CreateWindow(width, height, 'Fringe Data Demo' );

	IF ~ InitGL() THEN Close; RETURN END;
	(*Reshape(width, height );*)

	(* enter to main loop *)
	MainLoop; 

	GL.DeleteProgram(passthroughProgram);
	
	(* finally close the window *)	
	Close;
END Open;


BEGIN

END GLTextureCopyDemoGLSL.

GLTextureCopyDemoGLSL.Open~

SystemTools.Free GLTextureCopyDemoGLSL ~ 