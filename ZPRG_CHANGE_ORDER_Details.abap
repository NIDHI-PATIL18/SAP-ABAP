*&---------------------------------------------------------------------*
*& Report ZCHNAGE_ORDER_DETAILS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zchnage_order_details.

PARAMETERS p_ono TYPE zdeono_n.
PARAMETERS P_Paymod TYPE zdepaym_n.

CALL FUNCTION 'ENQUEUE_EZ_ORDER'
 EXPORTING
   MODE_ZORDER_HEADER_N       = 'S'
   MANDT                      = SY-MANDT
   ORDNO                      = p_ono
   X_ORDNO                    = ' '
   _SCOPE                     = '2'
   _WAIT                      = ' '
   _COLLECT                   = ' '
 EXCEPTIONS
   FOREIGN_LOCK               = 1
   SYSTEM_FAILURE             = 2
   OTHERS                     = 3
          .
IF sy-subrc <> 0.
MESSAGE E012(ZMSG).
ELSE.
UPDATE ZORDER_HEADER_N SET PAYMOD = p_paymod where ORDNO = p_ono.
IF sy-subrc = 0.
  Write text-000.
  Else.
    WRITE text-001.
ENDIF.

CALL FUNCTION 'DEQUEUE_EZ_ORDER'
 EXPORTING
   MODE_ZORDER_HEADER_N       = 'S'
   MANDT                      = SY-MANDT
   ORDNO                      = p_ono
   X_ORDNO                    = ' '
   _SCOPE                     = '3'
   _SYNCHRON                  = ' '
   _COLLECT                   = ' '
          .
ENDIF.