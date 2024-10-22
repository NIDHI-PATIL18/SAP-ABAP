*&---------------------------------------------------------------------*
*& Report ZPRG2_DEMO_SWITCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprg2_demo_switch.

PARAMETERS : p_input TYPE i.

DATA(lv_month) = SWITCH char20( p_input WHEN 1  THEN TEXT-000
                                        WHEN 2  THEN TEXT-001
                                        WHEN 3  THEN TEXT-002
                                        WHEN 4  THEN TEXT-003
                                        WHEN 5  THEN TEXT-004
                                        WHEN 6  THEN TEXT-005
                                        WHEN 7  THEN TEXT-006
                                        WHEN 8  THEN TEXT-007
                                        WHEN 9  THEN TEXT-008
                                        WHEN 10 THEN TEXT-009
                                        WHEN 11 THEN TEXT-010
                                        WHEN 12 THEN TEXT-011
                                        ELSE TEXT-012 ).
WRITE : lv_month.