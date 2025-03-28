-- SCOTT --
SELECT dept.*
    ,ROWID
FROM dept;
INSERT INTO dept VALUES ( 50, null, null);
INSERT INTO dept VALUES ( 60, null, null);
INSERT INTO dept VALUES ( 70, null, null);
commit;

DELETE FROM dept
WHERE deptno >= 50;

commit;

SELECT *
FROM dept;

--------------------------------------------------------------------------------
-- [테이블 생성, 수정, 삭제 ] --
--        DDL 문 - CREATE TABLE, ALTER TABLE, DROP TABLE
-- 테이블?
-- 실습) 테이블 생성
-- PK 아이디/이름/나이/연락처/생일/비고
-- 아이디  문자 VARCHAR2(10) 크기(SIZE) -- 6자리 이상 -> 나중에 체크제약조건(CK)            보통  자료형 하나로 통일함
-- 이름   문자 VARCHAR2(20)
-- 나이   숫자 NUMBER(3)                                                CK             float 내부적으로 NUMBER로 처리됨
-- 전화번호 문자 VARCHAR2(20)    x추후 수정시 추가
-- 생일   날짜 DATE/TIMESTAMP(6) 두개만 생각 -> DATE
-- 비고   문자 VARCHAR2(255)    x추후 수정시 추가

DROP TABLE table_sample PURGE;   -- 있는지 먼저 확인
--GRANT CONNECT(롤),RESOURCE(롤),UNLIMITED TABLESPACE(권한) TO SCOTT IDENTIFIED BY tiger;

CREATE TABLE tbl_sample
( 
        id VARCHAR2(10) 
       , name VARCHAR2(20)
       , age NUMBER(3)
       ,birth DATE
); 
-- Table TABLE_SAMPLE이(가) 생성되었습니다.
SELECT *
FROM tabs
WHERE table_name LIKE 'TBL\_S%' ESCAPE '\';
WHERE REGEXP_LIKE(table_name, '^tbl_s','i');
-- 
DESC tbl_sample;
-- 테이블 생성 -> 수정 :  전화번호, 비고 컬럼 추가.
-- DDL 문: ALTER TABLE 문 사용
SELECT *
FROM tbl_sample;

ALTER TABLE tbl_sample
ADD(
      tel VARCHAR2(20) -- DEFAULT '000-0000-0000'
    , bigo VARCHAR2(255)
);
-- Table TBL_SAMPLE이(가) 변경되었습니다.

-- [컬럼의 크기를 수정]
-- 비고 컬럼의 size(크기) 255 byte -> 100으로 수정 / null -> 가능, NOT null -> 확대만 가능
ALTER TABLE tbl_sample
MODIFY ( bigo VARCHAR2(100) );
-- Table TBL_SAMPLE이(가) 변경되었습니다.
DESC tbl_sample;
-- BIGO     VARCHAR2(100) 

-- [칼럼명을 수정]
-- bigo 칼럼명을 memo 컬럼명으로 수정
-- : 칼럼명 직접적 변경 불가능 -> 1) alias 이용하여 간접적으로 변경 , 별칭서라
--                            2)
--1)
SELECT name, bigo AS "memo"
FROM tbl_sample; -- ;
--2)
ALTER TABLE tbl_sample
RENAME COLUMN bigo TO memo;

--[컬럼 삭제] -- memo
ALTER TABLE tbl_sample
        DROP COLUMN memo; 
        
-- [tbl_sample 테이블이름 변경 : tbl_example ]
RENAME tbl_sample TO tbl_example;
--테이블 이름이 변경되었습니다.

