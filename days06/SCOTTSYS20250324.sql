-- SCOTT --

--[ 문제 1 ] table JOIN 하기
-- 풀이 [1] 
SELECT empno, ename, hiredate, dname
FROM emp e, dept d
WHERE e.deptno = d.deptno -- JOIN 조건

-- 풀이 [2] JOIN ~ ON 구문 사용
SELECT empno, ename, hiredate, dname
FROM emp e INNER JOIN dept d ON e.deptno = d.deptno -- ((INNER) JOIN : inner 생략
ORDER BY dname;

-- [ 문제 2 ] emp 테이블에서 job의 개수 조회
SELECT COUNT(DISTINCT job)
FROM emp;
-- 
SELECT COUNT(*)
FROM (
        SELECT DISTINCT job
        FROM emp
     );
     
-- [ 문제 2-2 ] emp 테이블의 각 부서별 사원수 조회
SELECT COUNT(*) -- 전체 사원 수 12명
FROM emp;
-- 전체 부서 정보 조회
SELECT *
FROM dept;
-- 풀이 (1) SET 연산자 사용
SELECT 10, COUNT(*) FROM emp WHERE deptno = 10
UNION ALL
SELECT 20, COUNT(*) FROM emp WHERE deptno = 20
UNION ALL
SELECT 30, COUNT(*) FROM emp WHERE deptno = 30
UNION ALL
SELECT 40, COUNT(*) FROM emp WHERE deptno = 40
UNION ALL
SELECT null, COUNT(*)FROM emp;

-- 풀이 (2) 상관 서브쿼리
SELECT DISTINCT deptno
        , ( SELECT COUNT(*) FROM emp WHERE deptno = e.deptno )사원수
FROM emp e
ORDER BY deptno ASC;

--[ 추가 ]  + 사원이 존재하지 않는 부서까지 출력 (40, 0)
SELECT deptno
        , ( SELECT COUNT(*) FROM emp WHERE deptno = d.deptno )사원수
FROM dept d;

-- 풀이 (3) GROUP BY 사용
-- 1 WITH
-- 6 SELECT
-- 2 FROM 
-- 3 WHERE
-- 4 GROUP BY
-- 5 HAVING
-- 7 ORDER BY

SELECT deptno, COUNT(*)
FROM emp
GROUP BY deptno -- GROUP 별로 모아놓고 집계함. 
ORDER BY deptno;

-- [ 추가 ] 40번 부서 0명까지 추가 
-- 1) UNION ALL
SELECT deptno, COUNT(*)
FROM emp
GROUP BY deptno
UNION ALL
SELECT 40, COUNT(*) FROM emp WHERE deptno = 40
ORDER BY deptno; -- ORDER BY 절 제일 끝에 

-- 2) SELECT deptno, COUNT(*)
SELECT DISTINCT deptno
             ,(SELECT COUNT(*) FROM emp WHERE emp.deptno = d.deptno)
FROM dept d
ORDER BY deptno;

--(4) dept 부서 테이블 10-40
--    emp 사원 테이블 10-30    40X

--SELECT d.deptno, COUNT(*) -- COUNT(*) -> null 포함 (40번 부서도 1 출력)
SELECT d.deptno, dname, COUNT(ename) -- COUNT(칼럼) -> null 제외
FROM emp e, dept d
WHERE e.deptno(+) = d.deptno -- 한쪽이 모두 출력되게(+) -> OUTER JOIN
GROUP BY d.deptno, dname
ORDER BY d.deptno ASC;

-- COUNT() 함수
SELECT count(comm) -- 4
FROM emp;

SELECT count(*) -- 12
FROM emp;

--SELECT deptno, count(comm) -- ORA-00937: not a single-group group function
--FROM emp;
-- 그러나 "GROUP BY 절에 있는 칼럼은 집계함수에 같이 쓸 수 있음"
SELECT d.deptno, dname, COUNT(ename) -- COUNT(칼럼) -> null 제외
FROM emp e, dept d
WHERE e.deptno(+) = d.deptno -- 한쪽이 모두 출력되게(+) -> OUTER JOIN
GROUP BY d.deptno, d.dname
ORDER BY d.deptno ASC;

