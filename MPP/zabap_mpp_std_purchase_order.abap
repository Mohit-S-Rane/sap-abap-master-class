*&---------------------------------------------------------------------*
*& Report ZABAP_MPP_STD_PURCHASE_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZABAP_MPP_STD_PURCHASE_ORDER
* Title            : ABAP MPP Standard Purchase Order based on vendor
* Description      : Display Standard Purchase Order based on vendor in 1st tab and based on standard purchase order display the item for which delivery completed (delivered) in 2nd tab.
* Original Author  : Mohit Rane
*&---------------------------------------------------------------------*
REPORT zabap_mpp_std_purchase_order NO STANDARD PAGE HEADING.

*INCLUDE ZABAP_MPP_STD_PURCHASE_ORDER_TOP.
*********************************************************
TABLES: lfa1,ekko,ekpo.

TYPES: BEGIN OF ty_ekko,
        ebeln TYPE ebeln,
        bukrs TYPE bukrs,
        aedat TYPE erdat,
        zterm TYPE dzterm,
        ekgrp TYPE ekgrp,
       END OF ty_ekko,

       BEGIN OF ty_ekpo,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        menge TYPE bstmg,
        meins TYPE bstme,
        netpr TYPE bprei,
       END OF ty_ekpo.

DATA: ls_ekko TYPE ty_ekko,
      ls_ekpo TYPE ty_ekpo,
      lt_ekko TYPE TABLE OF ty_ekko,
      lt_ekpo TYPE TABLE OF ty_ekpo.

CONTROLS: dell TYPE TABLEVIEW USING SCREEN 21,
          emc TYPE TABLEVIEW USING SCREEN 22,
          swan TYPE TABSTRIP.
***********************************************************

CALL SCREEN 1000.
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

MOVE: ls_ekko-ebeln TO ekko-ebeln,
      ls_ekko-bukrs TO ekko-bukrs,
      ls_ekko-aedat TO ekko-aedat,
      ls_ekko-zterm TO ekko-zterm,
      ls_ekko-ekgrp TO ekko-ekgrp.

dell-lines = sy-dbcnt.
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
        ebeln
        bukrs
        aedat
        FROM ekko INTO TABLE lt_ekko
        WHERE lifnr EQ lfa1-lifnr AND
              bsart EQ 'NB'.

      IF lt_ekko[] IS NOT INITIAL.
        SELECT
          ebelp
          matnr
          menge
          meins
          netpr
          FROM ekpo INTO TABLE lt_ekpo
          FOR ALL ENTRIES IN lt_ekko
          WHERE ebeln = lt_ekko-ebeln AND
                elikz = 'X'.
      ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.