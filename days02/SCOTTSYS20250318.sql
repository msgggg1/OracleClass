-- [SCOTT]
  -- 대상(테이블명, 뷰명)
SELECT *
FROM user_users;
FROM dba_users;
FROM all_users;

-- 
SELECT *
FROM tabs;  -- user_tables의 약어
FROM user_tables;

-- dept, emp, bonus, salgrade
SELECT *
FROM dept;

-- 테이블 구조 확인
DESC dept;  -- null : 값은 있는데 모른다. NOT NULL x -> 안적어도된다. 
-- 자료형 숫자 number(자리수, 실수 정수 모두), VARCHAR(바이트 크기 영어1, 한글3), 문자든, 문자열이든 앞뒤 홑따옴표''.

-- 20250318 ~ SCOTT 소유로 insa.sql 테이블 생성.

CREATE TABLE insa(
        num NUMBER(5) NOT NULL CONSTRAINT insa_pk PRIMARY KEY
       ,name VARCHAR2(20) NOT NULL
       ,ssn  VARCHAR2(14) NOT NULL
       ,ibsaDate DATE     NOT NULL
       ,city  VARCHAR2(10)
       ,tel   VARCHAR2(15)
       ,buseo VARCHAR2(15) NOT NULL
       ,jikwi VARCHAR2(15) NOT NULL
       ,basicPay NUMBER(10) NOT NULL
       ,sudang NUMBER(10) NOT NULL
);

INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1001, '홍길동', '771212-1022432', '1998-10-11', '서울', '011-2356-4528', '기획부', 
   '부장', 2610000, 200000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1002, '이순신', '801007-1544236', '2000-11-29', '경기', '010-4758-6532', '총무부', 
   '사원', 1320000, 200000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1003, '이순애', '770922-2312547', '1999-02-25', '인천', '010-4231-1236', '개발부', 
   '부장', 2550000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1004, '김정훈', '790304-1788896', '2000-10-01', '전북', '019-5236-4221', '영업부', 
   '대리', 1954200, 170000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1005, '한석봉', '811112-1566789', '2004-08-13', '서울', '018-5211-3542', '총무부', 
   '사원', 1420000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1006, '이기자', '780505-2978541', '2002-02-11', '인천', '010-3214-5357', '개발부', 
   '과장', 2265000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1007, '장인철', '780506-1625148', '1998-03-16', '제주', '011-2345-2525', '개발부', 
   '대리', 1250000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1008, '김영년', '821011-2362514', '2002-04-30', '서울', '016-2222-4444', '홍보부',    
