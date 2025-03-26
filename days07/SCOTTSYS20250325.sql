-- SCOTT --
-- [문제 ] insa 테이블에서 여자사원수가 5명 이상인 부서명, 사원 수 조회
SELECT buseo, count(*)
FROM insa
GROUP BY buseo;
-- (1)
SELECT buseo, COUNT(DECODE(MOD(SUBSTR(ssn, -7 ,1), 2) , 0, '여자') )여자사원수 -- else 값X -> 남자는 null
            , COUNT(DECODE(MOD(SUBSTR(ssn, -7 ,1), 2) , 1, '남자') )남자사원수
FROM insa
GROUP BY buseo
HAVING COUNT (DECODE(MOD(SUBSTR(ssn, -7 ,1), 2) , 0, '여자')) >= 5;

-- (2) WHERE 조건절과 HAVING 조건절에 대한 이해 
SELECT buseo, COUNT(*)
FROM insa
WHERE MOD(SUBSTR(ssn, -7 ,1), 2) = 0
GROUP BY buseo
HAVING COUNT(*) >= 5 
ORDER BY buseo;

-- [ 문제 ] emp 테이블에서 사원 전체 평균 급여보다 사원의 급여(pay)가 많으면 "많다", "적다" 출력
SELECT AVG(sal+NVL(comm,0)) avg_pay
FROM emp;
--(1) UNION/UNION ALL SET연산자(합집합)
SELECT e.*, '많다'평가
fROM emp e
WHERE sal+NVL(comm,0) > (SELECT AVG(sal+NVL(comm,0)) avg_pay FROM emp)
UNION
SELECT e.*, '적다'
fROM emp e
WHERE sal+NVL(comm,0) < (SELECT AVG(sal+NVL(comm,0)) avg_pay FROM emp);

--(2) CASE 함수
SELECT e.ename, e.pay, e.avg_pay
        , CASE
              WHEN e.pay > e.avg_pay THEN '많다'
              ELSE                         '적다'
            END 평가
FROM( 
    SELECT emp.*
        , sal + NVL(comm,0)pay
        , (SELECT AVG(sal+NVL(comm,0)) FROM emp ) avg_pay
    FROm emp
        )e ;

-- 내 풀이
SELECT  CASE 
            WHEN sal+NVL(comm,0) >= (SELECT AVG(sal+NVL(comm,0))FROM emp) THEN '많다'
            WHEN sal+NVL(comm,0) = (SELECT AVG(sal+NVL(comm,0))FROM emp) THEN  '같다'
            ELSE                                                               '적다'
        END 급여
FROM emp;

--(3) 
SELECT e.ename, e.pay, e.avg_pay
        , NVL2( NULLIF(SIGN(e.pay - avg_pay), 1) , '적다' , '많다') 평가
FROM( 
    SELECT emp.*
        , sal + NVL(comm,0)pay
        , (SELECT AVG(sal+NVL(comm,0)) FROM emp ) avg_pay
    FROm emp
        )e ;

-- [ 문제 ] emp 테이블에서 급여 MAX, MIN 사원의 정보 ( 부서명, 이름, 잡, 입사일자, pay)조회
SELECT d.dname, e.ename, e.job, e.hiredate, e.sal+NVL(e.comm,0)pay
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
WHERE e.sal+NVL(e.comm,0) IN( (SELECT MAX(e.sal+NVL(e.comm,0)) FROM emp) 
                             ,(SELECT MIN(e.sal+NVL(e.comm,0)) FROM emp));
-- (1)
SELECT dname, ename, job, hiredate, sal+NVL(comm,0)pay
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
WHERE sal+NVL(comm,0) IN( (SELECT MAX(sal+NVL(comm,0)) FROM emp) 
                         ,(SELECT MIN(sal+NVL(comm,0)) FROM emp));
                         
