MODULE GLU; (** AUTHOR ""; PURPOSE "UnixAos GLU binding"; *)

IMPORT Unix, Modules, GL := OpenGL, Strings, KernelLog;

VAR
	(* handle to library *)
	lib: ADDRESS;

CONST
	libname = 'libGLU.so.1';

TYPE
	Enum = GL.Enum;
	Boolean = GL.Boolean;
	Int = GL.Int;
	Float = GL.Float;
	Double = GL.Double;
	Pointer = ADDRESS;
	PPointer = ADDRESS;

	PFloat = ADDRESS; (*POINTER TO ARRAY OF Float; *)
	PDouble = ADDRESS; (* POINTER TO ARRAY OF Double;*)

	GLVector3d* = ADDRESS; (* ARRAY 3 OF Double; *)
	GLVector4i* = ADDRESS; (* ARRAY 4 OF Int; *)
	GLVector4f* = ADDRESS; (* ARRAY 4 OF Float; *)
	GLVector4p* = ADDRESS; (* ARRAY 4 OF Pointer; *)

	GLArray4f* = GLVector4f;  (* ARRAY OF GLVector4f; *)
	GLArray3d* = GLVector3d; (* ARRAY OF GLVector3d; *)
	GLArray4p* = GLVector4p; (* ARRAY OF GLVector4p; *)

	GLMatrix4f* = ADDRESS; (* ARRAY 4,4 OF Float; *)
	GLMatrix4d* = ADDRESS; (* ARRAY 4,4 OF Double; *)

	(* GLU types *)
	Nurbs* = ADDRESS;
	Quadric* =  ADDRESS;
	Tesselator* =  ADDRESS;


	(* QuadricCallback *)
	TQuadricErrorProc* = PROCEDURE{C}(errorCode: Enum);
	(* GLUTessCallback *)
	TTessBeginProc* = PROCEDURE{C}(AType: Enum);
	TTessEdgeFlagProc* = PROCEDURE{C}(Flag: Boolean);
	TTessVertexProc* = PROCEDURE{C}(VertexData: Pointer);
	TTessEndProc* = PROCEDURE{C};
	TTessErrorProc* = PROCEDURE{C}(ErrNo: Enum);
	TTessCombineProc* = PROCEDURE{C}(Coords: GLArray3d; VertexData: GLArray4p; Weight: GLArray4f; OutData: PPointer);
	TTessBeginDataProc* = PROCEDURE{C}(AType: Enum; UserData: Pointer);
	TTessEdgeFlagDataProc* = PROCEDURE{C}(Flag: Boolean; UserData: Pointer);
	TTessVertexDataProc* = PROCEDURE{C}(VertexData: Pointer; UserData: Pointer);
	TTessEndDataProc* = PROCEDURE{C}(UserData: Pointer);
	TTessErrorDataProc* = PROCEDURE{C}(ErrNo: Enum; UserData: Pointer);
	TTessCombineDataProc* = PROCEDURE{C}(Coords: GLArray3d; VertexData: GLArray4p; Weight: GLArray4f; OutData: PPointer; UserData: Pointer);
	(* NurbsCallback *)
	TNurbsErrorProc* = PROCEDURE{C}(ErrorCode: Enum);

