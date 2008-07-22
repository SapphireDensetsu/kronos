DEFINITION MODULE Model; (* Sem 13-Sep-86. (c) KRONOS *)

FROM mCodeMnem IMPORT   shl, shr, stot, lodt, lxb, sxb, lsw0, ssw0, copt,
                        and, add, lib, bic, swap;

TYPE

  Object=POINTER TO ObjectRec;

  ListBody;

  List=RECORD
    Size: INTEGER;
    Body: ListBody;
  END;

  Segment=RECORD
    start,end,size: INTEGER;
  END;

  IterProc=PROCEDURE (Object);

  String=ARRAY [0..15] OF CHAR;

  Objects=(signal, pin, externalpin, chip, chiptype, conductor, bus, picture);

  SigTypes=(power,fantom,fixed);

  SigType=SET OF SigTypes;

  ObjectRec=RECORD
    Info:        INTEGER;      (* For internal use only                 *)
    CASE :Objects OF
    signal:                     (*13*)
      TiedPins: List;           (* Список ножек подключенных к сигналу   *)
      Bus     : Object;         (* Шина, к которой принадлежит сигнал    *)
      ChainB  : Object;         (* Список проводников сигнала на плате   *)
      ChainD  : Object;         (* Список проводников сигнала на схеме   *)
      sType   : SigType;        (* Тип сигнала                           *)
      sGang   : INTEGER;        (* Зарезервировано для трассировщика     *)
      sHard   : INTEGER;        (* Зарезервировано для трассировщика     *)
   |pin:                        (*5*)
      No: INTEGER;              (* Номер пина                            *)
      Signal: Object;           (* Подключенный к пину сигнал            *)
      Chip:  Object;            (* Чип, к которому принадлежит пин       *)
      State: INTEGER;           (* Зарезервировано для моделирования     *)
   |externalpin:                (*14*)
      PinType:  Object;         (* Тип пина                              *)
      EPinNo: INTEGER;          (* Номер пина                            *)
      Host: Object;             (*                                       *)
      PinX, PinY: INTEGER;      (*                                       *)
      TrackWidth: INTEGER;      (* Рекомендуемый размер прводника для
                                   подключения пина к цепи               *)
   |chip:                       (*16*)
      ChipType: Object;         (* Тип чипа                              *)
      Pins: List;               (* Список ножек чипа                     *)
      XB,YB,RB: INTEGER;        (* Координаты и ориентация чипа на плате *)
      cBefor,
      cInit,
      cAfter: INTEGER;          (* Моделирующие роцедуры                 *)
      cValue: INTEGER;          (* Номинал                               *)
   |chiptype:                   (*16*)
      All:          List;       (* Список всех об'ектов модели           *)
      ExternalPins: List;       (* Интерфейсные пины модели              *)
      ctX,ctY:      INTEGER;    (* Размеры чипа на плате                 *)
      DX,DY:        INTEGER;    (* Размеры чипа на схеме                 *)
      DtxtX, DtxtY: INTEGER;    (*                                       *)
   |bus:                        (*10*)
      Signals:  List;           (* Принадлежащие шине сигналы            *)
      BusImage: List;           (* Изображение шины на схеме             *)
   |conductor:                  (*11*)
      cLen : INTEGER;           (* Количество сегментов                  *)
      cFree: INTEGER;           (* Первый свободный сегмент              *)
      cType: ARRAY [0..0] OF Segment;
   |picture:
      pUp       : Object;
      pDown     : Object;
      pRight    : Object;
      pLeft     : Object;
      pLines    : Object;
      pX1,pY1   : INTEGER;
      pX2,pY2   : INTEGER;
    END;
    Name:        String;        (* Имя объекта                           *)
  END;

PROCEDURE Tag(o: Object): Objects;
CODE 0 lxb END Tag;

PROCEDURE setTag(o: Object; t: Objects);
CODE 0 swap sxb END setTag;

PROCEDURE Poz(o: Object): INTEGER;
CODE lsw0 lib 0FFh bic 8 shr END Poz;

PROCEDURE setPoz(o: Object; p: INTEGER);
CODE stot copt lsw0 lib 0FFh and lodt 8 shl add ssw0 END setPoz;

PROCEDURE InitList(VAR l: List);
(* Инициализация списка *)

PROCEDURE KillList(VAR l: List);
(* Уничтожение списка *)

PROCEDURE Tie  (VAR l: List; o: Object);  (* Добавляет к списку объект *)

PROCEDURE UnTie(VAR l: List; o: Object);  (* Удаляет объект из списка *)

PROCEDURE Iterate(VAR l: List; p: IterProc);
(* Вызывает процедуру p для всех элементов списка *)

PROCEDURE Lset(VAR l: List; n: INTEGER; o: Object);
(* Занесение в список в позицию n *)

PROCEDURE Lget(VAR l: List; n: INTEGER): Object;
(* Чтение позиции n в списке l *)

PROCEDURE Lsize(VAR l: List): INTEGER;(* Размер списка *)

PROCEDURE Osize(t: Objects): INTEGER;(* Размер объекта в словах *)

PROCEDURE NewObject(t: Objects): Object;
(* Создает объект с пустыми атрибутами *)

PROCEDURE KillObject(VAR o: Object);
(* Уничтожает объект *)

PROCEDURE CleareModel(o: Object);

PROCEDURE RemoveModel(VAR o: Object);

VAR DoList  : PROCEDURE (VAR List);
VAR DoObject: PROCEDURE (VAR Object);
VAR DoNumber: PROCEDURE (VAR INTEGER);

PROCEDURE Do(o: Object);

VAR ObjectsNo: INTEGER;

END Model.
