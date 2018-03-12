MODULE GLShaderUtils; (** AUTHOR "fnecati"; PURPOSE "OpenGL GLSL utils "; *)

IMPORT
	gl := OpenGL, glc := OpenGLConst, Files, Strings, Streams, KernelLog;

CONST
	debug = FALSE;

TYPE

	Uint = gl.Uint;
	Int = gl.Int;

	Vector16f = ARRAY 16 OF REAL; (* 4x4 GLfloat Matrix *)

VAR
	wr: Streams.Writer;

(* write projection matrix *)
PROCEDURE WriteProjMatrixf*(CONST title: ARRAY OF CHAR);
VAR i: LONGINT;
	v: Vector16f;
BEGIN
	gl.GetFloatv(glc.GL_PROJECTION_MATRIX, ADDRESSOF(v[0]));
	wr.String("-----------------"); wr.Ln;
	wr.String("Float PROJECTION_MATRIX: "); wr.String(title); wr.Ln;
	FOR i:=0 TO 15 DO
		wr.FloatFix(v[i], 10,4,0);
	END;
	wr.Ln; wr.Update;
END WriteProjMatrixf;

(* write modelview matrix *)
PROCEDURE WriteModelMatrixf*(CONST title: ARRAY OF CHAR);
VAR i : LONGINT;
	v: Vector16f;
BEGIN
	gl.GetFloatv(glc.GL_MODELVIEW_MATRIX, ADDRESSOF(v[0]));
	wr.String("-----------------"); wr.Ln;
	wr.String("Float GL_MODELVIEW_MATRIX: ");wr.String(title); wr.Ln;
	FOR i:=0 TO 15 DO
		wr.FloatFix(v[i], 10,4,0);
	END;
	wr.Ln; wr.Update;
END WriteModelMatrixf;

(** read a text file and return it as String *)
PROCEDURE TextFileRead*(CONST fname: ARRAY OF CHAR): Strings.String;
VAR
	f: Files.File; rider: Files.Rider;
	str: Strings.String; len: LONGINT;
BEGIN
	f := Files.Old(fname);
	IF f #  NIL THEN
		len := f.Length();
		NEW(str, len+1);
		f.Set(rider, 0);
		f.ReadBytes(rider, str^, 0, len);
	END;
	RETURN str
END TextFileRead;

PROCEDURE PrintOpenGLError*(CONST title: ARRAY OF CHAR);
VAR glErr: gl.Enum;
	s: ARRAY 64 OF CHAR;
BEGIN
	glErr := gl.GetError();
	WHILE glErr # glc.GL_NO_ERROR DO
		IF glErr = glc.GL_INVALID_ENUM THEN s := "GL_INVALID_ENUM";
		ELSIF glErr = glc.GL_INVALID_VALUE THEN s := "GL_INVALID_VALUE";
		ELSIF glErr = glc.GL_INVALID_OPERATION THEN s := "GL_INVALID_OPERATION";
		ELSIF glErr = glc.GL_OUT_OF_MEMORY THEN s := "GL_OUT_OF_MEMORY";

		 (*  GL_ARB_framebuffer_object *)
		ELSIF glErr = glc.GL_INVALID_FRAMEBUFFER_OPERATION THEN s := "GL_INVALID_FRAMEBUFFER_OPERATION";

		(*  GL_ARB_uniform_buffer_object *)
		ELSIF glErr = glc. GL_INVALID_INDEX THEN s := " GL_INVALID_INDEX";

		(*  GL_EXT_framebuffer_object *)
		ELSIF glErr = glc.GL_INVALID_FRAMEBUFFER_OPERATION_EXT THEN s := "GL_INVALID_FRAMEBUFFER_OPERATION_EXT";

		(*  WGL_ARB_make_current_read *)
		ELSIF glErr = glc.ERROR_INVALID_PIXEL_TYPE_ARB THEN s := "ERROR_INVALID_PIXEL_TYPE_ARB";
		ELSIF glErr = glc.ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB THEN s := "ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB";

		(*  WGL_ARB_create_context *)
		ELSIF glErr = glc.ERROR_INVALID_VERSION_ARB THEN s := "ERROR_INVALID_VERSION_ARB";

		(*  WGL_ARB_create_context_profile *)
		ELSIF glErr = glc.ERROR_INVALID_PROFILE_ARB THEN s := "ERROR_INVALID_PROFILE_ARB";
		 (*  WGL_EXT_make_current_read *)
		ELSIF glErr = glc. ERROR_INVALID_PIXEL_TYPE_EXT THEN s := " ERROR_INVALID_PIXEL_TYPE_EXT";

		ELSE
			s := "Unknown error ";
		END;

		wr.String(title);  wr.String(s); wr.Ln; wr.Update;
		glErr := gl.GetError();
	END;
