*&---------------------------------------------------------------------*
*& Report ZABAP_CONTROL_BREAK_STATMENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_CONTROL_BREAK_STATMENT
* Title            : ABAP Control Break Statment
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_control_break_statment NO STANDARD PAGE HEADING.

TABLES:kna1,vbak.

SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_kunnr FOR kna1-kunnr,
                  s_erdat FOR vbak-erdat.
SELECTION-SCREEN:END OF BLOCK b1.

TYPES: BEGIN OF ty_ord,
        kunnr TYPE kunnr,
        vbeln TYPE vbeln_va,
        erdat TYPE erdat,
        netwr TYPE netwr_ak,
       END OF ty_ord.

DATA: wa_ord TYPE ty_ord,
      it_ord TYPE TABLE OF ty_ord.

  SELECT
    kna1~kunnr
    vbak~vbeln
    vbak~erdat
    vbak~netwr
    INTO TABLE it_ord
    FROM kna1 INNER JOIN vbak
    ON kna1~kunnr = vbak~kunnr
    WHERE kna1~kunnr IN s_kunnr AND
    vbak~erdat IN s_erdat.

  SORT it_ord BY kunnr vbeln.

  LOOP AT it_ord INTO wa_ord.
    AT FIRST.
      WRITE:/50 'Stock Details Report' COLOR 5.
      SKIP.
      ULINE.
    ENDAT.

    AT NEW kunnr.
      WRITE:/ 'The customer number is:', wa_ord-kunnr.
    ENDAT.

    WRITE:/ wa_ord-vbeln,
         20 wa_ord-erdat,
         40 wa_ord-netwr.

    AT END OF kunnr.
      SUM.
      WRITE:/ 'The total amount is:', wa_ord-netwr.
      SKIP.
      ULINE.
    ENDAT.

    AT LAST.
      SUM.
      WRITE:/ 'The grand total amount is:', wa_ord-netwr.
      SKIP.
      ULINE.
    ENDAT.

  ENDLOOP.