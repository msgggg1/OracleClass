--1. insa테이블에서 ssn 컬럼을 통해서 year, month, date, gender 출력
--    [실행 결과]
--      SSN          YEAR MONTH DATE GENDER  
--    ---------- ------ ---- ----- -----
--    771212-1022432	77	12	12	1
--    801007-1544236	80	10	07	1
--    770922-2312547	77	09	22	2
--    790304-1788896	79	03	04	1
--    811112-1566789	81	11	12	1
--    :
--    60개 행이 선택되었습니다. 

SELECT ssn
        ,SUBSTR(ssn,1,2)year
        ,TO_CHAR ( TO_DATE( SUBSTR(ssn,1,6)),'mm' )month
        ,EXTRACT ( DAY FROM TO_DATE( SUBSTR(ssn,1,6)))"DATE"
        ,SUBSTR(ssn,-7,1)GENDER
FROM insa;

--2. insa 테이블에서 70년대 12월생 모든 사원 아래와 같이 주민등록번호로 정렬해서 출력하세요.
--
--    NAME                 SSN           
--    -------------------- --------------
--    문길수               721217-1951357
--    김인수               731211-1214576
--    홍길동               771212-1022432   

SELECT name, ssn
FROM insa
--WHERE ssn LIKE '7_12%'  -- %, _ 만 사용
--WHERE REGEXP_LIKE(ssn, '^7\d12')
--WHERE REGEXP_LIKE(ssn, '^7.12')
WHERE REGEXP_LIKE(ssn, '^7[0-9]12')
ORDER BY ssn;

--3. insa 테이블에서 70년대 남자 사원만 조회.    
--    ㄱ. LIKE 연산자 사용.    
--    ㄴ. REGEXP_LIKE() 함수 사용   

-- ㄱ.
SELECT *
FROM insa
--WHERE ssn LIKE '7_____-1%'; --3,5,7,9 빠져있음
WHERE REGEXP_LIKE(ssn, '^7\d{5}-[13579]\d{5}');

SELECT ssn
        ,SUBSTR (ssn, -7,1) gender
        -- gender 홀수라면 남자인 성별
FROM insa
--WHERE SUBSTR(ssn,-7,1) % 2 != 0; -- 자바코딩
WHERE MOD( SUBSTR(ssn,-7,1) , 2 ) != 0 AND ssn LIKE '7%';

-- ㄴ.
SELECT *
FROM insa
WHERE REGEXP_LIKE (ssn , '^7\d{5}-1\d{6}');

--4. emp 테이블에서 사원명(ename) 속에  'la' 문자열을 포함하는 사원 정보를 조회(출력)
--   (조건 : 'la'문자는 대소문자를 구분하지 않는다.    la   La  lA  LA )
SELECT *
FROM emp
WHERE ename LIKE '%%'; -- (기억) : 오류 나지 않고 모든 레코드 출력됨
WHERE REGEXP_LIKE (ename,'la', 'i');


--5.insa 테이블에서 남자는 'X', 여자는 'O' 로 성별(gender) 출력하는 쿼리 작성   
--    NAME                 SSN            GENDER
--    -------------------- -------------- ------
--    홍길동               771212-1022432    X
--    이순신               801007-1544236    X
--    이순애               770922-2312547    O
--    김정훈               790304-1788896    X
--    한석봉               811112-1566789    X 
--    :

SELECT name, ssn
--        , SUBSTR(ssn, -7,1) gender
--        if( g == 1) X else O
--      , [1] 둘 중 하나 null로 변환
--   ,replace ( replace ( SUBSTR(ssn, 8, 1) ,'1', 'X'), '2', 'O') gender 
--   ,NVL2 (replace (SUBSTR(ssn,8,1), '1', null), 'O', 'X') )gender
   ,NVL2 (NULLIF( SUBSTR(ssn,8,1), '1' ), 'O', 'X') )gender -- MOD 추가해야 더 정확 
   
   -- CASE문, DECODE 문 사용할 수 있다. 
FROM insa;


-- NULLIF() 함수 설명
SELECT NULLIF(1,1), NULLIF(2,1)
FROM dual;