END PrintOpenGLError;

PROCEDURE PrintShaderSource*(obj: Uint);
VAR sourceLength: LONGINT;
	ssource: Strings.String;
	sslength: gl.Sizei;
BEGIN
	gl.GetShaderiv(obj, glc.GL_SHADER_SOURCE_LENGTH, ADDRESSOF(sourceLength));
	(* wr.Int(obj, 0);  wr.String(" sourceLength= "); wr.Int(sourceLength, 0); wr.Ln; *)
	NEW(ssource, sourceLength);
	gl.GetShaderSource(obj, sourceLength, sslength, ADDRESSOF(ssource^[0]));
	wr.String("************** SOURCE *********************************"); wr.Ln;
	wr.String(ssource^); wr.Ln;
	wr.String("*******************************************************"); wr.Ln; wr.Update;
END PrintShaderSource;

PROCEDURE PrintShaderInfoLog*(CONST tit: ARRAY OF CHAR; obj: Uint);
VAR infologLength, charsWritten: LONGINT;
	logInfo: Strings.String;
	info: Strings.String;

BEGIN
	gl.GetShaderiv(obj, glc.GL_INFO_LOG_LENGTH, ADDRESSOF(infologLength));
	IF infologLength > 0 THEN
		NEW(info, infologLength);
		gl.GetShaderInfoLog(obj, infologLength, charsWritten, ADDRESSOF(info[0]));

		NEW(logInfo, infologLength + Strings.Length(tit) + 3);
		Strings.Append(logInfo^, tit); Strings.AppendChar(logInfo^, 0AX);
		Strings.Append(logInfo^, info^);

		wr.String(logInfo^); wr.Ln; wr.Update;
		info := NIL;
		logInfo := NIL;
	END;
END PrintShaderInfoLog;

PROCEDURE PrintProgramInfoLog*(obj: Uint);
VAR infologLength, charsWritten: LONGINT;
	infoLog: Strings.String;
BEGIN
	gl.GetProgramiv(obj, glc.GL_INFO_LOG_LENGTH, ADDRESSOF(infologLength));
	IF infologLength > 0 THEN
		NEW(infoLog, infologLength);
		gl.GetProgramInfoLog(obj, infologLength, charsWritten, ADDRESSOF(infoLog[0]));
		wr.String(infoLog^); wr.Ln; wr.Update;
		infoLog := NIL;
	END;
END PrintProgramInfoLog;

PROCEDURE CompileVertexShader*(CONST vertshader : ARRAY OF CHAR): Uint;
VAR
	vs: Uint;
	vertcompiled: Int;
	adr : ADDRESS;
BEGIN
	IF Strings.Length(vertshader) = 0 THEN RETURN -1 END;
	vs := gl.CreateShader(glc.GL_VERTEX_SHADER);

	(* Load source code strings into shaders *)
	adr := ADDRESSOF(vertshader[0]);
	gl.ShaderSource(vs, 1, ADDRESSOF(adr), 0);

	gl.CompileShader(vs);
	gl.GetShaderiv(vs, glc.GL_COMPILE_STATUS, ADDRESSOF(vertcompiled));
	IF vertcompiled = glc.GL_FALSE THEN
			KernelLog.String("ERROR: vertex shader is not compiled "); KernelLog.Ln;
			PrintShaderInfoLog("Vertex Shader:", vs);
			gl.DeleteShader(vs);
			RETURN -1;
	END;
	IF debug THEN
		PrintShaderSource(vs);
	END;
	RETURN vs;
END CompileVertexShader;

PROCEDURE CompileFragmentShader*(CONST fragshader: ARRAY OF CHAR): Uint;
VAR
	fs: Uint;
	fragcompiled: Int;;
	adr: ADDRESS;
BEGIN
	IF Strings.Length(fragshader) = 0 THEN RETURN -1 END;
	fs := gl.CreateShader(glc.GL_FRAGMENT_SHADER);
	adr := ADDRESSOF(fragshader[0]);
	gl.ShaderSource(fs, 1, ADDRESSOF(adr), 0);

	 (* Compile the fragment shader and print out the compiler log *)
	gl.CompileShader(fs);
	gl.GetShaderiv(fs, glc.GL_COMPILE_STATUS, ADDRESSOF(fragcompiled));
	IF fragcompiled = glc.GL_FALSE THEN
		KernelLog.String("ERROR: fragment shader is not compiled "); KernelLog.Ln;
		PrintShaderInfoLog("Fragment Shader:", fs);
		gl.DeleteShader(fs);
		RETURN -1;
	END;
	IF debug THEN
		PrintShaderSource(fs);
	END;

	RETURN fs;