WITH temp AS
(
(SELECT MAX(sal+NVL(comm,0)) FROM emp)
UNION
(SELECT MIN(sal+NVL(comm,0)) FROM emp)
)
--, XX AS (
--temp -- 사용가능
--)
SELECT dname, ename, job, hiredate, sal+NVL(comm,0)pay
        , CASE sal+NVL(comm,0)
                WHEN 5000 THEN 'MAX_PAY'
                ELSE 'MIN_PAY'
        
          END 평가
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
WHERE sal+NVL(comm,0) IN ( SELECT * FROM temp);

-- [문제] insa 테이블에서 
-- 서울 출신 사원 중에 부서별 남자, 여자 사원 수 출력
--                         남자급여총합, 여자 급여 총합 조회(출력)
-- [출력형식]
--BUSEO   남자인원수   여자인원수   남자급여합   여자급여합
--개발부      0      2          (null)       1,790,000
--기획부      2      1          5,060,000    1,900,000
--:

DESC insa;

-- 풀이[1] GROUP BY 절X
WITH temp AS 
(
    SELECT *
    FROM insa 
    WHERE city = '서울'
)
SELECT DISTINCT buseo
        , (SELECT COUNT(*) FROM temp WHERE buseo = t.buseo )부서별서울출신사원수
        , (SELECT COUNT(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 1, '남')) FROM temp WHERE buseo = t.buseo)남사원수
        , (SELECT COUNT(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 0, '여')) FROM temp WHERE buseo = t.buseo)여사원수
        , (SELECT SUM(basicpay) FROM temp WHERE buseo = t.buseo )부서별총급여합
        , (SELECT SUM(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 1, basicpay)) FROM temp WHERE buseo = t.buseo)남급여합
        , (SELECT SUM(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 0, basicpay)) FROM temp WHERE buseo = t.buseo)여급여함
FROM temp t
ORDER BY buseo ;

--WITH temp AS (
--    SELECT name, buseo, city,  MOD( SUBSTR( ssn, -7,1) ,2 ) gender
--    FROM insa
--    WHERE city = '서울'
--)
--SELECT buseo, ( SELECT COUNT(name) FROM temp WHERE gender =1 AND  )남자인원수
--            , ( SELECT COUNT(name) FROM temp WHERE gender =0 GROUP BY buseo )여자인원수
--FROM temp t
--GROUP BY buseo

-- [2] GROUP BY 절 사용
SELECT buseo
        , COUNT(*) 총사원수
        , COUNT(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 1, '남')) 남사원수
        , COUNT(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 0, '여')) 여사원수
        , SUM(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 1, basicpay)) 남사원수
        , SUM(DECODE (MOD(SUBSTR(ssn , -7, 1),2), 0, basicpay)) 여사원수
FROm insa
WHERE city = '서울'
GROUP BY buseo
ORDER BY buseo ASC;

-- [3] 2차 그룹핑
SELECT buseo
--        , DECODE( MOD(SUBSTR(ssn , -7, 1),2),1, '남자', '여자')성별
        , CASE  MOD(SUBSTR(ssn , -7, 1),2)
            WHEN 1 THEN '남자'
            WHEN 0 THEN '여자'
         END 성별
        , COUNT(*)사원수
        , TO_CHAR(sum(basicpay), 'L999G999,999')급여합
FROM insa
WHERE city = '서울'
--GROUP BY ROLLUP(buseo, MOD(SUBSTR(ssn , -7, 1),2))
GROUP BY CUBE(buseo, MOD(SUBSTR(ssn , -7, 1),2))
ORDER BY buseo, MOD(SUBSTR(ssn , -7, 1),2);

-- [ 문제 ] emp 테이블에서 급여(sal) TOP -3 조회
-- [1] 
SELECT *
FROM (SELECT e.*, ( SELECT COUNT(*)+1 FROm emp WHERE sal > e.sal )sal_rank
FROM emp e
ORDER BY sal_rank ASC
)t
WHERE sal_rank BETWEEN 3 AND 5;
WHERE sal_rank <= 3;

-- [2] 풀이 ROWNUM: < , >= 만 사용 (= 제일 위아래 가능, 중간 것 X) -- 서브쿼리로 한번 더 감싸면 가능
--[2]-1 TOP_N
SELECT e.*, ROWNUM
FROM (
        SELECT *
        FROM emp
        ORDER BY sal DESC
    ) e
