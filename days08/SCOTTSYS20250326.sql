--SCOTT--

-- [문제] emp 테이블에서 
--       sal 칼럼을 기준으로 상위 20%에 해당되는 사원정보 조회
-- RANK()
SELECT *
FROM(
SELECT emp.*
        , RANK() OVER(ORDER BY sal DESC) sal_rank
        FROM emp
        
    )
WHERE sal_rank <= (SELECT FLOOR(COUNT(*)*0.2) FROM emp);

-- [2] PERCENT_RANK()
SELECT *
FROM(
    SELECT emp.*
        , PERCENT_RANK() OVER (ORDER BY sal DESC) sal_rank
    FROM emp
    )
WHERE sal_rank <= 0.2;

-- [나]
SELECT e.*, ROWNUM
FROM (
    SELECT *
    FROM emp
    ORDER BY sal DESC
)e
WHERE ROWNUM <= (SELECT FLOOR(COUNT(*)*0.2) FROM emp);

-- [문제] 다음주 월요일 휴가이다. (몇 일 확인 쿼리)
SELECT SYSDATE
    , TO_CHAR(SYSDATE, 'D')a -- 일1, 월2, 화3, 수4, 목5, 금6, 토7
    , TO_CHAR(SYSDATE, 'DY')b
    , TO_CHAR(SYSDATE, 'DAY')c
FROM dual;

SELECT NEXT_DAY(SYSDATE, '월')
FROM dual;

-- [문제] emp 테이블에서 각 사원들의 입사일자를 기준으로 10년 5개월 20일 째 되는 
-- 날짜를 출력하는 쿼리
SELECT ename, hiredate
        , ADD_MONTHS(hiredate, 10*12 +5 ) +20
FROM emp;

-- [ 문제 ] insa 테이블에서 [실행결과]
--                                           부서사원수/전체사원수 == 부/전 비율
--                                           부서의 해당성별사원수/전체사원수 == 부성/전%
--                                           부서의 해당성별사원수/부서사원수 == 성/부%
--                                           
--부서명     총사원수 부서사원수 성별  성별사원수  부/전%   부성/전%   성/부%
--개발부       60       14         F       8       23.3%     13.3%       57.1%
--개발부       60       14         M       6       23.3%     10%       42.9%
--기획부       60       7         F       3       11.7%       5%       42.9%
--기획부       60       7         M       4       11.7%   6.7%       57.1%
--영업부       60       16         F       8       26.7%   13.3%       50%
--영업부       60       16         M       8       26.7%   13.3%       50%
--인사부       60       4         M       4       6.7%   6.7%       100%
--자재부       60       6         F       4       10%       6.7%       66.7%
--자재부       60       6         M       2       10%       3.3%       33.3%
--총무부       60       7         F       3       11.7%   5%           42.9%
--총무부       60       7         M    4       11.7%   6.7%       57.1%
--홍보부       60       6         F       3       10%       5%           50%

SELECT buseo, COUNT(*)부서사원수
        ,DECODE( MOD(SUBSTR(ssn,-7,1), 2 ), 1, 'M', 'F')성별  
FROM insa
GROUP BY buseo, MOD(SUBSTR(ssn,-7,1), 2 )
ORDER BY buseo;


WITH t AS(
    SELECT buseo, COUNT(*)부서사원수
    FROM insa
    GROUP BY buseo
    ORDER BY buseo
)
SELECT DISTINCT i.buseo, t.부서사원수
        ,DECODE( MOD(SUBSTR(ssn,-7,1), 2 ), 1, 'M', 'F')성별  
        ,(SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)성별사원수
        , ROUND(t.부서사원수/(SELECT COUNT(*) FROM insa ) *100, 1) "부/전 비율"
        , ROUND((SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)/(SELECT SUM(부서사원수)FROM t ) *100, 1) "부성/전%"
        , ROUND((SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)/t.부서사원수*100, 1 ) "성/부%"
FROM insa i LEFT JOIN t ON i.buseo = t.buseo
ORDER BY buseo;


