*&---------------------------------------------------------------------*
*& Report ZABAP_PURCHASE_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_PURCHASE_ORDER_DETAILS
* Title            : ABAP Purchase Order Details Report
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_purchase_order_details NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_PURCHASE_ORDER_DETAILS_TOP.
********************************************
TABLES: lfa1,ekko,ekpo.

TYPES: BEGIN OF ty_lfa1,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
        ort01 TYPE ort01_gp,
        pstlz TYPE pstlz,
        stras TYPE stras_gp,
       END OF ty_lfa1,

       BEGIN OF ty_ekko,
        ebeln TYPE ebeln,
        aedat TYPE erdat,
        zterm TYPE dzterm,
       END OF ty_ekko,

       BEGIN OF ty_ekpo,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        menge TYPE bstmg,
        meins TYPE bstme,
        netpr TYPE bprei,
       END OF ty_ekpo.

TYPES: t_lfa1 TYPE STANDARD TABLE OF ty_lfa1,
       t_ekko TYPE STANDARD TABLE OF ty_ekko,
       t_ekpo TYPE STANDARD TABLE OF ty_ekpo.

DATA: wa_lfa1 TYPE ty_lfa1,
      wa_ekko TYPE ty_ekko,
      wa_ekpo TYPE ty_ekpo,
      gt_lfa1 TYPE t_lfa1,
      lt_ekko TYPE t_ekko,
      lt_ekpo TYPE t_ekpo.

DATA: gc_lifnr TYPE lifnr.
********************************************

*INCLUDE ZABAP_PURCHASE_ORDER_DETAILS_SEL.
********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_lifnr FOR lfa1-lifnr,
                  s_aedat FOR ekko-aedat.
SELECTION-SCREEN:END OF BLOCK b1.
********************************************

*INCLUDE ZABAP_PURCHASE_ORDER_DETAILS_F01.
********************************************
********************************************

START-OF-SELECTION.
  PERFORM get_lfa1 CHANGING gt_lfa1.
  PERFORM display_lfa1 TABLES gt_lfa1.
*&---------------------------------------------------------------------*
*& Form GET_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_LFA1
*&---------------------------------------------------------------------*
FORM get_lfa1  CHANGING p_gt_lfa1.
  SELECT
    lifnr
    name1
    ort01
    pstlz
    stras
    FROM lfa1 INTO TABLE gt_lfa1
    WHERE lifnr IN s_lifnr.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_LFA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LFA1
*&---------------------------------------------------------------------*
FORM display_lfa1  TABLES   p_gt_lfa1 LIKE gt_lfa1.
  LOOP AT p_gt_lfa1 INTO wa_lfa1.
    WRITE:/ wa_lfa1-lifnr HOTSPOT,
         15 wa_lfa1-name1,
         40 wa_lfa1-ort01,
         60 wa_lfa1-pstlz,
         80 wa_lfa1-stras.
    HIDE wa_lfa1-lifnr.
  ENDLOOP.
ENDFORM. " DISPLAY_LFA1

AT LINE-SELECTION.
  CASE sy-lsind.
    WHEN 1.
      SELECT
        ebeln
        aedat
        zterm
        FROM ekko INTO TABLE lt_ekko
        WHERE lifnr EQ gc_lifnr AND
        aedat IN s_aedat.

      LOOP AT lt_ekko INTO wa_ekko.
        WRITE:/1 wa_ekko-ebeln HOTSPOT,
              30 wa_ekko-aedat,
              60 wa_ekko-zterm.
        HIDE wa_ekko-ebeln.
      ENDLOOP.

    WHEN 2.
      SELECT
        ebelp
        matnr
        menge
        meins
        netpr
        FROM ekpo INTO TABLE lt_ekpo
        WHERE ebeln = wa_ekko-ebeln.

      LOOP AT lt_ekpo INTO wa_ekpo.
        WRITE:/ wa_ekpo-ebelp,
             15 wa_ekpo-matnr HOTSPOT,
             30 wa_ekpo-menge,
             60 wa_ekpo-meins,
             80 wa_ekpo-netpr.
        HIDE wa_ekpo-matnr.
      ENDLOOP.

    WHEN 3.
      SET PARAMETER ID 'MAT' FIELD wa_ekpo-matnr.
      CALL TRANSACTION 'MM02'AND SKIP FIRST SCREEN.
  ENDCASE.

TOP-OF-PAGE.
  WRITE:/60 'Supplier Details' COLOR 7.
  SKIP.
  ULINE.

TOP-OF-PAGE DURING LINE-SELECTION.
  CASE sy-lsind.
    WHEN 1.
      WRITE:/60 'Purchase Order - Header Data' COLOR 6.
      SKIP.
      ULINE.
    WHEN 2.

      WRITE:/60 'Purchase Order - Item Data' COLOR 6.
      SKIP.
      ULINE.
  ENDCASE.