'사원', 950000 , 145000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1009, '나윤균', '810810-1552147', '2003-10-10', '경기', '019-1111-2222', '인사부', 
   '사원', 840000 , 220400);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1010, '김종서', '751010-1122233', '1997-08-08', '부산', '011-3214-5555', '영업부', 
   '부장', 2540000, 130000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1011, '유관순', '801010-2987897', '2000-07-07', '서울', '010-8888-4422', '영업부', 
   '사원', 1020000, 140000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1012, '정한국', '760909-1333333', '1999-10-16', '강원', '018-2222-4242', '홍보부', 
   '사원', 880000 , 114000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1013, '조미숙', '790102-2777777', '1998-06-07', '경기', '019-6666-4444', '홍보부', 
   '대리', 1601000, 103000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1014, '황진이', '810707-2574812', '2002-02-15', '인천', '010-3214-5467', '개발부', 
   '사원', 1100000, 130000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1015, '이현숙', '800606-2954687', '1999-07-26', '경기', '016-2548-3365', '총무부', 
   '사원', 1050000, 104000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1016, '이상헌', '781010-1666678', '2001-11-29', '경기', '010-4526-1234', '개발부', 
   '과장', 2350000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1017, '엄용수', '820507-1452365', '2000-08-28', '인천', '010-3254-2542', '개발부', 
   '사원', 950000 , 210000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1018, '이성길', '801028-1849534', '2004-08-08', '전북', '018-1333-3333', '개발부', 
   '사원', 880000 , 123000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1019, '박문수', '780710-1985632', '1999-12-10', '서울', '017-4747-4848', '인사부', 
   '과장', 2300000, 165000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1020, '유영희', '800304-2741258', '2003-10-10', '전남', '011-9595-8585', '자재부', 
   '사원', 880000 , 140000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1021, '홍길남', '801010-1111111', '2001-09-07', '경기', '011-9999-7575', '개발부', 
   '사원', 875000 , 120000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1022, '이영숙', '800501-2312456', '2003-02-25', '전남', '017-5214-5282', '기획부', 
   '대리', 1960000, 180000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1023, '김인수', '731211-1214576', '1995-02-23', '서울', NULL           , '영업부', 
   '부장', 2500000, 170000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1024, '김말자', '830225-2633334', '1999-08-28', '서울', '011-5248-7789', '기획부', 
   '대리', 1900000, 170000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1025, '우재옥', '801103-1654442', '2000-10-01', '서울', '010-4563-2587', '영업부', 
   '사원', 1100000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1026, '김숙남', '810907-2015457', '2002-08-28', '경기', '010-2112-5225', '영업부', 
   '사원', 1050000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1027, '김영길', '801216-1898752', '2000-10-18', '서울', '019-8523-1478', '총무부', 
   '과장', 2340000, 170000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1028, '이남신', '810101-1010101', '2001-09-07', '제주', '016-1818-4848', '인사부', 
   '사원', 892000 , 110000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1029, '김말숙', '800301-2020202', '2000-09-08', '서울', '016-3535-3636', '총무부', 
   '사원', 920000 , 124000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1030, '정정해', '790210-2101010', '1999-10-17', '부산', '019-6564-6752', '총무부', 
   '과장', 2304000, 124000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1031, '지재환', '771115-1687988', '2001-01-21', '서울', '019-5552-7511', '기획부', 
   '부장', 2450000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1032, '심심해', '810206-2222222', '2000-05-05', '전북', '016-8888-7474', '자재부', 
   '사원', 880000 , 108000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1033, '김미나', '780505-2999999', '1998-06-07', '서울', '011-2444-4444', '영업부', 
   '사원', 1020000, 104000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1034, '이정석', '820505-1325468', '2005-09-26', '경기', '011-3697-7412', '기획부', 
   '사원', 1100000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1035, '정영희', '831010-2153252', '2002-05-16', '인천', NULL           , '개발부', 
   '사원', 1050000, 140000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1036, '이재영', '701126-2852147', '2003-08-10', '서울', '011-9999-9999', '자재부', 
   '사원', 960400 , 190000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1037, '최석규', '770129-1456987', '1998-10-15', '인천', '011-7777-7777', '홍보부', 
   '과장', 2350000, 187000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1038, '손인수', '791009-2321456', '1999-11-15', '부산', '010-6542-7412', '영업부', 
   '대리', 2000000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1039, '고순정', '800504-2000032', '2003-12-28', '경기', '010-2587-7895', '영업부', 
   '대리', 2010000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1040, '박세열', '790509-1635214', '2000-09-10', '경북', '016-4444-7777', '인사부', 
   '대리', 2100000, 130000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1041, '문길수', '721217-1951357', '2001-12-10', '충남', '016-4444-5555', '자재부', 
   '과장', 2300000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1042, '채정희', '810709-2000054', '2003-10-17', '경기', '011-5125-5511', '개발부', 
   '사원', 1020000, 200000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1043, '양미옥', '830504-2471523', '2003-09-24', '서울', '016-8548-6547', '영업부', 
   '사원', 1100000, 210000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1044, '지수환', '820305-1475286', '2004-01-21', '서울', '011-5555-7548', '영업부', 
   '사원', 1060000, 220000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1045, '홍원신', '690906-1985214', '2003-03-16', '전북', '011-7777-7777', '영업부', 
   '사원', 960000 , 152000);			
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1046, '허경운', '760105-1458752', '1999-05-04', '경남', '017-3333-3333', '총무부', 
   '부장', 2650000, 150000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1047, '산마루', '780505-1234567', '2001-07-15', '서울', '018-0505-0505', '영업부', 
   '대리', 2100000, 112000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1048, '이기상', '790604-1415141', '2001-06-07', '전남', NULL           , '개발부', 
   '대리', 2050000, 106000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1049, '이미성', '830908-2456548', '2000-04-07', '인천', '010-6654-8854', '개발부', 
   '사원', 1300000, 130000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1050, '이미인', '810403-2828287', '2003-06-07', '경기', '011-8585-5252', '홍보부', 
   '대리', 1950000, 103000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1051, '권영미', '790303-2155554', '2000-06-04', '서울', '011-5555-7548', '영업부', 
   '과장', 2260000, 104000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1052, '권옥경', '820406-2000456', '2000-10-10', '경기', '010-3644-5577', '기획부', 
   '사원', 1020000, 105000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1053, '김싱식', '800715-1313131', '1999-12-12', '전북', '011-7585-7474', '자재부', 
   '사원', 960000 , 108000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1054, '정상호', '810705-1212141', '1999-10-16', '강원', '016-1919-4242', '홍보부', 
   '사원', 980000 , 114000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1055, '정한나', '820506-2425153', '2004-06-07', '서울', '016-2424-4242', '영업부', 
   '사원', 1000000, 104000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1056, '전용재', '800605-1456987', '2004-08-13', '인천', '010-7549-8654', '영업부', 
   '대리', 1950000, 200000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1057, '이미경', '780406-2003214', '1998-02-11', '경기', '016-6542-7546', '자재부', 
   '부장', 2520000, 160000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1058, '김신제', '800709-1321456', '2003-08-08', '인천', '010-2415-5444', '기획부', 
   '대리', 1950000, 180000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1059, '임수봉', '810809-2121244', '2001-10-10', '서울', '011-4151-4154', '개발부', 
   '사원', 890000 , 102000);
