*&---------------------------------------------------------------------*
*& Report ZPRG_CONTROL_BREAK_STATEMENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_control_break_sta_test1.

TYPES :BEGIN OF ty_data,
         ono TYPE zdeono_07,
         pm  TYPE zdepm_07,
         ta  TYPE zdeta_07,
       END OF ty_data.

TYPES :BEGIN OF ty_data1,
         pm  TYPE zdepm_07,
         ono TYPE zdeono_07,
         ta  TYPE zdeta_07,
       END OF ty_data1.

DATA : lv_pm    TYPE zdepm_07,
       it_data  TYPE TABLE OF ty_data,
       wa_data  TYPE ty_data,
       it_data1 TYPE TABLE OF ty_data1,
       wa_data1 TYPE ty_data1.

SELECT-OPTIONS : s_pm FOR lv_pm NO INTERVALS.

SELECT ono pm ta
  FROM zorder_header_c
  INTO TABLE it_data
  WHERE pm IN s_pm.

LOOP AT it_data INTO wa_data.
  wa_data1-pm = wa_data-pm.
  wa_data1-ono = wa_data-ono.
  wa_data1-ta = wa_data-ta.
  APPEND wa_data1 TO it_data1.
  CLEAR : wa_data1.
ENDLOOP.

SORT it_data1 BY pm.

LOOP AT it_data1 INTO wa_data1.
*    write :/ wa_data-pm , wa_data-ta.
  AT FIRST.
    WRITE : / TEXT-000.
  ENDAT.

  AT NEW pm.                               "triggers for the first record of the group having the same value of the field name.
    WRITE : / wa_data-pm.
  ENDAT.

  AT END OF pm.
    SUM.
    WRITE :      wa_data1-ta.
  ENDAT.

  AT LAST.
    WRITE : / TEXT-001.
  ENDAT.

ENDLOOP.