--6. insa 테이블에서 2000년 이후 입사자 정보 조회하는 쿼리 작성
--    ㄱ. TO_CHAR() 함수 사용해서 풀기
--    ㄴ. EXTRACT() 함수 사용해서 풀기.
--    
--    NAME                 IBSADATE
--    -------------------- --------
--    이미성               00/04/07
--    심심해               00/05/05
--    권영미               00/06/04
--    유관순               00/07/07   

--ㄱ
SELECT name, ibsadate
        , TO_CHAR( ibsadate, 'YYYY') -- 문자
        , EXTRACT ( YEAR FROM ibsadate ) -- 숫자
FROM insa
-- 날짜 비교 가능
WHERE EXTRACT ( YEAR FROM ibsadate) >= 2000;
--WHERE TO_CHAR(SUBSTR(ibsadate,1,2)) <= SUBSTR(TO_CHAR(SYSDATE,'yyyy'),3,2); -- 내 풀이

--ㄴ
SELECT name, ibsadate
FROM insa
WHERE SUBSTR(EXTRACT(YEAR FROM ibsadate),3,2) <= SUBSTR(EXTRACT(YEAR FROM sysdate),3,2);

SELECT name, EXTRACT(ibsadate,'yyyy')
FROM insa;

--7. 현재 시스템의 날짜 출력하는 쿼리를 작성하세요. 
--    SELECT ( ㄱ       ), ( ㄴ          ) 
--    FROM dual;
SELECT SYSDATE, CURRENT_TIMESTAMP
-- SYSDATE () 없지만 함수이다.
-- 오라클 날짜 자료형: DATE, TIMESTAMP
FROM dual;
-- SYSDATE 년, 월, 일               요일/시간/분/초
SELECT TO_CHAR(SYSDATE, 'HH') 
        ,TO_CHAR(SYSDATE, 'HH12')
        ,TO_CHAR(SYSDATE, 'HH24')
        ,TO_CHAR(SYSDATE, 'MI')
        ,TO_CHAR(SYSDATE, 'SS')
        ,TO_CHAR(SYSDATE, 'DY')
        ,TO_CHAR(SYSDATE, 'DAY')
FROM dual;

-- 날짜, 문자 앞뒤 ''홑따옴표 붙인다.
-- EXTRACT() 시간, 분, 초, 요일 -- 요일 가져올 수 없음, SYSDATE는 DATE 타입이라 HOUR, MINUTE, SECOND 추출이 불가능함
SELECT EXTRACT ( HOUR FROM current_timestamp) 
    ,EXTRACT ( MINUTE FROM current_timestamp)
    ,EXTRACT ( SECOND FROM current_timestamp)
    , EXTRACT ( HOUR FROM CAST ( SYSDATE AS TIMESTAMP ) ) -- SYSDATE는 날짜 객체 돌려주는 함수 
FROM dual;

SELECT SYSDATE
    , TO_CHAR (SYSDATE, 'DS TS') -- 2025/03/20 오전 11:37:31
FROM dual;

--8. dept 테이블에서 10번 부서명을 확인하고
--   부서명을 'QC100%'로 수정하고 
--   LIKE 연산자를 사용해서 100%가 포함된 부서를 검색하는 쿼리를 작성하세요. 
--   그리고 마지막엔 ROLLBACK 하세요.

DESC dept;

SELECT dname
FROM dept
WHERE deptno = 10;

UPDATE dept 
SET dname = 'QC100%'
WHERE deptno = 10;

SELECT *
FROM dept
--WHERE dname LIKE '%100\%%' ESCAPE '\';
WHERE REGEXP_LIKE(dname,'100%');

ROLLBACK;

--9. TBL_TEST 테이블에서 email 컬럼의   .co.kr 을   .com 으로 변경해서 출력하는 쿼리를 작성하세요.
--실행결과)
--    EMAIL               EMAIL CHANGE
----------------------------------------------------------------------------------
--http://arirang.co.kr	http://arirang.com
--http://seoul.co.kr	    http://seoul.com
--http://home.co.kr	    http://home.com
SELECT email, 
--REPLACE(email,'.co.kr' , '.com')"EMAIL CHANGE"
REGEXP_REPLACE(email, '(.+)\.co\.kr$', '\1.com')
FROM tbl_test;


--10. 오늘날짜의 년,월,일, 요일을 출력하는 쿼리를 작성하세요. 
SELECT EXTRACT(YEAR FROM sysdate)년,
        EXTRACT(MONTH FROM sysdate)월,
        EXTRACT(DAY FROM sysdate)일,
        TO_CHAR(sysdate, 'day')요일