INSERT INTO insa (num, name, ssn, ibsaDate, city, tel, buseo, jikwi, basicPay, sudang) VALUES
  (1060, '김신애', '810809-2111111', '2001-10-10', '서울', '011-4151-4444', '개발부', 
   '사원', 900000 , 102000);

COMMIT;

-- insa 테이블의 구조 확인
DESCRIBE insa;
DESC insa; --줄임말

-- SELECT 문 7개의 절 있다. --
WITH -- 처리순서 1
SELECT --6, *필수절
FROM -- 2 , *필수절
WHERE -- 3
GROUP BY -- 4
HAVING -- 5
ORDER BY -- 7

-- emp 테이블의 구조 확인 후 모든 사원 정보를 조회
; -- 의미없는 ; 자동 구역 분할
DESC emp; -- NUMBER(7,2) --> 7자리, 소수점 2자리 실수
SELECT * -- emp 테이블의 모든 칼럼
FROM emp; --FROM scott.emp;

-- emp 테이블에서 사원번호, 사원명, 입사일자 조회
SELECT empno,ename,hiredate -- select_list
FROM emp;

-- 권한 부여
GRANT 
CONNECT,RESOURCE -- 롤(role)
,UNLIMITED TABLESPACE -- 권한: 제한없이 공간 할당
TO SCOTT IDENTIFIED BY tiger;
-- 사용자 계정 수정
ALTER USER SCOTT DEFAULT TABLESPACE USERS;
ALTER USER SCOTT TEMPORARY TABLESPACE TEMP;