-- 홍길동~
WITH a AS (
    SELECT buseo, (SELECT COUNT(*) FROM insa) 총사원수, (
        SELECT COUNT(*) n
        FROM insa
        WHERE buseo = a.buseo
        GROUP BY buseo
    ) 부서사원수, DECODE(MOD(SUBSTR(ssn, -7, 1),2), 1, 'M', 'F') 성별, COUNT(*) 성별사원수
    FROM insa a
    GROUP BY buseo, MOD(SUBSTR(ssn, -7, 1),2)  
    ORDER BY buseo
)
SELECT a.*,  (ROUND("부서사원수"/"총사원수"*100,1))|| '%' "부/전%",
        (ROUND("성별사원수"/"총사원수"*100,1))|| '%' "부성전%",
        (ROUND("성별사원수"/"부서사원수"*100,1))|| '%' "부성전%"
FROM a;

-- 김길동
WITH t AS(
    SELECT buseo, COUNT(*)부서사원수
    FROM insa
    GROUP BY buseo
    ORDER BY buseo
)
SELECT DISTINCT i.buseo, t.부서사원수
        ,DECODE( MOD(SUBSTR(ssn,-7,1), 2 ), 1, 'M', 'F')성별  
        ,(SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)성별사원수
        , ROUND(t.부서사원수/(SELECT SUM(부서사원수)FROM t ) *100, 1) "부/전 비율"
        , ROUND((SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)/(SELECT SUM(부서사원수)FROM t ) *100, 1) "부성/전%"
        , ROUND((SELECT COUNT(*) FROM insa WHERE MOD(SUBSTR(i.ssn,-7,1), 2 ) = MOD(SUBSTR(ssn,-7,1), 2 ) AND i.buseo = buseo)/t.부서사원수*100, 1 ) "성/부%"
FROM insa i LEFT JOIN t ON i.buseo = t.buseo
ORDER BY buseo;
-- 박길동
SELECT e.*
            , ROUND(e."부서 사원수"/ e."총사원수" * 100, 1) || '%' "부/전%"
             , ROUND(e."성별 사원 수"/ e."총사원수" * 100, 1) || '%' "부성/전%"
              , ROUND(e."성별 사원 수"/ e."부서 사원수" * 100, 1) || '%' "성/부%"
FROM (
SELECT buseo "부서명"
          , (SELECT COUNT(*) FROM insa) "총사원수"
          , (SELECT COUNT(*) FROM insa WHERE buseo = i.buseo) "부서 사원수"
          , DECODE(SUBSTR(ssn, -7 ,1), 1, 'M', 'F') "성별"
          , COUNT(DECODE(SUBSTR(ssn, -7 ,1), 1, 'M', 'F')) "성별 사원 수"
FROM insa i
GROUP BY buseo, DECODE(SUBSTR(ssn, -7 ,1), 1, 'M', 'F')
ORDER BY buseo
) e;

-- [1] 풀이
WITH a AS(
SELECT buseo, name, ssn
        ,DECODE(MOD( SUBSTR(ssn, -7, 1), 2),1, 'M', 'F')gender
FROM insa
), b AS(
    SELECT buseo 부서명
    , (SELECT COUNT(*) FROM insa)총사원수
    , (SELECT COUNT(*) FROM insa WHERE buseo = a.buseo )부서사원수
    , gender 성별
    , COUNT(*)성별사원수
    FROM a
    GROUP BY buseo, gender
    ORDER BY buseo, gender
)
SELECT b.*
    ,ROUND(   부서사원수/총사원수*100, 2) || '%' "부/전%"
    ,ROUND(   성별사원수/총사원수*100, 2) || '%' "부성/전%"
    ,ROUND(   성별사원수/부서사원수*100, 2) || '%'  "성/부%"
FROM b;

