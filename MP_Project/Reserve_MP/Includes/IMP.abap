*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_IMP
*&---------------------------------------------------------------------*
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
    METHOD init_disable_fields.
  
      LOOP AT SCREEN.
        IF screen-name = 'GS_SELECTION-SLOC'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
  
        IF screen-name = 'GS_SELECTION-DLOC'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
  
        IF screen-name = 'GS_SELECTION-ZLGTYP_DEST'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
  
        IF screen-name = 'GS_SELECTION-BIN'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
  
        IF screen-name = 'MOVE_BUT_S'.
          IF gv_mblnr_created IS NOT INITIAL.
            screen-input = 0.
            MODIFY SCREEN.
          ELSE.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDMETHOD.
  *----------------------------------------------------------------------*
    METHOD init_grid_source.
  *-------------------------Local Variable -------------------------------
      DATA lo_source_dsp TYPE REF TO cl_gui_custom_container  . "Container for table.
  
      CONSTANTS: lc_gt_source TYPE slis_tabname VALUE 'GT_SOURCE',
                 lc_ctrl_name TYPE scrfname VALUE 'C_ALV_SOURCE'.
  *-------------------start of processing (Function body)---------------
  *--------------------------------------------------------------------*
      IF go_source_grid IS INITIAL.
  *--------------------------------------------------------------------*
  *---Create CONTAINER object with reference to container name in the screen
        CREATE OBJECT lo_source_dsp
          EXPORTING
            container_name = lc_ctrl_name.
  *    "*--------------------------------------------------------------------*
        CREATE OBJECT go_source_grid
          EXPORTING
            i_parent = lo_source_dsp.
        "*--------------------------------------------------------------------*
        CALL METHOD fields_catalog_source
          EXPORTING
            im_itab_tab     = gt_source
            im_tab_name     = lc_gt_source
          IMPORTING
            ex_tab_fieldcat = gt_fieldcat.
  
        CALL METHOD go_source_grid->set_table_for_first_display
          EXPORTING
            is_layout       = gs_layout
          CHANGING
            it_outtab       = gt_source
            it_fieldcatalog = gt_fieldcat.
        "*--------------------------------------------------------------------*
        CALL METHOD go_source_grid->refresh_table_display.
      ELSE.
        CALL METHOD go_source_grid->refresh_table_display.
      ENDIF.
  
    ENDMETHOD.
  *------------------------------------------
  *  Build Field Catalog for Display for Source
  *------------------------------------------
    METHOD fields_catalog_source.
  
  *     Selection mode
      gs_layout-box_fname = 'SEL_LINE'.
      gs_layout-sel_mode = 'A'.
  
  *    gs_fieldcat-fieldname = 'MATERIAL'.
      gs_fieldcat-fieldname = 'MATNR'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Material'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = 'WERKS'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Plant'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = 'LGORT'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Location'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = 'CHARG'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Batch'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
  *    gs_fieldcat-fieldname = 'LQNUM'.
      gs_fieldcat-fieldname = 'VERME'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Quantity'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
      gs_fieldcat-fieldname = 'MEINS'.
      gs_fieldcat-tabname   = 'GT_SOURCE'.
      gs_fieldcat-coltext = 'Unit'.
  
      APPEND gs_fieldcat TO gt_fieldcat.
      CLEAR: gs_fieldcat.
  
    ENDMETHOD.
  *------------------------------------------
  * init_grid_dest.
  *------------------------------------------
    METHOD init_grid_dest.
  
      DATA lo_dest_dsp TYPE REF TO cl_gui_custom_container  . "Container for table.
  
      CONSTANTS: lc_gt_dest   TYPE slis_tabname VALUE 'GT_DEST',
                 lc_ctrl_name TYPE scrfname VALUE 'C_ALV_DEST'.
  
  *-------------------start of processing (Function body)---------------
  *--------------------------------------------------------------------*
      IF go_dest_grid IS INITIAL.
  *--------------------------------------------------------------------*
  *---Create CONTAINER object with reference to container name in the screen
        CREATE OBJECT lo_dest_dsp
          EXPORTING
            container_name = lc_ctrl_name.
  *    "*--------------------------------------------------------------------*
        CREATE OBJECT go_dest_grid
          EXPORTING
            i_parent = lo_dest_dsp.
        "*--------------------------------------------------------------------*
        CALL METHOD fields_catalog_dest
          EXPORTING
            im_itab     = gt_dest
            im_tname    = lc_gt_dest
          IMPORTING
            ex_tab_fcat = gt_fcat.
  
        CALL METHOD go_dest_grid->set_table_for_first_display
          EXPORTING
            is_layout       = gs_layout
          CHANGING
            it_outtab       = gt_dest
            it_fieldcatalog = gt_fcat.
        "*--------------------------------------------------------------------*
        CALL METHOD go_dest_grid->refresh_table_display.
      ELSE.
        CALL METHOD go_dest_grid->refresh_table_display.
  
      ENDIF.
  
    ENDMETHOD.
  *------------------------------------------
  ** init_filter.
  **------------------------------------------
    METHOD init_filter.
  
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = 'GV_CHARG'
          values          = gt_charg_values
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.
  
    ENDMETHOD.
  *------------------------------------------
  *  Build Field Catalog for Display for Dest
  *------------------------------------------
    METHOD fields_catalog_dest.
  
      gs_layout-box_fname = 'SEL_LINE'.
      gs_layout-sel_mode = 'A'.
  
  *    gs_fcat-fieldname = 'MATNR'.
      gs_fcat-fieldname = 'MATERIAL'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Material'.
  
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'WERKS'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Plant'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'LGORT'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Location'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'CHARG'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Batch'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
  *    gs_fcat-fieldname = 'LQNUM'.
      gs_fcat-fieldname = 'VERME'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Quantity'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'MEINS'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Unit'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'TO_NUMBER'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'TO Number'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'POSTING_CHANGE'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Posting Change'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
      gs_fcat-fieldname = 'MSG'.
      gs_fcat-tabname   = 'GT_DEST'.
      gs_fcat-coltext = 'Message Text'.
      APPEND gs_fcat TO gt_fcat.
      CLEAR: gs_fcat.
  
    ENDMETHOD.
  ENDCLASS.
  
  CLASS lcl_screen_manager IMPLEMENTATION.
  *------------------------------------------
  * user_command_1001.
  *------------------------------------------
    METHOD user_command_1001.
      DATA: lv_okcode TYPE sy-ucomm,
            lv_subrc  TYPE syst_subrc.
  *-------------------start of processing (Function body)-----------------
      lv_okcode = sy-ucomm.
  *--------------------------------------------------------------------*
      CASE lv_okcode.
  *--------------------------------------------------------------------*
        WHEN c_fct_back.
          LEAVE TO SCREEN 0.
  *--------------------------------------------------------------------*
        WHEN c_fct_exit OR c_fct_cancel.
          LEAVE TO SCREEN 0.
  *--------------------------------------------------------------------*
        WHEN 'TCS_MOVE'.
          lcl_screen_manager=>move_selected_record_s( ).
  *--------------------------------------------------------------------*
        WHEN 'TCD_MOVE'.
          lcl_screen_manager=>move_selected_record_d( ).
  *--------------------------------------------------------------------*
  
        WHEN 'FC_BATCH'. " Assuming 'FILTER' is the function code for a button that applies the filter
          PERFORM filter_container_data.
  *--------------------------------------------------------------------*
        WHEN 'PROCESS'.
  
          IF gv_mblnr_created EQ c_true. " MBLNR already created, user is re-trying for TO creation
  
            lcl_screen_manager=>bapi_to_for_posting_change( ).
  
          ELSE.
  
            " Fresh MBLNR creation followed by TO creation.
            lcl_screen_manager=>bapi_posting_material_doc( ).
            IF gv_mblnr IS NOT INITIAL.
              lcl_screen_manager=>bapi_to_for_posting_change( ).
            ENDIF.
  
          ENDIF.
      ENDCASE.
  *--------------------------------------------------------------------*
    ENDMETHOD.                    "LEAVE_SCREEN
  *------------------------------------------
  * move_selected_record_S.
  *------------------------------------------
    METHOD move_selected_record_s.
  
      DATA: lt_row_selected TYPE lvc_t_row,  " To hold selected rows
            ls_row_selected TYPE lvc_s_row,  " To hold individual selected row
            lv_index        TYPE sy-tabix.   " Index for selected rows
  
  *-------------------start of processing-----------------
  
  * Get selected rows from the left container (DEST)
      CALL METHOD go_source_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row_selected.
  
  * Loop through selected rows and move them
      LOOP AT lt_row_selected INTO ls_row_selected.
        lv_index = ls_row_selected-index.
  
  * Read the selected row from gt_dest based on the index
        READ TABLE gt_source INTO gs_source INDEX lv_index.
        IF sy-subrc = 0.
  
          gs_dest-material        =   gs_source-matnr.
          gs_dest-werks           =   gs_source-werks.
          gs_dest-lgort           =   gs_source-lgort.
          gs_dest-charg           =   gs_source-charg.
          gs_dest-verme           =   gs_source-verme.
          gs_dest-lqnum           =   gs_source-lqnum.
          gs_dest-lgnum           =   gs_source-lgnum.
          gs_dest-timestamp       =   gs_source-letyp.
          gs_dest-meins           =   gs_source-meins.
          gs_dest-ins_flag        =   c_true.
          APPEND gs_dest TO gt_dest.
          CLEAR gs_dest.
  
          gs_source-del_flag = c_true.
          MODIFY gt_source FROM gs_source INDEX lv_index.
        ENDIF.
      ENDLOOP.
  
      SORT gt_dest BY charg DESCENDING.
  
      DELETE gt_source WHERE del_flag = 'X'.
  
      LOOP AT gt_dest INTO gs_dest WHERE ins_flag = c_true.
  
        IF gv_oldstr = c_true.
  
          gs_zmm_scanreel_str-zstrnum         = gv_orig_strs.
          gs_zmm_scanreel_str-sydate          = gv_orig_date.
          gs_zmm_scanreel_str-sytime          = gv_orig_time.
          gs_zmm_scanreel_str-syuser          = gv_orig_uname.
          gs_zmm_scanreel_str-material        = gs_dest-material.
          gs_zmm_scanreel_str-werks           = gs_dest-werks.
          gs_zmm_scanreel_str-lgort           = gs_dest-lgort.
          gs_zmm_scanreel_str-charg           = gs_dest-charg.
          gs_zmm_scanreel_str-menge           = gs_dest-verme.
          gs_zmm_scanreel_str-meins           = gs_dest-meins.
          gs_zmm_scanreel_str-timestamp       = gs_dest-timestamp.
          gs_zmm_scanreel_str-zlgtyp_source   = p_sloc_t.
          gs_zmm_scanreel_str-bwart           = p_inv_m.
          gs_zmm_scanreel_str-zlgort_dest     = p_dloc.
          gs_zmm_scanreel_str-zlgtyp_dest     = p_zlgtyp .
          gs_zmm_scanreel_str-strlong         = gv_orig_strl.
  
          WRITE gs_dest-verme TO gv_menge.
          CONDENSE gv_menge.
          CONCATENATE gs_zmm_scanreel_str-material c_sep_ch c_l_ch gs_zmm_scanreel_str-charg c_sep_ch c_q_ch gv_menge c_sep_ch gs_zmm_scanreel_str-timestamp INTO gs_zmm_scanreel_str-lngstr.
          INSERT INTO zmm_scanreel_str VALUES  gs_zmm_scanreel_str.
          CLEAR gs_zmm_scanreel_str.
  
        ELSE.
          gs_zmm_scanreel_str-zstrnum         = gv_zstrnum.
          gs_zmm_scanreel_str-sydate          = gv_date.
          gs_zmm_scanreel_str-sytime          = gv_time.
          gs_zmm_scanreel_str-syuser          = sy-uname.
          gs_zmm_scanreel_str-material        = gs_dest-material.
          gs_zmm_scanreel_str-werks           = gs_dest-werks.
          gs_zmm_scanreel_str-lgort           = gs_dest-lgort.
          gs_zmm_scanreel_str-charg           = gs_dest-charg.
          gs_zmm_scanreel_str-menge           = gs_dest-verme.
          gs_zmm_scanreel_str-meins           = gs_dest-meins.
          gs_zmm_scanreel_str-timestamp       = gs_dest-timestamp.
          gs_zmm_scanreel_str-zlgtyp_source   = p_sloc_t.
          gs_zmm_scanreel_str-bwart           = p_inv_m.
          gs_zmm_scanreel_str-zlgort_dest     = p_dloc.
          gs_zmm_scanreel_str-zlgtyp_dest     = p_zlgtyp .
          gs_zmm_scanreel_str-strlong         = gv_strlong.
  
          WRITE gs_dest-verme TO gv_menge.
          CONDENSE gv_menge.
          CONCATENATE gs_zmm_scanreel_str-material c_sep_ch c_l_ch gs_zmm_scanreel_str-charg c_sep_ch c_q_ch gv_menge c_sep_ch gs_zmm_scanreel_str-timestamp INTO gs_zmm_scanreel_str-lngstr.
          INSERT INTO zmm_scanreel_str VALUES  gs_zmm_scanreel_str.
          CLEAR gs_zmm_scanreel_str.
  
        ENDIF.
  
  
      ENDLOOP.
      COMMIT WORK.
  *  * Refresh destination grids
      CALL METHOD go_source_grid->refresh_table_display.
    ENDMETHOD.
  **------------------------------------------
  ** move_selected_record_D.
  **------------------------------------------
    METHOD move_selected_record_d.
  
      DATA: lt_row_selected TYPE lvc_t_row,  " To hold selected rows
            ls_row_selected TYPE lvc_s_row,  " To hold individual selected row
            lv_index        TYPE sy-tabix.   " Index for selected rows
  
      DATA: lt_zmm_scanreel_str TYPE STANDARD TABLE OF zmm_scanreel_str,
            ls_zmm_scanreel_str TYPE zmm_scanreel_str.
  
  *-------------------start of processing-----------------
  
  * Get selected rows from the left container (DEST)
      CALL METHOD go_dest_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row_selected.
  
  * Loop through selected rows and move them
      LOOP AT lt_row_selected INTO ls_row_selected.
  
        lv_index = ls_row_selected-index.
  
  * Read the selected row from gt_dest based on the index
        READ TABLE gt_dest INTO gs_dest INDEX lv_index.
        IF sy-subrc = 0.
  
          gs_source-matnr =   gs_dest-material.
          gs_source-werks =   gs_dest-werks.
          gs_source-lgort =   gs_dest-lgort.
          gs_source-charg =   gs_dest-charg.
          gs_source-verme =   gs_dest-verme.
          gs_source-lqnum =   gs_dest-lqnum.
  *        gs_dest-menge =   gs_source-menge.
          gs_source-meins =   gs_dest-meins.
          APPEND gs_source TO gt_source.
          CLEAR gs_source.
  
          SORT gt_source BY charg DESCENDING.  " by charg meins
  
          gs_dest-del_flag = 'X'.
          MODIFY gt_dest FROM gs_dest INDEX lv_index.
        ENDIF.
      ENDLOOP.
  
      LOOP AT gt_dest INTO gs_dest WHERE del_flag = c_true.
  
        CLEAR ls_zmm_scanreel_str.
  
        IF gv_oldstr = c_true.
  
          DELETE FROM zmm_scanreel_str WHERE zstrnum  EQ gv_orig_strs
                                         AND syuser   EQ gv_orig_uname
                                         AND material EQ gs_dest-material
                                         AND werks    EQ gs_dest-werks
                                         AND lgort    EQ gs_dest-lgort
                                         AND charg    EQ gs_dest-charg.
        ELSE.
  
          DELETE FROM zmm_scanreel_str WHERE zstrnum  EQ gv_zstrnum
                                         AND syuser   EQ sy-uname
                                         AND material EQ gs_dest-material
                                         AND werks    EQ gs_dest-werks
                                         AND lgort    EQ gs_dest-lgort
                                         AND charg    EQ gs_dest-charg.
  
        ENDIF.
  
      ENDLOOP.
  
  
      COMMIT WORK.
  
      DELETE gt_dest WHERE del_flag = 'X'.
  
  *  * Refresh destination grids
      CALL METHOD go_dest_grid->refresh_table_display.
  
    ENDMETHOD.
  *------------------------------------------
  ** Bapi_posting_material_doc.
  **------------------------------------------
    METHOD bapi_posting_material_doc.
  
      DATA: lv_message TYPE string.
      DATA: lt_gm_header TYPE STANDARD TABLE OF  bapi2017_gm_head_01,
            ls_gm_header TYPE bapi2017_gm_head_01,
            lt_gm_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create,
            ls_gm_item   TYPE bapi2017_gm_item_create,
            lt_gm_return TYPE STANDARD TABLE OF bapiret2,
            ls_gm_return TYPE bapiret2,
            ls_gmvt_code TYPE bapi2017_gm_code. ##NEEDED
  
  
      ls_gm_header-header_txt = gs_selection-bin.     " STR Number from destination
      ls_gm_header-doc_date   = sy-datum.             " Current date
      ls_gm_header-pstng_date = sy-datum.             " Posting date
      ls_gmvt_code-gm_code    = c_gmcode.             " Gm Code
  
      LOOP AT gt_dest INTO gs_dest.
        ls_gm_item-material   = gs_dest-material.
        ls_gm_item-plant      = p_werks.
        ls_gm_item-stge_loc   = gs_dest-lgort.
        ls_gm_item-batch      = gs_dest-charg.
        ls_gm_item-move_stloc = p_dloc.
        ls_gm_item-move_batch = gs_dest-charg.
        ls_gm_item-move_plant = p_werks.
        ls_gm_item-move_type  = p_inv_m.
  *      gs_gm_item-move_type  = p_inv_m.
        ls_gm_item-entry_qnt  = gs_dest-verme.
        ls_gm_item-entry_uom  = gs_dest-meins.
        APPEND  ls_gm_item TO lt_gm_item.
        CLEAR: ls_gm_item.
      ENDLOOP.
  
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_gm_header
          goodsmvt_code    = c_gmcode
        IMPORTING
          materialdocument = gv_mblnr
        TABLES
          goodsmvt_item    = lt_gm_item
          return           = lt_gm_return.
  
      READ TABLE lt_gm_return ASSIGNING FIELD-SYMBOL(<lfs_return>) WITH KEY type = c_type_e.
      IF sy-subrc EQ 0.
  
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  
  *  Check if there are any errors in the return table
        LOOP AT lt_gm_return INTO ls_gm_return.
          IF ls_gm_return-type = 'E'.
            " Handle the error message.
            LOOP AT gt_dest INTO gs_dest.
              gs_dest-msg = ls_gm_return-message.           " Assign the message to the ALV field
              MODIFY gt_dest FROM gs_dest TRANSPORTING msg. " Update the internal table
            ENDLOOP.
            EXIT.
          ELSE.
          ENDIF.
        ENDLOOP.
      ELSE.
        " If no errors, commit the transaction
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
  
      IF gv_mblnr IS NOT INITIAL.
  
        LOOP AT gt_dest INTO gs_dest.
  *      CLEAR: gs_zmm_scanreel_str.
          MOVE-CORRESPONDING: gs_dest TO gs_zmm_scanreel_str.
          gs_zmm_scanreel_str-zstrnum         = gv_zstrnum.
          gs_zmm_scanreel_str-sydate          = gv_date.
          gs_zmm_scanreel_str-sytime          = gv_time.
          gs_zmm_scanreel_str-syuser          = sy-uname.
          gs_zmm_scanreel_str-material        = gs_dest-material.
          gs_zmm_scanreel_str-werks           = gs_dest-werks.
          gs_zmm_scanreel_str-lgort           = gs_dest-lgort.
          gs_zmm_scanreel_str-charg           = gs_dest-charg.
          gs_zmm_scanreel_str-menge           = gs_dest-verme.
          gs_zmm_scanreel_str-meins           = gs_dest-meins.
          gs_zmm_scanreel_str-timestamp       = gs_dest-timestamp.
          gs_zmm_scanreel_str-zlgtyp_source   = p_sloc_t.
          gs_zmm_scanreel_str-bwart           = p_inv_m.
          gs_zmm_scanreel_str-zlgort_dest     = p_dloc.
          gs_zmm_scanreel_str-zlgtyp_dest     = p_zlgtyp .
          gs_zmm_scanreel_str-strlong         = gv_strlong.
          gs_zmm_scanreel_str-mblnr           = gv_mblnr.
          APPEND gs_zmm_scanreel_str TO gt_zmm_scanreel_str.
        ENDLOOP.
  *    WRITE gs_dest-verme TO gv_menge.
  *    CONDENSE gv_menge.
  *    CONCATENATE gs_zmm_scanreel_str-material c_sep_ch c_l_ch gs_zmm_scanreel_str-charg c_sep_ch c_q_ch gv_menge c_sep_ch gs_zmm_scanreel_str-timestamp INTO gs_zmm_scanreel_str-lngstr.
        MODIFY zmm_scanreel_str FROM TABLE gt_zmm_scanreel_str.
        COMMIT WORK.
  *    ENDLOOP.
  
        lv_message = |Material document { gv_mblnr } is created.|.
  
        MESSAGE lv_message TYPE 'I'.
  
      ENDIF.
  
    ENDMETHOD.
  **------------------------------------------
  ** Bapi_posting_material_doc.
  **------------------------------------------
    METHOD bapi_to_for_posting_change.
  
      DATA: wa_lagp TYPE lagp.
  
      DATA: lt_lubqu   TYPE STANDARD TABLE OF lubqu,   " Table for quants
            ls_lubqu   TYPE lubqu,                     " Structure for quant
            lt_ltap_vb TYPE STANDARD TABLE OF ltap_vb, " Table for transfer items
            ls_ltap_vb TYPE ltap_vb.                   " Structure for transfer item
  
      CONSTANTS: lc_lptyp TYPE lvs_lptyp  VALUE '01',
                 lc_lkapv TYPE lagp_lkapv VALUE 1000000.
  
      IF gv_mblnr IS NOT INITIAL.
  
        " Get all posting change doc numbers for given MBLNR
        SELECT mblnr, matnr, werks, lgort, charg, ubnum
        FROM mseg
        INTO TABLE @DATA(lt_mseg)
        WHERE mblnr = @gv_mblnr
        AND bwart = @p_inv_m.
  
        IF lt_mseg IS NOT INITIAL.
  
          " Check the existance of Destination Storage Bin to be used
          SELECT COUNT(*)
            FROM lagp
            INTO @DATA(lv_count)
          WHERE lgnum = @gv_lgnum
            AND lgtyp = @p_zlgtyp
            AND lgpla = @gv_zstrnum.
  
          IF sy-subrc NE 0. " Destination Storage Bin does not exist, create a new one
  
            CLEAR wa_lagp.
            wa_lagp-lgnum = gv_lgnum.
            wa_lagp-lgtyp = p_zlgtyp.
            wa_lagp-lgpla = gv_zstrnum.
            wa_lagp-lptyp = lc_lptyp.
            wa_lagp-lkapv = lc_lkapv.
  
            CALL FUNCTION 'L_LAGP_HINZUFUEGEN'
              EXPORTING
                xlagp         = wa_lagp
              EXCEPTIONS
                error_message = 99.
  
            IF sy-subrc NE 0. " Destination Storage Bin Creation failed.
  
              LOOP AT gt_dest INTO gs_dest.
                READ TABLE lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg>) WITH KEY matnr = gs_dest-matnr
                                                                               werks = gs_dest-werks
                                                                               charg = gs_dest-charg.
                IF sy-subrc EQ 0.
                  gs_dest-posting_change = <lfs_mseg>-ubnum.  " Assign Posting Change number
                ENDIF.
                gs_dest-msg            = 'Error occured while creating Destination Sotrage Bin.'.
                MODIFY gt_dest FROM gs_dest TRANSPORTING to_number posting_change.
              ENDLOOP.
              RETURN.
  
            ELSE. " Destination Storage Bin created successfully.
  
              LOOP AT lt_mseg ASSIGNING <lfs_mseg>. "gv_ubnum. " Fetch each posting change number
  
                REFRESH: lt_lubqu, lt_ltap_vb.
                CLEAR: ls_lubqu, ls_ltap_vb, gv_tanum.
  
                LOOP AT gt_source_all INTO DATA(gs_source) WHERE matnr = <lfs_mseg>-matnr AND
                                                                 werks = <lfs_mseg>-werks AND
                                                                 charg = <lfs_mseg>-charg.
                  " Fill T_LUBQU table for quant information
                  ls_lubqu-lqnum = gs_source-lqnum.    " Quant number
                  ls_lubqu-menge = gs_source-verme.    " Available quantity
                  APPEND ls_lubqu TO lt_lubqu.
  
                  " Fill T_LTAP_VB table for transfer items
                  ls_ltap_vb-matnr = gs_source-matnr.  " Material number
                  ls_ltap_vb-werks = gs_source-werks.  " Plant
                  ls_ltap_vb-charg = gs_source-charg.  " Batch
                  ls_ltap_vb-nlpla = gv_zstrnum.       " Destination Storage Bin
                  APPEND ls_ltap_vb TO lt_ltap_vb.
                ENDLOOP.
  
                " Call BAPI for creating TO
                CALL FUNCTION 'L_TO_CREATE_POSTING_CHANGE'
                  EXPORTING
                    i_lgnum                      = gv_lgnum
                    i_ubnum                      = <lfs_mseg>-ubnum
                    i_squit                      = 'X'
                    i_nidru                      = 'X'
                    i_update_task                = 'X'
                    i_commit_work                = 'X'
                    i_bname                      = sy-uname
                  IMPORTING
                    e_tanum                      = gv_tanum
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
  
                IF sy-subrc NE 0.
  
                  READ TABLE gt_dest INTO gs_dest WITH KEY  matnr = <lfs_mseg>-matnr
                                                              werks = <lfs_mseg>-werks
                                                              charg = <lfs_mseg>-charg.
                  IF sy-subrc EQ 0.
  *                gs_dest-to_number      = gv_tanum.           " Assign TO number
                    gs_dest-posting_change = <lfs_mseg>-ubnum.  " Assign Posting Change number
                    gs_dest-msg            = 'Error occured while posting Transfer Order.'.
                    MODIFY gt_dest FROM gs_dest TRANSPORTING to_number posting_change.
                  ENDIF.
  
                ELSE.
                  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                    EXPORTING
                      wait = 'X'.
  
                  IF gv_tanum IS NOT INITIAL.
  
  
                    READ TABLE gt_dest INTO gs_dest WITH KEY  matnr = <lfs_mseg>-matnr
                                                              werks = <lfs_mseg>-werks
                                                              charg = <lfs_mseg>-charg.
                    IF sy-subrc EQ 0.
                      gs_dest-to_number      = gv_tanum.           " Assign TO number
                      gs_dest-posting_change = <lfs_mseg>-ubnum.  " Assign Posting Change number
                      MODIFY gt_dest FROM gs_dest TRANSPORTING to_number posting_change.
                    ENDIF.
  
                    DELETE FROM zmm_scanreel_str WHERE zstrnum  = gv_zstrnum AND
                                                       material = <lfs_mseg>-matnr AND
                                                          werks = <lfs_mseg>-werks AND
                                                          charg = <lfs_mseg>-charg .
                    IF sy-subrc EQ 0.
                      COMMIT WORK.
                    ENDIF.
  
                  ENDIF.
                ENDIF.
  
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMETHOD.
  ENDCLASS.