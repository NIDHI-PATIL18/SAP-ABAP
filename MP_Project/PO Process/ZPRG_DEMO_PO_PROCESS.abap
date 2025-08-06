*&---------------------------------------------------------------------*
*& Report ZPO_MANAGER_MP                                               *
*& Type: Module Pool (Executable via Transaction Code)                 *
*& Description: Unified PO Create/Change/Display Transaction           *
*&---------------------------------------------------------------------*
* This is a conceptual ABAP Module Pool program.
* An actual implementation would require detailed screen painter design,
* data dictionary definitions, and comprehensive error handling.
*&---------------------------------------------------------------------*

* Global Data Declarations (Top Include: LZPO_MANAGER_MPTOP)
*&---------------------------------------------------------------------*
INCLUDE lzpo_manager_mptop. " Global data declarations
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Type Definitions and Data Declarations                              *
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_po_data,
    action    TYPE char1, " 'C' for Create, 'H' for Change, 'D' for Display
    ebeln     TYPE ekko-ebeln, " Purchase Order Number
    ekorg     TYPE ekko-ekorg, " Purchasing Organization
    ekgrp     TYPE ekko-ekgrp, " Purchasing Group
    bukrs     TYPE ekko-bukrs, " Company Code
    lifnr     TYPE ekko-lifnr, " Vendor Number
    bedat     TYPE ekko-bedat, " PO Date
    bsart     TYPE ekko-bsart, " PO Document Type
    matnr     TYPE ekpo-matnr, " Material Number
    menge     TYPE ekpo-menge, " Quantity
    meins     TYPE ekpo-meins, " Unit of Measure
    netpr     TYPE ekpo-netpr, " Net Price
    peinh     TYPE ekpo-peinh, " Price Unit
    waers     TYPE ekko-waers, " Currency
    eindt     TYPE ekpo-eindt, " Delivery Date
    werks     TYPE ekpo-werks, " Plant
    lgort     TYPE ekpo-lgort, " Storage Location
    pstyp     TYPE ekpo-pstyp, " Item Category
  END OF ty_po_data.

DATA:
  gs_po_data    TYPE ty_po_data, " Screen fields structure
  gv_po_number  TYPE ekko-ebeln, " Holds the PO number for display/change
  gv_action     TYPE char1,      " Holds the selected action ('C', 'H', 'D')
  go_alv_grid   TYPE REF TO cl_gui_alv_grid, " For displaying item details (optional)
  g_custom_container TYPE REF TO cl_gui_custom_container. " For ALV (optional)

* BAPI Structures
DATA:
  ls_po_header     TYPE bapi2012_header,
  ls_po_headerx    TYPE bapi2012_headerx,
  lt_po_items      TYPE STANDARD TABLE OF bapi2012_item,
  lt_po_itemsx     TYPE STANDARD TABLE OF bapi2012_itemx,
  lt_po_item_schedules TYPE STANDARD TABLE OF bapi2012_item_schedule,
  lt_po_item_schedulesx TYPE STANDARD TABLE OF bapi2012_item_schedulex,
  lt_po_account_assignment TYPE STANDARD TABLE OF bapi2012_item_account_assignment,
  lt_po_account_assignmentx TYPE STANDARD TABLE OF bapi2012_item_account_assignmentx,
  lt_po_partners   TYPE STANDARD TABLE OF bapi2012_partner,
  lt_po_conditions TYPE STANDARD TABLE OF bapi2012_item_condition,
  lt_return        TYPE STANDARD TABLE OF bapiret2,
  ls_return_msg    TYPE bapiret2.

*&---------------------------------------------------------------------*
*& Screen Flow Logic (Main Program: ZPO_MANAGER_MP)                    *
*&---------------------------------------------------------------------*
* This is the main program for the module pool.
* It defines the initial screen and calls the PBO/PAI modules.
* The transaction code will point to this program and initial screen.

