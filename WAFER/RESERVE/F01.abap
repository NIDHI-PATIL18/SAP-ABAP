*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_F01
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
*&---------------------------------------------------------------------*
*& Form f_strno_f4
*&---------------------------------------------------------------------*
*& To access the list of STR no with the required fields.
*&---------------------------------------------------------------------*
FORM f_strno_f4.

    DATA: lt_return_tab TYPE STANDARD TABLE OF ddshretval,
          lt_dynpfields TYPE STANDARD TABLE OF dynpread,
          ls_dynpfields TYPE dynpread.
  
    "Get List of STR numbers from table
    SELECT zstrnum,
           sydate,
           sytime,
           material,
           lgort,
           zlgtyp_source,
           werks,
           syuser,
           strlong,
           zlgort_dest,
           zlgtyp_dest
      FROM zmm_scanreel_str
      INTO TABLE @DATA(lt_strnf4)
     WHERE werks = @p_werks.
  
    SORT lt_strnf4 BY strlong.
  
    DELETE ADJACENT DUPLICATES FROM lt_strnf4 COMPARING strlong.
  
    SORT lt_strnf4 BY sydate DESCENDING sytime DESCENDING.
  
    IF lt_strnf4[] IS NOT INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = c_strlong
          dynpprog        = sy-repid
          dynpnr          = c_dynpnr
          dynprofield     = c_strno
          value_org       = zcon_msg_s
        TABLES
          value_tab       = lt_strnf4
          return_tab      = lt_return_tab
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
  
      IF sy-subrc IS INITIAL.
  
        IF lt_return_tab[] IS NOT INITIAL.
          p_strno = lt_return_tab[ c_index1 ]-fieldval.
        ENDIF.
  
        IF p_strno IS NOT INITIAL.
          SORT lt_strnf4 BY strlong.
          READ TABLE lt_strnf4 ASSIGNING FIELD-SYMBOL(<lfs_strn>) WITH KEY strlong = p_strno BINARY SEARCH.
          IF sy-subrc IS INITIAL AND <lfs_strn> IS ASSIGNED.
  
            " It is an exisitng STR
            lcl_data_manager=>gv_oldstr    = abap_true.
            lcl_data_manager=>gv_strshort  = <lfs_strn>-zstrnum.
            lcl_data_manager=>gv_date      = <lfs_strn>-sydate.
            lcl_data_manager=>gv_time      = <lfs_strn>-sytime.
            lcl_data_manager=>gv_uname     = <lfs_strn>-syuser.
            lcl_data_manager=>gv_strlong   = <lfs_strn>-strlong.
  
            ls_dynpfields-fieldname    = c_matnr.
            ls_dynpfields-fieldvalue   = <lfs_strn>-material.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_werks.
            ls_dynpfields-fieldvalue   = <lfs_strn>-werks.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_sloc.
            ls_dynpfields-fieldvalue   = <lfs_strn>-lgort.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_sloct.
            ls_dynpfields-fieldvalue   = <lfs_strn>-zlgtyp_source.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_dloc.
            ls_dynpfields-fieldvalue   = <lfs_strn>-zlgort_dest.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_dloct.
            ls_dynpfields-fieldvalue   = <lfs_strn>-zlgtyp_dest.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            CALL FUNCTION 'DYNP_VALUES_UPDATE'
              EXPORTING
                dyname     = sy-repid
                dynumb     = sy-dynnr
              TABLES
                dynpfields = lt_dynpfields.
          ENDIF.
        ENDIF.
      ELSE.
        CASE sy-subrc.
          WHEN c_sy_subrc_1.
            MESSAGE TEXT-e11 TYPE zcon_msg_e.
          WHEN c_sy_subrc_2.
            MESSAGE TEXT-e12 TYPE zcon_msg_e.
          WHEN OTHERS.
            MESSAGE TEXT-e13 TYPE zcon_msg_e.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_call_pick_scr
  *&---------------------------------------------------------------------*
  *& To call the pick screen
  *&---------------------------------------------------------------------*
  FORM f_call_pick_scr.
  
    lcl_data_manager=>gs_selection-sloc        = p_sloc.
    lcl_data_manager=>gs_selection-dloc        = p_dloc.
    lcl_data_manager=>gs_selection-zlgtyp_dest = p_zlgtyp.
  
    IF lcl_data_manager=>gv_oldstr IS INITIAL.
      lcl_data_manager=>gv_strshort = p_strno.
      lcl_data_manager=>gv_date     = sy-datum.
      lcl_data_manager=>gv_time     = sy-uzeit.
      lcl_data_manager=>gv_uname    = sy-uname.
      lcl_data_manager=>gv_strlong  = c_p_str && p_strno && | { sy-datum+c_offset_4(c_offset_2) }|
                                                         && |{ sy-datum+c_offset_6(c_offset_2) }|
                                                         && |{ sy-datum+c_offset_2(c_offset_2) }|
                                                         && | { sy-uzeit }|.
    ENDIF.
  
    lcl_data_manager=>gs_selection-sloc        =  p_sloc.
    lcl_data_manager=>gs_selection-dloc        =  p_dloc.
    lcl_data_manager=>gs_selection-zlgtyp_dest =  p_zlgtyp.
    lcl_data_manager=>gs_selection-bin         =  lcl_data_manager=>gv_strshort.
  
    "Remove leading zeros from gs_selection-bin.
    SHIFT lcl_data_manager=>gs_selection-bin LEFT DELETING LEADING '0'.
  
    PERFORM f_get_data.
    PERFORM f_strno_data.
    PERFORM f_prepare_filter.
  
    IF lcl_data_manager=>gt_source[] IS NOT INITIAL OR
       lcl_data_manager=>gt_dest[]   IS NOT INITIAL.
  
      CALL SCREEN 1001.
  
    ELSE.
      " message no records to process.
      MESSAGE TEXT-e02 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_lgnum
  *&---------------------------------------------------------------------*
  *& Fetch Warehouse Number for Authorization checking and further use.
  *&---------------------------------------------------------------------*
  FORM f_get_lgnum .
  
    "Get Warehouse No
    SELECT SINGLE lgnum
      FROM t320
      INTO lcl_data_manager=>gv_lgnum
     WHERE werks = p_werks
       AND lgort = p_sloc.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_auth_check
  *&---------------------------------------------------------------------*
  *& Authorization object for movement type, plant, warehouse no./storage type..
  *&---------------------------------------------------------------------*
  FORM f_auth_check .
  
    AUTHORITY-CHECK OBJECT 'L_LGNUM'      " Authorization object for warehouse number/Storage type.
     ID 'LGNUM' FIELD lcl_data_manager=>gv_lgnum
     ID 'LGTYP' FIELD p_sloc_t.
    IF sy-subrc IS NOT INITIAL.
      lcl_data_manager=>gv_stop = abap_true.
      MESSAGE TEXT-e09 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
    ENDIF.
  
    IF lcl_data_manager=>gv_stop IS INITIAL.
      AUTHORITY-CHECK OBJECT 'M_MSEG_WWA' " Authorization object for Plant
       ID 'ACTVT' FIELD c_actvt
       ID 'WERKS' FIELD p_werks.
      IF sy-subrc IS NOT INITIAL.
        lcl_data_manager=>gv_stop = abap_true.
        MESSAGE TEXT-e08 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
      ENDIF.
    ENDIF.
  
    IF lcl_data_manager=>gv_stop IS INITIAL.
      AUTHORITY-CHECK OBJECT 'M_MSEG_BWA' " Authorization object for Movement type
       ID 'ACTVT' FIELD c_actvt
       ID 'BWART' FIELD p_inv_m.
      IF sy-subrc IS NOT INITIAL.
        lcl_data_manager=>gv_stop = abap_true.
        MESSAGE TEXT-e07 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
      ENDIF.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_data
  *&---------------------------------------------------------------------*
  *& To get the latest Quantity through aggregation.
  *&---------------------------------------------------------------------*
  FORM f_get_data .
  
    "Get summed data from LQUA table
    SELECT
            MIN( a~lgnum ) AS lgnum,   " Use aggregate functions like MIN/MAX for other fields
            MIN( a~lqnum ) AS lqnum,
            a~matnr,
            MIN( a~werks ) AS werks,
            a~charg,
            MIN( a~bestq ) AS bestq,
            MIN( a~sobkz ) AS sobkz,
            MIN( a~sonum ) AS sonum,
            MIN( a~lgtyp ) AS lgtyp,
            MIN( a~lgpla ) AS lgpla,
            MIN( a~letyp ) AS letyp,
            MIN( a~meins ) AS meins,
            SUM( a~verme ) AS verme,
            a~lgort
       FROM lqua AS a
      INNER JOIN mara AS b
              ON b~matnr = a~matnr
      INNER JOIN mcha AS c
              ON c~werks = a~werks
             AND c~charg = a~charg
             AND c~matnr = a~matnr
      WHERE a~lgnum EQ @lcl_data_manager=>gv_lgnum
        AND a~matnr EQ @p_matnr
        AND a~werks EQ @p_werks
        AND a~lgtyp EQ @p_sloc_t
        AND a~verme GT @c_zero_qty
        AND a~lgort EQ @p_sloc
      GROUP BY a~matnr,
               a~charg,
               a~lgort
       INTO TABLE @DATA(lt_source).
  
    lcl_data_manager=>gt_source = CORRESPONDING #( lt_source ).
    CLEAR lt_source[].
  
    SORT lcl_data_manager=>gt_source BY charg.
  
    "Backup of Original Table
    lcl_data_manager=>gt_source_backup[] = lcl_data_manager=>gt_source[].
  
    "Get all the records from LQUA table for quant and storage unit details
    SELECT a~lgnum,
           a~lqnum,
           a~matnr,
           a~werks,
           a~charg,
           a~bestq,
           a~sobkz,
           a~sonum,
           a~lgtyp,
           a~lgpla,
           a~letyp,
           a~meins,
           a~verme,
           a~lgort
      FROM lqua AS a
     INNER JOIN mara AS b
             ON b~matnr = a~matnr
     INNER JOIN mcha AS c
             ON c~werks = a~werks
            AND c~charg = a~charg
            AND c~matnr = a~matnr
      WHERE a~lgnum EQ @lcl_data_manager=>gv_lgnum
        AND a~matnr EQ @p_matnr
        AND a~werks EQ @p_werks
        AND a~lgtyp EQ @p_sloc_t
        AND a~verme GT @c_zero_qty
        AND a~lgort EQ @p_sloc
       INTO TABLE @DATA(lt_source_all).
  
    lcl_data_manager=>gt_source_all = CORRESPONDING #( lt_source_all ).
    CLEAR lt_source_all[].
  
    SORT lcl_data_manager=>gt_source_all BY charg.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_filter_container_data
  *&---------------------------------------------------------------------*
  *& filter the data from LQUA in the right container based on Batch.
  *&---------------------------------------------------------------------*
  FORM f_filter_container_data .
    IF lcl_data_manager=>gv_charg IS NOT INITIAL.
  
      " Filter based on Filter Value
      lcl_data_manager=>gt_source = lcl_data_manager=>gt_source_backup.
      DELETE lcl_data_manager=>gt_source WHERE charg NE lcl_data_manager=>gv_charg.
  
    ELSE.
      " Reset Filter - Show Original Table
      lcl_data_manager=>gt_source = lcl_data_manager=>gt_source_backup.
    ENDIF.
  
    "Delete the record which are moved to right container
    LOOP AT lcl_data_manager=>gt_dest[] ASSIGNING FIELD-SYMBOL(<lfs_record>).
      IF <lfs_record> IS ASSIGNED.
        DELETE lcl_data_manager=>gt_source[] WHERE charg EQ <lfs_record>-charg.
      ENDIF.
    ENDLOOP.
  
    CALL METHOD lcl_data_manager=>go_source_grid->refresh_table_display.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_prepare_filter
  *&---------------------------------------------------------------------*
  *& Prepare the list of batch filter.
  *&---------------------------------------------------------------------*
  FORM f_prepare_filter .
    CLEAR: lcl_data_manager=>gt_charg_values[].
  
    lcl_data_manager=>gt_charg_values = VALUE #( FOR <lfs_source>
                                           IN lcl_data_manager=>gt_source ( key = <lfs_source>-charg
                                                                            text = <lfs_source>-charg ) ).
  
    SORT lcl_data_manager=>gt_charg_values.
    DELETE ADJACENT DUPLICATES FROM lcl_data_manager=>gt_charg_values.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_strno_data
  *&---------------------------------------------------------------------*
  *& to fetch the exixting records from the custom table.
  *&---------------------------------------------------------------------*
  FORM f_strno_data.
  
    DATA: ls_dest  TYPE dest_s_type,
          lv_menge TYPE char20.
  
    DATA: ls_zmm_scanreel_str     TYPE zmm_scanreel_str,
          lt_zmm_scanreel_str_upd TYPE STANDARD TABLE OF zmm_scanreel_str.
  
    IF lcl_data_manager=>gv_oldstr EQ abap_true.
  
      " Fetch Exisitng records from ZMM_SCANREEL_STR table
      SELECT mandt,
             zstrnum,
             sydate,
             sytime,
             material,
             charg,
             timestamp,
             bwart,
             lgort,
             zlgtyp_source,
             werks,
             menge,
             meins,
             mblnr,
             syuser,
             lngstr,
             strlong,
             zlgort_dest,
             zlgtyp_dest,
             zlgpla_dest
        FROM zmm_scanreel_str
        INTO TABLE @DATA(lt_scanreel)
       WHERE zstrnum  EQ @lcl_data_manager=>gv_strshort
         AND sydate   EQ @lcl_data_manager=>gv_date
         AND sytime   EQ @lcl_data_manager=>gv_time
         AND material EQ @p_matnr.
  
      IF lt_scanreel[] IS NOT INITIAL.
  
        SORT lcl_data_manager=>gt_source BY matnr werks lgort charg.
        LOOP AT lt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>).
          IF <lfs_scanreel> IS ASSIGNED.
  
            " Append to GT_DEST
            ls_dest-material = <lfs_scanreel>-material.
            ls_dest-matnr    = <lfs_scanreel>-material.
            ls_dest-werks    = <lfs_scanreel>-werks.
            ls_dest-lgort    = <lfs_scanreel>-lgort.
            ls_dest-charg    = <lfs_scanreel>-charg.
            ls_dest-meins    = <lfs_scanreel>-meins.
  
            " Check if QTY has been modified in LQUA
            READ TABLE lcl_data_manager=>gt_source INTO DATA(ls_source) WITH KEY matnr = <lfs_scanreel>-material
                                                                                 werks = <lfs_scanreel>-werks
                                                                                 lgort = <lfs_scanreel>-lgort
                                                                                 charg = <lfs_scanreel>-charg
                                                                                 BINARY SEARCH.
            IF sy-subrc IS INITIAL.
  
              ls_dest = CORRESPONDING #( ls_source ).
              ls_dest-material = ls_source-matnr.
  
              IF <lfs_scanreel>-menge NE ls_source-verme. " QTY changed in LQUA
                ls_dest-verme    = ls_source-verme.
                ls_dest-upd_flg  = abap_true.
              ELSE.
                ls_dest-verme    = <lfs_scanreel>-menge.
              ENDIF.
  
              " Update flag to delete record from Source table
              ls_source-del_flag = abap_true.
              MODIFY lcl_data_manager=>gt_source FROM ls_source INDEX sy-tabix.
  
            ENDIF.
  
            APPEND ls_dest TO lcl_data_manager=>gt_dest.
            CLEAR ls_dest.
          ENDIF.
        ENDLOOP.
  
        IF lcl_data_manager=>gv_mblnr IS NOT INITIAL.
          " udpate posting change
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
  
            " Update Posting Change number
            LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_dest_pc>).
              IF <lfs_dest_pc> IS ASSIGNED.
                READ TABLE lt_mseg ASSIGNING FIELD-SYMBOL(<lfs_mseg>) WITH KEY matnr = <lfs_dest_pc>-matnr
                                                                               werks = <lfs_dest_pc>-werks
                                                                               charg = <lfs_dest_pc>-charg BINARY SEARCH.
                IF <lfs_mseg> IS ASSIGNED.
                  " Assign Posting Change number
                  <lfs_dest_pc>-posting_change = <lfs_mseg>-ubnum.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
  
        DELETE lcl_data_manager=>gt_source WHERE del_flag = abap_true.
  
        LOOP AT lcl_data_manager=>gt_dest INTO ls_dest WHERE upd_flg = abap_true.
  
          " Exisitng Original values.
          ls_zmm_scanreel_str-zstrnum       = lcl_data_manager=>gv_strshort.
          ls_zmm_scanreel_str-sydate        = lcl_data_manager=>gv_date.
          ls_zmm_scanreel_str-sytime        = lcl_data_manager=>gv_time.
          ls_zmm_scanreel_str-syuser        = lcl_data_manager=>gv_uname.
          ls_zmm_scanreel_str-material      = ls_dest-matnr.
          ls_zmm_scanreel_str-werks         = ls_dest-werks.
          ls_zmm_scanreel_str-lgort         = ls_dest-lgort.
          ls_zmm_scanreel_str-charg         = ls_dest-charg.
          ls_zmm_scanreel_str-meins         = ls_dest-meins.
          ls_zmm_scanreel_str-timestamp     = ls_dest-timestamp.
          ls_zmm_scanreel_str-zlgtyp_source = p_sloc_t.
          ls_zmm_scanreel_str-bwart         = p_inv_m.
          ls_zmm_scanreel_str-zlgort_dest   = p_dloc.
          ls_zmm_scanreel_str-zlgtyp_dest   = p_zlgtyp .
          ls_zmm_scanreel_str-strlong       = lcl_data_manager=>gv_strlong.
          ls_zmm_scanreel_str-menge         = ls_dest-verme.                 " Possible change in QTY values
          CLEAR lv_menge.
          lv_menge = ls_dest-verme.
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
  
          APPEND ls_zmm_scanreel_str TO lt_zmm_scanreel_str_upd.
          CLEAR: ls_zmm_scanreel_str, ls_dest.
        ENDLOOP.
      ENDIF.
    ENDIF.
  
    IF lt_zmm_scanreel_str_upd[] IS NOT INITIAL.
      TRY.
  
          MODIFY zmm_scanreel_str FROM TABLE lt_zmm_scanreel_str_upd.
  
          IF sy-subrc IS INITIAL.
            COMMIT WORK.
            CLEAR lt_zmm_scanreel_str_upd[].
          ENDIF.
        CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
          MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
        CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
          MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
      ENDTRY.
    ENDIF.
  
    SORT lcl_data_manager=>gt_dest BY matnr werks lgort charg.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_existing_data
  *&---------------------------------------------------------------------*
  *& To fetch the data based on the exixting STR number.
  *&---------------------------------------------------------------------*
  FORM f_get_existing_data .
  
    " Check if STR is existing
    SELECT zstrnum,
           sydate,
           sytime,
           material,
           lgort,
           zlgtyp_source,
           werks,
           mblnr,
           syuser,
           strlong,
           zlgort_dest,
           zlgtyp_dest
      FROM zmm_scanreel_str
     WHERE strlong = @p_strno
       AND zstrnum IS NOT INITIAL
     ORDER BY PRIMARY KEY
      INTO @DATA(ls_scanreel).
  
      IF ls_scanreel-zstrnum IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDSELECT.
  
    IF sy-subrc IS INITIAL AND ls_scanreel-zstrnum IS NOT INITIAL.
  
      " It is an exisitng STR
      lcl_data_manager=>gv_oldstr    = abap_true.
      lcl_data_manager=>gv_strshort  = ls_scanreel-zstrnum.
      lcl_data_manager=>gv_date      = ls_scanreel-sydate.
      lcl_data_manager=>gv_time      = ls_scanreel-sytime.
      lcl_data_manager=>gv_uname     = ls_scanreel-syuser.
      lcl_data_manager=>gv_strlong   = ls_scanreel-strlong.
  
      p_matnr  = ls_scanreel-material.
      p_werks  = ls_scanreel-werks.
      p_sloc   = ls_scanreel-lgort.
      p_dloc   = ls_scanreel-zlgort_dest.
      p_zlgtyp = ls_scanreel-zlgtyp_dest.
      p_sloc_t = ls_scanreel-zlgtyp_source.
  
      IF ls_scanreel-mblnr IS NOT INITIAL.
        lcl_data_manager=>gv_mblnr_created = abap_true.   " MBLNR is already created by user in previous run.
        lcl_data_manager=>gv_mblnr = ls_scanreel-mblnr.
      ELSE.
        CLEAR lcl_data_manager=>gv_mblnr_created.
      ENDIF.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_bapi_e_message
  *&---------------------------------------------------------------------*
  *& To retrieve a TO creation BAPI error message.
  *&---------------------------------------------------------------------*
  FORM f_bapi_e_message USING p_type       TYPE bapireturn-type
                              p_msgcl      TYPE sy-msgid
                              p_msgno      TYPE sy-msgno
                              p_par1       TYPE sy-msgv1
                              p_par2       TYPE sy-msgv2
                              p_par3       TYPE sy-msgv3
                              p_par4       TYPE sy-msgv4
                     CHANGING p_gv_message TYPE bapiret2-message.
  
    DATA: ls_bapiret2  TYPE bapiret2.
  
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = p_type
        cl     = p_msgcl
        number = p_msgno
        par1   = p_par1
        par2   = p_par2
        par3   = p_par3
        par4   = p_par4
      IMPORTING
        return = ls_bapiret2.
  
    p_gv_message = ls_bapiret2-message.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form delete_null_quantity
  *&---------------------------------------------------------------------*
  *& To delete null quantities from the Z table.
  *&---------------------------------------------------------------------*
  FORM f_delete_null_quantity.
  
    DATA: lt_del_null_q TYPE STANDARD TABLE OF zmm_scanreel_str,
          ls_del_null_q TYPE zmm_scanreel_str.
  
    " Delete Zero QTY records from z table
    LOOP AT lcl_data_manager=>gt_dest ASSIGNING FIELD-SYMBOL(<lfs_del>) WHERE verme EQ c_zero_qty.
      IF <lfs_del> IS ASSIGNED.
        ls_del_null_q-zstrnum   = lcl_data_manager=>gv_strshort.
        ls_del_null_q-sydate    = lcl_data_manager=>gv_date.
        ls_del_null_q-sytime    = lcl_data_manager=>gv_time.
        ls_del_null_q-material  = <lfs_del>-matnr.
        ls_del_null_q-charg     = <lfs_del>-charg.
        ls_del_null_q-bwart     = p_inv_m.
        ls_del_null_q-lgort     = <lfs_del>-lgort.
        APPEND ls_del_null_q TO lt_del_null_q.
        CLEAR ls_del_null_q.
      ENDIF.
    ENDLOOP.
  
    IF lt_del_null_q[] IS NOT INITIAL.
      TRY.
          " Delete null quntity records from zmm_scanreel_str table.
          DELETE zmm_scanreel_str FROM TABLE lt_del_null_q.
          IF sy-subrc IS INITIAL.
            COMMIT WORK.
            CLEAR lt_del_null_q[].
          ENDIF.
  
        CATCH cx_sy_open_sql_db INTO DATA(lcx_sy_open_sql_db).
          MESSAGE lcx_sy_open_sql_db->get_longtext( ) TYPE zcon_msg_e.
  
        CATCH cx_sy_itab_duplicate_key INTO DATA(lx_dup_key).
          MESSAGE lx_dup_key->get_text( ) TYPE zcon_msg_e.
      ENDTRY.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form F_RFC_CLOSE_DESTINATION
  *&---------------------------------------------------------------------*
  *& Close RFC Destination
  *&---------------------------------------------------------------------*
  FORM f_rfc_close_destination.
  
    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        destination = c_destination_n.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_set_pf_status_1000
  *&---------------------------------------------------------------------*
  FORM f_set_pf_status_1000.
  
    DATA: lt_exclude TYPE STANDARD TABLE OF sy-ucomm.
  
  
    IF sy-tcode EQ c_start_report.
  
      CLEAR lt_exclude.
      APPEND c_fct_get  TO lt_exclude.
      APPEND c_fct_spos TO lt_exclude.
  
    ELSE.
  
      CLEAR lt_exclude.
      SET PF-STATUS c_status_1000 EXCLUDING lt_exclude.
  
    ENDIF.
  
    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = c_status_1000
        p_program = sy-repid
      TABLES
        p_exclude = lt_exclude.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_display_docu
  *&---------------------------------------------------------------------*
  *& Display Prgoram Documentation
  *&---------------------------------------------------------------------*
  FORM f_display_docu.
  
    DATA: lt_links TYPE STANDARD TABLE OF tline.
  
    " Display help document
    CALL FUNCTION 'HELP_OBJECT_SHOW'
      EXPORTING
        dokclass = c_doc_class
        dokname  = c_doc_name
      TABLES
        links    = lt_links.
  
    CLEAR lt_links[].
  
  ENDFORM.