-- 위의 JOIN 쿼리를 JOIN~ON 구문으로 수정
SELECT d.deptno, dname, COUNT(ename) 
--FROM emp e JOIN dept d ON e.deptno(+) = d.deptno -- 잘못된 구문
--FROM emp e RIGHT [OUTER] JOIN dept d ON e.deptno = d.deptno -- OUTER JOIN 할 테이블 있는 방향 적기
FROM dept d LEFT OUTER JOIN emp e ON e.deptno = d.deptno -- LEFT [OUTER] JOIN
GROUP BY d.deptno, d.dname
ORDER BY d.deptno ASC;

------------------------------------------------------------------

SELECT 
    (SELECT COUNT(*) FROM emp WHERE deptno = 10) deptno_10
    ,(SELECT COUNT(*) FROM emp WHERE deptno = 20) deptno_20
    ,(SELECT COUNT(*) FROM emp WHERE deptno = 30) deptno_30
    ,(SELECT COUNT(*) FROM emp WHERE deptno = 40) deptno_40
    ,(SELECT COUNT(*) FROM emp)
FROM dual;

-- DECODE() 함수 사용 (기억)
-- 1) if 문 대신에 사용할 함수 -> SQL, PL/SQL 사용
-- 2) SELECT 사용 시 FROM 절 제외하고 어디든지 사용가능
-- 3) 단점 : 비교 연산은 '='만 가능하다. -> CASE 함수

-- 자바의 경우
if(조건식){
     /명령코딩;
}

if(A=B){
    return C;
}
==> DECODE(A,B,C);

if(A=B) {
    return C;
}else{
    return D;
}
==> DECODE(A,B,C,D)

if ( A = B ) {
    return ㄱ;
}else if(A=C){
    return ㄴ;
} else if (A=D){
    return ㄷ;
} else{
    return ㄹ;
}
==> DECODE(A, B, ㄱ, C, ㄴ, D, ㄷ, ㄹ);

-- [ 문제 ]  insa 테이블에서 이름, 주민번호, 성별('남자','여자') 출력
SELECT name, ssn
  , NVL2( NULLIF( MOD( SUBSTR(ssn, -7, 1) , 2 ) , 1 ), 'O', 'X') gender
  , REPLACE(REPLACE(MOD(SUBSTR(ssn, 8, 1) , 2 ), 1, 'X'), 0, 'O') gender
  , DECODE(  MOD( SUBSTR(ssn, -7, 1) , 2 ), 1 , '남자', '여자' ) gender
  , DECODE(  MOD( SUBSTR(ssn, -7, 1) , 2 ), 1 , '남자', 0, '여자' ) gender
-- CASE 함수 추가 (CASE - END 구문 전체 먼저 적기)
                , CASE SUBSTR(ssn,-7,1) WHEN '1' THEN '남자'
                                        ELSE          '여자'
                  END gender
FROm insa;

-- [ 문제 ] DECODE() 함수 사용
-- emp 테이블의 각 부서의 사원 수 조회 (암기)
SELECT COUNT(*)
    , COUNT ( DECODE(deptno, 10, 'o')) "10" -- 세번째 자리 null이 아닌 고정값만 주면 상관없음
    , COUNT ( DECODE(deptno, 20, empno)) "20"
    , COUNT ( DECODE(deptno, 30, empno)) "30"
    , COUNT ( DECODE(deptno, 40, empno)) "40"
FROM emp;

-- 위의 쿼리 설명
SELECT COUNT(comm) -- null 제외
FROM emp;

SELECT DECODE( deptno, 10, 'O') -- 10번부서원 아닌경우 null 들어감. = else 값 안주면 null 로 들어감.
FROM emp;

-- 구조 보기
SELECT 
     DECODE(deptno, 10, 'o') "10" 
    , DECODE(deptno, 20, empno) "20"
    , DECODE(deptno, 30, empno) "30"
    , DECODE(deptno, 40, empno) "40"
FROM emp;

-- [ 문제 ] emp 테이블에서 pay 모두 10% 인상하는 쿼리
SELECT empno, ename, sal, comm
        , sal+NVL(comm, 0) pay
        , (sal+NVL(comm, 0))* 1.1 "10%인상된pay"
FROM emp;

-- [ 문제 ] emp 테이블에서 10번 부서 pay 15% 인상, 20번 pay 10% 인상,
--          그 외 부서는 20% 인상
--          (DECODE() 함수를 사용)

