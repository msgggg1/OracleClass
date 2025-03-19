-- SCOTT 소유하고 있는 모든 테이블 정보 조회
SELECT *
FROM user_tables
WHERE table_name = UPPER('employees');

-- employees 테이블은 누가 OWNER인가?
SELECT *
FROM ;

--
SELECT 65, CHR(65)
FROM dual; -- from절 필수사항. dual 확인 용도

-- 
-- (기억) not a single-group group function
SELECT insa.*, COUNT(*) -- 단일행함수(모든 칼럼), 복수행 함수(여러개 -> 결과 한개) 같이 사용 불가 
FROM insa
WHERE buseo = '개발부';

-- 복습 풀이, 20250319 수업
-- [문제] SELECT문(DQL) 연습
--       WHERE 절
--       ORDER BY 절         ASC/DESC

-- insa 테이블에서 출생년도가 70년대생인 사원 정보를 조회.
SELECT num, name, ssn
FROM insa
--WHERE 70년대생 조건식; java: startwith, chatat, substring
-- SUBSTR 함수 이용
--WHERE SUBSTR(ssn,1,1) = 7; -- 1번째 위치 1개 -- '7'
WHERE SUBSTR(ssn, 0, 1) = 7 -- 문자이므로 홑따옴표 있어야함. 자바면 오류
ORDER BY ssn;


SELECT SUBSTR(ssn,-7) -- 뒤 값 없으면 지정 위치부터 끝까지
FROM insa

-- [풀이] INSTR()
SELECT num, name, ssn
    , INSTR(ssn, '7')
FROM insa
WHERE INSTR(ssn, '7') = '1';

-- [풀이]LIKE 연산자 사용
SELECT num, name, ssn
FROM insa
WHERE ssn LIKE '7_____-_______' 
--WHERE ssn LIKE '7%' -- 문자이므로 홑따옴표 있어야함. 자바면 오류
ORDER BY ssn ASC;

-- [문제] insa 테이블에서 사원의 성이 김씨인 사원 조회
SELECT num, name
FROM insa
WHERE REGEXP_LIKE(name, '^김');
WHERE name LIKE '김__'; -- 세글자, 첫번째 단어는 '김'
WHERE name LIKE '%김%'; -- 위치에 상관없이 '김'문자를 포함하는지
WHERE name LIKE '%김'; -- 이름의 맨 마지막 문자는 '김'
WHERE name LIKE '김%'; --   "      처음    "
--WHERE -- SUBSTR(), INSTR()

-- [실행결과]
SELECT name
--        , ssn rrn
--        , SUBSTR( ssn, 1, 8 ) || '******' rrn
--        , CONCAT(SUBSTR( ssn, 1, 8 ) , '******') rrn
--        , RPAD
--        , RPAD (SUBSTR( ssn, 1, 8 ), 14, '*') rrn
--          REPLACE() 함수
--        , REPLACE ( ssn, SUBSTR(ssn, -6 ) , '******') rrn
--        , REGEXP_REPLACE() 함수

FROM insa;

--
--10	ACCOUNTING	NEW YORK
--20	RESEARCH	DALLAS
--30	SALES	CHICAGO
--40	OPERATIONS	BOSTON
SELECT dname
        , REPLACE ( dname, 'E' ) -- 삭제
        , REPLACE ( dname, 'E', '[이]' ) -- 교체 
FROM dept;


-- RPAD() / LPAD() 함수 사용 예
SELECT ename, sal
    , RPAD(sal, 10, '*')
    , LPAD(sal, 10, '#')
FROM emp;

-- ORDER BY ??, ??;
SELECT deptno, ename, sal
FROM emp
ORDER BY 1, 3 DESC;
ORDER BY deptno ASC, sal DESC;
ORDER BY deptno ASC, ename ASC; -- 1차정렬, 2차정렬, 3차 정렬...

-- TBL_TEST 테이블 확인
SELECT *
FROM tbl_test;
-- REGEXP_REPLACE() 함수 테스트
SELECT regexp_replace(email,'http://([^/]+).*', '\1')
from tbl_test;
--
SELECT email
        , regexp_replace(email,'arirang', 'seoul')
FROM tbl_test;
--
SELECT 'hello hi hello hi hello'
          , regexp_replace('HeLLo hi hello hi HELLO','HeLLo', '헬로우', 1,0,'i') -- 생략하면 누군지 모름
--        , regexp_replace('hello hi hello hi hello','hello', '헬로우')
--        -- 첫번째 hello 만을 '헬로우' 교체
--        ,regexp_replace('hello hi hello hi hello','hello', '헬로우', 1, 1)
--        ,regexp_replace('hello hi hello hi hello','hello', '헬로우', 6, 1)
--        ,regexp_replace('hello hi hello hi hello','hello', '헬로우', 1, 2)
FROM dual;
--
SELECT regexp_replace('HeLLo 123 hello 3456 HELLO','\d+', '헬로우')
FROM dual;
--
SELECT REGEXP_REPLACE('LEE CHANG IK', '(.*) (.*) (.*)', '\3 \2 \1')
FROM dual;

SELECT name, ssn
    -- , REGEXP_REPLACE()
    , REGEXP_REPLACE(ssn, '(\d{6}-\d)\d{6}', '\1******' )
FROM insa;

-- 주민등록 번호로부터 년/월/일 출력.
SELECT name, ssn
--    , SUBSTR(ssn,0,2) year
--    , SUBSTR(ssn,3,2) month
--    , SUBSTR(ssn,5,2) AS "date" -- 예약어도 ""븉이면 alias 사용가능, ""안에 있는건 대문자 변환 안됨
    , SUBSTR(ssn,0,6) --  ' '문자열 return -> 날짜 자료형 변환
    , TO_DATE(SUBSTR(ssn,1,6))
FROM insa;

-- 오늘 날짜 정보 조회. SYSDATE 함수(괄호없어도 함수)
-- '25/03/19'
SELECT SYSDATE
--    , TO_CHAR( 날짜, 또는 숫자 )
      ,TO_CHAR( SYSDATE, 'YYYY' )y
--      , TO_CHAR( SYSDATE, 'year' )
      , TO_CHAR( SYSDATE, 'MM' )m -- '03'
--      , TO_CHAR( SYSDATE, 'MONTH' ) -- '3월'
--      , TO_CHAR( SYSDATE, 'MON' )-- '3월'
    , TO_CHAR( SYSDATE, 'DD' )d
    , TO_CHAR( SYSDATE, 'DY' ) --수
    , TO_CHAR( SYSDATE, 'DAY' ) --수요일
FROM dual;

-- 오늘 문제 70년대생 사원 정보 조회
SELECT *
FROM ( -- 인라인뷰
    SELECT name, ssn
    , TO_CHAR( TO_DATE( SUBSTR(ssn,1,6) ), 'YY' ) yy
    FROM insa
    ) t
WHERE yy BETWEEN 70 AND 79;    
--

SELECT ename, hiredate
, TO_CHAR(hiredate, 'YYYY')y
, TO_CHAR(hiredate, 'MM')m
, TO_CHAR(hiredate, 'DD')d -- 문자 리턴
--, EXTRACT() -- 추출하다
, EXTRACT ( YEAR FROM hiredate ) y2
, EXTRACT ( MONTH FROM hiredate ) m2
, EXTRACT ( DAY FROM hiredate ) d2 -- 숫자 리턴
-- 형변환 필요없음
FROM emp;

-- 현재 시간 가져오는 함수 기억 
SELECT SYSDATE, CURRENT_TIMESTAMP -- 오라클 자료형 DATE, TIMESTAMP
FROM dual;

--REGEXP 기억






