MODULE XNXLVoxConsole;

IMPORT  Base, TexVox, Out:=KernelLog;


VAR a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,slash,space,period,dotdotdot,qmark,emark: TexVox.TexVox;

PROCEDURE charvox*(CONST char:CHAR):Base.Voxel;
BEGIN
	CASE char OF
		'a': RETURN a
		|'b': RETURN b
		|'c': RETURN c
		|'d': RETURN d
		|'e': RETURN e
		|'f': RETURN f
		|'g': RETURN g
		|'h': RETURN h
		|'i': RETURN i
		|'j': RETURN j
		|'k': RETURN k
		|'l': RETURN l
		|'m': RETURN m
		|'n': RETURN n
		|'o': RETURN o
		|'p': RETURN p
		|'q': RETURN q
		|'r': RETURN r
		|'s': RETURN s
		|'t': RETURN t
		|'u': RETURN u
		|'v': RETURN v
		|'w': RETURN w
		|'x': RETURN x
		|'y': RETURN y
		|'z': RETURN z
		|'.': RETURN period
		|'/': RETURN slash
		|'?': RETURN qmark
		|'!': RETURN emark
		|' ': RETURN space
	ELSE
		RETURN space
	END	
END charvox;


BEGIN
	NEW(a,"voxelfont/a.png");
	NEW(b,"voxelfont/b.png");
	NEW(c,"voxelfont/c.png");
	NEW(d,"voxelfont/d.png");
	NEW(e,"voxelfont/e.png");
	NEW(f,"voxelfont/f.png");
	NEW(g,"voxelfont/g.png");
	NEW(h,"voxelfont/h.png");
	NEW(i,"voxelfont/i.png");
	NEW(j,"voxelfont/j.png");
	NEW(k,"voxelfont/k.png");
	NEW(l,"voxelfont/l.png");
	NEW(m,"voxelfont/m.png");	
	NEW(n,"voxelfont/n.png");
	NEW(o,"voxelfont/o.png");
	NEW(p,"voxelfont/p.png");
	NEW(q,"voxelfont/q.png");
	NEW(r,"voxelfont/r.png");
	NEW(s,"voxelfont/s.png");
	NEW(t,"voxelfont/t.png");
	NEW(u,"voxelfont/u.png");
	NEW(v,"voxelfont/v.png");
	NEW(w,"voxelfont/w.png");
	NEW(x,"voxelfont/x.png");
	NEW(y,"voxelfont/y.png");	
	NEW(z,"voxelfont/z.png");
	NEW(space,"voxelfont/space.png");
	NEW(period,"voxelfont/period.png");
	NEW(dotdotdot,"voxelfont/dotdotdot.png");
	NEW(slash,"voxelfont/slash.png");
	NEW(qmark,"voxelfont/qmark.png");
	NEW(emark,"voxelfont/emark.png")
END XNXLVoxConsole.