*&---------------------------------------------------------------------*
*& Report  ZNESTED_LOOPING
*&
*&---------------------------------------------------------------------*
* PROGRAM DETAILS
* Program Name     : ZNESTED_LOOPING
* Title            : ABAP Nested Looping
*&---------------------------------------------------------------------*

REPORT znested_looping.


DATA:
  gt_bkpf TYPE STANDARD TABLE OF bkpf,
  gt_bseg TYPE STANDARD TABLE OF bseg.

FIELD-SYMBOLS:
  <gs_bkpf> TYPE bkpf,
  <gs_bseg> TYPE bseg.


SELECT * UP TO 500 ROWS
  FROM bkpf
  INTO TABLE gt_bkpf.
IF sy-subrc <> 0.
  RETURN.
ENDIF.

SELECT *
  FROM bseg
  INTO TABLE gt_bseg
  FOR ALL ENTRIES IN gt_bkpf
  WHERE bukrs = gt_bkpf-bukrs
    AND belnr = gt_bkpf-belnr
    AND gjahr = gt_bkpf-gjahr.

LOOP AT gt_bkpf ASSIGNING <gs_bkpf>.
  READ TABLE gt_bseg TRANSPORTING NO FIELDS
       WITH KEY bukrs = <gs_bkpf>-bukrs
                belnr = <gs_bkpf>-belnr
                gjahr = <gs_bkpf>-gjahr
       BINARY SEARCH.
  CHECK sy-subrc = 0.

  LOOP AT gt_bseg ASSIGNING <gs_bseg> FROM sy-tabix.
    IF <gs_bkpf>-bukrs <> <gs_bseg>-bukrs
       OR <gs_bkpf>-belnr <> <gs_bseg>-belnr
       OR <gs_bkpf>-gjahr <> <gs_bseg>-gjahr.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDLOOP.