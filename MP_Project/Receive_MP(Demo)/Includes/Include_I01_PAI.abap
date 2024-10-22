*&---------------------------------------------------------------------*
*& Include ZTC_PRACTICE_I01
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_DISPLAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ztc_display_mark INPUT.
  DATA: g_ZTC_DISPLAY_wa2 LIKE LINE OF gt_vbak.
  IF ztc_display-line_sel_mode = 1
  AND gs_vbak-sel_flag = 'X'.
    LOOP AT gt_vbak INTO g_ZTC_DISPLAY_wa2
      WHERE sel_flag = 'X'.
      g_ZTC_DISPLAY_wa2-sel_flag = ''.
      MODIFY gt_vbak
        FROM g_ZTC_DISPLAY_wa2
        TRANSPORTING sel_flag.
    ENDLOOP.
  ENDIF.
  MODIFY gt_vbak
    FROM gs_vbak
    INDEX ztc_display-current_line
    TRANSPORTING sel_flag.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_DISPLAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ztc_display_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'ZTC_DISPLAY'
                              'GT_VBAK'
                              'SEL_FLAG'
                              'NETWR'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_EDIT_VAR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ztc_edit_var_modify INPUT.
  MODIFY gt_variant_data
    FROM gs_variant_data
    INDEX ztc_edit_var-current_line.

* ---------------------- testing code added by abhishek khainar --------
  IF gs_variant_data-varia IS INITIAL OR gs_variant_data-vbtyp IS INITIAL.

    IF gs_variant_data-varia IS INITIAL.
      MESSAGE 'Variant Name cannot be empty' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE 'Sales document Type cannot be empty' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_EDIT_VAR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ztc_edit_var_mark INPUT.
  DATA: g_ZTC_EDIT_VAR_wa2 LIKE LINE OF gt_variant_data.
  IF ztc_edit_var-line_sel_mode = 1
  AND gs_variant_data-sel_flag = 'X'.
    LOOP AT gt_variant_data INTO g_ZTC_EDIT_VAR_wa2
      WHERE sel_flag = 'X'.
      g_ZTC_EDIT_VAR_wa2-sel_flag = ''.
      MODIFY gt_variant_data
        FROM g_ZTC_EDIT_VAR_wa2
        TRANSPORTING sel_flag.
    ENDLOOP.
  ENDIF.
  MODIFY gt_variant_data
    FROM gs_variant_data
    INDEX ztc_edit_var-current_line
    TRANSPORTING sel_flag.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_EDIT_VAR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ztc_edit_var_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'ZTC_EDIT_VAR'
                              'GT_VARIANT_DATA'
                              'SEL_FLAG'
                              'NETWR'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate INPUT.

  gv_old_salesdoc_no   = gv_sales_doc_no.
  gv_old_salesdoc_type = gv_doc_type.

  CASE sy-ucomm.
    WHEN 'FC_SV_DEF'.

      DATA(counter) = 0.
      LOOP AT gt_vbak INTO DATA(ls_vbak) WHERE sel_flag IS NOT INITIAL.
        counter = counter + 1.
      ENDLOOP.
      IF counter GT 1.
        MESSAGE 'Only Single record selection is allowded' TYPE 'S' DISPLAY LIKE 'E'.
      ELSEIF counter NE 0.
*  -------------------  start of pop-up code for single variant definition's default variable name input field ---------------------------
        DATA: t_fields LIKE sval OCCURS 0 WITH HEADER LINE.
        CLEAR t_fields[].
        t_fields-tabname = 'ZTAB_SINGLE_VARI'.
        t_fields-fieldname =  'ZDEFAULT_VARINAME'.
        CLEAR t_fields-value.
        APPEND t_fields.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
*           NO_VALUE_CHECK  = 'X'
            popup_title     = 'Single Variant Definition'
