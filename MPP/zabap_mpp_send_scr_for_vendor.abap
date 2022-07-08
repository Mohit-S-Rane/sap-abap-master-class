*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_SEND_SCR_FOR_VENDOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_SEND_SCR_FOR_VENDOR
* Title            : ABAP MPP Send Screen for Vendor
* Description      : Example for field level validation as well as mail sending screen for vendor.
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_send_scr_for_vendor NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_SEND_SCR_FOR_VENDOR_TOP.
*********************************************************
TABLES kna1.

DATA: BEGIN OF ls_kna1,
       kunnr TYPE kunnr,
       land1 TYPE land1_gp,
       name1 TYPE name1_gp,
       ort01 TYPE ort01_gp,
       pstlz TYPE pstlz,
       stras TYPE stras_gp,
      END OF ls_kna1.

DATA: ls_text TYPE sodocchgi1,
      lt_receiver TYPE STANDARD TABLE OF somlrec90 WITH HEADER LINE,
      lt_message TYPE STANDARD TABLE OF solisti1 WITH HEADER LINE,
      lv_message TYPE string.
***********************************************************
  CALL SCREEN 5011.
*&---------------------------------------------------------------------*
*& Module STATUS_5011 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_5011 OUTPUT.
  SET PF-STATUS 'ZYGUI'.
  SET TITLEBAR 'ZYMAIL_SEND'.
  MOVE: ls_kna1-land1 TO kna1-land1,
        ls_kna1-name1 TO kna1-name1,
        ls_kna1-ort01 TO kna1-ort01,
        ls_kna1-pstlz TO kna1-pstlz,
        ls_kna1-stras TO kna1-stras.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_5011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_5011 INPUT.
CASE sy-ucomm.
  WHEN 'DISPLAY'.
    SELECT SINGLE
      kunnr
      land1
      name1
      ort01
      pstlz
      stras
      FROM kna1 INTO ls_kna1
      WHERE kunnr EQ kna1-kunnr.

  WHEN 'MAIL'.
    ls_text-obj_name = 'TEXT'.
    ls_text-obj_descr = 'Customer Details'.
    ls_text-obj_langu = sy-langu.
    lt_receiver-receiver = 'ADMIN@GMAIL.COM'.
    lt_receiver-rec_type = 'U'.
    APPEND lt_receiver.

    CONCATENATE '1.) Customer Country' ls_kna1-land1 INTO lv_message SEPARATED BY ' '.
    APPEND lv_message TO lt_message.

    CONCATENATE '2.) Customer Name' ls_kna1-name1 INTO lv_message SEPARATED BY ' '.
    APPEND lv_message TO lt_message.

    CONCATENATE '3.) Customer City' ls_kna1-ort01 INTO lv_message SEPARATED BY ' '.
    APPEND lv_message TO lt_message.

    CONCATENATE '4.) Customer Postal' ls_kna1-pstlz INTO lv_message SEPARATED BY ' '.
    APPEND lv_message TO lt_message.

    CONCATENATE '5.) Customer Street' ls_kna1-stras INTO lv_message SEPARATED BY ' '.
    APPEND lv_message TO lt_message.

    CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
      EXPORTING
        document_data = ls_text
*       COMMIT_WORK = ' '
      TABLES
        object_content = lt_message
        receivers = lt_receiver.

    IF sy-subrc EQ 0.
      COMMIT WORK.
      SUBMIT rsconn01 WITH mode = 'INT' AND RETURN.
    ENDIF.

  WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
    LEAVE PROGRAM.

ENDCASE.
ENDMODULE.