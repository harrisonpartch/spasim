MODULE Decoder3DS; (** AUTHOR "fnecati"; PURPOSE "a simple 3ds model loader"; *)

IMPORT KernelLog, Files, Strings, Containers, Commands, Math, Streams, Reals, WMGraphics, Raster,
	GLC := OpenGLConst, GL := OpenGL, GLU;

CONST

(* Primary Chunk, at the beginning of each file *)
MAIN3DS  = 4D4DH;

	(*  Main Chunks *)
	EDIT3DS = 3D3DH;				(* This gives the version of the mesh and is found right before the material and object information *)
 	VERSION = 0002H;					(* This gives the version of the .3ds file *)

	(* sub defines of EDIT3DS *)
	EDIT_MATERIAL = 0AFFFH;					(* This stored the texture info *)
		(*  sub defines of EDIT_MATERIAL *)
		MAT_NAME01 = 0A000H;					(* includes material name  (see mli doc for materials) *)
		MATAMBIENT = 0A010H;
		MATDIFFUSE = 0A020H;				(* This holds the color of the object/material *)
		MATSPECULAR = 0A030H;
		MATMAP = 0A200H;					(* This is a header for a new material, texture map 1 *)
		MATBUMP_MAP = 0A230H; 	(* Bump map *)
		MATREFLECTION_MAP = 0A220H;
			(* subchunks of each map *)
			MATMAPFILE = 0A300H;				(* This holds the file name of the mapping texture *)
			MATMAP_PARAMETERS = 0A351H;	(* map parameters *)

	EDIT_CONFIG1 = 0100H;
	EDIT_CONFIG2 = 3E3DH;
	EDIT_VIEW_P1 = 7012H;
		(* defines for viewport chunks *)
		TOP = 00001H;
		BOTTOM = 00002H;
		LEFT = 00003H;
		RIGHT = 00004H;
		FRONT = 00005H;
		BACK = 00006H;
		USER = 00007H;
		CAMERA = 00008H; (* 0xFFFF is the code read from file *)
		LIGHT = 00009H;
		DISABLED = 00010H;
		BOGUS = 00011H;
	EDIT_VIEW_P2 = 7011H;
		(* defines for viewport chunks, same as above *)
	EDIT_VIEW_P3 = 7020H;
	EDIT_VIEW1 = 7001H;
	EDIT_BACKGR = 1200H;
	EDIT_AMBIENT = 2100H;


	EDIT_OBJECT = 4000H;				(* This stores the faces, vertices, etc... *)
		(* sub defines of EDIT_OBJECT *)
		OBJ_TRIMESH = 4100H;				(* This lets us know that we are reading a new object *)
		(* sub defines of OBJ_TRIMESH *)
			TRI_VERTEXL = 4110H;			(* The objects vertices *)
			TRI_VERTEXOPTIONS = 4111H; (* TRI_FACEL2 ? unknown yet *)
			TRI_MAPPINGCOORS = 4140H;					(* The UV texture coordinates *)
			TRI_MAPPINGSTANDARD= 4170H;
			TRI_FACEL1 = 4120H;				(* The objects faces *)
				TRI_SMOOTH = 4150H;
				TRI_MATERIAL = 4130H;			(* This is found if the object has a material, either texture map or color *)
			TRI_LOCAL = 4160H;
			TRI_VISIBLE = 4165H;
		OBJ_LIGHT = 4600H;
			(* sub defines of OBJ_LIGHT *)
			LIT_OFF = 4620H;
			LIT_SPOT = 4610H;
			LIT_UNKNWN01 = 465AH;
		OBJ_CAMERA = 4700H;
			(* sub defines of OBJ_CAMERA *)
			CAM_UNKNWN01 = 4710H;
			CAM_UNKNWN02 = 4720H;
		OBJ_UNKNWN01 = 4710H;
		OBJ_UNKNWN02 = 4720H;
	EDIT_UNKNW01 = 1100H;
	EDIT_UNKNW02 = 1201H;
	EDIT_UNKNW03 = 1300H;
	EDIT_UNKNW04  = 1400H;
	EDIT_UNKNW05  = 1420H;
	EDIT_UNKNW06  = 1450H;
	EDIT_UNKNW07  = 1500H;
	EDIT_UNKNW08  = 2200H;
	EDIT_UNKNW09 = 2201H;
	EDIT_UNKNW10 = 2210H;
	EDIT_UNKNW11 = 2300H;
	EDIT_UNKNW12 = 2302H;
	EDIT_UNKNW13 = 2000H;
	EDIT_UNKNW14 = 0AFFFH;


 	KEYF3DS = 0B000H;			(* This is the header for all of the key frame info *)
		KEYF_UNKNWN01= 0B00AH;
		 		(* (7001H) ( viewport, same as editor )*)
		KEYF_FRAMES = 0B008H;
		KEYF_UNKNWN02 = 0B009H;
		KEYF_OBJDES = 0B002H;
			KEYF_OBJHIERARCH = 0B010H;
			KEYF_OBJDUMMYNAME = 0B011H;
			KEYF_OBJUNKNWN01 = 0B013H;
			KEYF_OBJUNKNWN02= 0B014H;
			KEYF_OBJUNKNWN03 = 0B015H;
			KEYF_OBJPIVOT = 0B020H;
			KEYF_OBJUNKNWN04 = 0B021H;
			KEYF_OBJUNKNWN05 = 0B022H;

	(*  these define the different color chunk types *)
	  COL_RGB = 00010H;
	  COL_TRU = 00011H;
	  COL_UNK = 00013H; (* unknown *)

TYPE
	List = Containers.Vector;

