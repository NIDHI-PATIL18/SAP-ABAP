*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_IMP
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
CLASS lcl_data_manager IMPLEMENTATION.

    METHOD init_grid_source.
  
      " Container for table.
      DATA: lo_source_dsp     TYPE REF TO cl_gui_custom_container,
            lo_event_receiver TYPE REF TO lcl_event_receiver.
  
      CONSTANTS: lc_ctrl_name TYPE scrfname VALUE c_p_alvs.
  
      IF go_source_grid IS INITIAL.
  
        CREATE OBJECT lo_source_dsp
          EXPORTING
            container_name = lc_ctrl_name.
  
        CREATE OBJECT go_source_grid
          EXPORTING
            i_parent = lo_source_dsp.
  
  *---Create Object Event
        CREATE OBJECT lo_event_receiver.
        SET HANDLER lo_event_receiver->handle_user_command_to_s FOR go_source_grid.          "Handle User Command
        SET HANDLER lo_event_receiver->handle_toolbar_to_s FOR go_source_grid.               "Handle Tool Bar
  
        CLEAR: lcl_data_manager=>gt_fieldcat.
  
        CALL METHOD fields_catalog_source.
  
        CALL METHOD go_source_grid->set_table_for_first_display
          EXPORTING
            is_layout       = gs_layout
          CHANGING
            it_outtab       = lcl_data_manager=>gt_source
            it_fieldcatalog = lcl_data_manager=>gt_fieldcat.
  
        CALL METHOD go_source_grid->refresh_table_display.
      ELSE.
        CALL METHOD go_source_grid->refresh_table_display.
      ENDIF.
    ENDMETHOD.
  *------------------------------------------
  *  Build Field Catalog for Display for Source
  *------------------------------------------
    METHOD fields_catalog_source.
  
      gs_layout-box_fname   = c_p_selline.
      gs_layout-sel_mode    = c_selmode.
  
      gs_fieldcat-fieldname = c_p_matnr.
      gs_fieldcat-tabname   = c_p_gtsour.
      gs_fieldcat-coltext   = TEXT-f01.
      gs_fieldcat-outputlen = c_len_25.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = c_p_werks1.
      gs_fieldcat-tabname   = c_p_gtsour.
      gs_fieldcat-coltext   = TEXT-f02.
      gs_fieldcat-outputlen = c_len_05.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = c_p_lgort.
      gs_fieldcat-tabname   = c_p_gtsour.
      gs_fieldcat-coltext   = TEXT-f03.
      gs_fieldcat-outputlen = c_len_06.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = c_p_charg.
      gs_fieldcat-tabname   = c_p_gtsour.
      gs_fieldcat-coltext   = TEXT-f04.
      gs_fieldcat-outputlen = c_len_11.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname  = c_p_verme.
      gs_fieldcat-tabname    = c_p_gtsour.
      gs_fieldcat-just       = c_l_ch.
      gs_fieldcat-coltext    = TEXT-f05.
      gs_fieldcat-decimals_o = c_dec_0.
      gs_fieldcat-outputlen = c_len_13.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = c_p_meins.
      gs_fieldcat-tabname   = c_p_gtsour.
      gs_fieldcat-coltext   = TEXT-f06.
      gs_fieldcat-outputlen = c_len_05.
      APPEND gs_fieldcat TO lcl_data_manager=>gt_fieldcat.
      CLEAR: gs_fieldcat.
  
    ENDMETHOD.
  *------------------------------------------
  * init_grid_dest.
  *------------------------------------------
    METHOD init_grid_dest.
  
      DATA: lo_dest_dsp TYPE REF TO cl_gui_custom_container  .                              " Container for table.
      DATA: lo_event_receiver_d TYPE REF TO lcl_event_receiver.
      CONSTANTS: lc_ctrl_name TYPE scrfname VALUE c_p_alvdest.
  
      IF go_dest_grid IS INITIAL.
  
        CREATE OBJECT lo_dest_dsp
          EXPORTING
            container_name = lc_ctrl_name.
  
        CREATE OBJECT go_dest_grid
          EXPORTING
            i_parent = lo_dest_dsp.
  
  *---Create Object Event
        CREATE OBJECT lo_event_receiver_d.
        SET HANDLER lo_event_receiver_d->handle_user_command_to_d FOR go_dest_grid.          "Handle User Command
        SET HANDLER lo_event_receiver_d->handle_toolbar_to_d FOR go_dest_grid.               "Handle Tool Bar
  
        CALL METHOD fields_catalog_dest.
  
        CALL METHOD go_dest_grid->set_table_for_first_display
          EXPORTING
            is_layout       = gs_layout
          CHANGING
            it_outtab       = lcl_data_manager=>gt_dest
            it_fieldcatalog = lcl_data_manager=>gt_fcat.
  
        CALL METHOD go_dest_grid->refresh_table_display.
      ELSE.
        CALL METHOD go_dest_grid->refresh_table_display.
      ENDIF.
    ENDMETHOD.
  *------------------------------------------
  ** Initialize filter for charg field.
  **------------------------------------------
    METHOD init_filter.
  
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = c_vrm_field
          values = lcl_data_manager=>gt_charg_values.
  
    ENDMETHOD.
  *------------------------------------------
  *  Build Field Catalog for Display for Dest
  *------------------------------------------
    METHOD fields_catalog_dest.
  
      gs_layout-box_fname = c_p_alvdest.
      gs_layout-sel_mode  = c_selmode.
  
      gs_fcat-fieldname   = c_p_material.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f01.
      gs_fcat-outputlen   = c_len_25.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_werks1.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f02.
      gs_fcat-outputlen   = c_len_05.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_lgort.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f03.
      gs_fcat-outputlen   = c_len_05.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_charg.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f04.
      gs_fcat-outputlen   = c_len_11.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_verme.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-just        = c_l_ch.
      gs_fcat-coltext     = TEXT-f05.
      gs_fcat-decimals_o  = c_dec_0.
      gs_fcat-outputlen   = c_len_13.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_meins.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f06.
      gs_fcat-outputlen   = c_len_05.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_to_num.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-just        = c_l_ch.
      gs_fcat-coltext     = TEXT-f07.
      gs_fcat-outputlen   = c_len_11.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_post_change.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f08.
      gs_fcat-outputlen   = c_len_11.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname   = c_p_msg.
      gs_fcat-tabname     = c_p_gtdest.
      gs_fcat-coltext     = TEXT-f09.
      gs_fcat-outputlen   = c_len_60.
      APPEND gs_fcat TO lcl_data_manager=>gt_fcat.
      CLEAR: gs_fcat.
  
    ENDMETHOD.
  ENDCLASS.
  
  CLASS lcl_screen_manager IMPLEMENTATION.
  *------------------------------------------
  * user_command_1001.
  *------------------------------------------
    METHOD user_command_1001.
  
      DATA: lv_okcode     TYPE sy-ucomm,
            lt_backup_del TYPE TABLE OF dest_s_type,
            lv_proceed    TYPE c LENGTH 1 VALUE abap_true.
  
      lv_okcode = sy-ucomm.
  
      CASE lv_okcode.
  
        WHEN zcon_fct_back OR zcon_fct_exit OR zcon_fct_cancel.
          IF lcl_data_manager=>gt_dest IS NOT INITIAL.
            IF line_exists( lcl_data_manager=>gt_dest[ verme = c_zero_qty ] ).
              PERFORM f_delete_null_quantity.
            ENDIF.
            LEAVE TO SCREEN 0.
          ELSE.
            LEAVE TO SCREEN 0.
          ENDIF.
  
        WHEN c_p_fc_batch.
          PERFORM f_filter_container_data.
  
        WHEN c_p_process.
  
          " Check if any non-zero qty records available to process
          lt_backup_del = CORRESPONDING #( lcl_data_manager=>gt_dest ).
          DELETE lt_backup_del WHERE verme = c_zero_qty.
          IF lt_backup_del IS INITIAL.
            " No non-zero qty records available to process
            CLEAR: lv_proceed.
          ENDIF.
  
          IF lv_proceed EQ abap_true." at least one non-zero qty records available to process
  
            CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
  
            IF lcl_data_manager=>gv_mblnr_created NE abap_true. " if material document is not posted, create material document
              lcl_screen_manager=>bapi_posting_material_doc( ).
            ENDIF.
  
            CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
  
            IF lcl_data_manager=>gv_mblnr IS NOT INITIAL.       "If material document available, go with TO posting
  
              IF line_exists( lcl_data_manager=>gt_dest[ to_number = c_zero_tanum ] ).
  
                lcl_screen_manager=>bapi_to_for_posting_change( ).
                CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
  
              ELSE.
                " All records already processed.
                MESSAGE TEXT-e21 TYPE zcon_msg_e.
              ENDIF.
            ENDIF.
  
            PERFORM f_rfc_close_destination.
  
          ELSE.
  
            " No records with Available stock, please select from left side panel.
            MESSAGE TEXT-e20 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
  
          ENDIF.
          CLEAR lt_backup_del[].
      ENDCASE.
    ENDMETHOD.                    "LEAVE_SCREEN
  *-------------------------------------------------
  * Move selected records from Source to Dest table
  *-------------------------------------------------
    METHOD move_selected_record_s.
  
      DATA: lt_zmm_scanreel_str TYPE TABLE OF zmm_scanreel_str,
            ls_zmm_scanreel_str TYPE zmm_scanreel_str,
            lt_row_selected     TYPE lvc_t_row,                 " To hold selected rows
            ls_dest             TYPE dest_s_type,
            lv_menge            TYPE char20,
            lv_index            TYPE sy-tabix,                  " Index for selected rows
            lr_batch            TYPE RANGE OF string.
  
      " Get selected rows from the left container (DEST)
      CALL METHOD lcl_data_manager=>go_source_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row_selected.
  
      " Loop through selected rows and move them
      LOOP AT lt_row_selected ASSIGNING FIELD-SYMBOL(<lfs_row_selected>).
        IF <lfs_row_selected> IS ASSIGNED.
          lv_index = <lfs_row_selected>-index.
  
          " Read the selected row from gt_dest based on the index
          DATA(ls_source) = lcl_data_manager=>gt_source[ lv_index ].
  
          IF sy-subrc IS INITIAL.
            ls_dest-material        =   ls_source-matnr.
            ls_dest-matnr           =   ls_source-matnr.
            ls_dest-werks           =   ls_source-werks.
            ls_dest-lgort           =   ls_source-lgort.
            ls_dest-charg           =   ls_source-charg.
            ls_dest-verme           =   ls_source-verme.
            ls_dest-lqnum           =   ls_source-lqnum.
            ls_dest-lgnum           =   ls_source-lgnum.
            ls_dest-meins           =   ls_source-meins.
            ls_dest-ins_flag        =   abap_true.
            APPEND ls_dest TO lcl_data_manager=>gt_dest.
            CLEAR ls_dest.
  
            ls_source-del_flag = abap_true.
            MODIFY lcl_data_manager=>gt_source FROM ls_source INDEX lv_index.
          ENDIF.
        ENDIF.
      ENDLOOP.
  
      SORT lcl_data_manager=>gt_dest BY charg DESCENDING.
  
      lr_batch = VALUE #( FOR ls_filter_batch IN lcl_data_manager=>gt_source
                        WHERE ( del_flag = abap_true ) ( option = zcon_opt_eq
                                                         sign   = zcon_sign_i
                                                         low    = ls_filter_batch-charg ) ).
  
      " Delete the records from left container after moving it to right conatiner
      DELETE lcl_data_manager=>gt_source WHERE del_flag = abap_true.
  
      IF lcl_data_manager=>gt_source IS NOT INITIAL.
        lcl_data_manager=>gt_charg_values = VALUE #( FOR ls_source1 IN lcl_data_manager=>gt_source
                                                                       ( key  = ls_source1-charg
                                                                         text = ls_source1-charg ) ).
      ELSE.
  
        " Delete the move record batch from the drop down list.
        DELETE lcl_data_manager=>gt_charg_values WHERE key IN lr_batch.
      ENDIF.
  
      LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest>) WHERE ins_flag = abap_true.
        IF <lfs_dest> IS ASSIGNED.
          ls_zmm_scanreel_str-zstrnum         = lcl_data_manager=>gv_strshort.
          ls_zmm_scanreel_str-sydate          = lcl_data_manager=>gv_date.
          ls_zmm_scanreel_str-sytime          = lcl_data_manager=>gv_time.
          ls_zmm_scanreel_str-syuser          = lcl_data_manager=>gv_uname.
          ls_zmm_scanreel_str-material        = <lfs_dest>-material.
          ls_zmm_scanreel_str-werks           = <lfs_dest>-werks.
          ls_zmm_scanreel_str-lgort           = <lfs_dest>-lgort.
          ls_zmm_scanreel_str-charg           = <lfs_dest>-charg.
          ls_zmm_scanreel_str-menge           = <lfs_dest>-verme.
          ls_zmm_scanreel_str-meins           = <lfs_dest>-meins.
          ls_zmm_scanreel_str-timestamp       = <lfs_dest>-timestamp.
          ls_zmm_scanreel_str-zlgtyp_source   = p_sloc_t.
          ls_zmm_scanreel_str-bwart           = p_inv_m.
          ls_zmm_scanreel_str-zlgort_dest     = p_dloc.
          ls_zmm_scanreel_str-zlgtyp_dest     = p_zlgtyp .
          ls_zmm_scanreel_str-strlong         = lcl_data_manager=>gv_strlong.
          lv_menge                            = <lfs_dest>-verme.
          CONDENSE lv_menge.
  
          ls_zmm_scanreel_str-lngstr = ls_zmm_scanreel_str-material  && "#EC CI_FLDEXT_OK[2215424]
                                       c_sep_ch                      &&
                                       c_l_ch                        &&
                                       ls_zmm_scanreel_str-charg     &&
                                       c_sep_ch                      &&
                                       c_q_ch                        &&
                                       lv_menge                      &&
                                       c_sep_ch                      &&
                                       ls_zmm_scanreel_str-timestamp.
  
          APPEND ls_zmm_scanreel_str TO lt_zmm_scanreel_str.
  
          CLEAR: ls_zmm_scanreel_str, lv_menge.
        ENDIF.
      ENDLOOP.
  
      IF lt_zmm_scanreel_str[] IS NOT INITIAL.
        TRY.
  
            MODIFY zmm_scanreel_str FROM TABLE lt_zmm_scanreel_str.
  
            IF sy-subrc IS INITIAL.
              COMMIT WORK.
              CLEAR lt_zmm_scanreel_str[].
            ENDIF.
  
          CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
            MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
          CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
            MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
        ENDTRY.
      ENDIF.
  
      SORT lcl_data_manager=>gt_dest BY charg.
  
      CLEAR lr_batch[].
  
      " Refresh destination grids
      CALL METHOD lcl_data_manager=>go_source_grid->refresh_table_display.
      CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
    ENDMETHOD.
  
  **------------------------------------------
  *Move selected records from Dest to Source table
  **------------------------------------------
    METHOD move_selected_record_d.
  
      DATA: lt_row_selected     TYPE lvc_t_row,          " To hold selected rows
            ls_source           TYPE source_s_type,
            lv_index            TYPE sy-tabix,           " Index for selected rows
            ls_zmm_scanreel_str TYPE zmm_scanreel_str,
            lt_zmm_scanreel_str TYPE STANDARD TABLE OF zmm_scanreel_str.
  
      " Get selected rows from the left container (DEST)
      CALL METHOD lcl_data_manager=>go_dest_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row_selected.
  
      " Loop through selected rows and move them
      LOOP AT lt_row_selected ASSIGNING FIELD-SYMBOL(<lfs_row_selected>).
        IF <lfs_row_selected> IS ASSIGNED.
          lv_index = <lfs_row_selected>-index.
  
          " Read the selected row from gt_dest based on the index
          DATA(ls_dest) = lcl_data_manager=>gt_dest[ lv_index ].
  
          IF sy-subrc IS INITIAL.
            ls_source = CORRESPONDING #( ls_dest ).
            ls_source-matnr = ls_dest-matnr.
            APPEND ls_source TO lcl_data_manager=>gt_source.
            CLEAR ls_source.
  
            ls_dest-del_flag = abap_true.
            MODIFY lcl_data_manager=>gt_dest FROM ls_dest INDEX lv_index TRANSPORTING del_flag.
          ENDIF.
        ENDIF.
      ENDLOOP.
  
      " Build records to delete from z table
      LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest>) WHERE del_flag = abap_true.
        IF <lfs_dest> IS ASSIGNED.
          CLEAR ls_zmm_scanreel_str.
          ls_zmm_scanreel_str-zstrnum   = lcl_data_manager=>gv_strshort.
          ls_zmm_scanreel_str-sydate    = lcl_data_manager=>gv_date.
          ls_zmm_scanreel_str-sytime    = lcl_data_manager=>gv_time.
          ls_zmm_scanreel_str-material  = <lfs_dest>-material.
          ls_zmm_scanreel_str-charg     = <lfs_dest>-charg.
          ls_zmm_scanreel_str-bwart     = p_inv_m.
          ls_zmm_scanreel_str-lgort     = <lfs_dest>-lgort.
          APPEND ls_zmm_scanreel_str TO lt_zmm_scanreel_str.
        ENDIF.
      ENDLOOP.
  
      " Delete records from z table
      IF lt_zmm_scanreel_str[] IS NOT INITIAL.
        TRY.
  
            DELETE zmm_scanreel_str FROM TABLE lt_zmm_scanreel_str.
  
            IF sy-subrc IS INITIAL.
              COMMIT WORK.
              CLEAR lt_zmm_scanreel_str[].
            ENDIF.
  
          CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
            MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
          CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
            MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
        ENDTRY.
      ENDIF.
  
      " Delete the the records from the right container that are getting moved to left conatiner.
      DELETE lcl_data_manager=>gt_dest WHERE del_flag = abap_true.
  
      lcl_data_manager=>gt_charg_values = VALUE #( FOR ls_scr1 IN lcl_data_manager=>gt_source_backup ( key = ls_scr1-charg
                                                                                                      text = ls_scr1-charg ) ).
      SORT lcl_data_manager=>gt_charg_values.
  
      LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_record1>).
        IF <lfs_record1> IS ASSIGNED.
          DELETE lcl_data_manager=>gt_charg_values WHERE key = <lfs_record1>-charg.
        ENDIF.
      ENDLOOP.
  
      SORT lcl_data_manager=>gt_source BY charg.
  
      IF lcl_data_manager=>gv_charg IS NOT INITIAL.
        DELETE lcl_data_manager=>gt_source WHERE charg NE lcl_data_manager=>gv_charg.
      ENDIF.
  
      " Refresh destination grids
      CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
      CALL METHOD lcl_data_manager=>go_source_grid->refresh_table_display.
  
    ENDMETHOD.
  *------------------------------------------
  ** Bapi_posting_material_doc.
  **------------------------------------------
    METHOD bapi_posting_material_doc.
  
      DATA: lv_message     TYPE string,
            lv_menge       TYPE char20,
            lv_part_failed TYPE c LENGTH 1.
  
      DATA: lt_zmm_scanreel_str TYPE STANDARD TABLE OF zmm_scanreel_str,
            ls_zmm_scanreel_str TYPE zmm_scanreel_str.
  
      DATA: ls_gm_header TYPE bapi2017_gm_head_01,
            lt_gm_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
            ls_gm_item   TYPE bapi2017_gm_item_create,
            lt_gm_return TYPE STANDARD TABLE OF bapiret2.
  
      ls_gm_header-header_txt = lcl_data_manager=>gv_strlong.           " STR Number from destination
      ls_gm_header-doc_date   = sy-datum.                               " Current date
      ls_gm_header-pstng_date = sy-datum.                               " Posting date
  
      SORT lcl_data_manager=>gt_dest BY matnr werks lgort charg.
  
      LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest>).
        IF <lfs_dest> IS ASSIGNED.
  
          IF <lfs_dest>-verme IS INITIAL.
  
            <lfs_dest>-msg = TEXT-t02. " No Available stock currently, record skipped from processing.
  
          ELSE.
            ls_gm_item-material   = <lfs_dest>-matnr.
            ls_gm_item-plant      = p_werks.
            ls_gm_item-stge_loc   = <lfs_dest>-lgort.
            ls_gm_item-batch      = <lfs_dest>-charg.
            ls_gm_item-move_stloc = p_dloc.
            ls_gm_item-move_batch = <lfs_dest>-charg.
            ls_gm_item-move_plant = p_werks.
            ls_gm_item-move_type  = p_inv_m.
            ls_gm_item-entry_qnt  = <lfs_dest>-verme.
            ls_gm_item-entry_uom  = <lfs_dest>-meins.
            ls_gm_item-spec_mvmt  = c_bsskz.
            APPEND ls_gm_item TO lt_gm_item.
            CLEAR: ls_gm_item.
  
          ENDIF.
        ENDIF.
      ENDLOOP.
  
      IF lt_gm_item IS NOT INITIAL.
  
        CALL FUNCTION 'BAPI_GOODSMVT_CREATE' DESTINATION c_destination_n "#EC CI_USAGE_OK[2438131]
          EXPORTING
            goodsmvt_header       = ls_gm_header
            goodsmvt_code         = c_gmcode
          IMPORTING
            materialdocument      = lcl_data_manager=>gv_mblnr
            matdocumentyear       = lcl_data_manager=>gv_mjahr
          TABLES
            goodsmvt_item         = lt_gm_item
            return                = lt_gm_return
          EXCEPTIONS
            communication_failure = 1
            system_failure        = 2
            OTHERS                = 3.
  
        IF sy-subrc IS INITIAL.
  
          IF line_exists( lt_gm_return[ type = zcon_msg_e ] ).
  
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
              EXCEPTIONS
                communication_failure = 1
                system_failure        = 2
                OTHERS                = 3.
  
            IF sy-subrc IS NOT INITIAL.
              MESSAGE TEXT-e18 TYPE zcon_msg_e.
            ENDIF.
  
            " Check if there are any errors in the return table
            CLEAR: lv_message.
            IF lt_gm_return IS NOT INITIAL.
              LOOP AT lt_gm_return ASSIGNING FIELD-SYMBOL(<lfs_gm_return>) WHERE type = zcon_msg_e.
                IF <lfs_gm_return> IS ASSIGNED.
                  IF <lfs_gm_return>-message_v4 IS NOT INITIAL.
                    DATA(lv_message_v4) = <lfs_gm_return>-message_v4.
                    DATA(lv_charg)  = lv_message_v4+c_offset(c_charg_len).
                    IF lv_charg IS NOT INITIAL.
                      READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_part>) WITH KEY charg = lv_charg BINARY SEARCH.
                      IF <lfs_part> IS ASSIGNED.
                        IF <lfs_part>-verme IS NOT INITIAL.
                          lv_part_failed = abap_true.
                          <lfs_part>-msg = <lfs_gm_return>-message.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ELSE.
                    IF <lfs_gm_return>-message IS NOT INITIAL AND <lfs_gm_return>-row IS NOT INITIAL.
                      READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_all>) INDEX <lfs_gm_return>-row.
                      IF <lfs_all> IS ASSIGNED.
                        <lfs_all>-msg = <lfs_gm_return>-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
  
            " Put back the sort order
            SORT lcl_data_manager=>gt_dest BY matnr werks lgort charg.
  
            " Check if its a Part failed case.
            IF lv_part_failed EQ abap_true.
              LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_record>) WHERE verme IS NOT INITIAL AND msg IS INITIAL.
                IF <lfs_dest_record> IS ASSIGNED.
                  <lfs_dest_record>-msg = TEXT-e22.      " Other record(s) in error, hence skipped this record.
                ENDIF.
              ENDLOOP.
            ENDIF.
  
          ELSE.
  
            " If no errors, commit the transaction
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION c_destination_n
              EXPORTING
                wait                  = abap_true
              EXCEPTIONS
                communication_failure = 1
                system_failure        = 2
                OTHERS                = 3.
  
            IF sy-subrc IS NOT INITIAL.
              MESSAGE TEXT-e17 TYPE zcon_msg_e.
            ENDIF.
  
          ENDIF.
        ELSE.
  
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
            EXCEPTIONS
              communication_failure = 1
              system_failure        = 2
              OTHERS                = 3.
          IF sy-subrc IS NOT INITIAL.
            MESSAGE TEXT-e18 TYPE zcon_msg_e.
          ENDIF.
  
          " Check if there are any errors in the return table
          CLEAR: lv_message.
          LOOP AT lt_gm_return ASSIGNING FIELD-SYMBOL(<lfs_gm_return1>) WHERE type = zcon_msg_e.
            IF <lfs_gm_return1> IS ASSIGNED.
              lv_message = lv_message && <lfs_gm_return1>-message.
            ENDIF.
          ENDLOOP.
  
          " Update message in table.
          LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_record1>) WHERE verme IS NOT INITIAL.
            IF <lfs_dest_record1> IS ASSIGNED.
              <lfs_dest_record1>-msg = lv_message.        " Assign the message to the ALV field
            ENDIF.
          ENDLOOP.
        ENDIF.
  
        IF lcl_data_manager=>gv_mblnr IS NOT INITIAL.
  
          lcl_data_manager=>gv_mblnr_created = abap_true.
  
          LOOP AT lcl_data_manager=>gt_dest ASSIGNING <lfs_dest> WHERE verme IS NOT INITIAL.
            IF <lfs_dest> IS ASSIGNED.
              ls_zmm_scanreel_str-zstrnum         = lcl_data_manager=>gv_strshort.
              ls_zmm_scanreel_str-sydate          = lcl_data_manager=>gv_date.
              ls_zmm_scanreel_str-sytime          = lcl_data_manager=>gv_time.
              ls_zmm_scanreel_str-syuser          = sy-uname.
              ls_zmm_scanreel_str-material        = <lfs_dest>-matnr.
              ls_zmm_scanreel_str-werks           = <lfs_dest>-werks.
              ls_zmm_scanreel_str-lgort           = <lfs_dest>-lgort.
              ls_zmm_scanreel_str-charg           = <lfs_dest>-charg.
              ls_zmm_scanreel_str-menge           = <lfs_dest>-verme.
              ls_zmm_scanreel_str-meins           = <lfs_dest>-meins.
              ls_zmm_scanreel_str-timestamp       = <lfs_dest>-timestamp.
              ls_zmm_scanreel_str-zlgtyp_source   = p_sloc_t.
              ls_zmm_scanreel_str-bwart           = p_inv_m.
              ls_zmm_scanreel_str-zlgort_dest     = p_dloc.
              ls_zmm_scanreel_str-zlgtyp_dest     = p_zlgtyp .
              ls_zmm_scanreel_str-strlong         = lcl_data_manager=>gv_strlong.
              ls_zmm_scanreel_str-mblnr           = lcl_data_manager=>gv_mblnr.
              lv_menge = <lfs_dest>-verme.
              CONDENSE lv_menge.
  
              ls_zmm_scanreel_str-lngstr = ls_zmm_scanreel_str-material   && "#EC CI_FLDEXT_OK[2215424]
                                           c_sep_ch                       &&
                                           c_l_ch                         &&
                                           ls_zmm_scanreel_str-charg      &&
                                           c_sep_ch                       &&
                                           c_q_ch                         &&
                                           lv_menge                       &&
                                           c_sep_ch                       &&
                                           ls_zmm_scanreel_str-timestamp.
  
              APPEND ls_zmm_scanreel_str TO lt_zmm_scanreel_str.
              CLEAR: ls_zmm_scanreel_str.
            ENDIF.
          ENDLOOP.
  
          IF lt_zmm_scanreel_str[] IS NOT INITIAL.
            TRY.
  
                MODIFY zmm_scanreel_str FROM TABLE lt_zmm_scanreel_str.
  
                IF sy-subrc IS INITIAL.
                  COMMIT WORK.
                  CLEAR lt_zmm_scanreel_str[].
                ENDIF.
  
              CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
                MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
              CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
                MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
  
            ENDTRY.
          ENDIF.
  
          " Get all posting change doc numbers for given MBLNR to update in GT_DEST
          SELECT mblnr, matnr, werks, lgort, charg, ubnum
            FROM mseg
           WHERE mblnr EQ @lcl_data_manager=>gv_mblnr
             AND mjahr EQ @lcl_data_manager=>gv_mjahr
             AND bwart EQ @p_inv_m
             AND lgort EQ @p_sloc
             AND ubnum IS NOT INITIAL
            INTO TABLE @DATA(lt_mseg).
  
          IF lt_mseg IS NOT INITIAL.
            SORT lt_mseg BY mblnr matnr werks lgort charg.
            LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg_record>).
              IF <lfs_mseg_record> IS ASSIGNED.
                READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_line>) WITH KEY matnr = <lfs_mseg_record>-matnr
                                                                                                      werks = <lfs_mseg_record>-werks
                                                                                                      charg = <lfs_mseg_record>-charg
                                                                                                      BINARY SEARCH.
                IF sy-subrc IS INITIAL AND <lfs_dest_line> IS ASSIGNED.
                  <lfs_dest_line>-posting_change = <lfs_mseg_record>-ubnum.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
          CLEAR lt_mseg[].
          CALL METHOD lcl_data_manager=>go_dest_grid->refresh_table_display.
  
          lv_message = | { TEXT-s01 }  { lcl_data_manager=>gv_mblnr } { TEXT-s02 } |.
          MESSAGE lv_message TYPE zcon_msg_i.
  
        ENDIF.
      ENDIF.
    ENDMETHOD.
  **----------------------------------------------
  ** Bapi to create TO number for posting change.
  **----------------------------------------------
    METHOD bapi_to_for_posting_change.
  
      DATA: lt_lubqu         TYPE STANDARD TABLE OF lubqu,   " Table for quants
            ls_lubqu         TYPE lubqu,                     " Structure for quant
            lt_ltap_vb       TYPE STANDARD TABLE OF ltap_vb, " Table for transfer items
            ls_ltap_vb       TYPE ltap_vb,                   " Structure for transfer item
            ls_lagp          TYPE lagp,
            lv_tanum         TYPE ltak-tanum,
            lv_bin_failed    TYPE c,
            lt_del_processed TYPE STANDARD TABLE OF zmm_scanreel_str,
            ls_del_processed TYPE zmm_scanreel_str,
            lv_message       TYPE bapiret2-message.
  
      CONSTANTS: lc_lptyp TYPE lvs_lptyp  VALUE c_actvt,
                 lc_lkapv TYPE lagp_lkapv VALUE c_max_capacity.
  
      IF lcl_data_manager=>gv_mblnr IS NOT INITIAL.
  
        " Get all posting change doc numbers for given MBLNR
        SELECT mblnr, matnr, werks, lgort, charg, ubnum
          FROM mseg
         WHERE mblnr EQ @lcl_data_manager=>gv_mblnr
           AND bwart EQ @p_inv_m
           AND lgort EQ @p_sloc
           AND ubnum IS NOT INITIAL
          INTO TABLE @DATA(lt_mseg).
  
        IF lt_mseg[] IS NOT INITIAL.
  
          SORT lt_mseg BY matnr werks charg.
          SORT lcl_data_manager=>gt_dest BY matnr werks charg.
  
          " Update Posting Change number if not updated already
          LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_pc>) WHERE posting_change IS INITIAL.
            IF <lfs_dest_pc> IS ASSIGNED.
              READ TABLE lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg>) WITH KEY matnr = <lfs_dest_pc>-matnr
                                                                             werks = <lfs_dest_pc>-werks
                                                                             charg = <lfs_dest_pc>-charg BINARY SEARCH.
              IF sy-subrc IS INITIAL AND <lfs_mseg> IS ASSIGNED.
                " Assign Posting Change number
                <lfs_dest_pc>-posting_change = <lfs_mseg>-ubnum.
              ENDIF.
            ENDIF.
          ENDLOOP.
  
          " Check the existance of Destination Storage Bin to be used
          SELECT COUNT( lgpla )
            FROM lagp
          WHERE lgnum = @lcl_data_manager=>gv_lgnum
            AND lgtyp = @p_zlgtyp
            AND lgpla = @lcl_data_manager=>gs_selection-bin " Storage Bin Without Leading Zeros
  *          AND lgpla = @lcl_data_manager=>gv_strshort " Commented by Shashi - UAT Changes
            INTO @DATA(lv_count).
  
          IF lv_count IS INITIAL.       " Destination Storage Bin does not exist, create a new one
  
            CLEAR ls_lagp.
            ls_lagp-lgnum = lcl_data_manager=>gv_lgnum.
            ls_lagp-lgtyp = p_zlgtyp.
            ls_lagp-lgpla = lcl_data_manager=>gs_selection-bin. " Storage Bin Without Leading Zeros
  *          ls_lagp-lgpla = lcl_data_manager=>gv_strshort. " Commented by Shashi - UAT Changes
            ls_lagp-lptyp = lc_lptyp.
            ls_lagp-lkapv = lc_lkapv.
  
            CALL FUNCTION 'L_LAGP_HINZUFUEGEN'
              EXPORTING
                xlagp         = ls_lagp
              EXCEPTIONS
                error_message = 99.
  
            IF sy-subrc IS NOT INITIAL.  " Destination Storage Bin Creation failed.
  
              lv_bin_failed = abap_true.
              LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<ls_dest_bin_failed>).
                IF <ls_dest_bin_failed> IS ASSIGNED.
                  <ls_dest_bin_failed>-msg = TEXT-e14.
                ENDIF.
              ENDLOOP.
  
            ENDIF.
          ENDIF.
  
          IF lv_count IS NOT INITIAL OR lv_bin_failed NE abap_true. " Bin already exists or created successfully
  
            " Build the range table
            DATA(lr_ubnum) = VALUE rsdsselopt_t(
             FOR ls_mseg IN lt_mseg
               ( sign   = zcon_sign_i
                 option = zcon_opt_eq
                 low    = ls_mseg-ubnum ) ).
  
            IF lr_ubnum[] IS NOT INITIAL.
  
              " Fetch all TOs created
              CLEAR lv_tanum.
              SELECT lgnum,
                     tanum,
                     ubnum
                FROM ltak
               WHERE lgnum = @lcl_data_manager=>gv_lgnum
                 AND tanum IS NOT INITIAL
                 AND ubnum IN @lr_ubnum[]
                ORDER BY PRIMARY KEY
                INTO TABLE @DATA(lt_tanum).
  
              SORT lt_tanum BY ubnum.
            ENDIF.
  
            " Cretae TOs
            LOOP AT lt_mseg ASSIGNING <lfs_mseg>.               " Fetch each posting change number
  
              IF <lfs_mseg> IS ASSIGNED.
  
                READ TABLE lt_tanum ASSIGNING FIELD-SYMBOL(<ls_tanum>) WITH KEY ubnum = <lfs_mseg>-ubnum BINARY SEARCH.
  
                IF <ls_tanum> IS ASSIGNED AND <ls_tanum>-tanum IS NOT INITIAL.
  
                  " TO is already created, update value and skip the record.
                  READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_upd>)
                                                                     WITH KEY matnr = <lfs_mseg>-matnr
                                                                              werks = <lfs_mseg>-werks
                                                                              charg = <lfs_mseg>-charg
                                                                              BINARY SEARCH.
                  IF <lfs_dest_upd> IS ASSIGNED.
                    <lfs_dest_upd>-to_number = <ls_tanum>-tanum.
                    CLEAR: <lfs_dest_upd>-msg. " clear old message
                    RETURN.
                  ENDIF.
  
                ELSE. " TO is not yet created, create a new one
  
                  CLEAR: lt_lubqu, lt_ltap_vb.
                  CLEAR: ls_lubqu, ls_ltap_vb, lv_tanum.
  
                  " Build FM table
                  LOOP AT lcl_data_manager=>gt_source_all ASSIGNING FIELD-SYMBOL(<lfs_source>)
                                                                           WHERE matnr = <lfs_mseg>-matnr
                                                                             AND werks = <lfs_mseg>-werks
                                                                             AND charg = <lfs_mseg>-charg.
                    IF <lfs_source> IS ASSIGNED.
                      " Fill T_LUBQU table for quant information
                      ls_lubqu-lqnum = <lfs_source>-lqnum.           " Quant number
                      ls_lubqu-menge = <lfs_source>-verme.           " Available quantity
  *                    ls_lubqu-nlpla = lcl_data_manager=>gv_strshort. " Commented by Shashi - UAT Changes
                      ls_lubqu-nlpla = lcl_data_manager=>gs_selection-bin. " Storage Bin Without Leading Zeros
  
                      ls_lubqu-nltyp = p_zlgtyp.
                      APPEND ls_lubqu TO lt_lubqu.
  
                      " Fill T_LTAP_VB table for transfer items
                      ls_ltap_vb-matnr = <lfs_source>-matnr.        " Material number
                      ls_ltap_vb-werks = <lfs_source>-werks.        " Plant
                      ls_ltap_vb-charg = <lfs_source>-charg.        " Batch
                      APPEND ls_ltap_vb TO lt_ltap_vb.
                    ENDIF.
                  ENDLOOP.
  
                  IF lt_lubqu   IS NOT INITIAL AND
                     lt_ltap_vb IS NOT INITIAL.
  
                    CLEAR lv_tanum.
  
                    " L_TO_CREATE_POSTING_CHANGE is an unreleased FM
                    " Continued to use this FM since it is the only option to Create transfer order for posting change
                    CALL FUNCTION 'L_TO_CREATE_POSTING_CHANGE'
                      EXPORTING
                        i_lgnum                      = lcl_data_manager=>gv_lgnum
                        i_ubnum                      = <lfs_mseg>-ubnum
                        i_squit                      = abap_true
                        i_nidru                      = abap_true
                        i_commit_work                = abap_true
                        i_bname                      = sy-uname
                      IMPORTING
                        e_tanum                      = lv_tanum
                      TABLES
                        t_lubqu                      = lt_lubqu
                        t_ltap_vb                    = lt_ltap_vb
                      EXCEPTIONS
                        foreign_lock                 = 1
                        tp_completed                 = 2
                        xfeld_wrong                  = 3
                        ldest_wrong                  = 4
                        drukz_wrong                  = 5
                        tp_wrong                     = 6
                        squit_forbidden              = 7
                        no_to_created                = 8
                        update_without_commit        = 9
                        no_authority                 = 10
                        i_ubnum_or_i_lubu            = 11
                        bwlvs_wrong                  = 12
                        material_not_found           = 13
                        manual_to_forbidden          = 14
                        bestq_wrong                  = 15
                        sobkz_missing                = 16
                        sobkz_wrong                  = 17
                        meins_wrong                  = 18
                        conversion_not_found         = 19
                        no_quants                    = 20
                        t_lubqu_required             = 21
                        le_bulk_quant_not_selectable = 22
                        quant_not_selectable         = 23
                        quantnumber_initial          = 24
                        kzuap_or_bin_location        = 25
                        date_wrong                   = 26
                        nltyp_missing                = 27
                        nlpla_missing                = 28
                        lgber_wrong                  = 29
                        lenum_wrong                  = 30
                        menge_wrong                  = 31
                        menge_to_big                 = 32
                        open_tr_kzuap                = 33
                        lock_exists                  = 34
                        double_quant                 = 35
                        quantity_wrong               = 36
                        OTHERS                       = 37.
  
                    IF sy-subrc IS INITIAL AND lv_tanum IS NOT INITIAL.
  
                      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION c_destination_n
                        EXPORTING
                          wait                  = abap_true
                        EXCEPTIONS
                          communication_failure = 1
                          system_failure        = 2
                          OTHERS                = 3.
  
                      IF sy-subrc IS NOT INITIAL.
  
                        MESSAGE TEXT-e17 TYPE zcon_msg_e.
  
                      ELSE.
  
                        " Update created TO number
                        READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_upd_to>)
                                                                           WITH KEY matnr = <lfs_mseg>-matnr
                                                                                    werks = <lfs_mseg>-werks
                                                                                    charg = <lfs_mseg>-charg
                                                                                   BINARY SEARCH.
  
  
                        IF sy-subrc IS INITIAL AND <lfs_upd_to> IS ASSIGNED.
                          <lfs_upd_to>-to_number  = lv_tanum.           " Assign TO number
                          CLEAR <lfs_upd_to>-msg.                       " clear old message
  
                          " append to local table for DB deletion
                          CLEAR ls_del_processed.
                          ls_del_processed-zstrnum   = lcl_data_manager=>gv_strshort.
                          ls_del_processed-sydate    = lcl_data_manager=>gv_date.
                          ls_del_processed-sytime    = lcl_data_manager=>gv_time.
                          ls_del_processed-material  = <lfs_upd_to>-matnr.
                          ls_del_processed-charg     = <lfs_upd_to>-charg.
                          ls_del_processed-bwart     = p_inv_m.
                          ls_del_processed-lgort     = <lfs_upd_to>-lgort.
                          APPEND ls_del_processed TO lt_del_processed.
                        ENDIF.
                      ENDIF.
  
                    ELSE.
  
                      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
                        EXCEPTIONS
                          communication_failure = 1
                          system_failure        = 2
                          OTHERS                = 3.
  
                      IF sy-subrc IS NOT INITIAL.
                        MESSAGE TEXT-e18 TYPE zcon_msg_e.
                      ENDIF.
  
                      CLEAR lv_message.
                      PERFORM f_bapi_e_message USING sy-msgty sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                                            CHANGING lv_message.
  
  
                      " Update TO creation failed message
                      READ TABLE lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_failed_to>)
                                                                         WITH KEY matnr = <lfs_mseg>-matnr
                                                                                  werks = <lfs_mseg>-werks
                                                                                  charg = <lfs_mseg>-charg
                                                                                 BINARY SEARCH.
  
                      IF sy-subrc IS INITIAL AND <lfs_failed_to> IS ASSIGNED.
                        <lfs_upd_to>-msg = lv_message.   " TO creation failed.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
  
      " Delete from custom table
      IF lt_del_processed[] IS NOT INITIAL.
        TRY.
            DELETE zmm_scanreel_str FROM TABLE lt_del_processed.
            IF sy-subrc IS INITIAL.
              COMMIT WORK.
              CLEAR lt_del_processed[].
            ENDIF.
  
          CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
            MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
          CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
            MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
        ENDTRY.
      ENDIF.
  
      CLEAR lr_ubnum[].
    ENDMETHOD.
  ENDCLASS.
  **---------------------------------------------
  ** Add new button in alv left (Source) tool bar
  **---------------------------------------------
  CLASS lcl_event_receiver IMPLEMENTATION.
  
    METHOD handle_toolbar_to_s.
      DATA: ls_toolbar  TYPE stb_button.
  
  **   APPEND A NEW BUTTON THAT TO THE TOOLBAR.
      CLEAR ls_toolbar.
      ls_toolbar-function    = c_p_tcd_mov.
      ls_toolbar-icon        = icon_next_object.
      ls_toolbar-quickinfo   = c_p_move_qi.
      ls_toolbar-text        = c_p_move_text.
  
      IF lcl_data_manager=>gv_mblnr_created IS NOT INITIAL.
        ls_toolbar-disabled  =  abap_true.
      ELSE.
        ls_toolbar-disabled  =  abap_false.
      ENDIF.
  
      APPEND ls_toolbar             TO e_object->mt_toolbar.
  *
    ENDMETHOD.                "HANDLE_TOOLBAR_TO_L
  **---------------------------------------------------
  ** Add new button in alv Right (destination) tool bar
  **---------------------------------------------------
    METHOD handle_toolbar_to_d.
  
      DATA:
          ls_toolbar  TYPE stb_button.
  
  *   APPEND A NEW BUTTON THAT TO THE TOOLBAR.
      CLEAR ls_toolbar.
      ls_toolbar-function  = c_p_tcs_mov.
      ls_toolbar-icon      = icon_previous_object.
      ls_toolbar-quickinfo = c_p_move_qi.
      ls_toolbar-text      = c_p_move_text.
  
      IF lcl_data_manager=>gv_mblnr_created IS NOT INITIAL.
        ls_toolbar-disabled  =  abap_true.
      ELSE.
        ls_toolbar-disabled  =  abap_false.
      ENDIF.
      APPEND ls_toolbar             TO e_object->mt_toolbar.
  
    ENDMETHOD.             "HANDLE_TOOLBAR_TO_R
  **------------------------------------------
  ** Handle User Command Left source conatiner
  **------------------------------------------
    METHOD handle_user_command_to_s.
  *   HANDLE OWN FUNCTIONS DEFINED IN THE TOOLBAR
      CASE e_ucomm.
        WHEN c_p_tcd_mov.
          CALL METHOD lcl_screen_manager=>move_selected_record_s( ).
      ENDCASE.
    ENDMETHOD.           "HANDLE_USER_COMMAND_TO_L
  **------------------------------------------
  ** Handle User Command Right dest conatiner
  **------------------------------------------
    METHOD handle_user_command_to_d.
  *   HANDLE OWN FUNCTIONS DEFINED IN THE TOOLBAR
      CASE e_ucomm.
        WHEN c_p_tcs_mov.
          CALL METHOD lcl_screen_manager=>move_selected_record_d( ).
      ENDCASE.
    ENDMETHOD.           "HANDLE_USER_COMMAND_TO_R
  ENDCLASS.