SELECT empno, ename, sal, comm, deptno
        , sal+NVL(comm, 0) pay,
        DECODE(deptno, 10, (sal+NVL(comm, 0))*1.15
                     , 20, (sal+NVL(comm, 0))*1.1
                     , (sal+NVL(comm, 0))*1.2)인상된pay
        , (sal+NVL(comm, 0)) * DECODE(deptno, 10, 1.15
                                            , 20,1.1
                                                , 1.2 ) 인상된pay

        , (sal+NVL(comm, 0)) * DECODE(deptno, 10, 1.15, 20,1.1, 1.2 ) 인상된pay
--        , CASE 컬럼명 | 수식 WHEN THEN
--                            WHEN THEN
--                            WHEN THEN
--                            :
--                            ELSE
--          END 별칭
        , (sal+NVL(comm, 0))*CASE deptno WHEN 10 THEN 1.15
                                         WHEN 20 THEN 1.1
                                         ELSE         1.2
          END 별칭
FROM emp
ORDER BY deptno;

---------------------------------------------------------------------
-- (분석, 이해, 암기)
SELECT count(case when to_char(hiredate,'MM') ='01' then count(*) end) as jan,
       count(case when to_char(hiredate,'MM') ='02' then count(*) end) as feb,
       count(case when to_char(hiredate,'MM') ='03' then count(*) end) as Mar,
       count(case when to_char(hiredate,'MM') ='04' then count(*) end) as Apr,
       count(case when to_char(hiredate,'MM') ='05' then count(*) end) as May,
       count(case when to_char(hiredate,'MM') ='06' then count(*) end) as Jun,
       count(*) Total
FROM emp
GROUP BY hiredate;

-----------------------------------
-- [날짜 함수]
--ROUND(date)
SELECT SYSDATE -- 함수다.
        , ROUND(SYSDATE)
        , ROUND(SYSDATE, 'DD')  -- [정오 전] 25/03/24 (정오 기준)
        , ROUND(SYSDATE, 'MM')   -- [24일] 25/04/01   (15일 기준)
        , ROUND(SYSDATE, 'YEAR') -- [3월] 25/01/01    (6월 기준)
FROm dual;
--------------------------------------
SELECT SYSDATE now
        , TO_CHAR( SYSDATE, 'DS TS')
        , TRUNC( SYSDATE) -- 시간, 분, 초 절삭
        , TO_CHAR ( TRUNC ( SYSDATE), 'DS TS') -- 2025/03/24 오전 12:00:00
        , TRUNC ( SYSDATE, 'MM')
        , TO_CHAR ( TRUNC ( SYSDATE, 'MM'), 'DS TS')
        , TRUNC ( SYSDATE, 'YEAR')
        , TO_CHAR ( TRUNC ( SYSDATE, 'YEAR'), 'DS TS')
FROM dual;

ROUND(숫자 또는 날짜)
TRUNC(숫자 또는 날짜)
-----------------------------------------
SELECT SYSDATE
        , SYSDATE + 7
        , SYSDATE - 7
        , SYSDATE + 1/24 -- 1시간 더하기
        , SYSDATE - 6/24
FROM dual;
-- 
SELECT ename, hiredate
        , CEIL(SYSDATE - hiredate) + 1 근무일수
FROm emp;

-- [ 문제 ] 개강일로부터 오늘까지 며칠이 지났는지 25/02/03
-- '25.02.03' 날짜인지 확인
--SELECT '25.02.03' -1
--FROM dual;

-- '25/02/03' 문자열 -> 날짜 변환 : TO_DATE
SELECT CEIL(SYSDATE- TO_DATE('25.02.03'))+1
FROm dual;

---------------------------------------------------
-- emp 사원테이블의 근무일수, 근무개월수, 근무년수 조회
SELECT ename, hiredate, SYSDATE
        ,CEIL(SYSDATE - hiredate) + 1 근무일수
        -- 소수점 3번째 자리에서 반올림
        , ROUND(MONTHS_BETWEEN(SYSDATE, hiredate),2) 근무개월수 -- MONTHS_BETWEEN
        , MONTHS_BETWEEN(SYSDATE, hiredate)/12 근무년수
FROM emp;
---------------------------------------------------
-- [ 문제 ] 설문조사 
--                  시작일  25.3.20 9시부터
--                  종료일  25.3.24 낮 12시까지
--                  지금은 설문이 가능한지 여부를 조회 25.3.24 오후 12:25

SELECT SYSDATE
--        TO_CHAR ( SYSDATE,  'DS TS')
        , TO_DATE( '25.3.20 9', 'YY.MM.DD HH')
