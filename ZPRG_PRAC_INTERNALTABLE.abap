*&---------------------------------------------------------------------*
*& Report ZPRG_PRAC_INTERNALTABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_prac_internaltable.

*TYPES : BEGIN OF ty_order,
*          or_num     TYPE zdataelement_1,
*          order_date TYPE zdataelement_2,
*          pay_mod    TYPE zdataelement_3,
**          tot_amo    TYPE zdataelement_4,
**          curr       TYPE zdataelement_5,
*        END OF ty_order.
*
*DATA : it_order TYPE TABLE OF ty_order.
*DATA : wa_order TYPE ty_order.
*DATA : ln_output type I.
*
*wa_order-or_num = 4.      "values passes from right to left in sap
*wa_order-order_date = '05102023'.
*wa_order-pay_mod = 'C'.
**wa_order-tot_amo = '2000'.
**wa_order-curr = '$'.
*APPEND wa_order TO it_order.
*CLEAR : wa_order.
*
*wa_order-or_num = 1.
*wa_order-order_date = '04102023'.
*wa_order-pay_mod = 'D'.
**wa_order-tot_amo = '2000'.
**wa_order-curr = '$'.
*APPEND wa_order TO it_order.
*CLEAR : wa_order.
*
*wa_order-or_num = 3.
*wa_order-order_date = '04102023'.
*wa_order-pay_mod = 'C'.
**wa_order-tot_amo = '2000'.
**wa_order-curr = '$'.
*APPEND wa_order TO it_order.
*CLEAR : wa_order.
*
*wa_order-or_num = 2.
*wa_order-order_date = '05102023'.
*wa_order-pay_mod = 'D'.
**wa_order-tot_amo = '2000'.
**wa_order-curr = '$'.
*APPEND wa_order TO it_order.
*CLEAR : wa_order.

*******************************************************************
*DELETE it_order where pay_mod = 'D'.
*DELETE it_order INDEX 3.   "it deletes the data with reference with the index no.(the row no.).
*******************************************************************

*******************************************************************
*LOOP AT it_order INTO wa_order.
*  IF wa_order-or_num = 1.
*    wa_order-pay_mod = 'N'.
*    MODIFY it_order FROM wa_order TRANSPORTING pay_mod.  "particular column data can be updtated or modified
*  ENDIF.
*ENDLOOP.
*******************************************************************

*******************************************************************
*LOOP AT it_order INTO wa_order.
*  WRITE : / wa_order-or_num , wa_order-order_date , wa_order-pay_mod , wa_order-tot_amo.
*ENDLOOP.
*******************************************************************

*******************************************************************
*READ TABLE it_order INTO wa_order WITH KEY or_num = 4.
*IF sy-subrc = 0.       "system variable.
*  WRITE : / wa_order-or_num ,wa_order-order_date ,wa_order-pay_mod.
*ELSE.
*  WRITE : 'Unsuccessful'.
*ENDIF.

"read table based on index.

*READ TABLE it_order INTO wa_order INDEX 3.
*IF sy-subrc = 0.
*  WRITE : / wa_order-or_num , wa_order-order_date ,wa_order-pay_mod.
*ENDIF.
*******************************************************************

*CLEAR : it_order. "both the ways have same output.
*REFRESH : it_order.

*******************************************************************

"Describe Table
*DESCRIBE TABLE it_order LINES ln_output.
*WRITE : / ln_output.
*
*CLEAR : it_order.
*
*DESCRIBE TABLE it_order LINES ln_output.
*WRITE : / ln_output.

*******************************************************************

"sort
*SORT it_order by or_num. "default it is sorted in accending order if we need the output in decending order the "DESENDING" key word should be used.
*
*LOOP AT it_order INTO wa_order.
*  WRITE : / wa_order-or_num , wa_order-order_date , wa_order-pay_mod.
*ENDLOOP.

*
*SORT it_order by or_num pay_mod DESCENDING. "here the order no will be sorted in accending order and payment mode will be sorted on decending order.
*LOOP AT it_order INTO wa_order.
*  WRITE : / wa_order-or_num , wa_order-order_date , wa_order-pay_mod.
*ENDLOOP.
*******************************************************************

TYPES : BEGIN OF ty_data,
          comp_name(3) TYPE c,
          dept(10)     TYPE c,
          amount       TYPE zdataelement_4,
        END OF ty_data.

DATA : it_data TYPE TABLE OF ty_data.
DATA : wa_data TYPE ty_data.
DATA : it_final type TABLE OF ty_data.

wa_data-comp_name = 'ABC'.
wa_data-dept = 'ADMIN'.
wa_data-amount = '10000.00'.
APPEND wa_data TO it_data.
CLEAR : wa_data.

wa_data-comp_name = 'ABC'.
wa_data-dept = 'HR'.
wa_data-amount = '20000.00'.
APPEND wa_data TO it_data.
CLEAR : wa_data.

wa_data-comp_name = 'ABC'.
wa_data-dept = 'ADMIN'.
wa_data-amount = '50000.00'.
APPEND wa_data TO it_data.
CLEAR : wa_data.

wa_data-comp_name = 'ABC'.
wa_data-dept = 'Training'.
wa_data-amount = '15000.00'.
APPEND wa_data TO it_data.
CLEAR : wa_data.

wa_data-comp_name = 'ABC'.
wa_data-dept = 'HR'.
wa_data-amount = '20000.00'.
APPEND wa_data TO it_data.
CLEAR : wa_data.

LOOP AT it_data into wa_data.
COLLECT wa_data into it_final.
ENDLOOP.  

LOOP AT it_final into wa_data.
write : / wa_data-comp_name , wa_data-dept , wa_data-amount.
ENDLOOP.
