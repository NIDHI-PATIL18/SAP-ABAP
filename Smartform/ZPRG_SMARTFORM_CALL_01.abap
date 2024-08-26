*&---------------------------------------------------------------------*
*& Report ZPRG_SMARTFORM_CALL_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPRG_SMARTFORM_CALL_01.

Data: lv_fname type RS38L_FNAM.

PARAMETERS : P_ONO type ZDEONO_07.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname                 = 'ZSF_ORDER_DATA_01'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 IMPORTING
   FM_NAME                  = lv_fname
 EXCEPTIONS
   NO_FORM                  = 1
   NO_FUNCTION_MODULE       = 2
   OTHERS                   = 3
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.




"call a Smartform from FM.
CALL FUNCTION lv_fname " dynamic in nature
  EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
    p_ono                      = P_ONO
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.