--        , TO_CHAR ( TO_DATE( '25.3.20 9', 'YY.MM.DD HH'),  'DS TS')
        , TO_DATE( '25.3.24 12', 'YY.MM.DD HH')
        , CASE WHEN SYSDATE BETWEEN TO_DATE( '25.3.20 9', 'YY.MM.DD HH') AND TO_DATE( '25.3.24 12', 'YY.MM.DD HH') THEN '설문 가능'
                ELSE '설문 불가능'
        END 설문조사가능여부
FROM dual;

-----------------------------------------
SELECT SYSDATE
        , SYSDATE + 3 -- 3일 후
        , SYSDATE - 3 -- 3일 전
        , ADD_MONTHS(SYSDATE,1) -- 한달 후
        , ADD_MONTHS(SYSDATE, -1) -- 한달 전
        , ADD_MONTHS(SYSDATE, 12) -- 1년 후
        , ADD_MONTHS(SYSDATE, -12) -- 1년 전
FROM dual;
-----------------------------------------
SELECT SYSDATE
        , LAST_DAY(SYSDATE)
        , TO_CHAR(LAST_DAY(SYSDATE),'DD')
        , TO_DATE('25/04/01')-1
        , TO_cHAR(TO_DATE('25/04/01')-1, 'DD')
FROM dual;
-----------------------------------------
SELECT SYSDATE
        ,TO_cHAR(SYSDATE, 'DY') --'월'
        ,TO_cHAR(SYSDATE, 'DAY') --'월요일'
        ,NEXT_DAY(SYSDATE, '금')
        , NEXT_DAY( SYSDATE, '월')
FROM dual;

--------------------------------------------------------------------------------
SELECT CURRENT_DATE, CURRENT_TIMESTAMP
FROM dual;
--------------------------------------------------------------------------------

---- [문제] 5월 첫 번째 월요일 휴강
SELECT NEXT_DAY(LAST_DAY(ADD_MONTHS(SYSDATE,1)),'월')
FROM dual;

-- [ 문제 ] 5월 첫 번째 목요일날 휴강
--       4월의 마지막 날짜에서  가까운 목
SELECT 
    TO_DATE('25', 'YY')  --년도 -> 날짜 변환 25/03/01
--      TO_DATE('25/05', 'YY/MM')  --   25/05/01
--      , NEXT_DAY( TO_DATE('25/05', 'YY/MM'), '목')
--      LAST_DAY( ADD_MONTHS( TO_DATE('25/05', 'YY/MM'), -1) )
    ,NEXT_DAY(  TO_DATE('25/05', 'YY/MM') - 1, '목')
FROM dual;

--
SELECT NEXT_DAY(LAST_DAY(ADD_MONTHS(SYSDATE,1)),'목')
,  NEXT_DAY ( LAST_DAY ( TO_DATE ( '25/04/01' ) ) ,   '목'  )
FROM dual;

------------------------------------------
SELECT 1234
        ,'1234'
        , TO_NUMBER('1234')
FROM dual;

-- 숫자, 문자, 날짜 -> TO_CHAR() 문자 변환하는 함수
SELECT num, name
        , basicpay, sudang
        , basicpay + sudang pay
        , To_CHAR(basicpay + sudang, 'L9G999G999D00')
FROM insa;


SELECT 100
    , TO_cHAR(100, 'S9999')
    , TO_cHAR(-100, 'S9999')
    
    , TO_cHAR(100, '9999MI')
    , TO_cHAR(-100, '9999MI')
    
    , TO_cHAR(100, '9999PR')
    , TO_cHAR(-100, '9999PR') -- <100>
FROM dual;

SELECT ename ,( sal+NVL(comm,0))*12 연봉
        , TO_CHAR(( sal+NVL(comm,0))*12, 'L9,999,999.00') -- 출력서식보다 더 크면 #
        , TO_CHAR(( sal+NVL(comm,0))*12, 'L9G999G999D00')
FROM emp;

--------------------------------------------------------------------------------
-- [문제]           Date 날짜 -> 내가 원하는 문자열 변환해서 출력. TO_CHAR()
-- [문제] insa테이블에서 입사일자를 '1998년 10월 11일 일요일' 형식으로 출력.
SELECT name, ibsadate
        ,TO_CHAR (ibsadate, 'DL')
        ,TO_CHAR(ibsadate, 'YYYY"년" MM"월" DD"일" DAY')
