*&---------------------------------------------------------------------*
*& Report ZABAP_ADD_BUT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_ADD_BUTTON_SELECTION_SCN
* Title            : ABAP Add Push Button on Selection Screen
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_add_button_selection_scn NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_ADD_BUT_SELECTION_SCREEN_TOP.
**********************************************
TABLES: mara, sscrfields.

TYPES: BEGIN OF ty_mara,
        matnr TYPE matnr,
        mtart TYPE mtart,
        meins TYPE meins,
        ntgew TYPE ntgew,
        brgew TYPE brgew,
       END OF ty_mara,

       BEGIN OF ty_mard,
        matnr TYPE matnr,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        labst TYPE labst,
       END OF ty_mard,

       BEGIN OF ty_mseg,
        matnr TYPE matnr,
        bwart TYPE bwart,
        menge TYPE menge_d,
        dmbtr TYPE dmbtr,
       END OF ty_mseg.

DATA: ls_mara TYPE ty_mara,
      ls_mard TYPE ty_mard,
      ls_mseg TYPE ty_mseg,
      lt_mara TYPE TABLE OF ty_mara,
      lt_mard TYPE TABLE OF ty_mard,
      lt_mseg TYPE TABLE OF ty_mseg.
**********************************************
*INCLUDE ZABAP_ADD_BUT_SELECTION_SCREEN_SEL.
**********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
  SELECT-OPTIONS s_matnr FOR mara-matnr.
SELECTION-SCREEN:END OF BLOCK b1.

SELECTION-SCREEN:BEGIN OF BLOCK b2 WITH FRAME TITLE t2.
  PARAMETERS: mat RADIOBUTTON GROUP rg1, " Material
              slo RADIOBUTTON GROUP rg1, " Storage Locarion
              grc RADIOBUTTON GROUP rg1. " Goods Reciept
SELECTION-SCREEN:END OF BLOCK b2.

SELECTION-SCREEN: FUNCTION KEY 1,
                  FUNCTION KEY 2.
**********************************************
*INCLUDE ZABAP_ADD_BUT_SELECTION_SCREEN_FORM.
**********************************************
**********************************************

INITIALIZATION.
  PERFORM label.

AT SELECTION-SCREEN.
  PERFORM validate_screen.

START-OF-SELECTION.
  PERFORM get_display_data.
*&---------------------------------------------------------------------*
*& Form LABEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM label .
  t1 = 'Material Selection'.
  t2 = 'Radio Buttons'.

  sscrfields-functxt_01 = 'Report'.
  sscrfields-functxt_02 = 'Exit'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_screen .
  IF sscrfields-ucomm = 'FC01'.
    sscrfields-ucomm = 'ONLI'.
  ELSEIF sscrfields-ucomm = 'FC02'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_display_data .
  IF mat = 'X'.
    SELECT
      matnr
      mtart
      meins
      ntgew
      brgew
      FROM mara INTO TABLE lt_mara
      WHERE matnr IN s_matnr.

    LOOP AT lt_mara INTO ls_mara.
      WRITE:/ ls_mara-matnr,
           20 ls_mara-mtart,
           40 ls_mara-meins,
           60 ls_mara-ntgew,
           80 ls_mara-brgew.
    ENDLOOP.

    ELSEIF slo = 'X'.
      SELECT
        matnr
        werks
        lgort
        labst
        FROM mard INTO TABLE lt_mard
        WHERE matnr IN s_matnr.

      LOOP AT lt_mard INTO ls_mard.
        WRITE:/ ls_mard-matnr,
             20 ls_mard-werks,
             40 ls_mard-lgort,
             60 ls_mard-labst.
      ENDLOOP.
  ELSE.
    SELECT
      matnr
      bwart
      menge
      dmbtr
      FROM mseg INTO TABLE lt_mseg
      WHERE matnr IN s_matnr.

    LOOP AT lt_mseg INTO ls_mseg.
      WRITE:/ ls_mseg-matnr,
           20 ls_mseg-bwart,
           40 ls_mseg-menge,
           60 ls_mseg-dmbtr.
    ENDLOOP.
  ENDIF.
ENDFORM.