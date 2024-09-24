*&---------------------------------------------------------------------*
*& Include ZTC_PRACTICE_O01
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_DISPLAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ztc_display_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_vbak LINES ztc_display-lines.
  IF gt_vbak IS INITIAL AND gv_sales_doc_no IS INITIAL AND gv_doc_type IS INITIAL .

    SELECT vbeln
           erdat
           vbtyp
      FROM vbak
      INTO CORRESPONDING FIELDS OF TABLE gt_vbak
      UP   TO 10 ROWS .
    IF sy-subrc EQ 0.
      REFRESH gt_temp_main_data.
      MOVE-CORRESPONDING gt_vbak TO gt_temp_main_data.
    ENDIF.

  ENDIF.

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_DISPLAY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ztc_display_get_lines OUTPUT.
  g_ztc_display_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_EDIT_VAR'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ztc_edit_var_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_variant_data LINES ztc_edit_var-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_EDIT_VAR'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ztc_edit_var_get_lines OUTPUT.
  g_ztc_edit_var_lines = sy-loopc.
  IF gt_variant_data IS NOT INITIAL.
    IF gs_variant_data-varia IS INITIAL.
      LOOP AT SCREEN.
        IF screen-name =  'GS_VARIANT_DATA-VARIA'.
          screen-input = 1.
        ELSEIF screen-name =  'GS_VARIANT_DATA-VBTYP'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSEIF gs_variant_data-varia IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-name =  'GS_VARIANT_DATA-VARIA'.
          screen-input = 1.
        ELSEIF screen-name =  'GS_VARIANT_DATA-VBTYP'.
          screen-input = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  " ----------Start of Code for Sales document no dropdown-------------
  IF gv_sales_doc_no IS INITIAL OR gv_flag_for_filter_update EQ 'X'.

    DATA: gv_sales_doc_no_ID     TYPE vrm_id,
          it_values_sales_doc_no TYPE vrm_values,
          wa_values_sales_doc_no LIKE LINE OF it_values_sales_doc_no,
          lt_sales_doc_no_data   TYPE TABLE OF vbak-vbeln,
          ls_sales_doc_no_data   TYPE vbak-vbeln.


    REFRESH it_values_sales_doc_no.

    SELECT vbeln                                       "bringing charg data from lqua based on matnr
      FROM vbak
      FOR  ALL ENTRIES IN @gt_temp_main_data
      WHERE vbeln = @gt_temp_main_data-vbeln
      INTO TABLE @lt_sales_doc_no_data.

    IF lt_sales_doc_no_data IS NOT INITIAL.