CONST
	(*  GLU constants *)
	GLU_INVALID_ENUM* = 100900;
	GLU_INVALID_VALUE* = 100901;
	GLU_OUT_OF_MEMORY* = 100902;
	GLU_INCOMPATIBLE_GL_VERSION* = 100903;
	GLU_VERSION* = 100800;
	GLU_EXTENSIONS* = 100801;
	GLU_TRUE* = 1;  (* GL_TRUE *)
	GLU_FALSE* = 0;  (*GL_FALSE *)
	GLU_SMOOTH* = 100000;
	GLU_FLAT* = 100001;
	GLU_NONE* = 100002;
	GLU_POINT* = 100010;
	GLU_LINE* = 100011;
	GLU_FILL* = 100012;
	GLU_SILHOUETTE* = 100013;
	GLU_OUTSIDE* = 100020;
	GLU_INSIDE* = 100021;
	GLU_TESS_MAX_COORD* = 1.0D150;
	GLU_TESS_WINDING_RULE* = 100140;
	GLU_TESS_BOUNDARY_ONLY* = 100141;
	GLU_TESS_TOLERANCE* = 100142;
	GLU_TESS_WINDING_ODD* = 100130;
	GLU_TESS_WINDING_NONZERO* = 100131;
	GLU_TESS_WINDING_POSITIVE* = 100132;
	GLU_TESS_WINDING_NEGATIVE* = 100133;
	GLU_TESS_WINDING_ABS_GEQ_TWO* = 100134;
	GLU_TESS_BEGIN* = 100100; (*  TTessBeginProc *)
	GLU_TESS_VERTEX* = 100101; (*  TTessVertexProc *)
	GLU_TESS_END* = 100102; (*  TTessEndProc *)
	GLU_TESS_ERROR* = 100103; (*  TTessErrorProc *)
	GLU_TESS_EDGE_FLAG* = 100104; (*  TTessEdgeFlagProc *)
	GLU_TESS_COMBINE* = 100105; (*  TTessCombineProc *)
	GLU_TESS_BEGIN_DATA* = 100106; (*  TTessBeginDataProc *)
	GLU_TESS_VERTEX_DATA* = 100107; (*  TTessVertexDataProc *)
	GLU_TESS_END_DATA* = 100108; (*  TTessEndDataProc *)
	GLU_TESS_ERROR_DATA* = 100109; (*  TTessErrorDataProc *)
	GLU_TESS_EDGE_FLAG_DATA* = 100110; (* TTessEdgeFlagDataProc *)
	GLU_TESS_COMBINE_DATA* = 100111; (* TTessCombineDataProc *)
	GLU_TESS_ERROR1* = 100151;
	GLU_TESS_ERROR2* = 100152;
	GLU_TESS_ERROR3* = 100153;
	GLU_TESS_ERROR4* = 100154;
	GLU_TESS_ERROR5* = 100155;
	GLU_TESS_ERROR6* = 100156;
	GLU_TESS_ERROR7* = 100157;
	GLU_TESS_ERROR8* = 100158;
	GLU_TESS_MISSING_BEGIN_POLYGON* = GLU_TESS_ERROR1;
	GLU_TESS_MISSING_BEGIN_CONTOUR* = GLU_TESS_ERROR2;
	GLU_TESS_MISSING_END_POLYGON* = GLU_TESS_ERROR3;
	GLU_TESS_MISSING_END_CONTOUR* = GLU_TESS_ERROR4;
	GLU_TESS_COORD_TOO_LARGE* = GLU_TESS_ERROR5;
	GLU_TESS_NEED_COMBINE_CALLBACK* = GLU_TESS_ERROR6;
	GLU_AUTO_LOAD_MATRIX* = 100200;
	GLU_CULLING* = 100201;
	GLU_SAMPLING_TOLERANCE* = 100203;
	GLU_DISPLAY_MODE* = 100204;
	GLU_PARAMETRIC_TOLERANCE* = 100202;
	GLU_SAMPLING_METHOD* = 100205;
	GLU_U_STEP* = 100206;
	GLU_V_STEP* = 100207;
	GLU_PATH_LENGTH* = 100215;
	GLU_PARAMETRIC_ERROR* = 100216;
	GLU_DOMAIN_DISTANCE* = 100217;
	GLU_MAP1_TRIM_2* = 100210;
	GLU_MAP1_TRIM_3* = 100211;
	GLU_OUTLINE_POLYGON* = 100240;
	GLU_OUTLINE_PATCH* = 100241;
	GLU_NURBS_ERROR1* = 100251;
	GLU_NURBS_ERROR2* = 100252;
	GLU_NURBS_ERROR3* = 100253;
	GLU_NURBS_ERROR4* = 100254;
	GLU_NURBS_ERROR5* = 100255;
	GLU_NURBS_ERROR6* = 100256;
	GLU_NURBS_ERROR7* = 100257;
	GLU_NURBS_ERROR8* = 100258;
	GLU_NURBS_ERROR9* = 100259;
	GLU_NURBS_ERROR10* = 100260;
	GLU_NURBS_ERROR11* = 100261;
	GLU_NURBS_ERROR12* = 100262;
	GLU_NURBS_ERROR13* = 100263;
	GLU_NURBS_ERROR14* = 100264;
	GLU_NURBS_ERROR15* = 100265;
	GLU_NURBS_ERROR16* = 100266;
	GLU_NURBS_ERROR17* = 100267;
	GLU_NURBS_ERROR18* = 100268;
	GLU_NURBS_ERROR19* = 100269;
	GLU_NURBS_ERROR20* = 100270;
	GLU_NURBS_ERROR21* = 100271;
	GLU_NURBS_ERROR22* = 100272;
	GLU_NURBS_ERROR23* = 100273;
	GLU_NURBS_ERROR24* = 100274;
	GLU_NURBS_ERROR25* = 100275;
	GLU_NURBS_ERROR26* = 100276;
	GLU_NURBS_ERROR27* = 100277;
	GLU_NURBS_ERROR28* = 100278;
	GLU_NURBS_ERROR29* = 100279;
	GLU_NURBS_ERROR30* = 100280;
	GLU_NURBS_ERROR31* = 100281;
	GLU_NURBS_ERROR32* = 100282;
	GLU_NURBS_ERROR33* = 100283;
	GLU_NURBS_ERROR34* = 100284;
	GLU_NURBS_ERROR35* = 100285;
	GLU_NURBS_ERROR36* = 100286;
	GLU_NURBS_ERROR37* = 100287;
	GLU_CW* = 100120;
	GLU_CCW* = 100121;
	GLU_INTERIOR* = 100122;
	GLU_EXTERIOR* = 100123;
	GLU_UNKNOWN* = 100124;
	GLU_BEGIN* = GLU_TESS_BEGIN;
	GLU_VERTEX* = GLU_TESS_VERTEX;
	GLU_END* = GLU_TESS_END;
	GLU_ERROR* = GLU_TESS_ERROR;
	GLU_EDGE_FLAG* = GLU_TESS_EDGE_FLAG;

