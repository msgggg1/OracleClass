-- SCOTT --
-- [문제] emp 테이블에서 사원이 존재하지 않는 부서번호, 부서명을 조회
-- [1] SET 연산자 : 차집합
WITH t AS(
SELECT deptno
FROM dept

MINUS

SELECT DISTINCT deptno
FROM emp
WHERE deptno IS NOT NULL
    )
SELECT t.deptno, d.dname
FROM t JOIN dept d ON t.deptno = d.deptno
;
--
--[2] SQL 연산자 (ANY, SOME, ALL, EXISTS)
SELECT d.deptno, d.dname
FROM dept d
WHERE NOT EXISTS(SELECT empno FROM emp WHERE deptno = d.deptno);

--[3] SQL 연산자 ( ANY , SOME , ALL , EXISTS )
SELECT d.deptno, d.dname
FROM dept d
WHERE (SELECT COUNT(empno) FROM emp WHERE deptno = d.deptno) = 0;

--[4]
SELECT d.deptno, d.dname
--        , COUNT(empno)
FROM emp e RIGHT JOIN dept d ON e.deptno = d.deptno
GROUP BY d.deptno, d.dname
HAVING COUNT(empno)=0;

-- [ 문제 ] GROUP BY, HAVING 절 사용
-- insa 테이블에서 각 부서별 여자사원수가 5명 이상인 부서 정보 출력
-- (이해: wHERE 조건절과 HAVING 조건절의 차이점)

SELECT buseo, COUNT(*) 
FROm insa
WHERE MOD(SUBSTR(ssn,-7,1),2)= 0
GROUP BY buseo
HAVING COUNT(*) >= 5;


-- [문제] insa 테이블
--     [총사원수]      [남자사원수]      [여자사원수] [남사원들의 총급여합]  [여사원들의 총급여합] [남자-max(급여)] [여자-max(급여)]
------------ ---------- ---------- ---------- ---------- ---------- ----------
--        60                31              29           51961200                41430400                  2650000          2550000

SELECT COUNT(*)
FROM insa;

SELECT COUNT(*), SUM(basicpay), MAX(basicpay)
FROM insa
WHERE MOD(SUBSTR(ssn,-7,1),2)= 1 ;

SELECT COUNT(*), SUM(basicpay), MAX(basicpay)
FROM insa
WHERE MOD(SUBSTR(ssn,-1,1),2)= 0 ;

-- 남자, 여자 사원 정보 같이 출력
SELECT COUNT(*)
        , COUNT( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,1, 'M') )남자사원수
        , COUNT( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,0, 'M') )여자사원수
        , SUM( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,1, basicpay) )남자총급여
        , SUM( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,0, basicpay) )여자총급여
        , MAX( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,1, basicpay) )남자최고급여
        , MAX( DECODE(MOD(SUBSTR(ssn,-1,1),2) ,0, basicpay) )여자최고급여
FROM insa;

-- [2] 풀이
SELECT CASE MOD(SUBSTR(ssn,-7,1),2)
        WHEN 1 THEN '남자'
        WHEN 0 THEN      '여자'
        ELSE        '전체'
        END gender
        , COUNT(*)
        , SUM(basicpay)
        , MAX(basicpay)
FROM insa
GROUP BY ROLLUP( MOD(SUBSTR(ssn,-7,1),2));

-- [문제] emp 테이블에서~
--      각 부서의 사원수, 부서 총급여합, 부서 평균급여
--결과)
--    DEPTNO       부서원수       총급여합            평균
------------ ----------       ----------    ----------
--        10          3          8750       2916.67
--        20          3          6775       2258.33
--        30          6         11600       1933.33 
--        40          0         0             0
-- [1] 풀이 GROUP BY 절 사용
-- (추가) 평균 무조건 소수점 두자리까지 
SELECT d.deptno
        , COUNT(empno)부서원수
        , NVL(SUM(sal+NVL(comm,0)),0)총급여합
        , NVL(TO_CHAR(ROUND(AVG(sal+NVL(comm,0)),2),'99990.00'),0)평균
FROM emp e RIGHT JOIN dept d ON e.deptno = d.deptno
GROUP BY d.deptno
ORDER BY d.deptno;

-- ROLLUP, CUBE 설명 --
-- GROUP BY 절에서 사용되는 그룹별 부분합을 추가로 보여주는 역할
-- 즉, 추가적인 집계 정보를 보여준다. 
SELECT MOD(SUBSTR(ssn,-7,1),2) 성별
        , COUNT(*) 사원수
FROM insa
GROUP BY MOD(SUBSTR(ssn,-7,1),2)
UNION ALL
SELECT null, COUNT(*)
FROM insa;--
SELECT MOD(SUBSTR(ssn,-7,1),2) 성별
        , COUNT(*) 사원수
FROM insa
GROUP BY CUBE(MOD(SUBSTR(ssn,-7,1),2));
--GROUP BY ROLLUP(MOD(SUBSTR(ssn,-7,1),2));

--[ ROLLIP/CUBE 차이점]
-- 1차 부서별 그룹핑, 2차 직위별로 그룹핑
SELECT buseo, jikwi
        , COUNT(*)
FROM insa
GROUP BY buseo, jikwi
--ORDER BY buseo, jikwi
UNION ALL
SELECT buseo, null
        ,COUNT(*) 사원수
FROM insa
GROUP BY buseo
--ORDER BY buseo, jikwi
UNION ALL
SELECT null, null
        , COUNT(*)
FROM insa;
--ORDER BY buseo, jikwi -- 인식 못함

-- [2] 
SELECT buseo, jikwi
        , COUNT(*) 사원수
FROM insa
GROUP BY CUBE(buseo, jikwi)
--GROUP BY ROLLUP(buseo, jikwi)
ORDER BY buseo, jikwi;

-- 분할 ROLLUP
SELECT buseo, jikwi, COUNT(*)사원수
FROM insa
--GROUP BY ROLLUP(buseo), jikwi -- 직위에 대한 부분 집계, 전체 집계 X
GROUP BY buseo, ROLLUP(jikwi) -- 부서에 대한 부분 집계, 전체 집계X
ORDER BY buseo, jikwi;

-- GROUPING SETS()
SELECT buseo, jikwi, COUNT(*)사원수
FROM insa
GROUP BY GROUPING SETS ( buseo, jikwi ) -- 그룹핑한 집계만 보고자 할 때
ORDER BY buseo, jikwi;

-- 
--[문제] 각 부서별 직위별   최소사원수, 최대사원수 조회.
-- 부서  직위 최소사원수  직위 최대사원수
--개발부   부장     1          사원     9
--기획부   부장     2          대리     3
--  :

-- [1] 풀이
WITH a AS(
SELECT buseo, jikwi, COUNT(num) tot_count
FROM insa
GROUP BY buseo, jikwi
), b AS(
    SELECT buseo
    , MIN(tot_count)최소사원수
    , MAX(tot_count)최대사원수
    FROM a
    GROUP BY buseo
)
SELECT a.buseo, a.jikwi, a.tot_count
FROM a, b
WHERE a.buseo = b.buseo AND a.tot_count IN(b.최소사원수, b.최대사원수)
ORDER BY a.buseo, a.tot_count;
--WHERE a.buseo = b.buseo AND a.tot_count=b.최소사원수;

--WITH a AS(
--    SELECT buseo, jikwi, COUNT(*) 사원수
--    FROM insa
--    GROUP BY ROLLUP(buseo, jikwi)
--    ORDER BY buseo, jikwi
--    )
--SELECT buseo, jikwi, 사원수
--        , (SELECT MIN(사원수) FROM a WHERE a.buseo = buseo )최소사원수
--        , (SELECT MAX(사원수) FROM a WHERE a.buseo = buseo )최대사원수
--FROM a;
--
--
--WITH a AS(
--    SELECT buseo, jikwi, COUNT(*) 사원수
--    FROM insa
--    GROUP BY buseo, jikwi
--    ORDER BY buseo, jikwi
--)
--SELECT a.*
--FROM a
--WHERE a.사원수 = (SELECT MAX(사원수) FROM a) OR  a.사원수 = (SELECT MIN(사원수) FROM a)
--ORDER ;

-- [2] 풀이 (FIRST/LAST 분석함수 사용)
--            집계함수(COUNT, SUM, AVG, MAX, MIN)와 같이 사용하여 
--            주어진 그룹에 대해 내부적으로 순위를 매겨 결과를 산출하는 함수
-- 문제점) 최소가 두 그룹인데 한그룹만 출력됨
WITH t AS(
    SELECT buseo, jikwi, COUNT(num)tot_count
    FROM insa
    GROUP BY buseo, jikwi
) 
SELECT t.buseo
        , MIN(t.jikwi) KEEP(DENSE_RANK FIRST ORDER BY t.tot_count ASC)직위
        , MIN(t.tot_count)
        , MIN(t.jikwi) KEEP(DENSE_RANK FIRST ORDER BY t.tot_count DESC)직위
        , MIN(t.jikwi) KEEP(DENSE_RANK LAST ORDER BY t.tot_count ASC)직위
        , MAX(t.tot_count)
FROM t
GROUP BY t.buseo
ORDER BY t.buseo ASC;


-- [문제] emp 테이블에서 사원정보 조회
-- 조건 1) deptno -> dname
-- 조건 2) 직속상사 mgr -> ename
-- 셀프조인: 자기 자신 조인 / 조건이 중요
SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
           LEFT JOIN emp e2 ON e.mgr = e2.empno;


--
SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname
FROM emp e , dept d , emp e2 
WHERE e.deptno = d.deptno AND e.mgr = e2.empno;

--
SELECT *
FROM salgrade;
--grade losal hisal
--1	700	1200
--2	1201	1400
--3	1401	2000
--4	2001	3000
--5	3001	9999

SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname, e.sal
        , CASE 
            WHEN e.sal BETWEEN 700 AND 1200 THEN '1'
            ELSE                        ' '
            END
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
           LEFT JOIN emp e2 ON e.mgr = e2.empno;


SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname, e.sal
        , CASE 
            WHEN e.sal BETWEEN 700 AND 1200 THEN 1
            WHEN e.sal BETWEEN 1201 AND 1400 THEN 2
            WHEN e.sal BETWEEN 1401 AND 2000 THEN 3
            WHEN e.sal BETWEEN 2001 AND 3000 THEN 4
            WHEN e.sal BETWEEN 3001 AND 9999 THEN 5                       
            END grade
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
           LEFT JOIN emp e2 ON e.mgr = e2.empno;


-- [2] NON-EQUI JOIN   //  
SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname, e.sal
        ,grade
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
           LEFT JOIN emp e2 ON e.mgr = e2.empno
           JOIN salgrade s ON e.sal BETWEEN losal AND hisal;


SELECT e.empno, e.ename, e.job, e2.ename 직속상사, e.hiredate, d.dname, grade
FROM emp e , dept d , emp e2 , salgrade s
WHERE e.deptno = d.deptno(+) AND e2.empno(+) = e.mgr AND e.sal BETWEEN losal AND hisal

;

-- 부모 - 자식 : 1)먼저 만들어져야 하는 테이블 2) 누가 주체가 되는지 (주문관계에서 누가 주문'하는지', 상품은 주문'되어짐')

-- JOIN
-- CROSS JOIN : WHERE 조건이 없을때



-- CUME_DIST() 분석함수
--     ㄴ 주어진 그룹에 대한 상대적인 누적 분포도 값을 반환
--     ㄴ  분포도값(비율)   0<    <=1
SELECT deptno, ename, sal
--    ,CUME_DIST() OVER (ORDER BY sal DESC)cd
    ,CUME_DIST() OVER (PARTITION BY deptno ORDER BY sal DESC)cd
FROm emp;

-- NTILE() 함수
-- ㄴ 파티션 별로 expr에 명시된 만큼 분할한 결과를 반환하는 함수
-- ㄴ 분할하는 수를 "버킷(bucket)"이라고 한다. 
SELECT deptno, ename, sal
        ,NTILE(2) OVER (PARTITION BY deptno ORDER BY sal ASC) ntiles
--        ,NTILE(4) OVER (ORDER BY sal ASC) ntiles
FROm emp;


-- 너비  버킷
-- WIDTH_BUCKET()
-- WIDTH_BUCKET(expression, min_value, max_vlaue, num_buckets)
-- exoression: 평가할 값, min_value, max_value사이에 있을 떄, 그 값이 어느 버킷에 해당하는지 계산
-- num bucket: 버킷의 개수

SELECT ename, sal
        , WIDTH_BUCKET(sal,0,5000,7)sb_sal
        , WIDTH_BUCKET(sal,1000,4000,4)sb_sal4
FROM emp;

WITH a AS(
    SELECT ename, TRUNC(sal/100+50) score
    FROM emp
)

SELECT a.*
-- 수우미양가 찍기
-- CASE       
      ,CASE 
        WHEN score BETWEEN 90 AND 100 THEN '수'
        WHEN score>=80 AND score<90  THEN '우'
        WHEN score>=70 AND score<80  THEN '미'
        WHEN score>=60 AND score<70  THEN '양'
        WHEN score< 60  THEN '가'
      END 등급
--DECODE
    
-- WIDTH_BUCKET
    , 
      CASE WIDTH_BUCKET (score, 60, 101, 4)
        WHEN 4 THEN '수'
        WHEN 3 THEN '우'
        WHEN 2 THEN '미'
        WHEN 1 THEN '양'
        ELSE        '가'
      END
FROM a;

--
-- LAG() : 현재 행의 이전 행 값을 반환 / 이전 행의 데이터 참조 시 유용/ 정렬 뒤 사용
--, LEAD()
-- 비교 용도로 사용됨

SELECT deptno, ename, hiredate, sal
        ,LAG( sal, 3, -1 ) OVER( ORDER BY sal DESC) prev_sal
        ,LEAD( sal, 2 , -1) OVER( ORDER BY sal DESC) next_sal
FROm emp;

-- 
SELECT t.*
FROM(
    SELECT ename, sal
        , RANK() OVER(ORDER BY sal DESC)r
        , LEAD(sal, 1, -1) OVER(ORDER BY sal DESC)next_sal
    FROM emp

)t
WHERE r = 1 OR next_sal = -1;

-- [문제 ] PIVOT() emp 테이블에서
--                  입사년도, 분기별 사원수 출력
--                  1980      1      3

--
SELECT *
FROM ( 
    SELECT TO_CHAR(hiredate,'YYYY') y
            , TO_CHAR(hiredate,'Q')q
    FROm emp
)
PIVOT( COUNT(*) FOR q IN( 1,2,3,4 ))
ORDER BY y ASC;

--- 나
SELECT DISTINCT TO_CHAR(hiredate, 'YYYY')입사년도
        ,WIDTH_BUCKET(TO_NUMBER(TO_CHAR(hiredate, 'MM')),1,13,4)분기별
        ,COUNT(*)사원수
FROm emp
GROUP BY TO_CHAR(hiredate, 'YYYY')
        ,WIDTH_BUCKET(TO_NUMBER(TO_CHAR(hiredate, 'MM')),1,13,4)
ORDER BY 입사년도, 분기별;

-- [2] PIVOT () 사용하지 않고 구현
WITH e AS(
    SELECT  TO_CHAR(hiredate,'YYYY') y
            , TO_CHAR(hiredate,'Q')q
    FROm emp
), a AS(
    SELECT TO_CHAR(hiredate,'Q')q
    FROm emp
)
SELECT e.y, e.q, COUNT(*)
FROM e PARTITION BY(e.y, a.q) RIGHT JOIN a ON e.q = a.q
GROUP BY e.y, e.q
ORDER BY e.y, e.q;


--[3] 위의 2번 풀이를 PARTITION BY () OUTER JOIN 사용하여 
WITH e AS(
    SELECT  empno ,TO_CHAR(hiredate,'YYYY') y
            , TO_CHAR(hiredate,'Q')q
    FROm emp
), m AS(
    SELECT LEVEL q
    FROm dual
    CONNECT BY LEVEL <=4 
)
SELECT e.y, m.q, COUNT(empno)
FROM e PARTITION BY(e.y) RIGHT JOIN m ON e.q = m.q
GROUP BY e.y, m.q
ORDER BY e.y, m.q;

-- COUNT ~ OVER : 질의한 행의 누적된 행 결과
SELECT name, basicpay
        , COUNT(*) OVER (ORDER BY basicpay ASC)
FROm insa;
-- SUM ~ OVER : 
SELECT name, basicpay
        , SUM(basicpay) OVER (ORDER BY basicpay DESC)
FROm insa;
-- AVG ~ OVER : 
SELECT name, basicpay
        , AVG(basicpay) OVER (ORDER BY basicpay DESC)
FROm insa;

-- [오라클 자료형(Date Type)]
--  1) CHAR[ ( SIZE [BYTE|CHAR] ) ]
      고정길이 문자열 저장
      1~2000바이트 저장할 수 있는 자료형
      항상 ex) 10바이트 비어있을때도 저장
      언제 사용 ) 데이터 주고받을때, 주민등록번호 '000000-0000000' 고정된 길이의 문자열
        
      
      예) 동일한 표현
       CHAR(1 BYTE) == CHAR(1) == CHAR-- BYTE기본값, 생략되어있음
       CHAR(3 BYTE) = 'abc'-> 저장, '홍길동' -> 저장되지 않고 오류
       CHAR(3 CHAR) == 'abc' O, '홍길동' O
    
    실습)
    CREATE TABLE tbl_char (
        aa CHAR         -- CHAR(1) == CHAR(1 BYTE)
        , bb CHAR(3)    -- CHAR(3 BYTE)
        , cc CHAR(3 CHAR)
    );
-- Table TBL_CHAR이(가) 생성되었습니다.
DESC tbl_char;
INSERT INTO tbl_char VALUES ('a', 'aaa', 'aaa');
--1 행 이(가) 삽입되었습니다.
commit;
INSERT INTO tbl_char VALUES ('b', '한', '한우리');
--1 행 이(가) 삽입되었습니다.
INSERT INTO tbl_char VALUES ('c', '한우리', '한우리');
-- SQL 오류: ORA-12899: value too large for column "SCOTT"."TBL_CHAR"."BB" (actual: 9, maximum: 3)

DROP TABLE tbl_char PURGE;
-- Table TBL_CHAR이(가) 삭제되었습니다.
-- DDL 문: CREATE, ALTER, DROP

--2) NCHAR [(SIZE)] 1문자 기본값, 2000바이트 까지
CREATE TABLE tbl_nchar (
    aa char(3)
    , bb char(3 char)
    , cc nchar(3) -- u[N]icode - 2바이트 모든 문자 2바이트로 처리
    );
-- Table TBL_NCHAR이(가) 생성되었습니다.
INSERT INTO tbl_nchar VALUES ('c', '한우리', 'aaaㄹ');
INSERT INTO tbl_nchar VALUES ('c', '한우리', '한글셋');

    CHAR/NCHAR 언제 구분해서 사용? 둘다 고정된길이, 2000바이트까지 저장
    CHAR 영어 1바이트, 한글 3바이트...
    NCHAR 알파벳, 한글 2바이트 형태로 저장
    
DROP TABLE tbl_nchar purge;

--3) VARCHAR2(SIZE [BYTE|CHAR] )
--  ㄴ 가변길이
--  ㄴ 4000바이트
    CHAR (10) == CHAR(10 BYTE)
    VARCHAR(10) == VARCHAR2(10 BYTES)
    name CHAR(10);
    name VARCHAR(10); ['a']['b']['c'] [][][][][][][] -> 버림
    
-- 4) [N]VARCHAR2 : 유니코드 varchar2 유니코드문자저장하는 가변길이 
-- 5) VARCHAR 현재는 VARCHAR2 와 같음. 시노님
-- 6) LONG: 가변길이 문자열, 2GB까지 저장
-- 7) NUMBER [(p[,s])]
    p 1 ~ 38
    s -84 ~127
    n NUMBER == n NUMBER(38,127)
    n NUMBER(5) == n NUMBER(5,0) 정수
    반올림(기억)
    
    kor NUMBER(3) -999~999
    avg NUMBER(5,2) 999.99 ~ -999.99
    예)
    CREATE TABLE tbl_number
    (
        name VARCHAR2(10)
        , kor NUMBER(3)
        , eng NUMBER(3)
        , mat NUMBER(3)
        , tot NUMBER(3)
        , avg NUMBER(5,2)
    );
    --
SELECT * FROM tbl_number;
ROLLBACK;

INSERT INTO tbl_number VALUES('홍길동', 23.22, 199.88, 23, null, null);
INSERT INTO tbl_number VALUES('홍길님', 98, 54, 76, null, null);
INSERT INTO tbl_number VALUES('서주원', 67, 99, 199, null, null);

UPDATE tbl_number
SET kor = CASE
                WHEN kor NOT BETWEEN 0 AND 100 THEN null
                ELSE    kor
            END
        , eng = CASE
                WHEN eng NOT BETWEEN 0 AND 100 THEN null
                ELSE    eng
            END
        , mat = CASE
                WHEN mat NOT BETWEEN 0 AND 100 THEN null
                ELSE    mat
            END
        tot = kor + eng + mat
        avg;

    -- 국어,영어,수학 null -> 0 처리해서 총점/평균 UPDATE 쿼리 작성하고 확인
UPDATE tbl_number
SET tot = NVL(kor, 0) + NVL(eng,0) + NVL(mat,0),
    avg = (NVL(kor, 0) + NVL(eng,0) + NVL(mat,0))/3;

DROP TABLE tbl_number PURGE;
-- FLOAT: 내부적으로 NUMBER 타입이다.
-- DATE : 날짜 + 시간 => 고정된 길이 7 BYTE
-- RAW(size),LONG RAW : 2진 데이터 저장 자료형 -- 이미지 저장 시// 그러나 보통 서버에 업로드한 경로를 저장함

-- ROWID : 레코드 위치값 나타내는 고유한 ID 값
SELECT emp.*, ROWID
FROm emp;

-- 테이블 생성/수정/삭제
-- 제약조건
-- DB 모델링 수업
-- PL/SQL
-- 프로젝트