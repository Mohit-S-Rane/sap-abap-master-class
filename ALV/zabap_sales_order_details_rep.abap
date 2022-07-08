*&---------------------------------------------------------------------*
*& Report ZABAP_SALES_ORDER_DETAILS_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_SALES_ORDER_DETAILS_REP
* Title            : ABAP Sales Order Details Report based on Customer
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_sales_order_details_rep NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_SALES_ORDER_DETAILS_REP_TOP.
**********************************************
TABLES: kna1,vbak,vbap.
TYPE-POOLS slis.

TYPES: BEGIN OF ty_kna1,
        kunnr TYPE kunnr,
        name1 TYPE name1_gp,
        ort01 TYPE ort01_gp,
        pstlz TYPE pstlz,
        stras TYPE stras_gp,
       END OF ty_kna1,

       BEGIN OF ty_vbak,
        vbeln TYPE vbeln_va,
        erdat TYPE erdat,
        netwr TYPE netwr_ak,
       END OF ty_vbak,

       BEGIN OF ty_vbap,
        posnr TYPE posnr,
        matnr TYPE matnr,
        kwmeng TYPE kwmeng,
        meins TYPE meins,
        netpr TYPE netpr,
       END OF ty_vbap,

      t_kna1 TYPE STANDARD TABLE OF ty_kna1,
      t_vbak TYPE STANDARD TABLE OF ty_vbak,
      t_vbap TYPE STANDARD TABLE OF ty_vbap.

DATA: lt_kna1 TYPE t_kna1,
      lt_vbak TYPE t_vbak,
      lt_vbap TYPE t_vbap.

DATA: f_kna1 TYPE slis_fieldcat_alv,
      f_vbak TYPE slis_fieldcat_alv,
      f_vbap TYPE slis_fieldcat_alv,
      t_kna1 TYPE slis_t_fieldcat_alv,
      t_vbak TYPE slis_t_fieldcat_alv,
      t_vbap TYPE slis_t_fieldcat_alv,
      w_event TYPE slis_alv_event,
      t_event TYPE slis_t_event.

DATA: v_kunnr TYPE kunnr,
      v_vbeln TYPE vbeln_va,
      v_matnr TYPE matnr.
**********************************************
*INCLUDE ZABAP_SALES_ORDER_DETAILS_REP_SEL.
**********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS: s_kunnr FOR kna1-kunnr,
                  s_erdat FOR vbak-erdat.
SELECTION-SCREEN:END OF BLOCK b1.
**********************************************
*INCLUDE ZABAP_SALES_ORDER_DETAILS_REP_F01.
**********************************************
**********************************************

START-OF-SELECTION.
  PERFORM get_kna1.
  PERFORM fill_cat.
  PERFORM event.
  PERFORM display.