*      DELETE ADJACENT DUPLICATES FROM lt_charg_data.

      LOOP AT lt_sales_doc_no_data INTO ls_sales_doc_no_data.
        wa_values_sales_doc_no-key  = ls_sales_doc_no_data.
        wa_values_sales_doc_no-text = ls_sales_doc_no_data.
        APPEND wa_values_sales_doc_no TO it_values_sales_doc_no.
        CLEAR wa_values_sales_doc_no.
      ENDLOOP.

      gv_sales_doc_no_ID = 'gv_sales_doc_no'.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = gv_sales_doc_no_ID
          values          = it_values_sales_doc_no
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.

      IF gv_flag_for_filter_update EQ 'X'.
        CLEAR gv_sales_doc_no.                          "Making the sales doc number initial.
        CLEAR gv_flag_for_filter_update.
      ENDIF.
    ENDIF.

  ENDIF.
  " ----------End of Code for Sales document no dropdown-------------


  " ----------Start of Code for Sales document type dropdown-------------
  IF gv_doc_type IS INITIAL OR gv_flag_for_filter_update EQ 'X'.

    DATA: gv_doc_type_ID       TYPE vrm_id,
          it_values_doc_type   TYPE vrm_values,
          wa_values_doc_type   LIKE LINE OF it_values_doc_type,
          lt_doc_type_data     TYPE TABLE OF vbak-vbtyp,
          ls_doc_type_data     TYPE vbak-vbtyp,
          doc_type_still_exist TYPE vbak-vbtyp.


    REFRESH it_values_doc_type.

    SELECT vbtyp                                       "bringing charg data from lqua based on matnr
      FROM vbak
      FOR  ALL ENTRIES IN @gt_temp_main_data
      WHERE vbeln = @gt_temp_main_data-vbeln
      INTO TABLE @lt_doc_type_data.

    IF lt_doc_type_data IS NOT INITIAL.

      DELETE ADJACENT DUPLICATES FROM lt_doc_type_data.

      IF gv_flag_for_filter_update EQ 'X'.
        READ TABLE lt_doc_type_data INTO doc_type_still_exist WITH KEY gv_doc_type.
        IF sy-subrc NE 0.
          CLEAR gv_doc_type.
        ENDIF.
        CLEAR gv_flag_for_filter_update.
      ENDIF.

      LOOP AT lt_doc_type_data INTO ls_doc_type_data.
        wa_values_doc_type-key  = ls_doc_type_data.
        wa_values_doc_type-text = ls_doc_type_data.
        APPEND wa_values_doc_type TO it_values_doc_type.
        CLEAR wa_values_doc_type.
      ENDLOOP.

      gv_doc_type_ID = 'gv_doc_type'.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id              = gv_doc_type_ID
          values          = it_values_doc_type
        EXCEPTIONS
          id_illegal_name = 1
          OTHERS          = 2.

    ENDIF.

  ENDIF.
  " ----------End of Code for Sales document type dropdown-------------




ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZMODEL_DIALOG_GUI_ST'.
  SET TITLEBAR 'ZMODEL_DIALOG_TITLE'.
  IF gt_multiple_variant_def IS NOT INITIAL AND  lv_multivar_scr_firstrun_flg EQ 'X'.
    READ TABLE gt_multiple_variant_def INTO DATA(gs_multiple_var_temp) INDEX 1.
    gs_multiple_variant-vbtyp = gs_multiple_var_temp-vbtyp.
    CLEAR gv_netwr.
    LOOP AT gt_multiple_variant_def INTO gs_multiple_variant_def.
      gs_multiple_variant-netwr = gs_multiple_variant-netwr + gs_multiple_variant_def-netwr.
      gv_netwr = gv_netwr + gs_multiple_variant_def-netwr.
    ENDLOOP.
    CLEAR lv_multivar_scr_firstrun_flg.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_MULTI_VAR'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ztc_multi_var_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_multiple_variant_def LINES ztc_multi_var-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_MULTI_VAR'. DO NOT CHANGE THIS LIN
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ztc_multi_var_get_lines OUTPUT.
  g_ztc_multi_var_lines = sy-loopc.
  IF gs_multiple_variant_def-varia IS INITIAL AND gs_multiple_variant_def-varf_n IS INITIAL AND sy-ucomm EQ 'FC_VAR_DEF'.
    LOOP AT SCREEN.
      IF screen-name = 'GS_MULTIPLE_VARIANT_DEF-VARIA' OR screen-name = 'GS_MULTIPLE_VARIANT_DEF-NETWR'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF ( gs_multiple_variant_def-varia IS INITIAL AND gs_multiple_variant_def-varf_n IS INITIAL AND sy-ucomm EQ 'ENTER' ) OR
         ( gs_multiple_variant_def-varia IS INITIAL AND gs_multiple_variant_def-varf_n IS NOT INITIAL AND sy-ucomm EQ 'ENTER' ).
    LOOP AT SCREEN.
      IF screen-name = 'GS_MULTIPLE_VARIANT_DEF-VARIA'.
        screen-input = 1.
        MESSAGE 'Please Enter a Variant Name' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF gv_total_count_flg EQ 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'GS_MULTIPLE_VARIANT_DEF-NETWR'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF ( gs_multiple_variant_def-varia IS NOT INITIAL AND gs_multiple_variant_def-varf_n IS NOT INITIAL AND ( sy-ucomm EQ 'ENTER' OR sy-ucomm EQ 'FC_EXECUTE_MDS' ) )    OR
         ( gs_multiple_variant_def-varia IS NOT INITIAL AND gs_multiple_variant_def-varf_n IS NOT INITIAL AND gv_del_rec_flag_mdbx EQ 'X' )                                OR     "Condition for Delete record
         ( gs_multiple_variant_def-varia IS     INITIAL AND gs_multiple_variant_def-varf_n IS     INITIAL AND gv_del_rec_flag_mdbx EQ 'X' ).                                      "Condition for Delete record
    LOOP AT SCREEN.
      IF screen-name = 'GS_MULTIPLE_VARIANT_DEF-VARIA' OR screen-name = 'GS_MULTIPLE_VARIANT_DEF-NETWR'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.