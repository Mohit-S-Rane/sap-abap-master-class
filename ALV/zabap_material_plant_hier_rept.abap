*&---------------------------------------------------------------------*
*& Report ZABAP_MATERIAL_PLANT_HIER_REPT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MATERIAL_PLANT_HIER_REPT
* Title            : ABAP Material & Plant Hierarchical Format Report
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_material_plant_hier_rept NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MATERIAL_PLANT_HIER_REPT_TOP.
***************************************************
TABLES: mara,makt,ekpo,ekko,lfa1.
TYPE-POOLS slis.

TYPES: BEGIN OF ty_mara,
         matnr TYPE matnr, " Material Number
       END OF ty_mara,

       BEGIN OF ty_makt,
         matnr TYPE matnr, " Material Number
         maktx TYPE maktx, " Material Description
       END OF ty_makt,

       BEGIN OF ty_ekpo,
         matnr TYPE matnr, " Material Number
         ebeln TYPE ebeln, " Purchasing Document Number
         aedat TYPE erdat, " Purchasing Document Item Date
         menge TYPE bstmg, " Quantity
         meins TYPE bstme, " Purchase Order Unit of Measure
         netpr TYPE bprei, " Net Price
       END OF ty_ekpo,

       BEGIN OF ty_ekko,
         ebeln TYPE ebeln, " Purchasing Document Number
         lifnr TYPE lifnr, " Vendor Number
       END OF ty_ekko,

       BEGIN OF ty_lfa1,
         lifnr TYPE lifnr, " Vendor Number
         name1 TYPE name1_gp, " Vendor Name
       END OF ty_lfa1.

DATA: BEGIN OF lt_item OCCURS 0,
       yek TYPE i,
       matnr TYPE matnr,
       maktx TYPE maktx,
       ebeln TYPE ebeln,
       aedat TYPE erdat,
       name1 TYPE name1_gp,
       menge TYPE bstmg,
       meins TYPE bstme,
       netpr TYPE bprei,
      END OF lt_item.

TYPES: t_mara TYPE STANDARD TABLE OF ty_mara,
       t_makt TYPE STANDARD TABLE OF ty_makt,
       t_ekpo TYPE STANDARD TABLE OF ty_ekpo,
       t_ekko TYPE STANDARD TABLE OF ty_ekko,
       t_lfa1 TYPE STANDARD TABLE OF ty_lfa1.

DATA: wa_mara TYPE ty_mara,
      wa_makt TYPE ty_makt,
      wa_ekpo TYPE ty_ekpo,
      wa_ekko TYPE ty_ekko,
      wa_lfa1 TYPE ty_lfa1,

      lt_mara TYPE t_mara,
      lt_makt TYPE t_makt,
      lt_ekpo TYPE t_ekpo,
      lt_ekko TYPE t_ekko,
      lt_lfa1 TYPE t_lfa1,
      lt_header LIKE lt_item OCCURS 0 WITH HEADER LINE.

DATA: w_fcat TYPE slis_fieldcat_alv,
      t_fcat TYPE slis_t_fieldcat_alv,
      w_event TYPE slis_t_event,
      key TYPE slis_keyinfo_alv.

***************************************************
*INCLUDE ZABAP_MATERIAL_PLANT_HIER_REPT_SEL.
***************************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_matnr FOR mara-matnr, " Material Number
                  s_matkl FOR mara-matkl, " Material Group
                  s_mtart FOR mara-mtart, " Material Type
                  s_werks FOR ekpo-werks, " Plant
                  s_ersda FOR mara-ersda. " Creation Date