-- [ 게시판 테이블 생성 + CRUD 등등 쿼리 작성 ]
DROP TABLE tbl_board PURGE;
CREATE TABLE tbl_board
(
    seq NUMBER(38) NOT NULL PRIMARY KEY     -- 제약조건, PK -> UK + NN, 따라서 NOT NULL 따로 안줘도 됨, 나중을 생각해서..
    , writer VARCHAR2(20) NOT NULL
    , password VARCHAR2(15) NOT NULL        -- 정규표현식 CK 제약조건
    , title VARCHAR2(100) NOT NULL
    ,content CLOB
    ,regdate DATE DEFAULT SYSDATE

);

-- 조회수 컬럼 추가  readed NUMBER(38) 기본값 0
ALTER TABLE tbl_board
ADD readed NUMBER(38) DEFAULT 0;

DESC tbl_board;

-- 게시판 새글 작성 INSERT 문--
INSERT INTO tbl_board (seq, writer, password, title, content ) --  , regdate, readed 안써도 입력됨 (기본값, 날짜)
VALUES (1, '홍길동', '1234', '환절기 건강 조심', null);
commit;
SELECT *
FROM tbl_board;

INSERT INTO tbl_board (seq, writer, password, title, content ) 
VALUES (2, '권태정', '1234', '밥 먹고 싶다', '배고프다');
INSERT INTO tbl_board (seq, writer, password, title, content ) --  , regdate, readed 안써도 입력됨 (기본값, 날짜)
VALUES (3, '김승효', '1234', '3', '3');
commit;
SELECT *
FROM tbl_board
ORDER BY seq DESC;

-- 시퀀스 번호 자동증가
-- 시퀀스 생성 + 순번 (seq) 1/2/3/4           활용) 제품번호 PA0001(seq)
CREATE SEQUENCE seq_tbl_board
        START WITH 4;
        
-- 시퀀스 생성 확인
SELECT *
FROM user_sequences;
FROM user_tables;

INSERT INTO tbl_board (seq, writer, password, title, content ) 
VALUES (seq_tbl_board.NEXTVAL, '서영학', '1234', '시퀀스 사용', '네 번째 게시글'); -- 뽑아올때 NEXTVAL
commit;
SELECT *
FROM tbl_board
ORDER BY seq DESC;

SELECT seq_tbl_board.CURRVAL -- 어디까지 썼나 확인할때 CURRVAL
FROm dual;

-- [ title 컬럼명 - subject 컬럼명 수정 ]
-- [ writer 컬럼 크기 20 -> 40 크기 확장 ]
--ALTER TABLE tbl_sample
--RENAME COLUMN bigo TO memo;
ALTER TABLE tbl_board
RENAME COLUMN title TO subject;

ALTER TABLE tbl_board
MODIFY writer VARCHAR(40) ;
-- [ 테이블 생성하는 방법 ]
-- 1. CREATE TABLE문 사용해서 테이블 생성
-- 2. 서브쿼리를 사용한 테이블 생성
--    ㄴ 기존 이미 존재하는 테이블을 이용해서 새로운 테이블 생성
--【형식】
--	CREATE TABLE 테이블명 [컬럼명 (,컬럼명),...]
--	AS subquery;

-- 예) emp 테이블에서 사원이 30번인 부서원들만 가져와서 새로운 tbl_emp30 테이블 생성
CREATE TABLE tbl_emp30 --(eno,name,ibsadate,job,pay) -- 이름 바꾸고 싶으면 다시 하나하나 주면됨
AS
SELECT empno, ename, hiredate, job, sal+NVL(comm,0)pay
FROM emp
WHERE deptno = 30;
--Table TBL_EMP30이(가) 생성되었습니다.
DESC tbl_emp30;
--이름       널? 유형           
---------- -- ------------ 
--EMPNO       NUMBER(4)    
--ENAME       VARCHAR2(10) 
--HIREDATE    DATE         
--JOB         VARCHAR2(9)  
--PAY         NUMBER    --> 알아서 최대로 잡음
-- 
SELECT *
FROM tbl_emp30;