END CompileFragmentShader;

PROCEDURE AttachAndLinkProgram*(prog, vs, fs: Uint): BOOLEAN;
VAR 	linked: Int;
BEGIN
	gl.AttachShader(prog, vs);
	gl.AttachShader(prog, fs);

	gl.LinkProgram(prog);
	gl.GetProgramiv(prog, glc.GL_LINK_STATUS, ADDRESSOF(linked));
	IF  linked = glc.GL_FALSE THEN
		KernelLog.String("ERROR: program is not linked"); KernelLog.Ln;
		PrintProgramInfoLog(prog);
	END;

	gl.DeleteShader(fs);
	gl.DeleteShader(vs);

	RETURN linked # glc.GL_FALSE;
END AttachAndLinkProgram;

PROCEDURE LoadTheseShaders*( CONST vertshader, fragshader: ARRAY OF CHAR;  VAR prog: Uint): BOOLEAN;
VAR
	vs, fs: Uint;
	res: BOOLEAN;
BEGIN
	res := FALSE;
	(* Create shaders *)
	vs := CompileVertexShader(vertshader);
	IF vs # -1 THEN
		fs := CompileFragmentShader(fragshader);
		IF fs # -1 THEN
			(* Create a program and attach the two compiled shaders *)
			prog := gl.CreateProgram();
			res := AttachAndLinkProgram(prog, vs, fs);
		END;
	END;

	RETURN res;
END LoadTheseShaders;

PROCEDURE LoadShadersFromFile*( CONST vertshaderFile, fragshaderFile: ARRAY OF CHAR): Uint;
VAR
	vss, fss: Strings.String; (* shader source pointers *)
	program: Uint;
	ok: BOOLEAN;
BEGIN
	program := 0;
	vss :=TextFileRead(vertshaderFile);
	IF vss # NIL THEN
		fss :=TextFileRead(fragshaderFile);
		IF fss # NIL THEN
			ok := LoadTheseShaders(vss^, fss^, program);
		END;
	END;
	RETURN program
END LoadShadersFromFile;

PROCEDURE LoadTheseShaders2*( CONST vertshader, fragshader: ARRAY OF CHAR; CONST locat0, locat1: ARRAY OF CHAR;  VAR prog: Uint): BOOLEAN;
VAR
	vs, fs: Uint;
	linked: Int;
BEGIN
	(* Create shaders *)
	linked := glc.GL_FALSE;
	vs := CompileVertexShader(vertshader);
	IF vs # -1 THEN
		fs := CompileFragmentShader(fragshader);
		IF fs # -1 THEN
			(* Create a program and attach the two compiled shaders *)
			prog := gl.CreateProgram();
			gl.BindAttribLocation(prog, 0, locat0);
			gl.BindAttribLocation(prog, 1, locat1);

			gl.AttachShader(prog, vs);
			gl.AttachShader(prog, fs);

			(* Link the program *)
			gl.LinkProgram(prog);
			gl.GetProgramiv(prog, glc.GL_LINK_STATUS, ADDRESSOF(linked));
			IF  linked = glc.GL_FALSE THEN
				KernelLog.String("ERROR: program is not linked"); KernelLog.Ln;
				PrintProgramInfoLog(prog);
			END;
			gl.DeleteShader(fs);
			gl.DeleteShader(vs);
		END;
	END;
	RETURN linked # glc.GL_FALSE;
END LoadTheseShaders2;

PROCEDURE LoadShadersFromFile2*( CONST vertshaderFile, fragshaderFile, locat0, locat1: ARRAY OF CHAR): Uint;
VAR
	vss, fss: Strings.String; (* shader source pointers *)
	program: Uint;
	ok: BOOLEAN;
BEGIN
	vss :=TextFileRead(vertshaderFile);
	IF vss # NIL THEN
		fss :=TextFileRead(fragshaderFile);
		IF fss # NIL THEN
			ok := LoadTheseShaders2(vss^, fss^, locat0, locat1, program);
			IF ~ ok THEN program := 0 END;
		END;
	END;
	RETURN program
END LoadShadersFromFile2;


BEGIN
	Streams.OpenWriter(wr, KernelLog.Send);
END GLShaderUtils.