SELECTION-SCREEN:END OF BLOCK b1.
***************************************************
*INCLUDE ZABAP_MATERIAL_PLANT_HIER_REPT_F01.
***************************************************
***************************************************

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM key_info.
  PERFORM fill_cat.
  PERFORM combine.
  PERFORM display.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT
    matnr
    FROM mara INTO TABLE lt_mara
    WHERE matnr IN s_matnr AND
    matkl IN s_matkl AND
    ersda IN s_ersda.

    IF lt_mara[] IS NOT INITIAL.
      SELECT
        matnr
        maktx
        FROM makt INTO TABLE lt_makt
        FOR ALL ENTRIES IN lt_mara
        WHERE matnr = lt_mara-matnr.
    ENDIF.

    IF lt_mara[] IS NOT INITIAL.
      SELECT
        matnr
        ebeln
        aedat
        menge
        meins
        netpr
        FROM ekpo INTO TABLE lt_ekpo
        FOR ALL ENTRIES IN lt_mara
        WHERE matnr = lt_mara-matnr.
    ENDIF.

    IF lt_ekpo[] IS NOT INITIAL.
      SELECT
        ebeln
        lifnr
        FROM ekko INTO TABLE lt_ekko
        FOR ALL ENTRIES IN lt_ekpo
        WHERE ebeln = lt_ekpo-ebeln.
    ENDIF.

    IF lt_ekko[] IS NOT INITIAL.
      SELECT
        lifnr
        name1
        FROM lfa1 INTO TABLE lt_lfa1
        FOR ALL ENTRIES IN lt_ekko
        WHERE lifnr = lt_ekko-lifnr.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form KEY_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM key_info .
  key-header01 = 'YEK'.
  key-item01 = 'YEK'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_cat .
  CLEAR w_fcat.
  w_fcat-fieldname = 'MATNR'.
  w_fcat-tabname = 'LT_HEADER'.
  w_fcat-seltext_m = 'Material No.'.
  w_fcat-outputlen = 15.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'MAKTX'.
  w_fcat-tabname = 'LT_HEADER'.
  w_fcat-seltext_m = 'Material Description'.
  w_fcat-outputlen = 50.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'EBELN'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'Order No.'.
  w_fcat-outputlen = 15.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'AEDAT'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'Creation Date'.
  w_fcat-outputlen = 15.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'NAME1'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'Supplier Name'.
  w_fcat-outputlen = 30.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'MENGE'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'Quantity'.
  w_fcat-outputlen = 25.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'MEINS'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'U O M'.
  w_fcat-outputlen = 25.
  APPEND w_fcat TO t_fcat.

  CLEAR w_fcat.
  w_fcat-fieldname = 'NETPR'.
  w_fcat-tabname = 'LT_ITEM'.
  w_fcat-seltext_m = 'Unit Price'.
  w_fcat-outputlen = 25.
  APPEND w_fcat TO t_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMBINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM combine .
DATA count TYPE i.
  LOOP AT lt_mara INTO wa_mara.
    LOOP AT lt_ekpo INTO wa_ekpo WHERE matnr = wa_mara-matnr.
      MOVE: wa_ekpo-matnr TO lt_item-matnr,
            wa_ekpo-ebeln TO lt_item-ebeln,
            wa_ekpo-aedat TO lt_item-aedat,
            wa_ekpo-menge TO lt_item-menge,
            wa_ekpo-meins TO lt_item-meins,
            wa_ekpo-netpr TO lt_item-netpr.

      READ TABLE lt_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr.
                                               lt_item-maktx = wa_makt-maktx.

      READ TABLE lt_ekko INTO wa_ekko WITH KEY ebeln = wa_ekpo-ebeln.

      READ TABLE lt_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_ekko-lifnr.

        lt_item-name1 = wa_lfa1-name1.
        lt_item-yek = count.

      APPEND lt_item.
    ENDLOOP.
    count = count + 1.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
lt_header[] = lt_item[].
DELETE ADJACENT DUPLICATES FROM lt_header COMPARING yek.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-cprog
      it_fieldcat = t_fcat
      it_events = w_event
      i_tabname_header = 'LT_HEADER'
      i_tabname_item = 'LT_ITEM'
      is_keyinfo = key
    TABLES
      t_outtab_header = lt_header
      t_outtab_item = lt_item.
ENDFORM.