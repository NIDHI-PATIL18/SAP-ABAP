*&---------------------------------------------------------------------*
*& Report ZPRG_DATABASE_OPERATIONS_INS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_database_operations_mod.

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
PARAMETERS : p_odate TYPE zdeodate_07 MODIF ID a1.
PARAMETERS : p_pm    TYPE zdepm_07 MODIF ID a2.
PARAMETERS : p_ta    TYPE zdeta_07 MODIF ID a3.
PARAMETERS : p_curr  TYPE zdecurr_07 MODIF ID a4.
PARAMETERS : p_r1 TYPE c RADIOBUTTON GROUP r1 USER-COMMAND abc.               "insert/ function code should always be assigned to the first parameter of the group.
PARAMETERS : p_r2 TYPE c RADIOBUTTON GROUP r1.                                "Update
PARAMETERS : p_r3 TYPE c RADIOBUTTON GROUP r1.                                "Delete
PARAMETERS : p_r4 TYPE c RADIOBUTTON GROUP r1 DEFAULT 'X'.                    "Modify

START-OF-SELECTION.

*Insert.
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

*if input is correct then only it goes to the start of selection event.

*Delete.
  IF p_r3 = 'X'.
    wa_data-ono = p_ono.
    DELETE zorder_header_c FROM wa_data.
    IF sy-subrc = 0.
      WRITE: TEXT-002,':', p_ono.
    ENDIF.
  ENDIF.

*Update.
  IF p_r2 = 'X'.
    wa_data-ono = p_ono.
    wa_data-odate = p_odate.
    wa_data-pm = p_pm.
    wa_data-ta = p_ta.
    wa_data-curr = p_curr.
    UPDATE zorder_header_c FROM wa_data.
    IF sy-subrc = 0.
      WRITE : TEXT-003,':', p_ono.
    ENDIF.
  ENDIF.

*Modify.
  IF p_r4 = 'X'.
    wa_data-ono = p_ono.
    wa_data-odate = p_odate.
    wa_data-pm = p_pm.
    wa_data-ta = p_ta.
    wa_data-curr = p_curr.
    MODIFY zorder_header_c FROM wa_data.
    IF sy-subrc = 0.
      WRITE : TEXT-004,':', p_ono.
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


*for the Delete Operation.
  IF p_r3 = 'X'.
    SELECT SINGLE ono
      FROM zorder_header_c
      INTO wa_data
      WHERE ono = p_ono.
    IF sy-subrc <> 0.
      MESSAGE e001(zmsg_nid) WITH p_ono.
    ENDIF.
  ENDIF.

  IF p_r2 = 'X'.
    SELECT SINGLE ono
      FROM zorder_header_c
      INTO wa_data
      WHERE ono = p_ono.
    IF sy-subrc <> 0.
      MESSAGE e002(zmsg_nid) WITH p_ono.
    ELSE.
      SELECT SINGLE mandt ono odate pm ta curr
      FROM zorder_header_c
      INTO wa_data
      WHERE ono = p_ono.
    ENDIF.
  ENDIF.

  IF p_r4 = 'X'.
    SELECT SINGLE mandt ono odate pm ta curr
        FROM zorder_header_c
        INTO wa_data
        WHERE ono = p_ono.
    IF sy-subrc <> 0.
      CLEAR : wa_data.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF p_r3 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'A1' OR
      screen-group1 = 'A2' OR
      screen-group1 = 'A3' OR
      screen-group1 = 'A4' .
        Screen-active = 0.       "to make all the other field/parameters expect order no. inactive.
*        screen-input = 0.         "to make all the other parameters disabled.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_r2 = 'X'.
    p_odate = wa_data-odate.
    p_pm = wa_data-pm.
    p_ta = wa_data-ta.
    p_curr = wa_data-curr.
  ENDIF.

  IF p_r4 = 'X'.
    p_odate = wa_data-odate.
    p_pm = wa_data-pm.
    p_ta = wa_data-ta.
    p_curr = wa_data-curr.
  ENDIF.