-- SCOTT --
-- [문제] emp 테이블에서 사원이 존재하지 않는 부서번호, 부서명을 조회
-- [1] SET 연산자 : 차집합
WITH  t AS(SELECT deptno
FROM dept

MINUS
SELECT DISTINCT  deptno
FROM emp
) 
SELECT t.deptno, d.dname
FROM t JOIN dept d ON t.deptno = d.deptno;

--[2] SQL 연산자 (ANY, SOME, ALL, EXISTS)
SELECT d.deptno, d.dname
FROm emp e RIGHT JOIN dept d ON  e.deptno = d.deptno
WHERE NOT EXISTS (SELECT empno FROM emp WHERE e.deptno = deptno);
--[3] SQL 연산자 ( ANY , SOME , ALL , EXISTS )
SELECT d.deptno, d.dname
FROm emp e RIGHT JOIN dept d ON  e.deptno = d.deptno
WHERE (SELECT COUNT(empno) FROM emp WHERE e.deptno = deptno) = 0;
--[4]
SELECT d.dname, d.deptno
FROM emp e RIGHT JOIN dept d ON e.deptno = d.deptno
GROUP BY d.dname, d.deptno
HAVING COUNT(empno) = 0;

-- [문제] GROUP BY, HAVING 절 사용
-- insa 테이블에서 각 부서별  여자사원수가 5명 이상인 부서 정보를 출력.
-- ( 이해: WHERE 조건절과 HAVING 조건절의 차이점 )
SELECT buseo, COUNT(*)
FROM insa i
WHERE MOD(SUBSTR(ssn, -7, 1),2)= 0
GROUP BY buseo
HAVING COUNT(*)>= 5;

-- [문제] insa 테이블
--     [총사원수]      [남자사원수]      [여자사원수] [남사원들의 총급여합]  [여사원들의 총급여합] [남자-max(급여)] [여자-max(급여)]
------------ ---------- ---------- ---------- ---------- ---------- ----------
--        60                31              29           51961200                41430400
SELECT (SELECT COUNT(*) FROM insa) 총사원수
    , CASE  MOD(SUBSTR(ssn, -7, 1),2)
        WHEN 1 THEN '남자'
        WHEN 0 THEN '여자'
        END gender
    , COUNT(*)
    , SUM(basicpay)
    , MAX(basicpay)
FROM insa
GROUP BY MOD(SUBSTR(ssn, -7, 1),2);

-- [문제] emp 테이블에서~
--      각 부서의 사원수, 부서 총급여합, 부서 평균급여
결과)
    DEPTNO       부서원수       총급여합    	     평균
---------- ---------- 		---------- 	----------
        10          3      	 8750    	2916.67
        20          3     	 6775    	2258.33
        30          6     	 11600    	1933.33 
        40          0         0             0

SELECT d.deptno, COUNT(empno), SUM(sal), AVG(sal)
FROM emp e RIGHT JOIN dept d ON d.deptno = e.deptno
GROUP BY d.deptno;

--[문제] 각 부서별 직위별   최소사원수, 최대사원수 조회.
-- 부서  직위 최소사원수  직위 최대사원수
-- 개발부	부장	  1	       사원	  9
-- 기획부	부장	  2	       대리	  3
--  :
with i AS(
    select buseo, jikwi, count(*)사원수
    from insa
    group by buseo, jikwi
), n AS(
    select buseo, max(사원수)최대사원수, min(사원수)최소사원수
    from i
    group by buseo
)
select i.buseo  , jikwi, 사원수
from i JOIN n ON i.buseo = n.buseo
where 사원수 In(최대사원수, 최소사원수)
order by buseo;

with i AS(
    select buseo, jikwi, count(*)사원수
    from insa
    group by buseo, jikwi
)
select buseo
    , MIN(jikwi) KEEP (DENSE_rank first order by 사원수 ASC) 직위
    , min(사원수)
    , MIN(jikwi) KEEP (DENSE_rank last order by 사원수 ASC) 직위
    , max(사원수)
from i
group by buseo
order by buseo;

-- [문제] emp 테이블에서 사원 정보 조회
-- 조건 1) deptno -> dname
-- 조건 2) 직속상사 mgr -> ename
select e.empno, e.ename, e.job, m.ename mgr_ename , e.hiredate , dname
        , e.sal
        , grade
from emp e LEFT JOIN dept d ON e.deptno = d.deptno
           LEFT JOIN emp m ON e.mgr = m.empno  
           JOIN salgrade s  On e.sal BETWEEN s.losal AND hisal;
           
select *
from salgrade;

select e.empno, e.ename, e.job, m.ename mgr_ename , e.hiredate , dname
        , e.sal
        , grade
from emp e, dept d, emp m, salgrade s
WHere e.deptno = d.deptno(+) AND e.mgr = m.empno(+) AND
        e.sal BETWEEN s.losal and hisal;

select t.*
from(
    select ename, sal
            , RANK() over(order by sal desc) r
            , lead(sal, 1, -1) OVER(ORDER by sal DESC) next_sal
    from emp
    )t
where r = 1 OR next_sal = -1;

-- [문제] PIVOT() emp 테이블에서           1~3  1분기, 4~6 2분기 7~9 3분기   10~12 4분기
--               입사년도, 분기별  사원수 출력
--               1980       1     3
-- (홍길동)
select *
from (
    select TO_char(hiredate, 'YYYY') 입사년도
            , width_bucket(To_number(TO_CHAR(hiredate, 'mm')),1,13,4 )분기
    from emp
)
pivot ( COUNT(*) for 분기 in (1,2,3,4))
;

WITH A as (
    select TO_char(hiredate, 'YYYY') 입사년도
            , TO_char(hiredate, 'Q') 분기
    from emp
)
select a.*, count(*)
from  a
group by 입사년도, 분기;

WITH a as (
    select empno,TO_char(hiredate, 'YYYY') 입사년도
            , TO_char(hiredate, 'Q') 분기
    from emp
), b as(
    select level 분기
    from dual
    connect by level <= 4
)
select a.입사년도, b.분기, count(empno)
from  a partition by(a.입사년도)RIGHT JOIN b on a.분기 = b.분기
group by 입사년도, b.분기
order by 입사년도, b.분기;