*           START_COLUMN    = '5'
*           START_ROW       = '5'
*   IMPORTING
*           RETURNCODE      = lv_return_val
          TABLES
            fields          = t_fields[]
          EXCEPTIONS
            error_in_fields = 1
            OTHERS          = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*  -------------------  end of pop-up code for single variant definition's default variable name input field ---------------------------
        FIELD-SYMBOLS: <fs_t_fields_value> TYPE any.
        READ TABLE t_fields INDEX 1.
        ASSIGN COMPONENT 3 OF STRUCTURE t_fields TO <fs_t_fields_value>.   "Getting the value user entered value.
        CONDENSE <fs_t_fields_value>.                                      "Code to remove leading and tailing spaces

        IF <fs_t_fields_value> IS NOT INITIAL.
          READ TABLE gt_vbak INTO gs_vbak WITH KEY sel_flag = 'X'.
          gs_variant_data-vbeln  = gs_vbak-vbeln.
          gs_variant_data-varia  = <fs_t_fields_value>.
          gs_variant_data-varf_n = gs_vbak-vbeln && '-' && <fs_t_fields_value>.
          gs_variant_data-vbtyp  = gs_vbak-vbtyp.
          APPEND gs_variant_data TO gt_variant_data.
          DELETE gt_vbak WHERE vbeln = gs_vbak-vbeln.
          IF sy-subrc EQ 0.
            DELETE gt_temp_main_data WHERE vbeln = gs_vbak-vbeln.
            CLEAR gs_vbak.
            IF gt_vbak IS INITIAL.                                       "If table gt_vbak is empty then only append 'temp' internal table data to gt_vbak
              MOVE-CORRESPONDING gt_temp_main_data TO gt_vbak.
              gv_flag_for_filter_update = 'X'.                           "Also recheck the dropdown
            ENDIF.
          ENDIF.
          gs_old_variant_names-varia = gs_variant_data-varia.
          gs_old_variant_names-vbeln = gs_variant_data-vbeln.
          APPEND gs_old_variant_names TO gt_old_variant_names.           "Getting old variants names.
          CLEAR gs_variant_data.
        ENDIF.
      ELSE.
        MESSAGE 'Select at least one record' TYPE 'S' DISPLAY LIKE 'E'.   "If no record was selected and pressed single variant definition button.
      ENDIF.

    WHEN 'FC_VAR_DEF'.
* ------------------------- Code for Adding data to gt_multiple_variant_def table ------------------------
      CLEAR gs_vbak.
      REFRESH gt_multiple_variant_def.
      DATA(lv_counter_multiple) = 0.
      DATA: lv_first_doc_type  TYPE vbak-vbtyp,
            lv_second_doc_type TYPE vbak-vbtyp.
      CLEAR lv_first_doc_type.
      CLEAR lv_second_doc_type.

      LOOP AT gt_vbak INTO DATA(ls_vbak_1) WHERE sel_flag IS NOT INITIAL.
        IF lv_counter_multiple EQ 0.
          lv_first_doc_type = ls_vbak_1-vbtyp.
        ELSEIF lv_counter_multiple EQ 1.
          LOOP AT gt_vbak INTO DATA(gs_different_doc_type) WHERE sel_flag = 'X' AND vbtyp NE lv_first_doc_type.
            lv_second_doc_type = gs_different_doc_type-vbtyp.
            IF lv_second_doc_type IS NOT INITIAL.
              CLEAR gs_different_doc_type.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF sy-subrc NE 0.
            lv_second_doc_type = ls_vbak_1-vbtyp.
          ENDIF.
        ENDIF.
        lv_counter_multiple = lv_counter_multiple + 1.
      ENDLOOP.

      IF lv_counter_multiple GT 1.
        IF lv_first_doc_type EQ lv_second_doc_type.
          LOOP AT gt_vbak INTO gs_vbak WHERE sel_flag = 'X'.
            CLEAR gs_multiple_variant_def.
            SELECT SINGLE  netwr
                     FROM  vbak
                     WHERE vbeln = @gs_vbak-vbeln
                     INTO  @DATA(ls_netwr_data).
            IF ls_netwr_data IS NOT INITIAL.
              gs_multiple_variant_def-vbeln = gs_vbak-vbeln.
              gs_multiple_variant_def-erdat = gs_vbak-erdat.
              gs_multiple_variant_def-vbtyp = gs_vbak-vbtyp.
              gs_multiple_variant_def-netwr = ls_netwr_data.
              APPEND gs_multiple_variant_def TO gt_multiple_variant_def.
              CLEAR gs_multiple_variant_def.
            ENDIF.
            CLEAR gs_vbak.
          ENDLOOP.
        ELSE.
          MESSAGE 'Sales document type must be same' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSEIF lv_counter_multiple NE 0.
        READ TABLE gt_vbak INTO gs_vbak WITH KEY sel_flag = 'X'.
        IF gs_vbak IS NOT INITIAL.
          SELECT SINGLE  netwr
                   FROM  vbak
                   WHERE vbeln = @gs_vbak-vbeln
                   INTO  @DATA(ls_netwr_data_sigle_rec).
          IF ls_netwr_data_sigle_rec IS NOT INITIAL.
            gs_multiple_variant_def-vbeln = gs_vbak-vbeln.
            gs_multiple_variant_def-erdat = gs_vbak-erdat.
            gs_multiple_variant_def-vbtyp = gs_vbak-vbtyp.
            gs_multiple_variant_def-netwr = ls_netwr_data_sigle_rec.
            APPEND gs_multiple_variant_def TO gt_multiple_variant_def.
            CLEAR gs_multiple_variant_def.
          ENDIF.
          CLEAR gs_vbak.
        ENDIF.
      ENDIF.