VAR
	GLU_VERSION_1_1* ,
	GLU_VERSION_1_2* ,
	GLU_VERSION_1_3* : BOOLEAN;

	(*! GLU utility functions *)
VAR

	XgluErrorString - : PROCEDURE{C}(errCode: Enum): ADDRESS; (* AnsiChar; *)
	XgluGetString - : PROCEDURE{C}(name: Enum): ADDRESS;
	Ortho2D - : PROCEDURE{C}(left, right, bottom, top: Double);
	Perspective - : PROCEDURE{C}(fovy, aspect, zNear, zFar: Double);
	PickMatrix - : PROCEDURE{C}(x, y, width, height: Double; CONST viewport: GLVector4i);
	LookAt - : PROCEDURE{C}(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: Double);
	Project - : PROCEDURE{C}(objx, objy, objz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; winx, winy, winz: PDouble): Int;
	UnProject - : PROCEDURE{C}(winx, winy, winz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; objx, objy, objz: PDouble): Int;
	ScaleImage - : PROCEDURE{C}(format: Enum; widthin, heightin: Int; typein: Enum; datain: Pointer; widthout, heightout: Int; typeout: Enum;  dataout: Pointer): Int;
	Build1DMipmaps - : PROCEDURE{C}(target: Enum; components, width: Int; format, atype: Enum;  data: Pointer): Int;
	Build2DMipmaps - : PROCEDURE{C}(target: Enum; components, width, height: Int; format, atype: Enum;  Data: Pointer): Int;
	NewQuadric - : PROCEDURE{C}(): Quadric;
	DeleteQuadric - : PROCEDURE{C}(state: Quadric);
	QuadricNormals - : PROCEDURE{C}(quadObject: Quadric; normals: Enum);
	QuadricTexture - : PROCEDURE{C}(quadObject: Quadric; textureCoords: Boolean);
	QuadricOrientation - : PROCEDURE{C}(quadObject: Quadric; orientation: Enum);
	QuadricDrawStyle - : PROCEDURE{C}(quadObject: Quadric; drawStyle: Enum);
	Cylinder - : PROCEDURE{C}(quadObject: Quadric; baseRadius, topRadius, height: Double; slices, stacks: Int);
	Disk - : PROCEDURE{C}(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int);
	PartialDisk - : PROCEDURE{C}(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int; startAngle, sweepAngle: Double);
	Sphere - : PROCEDURE{C}(quadObject: Quadric; radius: Double; slices, stacks: Int);
	QuadricCallback - : PROCEDURE{C}(quadObject: Quadric; which: Enum; fn: TQuadricErrorProc);
	NewTess - : PROCEDURE{C}(): Tesselator;
	DeleteTess - : PROCEDURE{C}(tess: Tesselator);
	TessBeginPolygon - : PROCEDURE{C}(tess: Tesselator; polygon_data: Pointer);
	TessBeginContour - : PROCEDURE{C}(tess: Tesselator);
	TessVertex - : PROCEDURE{C}(tess: Tesselator; CONST coords: GLArray3d; data: Pointer);
	TessEndContour - : PROCEDURE{C}(tess: Tesselator);
	TessEndPolygon - : PROCEDURE{C}(tess: Tesselator);
	TessProperty - : PROCEDURE{C}(tess: Tesselator; which: Enum; value: Double);
	TessNormal - : PROCEDURE{C}(tess: Tesselator; x, y, z: Double);
	TessCallback - : PROCEDURE{C}(tess: Tesselator; which: Enum; fn: Pointer);
	GetTessProperty - : PROCEDURE{C}(tess: Tesselator; which: Enum; value: PDouble);
	NewNurbsRenderer - : PROCEDURE{C}(): Nurbs;
	DeleteNurbsRenderer - : PROCEDURE{C}(nobj: Nurbs);
	BeginSurface - : PROCEDURE{C}(nobj: Nurbs);
	BeginCurve - : PROCEDURE{C}(nobj: Nurbs);
	EndCurve - : PROCEDURE{C}(nobj: Nurbs);
	EndSurface - : PROCEDURE{C}(nobj: Nurbs);
	BeginTrim - : PROCEDURE{C}(nobj: Nurbs);
	EndTrim - : PROCEDURE{C}(nobj: Nurbs);
	PwlCurve - : PROCEDURE{C}(nobj: Nurbs; count: Int; points: PFloat; stride: Int; atype: Enum);
	NurbsCurve - : PROCEDURE{C}(nobj: Nurbs; nknots: Int; knot: PFloat; stride: Int; ctlarray: PFloat; order: Int; atype: Enum);
	NurbsSurface - : PROCEDURE{C}(nobj: Nurbs; sknot_count: Int; sknot: PFloat; tknot_count: Int; tknot: PFloat; s_stride, t_stride: Int; ctlarray: PFloat; sorder, torder: Int; atype: Enum);
	LoadSamplingMatrices - : PROCEDURE{C}(nobj: Nurbs; CONST modelMatrix, projMatrix: GLMatrix4f; CONST viewport: GLVector4i);
	NurbsProperty - : PROCEDURE{C}(nobj: Nurbs; aproperty: Enum; value: Float);
	GetNurbsProperty - : PROCEDURE{C}(nobj: Nurbs; aproperty: Enum; value: PFloat);
	NurbsCallback - : PROCEDURE{C}(nobj: Nurbs; which: Enum; fn: TNurbsErrorProc);
	BeginPolygon - : PROCEDURE{C}(tess: Tesselator);
	NextContour - : PROCEDURE{C}(tess: Tesselator; atype: Enum);
	EndPolygon - : PROCEDURE{C}(tess: Tesselator);

