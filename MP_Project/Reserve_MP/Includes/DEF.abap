*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_DEF
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_DEF
*&---------------------------------------------------------------------*
*======================================================================*
*                Source Code Documentation Section                     *
*======================================================================*
* Requested by  : Ana Marlen Yañez
* Date          : Sep 04 2024
* Developer     : Kushagra Shah(SHAHAK)
* Description   : New Reserve SAP Process flow for DIE-ON Film
*                 frame proposal in WOBE plant.
*                 Transfer posting inventory from warehouse storage
*                 location to a separate storage location, maintaining
*                 original quant information, including storage units
* ITRS / Ref.   : RITM162110
* Transport     : DEVK9G0H43
*----------------------------------------------------------------------*
*======================================================================*

CLASS lcl_data_manager DEFINITION FINAL.
    PUBLIC SECTION.
  *--------------------------------------------------------------------*
      CLASS-METHODS:
        init_disable_fields,
        init_grid_source
          EXPORTING REFERENCE(ex_matnr) TYPE matnr
                    REFERENCE(ex_werks) TYPE werks_d
                    REFERENCE(ex_lgort) TYPE lgort_d
                    REFERENCE(ex_charg) TYPE charg_d
                    REFERENCE(ex_lqnum) TYPE lvs_lqnum
                    REFERENCE(ex_meins) TYPE meins,
  
        fields_catalog_source
          IMPORTING REFERENCE(im_itab_tab)     TYPE  STANDARD TABLE
                    REFERENCE(im_tab_name)     TYPE  slis_tabname
          EXPORTING REFERENCE(ex_tab_fieldcat) TYPE  lvc_t_fcat,
  
        init_grid_dest
          EXPORTING REFERENCE(ex_matnr) TYPE matnr
                    REFERENCE(ex_werks) TYPE werks_d
                    REFERENCE(ex_lgort) TYPE lgort_d
                    REFERENCE(ex_charg) TYPE charg_d
                    REFERENCE(ex_lqnum) TYPE lvs_lqnum
                    REFERENCE(ex_meins) TYPE meins
                    REFERENCE(ex_tonum) TYPE LQUA_BTANR
                    REFERENCE(ex_mblnr) TYPE mblnr
                    REFERENCE(ex_msg)   TYPE string,
  
        init_filter,
  
        fields_catalog_dest
          IMPORTING REFERENCE(im_itab)     TYPE  STANDARD TABLE
                    REFERENCE(im_tname)    TYPE  slis_tabname
          EXPORTING REFERENCE(ex_tab_fcat) TYPE  lvc_t_fcat.
  
  ENDCLASS.
  *---------------------------------------------------------------------*
  *                CLASS LCL_SCREEN_MAGANGER DEFINITION
  *---------------------------------------------------------------------*
  CLASS lcl_screen_manager DEFINITION FINAL.
    PUBLIC SECTION.
      CLASS-METHODS:
        user_command_1001,
        move_selected_record_S,
        move_selected_record_D,
        Bapi_posting_material_doc,
        bapi_to_for_posting_change.
  ENDCLASS.