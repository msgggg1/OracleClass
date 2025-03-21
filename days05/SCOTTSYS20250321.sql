--1. dept 테이블에   deptno = 50,  dname = QC,  loc = SEOUL  로 새로운 부서정보 추가
INSERT INTO dept VALUES(50, 'QC', 'SEOUL');

--1-2. dept 테이블에 QC 부서를 찾아서 부서명(dname)과 지역(loc)을 
--  dname = 현재부서명에 2를 추가,  loc = POHANG 으로 수정
-- PK 이용해서 수정, 삭제해야함
--1) pk 값 찾아오기
SELECT *
FROM dept
WHERE dname LIKE '%QC%' ; -- or REGEXP_LIKE 함수
--2) pk이용하여 수정
UPDATE dept 
SET dname = dname||2, loc = 'POHANG' 
WHERE deptno = 50;
WHERE dname = 'QC'; --보다는 위의 방법으로 

--([게시판] 조회수 증가 쿼리)
UPDATE board
SET readed = readed + 1
WHERE seq =10;

--1-3. dept 테이블에서 QC2 부서를 찾아서 deptno(PK)를 사용해서 삭제
DELETE FROM dept
WHERE deptno = 50;

--2.  insa 테이블에서 남자는 'X', 여자는 'O' 로 성별(gender) 출력하는 쿼리 작성
--    1. REPLACE() 사용해서 풀기
SELECT name, ssn, REPLACE(REPLACE(SUBSTR(ssn,8,1),'1','X'), '2', 'O') gender
FROM insa;

--    2. NVL2(), NULLIF() 사용해서 풀기.
SELECT name, ssn, NVL2(NULLIF(SUBSTR(ssn,8,1),'1'),'O','X')gender
FROM insa;
--    
--    NAME                 SSN            GENDER
--    -------------------- -------------- ------
--    홍길동               771212-1022432    X
--    이순신               801007-1544236    X
--    이순애               770922-2312547    O
--    김정훈               790304-1788896    X
--    한석봉               811112-1566789    X 
--
--3.  insa 테이블에서 2000년 이후 입사자 정보 조회하는 쿼리 작성
--    1. TO_CHAR() 함수 사용해서 풀기
SELECT name, ibsadate
FROM insa
WHERE TO_CHAR(ibsadate, 'yyyy') >= 2000;

--    2. EXTRACT() 함수 사용해서 풀기.
SELECT name, ibsadate
FROM insa
WHERE EXTRACT(YEAR FROM ibsadate) >= '2000';
--    
--    NAME                 IBSADATE
--    -------------------- --------
--    이미성               00/04/07
--    심심해               00/05/05
--    권영미               00/06/04
--    유관순               00/07/07    
--    
--4. 지금까지 배운 오라클 자료형을 적으세요.
--   ㄱ. 'DATE', 'TIMESTAMP'
--   ㄴ. NUMBER(p [,s])
--   ㄷ. 'VARCHAR2', LONG
--   ㄹ. CHAR
--
--5. 
--    
--6. 시노님(synonym)에 대해서 간단히 설명하세요. 
--   1) 정의 : 하나의 객체에 다른 이름을 정의하여 호출을 용이하게 하는 것. 스키마.객체명     시노님(별칭)
--   2) 종류 : private, public
--   3) 생성 , 삭제 선언 형식
--          생성: CAEATE [public] SYNONYM 사용할 명칭 FOR 대상테이블명
--          삭제: DROP [public] SYNONTM 시노님이름
--   4) 시노님 조회 쿼리.
        all_synonyms 뷰
        user_synonyms 뷰
        
        SELECT *
        FROM all_synonyms;
--
--7. 
--
--8.  insa 테이블에서  주민번호를 아래와 같이 '-' 문자를 제거해서 출력

