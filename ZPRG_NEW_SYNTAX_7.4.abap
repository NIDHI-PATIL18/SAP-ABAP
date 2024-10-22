*&---------------------------------------------------------------------*
*& Report ZPRG1_NEW_SYNTAX
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPRG1_NEW_SYNTAX.
*----------------------------------------------------------------------*
"INLINE Declaration
*----------------------------------------------------------------------*

*DATA: lv_input1(2) TYPE N.   " Old way to declare the data
*DATA: lv_input2(2) TYPE N.   " Old way to declare the data
*DATA: lv_input3(2) TYPE N.   " Old way to declare the data

*Data(lv_input1) = 10.
*DATA(lv_input2) = 20.
*DATA(lv_output) = lv_input1 + lv_input2.

*Write: lv_output.

*----------------------------------------------------------------------*
"COND( IF ) statement
*----------------------------------------------------------------------*
TYPES: BEGIN of lty_data,
      VBELN TYPE vbeln_va,
      netwr TYPE netwr_ak,
      END of lty_data.

DATA: lt_data TYPE TABLE OF lty_data.
DATA: ls_data TYPE lty_data.
DATA: lv_vbeln type vbeln_va.
*DATA: lv_text TYPE char20.

SELECT-OPTIONS : s_vbeln for lv_vbeln.

SELECT vbeln netwr
from vbak
into table lt_data
where vbeln in s_vbeln.

*LOOP at lt_data into ls_data.
*    IF ls_data-netwr GE 0 AND ls_dta LE 500.
*    lv_text = 'Low Priority'.
*ElseIF.
*    ls_data-netwr > 50000 AND ls_data-netwr LE 10000.
*    lv_text = 'medium priority'.
*else.
*    lv_text = 'High Priority'.
*ENDIF.
*write: / ls_data-vbeln, lv_text.
*    ENDLOOP.

LOOP AT lty_data into ls_data.
    DATA(lv_text) = COND char20( WHEN ls_data-netwr GE 0 AND ls_data-netwr LE 5000 THEN TEXT-000
                           WHEN ls_data-netwr > 5000 AND ls_data-netwr LE 10000 THEN TEXT-001
                           ELSE TEXT-002 ).
    write: / ls_data-vbeln, lv_text.
ENDLOOP.