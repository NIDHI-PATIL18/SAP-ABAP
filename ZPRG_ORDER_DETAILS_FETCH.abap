*&---------------------------------------------------------------------*
*& Report ZPRG_ORDER_DETAILS_FETCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg_order_details_fetch.

TABLES: vbak,vbap.
*
*DATA : lv_vbeln TYPE vbeln_va.
TYPES : BEGIN OF ty_vbak,
          vbeln    TYPE vbeln_va,         "SALES DOC
          erdat    TYPE erdat,            "Date on which the record was created
          vkorg    TYPE vkorg,            "SALES ORG
          kunnr    TYPE kunag,            "Sold-To Party
          vgbel    TYPE vbrp-vgbel,       "REFRENCE NO.
          bukrs_vf TYPE bukrs_vf,         "COMPANY CODE
        END OF ty_vbak .

TYPES : BEGIN OF ty_vbap,
          vbeln TYPE vbeln,
          upflu TYPE upflv,            "UPDATE INDICATOR FOR DOCUMENT FLOW
          vgtyp TYPE vbtypl_v,         "DOC CATEGORY FOR PRECEDING SD
        END OF ty_vbap.


TYPES : BEGIN OF ty_final,
          vbeln    TYPE vbeln_va,         "SALES DOC
          erdat    TYPE erdat,            "Date on which the record was created
          vkorg    TYPE vkorg,            "SALES ORG
          kunnr    TYPE kunag,            "Sold-To Party
          vgbel    TYPE vbrp-vgbel,
*          vbeln    TYPE vbeln,
          bukrs_vf TYPE bukrs_vf,         "COMPANY CODE
          upflu    TYPE upflv,
          vgtyp    TYPE vbtypl_v,         "DOC CATEGORY FOR PRECEDING SD
        END OF ty_final.

DATA : it_vbak  TYPE TABLE OF ty_vbak,
       wa_vbak  TYPE ty_vbak,
       it_vbap  TYPE TABLE OF ty_vbap,
       wa_vbap  TYPE ty_vbap,
       it_final TYPE TABLE OF ty_final,
       wa_final TYPE ty_final.


SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : p_vbeln FOR VBAK-VBELN.
*  PARAMETERS: p_vbeln TYPE vbeln.
SELECTION-SCREEN : END OF BLOCK b1.

START-OF-SELECTION.
  SELECT *
    FROM vbak
    INTO CORRESPONDING FIELDS OF TABLE it_vbak
    WHERE vbeln IN p_vbeln.

  IF it_vbak IS NOT INITIAL.
    SELECT  *
        FROM vbap
        INTO CORRESPONDING FIELDS OF TABLE it_vbap
        FOR ALL ENTRIES IN it_vbak
        WHERE vbeln = it_vbak-vbeln.
  ENDIF.

*  IF sy-subrc = 0.
*
*  ENDIF.

  LOOP AT it_vbak INTO wa_vbak.
    LOOP AT it_vbap INTO wa_vbap WHERE vbeln = wa_vbak-vbeln.
      wa_final-vbeln = wa_vbak-vbeln.
      wa_final-erdat = wa_vbak-erdat.
      wa_final-vkorg = wa_vbak-vkorg.
      wa_final-kunnr = wa_vbak-kunnr.
      wa_final-vgbel = wa_vbak-vgbel.
      wa_final-bukrs_vf = wa_vbak-bukrs_vf.
      wa_final-upflu = wa_vbap-upflu.
      wa_final-vgtyp = wa_vbap-vgtyp.
      APPEND wa_final TO it_final.
      CLEAR : wa_final.

    ENDLOOP.
  ENDLOOP.

  LOOP AT it_final INTO wa_final.
    WRITE : / wa_final-vbeln , wa_final-bukrs_vf , wa_final-vkorg, wa_final-erdat, wa_final-kunnr , wa_final-vgbel , wa_final-vgtyp , wa_final-upflu.
  ENDLOOP.