* Initial Screen (e.g., Screen 100)
PROCESS BEFORE OUTPUT.
  MODULE status_100.
  MODULE enable_fields_100.

PROCESS AFTER INPUT.
  MODULE user_command_100.

*&---------------------------------------------------------------------*
*& PBO Module (Include: LZPO_MANAGER_MPPBO)                            *
*&---------------------------------------------------------------------*
INCLUDE lzpo_manager_mppbo. " PBO modules

*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT                                            *
*& Description: Sets GUI status and title for screen 100               *
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.
  SET PF-STATUS 'MAIN_SCREEN'. " Define this in SE41
  SET TITLEBAR 'PO_MANAGER_TITLE'. " Define this in SE32
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module ENABLE_FIELDS_100 OUTPUT                                     *
*& Description: Controls field visibility/editability based on action  *
*&---------------------------------------------------------------------*
MODULE enable_fields_100 OUTPUT.
  CASE gv_action.
    WHEN 'C'. " Create mode
      LOOP AT SCREEN.
        IF screen-name EQ 'GS_PO_DATA-EBELN'. " PO Number field
          screen-input = 0. " Disable
        ELSEIF screen-group1 EQ 'PO_CREATE_FIELDS'. " Fields for creation
          screen-input = 1. " Enable
        ELSEIF screen-group1 EQ 'PO_DISPLAY_FIELDS'. " Read-only fields
          screen-input = 0. " Disable
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      CLEAR: gs_po_data-ebeln, lt_po_items[], lt_po_item_schedules[],
             lt_po_account_assignment[], lt_po_partners[], lt_po_conditions[].
      " Clear other fields relevant to previous PO data
      gs_po_data-bsart = 'NB'. " Default PO type
      gs_po_data-waers = 'INR'. " Default currency
      " ... default other fields as needed
    WHEN 'H'. " Change mode
      LOOP AT SCREEN.
        IF screen-name EQ 'GS_PO_DATA-EBELN'.
          screen-input = 1. " Enable PO number input
        ELSEIF screen-group1 EQ 'PO_CREATE_FIELDS' OR screen-group1 EQ 'PO_CHANGE_FIELDS'.
          screen-input = 1. " Enable for change
        ELSEIF screen-group1 EQ 'PO_DISPLAY_FIELDS'.
          screen-input = 0. " Read-only
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      " If PO number is entered, populate fields (this happens on PAI 'EXECUTE')
    WHEN 'D'. " Display mode
      LOOP AT SCREEN.
        IF screen-name EQ 'GS_PO_DATA-EBELN'.
          screen-input = 1. " Enable PO number input
        ELSE.
          screen-input = 0. " Disable all other fields
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      " If PO number is entered, populate fields (this happens on PAI 'EXECUTE')
    WHEN OTHERS. " Initial state
      LOOP AT SCREEN.
        IF screen-name EQ 'GV_ACTION'. " Action radio buttons
          screen-input = 1.
        ELSE.
          screen-input = 0. " Disable all other fields initially
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      CLEAR gs_po_data.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& PAI Module (Include: LZPO_MANAGER_MPPAI)                            *
*&---------------------------------------------------------------------*
INCLUDE lzpo_manager_mppai. " PAI modules

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_100 INPUT                                       *
*& Description: Handles user actions (buttons, radio buttons)          *
*&---------------------------------------------------------------------*
MODULE user_command_100 INPUT.
  CASE sy-ucomm.
    WHEN 'CREATE'. " User selected 'Create' radio button
      gv_action = 'C'.
      CLEAR gs_po_data. " Clear screen for new entry
      LEAVE TO SCREEN 100. " Re-display screen with create fields enabled

    WHEN 'CHANGE'. " User selected 'Change' radio button
      gv_action = 'H'.
      CLEAR gs_po_data. " Clear screen for PO number input
      LEAVE TO SCREEN 100.

    WHEN 'DISPLAY'. " User selected 'Display' radio button
      gv_action = 'D'.
      CLEAR gs_po_data. " Clear screen for PO number input
      LEAVE TO SCREEN 100.

    WHEN 'EXECUTE'. " User pressed 'Execute' (for Change/Display)
      IF gv_action EQ 'H' OR gv_action EQ 'D'.
        IF gs_po_data-ebeln IS INITIAL.
          MESSAGE 'Please enter a Purchase Order number.' TYPE 'E'.
          EXIT. " Stay on current screen
        ENDIF.
        PERFORM get_po_details USING gs_po_data-ebeln.
        IF lt_return IS NOT INITIAL. " Check if BAPI_PO_GETDETAIL returned errors
          LOOP AT lt_return INTO ls_return_msg.
            MESSAGE ID ls_return_msg-id TYPE ls_return_msg-type NUMBER ls_return_msg-number
                    WITH ls_return_msg-message_v1 ls_return_msg-message_v2
                         ls_return_msg-message_v3 ls_return_msg-message_v4.
          ENDLOOP.
        ELSE.
          " Populate screen fields with retrieved data
          " (This part needs detailed mapping from BAPI output to screen fields)
          " Example:
          gs_po_data-ekorg = ls_po_header-purch_org.
          gs_po_data-ekgrp = ls_po_header-pur_group.
          gs_po_data-bukrs = ls_po_header-comp_code.
          gs_po_data-lifnr = ls_po_header-vendor.
          gs_po_data-bedat = ls_po_header-doc_date.
          gs_po_data-bsart = ls_po_header-doc_type.
          " ... populate item details (e.g., in a table control or ALV)
          IF gv_action EQ 'D'. " If in display mode, make all fields read-only
            LOOP AT SCREEN.
              IF screen-name NE 'GS_PO_DATA-EBELN'.
                screen-input = 0.
                MODIFY SCREEN.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE 'Execute is only for Change/Display mode.' TYPE 'W'.
      ENDIF.
      LEAVE TO SCREEN 100.

    WHEN 'SAVE'. " User pressed 'Save' (for Create/Change)
      CASE gv_action.
        WHEN 'C'. " Create PO
          PERFORM create_purchase_order.
        WHEN 'H'. " Change PO
          PERFORM change_purchase_order.
        WHEN OTHERS.
          MESSAGE 'Save is only for Create/Change mode.' TYPE 'W'.
      ENDCASE.
      LEAVE TO SCREEN 100.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM. " Exit the transaction
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form Routines (Include: LZPO_MANAGER_MPF01)                         *
*&---------------------------------------------------------------------*
INCLUDE lzpo_manager_mpf01. " Form routines

