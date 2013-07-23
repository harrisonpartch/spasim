MODULE GLU; (** AUTHOR ""; PURPOSE "WinAos GLU binding"; *)

IMPORT  Kernel32, Modules, GL := OpenGL, SYSTEM, Strings, KernelLog;

VAR
	 (* handle to library *)
	lib:LONGINT;

CONST
   	libname = 'glu32.dll';

TYPE

  Enum = GL.Enum;
  Boolean = GL.Boolean;
  Int = GL.Int;
  Float = GL.Float;
  Double = GL.Double;
  Pointer = GL.Pointer;
  PPointer = GL.PPointer;

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
  Nurbs* = LONGINT;
  Quadric* = LONGINT;
  Tesselator* = LONGINT;

  PNurbs* = ADDRESS; (* POINTER TO ARRAY OF Nurbs; *)
  PQuadric* = ADDRESS; (* POINTER TO ARRAY OF Quadric; *)
  PTesselator* = ADDRESS; (* POINTER TO ARRAY OF Tesselator; *)

  (* backwards compatibility *)
  NurbsObj* = Nurbs;
  QuadricObj* = Quadric;
  TesselatorObj* = Tesselator;
  TriangulatorObj* = Tesselator;
  PNurbsObj* = PNurbs;
  PQuadricObj* = PQuadric;
  PTesselatorObj* = PTesselator;
  PTriangulatorObj* = PTesselator;

  (* QuadricCallback *)
  TQuadricErrorProc* = PROCEDURE{WINAPI}(errorCode: Enum);
  (* GLUTessCallback *)
  TTessBeginProc* = PROCEDURE{WINAPI}(AType: Enum);
  TTessEdgeFlagProc* = PROCEDURE{WINAPI}(Flag: Boolean);
  TTessVertexProc* = PROCEDURE{WINAPI}(VertexData: Pointer);
  TTessEndProc* = PROCEDURE{WINAPI};
  TTessErrorProc* = PROCEDURE{WINAPI}(ErrNo: Enum);
  TTessCombineProc* = PROCEDURE{WINAPI}(Coords: GLArray3d; VertexData: GLArray4p; Weight: GLArray4f; OutData: PPointer);
  TTessBeginDataProc* = PROCEDURE{WINAPI}(AType: Enum; UserData: Pointer);
  TTessEdgeFlagDataProc* = PROCEDURE{WINAPI}(Flag: Boolean; UserData: Pointer);
  TTessVertexDataProc* = PROCEDURE{WINAPI}(VertexData: Pointer; UserData: Pointer);
  TTessEndDataProc* = PROCEDURE{WINAPI}(UserData: Pointer);
  TTessErrorDataProc* = PROCEDURE{WINAPI}(ErrNo: Enum; UserData: Pointer);
  TTessCombineDataProc* = PROCEDURE{WINAPI}(Coords: GLArray3d; VertexData: GLArray4p; Weight: GLArray4f; OutData: PPointer; UserData: Pointer);
  (* NurbsCallback *)
  TNurbsErrorProc* = PROCEDURE{WINAPI}(ErrorCode: Enum);