-- (학생)
SELECT t1.buseo,
    (SELECT COUNT(*) FROM insa) 총사원,
    t2.부서별,
    DECODE(t1.gender,1,'M','F') gender,
    t1.성별,
    ROUND(t2.부서별/(SELECT COUNT(*) FROM insa)*100,1) || '%' "부/전",
    ROUND(t1.성별/(SELECT COUNT(*) FROM insa)*100,1) || '%' "성/전",
    ROUND(t1.성별/t2.부서별*100,1) || '%' "성/부"
FROM (
    SELECT buseo, 
        MOD(SUBSTR(ssn, -7, 1),2) gender,
        COUNT(*) 성별
    FROM insa
    GROUP BY buseo, MOD(SUBSTR(ssn, -7, 1),2)
) t1 JOIN (
    SELECT buseo,
        COUNT(*) 부서별
    FROM insa
    GROUP BY buseo
) t2
ON t1.buseo = t2.buseo
ORDER BY t1.buseo;

-- (학생)
SELECT temp.*
        , ROUND((temp.부서사원수 / temp.총사원수) * 100, 1) || '%' AS "부/전%"
        , ROUND((temp.성별사원수 / temp.총사원수) * 100, 1) || '%' AS "부성/전%"
        , ROUND((temp.성별사원수 / temp.부서사원수) * 100, 1) || '%' AS "성/부%"        
FROM(
    SELECT buseo, (SELECT COUNT(name) FROM insa) AS 총사원수
            , (SELECT COUNT(name) FROM insa WHERE i.buseo = buseo) 부서사원수
            , DECODE(SUBSTR(ssn, -7, 1), 1, 'M', 'F') AS 성별
            , COUNT(DECODE(SUBSTR(ssn, -7, 1), 1, 'M', 'F')) AS 성별사원수
    FROM insa i  
    GROUP BY buseo, DECODE(SUBSTR(ssn, -7, 1), 1, 'M', 'F')
) temp
ORDER BY buseo

-- (학생)
WITH a AS(
SELECT buseo, (SELECT COUNT(num) FROM insa) 총사원수
FROM insa
GROUP BY buseo
)
, b AS (
SELECT buseo, COUNT(num) 부서사원수
FROM insa
GROUP BY buseo
ORDER BY buseo
)
, c AS (
SELECT buseo, NVL2(DECODE(MOD(SUBSTR(ssn, -7, 1), 2), 1, '0'), 'M', 'F') 성별
FROM insa
GROUP BY buseo, NVL2(DECODE(MOD(SUBSTR(ssn, -7, 1), 2), 1, '0'), 'M', 'F')
ORDER BY buseo
) 
SELECT a.buseo, 총사원수
      , COUNT(*) OVER(PARTITION BY a.buseo) 
      , 성별
      , COUNT(*) OVER(PARTITION BY 성별) 
FROM a, b, c, insa 
-- WHERE
GROUP BY a.buseo, 총사원수, 부서사원수, 성별
ORDER BY a.buseo;

-- LISTAGG() 함수
-- [문제]
-- [실행결과]
-- 부서번호  해당 부서에 속한 사원들
-- 10       CLARK/MILLER/KING
-- 20       CLARK/MILLER/KING
-- 30       CLARK/MILLER/KING

SELECT deptno
        , COUNT(*)부서별사원수
        , LISTAGG(ename, '/') WITHIN GROUP(ORDER BY ename ASC)enameList
FROM emp
GROUP BY deptno --> 집계함수를 쓰겠다는 의미
ORDER BY deptno;

--[2]
-- deptno null -> 부서없음
--         40  -> 사원없음

SELECT NVL(TO_CHAR(d.deptno), '부서없음') deptno
        , COUNT(ename)부서별사원수
        , NVL(LISTAGG(e.ename, '/') WITHIN GROUP(ORDER BY e.ename ASC), '사원없음') enameList
        , CASE 
                WHEN d.deptno = 40 THEN '사원없음'
                ELSE            LISTAGG(e.ename, '/') WITHIN GROUP(ORDER BY e.ename ASC)
            END enameList
FROM emp e FULL OUTER JOIN dept d ON e.deptno = d.deptno
GROUP BY d.deptno 
ORDER BY d.deptno;

-- [문제 ] TRUNC() 절삭 함수
SELECT SYSDATE
        ,TO_CHAR( TRUNC( SYSDATE ,  'YYYY') , 'DS TS(DY)')-- 25/01/01
        ,TO_CHAR( TRUNC( SYSDATE ,  'MM') , 'DS TS(DY)')
        ,TO_CHAR( TRUNC( SYSDATE ,  'DD') , 'DS TS(DY)')
        ,TO_CHAR( TRUNC( SYSDATE ), 'DS TS(DY)' )
FROM dual;

-- [문제] insa 테이블에서 급여 많이 받는 5명만 출력
-- [1] 풀이 TOP-N 분석 방법

SELECT i.*, ROWNUM 순위     -- ROWNUM 의사칼럼 -> 순번
FROM (                  -- 인라인뷰 2번
    SELECT * 
    FROm insa
    ORDER BY basicpay DESC   -- 정렬 1번
)i
WHERE ROWNUM <= 5;      -- 4번


-- [2] 풀이 순위 함수

SELECT *
FROM (
    SELECT insa.*, RANK() OVER(ORDER BY basicpay DESC)순위
    FROM insa
)i
WHERE 순위 <= 5;

-- [달력 출력] 
-- 이해1) LEVEL, CONNECT BY 절
-- SELECT TO_DATE(:yyyymm , 'YYYYMM') + LEVEL - 1  dates
--        FROM dual
--        CONNECT BY LEVEL <= EXTRACT ( DAY FROM LAST_DAY(TO_DATE(:yyyymm , 'YYYYMM') ) )

SELECT LEVEL
FROM dual;
-- ORA-01788: [CONNECT BY clause] required in this query block
SELECT TO_DATE(:yyyymm, 'YYYYMM') + LEVEL -1 
FROM dual
CONNECT BY LEVEL <= EXTRACT( DAY FROM LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) );

-- 이해 2)-- 주 얻어오기
SELECT TO_DATE('2025/01/05')
        , TO_CHAR ( TO_DATE('2025/01/05'), 'WW')     " 년 중에 몇 번째 주"
        , TO_CHAR ( TO_DATE('2025/01/05'), 'W')      " 월 중에 몇 번째 주"
        , TO_CHAR ( TO_DATE('2025/01/05'), 'IW')     " 년 중에 몇 번째 주"
FROM dual;
--
SELECT d
        , TO_CHAR ( TO_DATE(d), 'WW')     " 년 중" -- 요일과 상관없이 7일을 한 주로 
        , TO_CHAR ( TO_DATE(d), 'W')      " 월 중"
        , TO_CHAR ( TO_DATE(d), 'IW')     " 년 중"
        , TO_CHAR ( TO_DATE(d), 'D')
FROM(
SELECT TO_DATE('24/12/29') + LEVEL -1 d
FROM dual
CONNECT BY LEVEL <= 30
);


-- [문제] emp 테이블에서 사원수가 가장 많은 부서명, 사원수
--      사원수가 가장 적은 부서명, 사원수 출력
-- 1)  SET 연산자 ;U,UA(합집합) -- +) 
SELECT s.*
    , CASE s.cnt_rank
        WHEN 1 THEN '많은 부서'
        ELSE '적은 부서'
        END
