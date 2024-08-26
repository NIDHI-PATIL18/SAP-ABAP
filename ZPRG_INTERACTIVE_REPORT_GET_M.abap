*&----;-----------------------------------------------------------------*
*& Report ZPRG_INTERACTIVE_REPORT_GET_M
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_interactive_report_get_m.

TYPES : BEGIN OF ty_ZORDER_HEADER_C,
          ono   TYPE zdeono_07,
          odate TYPE zdeodate_07,
          pm    TYPE zdepm_07,
          ta    TYPE zdeta_07,
          curr  TYPE zdecurr_07,
        END OF ty_zorder_header_c.

DATA : it_orderh    TYPE TABLE OF ty_ZORDER_HEADER_C,
       wa_orderh    TYPE ty_ZORDER_HEADER_C,
       lv_ono       TYPE zdeono_07,
       lv_field(30) TYPE c,
       lv_value(30) TYPE c.

SELECT-OPTIONS : s_ono FOR lv_ono.

START-OF-SELECTION.

  SELECT ono
    odate
    pm
    ta
    curr
   FROM zorder_header_c
    INTO TABLE it_orderh
    WHERE ono IN s_ono.


  LOOP AT it_orderh INTO wa_orderh.
    WRITE : / wa_orderh-ono , wa_orderh-odate , wa_orderh-pm , wa_orderh-ta , wa_orderh-curr.
  ENDLOOP.

AT LINE-SELECTION.

  GET CURSOR FIELD lv_field VALUE lv_value.

  IF lv_field = 'wa_orderh-ono'.
    WRITE : TEXT-007.
  ENDIF.