create or replace function uf_age
(
    pssn insa.ssn%type,
    ptype number -- 0 세는 나이, 1 만 나이
)
return number -- 크기 안줌
IS
    ㄱ number(4); -- 올해 년도
    ㄴ number(4); -- 생일년도
    ㄷ number(1); -- 생일 지남 여부 -1 , 0 , 1
    vcountingage number(3); -- 세는 나이
    vamericanage number(3); -- 만 나이
begin
    -- 세는 나이 = 올해 년도 - 생일 년도 + 1
    -- 만 나이 = 올해 년도 - 생일년도   +  (생일지남여부 -1)
--                = 세는 나이 -1
    ㄱ := TO_CHAR( SYSDATE, 'YYYY' );
    ㄴ := CASE 
             WHEN SUBSTR(pssn, -7, 1) IN (1,2,5,6) THEN 1900
             WHEN REGEXP_LIKE(SUBSTR(pssn, -7, 1), '[3478]') THEN 2000
             ELSE 1800
         END + SUBSTR( pssn, 1, 2);
    ㄷ := SIGN( TO_DATE( SUBSTR( pssn, 3,4)  , 'MMDD' ) - TRUNC( SYSDATE ) );
    vcountingage := ㄱ - ㄴ +1;
    vamericanage := vcountingage - 1 - CASE ㄷ
                                         WHEN 1 THEN -1
                                         ELSE 0
                                      END;

    
     IF ptype = 0 THEN return vcountingage;
        ELSE return vamericanage;
        END IF;

--exception
end;
