*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_SALES_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_SALES_ORDER_DETAILS
* Title            : ABAP MPP Sales Order Details based on Customer
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_sales_order_details NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_SALES_ORDER_DETAILS_TOP.
*************************************
TABLES: kna1,vbak.
TYPES: BEGIN OF ty_vbak,
        vbeln TYPE vbeln_va,
        erdat TYPE erdat,
        auart TYPE auart,
        netwr TYPE netwr_ak,
        vkorg TYPE vkorg,
       END OF ty_vbak.

DATA: ls_vbak TYPE ty_vbak,
      lt_vbak TYPE TABLE OF ty_vbak.
*************************************

CONTROLS swan TYPE TABLEVIEW USING SCREEN 1000.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  MOVE: ls_vbak-vbeln TO vbak-vbeln,
        ls_vbak-erdat TO vbak-erdat,
        ls_vbak-auart TO vbak-auart,
        ls_vbak-netwr TO vbak-netwr,
        ls_vbak-vkorg TO vbak-vkorg.

  swan-lines = sy-dbcnt.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
      WHEN 'DISPLAY'.
        SELECT
          vbeln
          erdat
          auart
          netwr
          vkorg
          FROM vbak INTO TABLE lt_vbak
          WHERE kunnr EQ kna1-kunnr.

      WHEN 'EXIT'.
        LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
