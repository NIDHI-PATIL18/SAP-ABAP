*&----;-----------------------------------------------------------------*
*& Report ZPRG_INTERACTIVE_REPORT_GET_M
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_interactive_report_at_uc.

TYPES : BEGIN OF ty_orderh,
          ono   TYPE zdeono_07,
          odate TYPE zdeodate_07,
          pm    TYPE zdepm_07,
*          ta    TYPE zdeta_07,
          curr  TYPE zdecurr_07,
        END OF ty_orderh.

DATA : it_orderh    TYPE TABLE OF ty_orderh,
       wa_orderh    TYPE ty_orderh,
       lv_ono       TYPE zdeono_07,
       lv_field(30) TYPE c,
       lv_value(30) TYPE c.

SELECT-OPTIONS : s_ono for lv_ono.

START-OF-SELECTION.

select ono
  odate
  pm
  curr
  from ZORDER_HEADER_C
  into table it_orderh
  where ono in s_ono.

  LOOP AT it_orderh into wa_orderh.
    write : / wa_orderh-ono , wa_orderh-odate , wa_orderh-pm , wa_orderh-curr.
  ENDLOOP.
  
  * create our own function
  *to create our on GUI status for the output string this syntax is used.
  SET PF-STATUS 'FUNCTION'.  "stri ng are case sensitive.

  AT USER-COMMAND.

  IF  sy-ucomm = 'ASCENDING'.
    SORT it_orderh BY ono.
    LOOP AT it_orderh INTO wa_orderh.
      WRITE : / wa_orderh-ono , wa_orderh-odate , wa_orderh-pm , wa_orderh-curr.
    ENDLOOP.
  ENDIF.

  IF  sy-ucomm = 'DECENDING'.
    SORT it_orderh BY ono DESCENDING.
    LOOP AT it_orderh INTO wa_orderh.
      WRITE : / wa_orderh-ono , wa_orderh-odate , wa_orderh-pm , wa_orderh-curr.
    ENDLOOP.
  ENDIF.