-- [ 제약조건은 복사 안됨]
--1) emp 테이블 제약조건 확인
--2) tbl_emp30 테이블 제약 조건 확인
SELECT constraint_name, constraint_type, table_name
FROM user_constraints
WHERE table_name = 'TBL_EMP30';
WHERE table_name = 'EMP';

--alter table test   ☜ 제약조건 추가
--ADD CONSTRAINT test_deptno_pk PRIMARY KEY(deptno);
ALTER TABLE tbl_emp30
ADD CONSTRAINT pk_tbl_emp30_empno PRIMARY KEY(empno);
-- tbl_emp30 테이블 삭제
DROP TABLE tbl_emp30 PURGE;

-- 만약 서브쿼리를 사용해서 테이블을 생성할 떄 데이터(레코드)는 가져오고 싶지 않을떄(구조만 복사)
CREATE TABLE tbl_emp
AS 
    SELECT *
    FROM emp
    WHERE 1 = 0; -- 조건절 항상 거짓이 되도록
    
-- 
SELECT *
FROm tabs
WHERE table_name LIKE 'TBL_%';

DROP TABLE tbl_tel PURGE;
DROP TABLE tbl_pivot PURGE;

-- [문제] 
-- 1) empno, dname, ename, pay, deptno, grade, hiredate, mgr_name
--      컬럼들을 가진 새로운 tbl_emp 테이블 생성
-- 2) empno PK 제약조건 추가

CREATE TABLE tbl_emp
AS
SELECT e.empno, dname, e.ename, e.sal+NVL(e.comm,0)pay, d.deptno
        , grade 
        , e.hiredate
        , m.ename "mgr_name"
FROM emp e LEFT JOIN dept d ON e.deptno = d.deptno
            JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
            LEFT JOIN emp m ON e.mgr = m.empno
ORDER BY deptno ASC;

DROP TABLE tbl_emp PURGE;

-- 2) empno PK 제약조건 추가
ALTER TABLE tbl_emp
ADD PRIMARY KEY (empno);

-- 3)제약조건확인
SELECT *
FROM user_constraints
WHERE table_name = UPPER('TBL_EMP');
--4) 테이블 삭제
DROP TABLE tbl_emp PURGE;

--[ DML문 - INSERT ]  COMMIT< ROLLBACK 둘 중 하나 해야함
SELECT *
FROM emp;
DESC emp;
-- 
INSERT INTO emp (empno) VALUES (9999);
COMMIT;
--
INSERT INTO emp (empno, hiredate) VALUES (9998, TO_DATE('01/01/88', 'MM/DD/YY'));
--SQL 오류: ORA-01847: day of month must be between 1 and last day of month
INSERT INTO emp (empno, hiredate) VALUES (9997, TO_DATE('01/01/88', 'MM/DD/RR'));

update emp
set ename = 'admin', hiredate = sysdate
where empno = 9999;

-- [ RR/YY 차이점 ]
SELECT empno, hiredate
        , TO_char(hiredate, 'DS TS')
FROM emp
where empno >= 9000;

--
DELETE FROM emp
where empno >= 9000;
commit;

-- emp -> 구조만 복사해서 tbl_emp 생성
create table tbl_emp
as
    select *
    From emp
    where 1=0;
    
--
select *
from tbl_emp;
-- [INSERT] emp 테이블의 30번 부서원들 -> tbl_emp 테이블에 insert
-- (원래) insert into 테이블명     values (컬럼값..); 
 -- (+)서브쿼리로 insert 가능
insert into tbl_emp (
    select *
    from emp 
    where deptno = 30
);
commit;

-- 부분적인 컬럼만 INSERT
insert into tbl_emp (empno, ename) (
        select empno, ename
        from emp 
        where deptno = 20
);

commit;

-- 다중 INSERT 문
1) unconditional insert all 
    【형식】
	INSERT ALL | FIRST
	  [INTO 테이블1 VALUES (컬럼1,컬럼2,...)]
	  [INTO 테이블2 VALUES (컬럼1,컬럼2,...)]
	  .......
	Subquery;