*&---------------------------------------------------------------------*
*& Form GET_KNA1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_kna1 .
  SELECT
    kunnr
    name1
    ort01
    pstlz
    stras
    FROM kna1 INTO TABLE lt_kna1
    WHERE kunnr IN s_kunnr.
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
  CLEAR f_kna1.
  f_kna1-col_pos = 1.
  f_kna1-fieldname = 'KUNNR'.
  f_kna1-tabname = 'LT_KNA1'.
  f_kna1-seltext_m = 'Customer Number'.
  f_kna1-outputlen = 15.
  APPEND f_kna1 TO t_kna1.

  CLEAR f_kna1.
  f_kna1-col_pos = 2.
  f_kna1-fieldname = 'NAME1'.
  f_kna1-tabname = 'LT_KNA1'.
  f_kna1-seltext_m = 'Customer Name'.
  f_kna1-outputlen = 35.
  APPEND f_kna1 TO t_kna1.

  CLEAR f_kna1.
  f_kna1-col_pos = 3.
  f_kna1-fieldname = 'ORT01'.
  f_kna1-tabname = 'LT_KNA1'.
  f_kna1-seltext_m = 'City'.
  APPEND f_kna1 TO t_kna1.

  CLEAR f_kna1.
  f_kna1-col_pos = 4.
  f_kna1-fieldname = 'PSTLZ'.
  f_kna1-tabname = 'LT_KNA1'.
  f_kna1-edit = 'X'.
  f_kna1-seltext_m = 'Postal Code'.
  f_kna1-outputlen = 15.
  APPEND f_kna1 TO t_kna1.

  CLEAR f_kna1.
  f_kna1-col_pos = 5.
  f_kna1-fieldname = 'STRAS'.
  f_kna1-tabname = 'LT_KNA1'.
  f_kna1-seltext_m = 'Street'.
  f_kna1-outputlen = 25.
  APPEND f_kna1 TO t_kna1.

  CLEAR f_vbak.
  f_vbak-col_pos = 1.
  f_vbak-fieldname = 'VBELN'.
  f_vbak-tabname = 'LT_VBAK'.
  f_vbak-seltext_m = 'Order Number'.
  f_vbak-outputlen = 15.
  APPEND f_vbak TO t_vbak.

  CLEAR f_vbak.
  f_vbak-col_pos = 2.
  f_vbak-fieldname = 'ERDAT'.
  f_vbak-tabname = 'LT_VBAK'.
  f_vbak-seltext_m = 'Order Date'.
  f_vbak-outputlen = 15.
  APPEND f_vbak TO t_vbak.

  CLEAR f_vbak.
  f_vbak-col_pos = 3.
  f_vbak-fieldname = 'NETWR'.
  f_vbak-tabname = 'LT_VBAK'.
  f_vbak-seltext_m = 'Bill Amount'.
  f_vbak-outputlen = 15.
  f_vbak-edit = 'X'.
  APPEND f_vbak TO t_vbak.

  CLEAR f_vbap.
  f_vbap-col_pos = 1.
  f_vbap-fieldname = 'POSNR'.
  f_vbap-tabname = 'LT_VBAP'.
  f_vbap-seltext_m = 'Item Number'.
  APPEND f_vbap TO t_vbap.

  CLEAR f_vbap.
  f_vbap-col_pos = 2.
  f_vbap-fieldname = 'MATNR'.
  f_vbap-tabname = 'LT_VBAP'.
  f_vbap-seltext_m = 'Material Number'.
  APPEND f_vbap TO t_vbap.

  CLEAR f_vbap.
  f_vbap-col_pos = 3.
  f_vbap-fieldname = 'KWMENG'.
  f_vbap-tabname = 'LT_VBAP'.
  f_vbap-seltext_m = 'Qunatity'.
  APPEND f_vbap TO t_vbap.

  CLEAR f_vbap.
  f_vbap-col_pos = 4.
  f_vbap-fieldname = 'MEINS'.
  f_vbap-tabname = 'LT_VBAP'.
  f_vbap-seltext_m = 'U O M'.
  APPEND f_vbap TO t_vbap.

  CLEAR f_vbap.
  f_vbap-col_pos = 5.
  f_vbap-fieldname = 'NETPR'.
  f_vbap-tabname = 'LT_VBAP'.
  f_vbap-seltext_m = 'Unit Price'.
  APPEND f_vbap TO t_vbap.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM event .
  w_event-name = 'USER_COMMAND'.
  w_event-form = 'INTERACTIVE'.
  APPEND w_event TO t_event.

  CLEAR w_event.
  w_event-name = 'TOP_OF_PAGE'.
  w_event-form = 'HEADING'.
  APPEND w_event TO t_event.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-cprog
      it_fieldcat = t_kna1
      it_events = t_event
    TABLES
      t_outtab = lt_kna1.
ENDFORM.

FORM interactive USING ucomm LIKE sy-ucomm sel TYPE slis_selfield.
  IF sel-fieldname = 'KUNNR'.
    v_kunnr = sel-value.
    SELECT
      vbeln
      erdat
      netwr
      FROM vbak INTO TABLE lt_vbak
      WHERE kunnr = v_kunnr AND
      erdat IN s_erdat.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-cprog
        it_fieldcat = t_vbak
        it_events = t_event
      TABLES
        t_outtab = lt_vbak.
  ENDIF.

  IF sel-fieldname = 'VBELN'.
    v_vbeln = sel-value.
    SELECT
      posnr
      matnr
      kwmeng
      meins
      netpr
      FROM vbap INTO TABLE lt_vbap
      WHERE vbeln = v_vbeln.

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title = 'Item Details'
        i_screen_start_column = 10
        i_screen_start_line = 10
        i_screen_end_column = 90
        i_screen_end_line = 90
        i_tabname = 'LT_VBAP'
        it_fieldcat = t_vbap
        i_callback_program = sy-cprog
      IMPORTING
        es_selfield = sel
      TABLES
        t_outtab = lt_vbap.
  ENDIF.

  IF sel-fieldname = 'MATNR'.
    v_matnr = sel-value.
    SET PARAMETER ID 'MAT' FIELD v_matnr.
    CALL TRANSACTION 'MM02' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.

FORM heading.
  DATA: wa_list TYPE slis_listheader,
        lt_list TYPE slis_t_listheader,
        str TYPE string.

  wa_list-typ = 'H'.
  wa_list-info = 'SWAN Solution Pvt. Ltd'.
  APPEND wa_list TO lt_list.

  wa_list-typ = 'S'.
  wa_list-key = 'Date : '.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO str SEPARATED BY '.'.

  wa_list-info = str .
  APPEND wa_list TO lt_list.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_list
      i_logo = 'SWAN'.
ENDFORM.