--    NAME    SSN             SSN_2
--    홍길동	770423-1022432	7704231022432
--    이순신	800423-1544236	8004231544236
--    이순애	770922-2312547	7709222312547    
--    
--    1) SUBSTR() 사용
SELECT  name, ssn, SUBSTR(ssn,1,6)||SUBSTR(ssn,-7)ssn_2
FROM insa;
--    2) REPLACE() 사용
SELECT  name, ssn, REPLACE(ssn, SUBSTR(ssn,7,1))ssn_2
FROM insa;
--    3) REGEXP_REPLACE() 사용
SELECT  name, ssn, REGEXP_REPLACE(ssn, '-')ssn_2
FROM insa;
--[숫자함수]
--9. ROUND() 
--   1) 함수 설명 : 반올림 함수
--   2) 형식 설명 : ROUND(대상[, 자리위치]) -> b+1자리에서 반올림, 없으면 0
--   3) 쿼리 설명
--        SELECT    3.141592
--               , ROUND(  3.141592 )     a     --> 3
--               , ROUND(  3.141592,  0 ) b     --> 3
--               , ROUND(  3.141592,  2 ) c     --> 3.14
--               , ROUND(  3.141592,  -1 ) d    --> 0
--               , ROUND( 12345  , -3 )  e      --> 12000
--       FROM dual;
--
--9-2. TRUNC()함수와 FLOOR() 함수에 대해서 설명하세요.      
        절삭함수
        FLOOR(a)--> 정수값 리턴
        TRUNC(a,b) --> b+1자리에서 절삭, 값 안주면 0기본값으로 FLOOR()와 동일한 기능. 숫자, 날짜 절삭
--9-3. CEIL() 함수에 대해서 설명하세요. 절상 함수 CEIL(a)
--9-4. 나머지 값을 리턴하는 함수 :  (   MOD()   )
--9-5. 절대값을 리턴하는 함수 :   (   ABS()    ) 
--
--11. insa 테이블에서 모든 사원들을 14명씩 팀을 만드면 총 몇 팀이 나올지를 쿼리로 작성하세요.
SELECT CEIL(COUNT(*)/14)
FROM insa;
-- 게시판 페이징 처리
-- 총 게시글 수 : 387
-- 한 페이지   : 10
-- 총 페이지 수 :?
SELECT CEIL(387/10)
FROm dual;

--
--12. emp 테이블에서 최고 급여자, 최저 급여자 정보 모두 조회

SELECT empno, ename, sal+NVL(comm,0) pay
FROm emp
ORDER BY pay DESC;
-- COUNT()
SELECT MAX(sal+NVL(comm,0))maxpay, MIN(sal+NVL(comm,0))minpay
FROm emp;
-- 사원 정보 조회 합집합(UNION) (SET 연산자)
--[1]
SELECT empno, ename, job, mgr, hiredate, sal+NVL(comm,0) pay, deptno, '최고급여자'
FROM emp
WHERE sal+NVL(comm,0) = (SELECT MAX(sal+NVL(comm,0))maxpay FROM emp)
UNION
SELECT empno, ename, job, mgr, hiredate, sal+NVL(comm,0) pay, deptno, '최저급여자'
FROM emp
WHERE sal+NVL(comm,0) = (SELECT MIN(sal+NVL(comm,0))minpay FROM emp);

--[2]
SELECT empno, ename, job, mgr, hiredate, sal+NVL(comm,0) pay, deptno
FROM emp
WHERE sal+NVL(comm,0) = (
                            SELECT MAX(sal+NVL(comm,0))maxpay 
                            FROM emp
                            ) 
        OR sal+NVL(comm,0) = (
                            SELECT MIN(sal+NVL(comm,0))minpay 
                            FROM emp
                            );
                            
--[3] OR 대신 IN
SELECT empno, ename, job, mgr, hiredate, sal+NVL(comm,0) pay, deptno
FROM emp
WHERE sal+NVL(comm,0) IN( (
                            SELECT MAX(sal+NVL(comm,0))maxpay 
                            FROM emp
                            ) 
                        , (
                            SELECT MIN(sal+NVL(comm,0))minpay 
                            FROM emp
                            ));

WITH e AS(
    SELECT emp.*, sal+NVL(comm,0)"PAY(sal+comm)"
    FROM emp
)
SELECT *
FROM e
WHERE sal+NVL(comm,0) = (SELECT MAX(sal+NVL(comm,0)) FROM e); 

--                                            PAY(sal+comm)
--7369	SMITH	CLERK	7902	80/12/17	800		    20  최고급여자
--7839	KING	PRESIDENT		81/11/17	5000		10  최저급여자
--
--13. emp 테이블에서 
--   comm 이 400 이하인 사원의 정보 조회
--  ( comm 이 null 인 사원도 포함 )
--    
--    ENAME   SAL    COMM
--    SMITH	800	
--    ALLEN	1600	300
--    JONES	2975	
--    BLAKE	2850	
--    CLARK	2450	
--    KING	5000	
--    TURNER	1500	0
--    JAMES	950	
--    FORD	3000	
--    MILLER	1300	

SELECT ename, sal, comm
FROM emp
WHERE LNNVL(comm>400);
WHERE comm <= 400 OR comm IS NULL;

--(이 문제는 생각만 풀 수 있으면 풀어보세요. )    
--14. emp 테이블에서 각 부서별 급여(pay)를 가장 많이 받는 사원의 정보 출력.    

SELECT deptno, ename, sal+NVL(comm,0) pay
FROM emp
ORDER BY deptno ASC, pay DESC;
--
SELECT MAX( sal+NVL(comm,0)) pay
FROM emp
WHERE deptno = 10; -- 20,30도 동일하게 확인가능
--
-- 상관 서브쿼리 ( 서브 + 메인 쿼리 ) 서로 관계가 있다. 
SELECT deptno, ename, sal+NVL(comm,0) pay
FROM emp e --AS 부여
WHERE sal + NVL(comm,0) = (
                            SELECT MAX(sal+NVL(comm,0)) 
                            FROM emp
                            WHERE deptno = e.deptno --메인쿼리 부서번호 넣어야 실행 -> 단독으로는 실행불가
                            )
ORDER BY deptno ;


-- [문제] emp 테이블의 전체 사원의 평균 급여 .
-- 그룹함수(집계 함수) : COUNT() ,  MAX(), MIN(), SUM()
SELECT SUM(sal + NVL(comm, 0))pay, COUNT(*)
        ,ROUND(SUM(sal + NVL(comm, 0)) / COUNT(*),2) avgpay
        ,ROUND(AVG(sal + NVL(comm, 0)))
FROM emp;

-- emp테이블에서 각 사원들이 평균급여보다 많이 받는 사원 정보 조회.
SELECT deptno, ename, sal + NVL(comm, 0)pay
FROm emp
WHERE sal + NVL(comm, 0) >= (SELECT AVG(sal + NVL(comm, 0)) FROM emp);

-- 각 부서의 평균 급여
SELECT AVG(sal + NVL(comm, 0)) FROM emp WHERE deptno = 10; -- 20, 30..

--[문제] 해당 부서의 평균보다 크면 출력
SELECT deptno, ename, sal + NVL(comm, 0)pay
,  (SELECT AVG(sal + NVL(comm, 0))
                            FROM emp
                            WHERE deptno = e.deptno)avgpay
FROm emp e
WHERE sal + NVL(comm, 0) >= (
                            SELECT AVG(sal + NVL(comm, 0))
                            FROM emp
                            WHERE deptno = e.deptno
                            )
ORDER BY deptno, pay ;
-- 서브 쿼리 성능 떨어짐
-- (2)
SELECT deptno, ename, sal + NVL(comm,0) pay
FROM emp
WHERE sal + NVL(comm,0) = (SELECT MAX(sal + NVL(comm, 0))   FROM emp WHERE deptno = 10 AND deptno = 10) 
UNION
SELECT deptno, ename, sal + NVL(comm,0) pay
FROM emp
WHERE sal + NVL(comm,0) = (SELECT MAX(sal + NVL(comm, 0))   FROM emp WHERE deptno = 20 AND deptno = 20) 
UNION
SELECT deptno, ename, sal + NVL(comm,0) pay
FROM emp
WHERE sal + NVL(comm,0) = (SELECT MAX(sal + NVL(comm, 0))   FROM emp WHERE deptno = 30 AND deptno = 30) ;
-- 다른 부서여도 최고값이 같다면 출력됨

-- [문제] 부서번호, [부서명], 사원번호, 사원명, 입사일자 조회 - 조인(JOIN) : 정규화작업에 의해 나누어져 있음 -> 조회하기 위해서 join
-- 부서명 emp 테이블에 존재x
SELECT deptno, empno, ename, hiredate
FROM emp;

SELECT deptno, dname, loc
FROm dept;
-- emp, dept 테이블 결합(join) + WHERE 조건절을 사용해서 조인 조건
SELECT emp.deptno, dname, empno, ename, hiredate ㅅ
FROM emp, dept
WHERE emp.deptno = dept.deptno; -- 보통 pk=fk
--ORA-00918: column ambiguously defined - 겹치는 속성, 누구건지
-- JOIN ~ ON 구문 : ON 뒤에 조인 조건
SELECT e.deptno, dname, empno, ename, hiredate
FROM emp e JOIN dept d ON e.deptno = d.deptno;


-- 관계형 데이터 모델 : 확장성, 유지보수력 높음
--[테이블]  관계  [테이블]  관계  [테이블]
사원(EMP) 테이블 생성한다고 가정
사원번호, 사원명, 입사일자, 부서번호, 부서명, 잡, 직급, 부서내선번호, 부서장 등 있어야 함을 분석 

정규화 과정 거쳐 테이블 쪼개기
[사원테이블]
사원번호 사원명 입사일자  잡 직급  부서번호 ( 부서테이들의 부서번호(PK) 참조 ) -> 참조키(외래키)(FK)
 8972   홍길동 97//    점 대리    10
 8972   홍길동 97//    점 대리    20  
 8972   홍길동 97//    점 대리    :
 8972   홍길동 97//    점 대리 
 8972   홍길동 97//    점 대리 
 8972   홍길동 97//    점 대리 
 8972   홍길동 97//    점 대리 
 8972   홍길동 97//    점 대리 

[부서테이블] 부모테이블
PK                          --중복 안되는 것 PK, or 복합키
부서번호 부서명 부서장 내선번호

--
--[SET(집합) 연산자]
-- 1) UNION / UNION ALL 연산자 (합집합)
SELECT  name, city, buseo --, COUNT(*) -- 집계함수와 일반칼럼 같이 사용할 수 없음
FROm insa
WHERE buseo = '개발부' -- 14명
--UNION -- 17개 출력, 중복X
UNION ALL -- 중복 O
SELECT name, city, buseo
FROM insa
WHERE city = '인천'; -- 9명

SELECT COUNT(*)
FROm insa
WHERE city = '인천' AND buseo = '개발부';


-- ( 주의 사항 ) -- 칼럼개수, mapping 자료형만 맞으면 UNION 됨, 첫번째 쿼리 칼럼 명 따름
SELECT ename, hiredate, null gender
FROm emp
UNION
SELECT name, ibsadate, SUBSTR(ssn, -7.1)gender
FROm insa;

-- [문제] emp
--        UNION
--       insa
--              사원명, 입사일자, 부서명
DESC emp;
DESC insa;

-- ORA-01790: expression must have same datatype as corresponding expression
SELECT ename, hiredate, dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
UNION
SELECT name, ibsadate, buseo
FROM insa;

--[2] 상관 서브쿼리
SELECT ename, hiredate, (SELECT dname FROM dept WHERE deptno = e.deptno) dname
FROM emp e
UNION
SELECT name, ibsadate, buseo
FROM insa i;

-- INTERSECT
SELECT  name, city, buseo 
FROm insa
WHERE buseo = '개발부' 
INTERSECT -- 개발부인 동시에 인천 사는 사원정보

SELECT name, city, buseo
FROM insa
WHERE city = '인천'; 

-- MINUS
SELECT  name, city, buseo 
FROm insa
WHERE buseo = '개발부' 
MINUS
SELECT name, city, buseo
FROM insa
WHERE city = '인천'; 

----------------------------------------------------------------
--nested -> 중첩
----------------
[계층적 질의 연산자 ]
PRIOR, CONNECT_BY_ROOT 연산자

----------------------------------
--[오라클 함수]
-- 복잡한 쿼리문을 간단하게 해주고, 데이터의 값을 [조작]하는데 사용되는 것.
-- 자바: 주민등록번호 입력받아서 나를 계산해서 반환
SELECT name, ssn
        , UF_AGE(ssn, 0) 만나이  -- PL/SQL 사용자 정의 함수 UF_AGE
        , UF_AGE(ssn, 1) 세는나이
FROM insa;

-----------
-- [ 오라클 함수 : 단일행 함수, 복수행 함수(다수 열 -> 한 개) ]
-- 복수행 함수 ( 그룹함수 )
SELECT COUNT(ename)
FROM emp;
-- 단일행 함수
SELECT LOWER(ename) -- 한 개 레코드당 한개의 결과
FROM emp;

-- ORA-00937: not a single-group group function
SELECT LOWER(ename), COUNT(ename)
FROM emp;
--
SELECT LOWER(ename), (SELECT COUNT(ename) FROm emp )cnt
FROM emp;

--------
-- [ 숫자 함수 ]
SELECT SIGN(123), SIGN(-10), SIGN(0)
FROM dual;

SELECT ename, pay, avgpay, SIGN(pay - avgpay)
FROM (
            SELECT ename, sal+NVL(comm,0) pay
            , (SELECT AVG(sal+NVL(comm,0))FROM emp)avgpay
            FROm emp
            )e
WHERE SIGN(pay - avgpay) = 1; -- 평균보다 높은 사람들

-----------
SELECT POWER(2,3), POWER(2,-3)
        ,SQRT(4), SQRT(2)
FROM dual;
------------
-- [문자 함수]
SELECT UPPER('Admin'), LOWER('Admin'), INITCAP('admin')
FROm dual;
----------
SELECT DISTINCT CONCAT( job, LENGTH(job))
FROm emp;

----------
-- ename 이름 속에 'I' 문자가 있는 위치 파악
SELECT ename
    , INSTR (ename, 'I')
    , INSTR (ename, 'AM')
FROm emp;

SELECT 'ABCDEABCDEABCDE'
        , INSTR (  'ABCDEABCDEABCDE' , 'C', 1,2) -- 앞에서부터 두번째 위치
        , INSTR (  'ABCDEABCDEABCDE' , 'C', -1,1) -- 뒤에서부터 첫번째 위치
FROM dual;
-----------
SELECT *
FROM tbl_tel; 02)123-1234
-- [ 문제 ] 지역번호만 뽑아와서 출력. / 앞자리 / 뒷자리 각각
SELECT  tel,
        , INSTR( tel, ')' )
        , INSTR( tel, '-' )
        , SUBSTR(tel, 1, INSTR(tel, ')')-1)지역번호
        , SUBSTR(tel, INSTR(tel, ')')+1, INSTR(tel, '-')-INSTR(tel, ')')-1)앞자리
        , SUBSTR(tel, INSTR(tel,'-')+1)뒷자리
FROM tbl_tel;

--(2) 풀이
SELECT tel
        , REGEXP_REPLACE(tel,'(\d+)\)(\d+)-(\d+)', '\1')
        , REGEXP_REPLACE(tel,'(\d+)\)(\d+)-(\d+)', '\2')
        , REGEXP_REPLACE(tel,'(\d+)\)(\d+)-(\d+)', '\3')
FROM tbl_tel;
-------------
--RPAD(), LPAD()
SELECT empno, ename|| RPAD(' ' , (SELECT MAX(LENGTH(ename)) from emp) - LENGTH(ename)+1) || hiredate
FROM emp;

SELECT empno
        ,LEngTH(ename)
        ,LENGTH(hiredate)
        , RPAD(ename , (SELECT MAX(LENGTH(ename)) from emp)+3 ,' ') || hiredate
FROM emp;

select RTRIM('BROWING: ./=./=./=./=.=/.=', '/=.') "RTRIM example" 
from dual;

select RTRIM('BROWINGyxXxy','xy') "RTRIM example" from dual;

SELECT RPAD(sal, 10, '*')
        , REPLACE( RPAD(sal, 10, '*'), '*')
        , RTRIM(RPAD(sal, 10, '*'), '*')
FROM emp;

-- [문제] RTRIM(), LTRIM(), TRIM()
-- 형식: TRIM([trim_char FROM] string)
SELECT '[   ADMIN    ]' -- 문자열 앞뒤의 공백을 제거
    ,'['||LTRIM(RTRIM('   ADMIN    ', ' '), ' ')||']'
    , TRIM(BOTH ' ' FROM '   ADMIN    ')
FROM dual;
-------
SELECT ASCII('A'), ASCII('0')
        ,CHR(65), CHR(48)
FROM dual;

-- GREATEST/LEAST : 숫자 또는 문자
SELECT GREATEST(1,2,3,4,5), GREATEST('a','b','A','B','z') --ASCII
        , LEAST(1,2,3,4,5), LEAST('a','b','A','B','z') --ASCII
FROM dual;
------------
--VSIZE()
SELECT VSIZE('A'), VSIZE('한'), VSIZE(1)
FROM dual;

SELECT dname
        ,VSIZE(dname) || 'bytes'
        FROm dept;
        
SELECT name
        ,LENGTH(name)
        ,VSIZE(name)
FROM insa
WHERE num <1005;

------------
-- [날짜 함수]
-- [SYSDATE 함수 ] 날짜 + 시간/분/초 (출력이 안되는거지 가지고 있음)
-- 2025.03.21 (금) 00:00:00
--tO_CHAR : 날짜, 숫자를 원하는 형식으로 출력 
SELECT SYSDATE
        , TO_CHAR( SYSDATE, 'YYYY.MM.DD (DY) HH24:MI:SS' )
FROM dual;