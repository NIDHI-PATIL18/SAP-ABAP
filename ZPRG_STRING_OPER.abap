*&---------------------------------------------------------------------*
*& Report ZPRG_STRING_OPER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPRG_STRING_OPER.

********************************************************************
*SUBPROCESS
DATA : ln_value(50) type c VALUE '91-040-7020302028'. "source string
DATA : ln_CITY(50) type c .
DATA : ln_country(10) type c.
DATA : ln_number(10) type c.

ln_country = ln_value+0(2).   "'0' staring position of the string
WRITE : /'The country code:', ln_country.

ln_city = ln_value+3(3).      "'3' staring position of the  city code string
WRITE : /'The CITY code:', ln_CITY.

ln_number = ln_value+7(10).   "'7' staring position of the mobile no. string
WRITE : /'The Mobile no.:', ln_number.
********************************************************************
*SHIFT
*DATA :  ln_input1(20) type c value 'NIDHI_PATIL',
*       ln_input2(20) type c value 'NIDHI_PATIL',
*       ln_input3(20) type c value '1234567890',
*       ln_input4(20) type c value '00000000005',
*       ln_input5(20) type c value '50000000000'.
*
*
*
*SHIFT ln_input1 by 5 places.
*WRITE : 'Left :', ln_input1.
*
*SHIFT ln_input2 by 2 places right.
*WRITE : /'Right :',ln_input2.
*
*SHIFT ln_input3 by 5 places circular.
*WRITE : /'Circular :', Ln_input3.
*
*SHIFT ln_input4 LEFT DELETING LEADING '0'.
*WRITE :/'Result after Deleting:',ln_input4.
*
*SHIFT ln_input5 RIGHT DELETING TRAILING '0'.
*WRITE :/'Result after Deleting:',ln_input5.

********************************************************************

"TRANSLATE
*DATA: ln_input(100) type c value ' Welocome to my Practice area ',
*      ln_input1(100) type c value ' Welocome to my Practice area',
*      ln_rule(100) type c value 'WwELoCETomYpRA'.
*
*TRANSLATE ln_input1 using ln_rule.
*WRITE: ' output using rule pattern:',ln_input1.
*TRANSLATE ln_input to LOWER CASE.
*WRITE: / ln_input.
*
*TRANSLATE ln_input1 to UPPER CASE.
*WRITE :/ ln_input1.

********************************************************************
"FIND
*DATA ln_input(100) type c value ' Welocome to Practice area '.
*
*FIND 'Practice' in ln_input IGNORING CASE.
**ignoring means just to ignore the upper case lower case or any condition.
*if sy-subrc = 0.
*  write : 'Successful', sy-subrc.
*  else.
*    write: 'Unsuccessful',sy-subrc.
*    endif.

********************************************************************
*DATA : ln_input1(10) type c value 'welcome',
*      ln_input2(10) type c value 'to',
*      ln_input3(10) type c value 'Home',
**      ln_output type string.
*
*DATA : ln_result1(10) type c ,
*      ln_result2(10) type c ,
*      ln_result3(10) type c .
*****************************************************************
*"CONCATENATE
*CONCATENATE ln_input1 ln_input2 ln_input3 into ln_output SEPARATED BY' '.
*
*write : 'thr result is :', ln_output.

********************************************************************
*"SPLIT
*Split ln_output at ' ' into ln_result1 ln_result2 ln_result3.
*write : /'result after split :',ln_result1,ln_result2,ln_result3.

********************************************************************
"CONDENSE
*Data ln_input type string value '  Welcome   to    home   '.
*data ln_length(2) type n.
*
*ln_length = strlen( ln_input ).
*
*write : /'The length before condense:', ln_length.
*
*Write :/' Before Condense:', ln_input.
*CONDENSE ln_input.
*WRITE :/ ' After condense:', ln_input.
*CONDENSE ln_input No-gaps.
*WRITE :/ ' After condense with no gaps:', ln_input.

********************************************************************