FROM insa;
----------------------------------------
SELECT ename
        , sal + NVL(comm,0) pay
        , sal + NVL2(comm,comm,0) pay
        -- 나열해놓은 값을 순차적으로 체크하여 Null이 아닌값을 리턴하는 함수
        , COALESCE(sal+comm, sal, 0)
FROM emp;
----------------------------------------
-- * NULL 칼럼값도 포함
--칼럼명 null 포함 X
SELECT COUNT(*), COUNT(ename), COUNT(comm)
        , SUM(comm)
        , AVG (comm) -- 550 / 총합 4 -- null 제외 -> 모든 집계합수는 null을 제외시킨다. 
        , SUM(comm)/COUNT(comm) -- 550
        ,SUM(sal)
        ,SUM(sal)/COUNT(*) 
        ,AVG(sal)
--     , SUM( comm ) / COUNT(*)     -- 주의
--     , SUM( comm ) / COUNT(comm)  -- 주의
FROM emp;

SELECT MAX(sal), MIN(sal)
FROM emp;

2명 국어시험(18명) 2명 응시x
------------------------------------------
-- GROUP BY 절 + HAVING 절 + 추가적 설명
-- [문제] insa 테이블에서 총사원수, 남자사원수, 여자사원수를 조회
-- 1) UNION ALL
SELECT '전체'"분류", COUNT(*)총사원수
FROM insa
UNION ALL
SELECT '남자',COUNT(*)
FROM insa
WHERE MOD(SUBSTR(ssn,-7,1),2) = 1
UNION ALL
SELECT '여자' ,COUNT(*)
FROM insa
WHERE MOD(SUBSTR(ssn,-7,1),2) = 0;

-- 2) 
SELECT ( SELECT COUNT(*) "여자" FROM insa WHERE SUBSTR(ssn, -7, 1) = 1) "여자 사원수" , ( SELECT COUNT(*) "남자" FROM insa WHERE SUBSTR(ssn, -7, 1) = 2) "남자 사원수" 
            ,  ( SELECT COUNT(*) FROM insa)
FROM dual;

SELECT 
  ( SELECT COUNT(*) "여자" FROM insa WHERE SUBSTR(ssn, -7, 1) = 1) "여자 사원수" 
  , ( SELECT COUNT(*) "남자" FROM insa WHERE SUBSTR(ssn, -7, 1) = 2) "남자 사원수" 
  , ( SELECT COUNT(*)  FROM insa)
FROM dual;

--COUNT(), DECODE()
SELECT COUNT(*)"총 사원수"
        ,COUNT( DECODE(MOD(SUBSTR(ssn, -7, 1),2 ),1,'O'))"남자 사원수"
        ,   COUNT( DECODE(MOD( SUBSTR(ssn, -7,1), 2 ),0,'X') ) "여자 사원수"
FROM insa;

-- CASE()
SELECT COUNT(*)총사원수
        ,COUNT( CASE MOD(SUBSTR(ssn, -7, 1),2) WHEN 1 THEN 'O' END) 남자사원수
        ,COUNT( CASE MOD(SUBSTR(ssn, -7, 1),2) WHEN 0 THEN 'O' END) 여자사원수
FROM insa;


-- (3) GROUP BY 절
SELECT MOD(SUBSTR(ssn, -7, 1),2)
    ,COUNT(*)
FROM insa
GROUP BY MOD(SUBSTR(ssn, -7, 1),2);
-- 
SELECT 
    CASE MOD(SUBSTR(ssn, -7, 1),2) 
    WHEN 1 THEN '남자사원수'
    ELSE '여자사원수'
    END gender
    ,COUNT(*)
FROM insa
GROUP BY MOD(SUBSTR(ssn, -7, 1),2)
UNION ALL
SELECT null,COUNT(*)
FROM insa;
-- 
SELECT 
    CASE MOD(SUBSTR(ssn, -7, 1),2) 
    WHEN 1 THEN '남자사원수'
    WHEN 0 THEN '여자사원수'
    ELSE '전체사원수'
    END gender
    ,COUNT(*)
FROM insa
GROUP BY ROLLUP (MOD(SUBSTR(ssn, -7, 1),2));
-- 예제) 
SELECT deptno, job, sal
FROM emp
ORDER BY deptno ASC;
-- 
SELECT deptno, SUM(sal) -- 집계함수를 제외한, 나머지 칼럼은 group by절에 있어야함. 
FROM emp
GROUP BY deptno
ORDER BY deptno ASC;
-- 
SELECT deptno,job,  sum(sal)
FROM emp
GROUP BY deptno, job -- 1차 그룹화 / 2차 그룹화
ORDER BY deptno ASC;
--
SELECT deptno,job, sum(sal)
FROM emp
--OUP BY ROLLUP(deptno, job)
GROUP BY CUBE(deptno, job)
ORDER BY deptno ASC;