FROM (
SELECT t.*
    , RANK() OVER(ORDER BY cnt DESC)cnt_rank 
FROM(
SELECT d.deptno, dname
        , COUNT(ename)cnt
FROM emp e RIGHT OUTER JOIN dept d ON e.deptno = d.deptno
GROUP BY d.deptno, dname
ORDER BY d.deptno ASC
    ) t
)s
WHERE cnt_rank IN(1,(SELECT MAX());


WITH t AS(
    SELECT d.deptno, dname
         , COUNT(ename)cnt
    FROM emp e RIGHT OUTER JOIN dept d ON e.deptno = d.deptno
    GROUP BY d.deptno, dname
    ORDER BY d.deptno ASC
), s AS(
    SELECT t.*
         , RANK() OVER(ORDER BY cnt DESC)cnt_rank 
    FROm t
)
SELECT s.*
    , CASE s.cnt_rank
        WHEN 1 THEN '많은 부서'
        ELSE '적은 부서'
        END
FROm s;


-- 내 풀이
SELECT *
FROm (
    SELECT d.dname 부서명, COUNT(e.ename)사원수, RANK() OVER(ORDER BY COUNT(e.ename)DESC)순위
    FROM emp e RIGHT OUTER JOIN dept d ON e.deptno = d.deptno
    GROUP BY d.dname
)a
WHERE a.순위 =1 or a.순위 = (SELECT COUNT(*) from dept);


-- [ 문제 ] JOB 별 사원수를 출력(조회)
-- COUNT(*), DECODE()
SELECT
    COUNT( DECODE(job, 'CLERK', 'O') )CLERK
    ,COUNT( DECODE(job, 'SALESMAN', 'O') )SALESMAN
    ,COUNT( DECODE(job, 'PRESIDENT', 'O') )PRESIDENT
    ,COUNT( DECODE(job, 'MANAGER', 'O') )MANAGER
    ,COUNT( DECODE(job, 'ANALYST', 'O') )ANALYST
FROM emp;

-- [ 피봇(PIVOT)/언피봇(UNPIVOT) 설명 ]
-- pivot: 축을 중심으로 회전시키다.
--SELECT * 
--  FROM (피벗 대상 쿼리문)
-- PIVOT (그룹함수(집계컬럼) FOR 피벗컬럼 IN(피벗컬럼 값 AS 별칭...))

SELECT job
FROM emp;

SELECT *
FROM (
    SELECT job -- 피봇 대상이 되는 쿼리문
    FROM emp 
    )
PIVOT( COUNT(job) FOR job IN('CLERK' , 'SALESMAN', 'PRESIDENT', 'MANAGER','ANALYST') );

--(2) 두번째 pivot 예제
-- emp 테이블에서 각 월별 입사한 사원수 파악
SELECT *
FROM (
    SELECT TO_CHAR(hiredate, 'YYYY')year
        ,TO_CHAR(hiredate, 'MM')month -- 피봇 대상이 되는 쿼리문
    FROM emp 
    )
PIVOT( COUNT(month) FOR month IN('01' AS"1월" , '02', '03', '04','05', '06', '07', '08','09', '10','11','12') )
ORDER BY year ASC;

-- [문제]
--    DEPTNO DNAME             'CLERK' 'SALESMAN' 'PRESIDENT'  'MANAGER'  'ANALYST'
------------ -------------- ---------- ---------- ----------- ---------- ----------
--        10 ACCOUNTING              1          0           1          1          0
--        20 RESEARCH                1          0           0          1          1
--        30 SALES                   1          4           0          1          0
--        40 OPERATIONS              0          0           0          0          0 

--(1) PIVOTx
SELECT d.deptno, dname
    , COUNT( DECODE(job, 'CLERK', 'O') )CLERK
    ,COUNT( DECODE(job, 'SALESMAN', 'O') )SALESMAN
    ,COUNT( DECODE(job, 'PRESIDENT', 'O') )PRESIDENT
    ,COUNT( DECODE(job, 'MANAGER', 'O') )MANAGER
    ,COUNT( DECODE(job, 'ANALYST', 'O') )ANALYST
FROM emp e FULL OUTER JOIN dept d ON e.deptno = d.deptno 
--FROM emp e , dept d
--WHERE e.deptno(+) = d.deptno(+)
GROUP BY d.deptno, dname
ORDER BY d.deptno ASC;

--(2) PIVOT 사용
SELECT *
FROm(
    SELECT d.deptno, dname ,job
    FROM emp e FULL JOIN dept d ON e.deptno = d.deptno 
    )
PIVOT ( COUNT(job) FOR job IN('CLERK' , 'SALESMAN', 'PRESIDENT', 'MANAGER','ANALYST')) -- (SELECT job FROM emp) 서브쿼리 안됨.. 일일이 다 작성해야함.
ORDER BY deptno, dname ASC ;

-- COUNT,DECODE <-> PIVOT


-- [문제] insa 테이블에서 
--              오늘생일    생일지남    생일안지남
--                  1       39          27
-- 이순신 월/일 0326 UPDATE + COMMIT
SELECT *
FROm insa;
UPDATe insa
SET ssn = '800326-1544236'
WHERE num = 1002;
commit;

--(1) pivot x
SELECT TRUNC(SYSDATE)
FROm dual;


WITH t AS (
    SELECT ssn
        , SUBSTR( ssn, 3, 4 )
        , TO_CHAR( TO_DATE( SUBSTR( ssn, 3, 4 ), 'MMDD' ) , 'DS TS')
        , TO_CHAR( TRUNC(SYSDATE) , 'DS TS')
        , SIGN( TO_DATE( SUBSTR( ssn, 3, 4 ), 'MMDD' ) - TRUNC(SYSDATE) ) b_sign
    FROM insa
)
SELECT t.b_sign, COUNT(*)
     , CASE   t.b_sign
           WHEN 1 THEN 'X'
           WHEN 0 THEN '오늘'
           WHEN -1 THEN 'O '
       END
FROM t
GROUP BY t.b_sign ;

-- 가로 출력
WITH t AS (
    SELECT ssn
        , SUBSTR( ssn, 3, 4 )
        , TO_CHAR( TO_DATE( SUBSTR( ssn, 3, 4 ), 'MMDD' ) , 'DS TS')
        , TO_CHAR( TRUNC(SYSDATE) , 'DS TS')
        , SIGN( TO_DATE( SUBSTR( ssn, 3, 4 ), 'MMDD' ) - TRUNC(SYSDATE) ) b_sign
    FROM insa
)
SELECT COUNT( DECODE(b_sign,1 , 'X') )"X"
        ,COUNT( DECODE(b_sign,-1 , 'X') )"O"
        ,COUNT( DECODE(b_sign,0 , 'X') )"오늘"
FROM t
;

-- 내풀이
WITH a AS(
    SELECT insa.*
            , SIGN(TRUNC(SYSDATE) - TO_DATE(SUBSTR(ssn,3,4),'MMDD'))생일판단
    FROM insa
)
SELECT COUNT( DECODE( 생일판단, 0, 'O' ) )오늘생일
        ,COUNT( DECODE( 생일판단, -1, 'O' ) )생일안지남
        ,COUNT( DECODE( 생일판단, 1, 'O' ) )생일지남
FROM a;

--(2) PIVOT 사용
--
SELECT *
FROM(
    SELECT SIGN( TO_DATE( SUBSTR( ssn, 3, 4 ), 'MMDD' ) - TRUNC(SYSDATE) ) b_sign
    FROM insa
)
PIVOT (COUNT(b_sign) FOR b_sign IN(1 AS 생일안지남, 0 AS 오늘생일, -1 AS 생일지남)) ;

-- 내풀이
SELECT *
FROM (
    SELECT 생일판단
    FROm (
    SELECT insa.*
            , SIGN(TRUNC(SYSDATE) - TO_DATE(SUBSTR(ssn,3,4),'MMDD'))생일판단
    FROM insa
    )a
)
PIVOT (COUNT(생일판단) FOR 생일판단 IN(-1 AS 생일안지남, 0 AS 오늘생일, 1 AS 생일지남));

-- [문제] pivot 예제
SELECT deptno, sal+NVL(comm,0) pay
FROm emp ;
-- 각 부서별 pay의 총급여합 조회
SELECT *
FROM (
    SELECT deptno, sal+NVL(comm,0) pay
    FROm emp 
)
PIVOT( SUM(pay) FOR deptno IN(10,20,30,40,null) );

-- [문제]
SELECT *
FROm (
SELECT deptno, sal
FROm emp
 )
 PIVOT( SUM(sal), MAX(sal) AS 최고액, MIN(sal) AS 최저액 FOR deptno IN(10,20,30,40) ); -- 집계함수 여러개 올 수 있음

-- [ 문제 ]
-- DDL 문 : CREATE 
CREATE TABLE tbl_pivot
(
--    컬럼명 자료형(크기) 제약조건...
     no    NUMBER            PRIMARY KEY -- 고유한키(PK) 제약조건 = UK + NN 자동으로 같이 걸림 -- 학번같은사람 없음
   , name  VARCHAR2(20 BYTE) NOT NULL -- NN 제약조건(== 필수입력사항)
   , jumsu NUMBER(3)  -- NULL 허용
); 
-- Table TBL_PIVOT이(가) 생성되었습니다.
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 1, '박예린', 90 );  -- kor
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 2, '박예린', 89 );  -- eng
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 3, '박예린', 99 );  -- mat
 
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 4, '안시은', 56 );  -- kor
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 5, '안시은', 45 );  -- eng
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 6, '안시은', 12 );  -- mat 
 
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 7, '김민', 99 );  -- kor
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 8, '김민', 85 );  -- eng
INSERT INTO TBL_PIVOT ( no, name, jumsu ) VALUES ( 9, '김민', 100 );  -- mat 

