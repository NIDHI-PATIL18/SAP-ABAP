*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTR_IMP
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
*                CLASS LCL_DATA_MANAGER IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_data_manager IMPLEMENTATION.

    METHOD initialize_screen_1001.
  
      gs_selection-werks  =  p_werks.     " Plant
      gs_selection-lgorts =  p_lgorts.    " Source Storage Location
      gs_selection-strn   =  p_strn.      " STR Number
      gs_selection-lgpla  =  p_lgpla.     " Destination Bin
      gs_selection-lgortd =  p_lgortd.    " Dest Storage Location
      gs_selection-mov_wm =  p_mov_wm.    " Warehouse management movement
      gs_selection-mov_in =  p_mov_in.    " Inventory Movement for Transfer
      gs_selection-mov_co =  p_mov_co.    " Consumption movement
      gs_selection-mov_sc =  p_mov_sc.    " Scrap movement
  
    ENDMETHOD.
  
    METHOD ini_clear_data.
  
      CLEAR: gt_tc_return[],
             lcl_data_manager=>gt_scanreel,
             gs_tc_return,
             gs_selection,
             lcl_data_manager=>gv_answer,
             lcl_data_manager=>gv_failed,
             lcl_data_manager=>gv_lgnum,
             lcl_data_manager=>gv_crsr_fld,
             lcl_data_manager=>gv_crsr_line,
             gv_tot_consu,
             gv_tot_count,
             gv_tot_new,
             gv_tot_scrap.
  
    ENDMETHOD.
  
    METHOD validate_before_call_bapi.
  
      gv_proceed = abap_true.
  
      IF gv_tot_consu IS INITIAL AND
         gv_tot_scrap IS INITIAL.
  
        CLEAR gv_proceed.
  
      ENDIF.
  
    ENDMETHOD.
  
    METHOD confirm_action.
  
      " Pop-up message to Confirm action.
      CLEAR gv_answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = TEXT-l01   " Confirmation
          text_question  = TEXT-m01   " Do you want to proceed with Consumption, Scap and New Count posting ?
          text_button_1  = TEXT-m02   " Yes
          text_button_2  = TEXT-m03   " No
        IMPORTING
          answer         = gv_answer  " User answer
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
  
      IF sy-subrc IS NOT INITIAL.
        MESSAGE ID sy-msgid
              TYPE sy-msgty
            NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
  
    ENDMETHOD.
  
    METHOD call_bapi.
  
      " Call BAPI
      CLEAR: et_return[],
             ev_mat_doc.
  
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE' DESTINATION c_destination_n "#EC CI_USAGE_OK[2438131]
        EXPORTING
          goodsmvt_header       = es_bapi_header
          goodsmvt_code         = ev_goodsmvt_code
          testrun               = ev_testrun
        IMPORTING
          materialdocument      = ev_mat_doc
          matdocumentyear       = ev_matdoc_year
        TABLES
          goodsmvt_item         = et_goodsmvt_item[]
          return                = et_return[]
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
  
      IF sy-subrc IS NOT INITIAL.
        MESSAGE TEXT-e16 TYPE zcon_msg_e.
      ENDIF.
  
    ENDMETHOD.
  *--------------------------------------------------------------------
  * Create Material document for Consumption, Scrap, Ncount, Pcount
  *--------------------------------------------------------------------
    METHOD process_data.
  
      DATA: ls_header      TYPE bapi2017_gm_head_01,
            lt_items       TYPE STANDARD TABLE OF bapi2017_gm_item_create,
            lt_return      TYPE STANDARD TABLE OF bapiret2,
            lv_matdoc      TYPE mblnr,
            lv_gjahr       TYPE gjahr,
            lv_error_msg   TYPE bapi_msg,
            lv_part_failed TYPE c LENGTH 1.
  
      DATA: lt_unique TYPE TABLE OF tc_return_s_type,
            lt_total  TYPE TABLE OF total_s_type.
  
      CLEAR: ev_matdoc_created,
             ev_to_created.
  
      READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_logs>) INDEX c_index1. "#EC CI_NOORDER
      IF sy-subrc IS INITIAL AND <lfs_logs> IS ASSIGNED.
        IF iv_ident = c_consum AND <lfs_logs>-mblnr_consume IS NOT INITIAL.
          DATA(lv_skip_matdoc) = abap_true.
          lv_matdoc = <lfs_logs>-mblnr_consume.
          ev_matdoc_created = abap_true.
        ELSEIF iv_ident = c_scrap AND <lfs_logs>-mblnr_scrap IS NOT INITIAL.
          lv_skip_matdoc = abap_true.
          lv_matdoc = <lfs_logs>-mblnr_scrap.
          ev_matdoc_created = abap_true.
        ELSEIF iv_ident = c_ncount AND <lfs_logs>-mblnr_ncount IS NOT INITIAL.
          lv_skip_matdoc = abap_true.
          lv_matdoc = <lfs_logs>-mblnr_ncount.
          ev_matdoc_created = abap_true.
        ELSEIF iv_ident = c_pcount AND <lfs_logs>-mblnr_pcount IS NOT INITIAL.
          lv_skip_matdoc = abap_true.
          lv_matdoc = <lfs_logs>-mblnr_pcount.
          ev_matdoc_created = abap_true.
        ENDIF.
      ENDIF.
  
      IF lv_skip_matdoc = abap_false.
        ls_header-header_txt = lcl_data_manager=>gv_strlong.
        ls_header-pstng_date = sy-datum.
        ls_header-doc_date   = sy-datum.
  
        lt_unique = VALUE #(
                            FOR GROUPS <group> OF <line> IN gt_tc_return
                                GROUP BY ( charg = <line>-charg
                                           matnr = <line>-matnr
                                           meins = <line>-meins )  " Correctly group by charg
                                         ( charg = <group>-charg
                                           matnr = <group>-matnr
                                           meins = <group>-meins )  " Create the unique entries in the result table
                                          ).
  
        IF sy-subrc IS INITIAL.
          lt_total = VALUE #( FOR ls_it_unique IN lt_unique
                              LET lv_batch_name = ls_it_unique-charg IN
                              ( charg  = lv_batch_name
                                pcount = REDUCE lqua_verme( INIT total = c_num0
                                         FOR <lfs_tc_return> IN gt_tc_return
                                             WHERE ( charg = lv_batch_name AND matnr = ls_it_unique-matnr )
                                             NEXT total = total + <lfs_tc_return>-pcount )
                                consum = REDUCE lqua_verme( INIT total = c_num0
                                         FOR <lfs_tc_return> IN gt_tc_return
                                             WHERE ( charg = lv_batch_name AND matnr = ls_it_unique-matnr )
                                             NEXT total = total + <lfs_tc_return>-consum )
                                scrap  = REDUCE lqua_verme( INIT total = c_num0
                                         FOR <lfs_tc_return> IN gt_tc_return
                                             WHERE ( charg = lv_batch_name AND matnr = ls_it_unique-matnr )
                                             NEXT total = total + <lfs_tc_return>-scrap )
                                ncount = REDUCE lqua_verme( INIT total = c_num0
                                         FOR <lfs_tc_return> IN gt_tc_return
                                             WHERE ( charg = lv_batch_name AND matnr = ls_it_unique-matnr )
                                             NEXT total = total + <lfs_tc_return>-ncount )
                                matnr = ls_it_unique-matnr
                                meins = ls_it_unique-meins )
                           ).
        ENDIF.
  
        " Prepare Items
        LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<lfs_total>).
          IF <lfs_total> IS ASSIGNED.
            IF iv_ident = c_pcount AND <lfs_total>-pcount IS INITIAL.
              CONTINUE.
            ELSEIF iv_ident = c_consum AND <lfs_total>-consum IS INITIAL.
              CONTINUE.
            ELSEIF iv_ident = c_scrap AND <lfs_total>-scrap IS INITIAL.
              CONTINUE.
            ELSEIF iv_ident = c_ncount AND <lfs_total>-ncount IS INITIAL.
              CONTINUE.
            ENDIF.
  
            APPEND INITIAL LINE TO lt_items ASSIGNING FIELD-SYMBOL(<lfs_items>).
            IF <lfs_items> IS ASSIGNED.
              <lfs_items>-material       = <lfs_total>-matnr .    " Material
              <lfs_items>-material_long  = <lfs_total>-matnr.     " Material
              <lfs_items>-plant          = p_werks.               " Plant
              <lfs_items>-stge_loc       = p_lgorts.              " LGORT (selection field on Select Section)
              <lfs_items>-batch          = <lfs_total>-charg.     " Batch
              <lfs_items>-move_stloc     = p_lgortd.
              IF iv_ident = c_pcount.
                <lfs_items>-entry_qnt    = <lfs_total>-pcount.
                <lfs_items>-po_pr_qnt    = <lfs_total>-pcount.
                <lfs_items>-move_type    = p_mov_in.              " 311 - New Count movement
                <lfs_items>-entry_uom    = <lfs_total>-meins.     " UOM
                <lfs_items>-spec_mvmt    = c_bsskz.
              ELSEIF iv_ident = c_consum.
                <lfs_items>-entry_qnt    = <lfs_total>-consum.
                <lfs_items>-po_pr_qnt    = <lfs_total>-consum.
                <lfs_items>-move_type    = p_mov_co.              " 201- Consumption movement
                <lfs_items>-entry_uom    = <lfs_total>-meins.     " UOM
                <lfs_items>-costcenter   = p_kostl.               " Cost Center (selection field on Select Section)
                <lfs_items>-move_reas    = p_reas_m.              " Movement Reason (selection field on Select Section)
                <lfs_items>-spec_mvmt    = c_bsskz.               " Special Movement Indicator - C
              ELSEIF iv_ident = c_scrap.
                <lfs_items>-entry_qnt      = <lfs_total>-scrap.
                <lfs_items>-po_pr_qnt      = <lfs_total>-scrap.
                <lfs_items>-move_type      = p_mov_sc.            " 92G - Scrap movement
                <lfs_items>-entry_uom      = <lfs_total>-meins.   " UOM
                <lfs_items>-costcenter     = p_kostl.
                <lfs_items>-spec_mvmt      = c_bsskz.
              ELSEIF iv_ident = c_ncount.
                <lfs_items>-entry_qnt      = <lfs_total>-ncount.
                <lfs_items>-po_pr_qnt      = <lfs_total>-ncount.
                <lfs_items>-move_type      = p_mov_in.            " 311 - New Count movement
                <lfs_items>-entry_uom      = <lfs_total>-meins.   " UOM
                <lfs_items>-spec_mvmt      = c_bsskz.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
  
        SORT lt_items.
        DELETE ADJACENT DUPLICATES FROM lt_items COMPARING batch.
  
        IF lt_items IS NOT INITIAL.
  
          " Test Run before Actual Run
          IF iv_ident = c_pcount OR
             iv_ident = c_ncount.
            lcl_data_manager=>call_bapi(
              EXPORTING
                es_bapi_header   = ls_header
                ev_goodsmvt_code = c_gm_code_04
                ev_testrun       = abap_true
              CHANGING
                ev_mat_doc       = lv_matdoc
                ev_matdoc_year   = lv_gjahr
                et_goodsmvt_item = lt_items[]
                et_return        = lt_return[]
            ).
  
            IF lt_return[] IS INITIAL.
              " Actual Run
              lcl_data_manager=>call_bapi(
                EXPORTING
                  es_bapi_header   = ls_header
                  ev_goodsmvt_code = c_gm_code_04
                CHANGING
                  ev_mat_doc       = lv_matdoc
                  ev_matdoc_year   = lv_gjahr
                  et_goodsmvt_item = lt_items[]
                  et_return        = lt_return[]
              ).
            ENDIF.
          ELSEIF iv_ident = c_consum.    " Consum Document
            CLEAR lv_matdoc.
            lcl_data_manager=>call_bapi(
              EXPORTING
                es_bapi_header   = ls_header
                ev_goodsmvt_code = c_gm_code_03
                ev_testrun       = abap_true
             CHANGING
               ev_mat_doc       = lv_matdoc
               ev_matdoc_year   = lv_gjahr
               et_goodsmvt_item = lt_items[]
               et_return        = lt_return[]
               ).
  
  
            IF lt_return[] IS INITIAL.
  
              " Actual Run
              lcl_data_manager=>call_bapi(
                EXPORTING
                  es_bapi_header   = ls_header
                  ev_goodsmvt_code = c_gm_code_03
                CHANGING
                  ev_mat_doc       = lv_matdoc
                  ev_matdoc_year   = lv_gjahr
                  et_goodsmvt_item = lt_items[]
                  et_return        = lt_return[]
              ).
            ENDIF.
          ELSEIF iv_ident = c_scrap.   "Scrap Document
            lcl_data_manager=>call_bapi(
              EXPORTING
                es_bapi_header   = ls_header
                ev_goodsmvt_code = c_gm_code_03
                ev_testrun       = abap_true
             CHANGING
               ev_mat_doc       = lv_matdoc
               ev_matdoc_year   = lv_gjahr
               et_goodsmvt_item = lt_items[]
               et_return        = lt_return[]
               ).
  
  
            IF lt_return[] IS INITIAL.
  
              " Actual Run
              lcl_data_manager=>call_bapi(
                EXPORTING
                  es_bapi_header   = ls_header
                  ev_goodsmvt_code = c_gm_code_03
                CHANGING
                  ev_mat_doc       = lv_matdoc
                  ev_matdoc_year   = lv_gjahr
                  et_goodsmvt_item = lt_items[]
                  et_return        = lt_return[]
              ).
            ENDIF.
          ENDIF.
  
          IF lv_matdoc IS NOT INITIAL.
  
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION c_destination_n
              EXPORTING
                wait                  = abap_true
              EXCEPTIONS
                communication_failure = 1
                system_failure        = 2
                OTHERS                = 3.
  
            IF sy-subrc IS INITIAL.
              " Update Log
              LOOP AT lt_unique ASSIGNING FIELD-SYMBOL(<lfs_unique>).
                IF <lfs_unique> IS ASSIGNED.
  
                  LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return1>) WHERE matnr = <lfs_unique>-matnr
                                                                             AND charg = <lfs_unique>-charg.
  
                    IF <lfs_return1> IS ASSIGNED.
                      IF iv_ident = c_consum AND <lfs_return1>-consum IS NOT INITIAL.
                        IF <lfs_return1>-log IS INITIAL.
                          <lfs_return1>-log = TEXT-m04.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m05 } { lv_matdoc } |.
                        ELSE.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m05 } { lv_matdoc } |.
                        ENDIF.
                        CONTINUE.
                      ELSEIF iv_ident = c_scrap AND <lfs_return1>-scrap IS NOT  INITIAL.
                        IF <lfs_return1>-log IS INITIAL.
                          <lfs_return1>-log = TEXT-m04.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m06 } { lv_matdoc } |.
                        ELSE.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m06 } { lv_matdoc } |.
                        ENDIF.
                        CONTINUE.
                      ELSEIF iv_ident = c_ncount AND <lfs_return1>-ncount IS NOT INITIAL.
                        IF <lfs_return1>-log IS INITIAL.
                          <lfs_return1>-log = TEXT-m04.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m07 } { lv_matdoc } |.
                        ELSE.
                          <lfs_return1>-log = |{ <lfs_return1>-log }  { TEXT-m07 } { lv_matdoc } |.
                        ENDIF.
                        CONTINUE.
                      ENDIF.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ELSE.
  
            " Rollback and Update Log
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
              EXCEPTIONS
                communication_failure = 1
                system_failure        = 2
                OTHERS                = 3.
  
            IF sy-subrc IS NOT INITIAL.
              MESSAGE TEXT-e16 TYPE zcon_msg_e.
            ENDIF.
  
            " Update Log - Failed
            READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<lfs_gm_return>) WITH KEY type = zcon_msg_e.
            IF sy-subrc IS INITIAL AND <lfs_gm_return> IS ASSIGNED.
              LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<lfs_gm_return1>) WHERE type = zcon_msg_e.
                IF <lfs_gm_return1> IS ASSIGNED.
                  IF <lfs_gm_return1>-message_v4 IS NOT INITIAL.
                    "  this is batch specific error
                    DATA(lv_message_v4) = <lfs_gm_return1>-message_v4.
                    DATA(lv_charg)      = lv_message_v4+c_offset(c_charg_len).
                    IF lv_charg IS NOT INITIAL.
                      LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_tc_return1>) WHERE charg = lv_charg.
                        IF <lfs_tc_return1> IS ASSIGNED.
                          IF iv_ident = c_pcount AND <lfs_tc_return1>-pcount IS NOT INITIAL.
                            lv_error_msg = |{ TEXT-e39 } { <lfs_gm_return1>-message }|.
                          ELSEIF iv_ident = c_consum AND <lfs_tc_return1>-consum IS NOT INITIAL.
                            lv_part_failed = abap_true.
                            <lfs_tc_return1>-log = <lfs_gm_return1>-message.
                            <lfs_tc_return1>-c_part_failed = abap_true.
                          ELSEIF iv_ident = c_scrap AND <lfs_tc_return1>-scrap IS NOT INITIAL.
                            lv_part_failed = abap_true.
                            <lfs_tc_return1>-log = <lfs_gm_return1>-message.
                            <lfs_tc_return1>-s_part_failed = abap_true.
                          ELSEIF iv_ident = c_ncount AND <lfs_tc_return1>-ncount IS NOT INITIAL.
                            lv_part_failed = abap_true.
                            <lfs_tc_return1>-log = <lfs_gm_return1>-message.
                            <lfs_tc_return1>-n_part_failed = abap_true.
                          ENDIF.
                        ENDIF.
                      ENDLOOP.
                    ENDIF.
                  ELSE.
                    IF <lfs_gm_return>-message IS NOT INITIAL AND <lfs_gm_return>-row IS NOT INITIAL.
                      READ TABLE gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_all>) INDEX <lfs_gm_return>-row.
                      IF <lfs_all> IS ASSIGNED.
                        <lfs_all>-log = <lfs_gm_return>-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
            IF lv_part_failed EQ abap_true.
              CASE iv_ident.
                WHEN c_consum.
                  LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return_c>) WHERE consum IS NOT INITIAL AND c_part_failed IS INITIAL.
                    IF <lfs_return_c> IS ASSIGNED.
                      <lfs_return_c>-log = <lfs_return_c>-log && TEXT-e40.      " Other record(s) in error, hence skipped this record.
                    ENDIF.
                  ENDLOOP.
                WHEN c_scrap.
                  LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return_s>) WHERE scrap IS NOT INITIAL AND s_part_failed IS INITIAL.
                    IF <lfs_return_s> IS ASSIGNED.
                      <lfs_return_s>-log = <lfs_return_s>-log && TEXT-e41.      " Other record(s) in error, hence skipped this record.
                    ENDIF.
                  ENDLOOP.
                WHEN c_ncount.
                  LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return_n>) WHERE ncount IS NOT INITIAL AND n_part_failed IS INITIAL.
                    IF <lfs_return_n> IS ASSIGNED.
                      <lfs_return_n>-log = <lfs_return_n>-log && TEXT-e42.      " Other record(s) in error, hence skipped this record.
                    ENDIF.
                  ENDLOOP.
              ENDCASE.
            ENDIF.
          ENDIF.
  
          CALL FUNCTION 'RFC_CONNECTION_CLOSE'
            EXPORTING
              destination = c_destination_n.
  
          " Save data in ztable after creating material documenet.
          SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
          IF ( iv_ident = c_scrap OR iv_ident = c_consum OR iv_ident = c_ncount )
           AND lv_matdoc IS NOT INITIAL.
            ev_matdoc_created = abap_true.
  
            LOOP AT gt_tc_return ASSIGNING <lfs_return1>.
              IF <lfs_return1> IS ASSIGNED.
  
                READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>) WITH KEY material = <lfs_return1>-matnr
                                                                                                         charg    = <lfs_return1>-charg
                                                                                                         timestamp = <lfs_return1>-varnm BINARY SEARCH.
                IF sy-subrc IS INITIAL AND <lfs_scanreel> IS ASSIGNED.
                  <lfs_scanreel>-menge_pcount = <lfs_return1>-pcount.
                  IF iv_ident = c_ncount.
                    <lfs_scanreel>-mblnr_ncount  = lv_matdoc.
                  ELSEIF iv_ident = c_consum.
                    <lfs_scanreel>-mblnr_consume = lv_matdoc.
                  ELSEIF iv_ident = c_scrap.
                    <lfs_scanreel>-mblnr_scrap  = lv_matdoc.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF lcl_data_manager=>gt_scanreel[] IS NOT INITIAL.
              TRY.
                  MODIFY zmm_scanreel_ret FROM TABLE lcl_data_manager=>gt_scanreel.
                  IF sy-subrc IS INITIAL.
                    COMMIT WORK.
                  ENDIF.
                CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
                  MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
                CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
                  MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
              ENDTRY.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
  
      IF lv_matdoc IS NOT INITIAL.
  
        CASE iv_ident.
          WHEN c_consum.
            lcl_data_manager=>create_to(
              EXPORTING
                iv_ident   = c_consum
                iv_mat_doc = lv_matdoc
                iv_mjahr   = lv_gjahr
              IMPORTING
                ev_to_created = ev_to_created ).
          WHEN c_scrap.
            lcl_data_manager=>create_to(
              EXPORTING
                iv_ident   = c_scrap
                iv_mat_doc = lv_matdoc
                iv_mjahr   = lv_gjahr
               IMPORTING
                ev_to_created = ev_to_created ).
          WHEN c_ncount.
            lcl_data_manager=>create_posting_change(
              EXPORTING
                iv_ident   = c_ncount
                iv_mat_doc = lv_matdoc
                iv_mjahr   = lv_gjahr ).
          WHEN c_pcount.
            lcl_data_manager=>create_posting_change(
              EXPORTING
                iv_ident   = c_pcount
                iv_mat_doc = lv_matdoc
                iv_mjahr   = lv_gjahr ).
          WHEN OTHERS.
        ENDCASE.
  
      ELSE.
        " RWNC BAPI Failed
        IF iv_ident = c_pcount AND lv_error_msg IS NOT INITIAL.
          MESSAGE lv_error_msg TYPE zcon_msg_i.
        ENDIF.
      ENDIF.
  
    ENDMETHOD.
  *--------------------------------------------------------------------
  * Create Tranfer order for Tranfer Requirement.( Consumption & Scrap )
  *--------------------------------------------------------------------
    METHOD create_to.
  
      DATA: lt_trite TYPE STANDARD TABLE OF l03b_trite,
            lv_tanum TYPE tanum.
  
      ev_to_created = abap_false.
  
      IF iv_mat_doc IS NOT INITIAL.
  
        SELECT mblnr, matnr, werks, lgort, charg, menge, erfme, tbnum, tbpos
          FROM mseg
          INTO TABLE @DATA(lt_mseg)
         WHERE mblnr = @iv_mat_doc
           AND mjahr = @iv_mjahr.
  
        IF lt_mseg[] IS NOT INITIAL.
  
          LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg>).
            IF iv_ident = c_consum AND <lfs_mseg> IS ASSIGNED.
              LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return>) WHERE  matnr = <lfs_mseg>-matnr AND
                                                                               werks = <lfs_mseg>-werks AND
                                                                               charg = <lfs_mseg>-charg AND
                                                                               consum > c_num0.
  
                IF <lfs_return> IS ASSIGNED.
                  APPEND INITIAL LINE TO lt_trite ASSIGNING FIELD-SYMBOL(<lfs_trite>).
                  <lfs_trite>-tbpos = <lfs_mseg>-tbpos.       " Transfer Requirement Item
                  <lfs_trite>-anfme = <lfs_return>-consum.    " Requested quantity in alternative unit of measure
                  <lfs_trite>-altme = <lfs_mseg>-erfme.       " Alternative Unit of Measure for Stockkeeping Unit
                  <lfs_trite>-charg = <lfs_mseg>-charg.       " Batch Number
                  <lfs_trite>-vlenr = <lfs_return>-varnm.     " Source Storage Unit
                  <lfs_trite>-letyp = <lfs_return>-letyp.     " Source storage type
                ENDIF.
              ENDLOOP.
  
            ELSEIF iv_ident = c_scrap.
              LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return1>) WHERE  matnr = <lfs_mseg>-matnr AND
                                                                                werks = <lfs_mseg>-werks AND
                                                                                charg = <lfs_mseg>-charg AND
                                                                                scrap > c_num0.
                IF <lfs_return1> IS ASSIGNED.
                  APPEND INITIAL LINE TO lt_trite ASSIGNING FIELD-SYMBOL(<lfs_trite1>).
                  <lfs_trite1>-tbpos = <lfs_mseg>-tbpos.       " Transfer Requirement Item
                  <lfs_trite1>-anfme = <lfs_return1>-scrap.    " Requested quantity in alternative unit of measure
                  <lfs_trite1>-altme = <lfs_mseg>-erfme.       " Alternative Unit of Measure for Stockkeeping Unit
                  <lfs_trite1>-charg = <lfs_mseg>-charg.       " Batch Number
                  <lfs_trite1>-vlenr = <lfs_return1>-varnm.    " Source Storage Unit
                  <lfs_trite1>-letyp = <lfs_return1>-letyp.    " Source storage type
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
  
          IF lt_trite[] IS NOT INITIAL.
  
            " L_TO_CREATE_TR is an unreleased FM
            " Continued to use this FM since it is the only option to Create a transfer order for transfer requirement
            CALL FUNCTION 'L_TO_CREATE_TR'
              EXPORTING
                i_lgnum                        = gv_lgnum
                i_tbnum                        = <lfs_mseg>-tbnum
                i_squit                        = abap_true
                i_commit_work                  = abap_true
                i_bname                        = sy-uname
                it_trite                       = lt_trite
              IMPORTING
                e_tanum                        = lv_tanum
              EXCEPTIONS
                foreign_lock                   = 1
                qm_relevant                    = 2
                tr_completed                   = 3
                xfeld_wrong                    = 4
                ldest_wrong                    = 5
                drukz_wrong                    = 6
                tr_wrong                       = 7
                squit_forbidden                = 8
                no_to_created                  = 9
                update_without_commit          = 10
                no_authority                   = 11
                preallocated_stock             = 12
                partial_transfer_req_forbidden = 13
                input_error                    = 14
                OTHERS                         = 15.
  
            IF sy-subrc IS INITIAL.
  
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION c_destination_n
                EXPORTING
                  wait                  = abap_true
                EXCEPTIONS
                  communication_failure = 1
                  system_failure        = 2
                  OTHERS                = 3.
              IF sy-subrc IS INITIAL AND lv_tanum IS NOT INITIAL.
                PERFORM f_convert_tanum CHANGING lv_tanum.
                ev_to_created = abap_true.
                " Update Log
                LOOP AT gt_tc_return ASSIGNING <lfs_return> WHERE matnr = <lfs_mseg>-matnr AND
                                                                  werks = <lfs_mseg>-werks AND
                                                                  ( consum > c_num0 OR scrap > c_num0 ).
  
                  IF <lfs_return> IS ASSIGNED.
                    IF iv_ident EQ c_consum AND <lfs_return>-consum IS NOT INITIAL AND <lfs_return> IS ASSIGNED.
  
                      IF <lfs_return>-to_number IS INITIAL.
                        <lfs_return>-to_number = TEXT-m11.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-m08 && | {  lv_tanum } |.
                      ELSE.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-m08 && | {  lv_tanum } |.
                      ENDIF.
                    ENDIF.
  
                    IF iv_ident EQ c_scrap AND <lfs_return>-scrap IS NOT INITIAL.
  
                      IF <lfs_return>-to_number IS INITIAL.
                        <lfs_return>-to_number = TEXT-m11.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-m09 && | {  lv_tanum } |.
                      ELSE.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-m09 && | {  lv_tanum } |.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              CALL FUNCTION 'RFC_CONNECTION_CLOSE'
                EXPORTING
                  destination = c_destination_n.
  
            ELSE.
  
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
                EXCEPTIONS
                  communication_failure = 1
                  system_failure        = 2
                  OTHERS                = 3.
  
              IF sy-subrc IS INITIAL.
                " Update Log - Failed - to be updated.
                LOOP AT gt_tc_return ASSIGNING <lfs_return> WHERE matnr = <lfs_mseg>-matnr AND
                                                                  werks = <lfs_mseg>-werks AND
                                                                  ( consum > c_num0 OR scrap > c_num0 ).
                  IF <lfs_return> IS ASSIGNED.
                    IF iv_ident EQ c_consum AND <lfs_return>-consum IS NOT INITIAL.
  
                      IF <lfs_return>-to_number IS INITIAL.
                        <lfs_return>-to_number = TEXT-m11.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-e11.
                      ELSE.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-e11.
                      ENDIF.
                    ENDIF.
  
                    IF iv_ident EQ c_scrap AND <lfs_return>-scrap IS NOT INITIAL.
                      IF <lfs_return>-to_number IS INITIAL.
                        <lfs_return>-to_number = TEXT-m11.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-e12.
                      ELSE.
                        <lfs_return>-to_number = |{ <lfs_return>-to_number } | && TEXT-e12.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              CALL FUNCTION 'RFC_CONNECTION_CLOSE'
                EXPORTING
                  destination = c_destination_n.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
  
      " Save record in ztable
      SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
      IF lv_tanum IS NOT INITIAL.
        LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return_1>).
          IF <lfs_return_1> IS ASSIGNED.
  
            READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>) WITH KEY material = <lfs_return_1>-matnr
                                                                                                     charg    = <lfs_return_1>-charg
                                                                                                     timestamp = <lfs_return_1>-varnm BINARY SEARCH.
            IF sy-subrc IS INITIAL AND <lfs_scanreel> IS ASSIGNED.
              IF iv_ident = c_consum.
  
                <lfs_scanreel>-mblnr_consume   = iv_mat_doc.
                <lfs_scanreel>-to_consum       = lv_tanum.
  
              ELSEIF iv_ident = c_scrap.
  
                <lfs_scanreel>-mblnr_scrap    = iv_mat_doc.
                <lfs_scanreel>-to_scrap       = lv_tanum.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF lcl_data_manager=>gt_scanreel[] IS NOT INITIAL.
          TRY.
              MODIFY zmm_scanreel_ret FROM TABLE lcl_data_manager=>gt_scanreel.
              IF sy-subrc IS INITIAL.
                COMMIT WORK.
              ENDIF.
            CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
              MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
            CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
              MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDMETHOD.
  *-----------------------------------------------------------------------
  * Create Tranfer order for Posting Change.( New Count & Previous Count )
  *-----------------------------------------------------------------------
    METHOD create_posting_change.
  
      " Local Declarations
      DATA: lt_lubqu     TYPE STANDARD TABLE OF lubqu,   " Table for quants
            ls_lubqu     TYPE lubqu,                     " Structure for quant
            lt_ltap_vb   TYPE STANDARD TABLE OF ltap_vb, " Table for transfer items
            lv_message   TYPE bapiret2-message,
            lv_error_msg TYPE bapiret2-message,
            lv_tanum     TYPE tanum,
            ls_ltap_vb   TYPE ltap_vb.                   " Structure for transfer item
  
      IF iv_mat_doc IS NOT INITIAL.
  
        SELECT lgtyp
          FROM lagp
          WHERE lgnum = @lcl_data_manager=>gv_lgnum
           AND lgpla = @p_lgpla
           AND lgtyp IS NOT INITIAL
           ORDER BY PRIMARY KEY
           INTO @DATA(lv_lgtyp).
          IF lv_lgtyp IS NOT INITIAL.
            EXIT.
          ENDIF.
        ENDSELECT.
  
        SELECT mblnr, matnr, werks, lgort, charg, ubnum
          FROM mseg
         WHERE mblnr = @iv_mat_doc
           AND mjahr = @iv_mjahr
           AND bwart = @p_mov_in
           AND umlgo = @p_lgortd
           AND ubnum IS NOT INITIAL
          INTO TABLE @DATA(lt_mseg).
  
        IF lt_mseg[] IS NOT INITIAL.
          SORT gt_tc_return BY matnr werks charg.
          LOOP AT lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg>).
            IF <lfs_mseg> IS ASSIGNED.
              CLEAR: lt_lubqu,lt_ltap_vb, ls_lubqu, ls_ltap_vb.
  
              IF iv_ident EQ c_ncount.
                LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return>) WHERE matnr = <lfs_mseg>-matnr AND
                                                                                werks = <lfs_mseg>-werks AND
                                                                                charg = <lfs_mseg>-charg AND
                                                                                ncount GT c_num0.
                  IF <lfs_return> IS ASSIGNED.
  
                    " Update Posting Change Number
                    <lfs_return>-posting_change = <lfs_mseg>-ubnum.
  
                    " Fill T_LUBQU table for quant information
                    ls_lubqu-lqnum = <lfs_return>-lqnum.    " Quant number
                    ls_lubqu-menge = <lfs_return>-ncount.   " New quantity
                    ls_lubqu-nlpla = p_lgpla.
                    ls_lubqu-nltyp = lv_lgtyp.
                    APPEND ls_lubqu TO lt_lubqu.
  
                    " Fill T_LTAP_VB table for transfer items
                    ls_ltap_vb-matnr = <lfs_return>-matnr.  " Material number
                    ls_ltap_vb-werks = <lfs_return>-werks.  " Plant
                    ls_ltap_vb-charg = <lfs_return>-charg.  " Batch
                    APPEND ls_ltap_vb TO lt_ltap_vb.
                  ENDIF.
                ENDLOOP.
  
              ELSEIF iv_ident EQ c_pcount.
                LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return1>) WHERE matnr = <lfs_mseg>-matnr AND
                                                                                 werks = <lfs_mseg>-werks AND
                                                                                 charg = <lfs_mseg>-charg AND
                                                                                 pcount GT c_num0.
                  IF <lfs_return1> IS ASSIGNED.
  
                    " Update Posting Change Number
                    <lfs_return1>-posting_change = <lfs_mseg>-ubnum.
  
                    " Fill T_LUBQU table for quant information
                    ls_lubqu-lqnum = <lfs_return1>-lqnum.    " Quant number
                    ls_lubqu-menge = <lfs_return1>-pcount.   " Previous Count
                    ls_lubqu-nlpla = p_lgpla.
                    ls_lubqu-nltyp = lv_lgtyp.
                    APPEND ls_lubqu TO lt_lubqu.
  
                    " Fill T_LTAP_VB table for transfer items
                    ls_ltap_vb-matnr = <lfs_return1>-matnr.  " Material number
                    ls_ltap_vb-werks = <lfs_return1>-werks.  " Plant
                    ls_ltap_vb-charg = <lfs_return1>-charg.  " Batch
                    APPEND ls_ltap_vb TO lt_ltap_vb.
                  ENDIF.
                ENDLOOP.
              ENDIF.
  
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
  
              IF sy-subrc IS INITIAL.
  
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION c_destination_n
                  EXPORTING
                    wait                  = abap_true
                  EXCEPTIONS
                    communication_failure = 1
                    system_failure        = 2
                    OTHERS                = 3.
  
                " only if if it is RWNC / Prev. Count case.
                IF sy-subrc IS INITIAL.
                  IF lv_tanum IS NOT INITIAL AND iv_ident EQ c_pcount.
                    lv_message = | { TEXT-s01 }  { iv_mat_doc } { TEXT-s02 } { TEXT-s03 } { lv_tanum } { TEXT-s04 }|.
                    lcl_data_manager=>gv_processed = abap_true.
                    MESSAGE lv_message TYPE zcon_msg_i.
                  ELSE.
                    lv_message =  TEXT-e15.
                  ENDIF.
                  IF  lv_tanum IS NOT INITIAL AND iv_ident EQ c_ncount.
                    PERFORM f_convert_tanum CHANGING lv_tanum.
                    " Update Log
                    LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return_log>) WHERE matnr = <lfs_mseg>-matnr AND
                                                                                        werks = <lfs_mseg>-werks AND
                                                                                        charg = <lfs_mseg>-charg.
  
                      IF <lfs_return_log> IS ASSIGNED.
                        IF iv_ident EQ c_ncount AND <lfs_return_log>-ncount IS NOT INITIAL.
                          IF <lfs_return_log>-to_number IS INITIAL.
                            <lfs_return_log>-to_number = TEXT-m11.
                            <lfs_return_log>-to_number = |{ <lfs_return_log>-to_number } | && TEXT-m10 && | {  lv_tanum } |.
                          ELSE.
                            <lfs_return_log>-to_number = |{ <lfs_return_log>-to_number } | && TEXT-m10 && | {  lv_tanum } |.
                          ENDIF.
                        ENDIF.
                      ENDIF.
                    ENDLOOP.
                  ENDIF.
                ENDIF.
                CALL FUNCTION 'RFC_CONNECTION_CLOSE'
                  EXPORTING
                    destination = c_destination_n.
  
              ELSE.
  
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION c_destination_n
                  EXCEPTIONS
                    communication_failure = 1
                    system_failure        = 2
                    OTHERS                = 3.
  
                IF sy-subrc IS INITIAL.
  
                  CLEAR lv_message.
                  PERFORM f_bapi_e_message USING sy-msgty sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                                            CHANGING lv_message.
  
                  READ TABLE gt_tc_return ASSIGNING <lfs_return> WITH KEY  matnr = <lfs_mseg>-matnr
                                                                           werks = <lfs_mseg>-werks
                                                                           charg = <lfs_mseg>-charg BINARY SEARCH.
  
                  IF <lfs_return> IS ASSIGNED.
                    IF sy-subrc IS INITIAL  AND <lfs_return>-ncount IS NOT INITIAL.
                      <lfs_return>-to_number = lv_message.
                    ENDIF.
  
                    IF sy-subrc IS INITIAL  AND <lfs_return>-pcount IS NOT INITIAL.
                      lv_error_msg = | { TEXT-s01 }  { iv_mat_doc } { TEXT-s02 } { TEXT-e38 } { lv_message } |.
                      MESSAGE lv_error_msg TYPE zcon_msg_i.
                    ENDIF.
                  ENDIF.
                ENDIF.
                CALL FUNCTION 'RFC_CONNECTION_CLOSE'
                  EXPORTING
                    destination = c_destination_n.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
  
      " Save record in ztable
      SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
      IF lv_tanum IS NOT INITIAL AND iv_ident = c_ncount.
        LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return2>).
          IF <lfs_return2> IS ASSIGNED.
            READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>) WITH KEY material = <lfs_return2>-matnr
                                                                                                     charg    = <lfs_return2>-charg
                                                                                                     timestamp = <lfs_return2>-varnm BINARY SEARCH.
            IF iv_ident = c_ncount AND <lfs_scanreel> IS ASSIGNED.
              <lfs_scanreel>-mblnr_ncount   = iv_mat_doc.
              <lfs_scanreel>-to_ncount      = lv_tanum.
            ENDIF.
          ENDIF.
        ENDLOOP.
  
        IF lcl_data_manager=>gt_scanreel IS NOT INITIAL.
          TRY.
              MODIFY zmm_scanreel_ret FROM TABLE lcl_data_manager=>gt_scanreel.
              IF sy-subrc IS INITIAL.
                COMMIT WORK.
              ENDIF.
            CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
              MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
            CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
              MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
          ENDTRY.
        ENDIF.
  
        IF ( iv_ident = c_ncount OR
             iv_ident = c_pcount )
          AND iv_mat_doc IS NOT INITIAL
          AND lv_tanum IS NOT INITIAL.
          DELETE zmm_scanreel_ret FROM TABLE lcl_data_manager=>gt_scanreel.
          IF sy-subrc IS INITIAL.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMETHOD.
  ENDCLASS.
  
  *---------------------------------------------------------------------*
  *                CLASS LCL_SCREEN_MAGANGER IMPLEMENTATION
  *---------------------------------------------------------------------*
  CLASS lcl_screen_manager IMPLEMENTATION.
  
    METHOD user_command_1001.
  
      " Local Variables
      DATA: lv_okcode TYPE sy-ucomm.
  
      " Method Processing Logic
      lv_okcode = sy-ucomm.
  
      CASE lv_okcode.
  
        WHEN c_fct_back.
          PERFORM f_clear_refresh_and_free.
          LEAVE TO SCREEN 0.
  
        WHEN c_fct_exit.
          PERFORM f_clear_refresh_and_free.
          LEAVE TO SCREEN 0.
  
        WHEN c_fct_cancel.
          PERFORM f_clear_refresh_and_free.
          LEAVE TO SCREEN 0.
  
        WHEN c_fct_execute.
  
          " Validate if any records available to proceed.
          lcl_data_manager=>validate_before_call_bapi( ).
  
          IF lcl_data_manager=>gv_proceed EQ abap_true.
  
            " Confirm Action
  
            lcl_data_manager=>confirm_action( ).
  
            " If Action = Yes
            IF lcl_data_manager=>gv_answer EQ c_ans_yes.
  
              " Consumption
              lcl_data_manager=>process_data( EXPORTING iv_ident = c_consum
                                              IMPORTING ev_matdoc_created = DATA(lv_matdoc_consum)
                                                        ev_to_created     = DATA(lv_to_consum) ).
  
              " Scrap
              IF lv_matdoc_consum IS NOT INITIAL AND lv_to_consum IS NOT INITIAL.
                lcl_data_manager=>process_data( EXPORTING iv_ident = c_scrap
                                                IMPORTING ev_matdoc_created = DATA(lv_matdoc_scrap)
                                                          ev_to_created     = DATA(lv_to_scrap) ).
                " New Count
                IF lv_matdoc_scrap IS NOT INITIAL AND lv_to_scrap IS NOT INITIAL.
                  lcl_data_manager=>process_data( EXPORTING iv_ident = c_ncount ).
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
  
            " No records modified for proccessing.
            MESSAGE TEXT-e05 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
          ENDIF.
        WHEN OTHERS.
  
      ENDCASE.
  
      CLEAR: lv_okcode.
  
    ENDMETHOD.
  ENDCLASS.