FROM dual;


--11. emp 테이블에서 아래와 같이 출력하는 쿼리를 작성하세요. 
--   ㄱ. deptno 오름차순 정렬 후 pay 로 내림차순 정렬
--   ㄴ. pay가 100 단위로 # 출력
--   ㄷ. pay = sal + comm
--   
--   실행결과)
--DEPTNO ENAME(PAY) BAR
----- ------------ -------------------------------------------------------------
--10	KING(5000)	 ##################################################
--10	CLARK(2450)	 #########################
--10	MILLER(1300) #############
--20	FORD(3000)	 ##############################
--20	JONES(2975)	 ##############################
--20	SMITH(800)	 ########
--30	BLAKE(2850)	 #############################
--30	MARTIN(2650) ###########################
--30	ALLEN(1900)	 ###################
--30	WARD(1750)	 ##################
--30	TURNER(1500) ###############
--30	JAMES(950)	 ##########

WITH temp AS(
        SELECT deptno, ename, sal+NVL(comm,0)pay
        FROM emp
        )
SELECT deptno
--        ,ename || '(' || pay || ')' "ENAME(PAY)"
            ,REGEXP_REPLACE(ename||pay, '([A-Z])(\d+)', '\1(\2)')
            , RPAD ( ' ', ROUND(pay/100)+1, '#') bar
FROM temp;
ORDER BY deptno, pay DESC;
        
        
SELECT deptno, (ename || '('|| TO_CHAR(sal+NVL(comm,0))|| ')' )"ENAME(PAY)", LPAD(' ',(sal+NVL(comm,0))/100+1,'#')bar
FROM emp
ORDER BY 1, sal+NVL(comm,0) DESC;

SELECT *
FROM emp;

--20250320 수업시작
-- DML : INSERT, UPDATE, DELETE + TCL : COMMIT, ROLLBACK
--10	ACCOUNTING	NEW YORK
--20	RESEARCH	DALLAS
--30	SALES	CHICAGO
--40	OPERATIONS	BOSTON

SELECT *
FROM dept;

--DML : INSERT
INSERT INTO 테이블명 ( 컬럼명 ) VALUES ( 컬럼값 );
INSERT INTO dept (deptno, dname, loc) VALUES (50, 'QC', 'SEOUL');
-- 1행 삽입되었습니다.
-- ORA-00001: unique constraint (SCOTT.PK_DEPT) violated : 유일성 제약조건(PK) 제약조건 위배(중복)
INSERT INTO dept (deptno, dname, loc) VALUES (50, 'QC2', 'SEOUL'); --고유키, 기본키, Primary Key(PK) 다른 레코드와 같은 값을 가질 수 없음
DESC dept; -- deptno만 not null, 나머지 기본값 null
INSERT INTO dept (deptno, dname, loc) VALUES (60, 'QC2');
-- SQL 오류: ORA-00947: not enough values
-- dname, loc NULL 허용
INSERT INTO dept (deptno, dname, loc) VALUES (60, 'QC2', null);
INSERT INTO dept (deptno, dname) VALUES (60, 'QC2'); -- null 허용하는 애들 제외
INSERT INTO dept VALUES (70, null, null); -- 차례대로 입력
INSERT INTO dept VALUES (null, null, null);
-- SQL 오류: ORA-01400: cannot insert NULL into ("SCOTT"."DEPT"."DEPTNO")
INSERT INTO dept (deptno, dname, loc) VALUES (100, 'QC3', null);
--SQL 오류: ORA-01438: value larger than specified precision allowed for this column
-- NUMBER(precision(정밀도, 정확도), scale)
-- NUMBER(2) : 2자리 정수
-- NUMBER(7,2) : 전체자리수 7자리, 소수점 2자리 실수
DESC dept; -- DEPTNO NOT NULL NUMBER(2)
COMMIT;

--
SELECT *
FROM dept;
-- DML : DELETE 문
DELETE FROM 테이블명;
DELETE FROM dept
WHERE deptno >= 60;
-- ORA-02292: integrity constraint (SCOTT.FK_DEPTNO) violated - child record found
-- 1)DELETE 구문에 WHERE 조건절 없으면 모든 레코드 삭제