WHERE ROWNUM BETWEEN 3 AND 5; -- 오류
WHERE ROWNUM < 5;  -- O
WHERE ROWNUM > 10; -- X
WHERE ROWNUM <= 5; -- O

--[2]- 2
SELECT *
FROM  (
    SELECT e.*, ROWNUM seq
    FROM (
        SELECT *
        FROM emp
        ORDER BY sal DESC
    ) e
    ) t
    WHERE seq BETWEEN 3 AND 5;

-- ROLLUP : 그룹화하고 그룹에 대한 부분합
SELECT dname, job, COUNT(*)
FROM emp e, dept d
WHERE e.deptno = d.deptno(+) -- OUTER 조인조건
--GROUP BY ROLLUP(dname, job)
GROUP BY CUBE(dname, job)
ORDER BY dname;
-- 11개 행만 보이는 이유는? King 부서번호 null. 제외

-- [ 순위(rank) 함수 ] - 칼럼기준 정렬 필수 --> 반드시 OVER( ORDER BY 절 ) 
-- RANK 함수
SELECT ename, sal, comm, sal+NVL(comm,0) pay
    -- 중복 순위 계산함 9/9 11
    , RANK() OVER ( ORDER BY sal DESC ) "RANK 급여순위"
    -- 중복 순위 계산 안함 9/9 10
    , DENSE_RANK() OVER(ORDER BY sal DESC) "DENSE_RANK 급여순위"
    -- sal 1250 9/9 9/10
    , ROW_NUMBER() OVER(ORDER BY sal DESC) "DENSE_RANK 급여순위"
FROM emp;

-- sal 수정
SELECT sal
FROM emp
WHERE ename LIKE '%JONES%';

UPDATE emp
SET sal = 2850
WHERE empno = 7566;
commit;

-- [ 문제 ] emp테이블에서 부서별 급여 순위 매겨서 출력(조회)
-- [1] rank 쓰지 않고
SELECT deptno, ename, sal
        , ( SELECT COUNT(*) + 1 FROM emp WHERE e.sal < sal AND e.deptno = deptno)부서별급여순위
FROM emp e
ORDER BY deptno, 부서별급여순위;

-- [2] RANK 함수 사용
-- 각 부서별 최고 급여액을 받는 사원의 정보 출력
SELECT *
FROM (
    SELECT deptno, ename, sal
        , RANK() OVER(PARTITION BY deptno ORDER BY sal) 부서별rank
    FROM emp e
    ORDER BY deptno, 부서별rank
    )
WHERE 부서별rank = 1;
WHERE 부서별rank <= 2;

-- [문제] insa 테이블에서 여자 사원수가 가장 많은 부서명, 여자사원수 출력
-- [1] rank() 안쓰고 TOP_N 분석방법
WITH temp AS (
    SELECT buseo, COUNT(*)여자사원수
    FROM insa 
    WHERE MOD(SUBSTR(ssn, -7,1), 2) = 0
    GROUP BY buseo
    ORDER BY 여자사원수 DESC
)
SELECT buseo, 여자사원수
FROM temp
WHERE 여자사원수 = (SELECT MAX(여자사원수) FROM temp);


-- [2] rank() 쓰고
SELECT *, "여자사원수"
FROM(
SELECT buseo, COUNT(*)여자사원수
        , RANK() OVER( ORDER BY COUNT(*) DESC )sal_rank
FROM insa
WHERE MOD( SUBSTR(ssn, -7, 1) , 2) = 0
GROUP BY buseo
)
WHERE sal_rank = 1;

-- [문제] insa 테이블에서 basicpay(기본급)이 상위 10%에 해당하는 사원들의 이름, 기본급 출력
SELECT *
FROM (SELECT name, basicpay, 
        RANK() OVER( ORDER BY basicpay DESC)"순위"
        FROM insa
        )i
WHERE 순위 <= (SELECT COUNT(*) FROM insa) * 0.1;

