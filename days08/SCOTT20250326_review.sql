-- SCOTT --
-- [문제] emp 테이블에서
--       sal 컬럼을 기준으로 상위 20%에 해당 되는 사원 정보 조회.
SELECT e.*, ROWNUM
FROM (
    SELECT *
    FROM emp
    ORDER BY sal DESC
    )e
WHERE ROWNUM <= (SELECT COUNT(*)*0.2 FROM emp);

SELECT *
FROM(
    SELECT emp.*, PERCENT_RANK() OVER(ORDER BY sal DESC)순위
    FROM emp
    ) e
WHERE 순위 <= 0.2;


-- [문제] emp 테이블에서 각 사원들의 입사일자를 기준으로 10년 5개월 20일 째 되는 
-- 날짜를 출력하는 쿼리
SELECT ADD_MONTHS(hiredate, 10*12+5) + 20
FROM emp;

-- [문제] insa 테이블에서 
--[실행결과]
--                                           부서사원수/전체사원수 == 부/전 비율
--                                           부서의 해당성별사원수/전체사원수 == 부성/전%
--                                           부서의 해당성별사원수/부서사원수 == 성/부%
--                                           
--부서명     총사원수 부서사원수 성별  성별사원수  부/전%   부성/전%   성/부%
--개발부	    60	    14	      F	    8	    23.3%	  13.3%	    57.1%
--개발부	    60	    14	      M	    6	    23.3%	  10%	    42.9%
--기획부	    60	    7	      F	    3	    11.7%	    5%	    42.9%
--기획부	    60	    7	      M	    4	    11.7%	6.7%	    57.1%
--영업부	    60	    16	      F	    8	    26.7%	13.3%	    50%
--영업부	    60	    16	      M	    8	    26.7%	13.3%	    50%
--인사부	    60	    4	      M	    4	    6.7%	6.7%	    100%
--자재부	    60	    6	      F	    4	    10%	    6.7%	    66.7%
--자재부	    60	    6	      M	    2	    10%	    3.3%	    33.3%
--총무부	    60	    7	      F	    3	    11.7%	5%	        42.9%
--총무부	    60	    7	      M 	4	    11.7%	6.7%	    57.1%
--홍보부	    60	    6	      F	    3	    10%	    5%	        50%

WITH i AS(
    SELECT buseo
        ,(SELECT COUNT(*) FROM insa)총사원수
         , DECODE( MOD( SUBSTR(ssn,-7,1), 2 ), 1 , 'M','F' ) 성별
        ,(SELECT COUNT(*) FROM insa WHERE i.buseo = buseo) 부서사원수
        , COUNT(DECODE( MOD( SUBSTR(ssn,-7,1), 2 ), 1 , 'M','F' ))성별사원수
    FROM insa i
    GROUP BY buseo, MOD( SUBSTR(ssn,-7,1), 2 )
    ORDER BY buseo, MOD( SUBSTR(ssn,-7,1), 2 )
)
SELECT i.*, ROUND(부서사원수/총사원수 * 100,1 )"부/전비율"
        , (성별사원수/총사원수*100)"부성/전%"
             , (성별사원수/부서사원수*100)"성/부%"
FROM i;

-- [문제] 
-- [실행결과]
-- 부서번호  그 해당 부서에 속한 사원들
-- 10       CLARK/MILLER/KING
-- 20       CLARK/MILLER/KING
-- 30       CLARK/MILLER/KING

-- deptno   null -> 부서없음
--          40      사원없음

SELECT deptno, LISTAGG(ename,'/') WITHIN GROUP(ORDER BY ename ASC) enameList
FROM emp
GROUP BY deptno;

-- [문제] insa 테이블에서 급여 많이 받는 5명만 출력
-- [1] 풀이  TOP-N 분석 방법


SELECT  TO_CHAR( dates, 'D')
        ,TO_CHAR( dates, 'W' ) + 1 "?"
        ,TO_CHAR( dates, 'DD')
--       NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 1, TO_CHAR( dates, 'DD')) ), ' ')  일
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 2, TO_CHAR( dates, 'DD')) ), ' ')  월
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 3, TO_CHAR( dates, 'DD')) ), ' ')  화
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 4, TO_CHAR( dates, 'DD')) ), ' ')  수
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 5, TO_CHAR( dates, 'DD')) ), ' ')  목
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 6, TO_CHAR( dates, 'DD')) ), ' ')  금
--     , NVL( MIN( DECODE( TO_CHAR( dates, 'D'), 7, TO_CHAR( dates, 'DD')) ), ' ')  토
FROM (
        SELECT TO_DATE(:yyyymm , 'YYYYMM') + LEVEL - 1  dates
        FROM dual
        CONNECT BY LEVEL <= EXTRACT ( DAY FROM LAST_DAY(TO_DATE(:yyyymm , 'YYYYMM') ) )
)  t 


-- [문제]emp 테이블에서 
-- 사원수가 가장 많은 부서명(dname), 사원수
-- 사원수가 가장 적은 부서명, 사원수 출력