*&---------------------------------------------------------------------*
*& Include          ZMM_RETURN_WFSTR_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF lstr_bktxt,
         mblnr TYPE mkpf-mblnr,                        "Number of Material Document
         bktxt TYPE mkpf-bktxt,                        "Document Header Text
       END OF lstr_bktxt.

TYPES: BEGIN OF lstr_mseg_data,
         mblnr TYPE mseg-mblnr,                        "Number of Material Document
         matnr TYPE mseg-matnr,                        "Material Number
         charg TYPE mseg-charg,                        "Batch Number
         menge TYPE mseg-menge,                        "Quantity
         lgpla TYPE mseg-lgpla,                        "Storage Bin
         lgort TYPE mseg-lgort,                        "Storage Location
         meins TYPE mseg-meins,                        "Base Unit of Measure
       END OF lstr_mseg_data.

TYPES: BEGIN OF lstr_tc_main,
         mblnr         TYPE mseg-mblnr,                        "Number of Material Document
         matnr         TYPE mseg-matnr,                        "Material Number
         charg         TYPE mseg-charg,                        "Batch Number
         unrescricted  TYPE mseg-menge,                        "Unrescricted column
         variant       TYPE char25,                            "Variant Name
         prev_count    TYPE mseg-menge,                        "Previous Count
         consumption   TYPE mseg-menge,                        "Consumption
         scrap         TYPE mseg-menge,                        "Scrap
         new_count     TYPE mseg-menge,                        "New Count
         log           TYPE char10,                            "log
       END OF lstr_tc_main.

DATA: gt_tc_main TYPE TABLE OF lstr_tc_main,           "Internal table for 'Process' Table control
      gs_tc_main TYPE lstr_tc_main.

DATA: gt_mseg_data TYPE TABLE OF lstr_mseg_data,       "Internal table for mseg data
      gs_mseg_data TYPE lstr_mseg_data.

DATA: gt_bktxt_data TYPE TABLE OF lstr_bktxt,          "Internal table for BKTXT data from MKPF table
      gs_bktxt_data TYPE lstr_bktxt.

DATA: gs_mseg TYPE mseg.                               "Workarea Used for Input parameters on screen

DATA: gv_str_num TYPE mkpf-bktxt.                      "Input STR Number

DATA: gv_dest_din TYPE string.                         "Input Destination Bin.

DATA: gv_previous_count_total TYPE mseg-menge,          "Prev. Count Total
      gv_consumption_total    TYPE mseg-menge,          "Consumption Total
      gv_scrap_total          TYPE mseg-menge,          "Scrap Total
      gv_new_count_total      TYPE mseg-menge.          "New Count Total

DATA: gs_goodsmvt_header TYPE bapi2017_gm_head_01.      "Workarea for importing parameter 'goodsmvt_header' of Bapi 'BAPI_GOODSMVT_CREATE'

DATA: gt_goodsmvt_item TYPE TABLE OF bapi2017_gm_item_create,    "Internal table for 'GOODSMVT_ITEM' which is one of the Table of Bapi 'BAPI_GOODSMVT_CREATE'
      gs_goodsmvt_item LIKE LINE OF gt_goodsmvt_item.

DATA: gt_return_msg    TYPE TABLE OF bapiret2.                   "Internal table for 'Return' which is one of the Table of Bapi 'BAPI_GOODSMVT_CREATE'

DATA: gv_fill_tc_flag  TYPE char1.                               "Flag for filling table control 'ZTC_PROCESS'(Used for Avoiding Recursive filling of Table Control).

DATA: gv_total_of_scrap_consum TYPE mseg-menge.                  "Variable for validating total(is it greater than Prev. Count or not ).

DATA: gv_mblnr                        TYPE TABLE OF mseg-mblnr,
      gv_consumption_gt               TYPE char1,                              "If consumption is greater than value will be 'X'
      gv_scrap_gt                     TYPE char1,                              "If scrap is greater than value will be 'X'
      gv_combination_gt               TYPE char1,                              "If combination is greater than value will be 'X'
      gv_no_of_rec_processed_counter  TYPE i.



*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC_PROCESS' ITSELF
CONTROLS: ZTC_PROCESS TYPE TABLEVIEW USING SCREEN 0200.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC_PROCESS'
DATA:     G_ZTC_PROCESS_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.