ROLLBACK;
-- 
DELETE FROM dept
WHERE deptno = 20;
-- ORA-02292: integrity constraint (SCOTT.FK_DEPTNO) violated - child record found : 부서테이블(부모) 번호 참조함. 테이블 생성시 설정가능

-- [DML] INSERT, DELETE
DELETE FROM dept


-- [문제]
SELECT *
FROM dept;
-- (기억)
DELETE FROM dept
--WHERE dname LIKE '%qc%'   --보통 pk값으로 삭제 많이 함
WHERE dname LIKE '%'|| UPPER('qc')||'%';
COMMIT;

INSERT INTO dept VALUES ( 50 , null,null);
commit;
INSERT INTO dept VALUES ( 40 , 'OPERATIONS' , 'BOSTON');
commit;
UPDATE dept SET dname = 'OPERATIONS', loc ='BOSTON' 
WHERE deptno =40;

-- [문제] 40번 부서의 부서명, 지역명을 얻어와서,
-- 50번 부서명, 지역명으로 UPDATE 문을 작성하세요
DESC dept;

--예)
UPDATE dept 
--SET dname = SUBSTR(dname,1,2) || 'XX' , loc = ?   
WHERE deptno = 50;

--[1]
UPDATE dept 
SET dname = (SELECT dname FROM dept WHERE deptno=40)  
    , loc = (SELECT loc FROM dept WHERE deptno=40)     -- (서브쿼리였다) 괄호 없으면 오류
WHERE deptno = 50;
ROLLBACK;

-- [풀이] [2]
UPDATE dept 
SET (dname, loc) = (SELECT dname,loc FROM dept WHERE deptno=40) -- SET에도 서브쿼리 사용가능
WHERE deptno = 50;

ROLLBACK;
--
DELETE FROM dept
WHERE deptno >=50;
COMMIT;

-- [문제] emp 테이블에서 10번 부서원 급여 20% 인상
--                     20번 부서원 급여 15% 인상
--                      그 외 부서원 급여 5% 인상 시키는 쿼리 작성

-- [문제] emp 테이블에서 모든 사원의 급여를 20% 인상시키는 쿼리를 작성하자
-- ( 급여( pay ) = sal + comm )
SELECT e.deptno, ename, pay
        , '20%'
        , pay + (pay*0.2)"인상된 pay"
FROM (
        SELECT deptno, ename
                ,sal + NVL(comm,0) pay
        FROM emp
    )e ;
-- sal  현재 sal에서 급여(pay)의 10% 인상 시키자.
UPDATE emp
SET sal = sal + ((sal + NVL(comm,0)*0.1); -- 실행x

DESC emp

SELECT sal+NVL(comm,0) pay , (sal+NVL(comm,0))*(1.2)
FROM emp
WHERE deptno = 10;

SELECT sal+NVL(comm,0) pay , (sal+NVL(comm,0))*(1.15)
FROM emp
WHERE deptno = 20;

SELECT sal+NVL(comm,0) pay , (sal+NVL(comm,0))*(1.2)
FROM emp
WHERE deptno NOT IN ( 10, 20);

-- C:\Users\계정명\AppData\Roaming\SQL Developer\SqlHistory

-- [ 오라클 연산자 (Operator) ] --
--1. 비교 연산자
--2. 논리 연산자
--3. SQL 연산자
--4. NULL 연산자
--5. SET(집합) 연산자
--6. 산술 연산자

-- [ 산술 연산자 ] +  -  *  /
SELECT 5 +3 -- 8
        , 5-3 --2
        , 5*3 -- 15
        , 5/3 -- 1.6666666... JAVA와 다른점**
FROM dual;

--[dual]
-- [스키마.dual] ?
--SYS 사용자가 모든 사용자들이 사용할 수 있도록 PUBLIC synonym 부여.
-- 시노님 조회
SELECT *
FROM all_synonyms
WHERE synonym_name LIKE UPPER('dual');

-- 1) scott 소유자가 hr 계정에게 SELECT 권한 부여
GRANT SELECT ON emp TO hr; -- Grant을(를) 성공했습니다.
--1) 권한 회수
REVOKE SELECT ON emp FROM hr; -- Revoke을(를) 성공했습니다.
---------------------------------------------------
SELECT  FLOOR(5/3) -- 절삭, 리턴값 정수                        소수점 첫 번째 자리에서 절삭
        , TRUNC(5/3) -- 절삭, 정수or실수. TRUNC ( [,m 절삭위치]) m번째 자리에서 절삭         -- 몫 1 오라클 절삭하는 함수/연산자 (자바 Math.floor())
        ,MOD(5,3) -- 나머지 2

    -- 5 % 2 나머지 연산자 없음
