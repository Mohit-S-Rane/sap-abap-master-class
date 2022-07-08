*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_VENDOR_INFO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_VENDOR_INFO
* Title            : ABAP MPP Vendor Information
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_vendor_info NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_VENDOR_INFO_TOP.
*************************************
TABLES: lfa1.

DATA: BEGIN OF wa_lfa1,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
        ort01 TYPE ort01_gp,
        pstlz TYPE pstlz,
        stras TYPE stras_gp,
      END OF wa_lfa1.

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

  MOVE: wa_lfa1-name1 TO lfa1-name1,
        wa_lfa1-ort01 TO lfa1-ort01,
        wa_lfa1-pstlz TO lfa1-pstlz,
        wa_lfa1-stras TO lfa1-stras.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'DIS21'.
      SELECT SINGLE
        lifnr
        name1
        ort01
        pstlz
        stras
        FROM lfa1 INTO wa_lfa1
        WHERE lifnr EQ lfa1-lifnr.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.