(* wrapper procedures *)
PROCEDURE ErrorString*(errCode: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := XgluErrorString(errCode);
	RETURN GL.GetStringFromAddr(sadr);
END ErrorString;

PROCEDURE GetString*(name: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := XgluGetString(name);
	RETURN GL.GetStringFromAddr(sadr);
END GetString;

(* ---------------------------- *)
PROCEDURE ReadVersion*();
VAR
	Buffer: Strings.String;
	MajorVersion, MinorVersion: LONGINT;

	PROCEDURE isNumber(ch: CHAR): BOOLEAN;
	VAR val: LONGINT; res: BOOLEAN;
	BEGIN
		res := FALSE;
		val := ORD(ch);
		IF (val >= ORD("0")) & (val<=ORD("9")) THEN res := TRUE; END;
		RETURN res;
	END isNumber;

	PROCEDURE TrimAndSplitVersionString(CONST buffer: ARRAY OF CHAR; VAR Max, Min: LONGINT);
	VAR
		separator, i : LONGINT;
	BEGIN
		i := 0;
		separator := Strings.Pos('.', buffer);
		(* At least one number must be before and one after the dot. *)
		IF (separator > 0) & (separator < Strings.Length(buffer)) & ((isNumber(buffer[separator - 1])) &
		      isNumber(buffer[separator + 1])) THEN
		      Max := ORD(buffer[separator + 1]);
		      Min := ORD(buffer[separator - 1]);
		ELSE
		      Max := 0;
		      Min := 0;
		END;
	END TrimAndSplitVersionString;

BEGIN
	GLU_VERSION_1_1 := FALSE;
	GLU_VERSION_1_2 := FALSE;
	GLU_VERSION_1_3 := FALSE;

	IF XgluGetString # NIL THEN
		Buffer := GetString(GLU_VERSION);
		TrimAndSplitVersionString(Buffer^, MajorVersion, MinorVersion);
		GLU_VERSION_1_1 := TRUE;
		IF MinorVersion >= 2 THEN GLU_VERSION_1_2 := TRUE; END;
		IF MinorVersion >= 3 THEN GLU_VERSION_1_3 := TRUE; END;
	END;
END ReadVersion;

(** Wrapper for Unix.Dlsym *)
PROCEDURE GetProcAddress*( lib: ADDRESS;  CONST procName: ARRAY OF CHAR;  adr: ADDRESS );
BEGIN
	Unix.Dlsym(lib, procName, adr);
END GetProcAddress;

PROCEDURE InitGLU();
BEGIN
	lib := Unix.Dlopen(libname, 2);
	ASSERT(lib # 0, 102);

	(* load GLU functions *)
	GetProcAddress(lib, 'gluBeginCurve', ADDRESSOF( BeginCurve ));
	GetProcAddress(lib, 'gluBeginPolygon', ADDRESSOF( BeginPolygon ));
	GetProcAddress(lib, 'gluBeginSurface', ADDRESSOF( BeginSurface ));
	GetProcAddress(lib, 'gluBeginTrim', ADDRESSOF(  BeginTrim));
	GetProcAddress(lib, 'gluBuild1DMipmaps', ADDRESSOF( Build1DMipmaps ));
	GetProcAddress(lib, 'gluBuild2DMipmaps', ADDRESSOF( Build2DMipmaps ));
	GetProcAddress(lib, 'gluCylinder', ADDRESSOF( Cylinder ));
	GetProcAddress(lib, 'gluDeleteNurbsRenderer', ADDRESSOF( DeleteNurbsRenderer ));
	GetProcAddress(lib, 'gluDeleteQuadric', ADDRESSOF( DeleteQuadric ));
	GetProcAddress(lib, 'gluDeleteTess', ADDRESSOF( DeleteTess ));
	GetProcAddress(lib, 'gluDisk', ADDRESSOF( Disk ));
	GetProcAddress(lib, 'gluEndCurve', ADDRESSOF( EndCurve ));
	GetProcAddress(lib, 'gluEndPolygon', ADDRESSOF( EndPolygon ));
	GetProcAddress(lib, 'gluEndSurface', ADDRESSOF( EndSurface ));
	GetProcAddress(lib, 'gluEndTrim', ADDRESSOF( EndTrim ));
	GetProcAddress(lib, 'gluErrorString', ADDRESSOF( XgluErrorString ));
	GetProcAddress(lib, 'gluGetNurbsProperty', ADDRESSOF( GetNurbsProperty ));
	GetProcAddress(lib, 'gluGetString', ADDRESSOF( XgluGetString ));
	GetProcAddress(lib, 'gluGetTessProperty', ADDRESSOF( GetTessProperty ));
	GetProcAddress(lib, 'gluLoadSamplingMatrices', ADDRESSOF( LoadSamplingMatrices ));
	GetProcAddress(lib, 'gluLookAt', ADDRESSOF( LookAt ));
	GetProcAddress(lib, 'gluNewNurbsRenderer', ADDRESSOF( NewNurbsRenderer ));
	GetProcAddress(lib, 'gluNewQuadric', ADDRESSOF( NewQuadric ));
	GetProcAddress(lib, 'gluNewTess', ADDRESSOF( NewTess ));
	GetProcAddress(lib, 'gluNextContour', ADDRESSOF( NextContour ));
	GetProcAddress(lib, 'gluNurbsCallback', ADDRESSOF( NurbsCallback ));
	GetProcAddress(lib, 'gluNurbsCurve', ADDRESSOF( NurbsCurve ));
	GetProcAddress(lib, 'gluNurbsProperty', ADDRESSOF( NurbsProperty ));
	GetProcAddress(lib, 'gluNurbsSurface', ADDRESSOF( NurbsSurface ));
	GetProcAddress(lib, 'gluOrtho2D', ADDRESSOF( Ortho2D ));
	GetProcAddress(lib, 'gluPartialDisk', ADDRESSOF( PartialDisk ));
	GetProcAddress(lib, 'gluPerspective', ADDRESSOF( Perspective ));
	GetProcAddress(lib, 'gluPickMatrix', ADDRESSOF( PickMatrix ));
	GetProcAddress(lib, 'gluProject', ADDRESSOF( Project ));
	GetProcAddress(lib, 'gluPwlCurve', ADDRESSOF( PwlCurve ));
	GetProcAddress(lib, 'gluQuadricCallback', ADDRESSOF( QuadricCallback ));
	GetProcAddress(lib, 'gluQuadricDrawStyle', ADDRESSOF( QuadricDrawStyle ));
	GetProcAddress(lib, 'gluQuadricNormals', ADDRESSOF( QuadricNormals ));
	GetProcAddress(lib, 'gluQuadricOrientation', ADDRESSOF( QuadricOrientation ));
	GetProcAddress(lib, 'gluQuadricTexture', ADDRESSOF( QuadricTexture ));
	GetProcAddress(lib, 'gluScaleImage', ADDRESSOF( ScaleImage ));
	GetProcAddress(lib, 'gluSphere', ADDRESSOF( Sphere ));
	GetProcAddress(lib, 'gluTessBeginContour', ADDRESSOF( TessBeginContour ));
	GetProcAddress(lib, 'gluTessBeginPolygon', ADDRESSOF( TessBeginPolygon ));
	GetProcAddress(lib, 'gluTessCallback', ADDRESSOF( TessCallback ));
	GetProcAddress(lib, 'gluTessEndContour', ADDRESSOF( TessEndContour ));
	GetProcAddress(lib, 'gluTessEndPolygon', ADDRESSOF( TessEndPolygon ));
	GetProcAddress(lib, 'gluTessNormal', ADDRESSOF( TessNormal ));
	GetProcAddress(lib, 'gluTessProperty', ADDRESSOF( TessProperty ));
	GetProcAddress(lib, 'gluTessVertex', ADDRESSOF( TessVertex ));
	GetProcAddress(lib, 'gluUnProject', ADDRESSOF( UnProject ));
	KernelLog.String(libname); KernelLog.String(" loaded."); KernelLog.Ln;

END InitGLU;

PROCEDURE OnClose;
BEGIN
	IF lib # NIL THEN
		Unix.Dlclose(lib);
		KernelLog.String(libname); KernelLog.String(" unloaded."); KernelLog.Ln;
	END;
END OnClose;

BEGIN
	InitGLU();
	ReadVersion;
	Modules.InstallTermHandler(OnClose);
END GLU.