*&---------------------------------------------------------------------*
*& FORM GET_PO_DETAILS                                                 *
*& Description: Calls BAPI_PO_GETDETAIL to retrieve PO data            *
*&---------------------------------------------------------------------*
FORM get_po_details USING iv_ebeln TYPE ekko-ebeln.
  CLEAR: ls_po_header, lt_po_items[], lt_po_item_schedules[],
         lt_po_account_assignment[], lt_po_partners[], lt_po_conditions[],
         lt_return[].

  CALL FUNCTION 'BAPI_PO_GETDETAIL'
    EXPORTING
      purchaseorder = iv_ebeln
    TABLES
      po_header     = ls_po_header
      po_items      = lt_po_items
      po_item_schedules = lt_po_item_schedules
      po_account_assignment = lt_po_account_assignment
      po_partners   = lt_po_partners
      po_conditions = lt_po_conditions
      return        = lt_return.

  " Check for errors from the BAPI
  READ TABLE lt_return INTO ls_return_msg WITH KEY type = 'E' OR type = 'A'.
  IF sy-subrc IS INITIAL.
    " Error messages will be displayed in PAI module
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CREATE_PURCHASE_ORDER                                          *
*& Description: Calls BAPI_PO_CREATE1 to create a new PO               *
*&---------------------------------------------------------------------*
FORM create_purchase_order.
  CLEAR: ls_po_header, ls_po_headerx, lt_po_items[], lt_po_itemsx[],
         lt_po_item_schedules[], lt_po_item_schedulesx[],
         lt_po_account_assignment[], lt_po_account_assignmentx[],
         lt_po_partners[], lt_po_conditions[], lt_return[].

  " Populate BAPI structures from screen fields (gs_po_data)
  ls_po_header-doc_type   = gs_po_data-bsart.
  ls_po_header-comp_code  = gs_po_data-bukrs.
  ls_po_header-purch_org  = gs_po_data-ekorg.
  ls_po_header-pur_group  = gs_po_data-ekgrp.
  ls_po_header-vendor     = gs_po_data-lifnr.
  ls_po_header-doc_date   = gs_po_data-bedat.
  ls_po_header-currency   = gs_po_data-waers.

  ls_po_headerx-doc_type   = 'X'.
  ls_po_headerx-comp_code  = 'X'.
  ls_po_headerx-purch_org  = 'X'.
  ls_po_headerx-pur_group  = 'X'.
  ls_po_headerx-vendor     = 'X'.
  ls_po_headerx-doc_date   = 'X'.
  ls_po_headerx-currency   = 'X'.

  " Populate item data (assuming a single item for simplicity,
  " in reality, this would be a loop through a table control or ALV data)
  DATA(ls_po_item)  TYPE bapi2012_item.
  DATA(ls_po_itemx) TYPE bapi2012_itemx.

  ls_po_item-po_item     = '00010'. " First item
  ls_po_item-material    = gs_po_data-matnr.
  ls_po_item-plant       = gs_po_data-werks.
  ls_po_item-stge_loc    = gs_po_data-lgort.
  ls_po_item-net_price   = gs_po_data-netpr.
  ls_po_item-price_unit  = gs_po_data-peinh.
  ls_po_item-po_unit     = gs_po_data-meins.
  ls_po_item-item_cat    = gs_po_data-pstyp. " e.g., '0' for Standard

  ls_po_itemx-po_item    = 'X'.
  ls_po_itemx-material   = 'X'.
  ls_po_itemx-plant      = 'X'.
  ls_po_itemx-stge_loc   = 'X'.
  ls_po_itemx-net_price  = 'X'.
  ls_po_itemx-price_unit = 'X'.
  ls_po_itemx-po_unit    = 'X'.
  ls_po_itemx-item_cat   = 'X'.

  APPEND ls_po_item TO lt_po_items.
  APPEND ls_po_itemx TO lt_po_itemsx.

  " Populate schedule line (delivery date and quantity)
  DATA(ls_schedule) TYPE bapi2012_item_schedule.
  DATA(ls_schedulex) TYPE bapi2012_item_schedulex.

  ls_schedule-po_item     = '00010'.
  ls_schedule-sched_line  = '0001'.
  ls_schedule-delivery_date = gs_po_data-eindt.
  ls_schedule-quantity    = gs_po_data-menge.

  ls_schedulex-po_item     = 'X'.
  ls_schedulex-sched_line  = 'X'.
  ls_schedulex-delivery_date = 'X'.
  ls_schedulex-quantity    = 'X'.

  APPEND ls_schedule TO lt_po_item_schedules.
  APPEND ls_schedulex TO lt_po_item_schedulesx.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      po_header         = ls_po_header
      po_headerx        = ls_po_headerx
    IMPORTING
      purchaserequisition = DATA(lv_pr_number) " If creating from PR
      purchaseorder     = gv_po_number " Newly created PO number
    TABLES
      return            = lt_return
      po_items          = lt_po_items
      po_itemsx         = lt_po_itemsx
      po_item_schedules = lt_po_item_schedules
      po_item_schedulesx = lt_po_item_schedulesx
      " ... other tables if needed
      .

  READ TABLE lt_return INTO ls_return_msg WITH KEY type = 'E' OR type = 'A'.
  IF sy-subrc IS INITIAL.
    " Error occurred
    LOOP AT lt_return INTO ls_return_msg.
      MESSAGE ID ls_return_msg-id TYPE ls_return_msg-type NUMBER ls_return_msg-number
              WITH ls_return_msg-message_v1 ls_return_msg-message_v2
                   ls_return_msg-message_v3 ls_return_msg-message_v4.
    ENDLOOP.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    " Success
    MESSAGE 'Purchase Order' && gv_po_number && ' created successfully!' TYPE 'S'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    " Clear screen for next entry
    CLEAR gs_po_data.
    gv_action = 'C'. " Stay in create mode
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHANGE_PURCHASE_ORDER                                          *
*& Description: Calls BAPI_PO_CHANGE to modify an existing PO          *
*&---------------------------------------------------------------------*
FORM change_purchase_order.
  CLEAR: ls_po_header, ls_po_headerx, lt_po_items[], lt_po_itemsx[],
         lt_po_item_schedules[], lt_po_item_schedulesx[],
         lt_po_account_assignment[], lt_po_account_assignmentx[],
         lt_po_partners[], lt_po_conditions[], lt_return[].

  " Populate header changes (example: change purchasing group)
  ls_po_header-pur_group = gs_po_data-ekgrp. " New value from screen
  ls_po_headerx-pur_group = 'X'. " Indicate this field is changed

  " Populate item changes (example: change quantity of item 00010)
  DATA(ls_change_item)  TYPE bapi2012_item.
  DATA(ls_change_itemx) TYPE bapi2012_itemx.
  DATA(ls_change_schedule) TYPE bapi2012_item_schedule.
  DATA(ls_change_schedulex) TYPE bapi2012_item_schedulex.

  ls_change_item-po_item = '00010'.
  ls_change_item-net_price = gs_po_data-netpr. " New price from screen
  ls_change_itemx-po_item = 'X'.
  ls_change_itemx-net_price = 'X'.
  APPEND ls_change_item TO lt_po_items.
  APPEND ls_change_itemx TO lt_po_itemsx.

  ls_change_schedule-po_item = '00010'.
  ls_change_schedule-sched_line = '0001'.
  ls_change_schedule-quantity = gs_po_data-menge. " New quantity from screen
  ls_change_schedulex-po_item = 'X'.
  ls_change_schedulex-sched_line = 'X'.
  ls_change_schedulex-quantity = 'X'.
  APPEND ls_change_schedule TO lt_po_item_schedules.
  APPEND ls_change_schedulex TO lt_po_item_schedulesx.


  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder     = gs_po_data-ebeln " PO number to change
      po_header         = ls_po_header
      po_headerx        = ls_po_headerx
    TABLES
      return            = lt_return
      po_items          = lt_po_items
      po_itemsx         = lt_po_itemsx
      po_item_schedules = lt_po_item_schedules
      po_item_schedulesx = lt_po_item_schedulesx
      " ... other tables if needed
      .

  READ TABLE lt_return INTO ls_return_msg WITH KEY type = 'E' OR type = 'A'.
  IF sy-subrc IS INITIAL.
    " Error occurred
    LOOP AT lt_return INTO ls_return_msg.
      MESSAGE ID ls_return_msg-id TYPE ls_return_msg-type NUMBER ls_return_msg-number
              WITH ls_return_msg-message_v1 ls_return_msg-message_v2
                   ls_return_msg-message_v3 ls_return_msg-message_v4.
    ENDLOOP.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    " Success
    MESSAGE 'Purchase Order' && gs_po_data-ebeln && ' changed successfully!' TYPE 'S'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    " Re-display the changed PO
    PERFORM get_po_details USING gs_po_data-ebeln.
    gv_action = 'H'. " Stay in change mode
  ENDIF.
ENDFORM.
