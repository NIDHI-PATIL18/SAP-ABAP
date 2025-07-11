*----------------------------------------------------------------------*
***INCLUDE ZMM_RETURN_WFSTR_I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'RETURN_NC' OR 'PROCESS'.
      REFRESH gt_bktxt_data.
      SELECT mblnr,                            "Getting BKTXT data from MKPF
             bktxt
        FROM mkpf
       WHERE bktxt = @gv_str_num
       INTO  TABLE @gt_bktxt_data.

      IF gt_bktxt_data IS NOT INITIAL.

        SELECT mblnr,
               matnr,
               charg,
               menge,
               lgpla,
               lgort,
               meins
          FROM mseg
           FOR ALL ENTRIES IN @gt_bktxt_data
         WHERE mblnr = @gt_bktxt_data-mblnr
           AND lgort = @gs_mseg-lgort
           AND werks = @gs_mseg-werks
          INTO TABLE @gt_mseg_data.

        IF gt_mseg_data IS NOT INITIAL.
          IF sy-ucomm EQ 'PROCESS'.
            gv_fill_tc_flag = 'X'.
            CALL SCREEN 0200.
          ELSEIF sy-ucomm EQ 'RETURN_NC'.
            CLEAR gs_goodsmvt_header.
            gs_goodsmvt_header-header_txt = gv_str_num.
            CLEAR gt_goodsmvt_item.
            LOOP AT gt_mseg_data INTO gs_mseg_data.
              gs_goodsmvt_item-material  = gs_mseg_data-matnr.
              gs_goodsmvt_item-plant     = gs_mseg-werks.                          "From Selection Screen
              gs_goodsmvt_item-stge_loc  = gs_mseg-lgort.                          "From Selection Screen
              gs_goodsmvt_item-batch     = gs_mseg_data-charg.
              gs_goodsmvt_item-move_type = '311'.
*              gs_goodsmvt_item-entry_qnt = '0'.
              gs_goodsmvt_item-entry_uom = gs_mseg_data-meins.
              APPEND gs_goodsmvt_item TO gt_goodsmvt_item.
              CLEAR gs_goodsmvt_item.
            ENDLOOP.
            IF gt_goodsmvt_item IS NOT INITIAL.
*                 CALL FUNCTION 'BAPI_GOODSMVT_CREATE'                                "Currently Gives a Dump because Importing param 'goodsmvt_code' not provided
*                   EXPORTING
*                     goodsmvt_header               = gs_goodsmvt_header
**                    goodsmvt_code                 =                                 "Required param
**                    TESTRUN                       = ' '
**                    GOODSMVT_REF_EWM              =
**                    GOODSMVT_PRINT_CTRL           =
**                  IMPORTING
**                    GOODSMVT_HEADRET              =
**                    MATERIALDOCUMENT              =
**                    MATDOCUMENTYEAR               =
*                   TABLES
*                     goodsmvt_item                 = gt_goodsmvt_item
**                    GOODSMVT_SERIALNUMBER         =
*                     return                        = gt_return_msg
**                    GOODSMVT_SERV_PART_DATA       =
**                    EXTENSIONIN                   =
**                    GOODSMVT_ITEM_CWM             =
*                           .

              IF gt_return_msg IS NOT INITIAL.

              ENDIF.

            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE 'No Data Present for the entered Plant and Source Storage Location or the Plant is empty' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.

      ELSE.
        MESSAGE 'No Data Present for the entered STRs Number' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'TEST'.
      DATA gt_links LIKE tline OCCURS 0.

      "display help document
      CALL FUNCTION 'HELP_OBJECT_SHOW'
        EXPORTING
          dokclass = 'TX'
          dokname  = 'ZINFOR'
        TABLES
          links    = gt_links.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  IF sy-ucomm EQ 'BACK'.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_PROCESS'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ztc_process_modify INPUT.
  MODIFY gt_tc_main
    FROM gs_tc_main
    INDEX ztc_process-current_line.

  IF gs_tc_main-consumption IS NOT INITIAL OR gs_tc_main-scrap IS NOT INITIAL.
    gv_total_of_scrap_consum = gs_tc_main-consumption + gs_tc_main-scrap.
    IF gv_total_of_scrap_consum LE gs_tc_main-prev_count.

    ELSE.
      IF gs_tc_main-consumption GT gs_tc_main-prev_count.
        APPEND gs_tc_main-mblnr TO gv_mblnr.
        gv_consumption_gt = 'X'.
        MESSAGE 'Consumption is greater than Prev. Count Please reduce the value of Consumption' TYPE 'S' DISPLAY LIKE 'E'.
      ELSEIF gs_tc_main-scrap GT gs_tc_main-prev_count.
        APPEND gs_tc_main-mblnr TO gv_mblnr.
        gv_scrap_gt = 'X'.
        MESSAGE 'Scrap is greater than Prev. Count Please reduce the value of Scrap' TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        APPEND gs_tc_main-mblnr TO gv_mblnr.
        gv_combination_gt = 'X'.
        MESSAGE 'Combination of both Consumption and Scrap is greater than Prev. Count' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC_PROCESS'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ztc_process_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'ZTC_PROCESS'
                              'GT_TC_MAIN'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ZBAPI_CREATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE zbapi_create INPUT.

  CASE sy-ucomm.
    WHEN 'EXECUTE'.
      LOOP AT gt_tc_main INTO gs_tc_main.

        IF gs_tc_main-consumption IS NOT INITIAL AND gs_tc_main-scrap IS NOT INITIAL.

        ENDIF.

        IF gs_tc_main-scrap IS NOT INITIAL.


        ELSEIF gs_tc_main-consumption IS INITIAL AND gs_tc_main-scrap IS INITIAL.

        ENDIF.
      ENDLOOP.

  ENDCASE.

ENDMODULE.