MODULE NCompiler;
IMPORT Files, Texts, TextUtilities, Diagnostics, CompilerInterface,Out:=KernelLog;

PROCEDURE ncompile*;
VAR
       e : Files.Enumerator;
       w: Files.Writer;
       compiler: CompilerInterface.Compiler;
       text: Texts.Text;
       diagnostics: Diagnostics.Diagnostics;
       error:BOOLEAN;
       format,res: LONGINT;
       name : ARRAY 256 OF CHAR; flags : SET; time, date, size : LONGINT;
BEGIN
       NEW(e);
       e.Open("N*.Mod", {});
       compiler:=CompilerInterface.GetCompilerByName("Fox");
       IF compiler#NIL THEN
		WHILE e.HasMoreEntries() DO
			IF e.GetEntry(name, flags, time, date, size) THEN
				Out.String(name); Out.Ln;
				NEW(text);
				TextUtilities.LoadAuto(text,name,format,res);
				compiler.CompileText(text,"",0,"","",w,diagnostics,error);
				IF error THEN Out.String("compile error ") END
			END
		END
	END;
END ncompile;

END NCompiler.ncompile 

SystemTools.Free XNXLNCompiler

 
