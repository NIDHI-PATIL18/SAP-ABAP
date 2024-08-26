*&---------------------------------------------------------------------*
*& Report ZPRG_SMARTFORM_CALL_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_smartform_call_02.

TYPES: BEGIN OF ty_header,
         ono   TYPE zdeono_07,
         odate TYPE zdeodate_07,
         pm    TYPE zdepm_07,
         ta    TYPE zdeta_07,
         curr  TYPE zdecurr_07,
       END OF ty_header.

TYPES: BEGIN OF ty_item,
         ono   TYPE zdeono_07,
         oino  TYPE zoitemno_07,
         icost TYPE zitemcost_07,
       END OF ty_item.

DATA: it_header TYPE TABLE OF ty_header,
      it_item   TYPE TABLE OF ty_item,
      it_dtext type TSFTEXT,
      wa_dtext type TLINE.
DATA: lv_fname TYPE rs38l_fnam.
*      lv_text type CHAR50.

PARAMETERS : p_ono TYPE zdeono_07,
             p_text type char50.

WA_DTEXT-TDFORMAT = '*'.
WA_dTEXT-TDLINE = P_TEXT.
APPEND WA_DTEXT TO IT_DTEXT.


SELECT ono odate pm ta curr
  FROM zorder_header_c
  INTO TABLE it_header
  WHERE ono = p_ono.

IF it_header IS NOT INITIAL.
  SELECT ono oino icost
    FROM zorder_item_c
    INTO TABLE it_item
    FOR ALL ENTRIES IN it_header
    WHERE ono = it_header-ono.
ENDIF.


CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = 'ZSF_ORDER_DATA_02'
  IMPORTING
    fm_name            = lv_fname
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.

CALL FUNCTION lv_fname
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
    it_header                  = it_header
    it_item                    = it_item
    it_text                    = it_dtext
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
