*&---------------------------------------------------------------------*
*& Report ZABAP_STOCK_DETAILS_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_STOCK_DETAILS_REPORT
* Title            : ABAP Stock Details Report Based on Plant
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_stock_details_report NO STANDARD PAGE HEADING LINE-COUNT 25(5).

*INCLUDE ZABAP_STOCK_DETAILS_REPORT_TOP.
***********************************************
TABLES: mara,makt,mseg.

TYPES:BEGIN OF ty_mara,
        matnr TYPE matnr,
      END OF ty_mara,

      BEGIN OF ty_makt,
        matnr TYPE matnr,
        maktx TYPE maktx,
      END OF ty_makt,

      BEGIN OF ty_mseg,
        matnr TYPE matnr,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        menge TYPE menge_d,
        meins TYPE meins,
        dmbtr TYPE dmbtr,
      END OF ty_mseg,

      BEGIN OF ty_final,
        werks TYPE werks_d,
        lgort TYPE lgort_d,
        matnr TYPE matnr,
        maktx TYPE maktx,
        menge TYPE menge_d,
        meins TYPE meins,
        dmbtr TYPE dmbtr,
      END OF ty_final.

DATA: wa_mara TYPE ty_mara,
      it_mara TYPE TABLE OF ty_mara,

      wa_makt TYPE ty_makt,
      it_makt TYPE TABLE OF ty_makt,

      wa_mseg TYPE ty_mseg,
      it_mseg TYPE TABLE OF ty_mseg,

      wa_final TYPE ty_final,
      it_final TYPE TABLE OF ty_final.
***********************************************
*INCLUDE ZABAP_STOCK_DETAILS_REPORT_SEL.
***********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  SELECT-OPTIONS:s_matnr FOR mara-matnr,
                 s_mtart FOR mara-mtart,
                 s_ersda FOR mara-ersda,
                 s_werks FOR mseg-werks,
                 s_lgort FOR mseg-lgort.
SELECTION-SCREEN:END OF BLOCK b1.
***********************************************
*INCLUDE ZABAP_STOCK_DETAILS_REPORT_FORM.
***********************************************
***********************************************

INITIALIZATION.
  PERFORM init.

AT SELECTION-SCREEN ON s_werks.
  PERFORM autho.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM combine_data.

END-OF-SELECTION.
  PERFORM display.
  PERFORM buttons.
*&---------------------------------------------------------------------*
*& Form INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init .
  s_werks-sign = 'I'.
  s_werks-option = 'BT'.
  s_werks-low = '1000'.
  s_werks-high = '3000'.
  APPEND s_werks.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM autho .
  IF s_werks-low < '1000' OR s_werks-high > '3000'.
    MESSAGE TEXT-001 TYPE 'E'.
  ENDIF.
ENDFORM.
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
    FROM mara INTO TABLE it_mara
    WHERE matnr IN s_matnr AND
    matkl IN s_mtart AND
    ersda IN s_ersda.

    IF it_mara[] IS NOT INITIAL.
      SELECT
        matnr
        maktx FROM makt INTO TABLE it_makt
        FOR ALL ENTRIES IN it_mara
        WHERE matnr = it_mara-matnr.
    ENDIF.

    IF it_mara[] IS NOT INITIAL.
      SELECT
        matnr
        werks
        lgort
        menge
        meins
        dmbtr
        FROM mseg INTO TABLE it_mseg
        FOR ALL ENTRIES IN it_mara
        WHERE matnr = it_mara-matnr AND
        werks IN s_werks AND
        lgort IN s_lgort.
    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COMBINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM combine_data .
LOOP AT it_mara INTO wa_mara.
  LOOP AT it_mseg INTO wa_mseg WHERE matnr = wa_mara-matnr.
    MOVE: wa_mseg-matnr TO wa_final-matnr,
          wa_mseg-werks TO wa_final-werks,
          wa_mseg-lgort TO wa_final-lgort,
          wa_mseg-menge TO wa_final-menge,
          wa_mseg-meins TO wa_final-meins,
          wa_mseg-dmbtr TO wa_final-dmbtr.

    READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr.
    IF sy-subrc IS INITIAL.
      wa_final-maktx = wa_makt-maktx.
      APPEND wa_final TO it_final.
    ENDIF.
  ENDLOOP.
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
SORT it_final BY matnr werks lgort.

LOOP AT it_final INTO wa_final.
  AT FIRST.
    WRITE:/ 'Plant' COLOR 2,
         15 'S Location' COLOR 2,
         30 'Material No.' COLOR 2,
         50 'Description' COLOR 2,
         85 'Quantity' COLOR 2,
         100 'U O M' COLOR 2,
         115 'Net Price' COLOR 2.
    SKIP.
    ULINE.
  ENDAT.

  AT NEW werks.
    WRITE:/1 wa_final-werks.
  ENDAT.

  AT NEW lgort.
    WRITE:/15 wa_final-lgort.
  ENDAT.

  WRITE:/30 wa_final-matnr,
         50 wa_final-maktx,
         77 wa_final-menge,
         100 wa_final-meins,
         120 wa_final-dmbtr.

  AT END OF matnr.
    SUM.
    WRITE:/ ' The total quantity is: ', wa_final-menge.
    WRITE:/ ' The total amount is: ', wa_final-dmbtr.
    SKIP.
    ULINE.
  ENDAT.
ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUTTONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM buttons .
  SET PF-STATUS 'ZBUTTON'.
ENDFORM.

DATA: fnam(20),
      fval(20).

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'MAH4'.
      GET CURSOR FIELD fnam VALUE fval.
      SET PARAMETER ID 'MAT' FIELD fval.
      CALL TRANSACTION 'MM02'.
    WHEN 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

  TOP-OF-PAGE.
    WRITE:/70 'Stock Details Report' COLOR 7.
    SKIP.
    ULINE.

  END-OF-PAGE.
    ULINE.
    WRITE:/ sy-pagno, 70 '**** Thank You *****' .