-- [ 문제 ] 각 부서별 최고 급여 사원 정보 조회
-- [ 문제 ] 각 부서별 최고 급여액 정보 조회
SELECT deptno
            ,MAX(sal+NVL(comm,0)) maxpay
            ,MIN(sal+NVL(comm,0)) minpay
            , SUM(sal+NVL(comm,0)) sumpay
            , AVG(sal+NVL(comm,0))avgpay
FROM emp
GROUP BY deptno
ORDER BY deptno ASC;

-- [문제] emp테이블에서 가장 급여(pay)를 많이 받는 사원의 정보를 조회
SELECT MAX( sal + NVL(comm,0) ) maxpay
FROM emp;
--
SELECT *
FROM emp
--WHERE sal + NVL(comm,0) = 5000;
WHERE sal + NVL(comm,0) = (SELECT MAX( sal + NVL(comm,0) ) maxpay
                                    FROM emp
                                    );

-- SQL 연산자
SELECT *
FROM emp
--WHERE sal + NVL(comm,0) = 5000;
WHERE sal + NVL(comm,0) <= ALL(
                                    SELECT sal + NVL(comm,0) pay
                                    FROM emp
                               ); -- 최소 급여
WHERE sal + NVL(comm,0) >= ALL(
                                    SELECT sal + NVL(comm,0) pay
                                    FROM emp
                               ); -- 최대 급여
                               
-- EXIST
select ename,job,sal 
from emp p
where EXISTS (
            select 'x' 
            from dept 
            where deptno=p.deptno
            );
            
select ename,job,sal 
from emp p
where deptno IN (
                select deptno 
                from dept
                where deptno=p.deptno
                );

-- KING 10 -> null
UPDATE emp 
SET deptno = null
WHERE empno = 7839;
-- 
SELECT *
FROm emp;
-- 
commit;
-- 전체 순위, 부서 안에서의 순위
SELECT deptno, empno, ename, sal + NVL(comm,0)pay
        , ( SELECT COUNT(*)+1 FROM emp WHERE sal + NVL(comm,0) > e.sal + NVL(e.comm,0)) payrank
        , ( SELECT COUNT(*)+1 
            FROM emp 
            WHERE sal + NVL(comm,0) > e.sal + NVL(e.comm,0) AND deptno = e.deptno
            )dept_payrank
FROM emp e
ORDER BY deptno, dept_payrank;

-- 각 부서별 최고급여자 조회
SELECT *
FROM (
SELECT deptno, empno, ename, sal + NVL(comm,0)pay
        , ( SELECT COUNT(*)+1 FROM emp WHERE sal + NVL(comm,0) > e.sal + NVL(e.comm,0)) payrank
        , ( SELECT COUNT(*)+1 
            FROM emp 
            WHERE sal + NVL(comm,0) > e.sal + NVL(e.comm,0) AND deptno = e.deptno
            )dept_payrank
FROM emp e
ORDER BY deptno, dept_payrank
)
WHERE dept_payrank <= 2;
WHERE dept_payrank = 1;

-- [ 문제 ]insa 테이블에서 부서별 사원수가 10명 이상인 부서 조회.
-- 1)
SELECT *
FROM (
        SELECT buseo, COUNT(*) 사원수
        FROM insa
        GROUP BY buseo
        ) i
WHERE i.사원수 >= 10;
-- 2) 
 SELECT buseo, COUNT(*) 사원수
        FROM insa
        GROUP BY buseo          -- 집계를 하겠다는 뜻
        HAVING COUNT(*) >= 10;  -- GROUP BY의 조건절, Group by 절이 있어야 사용 가능
        
-- [문제] insa 테이블에서 여자 사원수가 5명 이상인 부서명, 사원명 조회

SELECT buseo, name
FROM insa
WHERE buseo IN (
                SELECT buseo
                FROM insa 
                WHERE MOD(SUBSTR(ssn,-7, 1), 2) = 0
                GROUP BY buseo
                HAVING COUNT(*) >= 5
                )
ORDER BY buseo, name;