CREATE TABLE tbl_emp10 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp20 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp30 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp40 AS ( SELECT * FROM emp WHERE 1=0 );

SELECT * FROM tbl_emp10;
SELECT * FROM tbl_emp20;
SELECT * FROM tbl_emp30;
SELECT * FROM tbl_emp40;
--
INSERT INTO tbl_emp10 (SELECT * FROM emp);
INSERT INTO tbl_emp20 (SELECT * FROM emp);
INSERT INTO tbl_emp30 (SELECT * FROM emp);
INSERT INTO tbl_emp40 (SELECT * FROM emp);
Rollback;
-- 
INSERT ALL 
    INTO tbl_emp10 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    INTO tbl_emp20 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    INTO tbl_emp30 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    INTO tbl_emp40 (empno,ename, job, mgr) VALUES (empno, ename, job, mgr)
SELECT *
FROM emp;

rollback;

2) conditional insert all : 조건이 있는 다중 insert 문

INSERT INTO tbl_emp10 (SELECT * FROM emp WHERE deptno = 10);
INSERT INTO tbl_emp20 (SELECT * FROM emp WHERE deptno = 20);
INSERT INTO tbl_emp30 (SELECT * FROM emp WHERE deptno = 30);
INSERT INTO tbl_emp40 (SELECT * FROM emp WHERE deptno = 40);
--
【형식】
	INSERT ALL
	WHEN 조건절1 THEN
	  INTO [테이블1] VALUES (컬럼1,컬럼2,...)
	WHEN 조건절2 THEN
	  INTO [테이블2] VALUES (컬럼1,컬럼2,...)
	........
	ELSE
	  INTO [테이블3] VALUES (컬럼1,컬럼2,...)
	Subquery;
--
INSERT ALL -- 만족하는 곳 다 들어감
    WHEN deptno = 10 THEN
        INTO tbl_emp10 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    WHEN deptno = 20 THEN
        INTO tbl_emp20 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    WHEN deptno = 30 THEN
        INTO tbl_emp30 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    ELSE -- 40
        INTO tbl_emp40 (empno,ename, job, mgr) VALUES (empno, ename, job, mgr)
SELECT *
FROM emp;

rollback;

3) conditional first insert 
SELECT * FROM tbl_emp10;
SELECT * FROM tbl_emp20;
SELECT * FROM tbl_emp30;
SELECT * FROM tbl_emp40;
--
INSERT FIRST -- 한번 걸리면 더 진행X
    WHEN deptno = 10 THEN
        INTO tbl_emp10 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    WHEN sal >= 1500 THEN
        INTO tbl_emp20 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    WHEN deptno = 30 THEN
        INTO tbl_emp30 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    ELSE -- 40
        INTO tbl_emp40 VALUES (empno, ename, job, mgr, hiredate, sal, comm, deptno)
SELECT *
FROM emp;
SELECT *
FROm emp;

4) pivoting insert 
create table tbl_sales(
    employee_id       number(6),
    week_id            number(2),
    sales_mon          number(8,2),
    sales_tue          number(8,2),
    sales_wed          number(8,2),
    sales_thu          number(8,2),
    sales_fri          number(8,2)
    );
    
insert into tbl_sales values(1101,4,100,150,80,60,120);
insert into tbl_sales values(1102,5,300,300,230,120,150);

SELECT *
FROM tbl_sales;

create table tbl_sales_data(
    employee_id        number(6),
    week_id            number(2),
    sales              number(8,2)
    );

SELECT *
FROM tbl_sales_data;

insert all -- unconditional insert all문과 동일
    into tbl_sales_data values(employee_id, week_id, sales_mon)
    into tbl_sales_data values(employee_id, week_id, sales_tue)
    into tbl_sales_data values(employee_id, week_id, sales_wed)
    into tbl_sales_data values(employee_id, week_id, sales_thu)
    into tbl_sales_data values(employee_id, week_id, sales_fri)
  select employee_id, week_id, sales_mon, sales_tue, sales_wed,
           sales_thu, sales_fri
  from tbl_sales;

