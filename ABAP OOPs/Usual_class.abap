*&---------------------------------------------------------------------*
*& Report ZPRG_USUAL_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_usual_cl.

*local variable declaration--------------------------------------------*
DATA: lv_erdat TYPE erdat,
      lv_erzet TYPE erzet,
      lv_ernam TYPE ernam,
      lv_vbtyp TYPE vbtyp.

*object declaration----------------------------------------------------*
DATA: lo_object TYPE REF TO zusual_abap_cl.

*Parameters------------------------------------------------------------*
PARAMETERS : p_vbeln TYPE vbeln_va.

*-----------------------------------------------------------------------*
*                    Static method Logic(Public)
*-----------------------------------------------------------------------*

"method is geeting called by class name.
CALL METHOD zusual_abap_cl=>display
  EXPORTING
    pvbeln      = p_vbeln
  IMPORTING
    perdat      = lv_erdat
    perzet      = lv_erzet
    pernam      = lv_ernam
    pvbtyp      = lv_vbtyp
  EXCEPTIONS
    wrong_input = 1
    OTHERS      = 2.
IF sy-subrc <> 0.
  MESSAGE e009(zmsg).
ELSE.
  WRITE : / lv_erdat,
          / lv_erzet,
          / lv_ernam,
          / lv_vbtyp.
ENDIF.

*-----------------------------------------------------------------------*
*                     Instance method Logic(Public)
*-----------------------------------------------------------------------*

**Create Object---------------------------------------------------------*
*CREATE OBJECT lo_object.
*
**Calling the method----------------------------------------------------*
*CALL METHOD lo_object->display
*  EXPORTING
*    pvbeln      = p_vbeln
*  IMPORTING
*    perdat      = lv_erdat
*    perzet      = lv_erzet
*    pernam      = lv_ernam
*    pvbtyp      = lv_vbtyp
*  EXCEPTIONS
*    wrong_input = 1
*    OTHERS      = 2.
*IF sy-subrc <> 0.
*  MESSAGE e009(zmsg).
*ELSE.
*  WRITE : / lv_erdat,
*          / lv_erzet,
*          / lv_ernam,
*          / lv_vbtyp.
*ENDIF.