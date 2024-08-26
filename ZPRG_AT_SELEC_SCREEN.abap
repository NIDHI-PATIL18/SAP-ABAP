*&---------------------------------------------------------------------*
*& Report ZPRG_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPRG_SELECTION_SCREEN.

DATA : lv_or_num type ZDATAELEMENT_1.

SELECT-OPTIONS : s_or_num For lv_or_num DEFAULT 1 to 10 OBLIGATORY NO-EXTENSION.
"lv-local variable
"No-extension is used to hide the multiple selection button.
"NO-intervals is used to hide the high value range box.

PARAMETERS : p_or_num type ZDATAELEMENT_1."OBLIGATORY. "Default 1.
PARAMETERS : p_r1 type c RADIOBUTTON GROUP R1.
PARAMETERS : p_r2 type c RADIOBUTTON GROUP R1 DEFAULT 'X'.
PARAMETERS : p_r3 type c RADIOBUTTON GROUP R1.
PARAMETERS : p_check1 AS CHECKBOX.
PARAMETERS : p_check2 AS CHECKBOX.

WRITE : 1.