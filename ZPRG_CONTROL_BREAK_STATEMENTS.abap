*&---------------------------------------------------------------------*
*& Report ZPRG_CONTROL_BREAK_STATEMENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_control_break_statements.

TYPES :BEGIN OF ty_data,
         pm TYPE zdepm_07,
         ta TYPE zdeta_07,
       END OF ty_data.

DATA : lv_pm   TYPE zdepm_07,
       it_data TYPE TABLE OF ty_data,
       wa_data TYPE ty_data.

SELECT-OPTIONS : s_pm FOR lv_pm NO INTERVALS.

SELECT pm ta
  FROM zorder_header_c
  INTO TABLE it_data
  WHERE pm IN s_pm.


SORT it_data BY pm.

LOOP AT it_data INTO wa_data.
*    write :/ wa_data-pm , wa_data-ta.
  AT FIRST.
    WRITE : / TEXT-000.
  ENDAT.

  AT NEW pm.                               "triggers for the first record of the group having the same value of the field name.
    WRITE : / wa_data-pm.
  ENDAT.

  AT END OF pm.
    SUM.
    WRITE : wa_data-ta.
  ENDAT.

  AT LAST.
    WRITE : / TEXT-001.
  ENDAT.

ENDLOOP.