FROM dual;

--TRUNC() 
-- 형식) TRUNC( a, [,b])
SELECT 
    TRUNC(12345.6789, -1)
    ,TRUNC(12345.6789, -2)
    -- 3.141592 pi
    , ACOS(-1) pi
    ,TRUNC (ACOS(-1) )
    ,FLOOR (ACOS(-1) ) -- 위랑 같은 코딩
    , TRUNC(ACOS(-1) , 2) -- 3번째 자리에서 절삭 일어남
    , TRUNC(ACOS(-1) , 3) -- 절삭
    
    , FLOOR ( ACOS(-1) *100) /100
FROM dual;

-- 숫자 -> 형식(format)으로 출력 
SELECT ename, hourly_pay
        ,TO_CHAR(hourly_pay, '$9,999.999')
        ,TO_CHAR(hourly_pay, 'c9,999.999')
FROM(
    SELECT ename
            ,sal + NVL(comm, 0)pay
            ,TO_CHAR(TRUNC ((sal + NVL(comm, 0))/(20*8) ,3)) hourly_pay
    FROM emp
    ) e;
    
-- ORA-01476: divisor is equal to zero
-- divisor : 제수 , 나누는 수
-- dividend : 피제수, 나누어지는 수
--SELECT 5/0
SELECT MOD(5,0) -- 5 실행됨. 자바는 오류
FROM dual;

-- [ 비교 연산자 ] : WHERE 절에서 사용. 숫자, 날짜, 문자를 비교하는 연산자
--                  > < >= <= = != ^= <>

--SELECT 5 > 3   --> 에러
--FROM dual 
-- [ 문제 ] 입사일자 81/06~81/10 사이 입사한 사원 정보를 조회
DESC emp

SELECT ename, hiredate
FROM emp

--[3]
--WHERE hiredate >= '81/06/01' AND hiredate < '81/11/01';
--[4]
WHERE hiredate BETWEEN '81/06/01' AND '81/10/31';
--[1]
--WHERE to_char(hiredate, 'MM') >= 6 
--    AND to_char(hiredate,'YY') = 81    
--    AND to_char(hiredate, 'MM') <= 10
--[2]
--WHERE TO_CHAR( hiredate, 'YYMM' ) BETWEEN 8106 AND 8110

-- 날짜 절삭
-- 절삭 함수 : TRUNC(NUMBER, 위치), FLOOR(NUMBER)
SELECT SYSDATE -- 출력이 안됐을 뿐 시분초도 있음
        ,TRUNC( SYSDATE, 'YEAR')
        ,TRUNC( SYSDATE, 'YYYY')
        ,TRUNC( SYSDATE, 'MONTH')
        ,TRUNC( SYSDATE, 'MM')
        ,TRUNC( SYSDATE, 'DD')
FROM dual;

-- emp 에서 pay 가장 많이 받는 사람 조회 - 5000
-- emp 에서 pay 가장 적게 받는 사람 조회 - 800

SELECT MAX(sal + NVL(comm,0)) max_pay , MIN(sal + NVL(comm,0)) min_pay
FROM  emp;


-- [ 문제 ] emp 테이블에서 max pay 받는 사원 정보 조회
-- [ 문제 ] emp 테이블에서 min pay 받는 사원 정보 조회
-- [ 문제 ] emp 테이블에서 둘다 사원 정보 조회
DESC emp;

WITH e AS(
    SELECT emp.*, sal+NVL(comm,0) pay
    FROM emp
        )
SELECT *
FROM e
WHERE e.pay = (SELECT MAX(e.pay) FROM e);

WITH e AS(
    SELECT emp.*, sal+NVL(comm,0) pay
    FROM emp
        )
SELECT *
FROM e
WHERE e.pay = (SELECT MIN(e.pay) FROM e);

WITH e AS(
    SELECT emp.*, sal+NVL(comm,0) pay
    FROM emp
        )
SELECT *
FROM e
WHERE e.pay = (SELECT MAX(e.pay) FROM e) OR e.pay = (SELECT MIN(e.pay) FROM e);
