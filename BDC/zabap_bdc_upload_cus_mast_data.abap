*&---------------------------------------------------------------------*
*& Report ZABAP_BDC_UPLOAD_CUS_MAST_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_BDC_UPLOAD_CUS_MAST_DATA
* Title            : ABAP BDC Upload Customer Master Data
* Description      : Uploading the customer master through BDC technique where multiple bank information of a particular customer needs to be maintained in the screen table control.
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_bdc_upload_cus_mast_data NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_BDC_UPLOAD_CUS_MAST_DATA_TOP.
********************************************
TABLES: lfa1,lfbk,lfb1.
TYPES: BEGIN OF ty_xk01,
        lifnr TYPE lifnr,
        bukrs TYPE bukrs,
        ekorg TYPE ekorg,
        ktokk TYPE ktokk,
        anred TYPE anred,
        name1 TYPE name1_gp,
        sortl TYPE sortl,
        stras TYPE stras_gp,
        ort01 TYPE ort01_gp,
        pstlz TYPE pstlz,
        ort02 TYPE ort02_gp,
        land1 TYPE land1_gp,
        regio TYPE regio,
        akont TYPE akont,
        fdgrv TYPE fdgrv,
        waers TYPE waers,
       END OF ty_xk01,

       BEGIN OF ty_bank,
        lifnr TYPE lifnr,
        banks TYPE banks,
        bankl TYPE bankk,
        bankn TYPE bankn,
        koinh TYPE koinh_fi,
        banka TYPE banka,
       END OF ty_bank,

       BEGIN OF ty_error,
        record TYPE i,
        status TYPE string,
       END OF ty_error.

DATA: ls_xk01 TYPE ty_xk01,
      lt_xk01 TYPE TABLE OF ty_xk01,
      ls_bank TYPE ty_bank,
      lt_bank TYPE TABLE OF ty_bank,
      ls_bdc TYPE bdcdata,
      lt_bdc TYPE TABLE OF bdcdata,
      ls_msg TYPE bdcmsgcoll,
      lt_msg TYPE TABLE OF bdcmsgcoll,
      lt_raw TYPE truxs_t_text_data,
      lt_raw_1 TYPE truxs_t_text_data,
      ls_error TYPE ty_error,
      lt_error TYPE TABLE OF ty_error,
      s_fcat TYPE slis_fieldcat_alv,
      t_fcat TYPE slis_t_fieldcat_alv.

********************************************
*INCLUDE ZABAP_BDC_UPLOAD_CUS_MAST_DATA_SEL.
********************************************
SELECTION-SCREEN:BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
  PARAMETERS: pv_file TYPE rlgrap-filename OBLIGATORY, "Upload Vendor File
              pb_file TYPE rlgrap-filename OBLIGATORY. "Upload Bank File
SELECTION-SCREEN:END OF BLOCK b1.

********************************************
*INCLUDE ZABAP_BDC_UPLOAD_CUS_MAST_DATA_F01.
********************************************
********************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pv_file.
  PERFORM open_ven_file.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pb_file.
  PERFORM open_bank_file.

START-OF-SELECTION.
  PERFORM upload_file.
  PERFORM process_data.
  PERFORM process_error.

END-OF-SELECTION.
  PERFORM display_error.
*&---------------------------------------------------------------------*
*& Form OPEN_VEN_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_ven_file .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = pv_file.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading Vendor file' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_BANK_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_bank_file .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = pb_file.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading Bank file' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_file .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header = ' '
      i_tab_raw_data = lt_raw
      i_filename = pv_file
    TABLES
      i_tab_converted_data = lt_xk01.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading vendor file' TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header = ' '
      i_tab_raw_data = lt_raw_1
      i_filename = pb_file
    TABLES
      i_tab_converted_data = lt_bank.

  IF sy-subrc <> 0.
    MESSAGE 'Error while uploading bank file' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