-- PERCENT_RANK() --상대적인 위치를 나타냄
SELECT *
FROM (
    SELECT name, basicpay
        ,  PERCENT_RANK() OVER ( ORDER BY basicpay DESC) p_rank
    FROM insa
    )
WHERE p_rank <= 0.1;

-- [ 문제 ] emp 테이블에서 sal 컬럼으로 '상/중/하' 로 사원 구분

SELECT emp.*, RANK() OVER( ORDER BY sal DESC)"순위"
       , CASE 
            WHEN RANK() OVER( ORDER BY sal DESC) <= (SELECT COUNT(*) FROM emp)/3 THEN '상'
            WHEN RANK() OVER( ORDER BY sal DESC) BETWEEN (SELECT COUNT(*) FROM emp)/3 + 1 AND ((SELECT COUNT(*) FROM emp)/3)*2  THEN '중'
            ELSE                                            '하'
        END 등급
FROM emp;




WITH e AS(
    SELECT emp.*, RANK() OVER( ORDER BY sal DESC)"순위", (SELECT COUNT(*) from emp)총사원수
    FROM emp
)
SELECT e.*, 
        CASE 
            WHEN 순위 <= 총사원수/3 THEN '상'
            WHEN 순위 BETWEEN 총사원수/3 AND (총사원수/3)*2  THEN '중'
            ELSE                                               '하'
        END 등급
FROM e;

-- [3]
SELECT ename, sal
        , NTILE(3) OVER ( ORDER BY sal DESC ) n_group
        , CASE NTILE(3) OVER ( ORDER BY sal DESC )
            WHEN 1 THEN '상'
            WHEN 2 THEN '중'
            ELSE '하'
          END
FROM emp;

-- FIRST_VALUE, LAST_VALUE 분석함수
select sal
        ,first_value(sal) over (order by sal DESC)
        ,first_value(ename) over (order by sal DESC)
FROM (
    select * from emp
        where deptno = 20
        order by sal DESC
        );
        
-- [문제] emp 테이블에서 ename, pay, 평균급여 출력
SELECT ename, sal+NVL(comm,0)pay
        , (SELECT AVG(sal+NVL(comm,0)) FROM emp)avg_pay
FROm emp;


-- [문제] insa 테이블에서 주민등록번호 생일 지났다. 지나지 않았다. 오늘이 생일이다.
SELECT *
FROM insa;

-- 오늘이 생일인 사원 만들기. 1002 이순신 800325-1544236 UPDATE 쿼리 작성
SELECT insa.*, CONCAT(SUBSTR(ssn,1,2), TO_CHAR(SYSDATE, 'MMDD'))|| SUBSTR(ssn,-8)
        , REGEXP_REPLACE(ssn, '^(\d{2})(\d{4})(-\d{7})$', '\1'||TO_CHAR(SYSDATE, 'MMDD')||'\3')
FROM insa;

UPDATE insa
--SET ssn =  CONCAT(SUBSTR(ssn,1,2), TO_CHAR(SYSDATE, 'MMDD'))|| SUBSTR(ssn,-8)
SET ssn = REGEXP_REPLACE(ssn, '^(\d{2})(\d{4})(-\d{7})$', '\1'||TO_CHAR(SYSDATE, 'MMDD')||'\3')
WHERE num = 1002;

commit;

SELECT *
FROM insa;

------------

SELECT name, today, birthday
        , today - birthday
        ,DECODE( SIGN(today-birthday) , 0 , '오늘',1 , 'X', 'O')
--        , CASE 
--            WHEN today - birthday = 0 THEN '오늘생일'
--            WHEN today - birthday < 0 THEN '생일 지나지 않았다.'
--            ELSE '생일이 지났다.'
        END
        
FROM (
SELECT name, ssn
        ,TRUNC(SYSDATE)  today
        , TO_CHAR( SYSDATE, 'DS TS')
        ,TO_DATE( SUBSTR(ssn, 3,4)  , 'MMDD') birthday
FROM insa
);

-- [문제] insa 테이블에서 주민등록번호를 사용해서 만나이를 계산해서 출력.
--      만나이 = 올해년도(2025) - 생일년도(1977)  -1    생일지나지않으면
SELECT name, ssn
    , 올해년도 - 출생년도 - DECODE ( bsign, 1 , 1, 0  ) 만나이