CONST
 (*  GLU constants *)
  GLU_INVALID_ENUM* = 100900;
  GLU_INVALID_VALUE* = 100901;
  GLU_OUT_OF_MEMORY* = 100902;
  GLU_INCOMPATIBLE_GL_VERSION* = 100903;
  GLU_VERSION* = 100800;
  GLU_EXTENSIONS* = 100801;
  GLU_TRUE* = 1;  (* GL.GL_TRUE *)
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
  GLU_TESS_BEGIN* = 100100; (*  TGLUTessBeginProc *)
  GLU_TESS_VERTEX* = 100101; (*  TGLUTessVertexProc *)
  GLU_TESS_END* = 100102; (*  TGLUTessEndProc *)
  GLU_TESS_ERROR* = 100103; (*  TGLUTessErrorProc *)
  GLU_TESS_EDGE_FLAG* = 100104; (*  TGLUTessEdgeFlagProc *)
  GLU_TESS_COMBINE* = 100105; (*  TGLUTessCombineProc *)
  GLU_TESS_BEGIN_DATA* = 100106; (*  TGLUTessBeginDataProc *)
  GLU_TESS_VERTEX_DATA* = 100107; (*  TGLUTessVertexDataProc *)
  GLU_TESS_END_DATA* = 100108; (*  TGLUTessEndDataProc *)
  GLU_TESS_ERROR_DATA* = 100109; (*  TGLUTessErrorDataProc *)
  GLU_TESS_EDGE_FLAG_DATA* = 100110; (* TGLUTessEdgeFlagDataProc *)
  GLU_TESS_COMBINE_DATA* = 100111; (* TGLUTessCombineDataProc *)
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

   XgluErrorString - : PROCEDURE{WINAPI}(errCode: Enum): ADDRESS; (* AnsiChar; *)
  XgluGetString - : PROCEDURE{WINAPI}(name: Enum): ADDRESS;
  XgluOrtho2D - : PROCEDURE{WINAPI}(left, right, bottom, top: Double);
  XgluPerspective - : PROCEDURE{WINAPI}(fovy, aspect, zNear, zFar: Double);
  XgluPickMatrix - : PROCEDURE{WINAPI}(x, y, width, height: Double; CONST viewport: GLVector4i);
  XgluLookAt - : PROCEDURE{WINAPI}(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: Double);
  XgluProject - : PROCEDURE{WINAPI}(objx, objy, objz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; winx, winy, winz: PDouble): Int;
  XgluUnProject - : PROCEDURE{WINAPI}(winx, winy, winz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; objx, objy, objz: PDouble): Int;
  XgluScaleImage - : PROCEDURE{WINAPI}(format: Enum; widthin, heightin: Int; typein: Enum; datain: Pointer; widthout, heightout: Int; typeout: Enum;  dataout: Pointer): Int;
  XgluBuild1DMipmaps - : PROCEDURE{WINAPI}(target: Enum; components, width: Int; format, atype: Enum;  data: Pointer): Int;
  XgluBuild2DMipmaps - : PROCEDURE{WINAPI}(target: Enum; components, width, height: Int; format, atype: Enum;  Data: Pointer): Int;
  XgluNewQuadric - : PROCEDURE{WINAPI}(): Quadric;
  XgluDeleteQuadric - : PROCEDURE{WINAPI}(state: Quadric);
  XgluQuadricNormals - : PROCEDURE{WINAPI}(quadObject: Quadric; normals: Enum);
  XgluQuadricTexture - : PROCEDURE{WINAPI}(quadObject: PQuadric; textureCoords: Boolean);
  XgluQuadricOrientation - : PROCEDURE{WINAPI}(quadObject: PQuadric; orientation: Enum);
  XgluQuadricDrawStyle - : PROCEDURE{WINAPI}(quadObject: Quadric; drawStyle: Enum);
  XgluCylinder - : PROCEDURE{WINAPI}(quadObject: Quadric; baseRadius, topRadius, height: Double; slices, stacks: Int);
  XgluDisk - : PROCEDURE{WINAPI}(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int);
  XgluPartialDisk - : PROCEDURE{WINAPI}(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int; startAngle, sweepAngle: Double);
  XgluSphere - : PROCEDURE{WINAPI}(quadObject: Quadric; radius: Double; slices, stacks: Int);
  XgluQuadricCallback - : PROCEDURE{WINAPI}(quadObject: Quadric; which: Enum; fn: ADDRESS (*TQuadricErrorProc*));
  XgluNewTess - : PROCEDURE{WINAPI}(): PTesselator;
  XgluDeleteTess - : PROCEDURE{WINAPI}(tess: PTesselator);
  XgluTessBeginPolygon - : PROCEDURE{WINAPI}(tess: PTesselator; polygon_data: Pointer);
  XgluTessBeginContour - : PROCEDURE{WINAPI}(tess: PTesselator);
  XgluTessVertex - : PROCEDURE{WINAPI}(tess: PTesselator; CONST coords: GLArray3d; data: Pointer);
  XgluTessEndContour - : PROCEDURE{WINAPI}(tess: PTesselator);
  XgluTessEndPolygon - : PROCEDURE{WINAPI}(tess: PTesselator);
  XgluTessProperty - : PROCEDURE{WINAPI}(tess: PTesselator; which: Enum; value: Double);
  XgluTessNormal - : PROCEDURE{WINAPI}(tess: PTesselator; x, y, z: Double);
  XgluTessCallback - : PROCEDURE{WINAPI}(tess: PTesselator; which: Enum; fn: Pointer);
  XgluGetTessProperty - : PROCEDURE{WINAPI}(tess: PTesselator; which: Enum; value: PDouble);
  XgluNewNurbsRenderer - : PROCEDURE{WINAPI}(): PNurbs;
  XgluDeleteNurbsRenderer - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluBeginSurface - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluBeginCurve - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluEndCurve - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluEndSurface - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluBeginTrim - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluEndTrim - : PROCEDURE{WINAPI}(nobj: PNurbs);
  XgluPwlCurve - : PROCEDURE{WINAPI}(nobj: PNurbs; count: Int; points: PFloat; stride: Int; atype: Enum);
  XgluNurbsCurve - : PROCEDURE{WINAPI}(nobj: PNurbs; nknots: Int; knot: PFloat; stride: Int; ctlarray: PFloat; order: Int; atype: Enum);
  XgluNurbsSurface - : PROCEDURE{WINAPI}(nobj: PNurbs; sknot_count: Int; sknot: PFloat; tknot_count: Int; tknot: PFloat; s_stride, t_stride: Int; ctlarray: PFloat; sorder, torder: Int; atype: Enum);
  XgluLoadSamplingMatrices - : PROCEDURE{WINAPI}(nobj: PNurbs; CONST modelMatrix, projMatrix: GLMatrix4f; CONST viewport: GLVector4i);
  XgluNurbsProperty - : PROCEDURE{WINAPI}(nobj: PNurbs; aproperty: Enum; value: Float);
  XgluGetNurbsProperty - : PROCEDURE{WINAPI}(nobj: PNurbs; aproperty: Enum; value: PFloat);
  XgluNurbsCallback - : PROCEDURE{WINAPI}(nobj: PNurbs; which: Enum; fn: TNurbsErrorProc);
  XgluBeginPolygon - : PROCEDURE{WINAPI}(tess: PTesselator);
  XgluNextContour - : PROCEDURE{WINAPI}(tess: PTesselator; atype: Enum);
  XgluEndPolygon - : PROCEDURE{WINAPI}(tess: PTesselator);