DATA: v_banks TYPE char20,
      v_bankl TYPE char20,
      v_bankn TYPE char20,
      v_koinh TYPE char20,
      v_banka TYPE char20,
      v_count TYPE numc2.

  LOOP AT lt_xk01 INTO ls_xk01.
    REFRESH lt_bdc.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0100'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'RF02K-KTOKK'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_field USING 'RF02K-LIFNR' ls_xk01-lifnr.
    PERFORM bdc_field USING 'RF02K-BUKRS' ls_xk01-bukrs.
    PERFORM bdc_field USING 'RF02K-EKORG' ls_xk01-ekorg.
    PERFORM bdc_field USING 'RF02K-KTOKK' ls_xk01-ktokk.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0110'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFA1-REGIO'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_field USING 'LFA1-ANRED' ls_xk01-anred.
    PERFORM bdc_field USING 'LFA1-NAME1' ls_xk01-name1.
    PERFORM bdc_field USING 'LFA1-SORTL' ls_xk01-sortl.
    PERFORM bdc_field USING 'LFA1-STRAS' ls_xk01-stras.
    PERFORM bdc_field USING 'LFA1-PFACH' ''.
    PERFORM bdc_field USING 'LFA1-ORT01' ls_xk01-ort01.
    PERFORM bdc_field USING 'LFA1-PSTLZ' ls_xk01-pstlz.
    PERFORM bdc_field USING 'LFA1-ORT02' ls_xk01-ort02.
    PERFORM bdc_field USING 'LFA1-LAND1' ls_xk01-land1.
    PERFORM bdc_field USING 'LFA1-REGIO' ls_xk01-regio.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0120'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFA1-KUNNR'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0130'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFBK-KOINH(01)'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=ENTR'.

    CLEAR v_count.

    LOOP AT lt_bank INTO ls_bank WHERE lifnr = ls_xk01-lifnr.
      v_count = v_count + 1.
      CLEAR: v_banks, v_bankl, v_bankn, v_banka, v_koinh.
      CONCATENATE 'LFBK-BANKS('v_count')' INTO v_banks.
      CONCATENATE 'LFBK-BANKL('v_count')' INTO v_bankl.
      CONCATENATE 'LFBK-BANKN('v_count')' INTO v_bankn.
      CONCATENATE 'LFBK-KOINH('v_count')' INTO v_koinh.

      PERFORM bdc_field USING v_banks ls_bank-banks.
      PERFORM bdc_field USING v_bankl ls_bank-bankl.
      PERFORM bdc_field USING v_bankn ls_bank-bankn.
      PERFORM bdc_field USING v_koinh ls_bank-koinh.
    ENDLOOP.

    PERFORM bdc_dynpro USING 'SAPMF02K' '0130'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFBK-BANKS(01)'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=ENTR'.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0380'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'KNVK-NAMEV(01)'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=ENTR'.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0210'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFB1-FDGRV'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_field USING 'LFB1-AKONT' ls_xk01-akont.
    PERFORM bdc_field USING 'LFB1-FDGRV' ls_xk01-fdgrv.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0215'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFB1-ZTERM'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0220'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFB5-MAHNA'.
    PERFORM bdc_field USING 'BDC_OKCODE' '/00'.
    PERFORM bdc_dynpro USING 'SAPMF02K' '0310'.
    PERFORM bdc_field USING 'BDC_CURSOR' 'LFM1-WAERS'.
    PERFORM bdc_field USING 'BDC_OKCODE' '=UPDA'.
    PERFORM bdc_field USING 'LFM1-WAERS' ls_xk01-waers.

    CALL TRANSACTION 'XK01' USING lt_bdc MODE 'A' UPDATE 'A' MESSAGES INTO lt_msg.
    IF sy-subrc NE 0.
      MESSAGE 'Error while processing the data' TYPE 'E'.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_error .
DATA: v_text TYPE string,
      count TYPE i.

  LOOP AT lt_msg INTO ls_msg.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id = sy-msgid
        lang = '-D'
        no = ls_msg-msgnr
        v1 = ls_msg-msgv1
        v2 = ls_msg-msgv2
        v3 = ls_msg-msgv3
        v4 = ls_msg-msgv4
      IMPORTING
        msg = v_text.

    count = count + 1.
    ls_error-record = count.
    ls_error-status = v_text.
    APPEND ls_error TO lt_error.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ERROR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_error .
  CLEAR s_fcat.
  s_fcat-fieldname = 'RECORD'.
  s_fcat-tabname = 'LT_ERROR'.
  s_fcat-seltext_m = 'Ser.No.'.
  s_fcat-outputlen = 7.
  APPEND s_fcat TO t_fcat.

  CLEAR s_fcat.
  s_fcat-fieldname = 'STATUS'.
  s_fcat-tabname = 'LT_ERROR'.
  s_fcat-seltext_m = 'Message - Long Text'.
  s_fcat-outputlen = 50.
  APPEND s_fcat TO t_fcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-cprog
      it_fieldcat = t_fcat
    TABLES
      t_outtab = lt_error.
ENDFORM.
*&---------------------------------------------------------------------*
*&FormBDC_DYNPRO
*&---------------------------------------------------------------------*
*text
*----------------------------------------------------------------------*
*-->P_0061text
*-->P_0062text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING VALUE(p_0061) VALUE(p_0062).
  CLEAR ls_bdc.
  ls_bdc-program = p_0061.
  ls_bdc-dynpro = p_0062.
  ls_bdc-dynbegin = abap_true.
  APPEND ls_bdc TO lt_bdc.
ENDFORM." BDC_DYNPRO
*&-----------------------------------------------*
*&FormBDC_FIELD
*&-----------------------------------------------*
* text
*----------------------------------------------------*
*-->P_0066text
*-->P_0067text
*---------------------------------------------------*
FORM bdc_field USING VALUE(p_0066) VALUE(p_0067).
  CLEAR ls_bdc.
  ls_bdc-fnam = p_0066.
  ls_bdc-fval = p_0067.
  APPEND ls_bdc TO lt_bdc.
ENDFORM." BDC_FIELD