DROP TABLE tbl_emp10 purge;
DROP TABLE tbl_emp20 purge;
DROP TABLE tbl_emp30 purge;
DROP TABLE tbl_emp40 purge;

DROP TABLE tbl_sales purge;
DROP TABLE tbl_sales_data purge;

-- DELETE 문 : DML 문,레코드 삭제 I,U,D + 커밋/롤백
--             WHERE  조건절 x, 모든 레코드 삭제
-- DROP TABLE 문: DDL 문 (C/A/D) 테이블 삭제
-- TRuncate 문 : 모든 레코드 삭제. 커밋/롤백x(오토 커밋)
-- 예) TRUNCATE TABLE 테이블명;

-- [문제] tbl_score 테이블 생성
--       insa 기존 있는 테이블의 num, name 칼럼을 복사해서 
--       num <= 1005
-- (조건: 서브쿼리를 사용해서 테이블 생성)
CREATE TABLE tbl_score 
AS(
    SELECT num,name
  FROM insa
  WHERE num <= 1005
);
-- 제약조건 복사 x
SELECT *
FROM tbl_score;
-- [문제] tbl_score의 제약조건을 확인하는 쿼리 작성
-- [문제] num 컬럼에 pk 제약조건을 설정하는 쿼리 작성

SELECT constraint_name, constraint_type, table_name -- NN 제약조건은 복사됨.
FROm user_constraints
WHERE table_name = UPPER('tbl_score');

ALTER TABLE tbl_score
ADD CONSTRAINTS pk_tbl_score_num PRIMARY KEY(num);


-- [문제] tbl_score 테이블에 kor, eng, mat, tot, avg, grade, rank 컬럼 추가
--                                                  CHAR(1 CHAR) , N(3)
ALTER TABLE tbl_score
ADD(
    kor NUMBER(3) DEFAULT 0
    ,eng NUMBER(3) DEFAULT 0
    ,mat number(3) DEFAULT 0
    ,tot number(3) DEFAULT 0
    ,avg number(5,2) DEFAULT 0
    ,grade char(1 CHAR) 
    ,rank number(3)
);

DESC tbl_score;

-- [문제] 1001~1005 (num) 모든 학생들의 국,영,수 점수만을 0~100사이의
-- 임의의 정수를 채워넣는 UPDATE 쿼리를 작성
SELECT *
FROM tbl_score;
-- 
SELECT ROUND(DBMS_RANDOM.VALUE*100) 
        ,trunc(DBMS_RANDOM.VALUE*101)
        ,floor(DBMS_RANDOM.VALUE*101)
        ,Floor(dbms_random.value(0,101))
FROM dual;

UPDATE tbl_score
SET kor = floor(DBMS_RANDOM.VALUE*101)
    , eng = floor(DBMS_RANDOM.VALUE*101)
    , mat = floor(DBMS_RANDOM.VALUE*101);

commit;

-- [문제] 1005번 학생의 국,영 점수가 1001번 학생의 국-1, 영-1 점수로 UPDATE
UPDATE tbl_score
SET kor = (SELECT kor -1 FROM tbl_score wHERE num=1001) 
    ,eng = (SELECT eng -1 FROM tbl_score wHERE num=1001) 
WHERE num = 1005;
--
UPDATE tbl_score
SET (kor,eng) = (SELECT kor -1, eng -1 FROM tbl_score wHERE num=1001)  
WHERE num = 1005;

commit;


SELECT *
FROM tbl_score;
-- [ 문제] 수학 1문제 정답이 없어서 모두 5점씩 추가 update
update tbl_score 
set mat =
    CASE
        WHEN mat >= 95 THEN 100
        ELSE             mat + 5
    END;