(* ---------------------------- *)
(* wrapper procedures *)

PROCEDURE ErrorString*(errCode: Enum): Strings.String;
VAR  sadr: LONGINT;
BEGIN
  	sadr := XgluErrorString(errCode);
	RETURN GL.GetStringFromAddr(sadr);
   END ErrorString;

PROCEDURE GetString*(name: Enum): Strings.String;
VAR  sadr: LONGINT;
BEGIN
  	sadr := XgluGetString(name);
	RETURN GL.GetStringFromAddr(sadr);
END GetString;

PROCEDURE Ortho2D*(left, right, bottom, top: Double);
BEGIN
	GL.SetFCR();
	XgluOrtho2D(left, right, bottom, top);
END Ortho2D;

 PROCEDURE Perspective*(fovy, aspect, zNear, zFar: Double);
 BEGIN
 	GL.SetFCR();
 	XgluPerspective(fovy, aspect, zNear, zFar);
 END Perspective;

 PROCEDURE PickMatrix*(x, y, width, height: Double; CONST viewport: GLVector4i);
 BEGIN
 	GL.SetFCR();
 	XgluPickMatrix(x, y, width, height, viewport);
 END PickMatrix;

 PROCEDURE LookAt*(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: Double);
 BEGIN
	GL.SetFCR();
	XgluLookAt (eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz);
 END LookAt;


  PROCEDURE Project*(objx, objy, objz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; winx, winy, winz: PDouble): Int;
  BEGIN
  	GL.SetFCR();
  	RETURN XgluProject(objx, objy, objz, modelMatrix, projMatrix, viewport, winx, winy, winz);
  END Project;

  PROCEDURE UnProject*(winx, winy, winz: Double; CONST modelMatrix: GLMatrix4d; CONST projMatrix: GLMatrix4d; CONST viewport: GLVector4i; objx, objy, objz: PDouble): Int;
  BEGIN
  	GL.SetFCR();
  	RETURN XgluUnProject(winx, winy, winz, modelMatrix, projMatrix, viewport, objx, objy, objz);
  END UnProject;

  PROCEDURE ScaleImage*(format: Enum; widthin, heightin: Int; typein: Enum; datain: Pointer; widthout, heightout: Int; typeout: Enum;  dataout: Pointer): Int;
  BEGIN
  	GL.SetFCR();
  	RETURN XgluScaleImage(format,  widthin, heightin, typein, datain, widthout, heightout,  typeout, dataout);
  END ScaleImage;

   PROCEDURE Build1DMipmaps*(target: Enum; components, width: Int; format, atype: Enum;  data: Pointer): Int;
   BEGIN
   	GL.SetFCR();
   	RETURN XgluBuild1DMipmaps (target, components, width, format, atype,  data);
   END Build1DMipmaps;

   PROCEDURE Build2DMipmaps*(target: Enum; components, width, height: Int; format, atype: Enum;  Data: Pointer): Int;
   BEGIN
   	GL.SetFCR();
  	 RETURN XgluBuild2DMipmaps(target, components, width, height, format, atype, Data)
   END Build2DMipmaps;

   PROCEDURE NewQuadric*(): Quadric;
   BEGIN
   	GL.SetFCR();
   	RETURN XgluNewQuadric();
   END NewQuadric;

   PROCEDURE DeleteQuadric*(state: Quadric);
   BEGIN
   	GL.SetFCR();
   	XgluDeleteQuadric(state);
   END DeleteQuadric;

  PROCEDURE QuadricNormals*(quadObject: Quadric; normals: Enum);
  BEGIN
  	GL.SetFCR();
  	XgluQuadricNormals(quadObject, normals);
  END QuadricNormals;

  PROCEDURE QuadricTexture*(quadObject: PQuadric; textureCoords: Boolean);
  BEGIN
  	GL.SetFCR();
  	XgluQuadricTexture(quadObject, textureCoords);
  END QuadricTexture;

  PROCEDURE QuadricOrientation*(quadObject: PQuadric; orientation: Enum);
  BEGIN
  	GL.SetFCR();
  	XgluQuadricOrientation(quadObject, orientation);
  END QuadricOrientation;

  PROCEDURE QuadricDrawStyle*(quadObject: Quadric; drawStyle: Enum);
  BEGIN
  	GL.SetFCR();
  	XgluQuadricDrawStyle(quadObject, drawStyle);
  END QuadricDrawStyle;

  PROCEDURE Cylinder*(quadObject: Quadric; baseRadius, topRadius, height: Double; slices, stacks: Int);
  BEGIN
  	GL.SetFCR();
  	XgluCylinder(quadObject, baseRadius, topRadius, height, slices, stacks);
  END Cylinder;

  PROCEDURE Disk*(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int);
  BEGIN
  	GL.SetFCR();
  	XgluDisk(quadObject, innerRadius, outerRadius, slices, loops);
  END Disk;

  PROCEDURE PartialDisk*(quadObject: Quadric; innerRadius, outerRadius: Double; slices, loops: Int; startAngle, sweepAngle: Double);
  BEGIN
  	GL.SetFCR();
  	XgluPartialDisk(quadObject, innerRadius, outerRadius, slices, loops, startAngle, sweepAngle);
  END PartialDisk;

  PROCEDURE Sphere*(quadObject: Quadric; radius: Double; slices, stacks: Int);
  BEGIN
  	GL.SetFCR();
  	XgluSphere(quadObject, radius, slices, stacks);
  END Sphere;

 PROCEDURE QuadricCallback*(quadObject: Quadric; which: Enum; fn: ADDRESS (*TQuadricErrorProc*));
 BEGIN
 	GL.SetFCR();
 	XgluQuadricCallback(quadObject, which,  fn)
 END QuadricCallback;

   PROCEDURE NewTess*(): PTesselator;
  BEGIN
  	GL.SetFCR();
  	RETURN XgluNewTess();
  END NewTess;

  PROCEDURE DeleteTess*(tess: PTesselator);
  BEGIN
  	XgluDeleteTess(tess);
  END DeleteTess;

  PROCEDURE TessBeginPolygon*(tess: PTesselator; polygon_data: Pointer);
  BEGIN
  	XgluTessBeginPolygon(tess, polygon_data);
  END TessBeginPolygon;

  PROCEDURE TessBeginContour*(tess: PTesselator);
  BEGIN
  	XgluTessBeginContour(tess);
  END TessBeginContour;

  PROCEDURE TessVertex*(tess: PTesselator; CONST coords: GLArray3d; data: Pointer);
  BEGIN
  	GL.SetFCR();
  	XgluTessVertex(tess,  coords,  data);
  END TessVertex;

   PROCEDURE TessEndContour*(tess: PTesselator);
   BEGIN
   	GL.SetFCR();
   	XgluTessEndContour(tess);
   END TessEndContour;

  PROCEDURE TessEndPolygon*(tess: PTesselator);
  BEGIN
  	GL.SetFCR();
  	XgluTessEndPolygon(tess);
  END TessEndPolygon;

  PROCEDURE TessProperty*(tess: PTesselator; which: Enum; value: Double);
  BEGIN
  	GL.SetFCR();
  	XgluTessProperty(tess, which, value);
  END TessProperty;

  PROCEDURE TessNormal*(tess: PTesselator; x, y, z: Double);
  BEGIN
  	GL.SetFCR();
  	XgluTessNormal(tess, x, y, z);
  END TessNormal;

  PROCEDURE TessCallback*(tess: PTesselator; which: Enum; fn: Pointer);
  BEGIN
  	GL.SetFCR();
  	XgluTessCallback(tess, which, fn);
  END TessCallback;


  PROCEDURE GetTessProperty*(tess: PTesselator; which: Enum; value: PDouble);
  BEGIN
  	XgluGetTessProperty(tess, which, value);
  END GetTessProperty;

  PROCEDURE NewNurbsRenderer*(): PNurbs;
  BEGIN
  	RETURN XgluNewNurbsRenderer()
  END NewNurbsRenderer;

  PROCEDURE DeleteNurbsRenderer*(nobj: PNurbs);
  BEGIN
  	XgluDeleteNurbsRenderer(nobj);
  END DeleteNurbsRenderer;

  PROCEDURE BeginSurface*(nobj: PNurbs);
  BEGIN
  	XgluBeginSurface(nobj);
  END BeginSurface;

  PROCEDURE BeginCurve*(nobj: PNurbs);
  BEGIN
  	XgluBeginCurve(nobj);
  END BeginCurve;

  PROCEDURE EndCurve*(nobj: PNurbs);
  BEGIN
  	XgluEndCurve(nobj);
  END EndCurve;

  PROCEDURE EndSurface*(nobj: PNurbs);
  BEGIN
  	XgluEndSurface(nobj);
  END EndSurface;

  PROCEDURE BeginTrim*(nobj: PNurbs);
  BEGIN
  	XgluBeginTrim(nobj);
  END BeginTrim;

  PROCEDURE EndTrim*(nobj: PNurbs);
  BEGIN
  	XgluEndTrim(nobj);
  END EndTrim;

  PROCEDURE PwlCurve*(nobj: PNurbs; count: Int; points: PFloat; stride: Int; atype: Enum);
  BEGIN
  	XgluPwlCurve(nobj, count, points, stride, atype);
  END PwlCurve;

  PROCEDURE NurbsCurve*(nobj: PNurbs; nknots: Int; knot: PFloat; stride: Int; ctlarray: PFloat; order: Int; atype: Enum);
  BEGIN
  	XgluNurbsCurve(nobj, nknots, knot, stride, ctlarray, order, atype);
  END NurbsCurve;


  PROCEDURE NurbsSurface*(nobj: PNurbs; sknot_count: Int; sknot: PFloat; tknot_count: Int; tknot: PFloat; s_stride, t_stride: Int; ctlarray: PFloat; sorder, torder: Int; atype: Enum);
  BEGIN
  	XgluNurbsSurface(nobj, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctlarray, sorder, torder, atype);
  END NurbsSurface;

  PROCEDURE LoadSamplingMatrices*(nobj: PNurbs; CONST modelMatrix, projMatrix: GLMatrix4f; CONST viewport: GLVector4i);
  BEGIN
  	XgluLoadSamplingMatrices(nobj, modelMatrix, projMatrix, viewport)
  END LoadSamplingMatrices;

  PROCEDURE NurbsProperty*(nobj: PNurbs; aproperty: Enum; value: Float);
  BEGIN
  	XgluNurbsProperty(nobj, aproperty, value);
  END NurbsProperty;

   PROCEDURE GetNurbsProperty*(nobj: PNurbs; aproperty: Enum; value: PFloat);
  BEGIN
  	XgluGetNurbsProperty(nobj, aproperty, value);
  END GetNurbsProperty;

   PROCEDURE NurbsCallback*(nobj: PNurbs; which: Enum; fn: TNurbsErrorProc);
  BEGIN
  	XgluNurbsCallback(nobj, which, fn);
  END NurbsCallback;


   PROCEDURE BeginPolygon*(tess: PTesselator);
   BEGIN
   	GL.SetFCR();
   	XgluBeginPolygon(tess);
   END BeginPolygon;

   PROCEDURE EndPolygon*(tess: PTesselator);
   BEGIN
		GL.SetFCR();
 	  	XgluEndPolygon(tess);
   END EndPolygon;

	PROCEDURE NextContour*(tess: PTesselator; atype: Enum);
	BEGIN
		GL.SetFCR();
		XgluNextContour(tess, atype);
	END NextContour ;

