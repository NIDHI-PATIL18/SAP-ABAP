*&---------------------------------------------------------------------*
*& Include ZTC_PRACTICE_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
p_table_name
p_mark_name
p_netwr
CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
DATA: l_ok     TYPE sy-ucomm,
l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
SEARCH p_ok FOR p_tc_name.
IF sy-subrc <> 0.
EXIT.
ENDIF.
l_offset = strlen( p_tc_name ) + 1.
l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
CASE l_ok.
WHEN 'INSR'.                      "insert row
PERFORM fcode_insert_row USING    p_tc_name
               p_table_name.
CLEAR p_ok.

WHEN 'DELE'.                      "delete row
PERFORM fcode_delete_row USING    p_tc_name
               p_table_name
               p_mark_name
               p_netwr.
CLEAR p_ok.

WHEN 'P--' OR                     "top of list
'P-'  OR                     "previous page
'P+'  OR                     "next page
'P++'.                       "bottom of list
PERFORM compute_scrolling_in_tc USING p_tc_name
                   l_ok.
CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
WHEN 'MARK'.                      "mark all filled lines
PERFORM fcode_tc_mark_lines USING p_tc_name
               p_table_name
               p_mark_name   .
CLEAR p_ok.

WHEN 'DMRK'.                      "demark all filled lines
PERFORM fcode_tc_demark_lines USING p_tc_name
                 p_table_name
                 p_mark_name .
CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
USING    p_tc_name           TYPE dynfnam
p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
DATA l_lines_name       LIKE feld-name.
DATA l_selline          LIKE sy-stepl.
DATA l_lastline         TYPE i.
DATA l_line             TYPE i.
DATA l_table_name       LIKE feld-name.
FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
CONCATENATE p_table_name '[]' INTO l_table_name. "table body
ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
GET CURSOR LINE l_selline.
IF sy-subrc <> 0.                   " append line to table
l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
IF l_selline > <lines>.
<tc>-top_line = l_selline - <lines> + 1 .
ELSE.
<tc>-top_line = 1.
ENDIF.
ELSE.                               " insert line into table
l_selline = <tc>-top_line + l_selline - 1.
l_lastline = <tc>-top_line + <lines> - 1.
ENDIF.
*&SPWIZARD: set new cursor line                                        *
l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
INSERT INITIAL LINE INTO <table> INDEX l_selline.
<tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
SET CURSOR 1 l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
USING    p_tc_name           TYPE dynfnam
p_table_name
p_mark_name
p_netwr.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
DATA l_table_name       LIKE feld-name.

FIELD-SYMBOLS <tc>         TYPE cxtab_control.
FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
FIELD-SYMBOLS <wa>.
FIELD-SYMBOLS <mark_field>.
FIELD-SYMBOLS <lfs_netwr>.

*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
CONCATENATE p_table_name '[]' INTO l_table_name. "table body
ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
DESCRIBE TABLE <table> LINES <tc>-lines.

LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

IF <mark_field> = 'X'.
*------------- Custom Code Added by Abhishek Khairnar---------------------
DATA(lv_sy_tabix_index) = syst-tabix.
CLEAR gv_popup_return.
CALL FUNCTION 'POPUP_TO_CONFIRM'                                                    "Confirmation from user if he wants to delete the record or not
EXPORTING
titlebar              = 'Confirmation '
text_question         = 'Do you want to Delete the record from the table?'
text_button_1         = 'Yes'
text_button_2         = 'No'
default_button        = '2'
display_cancel_button = ''
popup_type            = 'ICON_MESSAGE_WARNING'
IMPORTING
answer                = gv_popup_return                                         " to hold the FM's return value
EXCEPTIONS
text_not_found        = 1
OTHERS                = 2.
IF sy-subrc <> 0.
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
*------------- Custom Code Added by Abhishek Khairnar---------------------
IF p_table_name EQ 'GT_MULTIPLE_VARIANT_DEF'.
IF gv_popup_return EQ '2'.
ASSIGN COMPONENT p_netwr OF STRUCTURE <wa> TO <lfs_netwr>.
lv_multi_variant_netwr = <lfs_netwr>.
gs_multiple_variant-netwr = gs_multiple_variant-netwr - lv_multi_variant_netwr.
gv_del_rec_flag_mdbx = 'X'.                                                       "Used in PBO of Screen 200
CLEAR lv_multi_variant_netwr.
ENDIF.
ENDIF.

IF gv_popup_return EQ '1'.
DELETE <table> INDEX lv_sy_tabix_index.
IF sy-subrc = 0.
<tc>-lines = <tc>-lines - 1.
ENDIF.
ELSE.

ENDIF.

ENDIF.
ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
             p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
DATA l_tc_new_top_line     TYPE i.
DATA l_tc_name             LIKE feld-name.
DATA l_tc_lines_name       LIKE feld-name.
DATA l_tc_field_name       LIKE feld-name.

FIELD-SYMBOLS <tc>         TYPE cxtab_control.
FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
l_tc_new_top_line = 1.
ELSE.
*&SPWIZARD: no, ...                                                    *
CALL FUNCTION 'SCROLLING_IN_TABLE'
EXPORTING
entry_act      = <tc>-top_line
entry_from     = 1
entry_to       = <tc>-lines
last_page_full = 'X'
loops          = <lines>
ok_code        = p_ok
overlapping    = 'X'
IMPORTING
entry_new      = l_tc_new_top_line
EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
OTHERS         = 0.
ENDIF.

*&SPWIZARD: get actual tc and column                                   *
GET CURSOR FIELD l_tc_field_name
AREA  l_tc_name.

IF syst-subrc = 0.
IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
SET CURSOR FIELD l_tc_field_name LINE 1.
ENDIF.
ENDIF.

*&SPWIZARD: set the new top line                                       *
<tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
      p_table_name
      p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
DATA l_table_name       LIKE feld-name.

FIELD-SYMBOLS <tc>         TYPE cxtab_control.
FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
FIELD-SYMBOLS <wa>.
FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
CONCATENATE p_table_name '[]' INTO l_table_name. "table body
ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

<mark_field> = 'X'.
ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
        p_table_name
        p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
DATA l_table_name       LIKE feld-name.

FIELD-SYMBOLS <tc>         TYPE cxtab_control.
FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
FIELD-SYMBOLS <wa>.
FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
CONCATENATE p_table_name '[]' INTO l_table_name. "table body
ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

<mark_field> = space.
ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines