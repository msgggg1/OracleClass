-- [ 문제 ] emp 테이블에서 급여(sal) TOP -3 조회

SELECT t.*, seq
FROM (
        SELECT e.*, ROWNUM seq
        FROM (
            SELECT *
            FROM emp
            ORDER BY sal DESC
         ) e
    )t
WHERE seq = 3;

-- [ 문제 ] emp테이블에서 부서별 급여 순위 매겨서 출력(조회)

SELECT e.*, rank()OVER(PARTITION BY deptno ORDER BY sal)순위
FROM emp e
ORDER BY deptno, 순위 ;