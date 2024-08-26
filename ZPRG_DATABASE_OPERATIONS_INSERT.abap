*&---------------------------------------------------------------------*
*& Report ZPRG_DATABASE_OPERATIONS_INS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_database_operations_ins.

TYPES : BEGIN OF ty_data,
          mandt TYPE mandt,
          ono   TYPE zdeono_07,
          odate TYPE zdeodate_07,
          pm    TYPE zdepm_07,
          ta    TYPE zdeta_07,
          curr  TYPE zdecurr_07,
        END OF ty_data.

*DATA : wa_data TYPE zorder_header_c.
DATA : it_data TYPE TABLE OF ty_data,
       wa_data TYPE ty_data.

PARAMETERS : p_ono   TYPE zdeono_07 OBLIGATORY.
PARAMETERS : p_odate TYPE zdeodate_07.
PARAMETERS : p_pm    TYPE zdepm_07.
PARAMETERS : p_ta    TYPE zdeta_07.
PARAMETERS : p_curr  TYPE zdecurr_07.
PARAMETERS : p_r1 TYPE c RADIOBUTTON GROUP r1.               "insert
PARAMETERS : p_r2 TYPE c RADIOBUTTON GROUP r1.               "Update
PARAMETERS : p_r3 TYPE c RADIOBUTTON GROUP r1.               "Delete
PARAMETERS : p_r4 TYPE c RADIOBUTTON GROUP r1 DEFAULT 'X'.   "Modify

START-OF-SELECTION.

*insert logic.
  IF p_r1 = 'X'.
    wa_data-ono = p_ono.
    wa_data-odate = p_odate.
    wa_data-pm = p_pm.
    wa_data-ta = p_ta.
    wa_data-curr = p_curr.
    INSERT zorder_header_c FROM wa_data.
    IF sy-subrc = 0.
      WRITE : TEXT-000.
    ELSE.
      WRITE : TEXT-001.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN.

  IF p_r1 = 'X'.
    SELECT ono
    FROM zorder_header_c
    INTO TABLE it_data
     WHERE ono = p_ono.

*to get a single order no.
*    SELECT SINGLE ono
*      FROM zorder_header_c
*      INTO wa_data
*      WHERE ono = p_ono.

    IF sy-subrc = 0.
      MESSAGE e000(zmsg_nid) WITH p_ono.
    ENDIF.
  ENDIF.