(*
(* Here is our structure for our 3DS indicies (since .3DS stores 4 unsigned shorts) *)
TYPE
	Indices = RECORD
		a, b, c, bVisible: INTEGER; (* This will hold point1, 2, and 3 index's into the vertex array plus a visible flag*)
	END;
*)

(* This holds the chunk info *)
TYPE Chunk = RECORD
		ID: INTEGER;	(* The chunk's ID *)
		length: LONGINT;				(* The length of the chunk *)
		bytesRead: LONGINT;			(* The amount of bytes read within that chunk *)
END;

(* will be used to store the vertices of our model. *)
TYPE Vector3f* = RECORD
		x*, y*, z*: REAL;
	END;

(*  will be used to store the UV coordinates.*)
	Vector2f* = RECORD
		x*, y*: REAL;
	END;

(*  Face structure is used for indexing into the vertex
 and texture coordinate arrays.  From this information we know which vertices
 from our vertex array go to which face, along with the correct texture coordinates. *)
TYPE
	Face* = RECORD
		a*, b*, c* : INTEGER;		(* indicies for the verts that make up this triangle*)
		tia*, tib*, tic* : INTEGER;		(* indicies for the tex coords to texture this face *)
	END;

(* This holds the information for a material.  It may be a texture map of a color.
 Some of these are not used, but I left them because you will want to eventually
 read in the UV tile ratio and the UV tile offset for some models. *)
TYPE MaterialInfo* = OBJECT
	VAR
		name*: ARRAY 255 OF CHAR;		(* The texture name *)
		texFilename*: ARRAY 255 OF CHAR;	(* The texture file name (If this is set it's a texture map) *)
		color*: ARRAY 3 OF CHAR;			(* The color of the object (R, G, B) *)
		textureId*: LONGINT;		(* the texture ID *)
		uTile*: REAL;				(* u tiling of texture  (Currently not used) *)
		vTile*: REAL;				(* v tiling of texture	(Currently not used) *)
		uOffset*: REAL;			(* u offset of texture	(Currently not used)*)
		vOffset*: REAL;			(* v offset of texture	(Currently not used) *)
	END MaterialInfo ;

(* This holds all the information for our model/scene.
 You should eventually turn into a robust class that
 has loading/drawing/querying functions like:
 LoadModel(...); DrawObject(...); DrawModel(...); DestroyModel(...); *)
TYPE  Object3D* = OBJECT
	VAR
		name*: ARRAY 255 OF CHAR;				(* The name of the object *)
		numVerts*: INTEGER;			(* The number of verts in the model *)
		numFaces*: INTEGER;			(* The number of faces in the model *)
		numTexVerts*: INTEGER;		(* The number of texture coordinates *)

		materialID*: LONGINT;			(* The texture ID to use, which is the index into our texture array *)
		hasTexture*: BOOLEAN;		(* This is TRUE if there is a texture map for this object *)

		verts*: POINTER TO ARRAY OF Vector3f;			(* The object's vertices *)
		normals*: POINTER TO ARRAY OF Vector3f;		(* The object's normals *)
		texVerts*: POINTER TO ARRAY OF Vector2f;		(* The texture's UV coordinates *)
		faces*: POINTER TO ARRAY OF Face;			(* The faces information of the object *)

		(** render the object *)
		PROCEDURE Draw*();
		VAR i, j: LONGINT;
		BEGIN

		END Draw;

	END Object3D;

(** This holds our model information.  This should also turn into a robust class.
 We use  List object to ease our link list burdens. :) *)
TYPE
	Model3D* = OBJECT
	VAR
	 	numObjects*: LONGINT;			(* The number of objects in the model *)
		numMaterials*: LONGINT;			(* The number of materials for the model *)
		materials*: List;	(* The list of material information (Textures and colors) *)
		objects*: List;			(* The object list for our model*)

		(** render the model *)
		PROCEDURE Draw*;
		BEGIN
		END Draw;

	END Model3D;

VAR
	writer: Streams.Writer;
	curChunk: Chunk;				(* Initialize and allocate our current chunk *)
	tmpChunk : Chunk;				(* Initialize and allocate a temporary chunk *)
	file: Files.File;
	rider: Files.Rider;
	buffer: ARRAY 50000 OF CHAR; (* This is used to read past unwanted data*)

	(* This function reads in a chunk ID and it's length in bytes *)
	PROCEDURE ReadChunk(VAR chunk: Chunk);
	VAR s: ARRAY 2 OF CHAR;
	BEGIN
		(* This reads the chunk ID which is 2 bytes.
		 The chunk ID is like OBJECT or EDIT_MATERIAL.  It tells what data is
		 able to be read in within the chunks section.  *)
		(* Files.ReadInt(rider, chunk.ID); *)
		file.ReadBytes(rider, s, 0,2);
		chunk.ID := ORD(s[1])*100H + ORD(s[0]);
		chunk.bytesRead := 2;
		(* Then, we read the length of the chunk which is 4 bytes.
		 This is how we know how much to read in, or read past. *)
		 Files.ReadLInt(rider, chunk.length);
		INC(chunk.bytesRead, 4);
	END ReadChunk;

(** This function reads in the RGB color data *)
PROCEDURE ReadColorChunk(VAR mat: MaterialInfo; VAR chunk: Chunk);
BEGIN
	(* Read the color chunk info *)
	ReadChunk(tmpChunk);

	(* Read in the R G B color (3 bytes - 0 through 255) *)
	file.ReadBytes(rider, mat.color, 0, tmpChunk.length - tmpChunk.bytesRead);
	INC(tmpChunk.bytesRead, tmpChunk.length - tmpChunk.bytesRead);

	(* Add the bytes read to our chunk *)
	INC(chunk.bytesRead, tmpChunk.bytesRead);
END ReadColorChunk;


(**	This function reads in a string of characters *)
PROCEDURE GetString(VAR pBuffer: ARRAY OF CHAR): LONGINT;
VAR index: LONGINT;
	ch: CHAR;
BEGIN
	index := 0;

	(* Read 1 byte of data which is the first letter of the string *)
	file.Read(rider, ch);


	(* Loop until we get NULL *)
	WHILE ch # 0X DO
		pBuffer[index] := ch;
		(* Read in a character at a time until we hit NULL. *)
		file.Read(rider, ch);
		INC(index);
	END;

	(* Return the string length, which is how many bytes we read in (including the NULL)*)
	RETURN Strings.Length(pBuffer) + 1;
END GetString;

(** This function handles all the information about the material (Texture) *)
PROCEDURE ProcessNextMaterialChunk(VAR model: Model3D;  VAR prevChunk: Chunk);
VAR
	matinfo: MaterialInfo;
	any: ANY;

BEGIN
	(* Continue to read these chunks until we read the end of this sub chunk *)
	curChunk.ID := 0;
	curChunk.length := 0;
	curChunk.bytesRead := 0;

	WHILE (prevChunk.bytesRead < prevChunk.length) DO
		(* Read the next chunk *)
		ReadChunk(curChunk);

		(* Check which chunk we just read in *)
		IF curChunk.ID = MAT_NAME01 THEN		(* This chunk holds the name of the material*)

			(* Here we read in the material name *)
			any := model.materials.GetItem(model.numMaterials - 1);
			matinfo := any(MaterialInfo);
			file.ReadBytes(rider, matinfo.name, 0, curChunk.length - curChunk.bytesRead);
			INC(curChunk.bytesRead, curChunk.length - curChunk.bytesRead);

		ELSIF curChunk.ID = MATDIFFUSE THEN	(* This holds the R G B color of our object *)

			any := model.materials.GetItem(model.numMaterials - 1);
			matinfo := any(MaterialInfo);

			ReadColorChunk(matinfo, curChunk);


		ELSIF curChunk.ID = MATMAP THEN	(* This is the header for the texture info*)

			(* Proceed to read in the material information *)
			ProcessNextMaterialChunk(model, curChunk);

		ELSIF curChunk.ID = MATMAPFILE THEN		(*This stores the file name of the material *)

			(* Here we read in the material's file name *)
			any := model.materials.GetItem(model.numMaterials - 1);
			matinfo := any(MaterialInfo);
			file.ReadBytes(rider, matinfo.texFilename, 0, curChunk.length - curChunk.bytesRead);

			INC(curChunk.bytesRead, curChunk.length - curChunk.bytesRead);


		ELSE (* default *)
				(* Read past the ignored or unknown chunks *)
				file.ReadBytes(rider, buffer, 0, curChunk.length - curChunk.bytesRead);
				INC(curChunk.bytesRead , curChunk.length - curChunk.bytesRead)


		END; (* ifs *)

		(* Add the bytes read from the last chunk to the previous chunk passed in. *)
		INC(prevChunk.bytesRead, curChunk.bytesRead);
	END; (* while *)
	curChunk := prevChunk;

END ProcessNextMaterialChunk;

(** 	This function reads in the indices for the vertex array *)
PROCEDURE ReadVertexIndices(object: Object3D; VAR prevChunk: Chunk );
VAR index: INTEGER; (* This is used to read in the current face index *)
	i, j: LONGINT;
BEGIN

	(* In order to read in the vertex indices for the object, we need to first
	 read in the number of them, then read them in.  Remember,
	 we only want 3 of the 4 values read in for each face.  The fourth is
	 a visibility flag for 3D Studio Max that doesn't mean anything to us. *)

	(* Read in the number of faces that are in this object (int) *)
	Files.ReadInt(rider, object.numFaces);
	INC(prevChunk.bytesRead, 2);


	(* Alloc enough memory for the faces and initialize the structure *)
	NEW(object.faces, object.numFaces);

	(* Go through all of the faces in this object *)
	FOR i := 0 TO object.numFaces-1 DO
		(* Next, we read in the A then B then C index for the face, but ignore the 4th value.
		 The fourth value is a visibility flag for 3D Studio Max, we don't care about this. *)

			Files.ReadInt(rider, object.faces[i].a);
			Files.ReadInt(rider, object.faces[i].b);
			Files.ReadInt(rider, object.faces[i].c);
			Files.ReadInt(rider, index);
			INC(prevChunk.bytesRead, 4*2); (* 4*sizeof(integer) *)
	END;
END ReadVertexIndices;

(**	This function reads in the UV coordinates for the object *)
PROCEDURE ReadUVCoordinates( object: Object3D;  VAR prevChunk: Chunk );
VAR i: LONGINT;
BEGIN
	(* In order to read in the UV indices for the object, we need to first
	 read in the amount there are, then read them in. *)

	(* Read in the number of UV coordinates there are (int) *)
	Files.ReadInt(rider, object.numTexVerts);
	INC(prevChunk.bytesRead, 2);

	(* Allocate memory to hold the UV coordinates *)
	NEW(object.texVerts, object.numTexVerts);

	(* Read in the texture coodinates (an array 2 float) *)
	FOR i :=0 TO object.numTexVerts-1 DO
		Files.ReadReal(rider, object.texVerts[i].x);
		Files.ReadReal(rider, object.texVerts[i].y);
	END;
	INC(prevChunk.bytesRead, object.numTexVerts*2*4); (* sizeof(real)*2*n *)
END ReadUVCoordinates;


(** This function reads in the vertices for the object*)
PROCEDURE ReadVertices(object: Object3D; VAR prevChunk: Chunk);
VAR i: LONGINT;
	tempY: REAL;
BEGIN
	(* Like most chunks, before we read in the actual vertices, we need
	 to find out how many there are to read in.  Once we have that number
	 we then fread() them into our vertice array. *)

	(* Read in the number of vertices (int)*)
	Files.ReadInt(rider, object.numVerts);
	INC(prevChunk.bytesRead, 2);

	(* Allocate the memory for the verts and initialize the structure *)
	NEW(object.verts, object.numVerts);

	(* Read in the array of vertices (an array of 3 floats) *)
	FOR i:=0  TO object.numVerts-1 DO
		Files.ReadReal(rider, object.verts[i].x);
		Files.ReadReal(rider, object.verts[i].y);
		Files.ReadReal(rider, object.verts[i].z);
	END;
	(* INC(prevChunk.bytesRead, (prevChunk.length - prevChunk.bytesRead)); *)

	INC(prevChunk.bytesRead, object.numVerts*4*3); (* sizeof(real)*3 *)

	(* Now we should have all of the vertices read in.  Because 3D Studio Max
	 Models with the Z-Axis pointing up (strange and ugly I know!), we need
	 to flip the y values with the z values in our vertices.  That way it
	 will be normal, with Y pointing up.  If you prefer to work with Z pointing
	 up, then just delete this next loop.  Also, because we swap the Y and Z
	 we need to negate the Z to make it come out correctly. *)

	(* Go through all of the vertices that we just read and swap the Y and Z values *)
	FOR i := 0 TO object.numVerts-1 DO
		(* Store off the Y value *)
		tempY := object.verts[i].y;

		(* Set the Y value to the Z value*)
		object.verts[i].y := object.verts[i].z;

		(* Set the Z value to the Y value,
		 but negative Z because 3D Studio max does the opposite. *)
		object.verts[i].z := -tempY;
	END;

END ReadVertices;

(**	This function reads in the material name assigned to the object and sets the materialID *)
PROCEDURE ReadObjectMaterial(VAR model: Model3D;  object: Object3D;  VAR prevChunk: Chunk );
VAR  strMaterial: ARRAY 255 OF CHAR;  (* This is used to hold the objects material name *)
	i: LONGINT;
	mat: MaterialInfo;
	any: ANY;
BEGIN

	(* *What is a material?*  - A material is either the color or the texture map of the object.
	 It can also hold other information like the brightness, shine, etc... Stuff we don't
	 really care about.  We just want the color, or the texture map file name really. *)

	(* Here we read the material name that is assigned to the current object.
	 strMaterial should now have a string of the material name, like "Material #2" etc.. *)
	 i := GetString(strMaterial);
	INC(prevChunk.bytesRead, i );

	(* Now that we have a material name, we need to go through all of the materials
	 and check the name against each material.  When we find a material in our material
	 list that matches this name we just read in, then we assign the materialID
	 of the object to that material index.  You will notice that we passed in the
	 model to this function.  This is because we need the number of textures.
	 Yes though, we could have just passed in the model and not the object too. *)

	(* Go through all of the textures *)
	FOR i := 0 TO model.numMaterials-1 DO
		(* If the material we just read in matches the current texture name *)
		any := model.materials.GetItem(i);
		mat := any(MaterialInfo);

		IF Strings.Pos(strMaterial, mat.name) # -1 THEN
			(* Set the material ID to the current index 'i' and stop checking *)
			object.materialID := i;

			(* Now that we found the material, check if it's a texture map.
			 If the texFilename has a string length of 1 and over it's a texture *)
			IF Strings.Length(mat.texFilename) > 0 THEN

				(* Set the object's flag to say it has a texture map to bind.*)
				object.hasTexture := TRUE;
			END;

		ELSE
			(* Set the ID to -1 to show there is no material for this object*)
			object.materialID := -1;
		END;
	END;

	(* Read past the rest of the chunk since we don't care about shared vertices
	 You will notice we subtract the bytes already read in this chunk from the total length. *)
	 file.ReadBytes(rider, buffer, 0, prevChunk.length - prevChunk.bytesRead);
	INC(prevChunk.bytesRead, prevChunk.length - prevChunk.bytesRead)


END ReadObjectMaterial;

PROCEDURE ReadCameraChunk(VAR prevChunk: Chunk);
VAR cam_eye, cam_focus : ARRAY 3 OF REAL;
	rotation, lens: REAL;
BEGIN
		Files.ReadReal(rider, cam_eye[0]);
		Files.ReadReal(rider, cam_eye[1]);
		Files.ReadReal(rider, cam_eye[2]);
		INC(prevChunk.bytesRead, 3*4);
		Files.ReadReal(rider, cam_focus[0]);
		Files.ReadReal(rider, cam_focus[1]);
		Files.ReadReal(rider, cam_focus[2]);
		INC(prevChunk.bytesRead, 3*4);

		Files.ReadReal(rider, rotation);
		Files.ReadReal(rider, lens);
		INC(prevChunk.bytesRead, 2*4);
		writer.String("cam_eye: ");
			writer.FloatFix(cam_eye[0], 0, 4, 0); writer.FloatFix(cam_eye[1], 0, 4, 0); writer.FloatFix(cam_eye[2], 0, 4, 0);writer.Ln;
		writer.String("cam_focus: ");
			writer.FloatFix(cam_focus[0], 0, 4, 0); writer.FloatFix(cam_focus[1], 0, 4, 0); writer.FloatFix(cam_focus[2], 0, 4, 0);writer.Ln;
		writer.String(" rotation :");  writer.FloatFix(rotation, 0, 4, 0); writer.Ln;
		writer.String(" lens :");  writer.FloatFix(lens, 0, 4, 0); writer.Ln;
		writer.Update;

END ReadCameraChunk;

(** This function handles all the information about the objects in the file *)
PROCEDURE ProcessNextObjecChunk(VAR model: Model3D;  object: Object3D; prevChunk: Chunk);

BEGIN
	(* Allocate a new chunk to work with*)
	curChunk.ID := 0;
	curChunk.length := 0;
	curChunk.bytesRead := 0;

	(* Continue to read these chunks until we read the end of this sub chunk *)
	WHILE (prevChunk.bytesRead < prevChunk.length) DO

		(* Read the next chunk *)
		ReadChunk(curChunk);

		(* Check which chunk we just read *)


		IF curChunk.ID = OBJ_TRIMESH THEN					(* This lets us know that we are reading a new object*)

			(* We found a new object, so let's read in it's info using recursion *)
			ProcessNextObjecChunk(model, object, curChunk);


		ELSIF curChunk.ID = TRI_VERTEXL THEN				(* This is the objects vertices *)
			ReadVertices(object, curChunk);


		ELSIF curChunk.ID = TRI_FACEL1 THEN					(* This is the objects face information *)
			ReadVertexIndices(object, curChunk);


		ELSIF curChunk.ID = TRI_MATERIAL THEN				(* This holds the material name that the object has*)

			(* This chunk holds the name of the material that the object has assigned to it.
			 This could either be just a color or a texture map.  This chunk also holds
			 the faces that the texture is assigned to (In the case that there is multiple
			 textures assigned to one object, or it just has a texture on a part of the object.
			 Since most of my game objects just have the texture around the whole object, and
			 they aren't multitextured, I just want the material name. *)

			(* We now will read the name of the material assigned to this object *)
			ReadObjectMaterial(model, object, curChunk);


		ELSIF curChunk.ID = TRI_MAPPINGCOORS THEN						(* This holds the UV texture coordinates for the object*)

			(* This chunk holds all of the UV coordinates for our object.  Let's read them in. *)
			ReadUVCoordinates(object, curChunk);

		ELSIF curChunk.ID = OBJ_LIGHT THEN writer.String("Obj-Light"); writer.Ln; writer.Update;
		ELSIF curChunk.ID = OBJ_CAMERA THEN
			ReadCameraChunk(curChunk);
		ELSE

			(* Read past the ignored or unknown chunks *)

			file.ReadBytes(rider, buffer, 0, curChunk.length - curChunk.bytesRead);
			INC(curChunk.bytesRead, curChunk.length - curChunk.bytesRead);
		END;

		(* Add the bytes read from the last chunk to the previous chunk passed in.*)
		INC(prevChunk.bytesRead, curChunk.bytesRead);
	END; (* while *)

	(* Free the current chunk and set it back to the previous chunk (since it started that way) *)

	curChunk := prevChunk;

END ProcessNextObjecChunk;

(** This function reads the main sections of the .3DS file, then dives deeper with recursion *)
PROCEDURE ProcessNexChunk(VAR model: Model3D;  prevChunk: Chunk);
VAR
	newObject: Object3D; (* Object3D;  This is used to add to our object list *)
	newTexture: MaterialInfo; (* MaterialInfo, This is used to add to our material list *)
	version: LONGINT; (* This will hold the file version *)
	cnt: LONGINT;

BEGIN

	(* Below we check our chunk ID each time we read a new chunk.  Then, if
	we want to extract the information from that chunk, we do so.
	If we don't want a chunk, we just read past it.

	Continue to read the sub chunks until we have reached the length.
	After we read ANYTHING we add the bytes read to the chunk and then check
	check against the length.*)

	curChunk.ID := 0;
	curChunk.length := 0;
	curChunk.bytesRead := 0;


	WHILE prevChunk.bytesRead < prevChunk.length DO
		(* Read next Chunk *)
		ReadChunk(curChunk);
		(* writer.String("curChunk.ID= "); writer.Hex(curChunk.ID, 4); writer.Ln; *)

		(* Check the chunk ID *)
		IF curChunk.ID = VERSION THEN (* This holds the version of the file *)

			(* This chunk has an unsigned short that holds the file version.
			 Since there might be new additions to the 3DS file format in 4.0,
			 we give a warning to that problem.

			 Read the file version and add the bytes read to our bytesRead variable *)
			 Files.ReadLInt(rider, version);
			INC(curChunk.bytesRead,curChunk.length - curChunk.bytesRead);

			(* If the file version is over 3, give a warning that there could be a problem *)
			IF version > 03H THEN
				writer.String("WARNING: This 3DS file is over version 3 so it may load incorrectly"); writer.Ln;
			END;

		ELSIF curChunk.ID = EDIT3DS THEN (* This holds the version of the mesh *)

			(* This chunk holds the version of the mesh.  It is also the head of the EDIT_MATERIAL
			 and OBJECT chunks.  From here on we start reading in the material and object info.*)

			(* Read the next chunk *)
			ReadChunk(tmpChunk);

			(* Get the version of the mesh *)
			Files.ReadLInt(rider, version);

			INC(tmpChunk.bytesRead, tmpChunk.length - tmpChunk.bytesRead);

			(* Increase the bytesRead by the bytes read from the last chunk *)
			INC(curChunk.bytesRead , tmpChunk.bytesRead);

			(* Go to the next chunk, which is the object has a texture, it should be EDIT_MATERIAL, then OBJECT. *)
			ProcessNexChunk(model, curChunk);

		ELSIF curChunk.ID =  EDIT_MATERIAL THEN		(* This holds the material information *)

			(* This chunk is the header for the material info chunks *)

			(* Increase the number of materials *)
			INC(model.numMaterials);

			(* Add a empty texture structure to our texture list.
			 If you are unfamiliar with STL's "vector" class, all push_back()
			 does is add a new node onto the list.  I used the vector class
			 so I didn't need to write my own link list functions.  *)

			 NEW(newTexture);
			model.materials.Add(newTexture);

			(* Proceed to the material loading function *)
			ProcessNextMaterialChunk(model, curChunk);

		ELSIF  curChunk.ID = EDIT_OBJECT THEN	(* This holds the name of the object being read *)

			(* This chunk is the header for the object info chunks.  It also
			 holds the name of the object. *)

			(* Increase the object count *)
			INC(model.numObjects);

			(* Add a new tObject node to our list of objects (like a link list) *)
			NEW(newObject);

			model.objects.Add(newObject);

			(* Initialize the object and all it's data members *)

			(* Get the name of the object and store it, then add the read bytes to our byte counter. *)
			cnt :=  GetString(newObject.name);
			INC(curChunk.bytesRead, cnt);

			(* Now proceed to read in the rest of the object information *)

			ProcessNextObjecChunk(model, newObject, curChunk);

		ELSIF  curChunk.ID =  KEYF3DS THEN

			(* Because I wanted to make this a SIMPLE tutorial as possible, I did not include
			 the key frame information.  This chunk is the header for all the animation info.
			 In a later tutorial this will be the subject and explained thoroughly. *)

			(* ProcessNextKeyFrameChunk(model, curChunk); *)

			(* Read past this chunk and add the bytes read to the byte counter *)
			file.ReadBytes(rider, buffer, 0, curChunk.length - curChunk.bytesRead);
			INC(curChunk.bytesRead, curChunk.length - curChunk.bytesRead);

		ELSE (* default *)

			(* If we didn't care about a chunk, then we get here.  We still need
			 to read past the unknown or ignored chunk and add the bytes read to the byte counter. *)
			file.ReadBytes(rider, buffer, 0, curChunk.length - curChunk.bytesRead);
			INC(curChunk.bytesRead, curChunk.length - curChunk.bytesRead);
		END; (*ifs *)

		(* Add the bytes read from the last chunk to the previous chunk passed in.*)
		INC(prevChunk.bytesRead, curChunk.bytesRead);
	END; (* while *)
	curChunk := prevChunk;
END ProcessNexChunk;

(* *********************************** *)
(* *********************************** *)
(* ********** MATH ******************** *)
(* *********************************** *)

(** This calculates a vector between 2 points and returns the result*)
PROCEDURE Vector(vpoint1,  vpoint2: Vector3f): Vector3f;
VAR v: Vector3f;
BEGIN
	v.x := vpoint1.x - vpoint2.x;			(* Subtract point1 and point2 x's y's z's *)
	v.y := vpoint1.y - vpoint2.y;
	v.z := vpoint1.z - vpoint2.z;

	RETURN v;
END Vector;

(** This adds 2 vectors together and returns the result *)
PROCEDURE AddVector(v1, v2: Vector3f): Vector3f;
VAR
	res: Vector3f;
BEGIN
	res.x := v2.x + v1.x;		(* Add v1 and v2 x, y, z's *)
	res.y := v2.y + v1.y;
	res.z := v2.z + v1.z;
	RETURN res;
END AddVector;

(** This divides a vector by a single number (scalar) and returns the result*)
PROCEDURE DivideVectorByScaler(v1: Vector3f;  scaler: REAL): Vector3f;
VAR
	 res: Vector3f;
BEGIN
	res.x := v1.x / scaler;			(* Divide v1's x, y, z values by the scaler *)
	res.y := v1.y / scaler;
	res.z := v1.z / scaler;
	IF Reals.IsNaN(res.x) THEN
		writer.String("NaN number:scaler  "); writer.FloatFix(scaler, 0,16,0); writer.Ln; writer.Update;
	END;
	RETURN res;			(* Return the resultant vector *)
END DivideVectorByScaler;

(** This returns the cross product between 2 vectors *)
PROCEDURE Cross(v1, v2: Vector3f ): Vector3f;
VAR vc: Vector3f;
BEGIN
	vc.x := (v1.y * v2.z) - (v1.z * v2.y);
	vc.y := (v1.z * v2.x) - (v1.x * v2.z);
	vc.z := (v1.x * v2.y) - (v1.y * v2.x);
	RETURN vc;			(* Return the cross product *)
END Cross;

(** This computes the magnitude of a normal.   (magnitude = sqrt(x^2 + y^2 + z^2) *)
PROCEDURE  Mag(normal: Vector3f): REAL;
BEGIN
	RETURN Math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
END Mag;

(** This returns the normal of a vector *)
PROCEDURE Normalize( vnormal: Vector3f): Vector3f;
VAR mag: REAL;
BEGIN
	mag := Mag(vnormal);	(* Get the magnitude*)

	vnormal.x := vnormal.x / mag;		(* Divide the vector's X, Y, Z by the magnitude *)
	vnormal.y := vnormal.y / mag;
	vnormal.z := vnormal.z / mag;
	RETURN vnormal;
END Normalize;

(** This function computes the normals and vertex normals of the objects *)
PROCEDURE ComputeNormals(VAR model: Model3D);
VAR
 vec1, vec2, vnorm: Vector3f;
 vpoly: ARRAY 3 OF Vector3f;;
 i, j, index: LONGINT;
 object: Object3D;
 normals, tmpNormals : POINTER TO ARRAY OF Vector3f;
 vsum, vzero: Vector3f;
 shared: LONGINT;
BEGIN
	(* If there are no objects, we can skip this part *)
	IF model.numObjects <= 0 THEN RETURN END;


	(* What are vertex normals?  And how are they different from other normals?
	 Well, if you find the normal to a triangle, you are finding a "Face Normal".
	 If you give OpenGL a face normal for lighting, it will make your object look
	 really flat and not very round.  If we find the normal for each vertex, it makes
	 the smooth lighting look.  This also covers up blocky looking objects and they appear
	 to have more polygons than they do.    Basically, what you do is first
	 calculate the face normals, then you take the average of all the normals around each
	 vertex.  It's just averaging.  That way you get a better approximation for that vertex. *)

	(* Go through each of the objects to calculate their normals*)
	FOR index := 0 TO model.numObjects-1 DO

		(* Get the current object *)
		object := model.objects.GetItem(index)(Object3D);

		(* Here we allocate all the memory we need to calculate the normals *)
		NEW(normals, object.numFaces);
		NEW(tmpNormals, object.numFaces);
		NEW(object.normals, object.numVerts);

		(* Go though all of the faces of this object *)
		FOR i := 0 TO object.numFaces-1 DO
			(* To cut down LARGE code, we extract the 3 points of this face *)
			vpoly[0] := object.verts[object.faces[i].a];
			vpoly[1] := object.verts[object.faces[i].b];
			vpoly[2] := object.verts[object.faces[i].c];

			(* Now let's calculate the face normals (Get 2 vectors and find the cross product of those 2) *)

			vec1 := Vector(vpoly[0], vpoly[2]);		(* Get the vector of the polygon (we just need 2 sides for the normal) *)
			vec2 := Vector(vpoly[2], vpoly[1]);		(* Get a second vector of the polygon *)

			vnorm  := Cross(vec1, vec2);		(* Return the cross product of the 2 vectors (normalize vector, but not a unit vector) *)
			tmpNormals[i] := vnorm;				(* Save the un-normalized normal for the vertex normals *)
			vnorm  := Normalize(vnorm);				(* Normalize the cross product to give us the polygons normal *)

			normals[i] := vnorm;						(* Assign the normal to the list of normals *)
		END;

		(* Now Get The Vertex Normals *)

		vsum.x := 0.0; vsum.y := 0.0; vsum.z := 0.0;
		vzero := vsum;
		shared:=0;

		FOR i := 0 TO object.numVerts -1 DO			(* Go through all of the vertices*)
			FOR  j := 0 TO object.numFaces-1 DO	 (* Go through all of the triangles *)
														(* Check if the vertex is shared by another face *)
				IF (object.faces[j].a = i) OR
					(object.faces[j].b = i) OR
					(object.faces[j].c = i) THEN

					vsum := AddVector(vsum, tmpNormals[j]);  (* Add the un-normalized normal of the shared face *)
					INC(shared);								(* Increase the number of shared triangles *)
				END;
			END;

			(* Get the normal by dividing the sum by the shared.  We negate the shared so it has the normals pointing out. *)
			object.normals[i] := DivideVectorByScaler(vsum, REAL(-shared));

			(* Normalize the normal for the final vertex normal *)
			object.normals[i] := Normalize(object.normals[i]);

			vsum := vzero;									(* Reset the sum *)
			shared := 0;										(* Reset the shared *)
		END;

	END;
END ComputeNormals;


(**	This is called by the client to open the .3ds file, read it, then clean up *)
PROCEDURE Import3DS* (VAR model: Model3D;  CONST filename: ARRAY OF CHAR): BOOLEAN;

BEGIN
	file := Files.Old(filename);
	IF file = NIL THEN
		writer.String("Unable to find the file: "); writer.String(filename); writer.Ln;
		RETURN FALSE; (*Open the file *)
	END;

	NEW(model);

	(* Initialize our current and temp chunk *)
	curChunk.ID := 0; curChunk.length := 0; curChunk.bytesRead := 0;
	tmpChunk.ID := 0; tmpChunk.length := 0; tmpChunk.bytesRead := 0;

	file.Set(rider, 0);

	(* Once we have the file open, we need to read the very first data chunk
	 to see if it's a 3DS file.  That way we don't read an invalid file.
	 If it is a 3DS file, then the first chunk ID will be equal to MAIN3DS (some hex num) *)

	(* Read the first chuck of the file to see if it's a 3DS file *)
	ReadChunk(curChunk);

	(* Make sure this is a 3DS file *)
	IF curChunk.ID # MAIN3DS THEN

		writer.String("Unable to load MAIN3DS chuck from file: "); writer.String(filename); writer.Ln;
		RETURN FALSE
	END;

	(* Now we actually start reading in the data.  ProcessNexChunk() is recursive *)

	NEW(model.materials, NIL, {}); (* create an empy materlial list *)
	NEW(model.objects, NIL, {}); (* create an empty object list *)

	(* Begin loading objects, by calling this recursive function *)
	ProcessNexChunk(model, curChunk);

	(* After we have read the whole 3DS file, we want to calculate our own vertex normals. *)
	(*ComputeNormals(model); *)

	RETURN TRUE; (* Returns ok *)

END Import3DS;


(**  This function loads an image file and return the OpenGL reference ID to use that texture *)
PROCEDURE LoadImage* (CONST filename: ARRAY OF CHAR): LONGINT;
VAR img0, img: Raster.Image;
	res: LONGINT;
	textureNumber: LONGINT;
BEGIN

	img0:= WMGraphics.LoadImage(filename, FALSE); (* loaded image format is BGRA8888 - > GL.GL_BGRA *)
	IF img0 = NIL THEN
		writer.String(filename); writer.String(" Not Loaded"); writer.Ln; writer.Update;
		RETURN -1; (* Open the file for reading *)
	  END;

	img := TransposeImage(img0);

	writer.String(filename); writer.String("  loaded.."); writer.Ln;  writer.Update;
  	GL.GenTextures(1, ADDRESSOF(textureNumber));

	GL.BindTexture(GLC.GL_TEXTURE_2D, textureNumber);  (* Bind the ID texture specified by the 2nd parameter *)

	(* The next commands sets the texture parameters *)
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_S, GLC.GL_REPEAT);  (* If the u,v coordinates overflow the range 0,1 the image is repeated *)
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_T, GLC.GL_REPEAT);
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);  (* The magnification function ("linear" produces better results) *)
	GL.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR_MIPMAP_NEAREST);  (*The minifying function *)

	GL.TexEnvf(GLC.GL_TEXTURE_ENV, GLC.GL_TEXTURE_ENV_MODE, GLC.GL_REPLACE);  (* We don't combine the color with the original surface color, use only the texture map. *)

	(* Finally we define the 2d texture *)
	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, img.width, img.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);

	(* And create 2d mipmaps for the minifying function *)
	res := GLU.Build2DMipmaps(GLC.GL_TEXTURE_2D, GLC.GL_RGBA, img.width, img.height, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);

	img0 := NIL;
	img := NIL;
	RETURN textureNumber; (*  Returns the current texture OpenGL ID *)
END LoadImage;

PROCEDURE TransposeImage(im: Raster.Image): Raster.Image;
VAR i, j: LONGINT;
	tim: Raster.Image;
	pix: Raster.Pixel;
	mode: Raster.Mode;
BEGIN
	Raster.InitMode(mode, Raster.srcCopy);
	NEW(tim);
	Raster.Create(tim, im.width, im.height, im.fmt);

	FOR j :=0 TO im.height-1 DO
		FOR i:=0 TO im.width-1 DO
		 	Raster.Get(im,i, j, pix, mode);
			 Raster.Put(tim, i, im.height-j-1, pix, mode); (* flip vertical  *)
		END;
	END;
 	RETURN tim;
END TransposeImage;

(** for testing *)
PROCEDURE PrintModelInfo(VAR m: Model3D);
VAR i, j: LONGINT;

	obj: Object3D;
	mat: MaterialInfo;

BEGIN
	writer.String("m.numObjects= "); writer.Int(m.numObjects, 0); writer.Ln;
	writer.String("m.numMaterials= "); writer.Int(m.numMaterials, 0); writer.Ln;
	FOR i:= 0 TO m.objects.GetCount()-1 DO
		obj:= m.objects.GetItem(i)(Object3D);
		writer.Int(i, 0); writer.String(": -------"); writer.Ln;
		writer.String(obj.name); writer.Ln;
		writer.String("obj.numVerts= "); writer.Int(obj.numVerts, 0); writer.Ln;
		writer.String("obj.numFaces= "); writer.Int(obj.numFaces, 0); writer.Ln;
		writer.String("obj.numTexVerts= "); writer.Int(obj.numTexVerts, 0); writer.Ln;
		writer.Update;

(*		writer.String(" vertices: "); writer.Ln;
		FOR j:=0 TO obj.numVerts-1 DO
			writer.Int(j,0); writer.String(": "); writer.FloatFix(obj.verts[j].x, 0,4,0); writer.FloatFix(obj.verts[j].y, 0,4,0); writer.FloatFix(obj.verts[j].z, 0,4,0); writer.Ln;
		END;
		writer.Update;
*)
		IF obj.normals # NIL THEN
			writer.String(" normals: "); writer.Ln;
			FOR j:=0 TO obj.numVerts-1 DO
				writer.Int(j,0); writer.FloatFix(obj.normals[j].x, 0,4,0); writer.FloatFix(obj.normals[j].y, 0,4,0); writer.FloatFix(obj.normals[j].x, 0,4,0); writer.Ln;
			END;
			writer.Update;
		END;

(*		writer.String(" faces: "); writer.Ln;
		FOR j:=0 TO obj.numFaces-1 DO
			writer.Int(j,0); writer.Int(obj.faces[j].a, 5);  writer.Int(obj.faces[j].b, 5); writer.Int(obj.faces[j].c, 5); writer.Ln;
(*			writer.Int(j,0); writer.Int(obj.faces[j].tia, 5);  writer.Int(obj.faces[j].tib, 5); writer.Int(obj.faces[j].tic, 5); writer.Ln;*)
		END;
*)
(*		writer.String(" texVerts: "); writer.Ln;
		FOR j:=0 TO obj.numTexVerts-1 DO
			writer.Int(j,0); writer.FloatFix(obj.texVerts[j].x, 0,4,0);
			writer.FloatFix(obj.texVerts[j].y, 0,4,0); writer.Ln;
		END;
*)
		writer.Update;
	END;

	writer.String(" Materials: "); writer.Ln;
	FOR i:= 0 TO m.materials.GetCount()-1 DO
		mat := m.materials.GetItem(i)(MaterialInfo);
		writer.String(" ----"); writer.Int(i, 0); writer.String(" ----"); writer.Ln;
		writer.String("mat.name: "); writer.String(mat.name); writer.Ln;
		writer.String("mat.texFilename: "); writer.String(mat.texFilename); writer.Ln;
		writer.String("mat.textureId: "); writer.Int(mat.textureId, 0); writer.Ln;
		writer.String("mat.color: ");
			writer.Int(ORD(mat.color[0]), 4);
			writer.Int(ORD(mat.color[1]), 4);
			writer.Int(ORD(mat.color[2]), 4);
			writer.Ln;

	END;

	writer.Update;
END PrintModelInfo;

(* for testing *)
PROCEDURE Open*(context: Commands.Context);
VAR
	fname: ARRAY 128 OF CHAR;
	res: BOOLEAN;
	model: Model3D;
BEGIN
	IF ~context.arg.GetString(fname) THEN
		context.out.String("Input Error, file name expected"); context.out.Ln;
		RETURN;
	END;

	context.out.String("loading 3ds file: "); context.out.String(fname); context.out.Ln;

	res := Import3DS(model, fname);

	IF  res THEN
		context.out.String("Ok"); context.out.Ln;
		PrintModelInfo(model);
	ELSE
		context.out.String("Error: loading"); context.out.Ln;
	END;

END Open;

BEGIN
	Streams.OpenWriter(writer, KernelLog.Send);
END Decoder3DS.

Decoder3DS.Open "spaceship.3ds" ~

Decoder3DS.Open "objects.3ds" ~
Decoder3DS.Open "sphere.3ds" ~

Decoder3DS.Open "boxtext.3ds" ~

Decoder3DS.Open "teapot.3ds" ~
Decoder3DS.Open "AMBLNC1.3DS" ~

Decoder3DS.Open "jelyfish.3ds" ~

System.Free Decoder3DS ~

(*
(*  This module handles all of the code needed to load a .3DS file.
 Basically, how it works is, you load a chunk, then you check
 the chunk ID.  Depending on the chunk ID, you load the information
 that is stored in that chunk.  If you do not want to read that information,
 you read past it.  You know how many bytes to read past the chunk because
 every chunk stores the length in bytes of that chunk. *)
*)
