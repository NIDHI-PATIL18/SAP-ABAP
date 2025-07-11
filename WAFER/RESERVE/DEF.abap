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
*---------------------------------------------------------------------*
*                CLASS LCL_DATA_MANAGER DEFINITION
CLASS lcl_data_manager DEFINITION FINAL.

    PUBLIC SECTION.
  
      CLASS-METHODS:
        init_grid_source,                                              " Initialize the data source for source grid
        fields_catalog_source,                                         " defines the source field catelog for the grid control
        init_grid_dest,                                                " Initialize the data source for destination grid
        init_filter,                                                   " filter functionality for the Batch no.
        fields_catalog_dest.                                           " defines the dest field catelog for the grid control
  
      CLASS-DATA: gv_mblnr_created TYPE c,                             " Created Material Documnet
                  gv_oldstr        TYPE c,                             " Exixting STR number
                  gv_stop          TYPE c,                             " Flag to stop processing
                  gv_lgnum         TYPE lgnum,                         " Warehouse number
                  gv_charg         TYPE lqua-charg,                    " Batch
                  gv_mblnr         TYPE bapi2017_gm_head_ret-mat_doc,  " Material Document Number
                  gv_mjahr         TYPE bapi2017_gm_head_ret-doc_year,  " Material Document Number
                  gv_date          TYPE zmm_scanreel_str-sydate,       " Date of processing
                  gv_time          TYPE zmm_scanreel_str-sytime,       " Time of processing
                  gv_uname         TYPE zmm_scanreel_str-syuser,       " User name
                  gv_strshort      TYPE zmm_scanreel_str-zstrnum,      " Short STR Number
                  gv_strlong       TYPE zmm_scanreel_str-strlong.      " Long STR Number
  
      CLASS-DATA: gt_source        TYPE TABLE OF source_s_type,        " LQUA Internal table for left container
                  gt_source_backup TYPE TABLE OF source_s_type,        " source internal table backup
                  gt_source_all    TYPE TABLE OF source_s_type,        "
                  gt_dest          TYPE TABLE OF dest_s_type,          " Internal table for Right container
                  gt_fieldcat      TYPE lvc_t_fcat,                    " Field Catalog internal table for source data
                  gs_fieldcat      TYPE lvc_s_fcat,                    " field catalog work area for source data
                  gt_fcat          TYPE lvc_t_fcat,                    " Field Catalog Internal table for dest data
                  gs_fcat          TYPE lvc_s_fcat,                    " Field Catalog work area for dest data
                  gt_charg_values  TYPE vrm_values,                    " Internal table to store batch values.
                  gs_selection     TYPE sel_s_type,
                  gs_layout        TYPE lvc_s_layo.
  
      CLASS-DATA: go_source_grid TYPE REF TO cl_gui_alv_grid,          " Instance of the source ALV grid control
                  go_dest_grid   TYPE REF TO cl_gui_alv_grid.          " Instance of the dest ALV grid control
  ENDCLASS.
  *---------------------------------------------------------------------*
  *                CLASS LCL_SCREEN_MAGANGER DEFINITION
  *---------------------------------------------------------------------*
  CLASS lcl_screen_manager DEFINITION FINAL.
    PUBLIC SECTION.
      CLASS-METHODS:
        user_command_1001,
        move_selected_record_s,                                        " Move selected record from source to dest.
        move_selected_record_d,                                        " Move selected record from dest to source.
        bapi_posting_material_doc,                                     " Create material document posting for inventory transaction
        bapi_to_for_posting_change.                                    " Creates a transportation order (TO) for the posting change
  
  ENDCLASS.
  *---------------------------------------------------------------------*
  *                CLASS LCL_EVENT_REVEIVER DEFINITION
  *---------------------------------------------------------------------*
  CLASS lcl_event_receiver DEFINITION FINAL.
  
    PUBLIC SECTION.
      METHODS:
        handle_user_command_to_s
          FOR EVENT user_command OF cl_gui_alv_grid
          IMPORTING e_ucomm,
        handle_toolbar_to_s
          FOR EVENT toolbar OF cl_gui_alv_grid
          IMPORTING e_object,
        handle_user_command_to_d
          FOR EVENT user_command OF cl_gui_alv_grid
          IMPORTING e_ucomm,
        handle_toolbar_to_d
          FOR EVENT toolbar OF cl_gui_alv_grid
          IMPORTING e_object.
  ENDCLASS.