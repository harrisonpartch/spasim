MODULE NCompiler;
IMPORT Base, Files, Streams, Texts, TextUtilities, Diagnostics, CompilerInterface, Commands;

PROCEDURE ncompile*(context : Commands.Context);
VAR
       e : Files.Enumerator;
       w: Files.Writer;
       compiler: CompilerInterface.Compiler;
       text: Texts.Text;
       diagnostics: Diagnostics.Diagnostics;
       error:BOOLEAN;
       format,res: INTEGER;
       name : ARRAY 256 OF CHAR; 
       flags : SET; 
       time, date : SIGNED32;
       size: Streams.Position;
BEGIN
        NEW(e);
      e.Open("./N*Mod", {}); 
       compiler:=CompilerInterface.GetCompilerByName("Fox");
       context.out.String("compiling all N*Mod ");
       context.out.Ln;
       IF compiler#NIL THEN
		WHILE e.HasMoreEntries() DO
			IF e.GetEntry(name, flags, time, date, size) THEN
				context.out.String(name); 
				context.out.String("   ");
				NEW(text);
				TextUtilities.LoadAuto(text,name,format,res);
				compiler.CompileText(text,"",0,"","",w,diagnostics,error);
				IF error THEN context.out.String("compile error ") END;
				context.out.Ln;
			END
		END
	ELSE
       	context.out.String(" compiler not found ");
       	context.out.Ln;	 
	END;
END ncompile;

END NCompiler.ncompile ~

SystemTools.Free NCompiler ~

 