COMMIT; 
---
SELECT * 
FROM tbl_pivot;

-- (피봇되어져서 결과 출력)
-- no 이름 국 영 수
-- 1 박예린 90 89 99
-- 2 안시은 56 45 12

SELECT *
FROm (
    SELECT TRUNC((no -1)/3)+1 no
            , name
            , jumsu
            , DECODE (MOD(no,3) , 1, '국어', 2, '영어', '수학')subject
    FROm tbl_pivot
    )
PIVOT (AVG(jumsu) FOR subject IN('국어', '영어', '수학'))
ORDER BY no ASC;

-- [2] 풀이
SELECT *
FROM (
      SELECT TRUNC( (no-1)/3 )+1  no
            , name
            , jumsu
            , ROW_NUMBER() OVER(PARTITION BY name ORDER BY no)  subject
      FROM tbl_pivot
)
PIVOT( SUM(jumsu) FOR subject IN (1 AS "국어", 2 AS "영어",3 AS "수학"))
ORDER BY no ASC; 

----
FROM(
    SELECT name
    FROm (
        SELECT 
            CASE WHEN MOD(no,3) = 1 THEN jumsu END 국어
            ,CASE WHEN MOD(no,3) = 2 THEN jumsu END 영어
            ,CASE WHEN MOD(no,3) = 0 THEN jumsu END 수학  
        FROm tbl_pivot 
    )

    );

