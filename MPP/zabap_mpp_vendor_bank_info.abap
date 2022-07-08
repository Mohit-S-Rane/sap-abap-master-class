*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_VENDOR_BANK_INFO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_VENDOR_BANK_INFO
* Title            : ABAP MPP Vendor Bank Information Display
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_vendor_bank_info NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_VENDOR_BANK_INFO_TOP.
*************************************
TABLES: lfa1,lfbk.

DATA: BEGIN OF wa_lfbk,
        banks TYPE banks,
        bankn TYPE bankn,
        koinh TYPE koinh_fi,
      END OF wa_lfbk.
*************************************


CALL SCREEN 1000.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  MOVE: wa_lfbk-banks TO lfbk-banks,
        wa_lfbk-bankn TO lfbk-bankn,
        wa_lfbk-koinh TO lfbk-koinh.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'DISPLAY'.
      SELECT SINGLE
        banks
        bankn
        koinh
        FROM lfbk INTO wa_lfbk
        WHERE lifnr EQ lfa1-lifnr.

    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.