* ------------------------- Code for Adding data to gt_multiple_variant_def table ------------------------
      IF sy-subrc NE 0.
        MESSAGE 'No record selected, Please select either one or multiple' TYPE 'S' DISPLAY LIKE 'E'.     "Error msg if no record is selected.
      ENDIF.

*-------------------------- Code for calling Model dialoge screen-----------------------------------------
      lv_multivar_scr_firstrun_flg = 'X'.

      IF gt_multiple_variant_def IS NOT INITIAL.
        CALL SCREEN 0200 STARTING AT 5 5
                         ENDING   AT 131 30.

      ENDIF.
*-------------------------- Code for calling Model dialoge screen-----------------------------------------
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FILTER_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE filter_data INPUT.

  IF gv_sales_doc_no IS INITIAL AND gv_doc_type IS INITIAL.
    READ TABLE gt_vbak INTO gs_vbak WITH KEY sel_flag = 'X'.
    DATA(lv_sel_bool) = COND #( WHEN gs_vbak IS NOT INITIAL
      THEN abap_true
      ELSE abap_false ).
    CLEAR gs_vbak.
  ENDIF.

  IF ( gv_sales_doc_no NE gv_old_salesdoc_no OR gv_doc_type NE gv_old_salesdoc_type ) OR lv_sel_bool EQ abap_true.
    IF gv_sales_doc_no IS INITIAL  AND  gv_doc_type IS INITIAL.
      READ TABLE gt_vbak INTO gs_vbak WITH KEY sel_flag = 'X'.
      lv_sel_bool = abap_false.
      IF sy-subrc EQ 0.
        DESCRIBE TABLE gt_temp_main_data LINES DATA(gv_temp_main_lenght).
        DESCRIBE TABLE gt_vbak LINES DATA(gv_vbak_lenght).
        IF gv_vbak_lenght NE gv_temp_main_lenght.
          REFRESH gt_vbak.
          MOVE-CORRESPONDING gt_temp_main_data TO gt_vbak.
        ENDIF.
      ELSE.
        REFRESH gt_vbak.
        MOVE-CORRESPONDING gt_temp_main_data TO gt_vbak.
      ENDIF.
    ELSEIF gv_sales_doc_no IS INITIAL  OR  gv_doc_type IS INITIAL.
      IF gv_sales_doc_no IS INITIAL.
        REFRESH gt_vbak.
        MOVE-CORRESPONDING gt_temp_main_data TO gt_vbak.
        DELETE gt_vbak WHERE vbtyp <> gv_doc_type.
      ELSE.
        REFRESH gt_vbak.
        MOVE-CORRESPONDING gt_temp_main_data TO gt_vbak.
        DELETE gt_vbak WHERE vbeln <> gv_sales_doc_no.
      ENDIF.
    ELSEIF gv_sales_doc_no IS NOT INITIAL  AND  gv_doc_type IS NOT INITIAL.
      REFRESH gt_vbak.
      LOOP AT gt_temp_main_data INTO gs_temp_main_data WHERE vbeln = gv_sales_doc_no AND vbtyp = gv_doc_type.
        gs_vbak-sel_flag = gs_temp_main_data-sel_flag.
        gs_vbak-vbeln = gs_temp_main_data-vbeln.
        gs_vbak-vbtyp = gs_temp_main_data-vbtyp.
        gs_vbak-erdat = gs_temp_main_data-erdat.
        APPEND gs_vbak TO gt_vbak.
        CLEAR gs_vbak.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_VARIANT_FN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_variant_fn INPUT.

  LOOP AT gt_variant_data INTO gs_variant_data.
    LOOP AT gt_old_variant_names INTO gs_old_variant_names WHERE vbeln = gs_variant_data-vbeln.
      IF gs_variant_data-varia NE gs_old_variant_names-varia.
        gs_variant_data-varf_n = gs_variant_data-vbeln && '-' && gs_variant_data-varia.
        MODIFY gt_variant_data FROM gs_variant_data TRANSPORTING varf_n.
        gs_old_variant_names-varia = gs_variant_data-varia.
        MODIFY gt_old_variant_names FROM gs_old_variant_names TRANSPORTING varia.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_MULTI_VAR'. DO NOT CHANGE THIS LINE
*&SPWIZARD: MODIFY TABLE
MODULE ztc_multi_var_modify INPUT.
  MODIFY gt_multiple_variant_def
    FROM gs_multiple_variant_def
    INDEX ztc_multi_var-current_line.

ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'ZTC_MULTI_VAR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE ztc_multi_var_mark INPUT.
  DATA: g_ZTC_MULTI_VAR_wa2 LIKE LINE OF gt_multiple_variant_def.
  IF ztc_multi_var-line_sel_mode = 1
  AND gs_multiple_variant_def-sel_flag = 'X'.
    LOOP AT gt_multiple_variant_def INTO g_ZTC_MULTI_VAR_wa2
      WHERE sel_flag = 'X'.
      g_ZTC_MULTI_VAR_wa2-sel_flag = ''.
      MODIFY gt_multiple_variant_def
        FROM g_ZTC_MULTI_VAR_wa2
        TRANSPORTING sel_flag.
    ENDLOOP.
  ENDIF.
  MODIFY gt_multiple_variant_def
    FROM gs_multiple_variant_def
    INDEX ztc_multi_var-current_line
    TRANSPORTING sel_flag.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_MULTI_VAR'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