-- 자주 사용함
-- 오라클 10G 새로 추가된 기능 : PARTITION BY OUTER JOIN 구문
-- [문제] insa 테이블에서 각 부서별/출신지역별 사원 수 몇명인지 출력(조회)
SELECT DISTINCT city -- 11개
FROm insa;
-- 
SELECT buseo, city, COUNT(*)사원수
FROM insa
GROUP BY buseo, city
ORDER BY buseo, city;
-- 각 부서의 출신지역에 사원이 없는 도시도 출력
WITH c AS(
    SELECT  DISTINCT city -- 11개의 출신지역
    FROM insa
)
SELECT buseo, c.city, COUNT(num)사원수
FROM insa i PARTITION BY(buseo) RIGHT JOIN c ON i.city = c.city
GROUP BY buseo, c.city
ORDER BY buseo, c.city;

-- [문제] emp 테이블에서
-- 각 년도별, 월별 입사한 사원수 조회
WITH a AS(
    SELECT TO_CHAR(hiredate, 'YYYY')입사년도, TO_CHAR(hiredate, 'MM')입사월
    FROm emp
)
SELECT 입사년도, 입사월, COUNT(*)사원수
FROM a
GROUP BY 입사년도, 입사월
ORDER BY 입사년도, 입사월;
-- 모든 월 조회