PROCEDURE ReadVersion*;
VAR
  Buffer: Strings.String;
  MajorVersion, MinorVersion: LONGINT;

	PROCEDURE isNumber(ch: CHAR): BOOLEAN;
	VAR
	      val: LONGINT;
	      res: BOOLEAN;
	BEGIN
		res := FALSE;
		val := ORD(ch);
		IF (val >= ORD("0")) & (val<=ORD("9")) THEN res := TRUE; END;
		RETURN res;
	END isNumber;


	PROCEDURE TrimAndSplitVersionString(CONST buffer: ARRAY OF CHAR; VAR Max, Min: LONGINT);
	 VAR
	    separator,i : LONGINT;
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

  (* GLU *)
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


PROCEDURE InitGLU*;
BEGIN

  lib := Kernel32.LoadLibrary(libname);
  ASSERT(lib # 0,102);

  (* load GLU functions *)
  IF lib # 0 THEN
    (* GLU ======================================================================== *)
     Kernel32.GetProcAddress(lib,  'gluBeginCurve', SYSTEM.VAL(ADDRESS, XgluBeginCurve ));
     Kernel32.GetProcAddress(lib,  'gluBeginPolygon', SYSTEM.VAL(ADDRESS, XgluBeginPolygon ));
     Kernel32.GetProcAddress(lib,  'gluBeginSurface', SYSTEM.VAL(ADDRESS, XgluBeginSurface ));
     Kernel32.GetProcAddress(lib,  'gluBeginTrim', SYSTEM.VAL(ADDRESS,  XgluBeginTrim));
     Kernel32.GetProcAddress(lib,  'gluBuild1DMipmaps', SYSTEM.VAL(ADDRESS, XgluBuild1DMipmaps ));
     Kernel32.GetProcAddress(lib,  'gluBuild2DMipmaps', SYSTEM.VAL(ADDRESS, XgluBuild2DMipmaps ));
     Kernel32.GetProcAddress(lib,  'gluCylinder', SYSTEM.VAL(ADDRESS, XgluCylinder ));
     Kernel32.GetProcAddress(lib,  'gluDeleteNurbsRenderer', SYSTEM.VAL(ADDRESS, XgluDeleteNurbsRenderer ));
     Kernel32.GetProcAddress(lib,  'gluDeleteQuadric', SYSTEM.VAL(ADDRESS, XgluDeleteQuadric ));
     Kernel32.GetProcAddress(lib,  'gluDeleteTess', SYSTEM.VAL(ADDRESS, XgluDeleteTess ));
     Kernel32.GetProcAddress(lib,  'gluDisk', SYSTEM.VAL(ADDRESS, XgluDisk ));
     Kernel32.GetProcAddress(lib,  'gluEndCurve', SYSTEM.VAL(ADDRESS, XgluEndCurve ));
     Kernel32.GetProcAddress(lib,  'gluEndPolygon', SYSTEM.VAL(ADDRESS, XgluEndPolygon ));
     Kernel32.GetProcAddress(lib,  'gluEndSurface', SYSTEM.VAL(ADDRESS, XgluEndSurface ));
     Kernel32.GetProcAddress(lib,  'gluEndTrim', SYSTEM.VAL(ADDRESS, XgluEndTrim ));
     Kernel32.GetProcAddress(lib,  'gluErrorString', SYSTEM.VAL(ADDRESS, XgluErrorString ));
     Kernel32.GetProcAddress(lib,  'gluGetNurbsProperty', SYSTEM.VAL(ADDRESS, XgluGetNurbsProperty ));
     Kernel32.GetProcAddress(lib,  'gluGetString', SYSTEM.VAL(ADDRESS, XgluGetString ));
     Kernel32.GetProcAddress(lib,  'gluGetTessProperty', SYSTEM.VAL(ADDRESS, XgluGetTessProperty ));
     Kernel32.GetProcAddress(lib,  'gluLoadSamplingMatrices', SYSTEM.VAL(ADDRESS, XgluLoadSamplingMatrices ));
     Kernel32.GetProcAddress(lib,  'gluLookAt', SYSTEM.VAL(ADDRESS, XgluLookAt ));
     Kernel32.GetProcAddress(lib,  'gluNewNurbsRenderer', SYSTEM.VAL(ADDRESS, XgluNewNurbsRenderer ));
     Kernel32.GetProcAddress(lib,  'gluNewQuadric', SYSTEM.VAL(ADDRESS, XgluNewQuadric ));
     Kernel32.GetProcAddress(lib,  'gluNewTess', SYSTEM.VAL(ADDRESS, XgluNewTess ));
     Kernel32.GetProcAddress(lib,  'gluNextContour', SYSTEM.VAL(ADDRESS, XgluNextContour ));
     Kernel32.GetProcAddress(lib,  'gluNurbsCallback', SYSTEM.VAL(ADDRESS, XgluNurbsCallback ));
     Kernel32.GetProcAddress(lib,  'gluNurbsCurve', SYSTEM.VAL(ADDRESS, XgluNurbsCurve ));
     Kernel32.GetProcAddress(lib,  'gluNurbsProperty', SYSTEM.VAL(ADDRESS, XgluNurbsProperty ));
     Kernel32.GetProcAddress(lib,  'gluNurbsSurface', SYSTEM.VAL(ADDRESS, XgluNurbsSurface ));
     Kernel32.GetProcAddress(lib,  'gluOrtho2D', SYSTEM.VAL(ADDRESS, XgluOrtho2D ));
     Kernel32.GetProcAddress(lib,  'gluPartialDisk', SYSTEM.VAL(ADDRESS, XgluPartialDisk ));
     Kernel32.GetProcAddress(lib,  'gluPerspective', SYSTEM.VAL(ADDRESS, XgluPerspective ));
     Kernel32.GetProcAddress(lib,  'gluPickMatrix', SYSTEM.VAL(ADDRESS, XgluPickMatrix ));
     Kernel32.GetProcAddress(lib,  'gluProject', SYSTEM.VAL(ADDRESS, XgluProject ));
     Kernel32.GetProcAddress(lib,  'gluPwlCurve', SYSTEM.VAL(ADDRESS, XgluPwlCurve ));
     Kernel32.GetProcAddress(lib,  'gluQuadricCallback', SYSTEM.VAL(ADDRESS, XgluQuadricCallback ));
     Kernel32.GetProcAddress(lib,  'gluQuadricDrawStyle', SYSTEM.VAL(ADDRESS, XgluQuadricDrawStyle ));
     Kernel32.GetProcAddress(lib,  'gluQuadricNormals', SYSTEM.VAL(ADDRESS, XgluQuadricNormals ));
     Kernel32.GetProcAddress(lib,  'gluQuadricOrientation', SYSTEM.VAL(ADDRESS, XgluQuadricOrientation ));
     Kernel32.GetProcAddress(lib,  'gluQuadricTexture', SYSTEM.VAL(ADDRESS, XgluQuadricTexture ));
     Kernel32.GetProcAddress(lib,  'gluScaleImage', SYSTEM.VAL(ADDRESS, XgluScaleImage ));
     Kernel32.GetProcAddress(lib,  'gluSphere', SYSTEM.VAL(ADDRESS, XgluSphere ));
     Kernel32.GetProcAddress(lib,  'gluTessBeginContour', SYSTEM.VAL(ADDRESS, XgluTessBeginContour ));
     Kernel32.GetProcAddress(lib,  'gluTessBeginPolygon', SYSTEM.VAL(ADDRESS, XgluTessBeginPolygon ));
     Kernel32.GetProcAddress(lib,  'gluTessCallback', SYSTEM.VAL(ADDRESS, XgluTessCallback ));
     Kernel32.GetProcAddress(lib,  'gluTessEndContour', SYSTEM.VAL(ADDRESS, XgluTessEndContour ));
     Kernel32.GetProcAddress(lib,  'gluTessEndPolygon', SYSTEM.VAL(ADDRESS, XgluTessEndPolygon ));
     Kernel32.GetProcAddress(lib,  'gluTessNormal', SYSTEM.VAL(ADDRESS, XgluTessNormal ));
     Kernel32.GetProcAddress(lib,  'gluTessProperty', SYSTEM.VAL(ADDRESS, XgluTessProperty ));
     Kernel32.GetProcAddress(lib,  'gluTessVertex', SYSTEM.VAL(ADDRESS, XgluTessVertex ));
     Kernel32.GetProcAddress(lib,  'gluUnProject', SYSTEM.VAL(ADDRESS, XgluUnProject ));

      KernelLog.String(libname); KernelLog.String(" loaded."); KernelLog.Ln;

  END;


END InitGLU;


PROCEDURE OnClose;
VAR res: LONGINT;
BEGIN
 IF lib # Kernel32.NULL THEN
        res := Kernel32.FreeLibrary(lib);
     KernelLog.String(libname); KernelLog.String(" unloaded."); KernelLog.Ln;
END;

END OnClose;

BEGIN
 Modules.InstallTermHandler(OnClose);
  InitGLU();
  ReadVersion;
END GLU.
