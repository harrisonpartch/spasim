MODULE Saboteur;
IMPORT Base, Files, Strings, CryptoMD5, CompilerInterface, Texts, TextUtilities, Diagnostics, Base64, Streams, Out:=KernelLog;  

TYPE Name=Base.Name;

VAR
	hasher:CryptoMD5.Hash;
	
PROCEDURE charmd5(VAR hash: ARRAY 16 OF CHAR; VAR charmdhash:Name);
VAR 
	W:Streams.StringWriter; 
	R: Streams.StringReader; 
	i: INTEGER;
	hashox: ARRAY 17 OF CHAR; 
	plain, base64: ARRAY 80 OF CHAR;
BEGIN
	NEW(W,80); NEW(R,80);	
	FOR i:=0 TO 15 DO
		hashox[i]:=hash[i]
	END;
	R.Set(hashox);
	W.Char('N');
	Base64.Encode(R,W);
	W.Get(charmdhash); 
END charmd5;	

PROCEDURE Sabotage(CONST t: ARRAY OF CHAR):Name; 
VAR
	md5: Name;
	hash: ARRAY 16 OF CHAR;
	md5string, anonymod: Strings.String;
	hashtext,anonymodtext: Strings.String;
	len: SIZE;
	format,res: INTEGER;
	error:BOOLEAN;
	f: Files.File; w: Files.Writer;
	compiler: CompilerInterface.Compiler;
	text: Texts.Text;
	diagnostics: Diagnostics.Diagnostics
BEGIN
	hasher.Initialize;
	hashtext:=Strings.NewString(t);
	len:=Strings.Length(hashtext^);
	hasher.Update(hashtext^,0,len);
	hasher.GetHash(hash,0);	   
	charmd5(hash,md5);
	Out.String(md5);
	Out.Ln;	
	NEW(md5string,28);
	Strings.Concat(md5,".Mod",md5string^);
	Out.String(md5string^);
	Out.Ln;		
	f:=Files.New(md5string^); 
	IF (f # NIL) THEN
		Files.OpenWriter(w, f, 0);
		anonymodtext:=Strings.ConcatToNew("MODULE ", md5);
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,";");	
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,hashtext^);
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,"CONST sourcecode*=");
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,'"');
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,hashtext^);
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,'";');
		(*  almost works now but it represents a flawed idea. hiding the source code inside an Obj file *)
		(* and dispensing with the Mod file has a fatal consequence: the inability to access the source *)
		(* and recompile it if the object file becomes unloadable *)
		anonymodtext:=Strings.ConcatToNew(anonymodtext^," END ");
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,md5);	
		anonymodtext:=Strings.ConcatToNew(anonymodtext^,". ");
		Out.String("marker");
		Out.Ln;
		w.String(anonymodtext^);
		w.Update;
		Files.Register(f); 
		compiler:=CompilerInterface.GetCompilerByName("Fox");
		IF compiler#NIL THEN
			(* call compiler on anonymod to create md5".Obj"*)
			(* TextUtilities.LoadAuto(text,md5string^,format,res); *)
			NEW(text);
			TextUtilities.StrToText(text,10000,anonymodtext^);
			compiler.CompileText(text,"",0,"","",w,diagnostics,error);
			IF error THEN Out.String("compile error ") END;
			
	 	END;	
 	ELSE
 		Out.String("could not create file ");
 	END;
	RETURN md5  (* if md5.Obj exists, it "worked"*)
END Sabotage;

PROCEDURE test*;
VAR
	compiler: CompilerInterface.Compiler;
	anony:Name;
BEGIN
	compiler:=CompilerInterface.GetCompilerByName("Fox");
	anony:=Sabotage(" 
IMPORT Math, Base:=Base, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;

 VAR vox: XNXLHalfSpace.halfvox; v: XNXLTexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;  
BEGIN
	 NEW(v,'tigerlily.png'); 
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN vox
END thisvox;
");
END test;

BEGIN
	NEW(hasher)
END Saboteur.test

SystemTools.Free Saboteur ~