MODULE ztc_multi_var_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'ZTC_MULTI_VAR'
                              'GT_MULTIPLE_VARIANT_DEF'
                              'SEL_FLAG'
                              'NETWR'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCEL' OR 'FC_BACK_TO_PREVIOUS'.
      CLEAR gs_multiple_variant-netwr.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_MULTIPLE_VAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_multiple_var INPUT.
  CASE sy-ucomm.
    WHEN 'ENTER'.

*----------------------------------------- Code for Variant Full Name Update ------------------------------------------------------------
      CLEAR gs_multiple_variant_def.
      LOOP AT gt_multiple_variant_def INTO gs_multiple_variant_def.
        IF gs_multiple_variant_def-varia IS NOT INITIAL.
          CLEAR gs_old_variant_names_model_db.
          READ TABLE gt_old_variant_names_model_db INTO gs_old_variant_names_model_db WITH KEY vbeln = gs_multiple_variant_def-vbeln.
          DATA(lv_index_of_rec) = sy-tabix.
          IF gs_old_variant_names_model_db IS INITIAL.
            gs_old_variant_names_model_db-vbeln = gs_multiple_variant_def-vbeln.
            gs_old_variant_names_model_db-varia = gs_multiple_variant_def-varia.
            APPEND gs_old_variant_names_model_db TO gt_old_variant_names_model_db.
            gs_multiple_variant_def-varf_n = gs_multiple_variant_def-vbeln && '-' && gs_multiple_variant_def-varia.
            MODIFY gt_multiple_variant_def FROM gs_multiple_variant_def TRANSPORTING varf_n.
          ELSE.
            IF gs_multiple_variant_def-varia NE gs_old_variant_names_model_db-varia.
              gs_multiple_variant_def-varf_n = gs_multiple_variant_def-vbeln && '-' && gs_multiple_variant_def-varia.
              MODIFY gt_multiple_variant_def FROM gs_multiple_variant_def TRANSPORTING varf_n.
              gs_old_variant_names_model_db-varia = gs_multiple_variant_def-varia.
              MODIFY gt_old_variant_names_model_db INDEX lv_index_of_rec FROM gs_old_variant_names_model_db.
              CLEAR lv_index_of_rec.
            ENDIF.
            FIND FIRST OCCURRENCE OF gs_multiple_variant_def-varia IN gs_multiple_variant_def-varf_n.
            IF sy-subrc NE 0.
              gs_multiple_variant_def-varf_n = gs_multiple_variant_def-vbeln && '-' && gs_multiple_variant_def-varia.
              MODIFY gt_multiple_variant_def FROM gs_multiple_variant_def TRANSPORTING varf_n.
            ENDIF.
          ENDIF.
        ELSEIF gs_multiple_variant_def-varia IS INITIAL.
          IF gs_multiple_variant_def-varf_n IS NOT INITIAL.
            FIND FIRST OCCURRENCE OF '-' IN gs_multiple_variant_def-varf_n MATCH OFFSET DATA(lv_hyphen_pos).
            gs_multiple_variant_def-varf_n = substring( val = gs_multiple_variant_def-varf_n  off = 0 len = lv_hyphen_pos + 1 ).
            MODIFY gt_multiple_variant_def FROM gs_multiple_variant_def TRANSPORTING varf_n.
          ENDIF.
        ENDIF.
      ENDLOOP.
*----------------------------------------- Code for Variant Full Name Update ------------------------------------------------------------

*----------------------------------------- Code for Total Amount Calculation ------------------------------------------------------------
      CLEAR gs_multiple_variant_def.
      CLEAR gv_netwr.
      LOOP AT gt_multiple_variant_def INTO gs_multiple_variant_def.
        gv_netwr = gv_netwr + gs_multiple_variant_def-netwr.
      ENDLOOP.
*----------------------------------------- Code for Total Amount Calculation ------------------------------------------------------------


  WHEN 'FC_EXECUTE_MDS'.
    IF gv_netwr NE gs_multiple_variant-netwr.
      MESSAGE 'Total count should match Net Value.' TYPE 'S' DISPLAY LIKE 'E'.
      gv_total_count_flg = 'X'.
    ELSEIF gv_netwr EQ gs_multiple_variant-netwr.
      CLEAR gv_total_count_flg.
    ENDIF.

  ENDCASE.
ENDMODULE.