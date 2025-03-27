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