-- [문제] K,E,M,최종적 확인 -> 총점 / 평균 UPDATE
UPdate tbl_score
SET tot = kor +eng +mat
    , avg = (kor +eng +mat)/3;
    
    commit;
    
-- [문제] 등수 (rank 컬럼 ) 처리 UPDATE
SELECT num, tot
        , (SELECT COUNT(*)+1 FROm tbl_score WHERE s.tot<tot)
FROM tbl_score s;
--
SELECT num, tot
        , RANK() over(order by tot desc) r
FROM tbl_score
order by num;
-- [1]
UPDATE tbl_score s
SET rank = (SELECT COUNT(*)+1 FROm tbl_score WHERE s.tot<tot);

--[2]
UPDATE tbl_score s
SET rank = (
SELECT r
FROM(
    SELECT num, tot
        , RANK() over(order by tot desc) r
    FROM tbl_score
)
 WHERE num = s.num
);

commit;

-- [문제] 등급 수정
-- avg 90 이상 '수', 80 이상 '우', ~ '가'
UPDATE tbl_score
SET grade = CASE
                WHEN avg>=90 THEN '수'
                WHEN avg>=80 THEN '우'
                WHEN avg>=70 THEN '미'
                WHEN avg>=60 THEN '양'
                ELSE '가'
            END;

SELECT *
FROM tbl_score;
--[2] DECODE() 비교 = 만 사용
UPDATE tbl_score
SET grade = DECODE( TRUNC(avg/10), 10 , '수', 9, '수', 8, '우', 7, '미', 6, '양', '가');

UPDATE tbl_score
SET grade = CASE
                WHEN avg>=90 THEN '수'
                WHEN avg>=80 AND avg<90 THEN '우'
                WHEN avg>=70 AND avg<80 THEN '미'
                WHEN avg>=60 AND avg<70 THEN '양'
                ELSE '가'
            END;
            
rollback;

-- [3] 다중 INSERT 문 --UPDATE 안됨. INSERT  가능
INSERT FIRST
    WHEN avg >=90 THEN    
        INTO tbl_score(num, grade) VALUES(num,'수')
    WHEN avg >=80 THEN
        INTO tbl_score(num, grade) VALUES(num,'우')
    WHEN avg >=70 THEN
        INTO tbl_score(num, grade) VALUES(num,'미')
    WHEN avg >=60 THEN
        INTO tbl_score(num, grade) VALUES(num,'양')
    ELSE
        INTO tbl_score(num, grade) VALUES(num,'가')
SELECT avg
FROM tbl_score;

-- [문제] tbl_score 테이블에서 남학생들만 국어점수 10 감소. (UPDATE)
-- 문제점) tbl_score 테이블에는 성별을 구분할 수 있는 칼럼 x
--          insa 테이블의 ssn 가지고 성별 파악해서 UPDATE

update tbl_score s
set kor = case
                when kor -10 <0 then 0
                else kor-10
            end
where s.num = (
    select num
    from insa
    where mod(substr(ssn,-7,1),2)=1 and s.num = num
);
where num = any ( 
        select num
        from insa
        where mod(substr(ssn,-7,1),2)=1 and num <=1005
);
where num in (
        select num
        from insa
        where mod(substr(ssn,-7,1),2)=1 and num <=1005
);

SELECT *
FROM tbl_score;
-- 
rollback;
-- 
-- [문제] result 컬럼 추가 ('합격', '불합격', '과락')
-- 합격  : 평균 60점 이상, 40 미만 x
-- 불합격: 평균 60점 미만
-- 과락  : 40 미만

ALTER TABLE tbl_score
ADD result VARCHAR2(9);

UPDATE tbl_score
SET result = CASE
                WHEN avg >= 60 AND kor>=40 AND eng>=40 AND mat>=40 THEN '합격'
                WHEN avg < 60 THEN '불합격'
                ELSE '과락'
            END;

commit;