FROM(
SELECT name, ssn
    , TO_CHAR(SYSDATE, 'YYYY') 올해년도
    , SUBSTR(ssn, -7, 1) 성별
    , SUBSTR(ssn, 1, 2) 생일의2자리년도
    , CASE 
        WHEN SUBSTR(ssn, -7, 1) IN (1,2,5,6) THEN 1900
        WHEN REGEXP_LIKE(SUBSTR(ssn, -7, 1), '[3778]') THEN 2000
        ELSE 1800
     END + SUBSTR(ssn, 1, 2) 출생년도
    , SIGN( TO_DATE( SUBSTR( ssn, 3, 4), 'MMDD' ) - TRUNC(SYSDATE)) bsign
    -- 생일이 지나지 않으면 1        -1살
    
FROM insa
);

-- Math.random() 임의의 수
-- Random rnd = new Random(seed long); rnd.nextInt(1,46)
-- 오라클 DBMS_RANDOM 패키지 존재 : 서로 관련된 함수, 프로시저 등을 묶어 놓은 것
SELECT DBMS_RANDOM.VALUE -- 0 <= 실수 < 1
    ,DBMS_RANDOM.VALUE(1,46) -- 두 값 사이의 실수 값
    -- 정수 로또번호
    ,FLOOR ( DBMS_RANDOM.VALUE(1,46) )
FROM dual;

SELECT DBMS_RANDOM.RANDOM -- -21억 ~ 정수 ~21억
FROM dual;

SELECT DBMS_RANDOM.STRING('X',10) -- 대문자 + 숫자 10자리
        , DBMS_RANDOM.STRING('U',10) -- 대문자만 10자리
        , DBMS_RANDOM.STRING('L',10) -- 소문자만 10자리
        , DBMS_RANDOM.STRING('P',10) -- 대문자+소문자+숫자+특수문자
        , DBMS_RANDOM.STRING('A',10) -- 대문자+소문자
FROm dual;

-- 로또번호(1~45)
-- 국어점수(0~100)
-- 인증번호 6자리 생성, 출력
SELECT TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0,1000000)), '099999')
     , TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(0,1000000)), '099999')
FROM dual;

-- 
SELECT *
FROM (SELECT * FROM emp ORDER BY DBMS_RANDOM.VALUE)
WHERE ROWNUM <= 5;

-- [문제] emp 테이블에서 각 부서별 최고 급여자, 최저 급여자 사원정보 조회.
--[1] 풀이
SELECT *
FROM emp m
WHERE sal IN (
                (SELECT MAX(sal) FROM emp WHERE deptno = m.deptno)
                , (SELECT MIN(sal) FROM emp WHERE deptno = m.deptno)
                )
ORDER BY deptno ASC, sal DESC ;

--[2] 풀이
SELECT m.*,
        CASE
        END
FROM (
SELECT e.*
        , RANK() OVER( PARTITION BY deptno ORDER BY sal DESC )saldesc
        , RANK() OVER( PARTITION BY deptno ORDER BY sal ASC )salasc
FROm emp e
)m
WHERE saldesc = 1 OR salasc = 1 ;



DESC emp;

SELECT *
FROM emp e
WHERE e.sal = SELECT FIRST_VALUE(sal) OVER(PARTITION BY deptno ORDER BY sal DESC) AND e.deptno = deptno)

--[3] 풀이
SELECT a.*
FROM emp a, (SELECT deptno,  MAX(sal) max, MIN(sal) min FROM emp GROUP BY deptno) b
WHERE a.sal = b.max OR a.sal = b.min  AND a.deptno = b.deptno
ORDER BY a.deptno, sal DESC;

--[4]
 WITH t AS (
    SELECT emp.*
       , RANK() OVER(ORDER BY sal DESC) r
    FROM emp
), s AS (
    SELECT MAX(r)mr
    FROM t 
)
SELECT empno, ename, sal, r
FROM t
WHERE r IN (1, (SELECT mr FROM s));