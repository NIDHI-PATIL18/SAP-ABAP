*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTR_DEF
*&---------------------------------------------------------------------*
*======================================================================*
*                Source Code Documentation Section                     *
*======================================================================*
* Requested by  : Ana Marlen Yañez
* Date          : Sep 04 2024
* Developer     : Shashikant M (MOTARWS)
* Description   : New RETURN SAP Process flow for DIE-ON Film
*                 frame proposal in WOBE plant.
*                 Return: Goods Issue & Transfer posting inventory from
*                 warehouse storage location to a separate storage
*                 location, maintaining original quant information,
*                 including storage units
* ITRS / Ref.   : RITM162110
* Transport     : DEVK9G0H43
*----------------------------------------------------------------------*
*======================================================================*
*---------------------------------------------------------------------*
*                CLASS LCL_DATA_MANAGER DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_data_manager DEFINITION FINAL.

    PUBLIC SECTION.
  *--------------------------------------------------------------------*
  
      CLASS-METHODS:
        initialize_screen_1001,
        ini_clear_data,
        validate_before_call_bapi,
        confirm_action,
        call_bapi IMPORTING es_bapi_header   TYPE bapi2017_gm_head_01
                            ev_goodsmvt_code TYPE bapi2017_gm_code
                            ev_testrun       TYPE bapi2017_gm_gen-testrun OPTIONAL
                  CHANGING  ev_mat_doc       TYPE bapi2017_gm_head_ret-mat_doc
                            ev_matdoc_year   TYPE bapi2017_gm_head_ret-doc_year OPTIONAL
                            et_goodsmvt_item TYPE gty_goodsmvt_item
                            et_return        TYPE gty_return,
  
        process_data IMPORTING iv_ident          TYPE flag
                     EXPORTING ev_matdoc_created TYPE flag
                               ev_to_created     TYPE flag,
  
        create_to IMPORTING iv_ident      TYPE flag
                            iv_mat_doc    TYPE bapi2017_gm_head_ret-mat_doc
                            iv_mjahr      TYPE mseg-mjahr
                  EXPORTING ev_to_created TYPE flag,
  
        create_posting_change IMPORTING iv_ident   TYPE flag
                                        iv_mat_doc TYPE bapi2017_gm_head_ret-mat_doc
                                        iv_mjahr   TYPE mseg-mjahr.
  
      CLASS-DATA: gv_lgnum     TYPE lgnum,
                  gv_oldstr    TYPE flag,
                  gv_strshort  TYPE zmm_scanreel_ret-zstrnum, " Short Str Number
                  gv_lgpla     TYPE lqua-lgpla,               " Bin Number
                  gv_date      TYPE zmm_scanreel_ret-sydate,
                  gv_time      TYPE zmm_scanreel_ret-sytime,
                  gv_uname     TYPE zmm_scanreel_ret-syuser,
                  gv_strlong   TYPE zmm_scanreel_ret-strlong,
                  gv_processed TYPE c LENGTH 1,
                  gv_answer    TYPE c,
                  gv_failed    TYPE c,
                  gv_proceed   TYPE c VALUE abap_true,
                  gv_crsr_fld  TYPE c LENGTH 20,              " Cursor Field
                  gv_crsr_line TYPE sy-loopc,
                  gt_scanreel  TYPE TABLE OF zmm_scanreel_ret.
  ENDCLASS.
  
  *---------------------------------------------------------------------*
  *                CLASS LCL_SCREEN_MAGANGER DEFINITION
  *---------------------------------------------------------------------*
  CLASS lcl_screen_manager DEFINITION FINAL.
  
    PUBLIC SECTION.
  *--------------------------------------------------------------------*
      CLASS-METHODS:
        user_command_1001.
  
  ENDCLASS.