WITH a AS(
    SELECT empno,
        TO_CHAR(hiredate, 'YYYY')입사년도, TO_CHAR(hiredate, 'MM')입사월
    FROm emp
), b AS(
    SELECT LPAD(LEVEL, 2, '0') AS 입사월
    FROM dual
    CONNECT BY LEVEL <= 12
)
SELECT 입사년도, b.입사월, COUNT(empno)사원수
FROM a PARTITION BY(입사년도) RIGHT JOIN b ON a.입사월 = b.입사월
GROUP BY 입사년도, b.입사월
ORDER BY 입사년도, b.입사월;

------
WITH t1 AS (
    SELECT EXTRACT(YEAR FROM(ADD_MONTHS(TRUNC(TO_DATE('80', 'rr'), 'year'), LEVEL - 1))) 년도,
        EXTRACT(MONTH FROM(ADD_MONTHS(TRUNC(TO_DATE('80', 'rr'), 'year'), LEVEL - 1))) 월별
    FROM dual
    CONNECT BY LEVEL <= 36
) ,temp AS (
    SELECT ename, TRUNC(hiredate, 'month') k, EXTRACT(YEAR FROM hiredate) 년도, EXTRACT(MONTH FROM hiredate) 월별
    FROM emp
)
SELECT b.년도, b.월별, COUNT(ename) 사원수
FROM temp a PARTITION BY (a.년도, a.월별) RIGHT OUTER JOIN t1 b ON (a.년도 = b.년도 AND a.월별 = b.월별)
GROUP BY b.년도, b.월별
ORDER BY b.년도, b.월별;

--[2] 풀이
WITH e AS(
    SELECT empno
            , TO_CHAR( hiredate, 'YYYY') year
            , TO_CHAR(hiredate, 'MM') month
    FROM emp
), m AS(
    SELECT LEVEL month
    FROM dual
    CONNECT BY LEVEL <=12
    )
SELECT e.year, m.month, COUNT(empno)
FROM e PARTITION BY(e.year) RIGHT JOIN m ON e.month = m.month
GROUP BY e.year, m.month
ORDER BY e.year, m.month;

--[3]

SELECT e.year, m.month, COUNT(empno)
FROM (
     SELECT empno
            , TO_CHAR( hiredate, 'YYYY') year
            , TO_CHAR(hiredate, 'MM') month
    FROM emp

    ) e PARTITION BY(e.year) 
        RIGHT JOIN (
                SELECT LEVEL month
                FROM dual
                CONNECT BY LEVEL <=12
                ) m ON e.month = m.month
GROUP BY e.year, m.month
ORDER BY e.year, m.month;

-- [문제] 분석함수 FIRST, LAST -- 집계함수와 같이 사용(형식상 필요한 것으로 아무거나 와도 상관없음!, DENSE_RANK() 필수 
--            집계함수(COUNT, SUM, AVG, MAX, MIN)와 같이 사용하여 
--            주어진 그룹에 대해 내부적으로 순위를 매겨 결과를 산출하는 함수
--       emp 테이블에서 sal 가장 많이 받는 사원의 이름, sal 출력
--       emp 테이블에서 sal 가장 적게 받는 사원의 이름, sal 출력
SELECT MAX(sal), MIN(sal)
FROM emp;

FROM emp WHERE sal =

--
SELECT 
    MAX(sal)
    , MAX(ename) KEEP ( DENSE_RANK FIRST ORDER BY sal DESC) max_pay
    , MIN(sal)
    , MIN(ename) KEEP ( DENSE_RANK LAST ORDER BY sal DESC) min_pay
FROM emp;

-- [문제] emp 테이블에서 각 부서별 최고 sal, empno, 최저 sal, empno
SELECT 
    deptno
    , MAX(sal)
    , MAX(empno) KEEP ( DENSE_RANK FIRST ORDER BY sal DESC) max_pay
    , MIN(sal)
    , MIN(empno) KEEP ( DENSE_RANK LAST ORDER BY sal DESC) min_pay
FROM emp
GROUP BY deptno;