-- emp 테이블에서 사원번호, 사원명, 입사일자 조회
-- SELECT * , empno, ename, hiredate -- 바로 from절 찾아서 오류
-- SELECT empno, ename, hiredate
SELECT e.*, empno, ename, hiredate -- 암기
FROM emp e; -- emp 테이블명에 ALIAS(별칭) 주기

-- emp 테이블에서 잡(job) 칼럼만 출력/조회.
-- emp 테이블에서 job의 종류만 조회 ( 중복된 잡은 제거 )
SELECT DISTINCT job
FROM emp;
-- (주의)
SELECT DISTINCT ename, job; -- 둘다 다른거
FROM emp;
-- 
-- SELECT ename, job; -- ALL 생략 
SELECT ALL ename, job; -- 잘 안씀
FROM emp;

-- emp 테이블의 사원수 조회 : COUNT() 함수
SELECT COUNT(*) 총사원수 -- AS
FROM emp;

-- [문제] emp 테이블에서 사원들의 잡의 종류가 몇개인지
SELECT COUNT(DISTINCT job)
FROM emp;

-- emp 테이블의 사원번호, 사원명, 입사일자 조회
--                     YY/MM/DD 
--             날짜형식 RR/MM/DD  ( YY/RR의 날짜 형식 차이점 파악 )
-- 7369	SMITH	'07/12/17' -- oracle 날짜와 -- 뒤에 홑따옴표 붙임
SELECT empno, ename, hiredate
FROM emp;

-- emp 테이블에서 모든 사원의 월급을 조회.
-- comm 이 null 인 사원 존재 -> pay 결과값 null
-- [해결] null 값 임시로 0으로 처리(null 처리)
--     NULL 처리하는 오라클 함수?
DESC emp;

-- 기본키 없으면 수정, 삭제 작업 불가 / 테이블에는 항상 기본키 한 개 이상 반드시 있어야 함. 
SELECT empno, ename
        , sal 
        --comm -- null 안받는게(0) 아니라 미확인 값.
        , NVL ( comm, 0 )
        , sal + NVL ( comm, 0 ) pay -- null 연산 -> 모든 결과 값 null
        , NVL ( sal + comm, sal ) pay
        , sal + NVL2(comm, comm ,0) pay
        , NVL2 ( comm, sal+comm, sal) pay
FROM emp;

-- [문제 ] emp 테이블에서 사원번호, 사원명, 직속상사 조회
--      직속상사가 null 사원의 mgr을 'CEO'라고 출력.
-- (해결) NULL 처리하는 코딩. NVL() 함수 
--          mgr   NUMBER(4) -> 문자열 변환
-- Java :  int i = 10;   ->  "10"    10+""
-- Oracle : mgr || ''  ,   함수
--        숫자 -> 문자열 변환 : TO_CHAR()
--        날짜 -> 문자열 변환 : TO_CHAR()

-- invalid number

SELECT empno, ename
            , mgr|| ''
            , NVL(mgr || '', 'CEO')
            , TO_CHAR(mgr)
            , NVL(TO_CHAR(mgr), 'CEO')
FROM emp;
-- 우측정렬: 숫자, 좌측정렬: 문자


-- emp 테이블에서 이름은 'SMITH'이고, 잡은 CLERK입니다. 
-- JAVA : System.out.printf("이름은 \"%s\"이고, 잡은 %s입니다.", name, job);
-- 홑따옴표 '' 두 개
SELECT '이름은 ' || CHR(39) || ename || '''이고, 잡은 ' || job || '입니다.'
FROM emp;

SELECT 39, CHR(39)
FROM emp;

-- [문제 ] emp 테이블에서 10번 부서 사원의 부서번호, 사원명, 입사일자 조회.
SELECT deptno, ename, hiredate
FROM emp
WHERE deptno = 10; -- 오라클의 같다 연산자 =    // 조건절: 참이면 처리
-- 자바
--for( int i=0; i<12; i++){
--     if( emps[i].deptno == 10 ){
--         syso(부서번호, 사원명, 입사일자)
--     }
--}

-- [문제 ] emp 테이블에서 10번 부서가 아닌 사원의 부서번호, 사원명, 입사일자 조회.
SELECT deptno, ename, hiredate
FROM emp
-- JAVA : WHERE deptno == 20 || deptno == 30 || deptno == 40;
-- Oracle 논리연산자
WHERE NOT deptno IN (20,30,40); -- 논리연산자 not 얘는 다른코딩
WHERE deptno NOT IN (20,30,40); -- sql 연산자 not
WHERE deptno IN (20,30,40);
WHERE NOT deptno = 10; -- NOT 논리연산자
WHERE deptno ^= 10; -- 비교연산자
--WHERE deptno <> 10;
--WHERE deptno != 10;

-- DEPT 부서테이블에 부서번호 개수 확인
SELECT *
FROM emp
WHERE deptno=20 OR deptno=30 OR deptno = 40; -- 332,333과 내부적으로 처리과정 같음. -> 같은 코딩

-- [문제] insa 테이블에서 출신지역이 수도권인 사원
DESC insa; --VARCHAR2

--SELECT COUNT(*)
SELECT *
FROM insa
WHERE city IN('서울','경기','인천');
WHERE city = '서울' or city = '경기' or city = '인천';
-- [문제] insa 테이블에서 비수도권 사원 정보 조회.
SELECT *
FROM insa
WHERE city != '서울' AND city != '경기' AND city != '인천';
WHERE NOT(city = '서울' OR city = '경기' OR city = '인천');
WHERE city NOT IN('서울','경기','인천');

-- (기억)
-- [문제] emp 테이블에서 사원명이 'ford'인 사원의 모든 사원정보를 출력
-- Java : STring.toUpperCase();
DESC emp; -- VARCHAR2(10) 

SELECT *
FROM emp
WHERE ename IN (UPPER(:ename)); -- 바인더함수 LOWER()
WHERE ename IN (UPPER('ford')); -- 비밀번호, 문자열 검색 시에는 대소문자 구분함. 

--
SELECT ename
        ,LOWER(ename)
        ,UPPER(ename)
        ,INITCAP(ename) -- 첫번째 한 문자만 대문자
FROM emp;

-- (기억) is null, is not null SQL 연산자 사용
-- [문제] emp 테이블에서 comm이 null인 사원 정보 조회
SELECT *
FROM emp
WHERE comm IS NOT NULL;
WHERE comm IS NULL;

-- [문제] emp 테이블에서 월급(pay = sal + comm)이 2000 이상 4000 이하 사원정보
--          (  부서번호, 사원명, 잡, 월급 )
-- [1]
SELECT deptno, ename ,  sal + NVL(comm, 0)  pay
FROM emp 
WHERE sal + NVL(comm, 0) >= 2000 AND sal + NVL(comm, 0) <= 4000;
--[2]
SELECT deptno, ename, job, sal + NVL(comm,0) pay
FROM emp e 
WHERE sal + NVL(comm,0) BETWEEN 2000 AND 4000;

-- [3] WITH 절 사용
--      : 공통 테이블 표현식(CTE) 정의 시 사용. 가독성, 재사용성 높임
WITH emp_pay AS (SELECT deptno, ename, job, sal + NVL(comm,0) pay
FROM emp
)
SELECT *
FROM emp_pay
WHERE pay between 2000 AND 4000;
--??? AS () 필요시 더 
--??? AS ()
-- [4] 인라인뷰 ( inline view ) 사용 
-- FROM ( subquery ) 별칭(alias) / FROM 절 뒤 서브쿼리 -> 인라인뷰
SELECT temp.* -- *도 가능
FROM (
    SELECT deptno, ename, job, sal + NVL(comm,0) pay
    FROM emp
)temp
WHERE pay between 2000 AND 4000; --temp.pay 상관없음