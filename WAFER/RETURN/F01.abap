*&---------------------------------------------------------------------*
*& Include          ZMMI_RETURN_WFSTR_F01
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
*&---------------------------------------------------------------------*
*& Form f_set_pf_status_1000
*&---------------------------------------------------------------------*
FORM f_set_pf_status_1000.

    DATA: lt_exclude TYPE STANDARD TABLE OF sy-ucomm.
  
    IF sy-tcode EQ c_start_report.
  
      CLEAR lt_exclude.
      APPEND c_fct_get TO lt_exclude.
      APPEND c_fct_onli TO lt_exclude.
      APPEND c_fct_spos TO lt_exclude.
  
    ELSE.
  
      CLEAR lt_exclude.
      APPEND c_fct_onli TO lt_exclude.
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
  *& Form f_set_title_1000
  *&---------------------------------------------------------------------*
  FORM f_set_title_1000 .
  
    SET TITLEBAR c_title_1000.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_strn_f4
  *&---------------------------------------------------------------------*
  FORM f_strn_f4.
  
    DATA: lt_return_tab TYPE STANDARD TABLE OF ddshretval,
          lt_dynpfields TYPE STANDARD TABLE OF dynpread,
          ls_dynpfields TYPE dynpread.
  
    CLEAR: lcl_data_manager=>gv_oldstr.
    " Get List of STR numbers from table
    SELECT zstrnum,
           sydate,
           sytime,
           material,
           charg,
           timestamp,
           werks,
           syuser,
           lgort,
           strlong
      FROM zmm_scanreel_ret
      WHERE zstrnum IS NOT INITIAL
      INTO TABLE @DATA(lt_strn_f4).
  
    SORT lt_strn_f4 BY strlong.
  
    DELETE ADJACENT DUPLICATES FROM lt_strn_f4 COMPARING strlong.
  
    SORT lt_strn_f4 BY sydate DESCENDING sytime DESCENDING.
  
  
    IF lt_strn_f4[] IS NOT INITIAL.
  
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = c_strlong
          dynpprog        = sy-repid
          dynpnr          = c_scr_1000
          dynprofield     = c_p_strn
          value_org       = zcon_msg_s
        TABLES
          value_tab       = lt_strn_f4
          return_tab      = lt_return_tab
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
  
      IF sy-subrc IS INITIAL.
        SORT lt_strn_f4 BY strlong.
        READ TABLE lt_return_tab ASSIGNING FIELD-SYMBOL(<lfs_return>) INDEX c_index1.
        IF sy-subrc IS INITIAL AND <lfs_return> IS ASSIGNED.
          p_strn = <lfs_return>-fieldval.
        ENDIF.
  
        IF p_strn IS NOT INITIAL.
          READ TABLE lt_strn_f4 ASSIGNING FIELD-SYMBOL(<lfs_strn>) WITH KEY strlong = p_strn BINARY SEARCH.
          IF sy-subrc IS INITIAL AND <lfs_strn> IS ASSIGNED.
  
            " It is an exisitng STR
            lcl_data_manager=>gv_oldstr     = abap_true.
            lcl_data_manager=>gv_strshort   = <lfs_strn>-zstrnum.
            lcl_data_manager=>gv_date       = <lfs_strn>-sydate.
            lcl_data_manager=>gv_time       = <lfs_strn>-sytime.
            lcl_data_manager=>gv_uname      = <lfs_strn>-syuser.
            lcl_data_manager=>gv_strlong    = <lfs_strn>-strlong.
  
            ls_dynpfields-fieldname    = c_werks_d.
            ls_dynpfields-fieldvalue   = <lfs_strn>-werks.
            APPEND ls_dynpfields TO lt_dynpfields.
            CLEAR ls_dynpfields.
  
            ls_dynpfields-fieldname    = c_lgort_s.
            ls_dynpfields-fieldvalue   = <lfs_strn>-lgort.
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
      ENDIF.
    ENDIF.
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_call_pick_scr
  *&---------------------------------------------------------------------*
  FORM f_call_pick_scr .
  
    IF lcl_data_manager=>gv_oldstr IS INITIAL.
      lcl_data_manager=>gv_strshort  = p_strn.
      " Remove leading zeros from gs_selection-bin.
      SHIFT lcl_data_manager=>gv_strshort LEFT DELETING LEADING '0'.
      lcl_data_manager=>gv_date      = sy-datum.
      lcl_data_manager=>gv_time      = sy-uzeit.
      lcl_data_manager=>gv_uname     = sy-uname.
      lcl_data_manager=>gv_strlong  = c_p_str && p_strn  && | { sy-datum+c_offset_4(c_offset_2) }|
                                                         && |{ sy-datum+c_offset_6(c_offset_2) }|
                                                         && |{ sy-datum+c_offset_2(c_offset_2) }|
                                                         && | { sy-uzeit }|.
    ELSE.
      lcl_data_manager=>gv_lgpla = lcl_data_manager=>gv_strshort.
    ENDIF.
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_call_pick_scr
  *&---------------------------------------------------------------------*
  FORM f_call_screen_1001.
  
    CALL SCREEN 1001.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_get_lgnum
  *&---------------------------------------------------------------------*
  FORM f_get_lgnum.
  
    SELECT SINGLE lgnum
      FROM t320
      INTO lcl_data_manager=>gv_lgnum
     WHERE werks = p_werks
       AND lgort = p_lgorts.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_auth_check_lgnum
  *&---------------------------------------------------------------------*
  FORM f_auth_check_lgnum.
  
    IF lcl_data_manager=>gv_lgnum IS NOT INITIAL.
      AUTHORITY-CHECK OBJECT 'L_LGNUM'               " Authorization object for warehouse number/Storage type.
      ID 'LGNUM' FIELD lcl_data_manager=>gv_lgnum
      ID 'LGTYP' FIELD c_all.
      IF sy-subrc IS NOT INITIAL.
        CLEAR lcl_data_manager=>gv_proceed.
        MESSAGE TEXT-e10 TYPE zcon_msg_s DISPLAY LIKE zcon_msg_e.
        RETURN.
      ENDIF.
    ENDIF.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_fetch_data
  *&---------------------------------------------------------------------*
  FORM f_fetch_data.
  
    IF lcl_data_manager=>gv_oldstr EQ abap_true.
  
      SELECT a~zstrnum,
             a~sydate,
             a~sytime,
             a~material,
             a~charg,
             a~timestamp,
             a~lgort,
             a~werks,
             a~menge_consum,
             a~menge_scrap,
             a~menge_pcount,
             a~meins,
             a~lenum,
             a~mblnr_consume,
             a~mblnr_scrap,
             a~mblnr_ncount,
             a~to_consum,
             a~to_scrap,
             a~to_ncount,
             a~syuser,
             a~strlong,
             b~lgnum,
             b~lqnum,
             b~matnr,
             b~lgpla,
             b~verme,
             b~letyp,
             b~lgtyp
        FROM zmm_scanreel_ret AS a
        INNER JOIN lqua AS b
          ON b~matnr   EQ a~material
         AND b~werks   EQ a~werks
         AND b~lgort   EQ a~lgort
         AND b~charg   EQ a~charg
  *       AND b~lgpla   EQ @lcl_data_manager=>gv_strshort
         AND b~lgpla   EQ @lcl_data_manager=>gv_lgpla
         AND b~lenum   EQ a~timestamp
       WHERE a~zstrnum EQ @lcl_data_manager=>gv_strshort
         AND a~sydate  EQ @lcl_data_manager=>gv_date
         AND a~sytime  EQ @lcl_data_manager=>gv_time
         AND b~verme   IS NOT INITIAL
        INTO TABLE @DATA(lt_scanreel).
  
      IF sy-subrc IS NOT INITIAL.
        CLEAR lt_scanreel[].
      ENDIF.
  
      LOOP AT lt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>).
        IF <lfs_scanreel> IS ASSIGNED.
          APPEND INITIAL LINE TO gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_tc_return>).
          IF <lfs_tc_return> IS ASSIGNED.
            <lfs_tc_return>-matnr    = <lfs_scanreel>-material.
            <lfs_tc_return>-charg    = <lfs_scanreel>-charg.
            <lfs_tc_return>-werks    = <lfs_scanreel>-werks.
            <lfs_tc_return>-meins    = <lfs_scanreel>-meins.
            <lfs_tc_return>-lgort    = <lfs_scanreel>-lgort.
            <lfs_tc_return>-lqnum    = <lfs_scanreel>-lqnum.
            <lfs_tc_return>-menge    = <lfs_scanreel>-verme.
            IF <lfs_scanreel>-mblnr_consume IS NOT INITIAL OR <lfs_scanreel>-mblnr_scrap IS NOT INITIAL OR <lfs_scanreel>-mblnr_ncount IS NOT INITIAL.
              <lfs_tc_return>-menge  = <lfs_scanreel>-menge_pcount.
              <lfs_tc_return>-pcount =  <lfs_scanreel>-menge_pcount.
            ELSE.
              <lfs_tc_return>-menge  = <lfs_scanreel>-verme.
              <lfs_tc_return>-pcount = <lfs_scanreel>-verme.
            ENDIF.
            <lfs_tc_return>-letyp    = <lfs_scanreel>-letyp.
            <lfs_tc_return>-lgtyp    = <lfs_scanreel>-lgtyp.
            IF <lfs_scanreel>-mblnr_consume IS NOT INITIAL OR <lfs_scanreel>-mblnr_scrap IS NOT INITIAL OR <lfs_scanreel>-mblnr_ncount IS NOT INITIAL.
              <lfs_tc_return>-menge  = <lfs_scanreel>-menge_pcount.
              <lfs_tc_return>-pcount =  <lfs_scanreel>-menge_pcount.
            ENDIF.
            <lfs_tc_return>-varnm    = <lfs_scanreel>-timestamp.
            <lfs_tc_return>-lgpla    = lcl_data_manager=>gv_strshort.
            <lfs_tc_return>-consum   = <lfs_scanreel>-menge_consum.
            <lfs_tc_return>-scrap    = <lfs_scanreel>-menge_scrap.
          ENDIF.
        ENDIF.
      ENDLOOP.
  
      lcl_data_manager=>gt_scanreel = CORRESPONDING #( lt_scanreel ).
    ELSE.
  
      SELECT lgnum,
             lqnum,
             matnr,
             werks,
             charg,
             lgpla,
             verme,
             meins,
             lgort,
             lenum,
             letyp,
             lgtyp
        FROM lqua
       WHERE lgnum EQ @lcl_data_manager=>gv_lgnum
         AND werks EQ @p_werks
  *       AND lgpla EQ @lcl_data_manager=>gv_strshort
         AND lgpla EQ @p_strn
         AND verme IS NOT INITIAL
         AND lgort EQ @p_lgorts
        INTO TABLE @DATA(lt_lqua).
  
      IF sy-subrc IS INITIAL.
  
        LOOP AT lt_lqua ASSIGNING FIELD-SYMBOL(<lfs_lqua>).
          IF <lfs_lqua> IS ASSIGNED.
            APPEND INITIAL LINE TO gt_tc_return ASSIGNING <lfs_tc_return>.
            IF <lfs_tc_return> IS ASSIGNED.
              <lfs_tc_return>-matnr   = <lfs_lqua>-matnr.                     " Field for TC Column - Material
              <lfs_tc_return>-charg   = <lfs_lqua>-charg.                     " Field for TC Column - Batch
              <lfs_tc_return>-werks   = <lfs_lqua>-werks.
              <lfs_tc_return>-menge   = <lfs_lqua>-verme.                     " Field for TC Column - Unrestricted
              <lfs_tc_return>-meins   = <lfs_lqua>-meins.                     " UOM
              <lfs_tc_return>-lqnum   = <lfs_lqua>-lqnum.
              <lfs_tc_return>-varnm   = <lfs_lqua>-lenum.                     " Field for TC Column - Variant Name
              <lfs_tc_return>-pcount  = <lfs_lqua>-verme.                     " Field for TC Column - Previous Count
              <lfs_tc_return>-lgpla   = <lfs_lqua>-lgpla.
              <lfs_tc_return>-letyp   = <lfs_lqua>-letyp.
              <lfs_tc_return>-lgtyp   = <lfs_lqua>-lgtyp.
            ENDIF.
  
            APPEND INITIAL LINE TO lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel2>).
            IF <lfs_scanreel2> IS ASSIGNED.
              <lfs_scanreel2>-zstrnum         = lcl_data_manager=>gv_strshort.
              <lfs_scanreel2>-sydate          = lcl_data_manager=>gv_date.
              <lfs_scanreel2>-sytime          = lcl_data_manager=>gv_time.
              <lfs_scanreel2>-syuser          = lcl_data_manager=>gv_uname.
              <lfs_scanreel2>-material        = <lfs_lqua>-matnr.
              <lfs_scanreel2>-werks           = p_werks.
              <lfs_scanreel2>-lgort           = p_lgorts.
              <lfs_scanreel2>-charg           = <lfs_lqua>-charg.
              <lfs_scanreel2>-meins           = <lfs_lqua>-meins.
              <lfs_scanreel2>-timestamp       = <lfs_lqua>-lenum.
              <lfs_scanreel2>-strlong         = lcl_data_manager=>gv_strlong.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    CLEAR lt_lqua.
    CLEAR lcl_data_manager=>gv_oldstr.
    SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
    SORT gt_tc_return BY matnr charg varnm.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_refresh
  *&---------------------------------------------------------------------*
  FORM f_clear_refresh_and_free.
  
    CLEAR:
           gs_tc_return,
           gt_tc_return.
    FREE:
           gs_tc_return,
           gt_tc_return.
  
    REFRESH CONTROL c_tcr FROM SCREEN c_screen_1001.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f_save_data
  *&---------------------------------------------------------------------*
  FORM f_save_data .
  
    IF lcl_data_manager=>gv_processed IS NOT INITIAL.
  
      " Initially saved data in ztable zmm_scanreel_ret
      SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
      IF gv_tot_consu IS NOT INITIAL AND gv_tot_scrap IS NOT INITIAL.
  
        LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_return>).
          IF <lfs_return> IS ASSIGNED.
            READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_log>) WITH KEY material = <lfs_return>-matnr
                                                                                                charg    = <lfs_return>-charg
                                                                                                timestamp = <lfs_return>-varnm BINARY SEARCH.
            IF sy-subrc IS INITIAL AND <lfs_log> IS ASSIGNED.
              <lfs_log>-menge_consum = <lfs_return>-consum.
              <lfs_log>-menge_scrap  = <lfs_return>-scrap.
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
            CATCH cx_sy_itab_duplicate_key INTO DATA(lcx_dup_key).
              MESSAGE lcx_dup_key->get_longtext( ) TYPE zcon_msg_e.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_validate_consum
  *&---------------------------------------------------------------------*
  *& Validate Cosnumption QTY
  *&---------------------------------------------------------------------*
  FORM f_validate_consum.
  
    DATA: lv_tot_used TYPE lqua_verme.
  
    CLEAR: lcl_data_manager=>gv_failed.
  
    lv_tot_used = gs_tc_return-consum + gs_tc_return-scrap.
  
    IF lv_tot_used GT gs_tc_return-pcount.
  
      lcl_data_manager=>gv_failed = abap_true.
  
      IF gs_tc_return-consum IS NOT INITIAL AND
         gs_tc_return-scrap  IS NOT INITIAL.
        lcl_data_manager=>gv_crsr_fld = c_scrn_consum.
        SET CURSOR FIELD lcl_data_manager=>gv_crsr_fld LINE lcl_data_manager=>gv_crsr_line.
        MESSAGE TEXT-e03 TYPE zcon_msg_e.
      ENDIF.
  
      IF gs_tc_return-consum IS NOT INITIAL AND
         gs_tc_return-scrap  IS INITIAL.
        lcl_data_manager=>gv_crsr_fld = c_scrn_consum.
        SET CURSOR FIELD lcl_data_manager=>gv_crsr_fld LINE lcl_data_manager=>gv_crsr_line.
        MESSAGE TEXT-e01 TYPE zcon_msg_e.
      ENDIF.
  
      IF gs_tc_return-consum IS INITIAL AND
         gs_tc_return-scrap  IS NOT INITIAL.
        lcl_data_manager=>gv_crsr_fld = c_scrn_scrap .
        SET CURSOR FIELD lcl_data_manager=>gv_crsr_fld LINE lcl_data_manager=>gv_crsr_line.
        MESSAGE TEXT-e02 TYPE zcon_msg_e.
      ENDIF.
  
    ENDIF.
  
    " Initially saved data in ztable zmm_scanreel_ret
    SORT lcl_data_manager=>gt_scanreel BY material charg timestamp.
    READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_log>) WITH KEY material = gs_tc_return-matnr
                                                                                        charg    = gs_tc_return-charg
                                                                                        timestamp = gs_tc_return-varnm BINARY SEARCH.
    IF sy-subrc IS INITIAL AND <lfs_log> IS ASSIGNED.
      <lfs_log>-menge_consum = gs_tc_return-consum.
      <lfs_log>-menge_scrap  = gs_tc_return-scrap.
    ENDIF.
  
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
  
    IF lcl_data_manager=>gv_failed IS INITIAL.
      MODIFY gt_tc_return
        FROM gs_tc_return
       INDEX tcr-current_line
       TRANSPORTING scrap consum.
    ENDIF.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_tcr_change_tc_attr
  *&---------------------------------------------------------------------*
  FORM f_tcr_change_tc_attr .
  
    tcr-lines = lines( gt_tc_return ).
  
    CLEAR: gv_tot_count,
           gv_tot_consu,
           gv_tot_scrap,
           gv_tot_new.
  
    " Process Counts
    LOOP AT gt_tc_return ASSIGNING FIELD-SYMBOL(<lfs_tc_return>).
      IF <lfs_tc_return> IS ASSIGNED.
  
        <lfs_tc_return>-ncount = <lfs_tc_return>-pcount - ( <lfs_tc_return>-consum + <lfs_tc_return>-scrap ).
  
        gv_tot_count = gv_tot_count + <lfs_tc_return>-pcount.
        gv_tot_consu = gv_tot_consu + <lfs_tc_return>-consum.
        gv_tot_scrap = gv_tot_scrap + <lfs_tc_return>-scrap.
        gv_tot_new   = gv_tot_new   + <lfs_tc_return>-ncount.
      ENDIF.
    ENDLOOP.
    SET CURSOR FIELD lcl_data_manager=>gv_crsr_fld LINE lcl_data_manager=>gv_crsr_line.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_tcr_get_lines
  *&---------------------------------------------------------------------*
  FORM f_tcr_get_lines.
  
    READ TABLE lcl_data_manager=>gt_scanreel ASSIGNING FIELD-SYMBOL(<lfs_scanreel>) WITH KEY material  = gs_tc_return-matnr
                                                                                             charg     = gs_tc_return-charg
                                                                                             timestamp = gs_tc_return-varnm
                                                                                             BINARY SEARCH.
  
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN c_scrn_consum.
          IF <lfs_scanreel>-mblnr_consume IS NOT INITIAL.
            screen-input = zcon_mod_off.
          ELSE.
            screen-input = zcon_mod_on.
          ENDIF.
          MODIFY SCREEN.
        WHEN c_scrn_scrap.
          IF <lfs_scanreel>-mblnr_scrap IS NOT INITIAL.
            screen-input = zcon_mod_off.
          ELSE.
            screen-input = zcon_mod_on.
          ENDIF.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_bapi_e_message
  *&---------------------------------------------------------------------*
  *&  BAPI return Message
  *&---------------------------------------------------------------------*
  FORM f_bapi_e_message USING p_type       TYPE bapireturn-type
                              p_msgcl      TYPE sy-msgid
                              p_msgno      TYPE sy-msgno
                              p_par1       TYPE sy-msgv1
                              p_par2       TYPE sy-msgv2
                              p_par3       TYPE sy-msgv3
                              p_par4       TYPE sy-msgv4
                     CHANGING p_gv_message TYPE bapiret2-message.
  
    DATA: ls_bapiret2       TYPE bapiret2.
  
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
  *& Form f_convert_tanum
  *&---------------------------------------------------------------------*
  FORM f_convert_tanum  CHANGING p_lv_tanum TYPE tanum.
  
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = p_lv_tanum
      IMPORTING
        output = p_lv_tanum.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form f_validate_input
  *&---------------------------------------------------------------------*
  *& Input Validation
  *&---------------------------------------------------------------------*
  FORM f_validate_input.
  
    " Plant Validation.
    IF p_werks IS INITIAL.
      MESSAGE TEXT-e18 TYPE zcon_msg_e.
    ELSE.
      SELECT werks
        FROM t001w
       WHERE werks = @p_werks
       INTO @DATA(lv_werks)
        UP TO 1 ROWS.
      ENDSELECT.
  
      IF lv_werks IS INITIAL.
        MESSAGE TEXT-e19 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_werks.
      ENDIF.
    ENDIF.
  
    " Source storage location validation.
    IF p_lgorts IS INITIAL.
      MESSAGE TEXT-e20 TYPE zcon_msg_e.
    ELSE.
      SELECT lgort
        FROM t001l
       WHERE werks = @p_werks
         AND lgort = @p_lgorts
        INTO @DATA(lv_lgort)
       UP TO 1 ROWS.
      ENDSELECT.
  
      IF lv_lgort IS INITIAL.
        MESSAGE TEXT-e21 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_lgort.
      ENDIF.
    ENDIF.
  
    " STR Number validation.
    IF p_strn IS INITIAL.
      MESSAGE TEXT-e22 TYPE zcon_msg_e.
      RETURN.
    ENDIF.
  
    " Get Warehouse Number (LGNUM) from table T320.
    IF p_werks IS NOT INITIAL AND
      p_lgorts  IS NOT INITIAL.
      PERFORM f_get_lgnum.
    ENDIF.
  
    " Destination Bin validation.
    IF p_lgpla IS INITIAL.
      MESSAGE TEXT-e06 TYPE zcon_msg_e.
    ELSE.
      SELECT lgpla
        FROM lagp
       WHERE lgnum = @lcl_data_manager=>gv_lgnum
         AND lgtyp IS NOT INITIAL
         AND lgpla = @p_lgpla
        ORDER BY lgnum
        INTO @DATA(lv_lgpla)
          UP TO 1 ROWS.
      ENDSELECT.
      IF lv_lgpla IS INITIAL.
        MESSAGE TEXT-e36 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_lgpla.
      ENDIF.
    ENDIF.
  
    " Destination storage location validation.
    IF p_lgortd IS INITIAL.
      MESSAGE TEXT-e23 TYPE zcon_msg_e.
    ELSE.
      SELECT lgort
        FROM t001l
       WHERE werks = @p_werks
         AND lgort = @p_lgortd
        INTO @DATA(lv_lgort_v)
        UP TO 1 ROWS.
      ENDSELECT.
      IF lv_lgort_v IS INITIAL.
        MESSAGE TEXT-e37 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_lgort_v.
      ENDIF.
    ENDIF.
  
    " Warehouse Movement validation.
    IF p_mov_wm IS INITIAL.
      MESSAGE TEXT-e24 TYPE zcon_msg_e.
    ELSE.
      SELECT bwlvs
        FROM t333
       WHERE lgnum = @lcl_data_manager=>gv_lgnum
         AND bwlvs = @p_mov_wm
        INTO @DATA(lv_mov_wm)
        UP TO 1 ROWS.
      ENDSELECT.
      IF lv_mov_wm IS INITIAL.
        MESSAGE TEXT-e25 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_mov_wm.
      ENDIF.
    ENDIF.
  
    " Inv. Mov. Transfer validation.
    IF p_mov_in IS INITIAL.
      MESSAGE TEXT-e30 TYPE zcon_msg_e.
    ELSE.
      SELECT bwart
        FROM t156
       WHERE bwart = @p_mov_in
        INTO @DATA(lv_mov_in)
        UP TO 1 ROWS.
      ENDSELECT.
      IF lv_mov_in IS INITIAL.
        MESSAGE TEXT-e31 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_mov_in.
      ENDIF.
    ENDIF.
  
    " Consumption Movement validation.
    IF p_mov_co IS INITIAL.
      MESSAGE TEXT-e32 TYPE zcon_msg_e.
    ELSE.
      SELECT bwart
        FROM t156
       WHERE bwart = @p_mov_co
        INTO @DATA(lv_mov_co)
       UP TO 1 ROWS.
      ENDSELECT.
  
      IF lv_mov_co IS INITIAL.
        MESSAGE TEXT-e33 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_mov_co.
      ENDIF.
    ENDIF.
  
    " Scrap Movement validation.
    IF p_mov_sc IS INITIAL.
      MESSAGE TEXT-e34 TYPE zcon_msg_e.
    ELSE.
      SELECT bwart
        FROM t156
       WHERE bwart = @p_mov_sc
        INTO @DATA(lv_mov_sc)
       UP TO 1 ROWS.
      ENDSELECT.
  
      IF lv_mov_sc IS INITIAL.
        MESSAGE TEXT-e35 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_mov_sc.
      ENDIF.
    ENDIF.
  
    " Cost center validation
    IF p_kostl IS INITIAL.
      MESSAGE TEXT-e26 TYPE zcon_msg_e.
    ELSE.
  
      " Get company code
      SELECT bukrs
        FROM t001k
       UP TO 1 ROWS
       INTO @DATA(lv_bukrs)
       WHERE bwkey = @p_werks.
      ENDSELECT.
  
      IF lv_bukrs IS NOT INITIAL.
  
        " Get Controlling area
        SELECT kokrs
          FROM tka02
          WHERE bukrs = @lv_bukrs
            AND gsber IS INITIAL
           INTO @DATA(lv_kokrs)
          UP TO 1 ROWS.
        ENDSELECT.
  
        SELECT kostl
          FROM csks
            UP TO 1 ROWS
          INTO @DATA(lv_kostl1)
         WHERE kokrs EQ @lv_kokrs
           AND kostl EQ @p_kostl
           AND datbi GE @sy-datum
           AND datab LE @sy-datum
         ORDER BY kokrs, kostl, datbi.
        ENDSELECT.
  
        IF lv_kostl1 IS INITIAL.
          MESSAGE TEXT-e27 TYPE zcon_msg_e.
        ELSE.
          CLEAR lv_kostl1.
        ENDIF.
      ENDIF.
    ENDIF.
  
    " Reason for Movement validation
    IF p_reas_m IS INITIAL.
      MESSAGE TEXT-e28 TYPE zcon_msg_e.
    ELSE.
      SELECT grund
        FROM t157d
       WHERE bwart = @p_mov_co
         AND grund = @p_reas_m
       INTO @DATA(lv_grund)
       UP TO 1 ROWS.
      ENDSELECT.
      IF lv_grund IS INITIAL.
        MESSAGE TEXT-e29 TYPE zcon_msg_e.
      ELSE.
        CLEAR lv_grund.
      ENDIF.
    ENDIF.
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