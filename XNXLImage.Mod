MODULE XNXLImage;
IMPORT  XNXLBase, Out := KernelLog;

CONST
	W=2*XNXLBase.W;
	H=2*XNXLBase.H;
	filterweight= [	[1,1,1],
					[1,1,1],
					[1,1,1]	];	
			
TYPE Color*=RECORD
	red*,green*,blue*: LONGINT
END;

(*
VAR
	img*, fimg:ARRAY W,H OF Color;

PROCEDURE filter*;
VAR
	i,j,k,l:LONGINT;
	r,g,b,wsum: LONGINT;
BEGIN
	FOR k:= 0 TO 2 DO
		FOR l:= 0 TO 2 DO
			wsum:=wsum+filterweight[k,l];
		END
	END;
	FOR i:= 1 TO W-2 DO
		FOR j:= 1 TO H-2 DO
			r:=0; g:=0; b:=0;
			FOR k:= 0 TO 2 DO
				FOR l:= 0 TO 2 DO
					r:=r+img[i+k-1,j+l-1].red*filterweight[k,l];
					g:=g+img[i+k-1,j+l-1].green*filterweight[k,l];
					b:=b+img[i+k-1,j+l-1].blue*filterweight[k,l];
				END
			END;
			fimg[i,j].red:=r DIV wsum;
			fimg[i,j].green:=g DIV wsum;			
			fimg[i,j].blue:=b DIV wsum;	
		END
	END;
	FOR i:= 1 TO W-1 DO
		FOR j:= 1 TO H-1 DO
			img[i,j]:=fimg[i,j];
		END
	END;	
END filter;	
*)
END XNXLImage.

SystemTools.FreeDownTo XNXLImage ~

