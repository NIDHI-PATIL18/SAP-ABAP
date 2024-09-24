*&---------------------------------------------------------------------*
*& Include          ZMMI_RESERVE_WFSTR_FINAL_F01
*&---------------------------------------------------------------------*
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
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_strno_f4 .

    DATA: lt_return_tab TYPE STANDARD TABLE OF ddshretval.
    DATA: ls_return_tab TYPE ddshretval.
    DATA: ls_dynpfields TYPE dynpread,
          lt_dynpfields LIKE STANDARD TABLE OF dynpread.
  
    CLEAR gt_strnf4.
  
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
          FROM zmm_scanreel_str INTO TABLE @gt_strnf4
          WHERE werks = @p_werks.
  
  *  SORT gt_strnf4 BY sydate
  *                    sytime
  *                    strlong
  *                 DESCENDING.
  *
  * DELETE ADJACENT DUPLICATES FROM gt_strnf4 COMPARING strlong.
  
    IF gt_strnf4 IS NOT INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'STRLONG'
          dynpprog        = sy-repid
          dynpnr          = '1000'
          dynprofield     = 'P_STRNO'
          value_org       = 'S'
        TABLES
          value_tab       = gt_strnf4
          return_tab      = lt_return_tab
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
  
      IF sy-subrc EQ 0.
  
        READ TABLE lt_return_tab INTO ls_return_tab INDEX 1.
  
        IF sy-subrc EQ 0.
          p_strno = ls_return_tab-fieldval.
        ENDIF.
  
        IF p_strno IS NOT INITIAL.
  
          READ TABLE gt_strnf4 INTO gs_strnf4 WITH KEY strlong = p_strno.
  
          IF sy-subrc = 0.
  
            " It is an exisitng STR
            gv_oldstr = c_true.
            gv_orig_strs  = gs_strnf4-zstrnum.
            gv_orig_date  = gs_strnf4-sydate.
            gv_orig_time  = gs_strnf4-sytime.
            gv_orig_uname = gs_strnf4-syuser.
            gv_orig_strl  = gs_strnf4-strlong.
            gv_orig_bin   = gv_orig_strs.
  
            ls_dynpfields-fieldname    = 'P_MATNR'.
            ls_dynpfields-fieldvalue   = gs_strnf4-material.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = 'P_WERKS'.
            ls_dynpfields-fieldvalue   = gs_strnf4-werks.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = 'P_SLOC'.
            ls_dynpfields-fieldvalue   = gs_strnf4-lgort.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = 'P_SLOC_T'.
            ls_dynpfields-fieldvalue   = gs_strnf4-zlgtyp_source.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = 'P_DLOC'.
            ls_dynpfields-fieldvalue   = gs_strnf4-zlgort_dest.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = 'P_ZLGTYP'.
            ls_dynpfields-fieldvalue   = gs_strnf4-zlgtyp_dest.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
  
  
            "DYNP_VALUES_UPDATE
            CALL FUNCTION 'DYNP_VALUES_UPDATE'
              EXPORTING
                dyname     = sy-repid
                dynumb     = sy-dynnr
              TABLES
                dynpfields = lt_dynpfields.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_call_pick_scr
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_call_pick_scr .
    DATA: lv_date TYPE sy-datum.
    DATA: lv_time TYPE sy-uzeit.
    DATA: lv_str  TYPE string.
    MOVE:
  *           p_strno TO gs_selection-bin,
             p_sloc TO gs_selection-sloc,
             p_dloc TO gs_selection-dloc,
             p_zlgtyp TO gs_selection-zlgtyp_dest.
  
  
    IF p_strno(3) EQ 'STR'.
      gv_strlong = p_strno.
      SPLIT p_strno AT ' ' INTO  lv_str lv_date lv_time.
      DATA(lv_strnum) = strlen( lv_str ).
      lv_strnum = lv_strnum - 3.
      DATA(lv_strshort) = lv_str+3(lv_strnum).
      gs_selection-bin = lv_strshort.
      gv_zstrnum       = lv_strshort.
  
  
    ELSE.
      gs_selection-bin = p_strno.
      gv_zstrnum       = p_strno.
      CONCATENATE 'STR' p_strno INTO lv_str.
      CONCATENATE sy-datum+4(2) sy-datum+6(2) sy-datum+2(2) INTO lv_date.
      CONCATENATE sy-uzeit+0(2) sy-uzeit+2(2) sy-uzeit+4(2) INTO lv_time..
      CONCATENATE lv_str lv_date lv_time INTO gv_strlong SEPARATED BY ' '.
      gv_date = sy-datum.
      gv_time = sy-uzeit.
    ENDIF.
  
    PERFORM f_get_data.
    PERFORM f_strno_data.
    PERFORM f_prepare_filter.
  
    IF gt_source IS NOT INITIAL OR
       gt_dest   IS NOT INITIAL.
  
      CALL SCREEN 1001.
  
    ELSE.
      " mess -- no records to process.
      MESSAGE TEXT-e02 TYPE c_type_s DISPLAY LIKE c_type_e.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_lgnum
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_get_lgnum .
  
    SELECT SINGLE lgnum FROM t320 INTO gv_lgnum WHERE werks = p_werks AND lgort = p_sloc.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_auth_check
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_auth_check .
  
    AUTHORITY-CHECK OBJECT 'M_MSEG_BWA' " Authorization object for Movement type
     ID 'ACTVT' FIELD '01'
     ID 'BWART' FIELD p_inv_m.
    IF sy-subrc <> 0.
      gv_stop = c_true.
      MESSAGE TEXT-e07 type c_type_s DISPLAY LIKE c_type_e.
    ENDIF.
  
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWA' " Authorization object for Plant
     ID 'ACTVT' FIELD '01'
     ID 'WERKS' FIELD p_werks.
    IF sy-subrc <> 0.
      gv_stop = c_true.
      MESSAGE TEXT-e08 TYPE c_type_s DISPLAY LIKE c_type_e.
    ENDIF.
  
    AUTHORITY-CHECK OBJECT 'L_LGNUM'    " Authorization object for warehouse number/Storage type.
     ID 'LGNUM' FIELD gv_lgnum
     ID 'LGTYP' FIELD p_sloc_t.
    IF sy-subrc <> 0.
      gv_stop = c_true.
      MESSAGE TEXT-e09 TYPE c_type_s DISPLAY LIKE c_type_e.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_get_data .
  
  
    SELECT  a~matnr,
            a~charg,
            a~lgort,
            SUM( a~verme ) AS verme,
            MIN( a~lgnum ) AS lgnum,  " Use aggregate functions like MIN/MAX for other fields
            MIN( a~lqnum ) AS lqnum,
  *          MIN( a~lenum ) AS lenum,
            MIN( a~werks ) AS werks,
            MIN( a~bestq ) AS bestq,
            MIN( a~sobkz ) AS sobkz,
            MIN( a~sonum ) AS sonum,
            MIN( a~lgtyp ) AS lgtyp,
            MIN( a~lgpla ) AS lgpla,
            MIN( a~letyp ) AS letyp,
            MIN( a~meins ) AS meins
       FROM lqua AS a
      INNER JOIN mara AS b
         ON b~matnr = a~matnr
      INNER JOIN mcha AS c
         ON c~werks = a~werks
        AND c~charg = a~charg
        AND c~matnr = a~matnr
      WHERE a~verme > 0
      AND a~matnr EQ @p_matnr
      AND a~werks EQ @p_werks
      AND a~lgort EQ @p_sloc
      AND a~lgnum EQ @gv_lgnum
      GROUP BY a~matnr,
               a~charg,
               a~lgort
       INTO CORRESPONDING FIELDS OF TABLE @gt_source.
  
    " Backup of Original Table
    gt_source_backup = gt_source.
  
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
   WHERE a~verme > 0
   AND a~matnr = @p_matnr
   AND a~werks = @p_werks
   AND a~lgort = @p_sloc
   AND a~lgnum = @gv_lgnum
   INTO TABLE @gt_source_all.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form filter_container_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM filter_container_data .
  
    IF gv_charg IS NOT INITIAL.
      " Filter based on Filter Value
      gt_source = gt_source_backup.
      DELETE gt_source WHERE charg NE gv_charg.
  
    ELSE.
      " Reset Filter - Show Original Table
      gt_source = gt_source_backup.
    ENDIF.
  
    CALL METHOD go_source_grid->refresh_table_display.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_dropdn_value
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_get_dropdn_value .
    TYPE-POOLS : vrm.
    DATA: lt_charg_values TYPE  vrm_values,
          ls_charg_value  TYPE vrm_value.
  
    CLEAR lt_charg_values.
    LOOP AT gt_source INTO gs_source.
      ls_charg_value-key = gs_source-charg.
      ls_charg_value-text = gs_source-charg.
      APPEND ls_charg_value TO lt_charg_values.
    ENDLOOP.
  
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'GV_CHARG'
        values          = lt_charg_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
  * Implement suitable error handling here
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_prepare_filter
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_prepare_filter .
  
    CLEAR: gs_charg_value,
           gt_charg_values.
  
    LOOP AT gt_source INTO gs_source.
      gs_charg_value-key = gs_source-charg.
      gs_charg_value-text = gs_source-charg.
      APPEND gs_charg_value TO gt_charg_values.
    ENDLOOP.
  
  *  gt_charg_values = VALUE #( FOR gs_source in gt_source ( key = gs_source-charg
  *                                                          text = gs_source-charg ) ).
    SORT gt_charg_values.
    DELETE ADJACENT DUPLICATES FROM gt_charg_values.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_strno_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_strno_data .
  
    IF gv_oldstr EQ c_true.
  
      " Fetch Exisitng records from ZMM_SCANREEL_STR table
      SELECT *
       FROM zmm_scanreel_str
       INTO CORRESPONDING FIELDS OF TABLE @gt_zmm_scanreel_str
      WHERE zstrnum = @gv_orig_strs
      AND material = @p_matnr.
  
      IF sy-subrc = 0 AND gt_zmm_scanreel_str IS NOT INITIAL.
  
        LOOP AT gt_zmm_scanreel_str INTO gs_zmm_scanreel_str.
  
          " Append to GT_DEST
          gs_dest-material = gs_zmm_scanreel_str-material.
          gs_dest-werks    = gs_zmm_scanreel_str-werks.
          gs_dest-lgort    = gs_zmm_scanreel_str-lgort.
          gs_dest-charg    = gs_zmm_scanreel_str-charg.
          gs_dest-meins    = gs_zmm_scanreel_str-meins.
  
          " Check if QTY has been modified in LQUA
          READ TABLE gt_source INTO gs_source WITH KEY matnr = gs_zmm_scanreel_str-material
                                                   werks = gs_zmm_scanreel_str-werks
                                                   lgort = gs_zmm_scanreel_str-lgort
                                                   charg = gs_zmm_scanreel_str-charg.
          IF sy-subrc = 0.
  
            gs_dest-lqnum    = gs_source-lqnum.
  
            IF gs_zmm_scanreel_str-menge NE gs_source-verme. " QTY changed in LQUA
              gs_dest-verme    = gs_source-verme.
              gs_dest-upd_flg  = c_true.
            ELSE.
              gs_dest-verme    = gs_zmm_scanreel_str-menge.
            ENDIF.
  
            " Update flag to delete record from Source table
            gs_source-del_flag = c_true.
            MODIFY gt_source FROM gs_source INDEX sy-tabix.
  
          ENDIF.
  
          APPEND  gs_dest TO gt_dest.
          CLEAR gs_dest.
        ENDLOOP.
  
        DELETE gt_source WHERE del_flag = c_true.
  
        LOOP AT gt_dest INTO gs_dest WHERE upd_flg = c_true.
  
          " Exisitng Original values.
          gs_zmm_scanreel_str-zstrnum          = gv_orig_strs.
          gs_zmm_scanreel_str-sydate           = gv_orig_date.
          gs_zmm_scanreel_str-sytime           = gv_orig_time.
          gs_zmm_scanreel_str-syuser           = gv_orig_uname.
          gs_zmm_scanreel_str-material         = gs_dest-material.
          gs_zmm_scanreel_str-werks            = gs_dest-werks.
          gs_zmm_scanreel_str-lgort            = gs_dest-lgort.
          gs_zmm_scanreel_str-charg            = gs_dest-charg.
          gs_zmm_scanreel_str-meins            = gs_dest-meins.
          gs_zmm_scanreel_str-timestamp        = gs_dest-timestamp.
          gs_zmm_scanreel_str-zlgtyp_source    = p_sloc_t.
          gs_zmm_scanreel_str-bwart            = p_inv_m.
          gs_zmm_scanreel_str-zlgort_dest      = p_dloc.
          gs_zmm_scanreel_str-zlgtyp_dest      = p_zlgtyp .
          gs_zmm_scanreel_str-strlong          = gv_orig_strl.
  
          " Possible changing values
          gs_zmm_scanreel_str-menge            = gs_dest-verme.
  
          CLEAR gv_menge.
          WRITE gs_dest-verme TO gv_menge.
          CONDENSE gv_menge.
          CONCATENATE gs_zmm_scanreel_str-material c_sep_ch c_l_ch gs_zmm_scanreel_str-charg c_sep_ch c_q_ch gv_menge c_sep_ch gs_zmm_scanreel_str-timestamp INTO gs_zmm_scanreel_str-lngstr.
  
          MODIFY zmm_scanreel_str FROM gs_zmm_scanreel_str.
          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.
  
        ENDLOOP.
  
  
  *      LOOP AT gt_zmm_scanreel_str INTO gs_zmm_scanreel_str.
  *
  **  Fetch latest quantity from LQUA table
  *        SELECT SINGLE verme
  *        FROM lqua
  *        WHERE matnr =   @gs_zmm_scanreel_str-material
  *        AND   werks   = @gs_zmm_scanreel_str-werks
  *        AND   lgort   = @gs_zmm_scanreel_str-lgort
  *        AND   charg   = @gs_zmm_scanreel_str-charg
  *        INTO @DATA(lv_latest_quantity).
  *
  **    * Check if the quantity was found
  *        IF sy-subrc = 0.
  *          gs_dest-material = gs_zmm_scanreel_str-material.
  *          gs_dest-werks   =  gs_zmm_scanreel_str-werks.
  *          gs_dest-lgort   = gs_zmm_scanreel_str-lgort.
  *          gs_dest-charg   = gs_zmm_scanreel_str-charg.
  *          gs_dest-verme   = gs_zmm_scanreel_str-menge.
  **        gs_dest-verme   = lv_latest_quantity.
  *          gs_dest-meins   = gs_zmm_scanreel_str-meins.
  *
  *          APPEND  gs_dest TO gt_dest.
  *          CLEAR gs_dest.
  *        ENDIF.
  *      ENDLOOP.
      ENDIF.
  
  *    LOOP AT gt_source INTO gs_source.
  *      " Check if the same record exists in gt_dest
  *      READ TABLE gt_dest INTO gs_dest WITH KEY material = gs_source-matnr
  *                                werks    = gs_source-werks
  *                                lgort    = gs_source-lgort
  *                                charg    = gs_source-charg
  *                                meins    = gs_source-meins.
  *      IF sy-subrc = 0.
  *        " Record exists in gt_dest, mark for deletion or skip
  *        DELETE gt_source WHERE matnr = gs_source-matnr
  *                          AND werks = gs_source-werks
  *                          AND lgort = gs_source-lgort
  *                          AND charg = gs_source-charg
  *                          AND meins = gs_source-meins.
  *      ENDIF.
  *  ENDLOOP.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_get_existing_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f_get_existing_data .
  
    IF p_strno IS NOT INITIAL.
  
      " Check if STR is existing
  
      SELECT
      SINGLE *
        FROM zmm_scanreel_str INTO @gs_zmm_scanreel_str_sel
       WHERE strlong = @p_strno.
  
      IF sy-subrc = 0 AND gs_zmm_scanreel_str_sel-zstrnum IS NOT INITIAL.
  
        " It is an exisitng STR
  
        gv_oldstr     = c_true.
        gv_orig_strs  = gs_zmm_scanreel_str_sel-zstrnum.
        gv_orig_date  = gs_zmm_scanreel_str_sel-sydate.
        gv_orig_time  = gs_zmm_scanreel_str_sel-sytime.
        gv_orig_uname = gs_zmm_scanreel_str_sel-syuser.
        gv_orig_strl  = gs_zmm_scanreel_str_sel-strlong.
  
        p_matnr       = gs_zmm_scanreel_str_sel-material.
        p_werks       = gs_zmm_scanreel_str_sel-werks.
        p_sloc        = gs_zmm_scanreel_str_sel-lgort.
        p_dloc        = gs_zmm_scanreel_str_sel-zlgort_dest.
        p_zlgtyp      = gs_zmm_scanreel_str_sel-zlgtyp_dest.
        p_sloc_t      = gs_zmm_scanreel_str_sel-zlgtyp_source.
  
  
        IF gs_zmm_scanreel_str_sel-mblnr IS NOT INITIAL.
          gv_mblnr_created = c_true.   " MBLNR is already created by user in previous run.
          gv_mblnr = gs_zmm_scanreel_str_sel-mblnr.
        ELSE.
          CLEAR gv_mblnr_created.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.