IMPLEMENTATION MODULE pcM; (* Leo 05-Jun-88. (c) KRONOS *)
                           (* Ned 04-Mar-90. (c) KRONOS *)
                           (* Ned 17-Nov-90. (c) KRONOS *)

IMPORT FIO, Str, Lib, IO, Storage;

CONST TMP_NAME = "SYM.$$$";

VAR
  sym : FIO.File;
  new : FIO.File;
  symf: ARRAY [0..31] OF CHAR;
(*buf : ARRAY [0..1023+FIO.BufferOverhead] OF BYTE;*)
  null: CARDINAL;

PROCEDURE check;
  VAR n: CARDINAL;
BEGIN
  n:=FIO.IOresult();
  IF n#0 THEN
    IO.WrStr('io error: '); IO.WrCard(n,0); IO.WrLn;
    abort;
  END;
END check;

PROCEDURE create(name: ARRAY OF CHAR; VAR done: BOOLEAN);
BEGIN
  Str.Copy(symf,name); Str.Append(symf,'.sym');
  new:=FIO.Create(TMP_NAME);
  done:=(new#MAX(CARDINAL));
  IF done THEN
    IO.WrStr('create sym file: '); IO.WrStr(symf); IO.WrLn;
(*    FIO.AssignBuffer(new,buf);*)
  ELSE
    IO.WrStr("can't create sym file: "); IO.WrStr(symf); IO.WrLn;
  END;
END create;

PROCEDURE put(x: LONGINT);
  VAR i: SHORTCARD;
BEGIN
  i:=SHORTCARD(x);
  FIO.WrBin(new,i,1);
END put;

PROCEDURE put2(x: LONGINT);
  VAR i: CARDINAL;
BEGIN
  i:=CARDINAL(x);
  FIO.WrBin(new,i,2);
END put2;

PROCEDURE put4(x: LONGINT);
BEGIN
  FIO.WrBin(new,x,4);
END put4;

PROCEDURE put8(x: LONGREAL);
BEGIN
  FIO.WrBin(new,x,8);
END put8;

PROCEDURE put_name(s: ARRAY OF CHAR);
BEGIN
  FIO.WrStr(new,s); FIO.WrChar(new,15C);
END put_name;

PROCEDURE put_bytes(VAR x: ARRAY OF BYTE; len: LONGINT);
BEGIN
  FIO.WrBin(new,x,CARDINAL(len));
END put_bytes;

PROCEDURE close_new(register: BOOLEAN);
BEGIN
  FIO.Close(new); check;
  IF register THEN
    FIO.Erase(symf); check;
    FIO.Rename(TMP_NAME,symf); check;
  ELSE
    FIO.Erase(TMP_NAME); check;
  END;
END close_new;

PROCEDURE open(name: ARRAY OF CHAR; self: BOOLEAN; VAR done: BOOLEAN);
  VAR fn: ARRAY [0..63] OF CHAR;
BEGIN
  Str.Copy(fn,name); Str.Append(fn,'.sym');
  sym:=FIO.Open(fn);
  done:=sym#MAX(CARDINAL);
  IF done THEN
    IO.WrStr(fn); IO.WrLn;
(*    bio.buffers(sym,1,1);*)
  ELSIF NOT self THEN
    IO.WrStr("can't open sym file: "); IO.WrStr(fn); IO.WrLn;
  END;
END open;

PROCEDURE get(VAR x: LONGINT);
BEGIN
  x:=0;
  null:=FIO.RdBin(sym,x,1);
END get;

PROCEDURE get2(VAR x: LONGINT);
BEGIN
  x:=0;
  null:=FIO.RdBin(sym,x,2);
END get2;

PROCEDURE get4(VAR x: LONGINT);
BEGIN
  null:=FIO.RdBin(sym,x,4);
END get4;

PROCEDURE get8(VAR x: LONGREAL);
BEGIN
  null:=FIO.RdBin(sym,x,8);
END get8;

PROCEDURE get_name(VAR s: ARRAY OF CHAR);
BEGIN
  FIO.RdStr(sym,s);
END get_name;

PROCEDURE get_bytes(VAR x: ARRAY OF BYTE; len: LONGINT);
BEGIN
  null:=FIO.RdBin(sym,x,CARDINAL(len));
END get_bytes;

PROCEDURE close;
BEGIN
  FIO.Close(sym);
END close;

PROCEDURE equal(pos: LONGINT): BOOLEAN;
  (*VAR eof,len,i: LONGINT; a,b: DYNARR OF INTEGER;*)
BEGIN
(*
  eof:=bio.eof(sym);
  IF bio.eof(new)#eof THEN RETURN FALSE END;
  len:=(eof-pos+3) DIV 4;
  NEW(a,len); a[len-1]:=0;
  NEW(b,len); b[len-1]:=0;
  bio.seek(sym,pos,0); bio.get(sym,a,eof-pos);
  bio.seek(new,pos,0); bio.get(new,b,eof-pos);
  FOR i:=0 TO len-1 DO
    IF a[i]#b[i] THEN RETURN FALSE END;
  END;
*)
  RETURN TRUE
END equal;

(*----------------------------------------------------------------*)

PROCEDURE wc(c: CHAR); BEGIN IO.WrChar(c) END wc;
PROCEDURE ws(s: ARRAY OF CHAR); BEGIN IO.WrStr(s); END ws;
PROCEDURE wi(x: LONGINT; n: INTEGER); BEGIN IO.WrLngInt(x,n) END wi;
PROCEDURE wl; BEGIN IO.WrLn END wl;

(*----------------------------------------------------------------*)

PROCEDURE abort;
BEGIN
  IO.WrLn; IO.WrStr('#ABORT'); IO.WrLn; HALT;
END abort;

PROCEDURE final(p: CLOSURE);  BEGIN (*env.final(p)*) END final;

PROCEDURE time(): LONGINT;
BEGIN
  RETURN 0
END time;

PROCEDURE str_equ(a,b: ARRAY OF CHAR): BOOLEAN;
  VAR i: CARDINAL;
BEGIN
  i:=0;
  LOOP
    IF a[i]#b[i] THEN RETURN FALSE END;
    IF a[i]=0C THEN RETURN TRUE END;
    INC(i);
  END;
END str_equ;

PROCEDURE str_copy(VAR a: ARRAY OF CHAR; b: ARRAY OF CHAR);
  VAR i: CARDINAL;
BEGIN
  IF HIGH(b)>HIGH(a) THEN abort END;
  FOR i:=0 TO HIGH(b) DO a[i]:=b[i] END;
END str_copy;

PROCEDURE app(VAR s: ARRAY OF CHAR; x: ARRAY OF CHAR);
BEGIN Str.Append(s,x);
END app;

PROCEDURE app_num(VAR s: ARRAY OF CHAR; x: LONGINT);
  VAR a: ARRAY [0..23] OF CHAR; ok: BOOLEAN;
BEGIN
  Str.IntToStr(x,a,10,ok);
  Str.Append(s,a);
END app_num;

(*---------------------------------------------------------------*)

PROCEDURE err_msg(no: INTEGER; VAR s: ARRAY OF CHAR);
BEGIN
  CASE no OF
  |000: Str.Copy(s,"")

  |001: Str.Copy(s,"�������� ���� ����������")
  |002: Str.Copy(s,"��������� ������਩, ��砢訩�� � ��ப�")
  |003: Str.Copy(s,"���ࠢ��쭮� �᫮")
  |004: Str.Copy(s,"��������� ��� ᫨誮� ������� ��ப�!")
  |005: Str.Copy(s,"���������� ����� ��室���� ⥪��!")
  |006: Str.Copy(s,"���誮� ������� ���")
  |007: Str.Copy(s,"������ ���� �����䨪���");
  |008: Str.Copy(s,"������ ���� ᨬ���")

  |020: Str.Copy(s,"�������� ��ꥪ�")
  |021: Str.Copy(s,"�����ᨢ��� ��।������ ⨯�")
  |022: Str.Copy(s,"����୮ �����")
  |024: Str.Copy(s,"�����ᨢ�� ������ ����饭")
  |023: Str.Copy(s,"����୮� �।���⥫쭮� ���ᠭ��")

  |030: Str.Copy(s,"���� ��ᮢ���⨬�")
  |031: Str.Copy(s,"������ ���� ⨯")
  |032: Str.Copy(s,"������ ���� ᪠���� ⨯")
  |033: Str.Copy(s,"������ ���� ���⮩ (1 ᫮��) ⨯")
  |034: Str.Copy(s,"�������⨬�� �८�ࠧ������ ⨯�")
  |036: Str.Copy(s,"�������⨬�� ॠ������ ���⮣� ⨯�")
  |092: Str.Copy(s,"����䨪��� VAL �������⨬ � ���ᠭ�� ��楤�୮�� ⨯�");
  |038: Str.Copy(s,"���ࠢ��쭮� �᫮ ��ࠬ��஢")
  |039: Str.Copy(s,"���ࠢ���� ᯥ�䨪��� ��ࠬ���")
  |040: Str.Copy(s,"�� ᮢ������ ����� ��ࠬ��஢")
  |041: Str.Copy(s,"�� ���� ���७��� ⨯�")
  |042: Str.Copy(s,"�� ᮢ���⨬� �� ��ᢠ������")
  |043: Str.Copy(s,"�� ����� ���� ⨯�� १���� �㭪樨")
  |044: Str.Copy(s,"���� १���� ��ᮢ���⨬�")

  |050: Str.Copy(s,"������ ���� ���ᨢ")
  |051: Str.Copy(s,"������ ���� ������")
  |052: Str.Copy(s,"������ ���� 㪠��⥫�")
  |053: Str.Copy(s,"������ ���� ������⢮")
  |054: Str.Copy(s,"������ ���� ��६�����")
  |055: Str.Copy(s,"������ ���� ��楤��")
  |056: Str.Copy(s,"������ ���� �����")
  |057: Str.Copy(s,"������ ���� �⠭���⭠� ��楤��")
  |058: Str.Copy(s,"������ ���� ���. ���ᨢ")
  |059: Str.Copy(s,"����஫� ⨯� ������ �ਬ������ � 㪠��⥫� ��� ����� (VAR ��ࠬ���)")
  |060: Str.Copy(s,"������ ⨯�� 㪠��⥫� ������ ���� ���ᨢ ��� ������")
  |061: Str.Copy(s,"�����୮��� � LEN ᫨誮� ������ ��� ����⥫쭠�")
  |062: Str.Copy(s,"������ ���� 㪠��⥫� �� ������")
  |063: Str.Copy(s,"������ ���� ��⮤")
  |064: Str.Copy(s,"��⮤ �� ��।����")
  |065: Str.Copy(s,"����� ��।����� ��⮤ ��� ����� �� ��㣮�� �����")
  |066: Str.Copy(s,"������ ���� 㪠��⥫� ��� ������ (VAR ��ࠬ���)")
  |067: Str.Copy(s,"��� ��⮤ ������ ���� �ਬ���� � 㪠��⥫�")
  |068: Str.Copy(s,"�������⨬� �맮� �㯥�-��⮤�")
  |069: Str.Copy(s,"�����४⭮� ��८�।������ ��⮤�")

  |080: Str.Copy(s,"�訡�� � ��������� �����");
  |081: Str.Copy(s,"���ࠢ��쭮� ��ࠦ����")
  |082: Str.Copy(s,"�訡�� � ���ᠭ���")
  |083: Str.Copy(s,"�訡�� � ��������� ⨯�")
  |086: Str.Copy(s,"������ ���� ������")
  |087: Str.Copy(s,"������ ���� ����⠭⭮� ��ࠦ����")
  |088: Str.Copy(s,"������ ���� ��� �����")
  |089: Str.Copy(s,"��ॠ���������� ��楤��")
  |090: Str.Copy(s,"�맮� �㭪樨 � ����樨 ������")
  |091: Str.Copy(s,"�맮� ��楤��� � ��ࠦ����")
  |093: Str.Copy(s,"�������⨬� � ��।����饬 ���㫥")
  |094: Str.Copy(s,"����襭� ⮫쪮 � ��।����饬 ���㫥");
  |095: Str.Copy(s,"����襭� ⮫쪮 �� �஢�� ������� �������樨")
  |096: Str.Copy(s,"�� ����� ���� �ᯮ��஢��")
  |097: Str.Copy(s,"�� ॠ��������� 㪠��⥫� ���।")

  |120: Str.Copy(s,"�� �������� ���ᮬ")
  |121: Str.Copy(s,"�� �������� ���祭���")
  |122: Str.Copy(s,"��室 �� �࠭��� ���������")
  |123: Str.Copy(s,"��ᢠ������ VAL ��६����� (���쪮 ��� �⥭��)");
  |124: Str.Copy(s,"��஦����� ��१��")
  |125: Str.Copy(s,"EXIT ��� LOOP'�")
  |126: Str.Copy(s,"����� ��⪠ 㦥 �뫠")
  |127: Str.Copy(s,"� CASE �㦭� ��� ���� ����ୠ⨢�");
  |128: Str.Copy(s,"��६����� 横�� ������ ���� �����쭮�")
  |129: Str.Copy(s,"�� �� RTS ��楤��")
  |130: Str.Copy(s,"��८�।������ RTS ��楤���")

  |190: Str.Copy(s,"�訡�� � ��������� ᨬ䠩��")
  |191: Str.Copy(s,"�����४⭠� ����� ᨬ䠩��")
  |192: Str.Copy(s,"���䫨�� ���ᨩ (�� �६��� �������樨)");
  |193: Str.Copy(s,"������ ������ ᨬ䠩�� �� ࠧ�襭�");

  |200: Str.Copy(s,"�� �� ॠ��������")
  |201: Str.Copy(s,"���誮� ����讥 �᫮")
  |202: Str.Copy(s,"�����४�� ������ ⨯ ������⢠")
  |203: Str.Copy(s,"������� �� ����");

  |220: Str.Copy(s,"���誮� ����� ��६�����")
  |221: Str.Copy(s,"���誮� ����� ��楤��")
  |222: Str.Copy(s,"���誮� ����� ��ࠬ��஢")
  |223: Str.Copy(s,"���誮� ����� ����ୠ⨢ � ������ CASE")
  |224: Str.Copy(s,"���誮� ����� 㪠��⥫��")
  |225: Str.Copy(s,"���誮� ����� �ᯮ��஢����� ⨯��")
  |226: Str.Copy(s,"���誮� ����让 ᯨ᮪ ������")
  |227: Str.Copy(s,"���誮� ������ ����� ���室�")
  |228: Str.Copy(s,"�� 墠⠥� ॣ���஢ (��� �⥪�)");
  |229: Str.Copy(s,"���誮� ����� ࠧ ���७��� ������");
  |230: Str.Copy(s,"���誮� ����� ����ᥩ � ��⮤���")
  |231: Str.Copy(s,"���誮� ����� ���� ��� ��楤���")
  |232: Str.Copy(s,"Too large type size");
  |233: Str.Copy(s,"ASSERT");
  |240: Str.Copy(s,"������㯭�� RTS ��楤��")
  ELSE Str.Copy(s,"�������⭠� �訡��");
  END;
END err_msg;

(*---------------------------------------------------------------*)
(*
TYPE
  block_ptr = POINTER TO block_rec;
  block_rec = RECORD size: INTEGER; next: block_ptr END;
  slot_ptr = POINTER TO slot_rec;
  slot_rec = RECORD next: slot_ptr END;

VAR
  slots: ARRAY [0..31] OF slot_ptr;
  stat : ARRAY [0..31] OF INTEGER;
  nodes: block_ptr;

PROCEDURE alloc(VAR a: sys.ADDRESS; size: INTEGER);
  VAR s,l: slot_ptr; n: block_ptr; co,i,sz: INTEGER;
BEGIN
  IF size<=HIGH(slots) THEN
    co:=32;
    INC(stat[size],co);
  ELSE co:=1
  END;
  sz:=size*co+SIZE(n^);
  mem.ALLOCATE(n,sz);
  n^.size:=sz;
  n^.next:=nodes; nodes:=n;
  a:=sys.ADDRESS(n)+SIZE(n^);
  IF size<=HIGH(slots) THEN
    l:=NIL; s:=a+size;
    FOR i:=0 TO co-2 DO
      s^.next:=l; l:=s;
      s:=sys.ADDRESS(s)+size;
    END;
    slots[size]:=l;
  END;
END alloc;

PROCEDURE ALLOCATE(VAR a: sys.ADDRESS; size: INTEGER);
  VAR s: slot_ptr;
BEGIN
  IF (size<=HIGH(slots)) & (slots[size]#NIL) THEN
    s:=slots[size]; slots[size]:=s^.next; a:=s;
  ELSE
    alloc(a,size);
  END;
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR a: sys.ADDRESS; size: INTEGER);
  VAR s: slot_ptr;
BEGIN
  IF (a=NIL) OR (size<=0) THEN RETURN END;
  IF size<=HIGH(slots) THEN
    s:=a;
    s^.next:=slots[size]; slots[size]:=s;
  END;
  a:=NIL;
END DEALLOCATE;

PROCEDURE ini_heap;
  VAR i: INTEGER;
BEGIN
  nodes:=NIL;
  FOR i:=0 TO HIGH(slots) DO slots[i]:=NIL END;
  FOR i:=0 TO HIGH(stat)  DO stat[i]:=0 END;
END ini_heap;

PROCEDURE release;
  VAR x: block_ptr; i: INTEGER;
BEGIN
  WHILE nodes#NIL DO
    x:=nodes; nodes:=nodes^.next;
    mem.DEALLOCATE(x,x^.size);
  END;
  IF args.flag('+','?') THEN
    FOR i:=0 TO HIGH(stat) DO
      IF stat[i]#0 THEN
        tty.print('%2d: %4d  %4dKb\n',i,stat[i],stat[i]*i DIV 256);
      END;
    END;
  END;
  ini_heap;
END release;
*)

PROCEDURE ALLOCATE(VAR a: ADDRESS; n: LONGINT);
BEGIN
  Storage.ALLOCATE(a,CARDINAL(n));
END ALLOCATE;

PROCEDURE DEALLOCATE(VAR a: ADDRESS; n: LONGINT);
BEGIN
  Storage.DEALLOCATE(a,CARDINAL(n));
END DEALLOCATE;

PROCEDURE release; END release;
PROCEDURE ini_heap; END ini_heap;

(*----------------------------------------------------------------*)

PROCEDURE _getstr(VAR s: ARRAY OF CHAR; VAR done: BOOLEAN);
BEGIN abort END _getstr;

PROCEDURE _error(l,c: INTEGER; source,msg: ARRAY OF CHAR);
BEGIN abort END _error;

PROCEDURE _message(msg: ARRAY OF CHAR); BEGIN abort END _message;

VAR i: CHAR;

BEGIN
  cardinal:=2;
  integer :=2;
  longint :=4;
  real    :=4;
  longreal:=8;
  boolean :=1;
  bitset  :=2;
  byte    :=1;
  word    :=2;
  addr    :=4;
  proctype:=4;
  nilval  :=INTEGER(NIL);

  min_sint:=MIN(SHORTINT);  max_sint:=MAX(SHORTINT);
  min_int :=MIN(INTEGER);   max_int :=MAX(INTEGER);
  min_lint:=MIN(LONGINT);   max_lint:=MAX(LONGINT);
  max_scard:=255;           max_card:=MAX(CARDINAL);

  max_hex_dig:=8;
  max_real:=REAL(7FFFFFFFH);
  min_real:=-max_real;
  max_dig :=9;
  max_exp :=64;
  oberon:=FALSE;
(*----------------------------------------------------------------*)
  FOR i:=0C TO 377C DO alpha[i]:=0C END;
  FOR i:='0' TO '9' DO alpha[i]:=2C END;
  FOR i:='a' TO 'z' DO alpha[i]:=2C END;
  FOR i:='A' TO 'Z' DO alpha[i]:=2C END;
  FOR i:=300C TO 377C DO alpha[i]:=1C END;
  alpha['_']:=1C;
  alpha['?']:=1C;
(*----------------------------------------------------------------*)
  getstr:=_getstr;
  error:=_error;
  message:=_message;
  pass2:=TRUE;
  ini_heap;
  FIO.IOcheck:=FALSE;
  Lib.EnableBreakCheck;
END pcM.
