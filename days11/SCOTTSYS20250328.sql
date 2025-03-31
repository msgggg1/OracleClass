--SCOTT--
drop table tbl_emp purge;
--
create table tbl_emp(
  id number primary key, 
  name varchar2(10) not null,
  salary  number,
  bonus number default 100
);

insert into tbl_emp(id,name,salary) values(1001,'jijoe',150);
insert into tbl_emp(id,name,salary) values(1002,'cho',130);
insert into tbl_emp(id,name,salary) values(1003,'kim',140);
commit;
select * from tbl_emp;

create table tbl_bonus(
    id number
    , bonus number default 100
);

insert into tbl_bonus(id) (select e.id from tbl_emp e);
select *
from tbl_bonus;

insert into tbl_bonus values(1004, 50);
commit;

-- MERGE(병합) : tbl_bonus(id,bonus) <- tbl_emp (id, bonus)     name,salary x
【형식】
    MERGE [hint] INTO [schema.] {table ¦ view} [t_alias]
      USING {{[schema.] {table ¦ view}} ¦
            subquery} [t_alias]
      ON (condition) [merge_update_clause] [merge_insert_clause] [error_logging_clause];
    
MERGE INTO tbl_bonus b 
USING (select id, salary from tbl_emp) e
ON (b.id = e.id)
WHEN MATCHED THEN
    UPDATE SET b.bonus = b.bonus + e.salary * 0.1
WHEN NOT MATCHED THEN
    INSERT (b.id, b.bonus) VALUES (e.id, e.salary * 0.01);
    
select *
from tbl_bonus;

-- [제약 조건(constraints)]
-- 1) user_constraints 뷰 - 제약조건 확인
select *
from user_constraints
where table_name = 'EMP';
-- P(PK_EMP)        ,   R(FK_DEPTNO)

--2) 제약조건 정의
-- : 데이터 무결성 위해 테이블에 행(레코드)를 추가, 수정, 삭제할 때 적용되는 규칙
-- 데이터 추가
INSERT into emp (empno,deptno) values(9999, 90); -- 잘못된 데이터저장 막기위해(데이터 무결성)
-- 데이터 삭제
delete from dept where deptno = 10; --
-- 데이터 수정
update emp SEt deptno = 90 where empno = 7369;

insert into emp (empno) values (9999);
select * from emp;
roll back;
insert into emp (empno) values (7369); -- 유일성 제약조건 위배

-- 데이터 무결성 3가지
-- 1) 개체 무결성
-- 2) 참조 무결성
-- 3) 도메인 무결성

-- [ 급여 지급 테이블 ]
-- 사번 + 지급일자 고유키(PK) -> 복합키 / PK 역정규화 - 필요없는데 추가된 칼럼
사번  지급일자        지급액             순번
1     2025/01/23    5,000,-
[2]   2025/01/23    2,000,-
:
UPDATE 급여 지급 테이블
SET 지급액 = 2500000
WHErE 사번 = 2 AND 지급일자 = '2025/01/23'
-- WHERE 지급일자 = '2025/01/23';
-- WHERE 사번 = 2;
변경 시 지급일자, 사번 둘다 필요함. 

-- [ 제약조건 생성]
1) 테이블 생성 ( CREATE TABLE)
    (1) COLUMN LEVEL 방식 제약조건 추가 
    (2) TABLE LEVEL 방식 제약조건 추가
    
2) 테이블 수정 ( ALTER TABLE)

-- [ 제약 조건 5가지 종류 ]
1) PRIMARY KEY ( PK ) -- 고유한 키 예) emp의 empno = UK(유일성) + NN
2) FOREIGN KEY ( FK ) -- 외래키(FK)                 참조키
--                       참조하는 키                 참조되는 키 (PK임)
--                       emp(daptno) 10-40, null    dept 의 (deptno PK) 10/20/30/40
--                      -> 꼭 부모키와 같은 이름 아니어도 됨
3) UNIQUE KEY ( UK )  폰번호/주민등록번호/사번/이메일 등
4) NOT NULL ( NN )    반드시 입력 ( 필수 입력 )
    예) 회원 가입 ( 필수 입력 항목 )
5) CHECK( CK ) 
    예)  kor NUMBER(3) -999~999      CK  kor BETWEEN 0 AND 100
    INSERT, UPDATE kor = 111
;
-- 실습 --
-- tbl_constraint 테이블 생성
-- 1) 확인
select *
from tabs
where regexp_like (table_name, 'tbl_con%', 'i');

-- 2) 테이블 생성
create table tbl_constraint
(
    empno number(4)
    , ename varchar2(20)
    ,deptno number(2)
    ,kor number(3)
    ,email varchar(250)
    ,city varchar2(20)
);

INSERT into tbl_constraint (empno,ename, deptno, kor, email, city)
values (null, null, null, null, null, null);

INSERT into tbl_constraint (empno,ename, deptno, kor, email, city)
values (1111, '홍길동', null, null, null, null);

INSERT into tbl_constraint (empno,ename, deptno, kor, email, city)
values (1111, '서영학', null, null, null, null);
-- 개체 무결성 위반 (개체를 구분할 수 없음_)

update tbl_constraint
set ename = '정창기'
where empno = 1111; -- 문제) 2개다 업데이트

-- 
delete tbl_constraint
where empno = 1111; -- 둘 다 삭제

-- 제약조건 설정하지 않아서 발생한 문제 //

DROP table tbl_constraint;
-- 테이블 생성할 때  1) 컬럼레벨 

create table tbl_constraint
(
    --컬럼명 데이터타입 [ CONSTRAINT constraint명 ]  PRIMARY KEY
--    empno number(4) [CONSTRAINT PK_tbl_constraint_empno] 생략 가능PRIMARY KEY
--                      --> SYS 가 자동 부여 / 수정/삭제, 또는 제약조건 비활성화/활성화 시에 알고 있으면 좋긴함. 아니면 검색해서 찾기 
    empno number(4) NOT NULL CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY
    ,ename varchar2(20) NOT NULL
    -- dept 테이블의 deptno 칼럼을 참조하는 FK 설정
    -- 컬럼명 데이터타입 CONSTRAINT constraint명 REFERENCES 참조테이블명 (참조컬럼명)
    --          [ON DELETE CASCADE | ON DELETE SET NULL]
    ,deptno number(2) CONSTRAINT FK_tbl_constraint_deptno references dept(deptno)
    -- 컬럼명 데이터타입 CONSTRAINT constraint명 CHECK (조건)
    ,kor number(3) CONSTRAINT CK_tbl_constraint_kor_ CHECK (kor BETWEEN 0 AND 100)
    -- 컬럼명 데이터타입 CONSTRAINT constraint명 UNIQUE
    ,email varchar(250)  CONSTRAINT UK_tbl_constraint_email UNIQUE
    -- 서울, 부산, 인천 중에 1
    ,city varchar2(20) CONSTRAINT CK_tbl_constraint_city CHECK( city IN ('서울', '부산', '인천')) 
);


-- NN
insert into tbl_constraint (empno, ename, deptno, kor, email, city)
values (null, 'kims', 10, 90, 'kim@naver.com', '서울');
-- FK
INSERT INTO tbl_constraint (empno, ename, deptno, kor, email, city )
VALUES ( 1001, 'kim', 90, 90, 'kim@naver.com', '서울');
-- CK
INSERT INTO tbl_constraint (empno, ename, deptno, kor, email, city )
VALUES ( 1001, 'kim', 10, 190, 'kim@naver.com', '서울');
-- NN
INSERT INTO tbl_constraint (empno, ename, deptno, kor, email, city )
VALUES ( 1001, NULL, 10, 190, 'kim@naver.com', '서울');
-- CK
INSERT INTO tbl_constraint (empno, ename, deptno, kor, email, city )
VALUES ( 1001, 'LEE', 10, 190, 'kim@naver.com', '대전');

-- 
select *
FROM user_indexes
where regexp_like (table_name, 'TBL_CON'); --인덱스 자동 생성되어 있음
--

drop table tbl_constraint purge;

-- 테이블 생성할 때   2) 테이블 레벨 방법
-- NOT NULL 테이블 레벨 방식으로 설정할 수 없음.
-- 복합키는 테이블레벨 방식으로O, 컬럼레벨 방식으로X
create table tbl_constraint
(
    empno number(4)     NOT NULL 
    ,ename varchar2(20) NOT NULL
    ,deptno number(2) 
    ,kor number(3) 
    ,email varchar(250)  
    ,city varchar2(20) 
    
    , CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY (empno) 
    , CONSTRAINT FK_tbl_constraint_deptno FOREIGN KEY(deptno) references dept(deptno) 
    , CONSTRAINT CK_tbl_constraint_kor_ CHECK (kor BETWEEN 0 AND 100)
    , CONSTRAINT UK_tbl_constraint_email UNIQUE (email)
    , CONSTRAINT CK_tbl_constraint_city CHECK( city IN ('서울', '부산', '인천')) 
);

-- 제약조건 확인
select *
from user_constraints
WHERE table_name LIKE 'TBL_CON%';

-- [ 제약조건 수정 ]
-- 제약조건 수정할 수가 없다. ( 삭제 -> 새로 생성 )
-- 테이블을 삭제하면 그 안의 모든 제약조건도 함께 삭제된다.

-- [제약조건 삭제]
-- 1) PK 제약조건 삭제
ALTER TABLE tbl_constraint
DROP PRIMARY KEY;

ALTER TABLE tbl_constraint
DROP CONSTRAINT PK_tbl_constraint_empno;

-- email UK 제약조건 삭제
ALTER TABLE tbl_constraint
drop unique(email);
DROP CONSTRAINT UK_tbl_constraint_email;

-- [제약조건 2개 삭제 : PK, UK ]
-- 새로 제약조건 2개를 다시 추가
-- 테이블 생성이 완료된 후에 제약조건을 추가
alter table tbl_constraint
add (
    CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY(empno)
    , CONSTRAINT UK_tbl_constraint_email UNIQUE(email)
);

-- ADD COLUMN (컬럼들..)

-- 제약조건 비활성화/활성화
alter table 테이블명
enable constraint 제약조건명;
--
alter table 테이블명
disable constraint 제약조건명;


--      [  컬럼명 데이터타입 CONSTRAINT constraint명 ]
-- FK 제약조건을 설정할때 + 옵션
--	REFERENCES 참조테이블명 (참조컬럼명) 
--             [ON DELETE CASCADE | ON DELETE SET NULL]
-- 1) ON DELETE CASCADE
--    부모테이블의 참조키가 삭제될 때 자동으로 자식테이블의 참조한 레코드도 동시에 삭제

-- 2) ON DELETE SET NULL
--    부모테이블의 참조키가 삭제될 때 자동으로 자식테이블의 참조한 칼럼값은 NULL로 설정된다.

-- 실습 )
-- emp -> tbl_emp 생성
-- dept -> tbl_dept  생성

drop table tbl_emp;
drop table tbl_dept;

create table tbl_emp 
AS ( select * from emp );


create table tbl_dept 
AS ( select * from dept );

select *
from tbl_dept;

-- NN 외 제약 조건은 복사되지 않음. 
-- 테이블 생성 후에 제약 조건을 추가
-- 1) tbl_dept     deptno(PK)
ALTER table tbl_dept
ADD(
    CONSTRAINT PK_tbl_dept_deptno PRIMARY KEY (deptno)
);
-- tbl_emp      empno(PK)/  deptno(FK) + ON DELETE 옵션 추가 테스트
ALTER table tbl_emp
ADD(
    CONSTRAINT PK_tbl_emp_empno PRIMARY KEY (empno)
    , CONSTrAINT FK_tbl_emp_deptno FOREIGN KEY(deptno) REFERENCES tbl_dept(deptno)
);
--
DELETE FROM dept
where deptno = 30;
-- integrity constraint (SCOTT.FK_DEPTNO) violated - child record found
-- FK 제약조건 수정 X = 삭제 -> 추가


ALTER table tbl_emp
dROP constraint FK_tbl_emp_deptno;
-- 다시 추가
ALTER table tbl_emp
ADD(
    CONSTrAINT FK_tbl_emp_deptno FOREIGN KEY(deptno) 
--    REFERENCES tbl_dept(deptno) ON DELETE CASCADE
    REFERENCES tbl_dept(deptno) ON DELETE SET NULL
);
--
SELECT * FROM tbl_emp where deptno = 30; -- 6명
DELETE from tbl_dept
where deptno = 30;

rollback;


-- 조인(JOIN)            -- DB 모델링도구 eXERD

CREATE TABLE book(
       b_id     VARCHAR2(10)    NOT NULL PRIMARY KEY   -- 책ID
      ,title      VARCHAR2(100) NOT NULL  -- 책 제목
      ,c_name  VARCHAR2(100)    NOT NULL     -- c 이름
     -- ,  price  NUMBER(7) NOT NULL
 );
 
INSERT INTO book (b_id, title, c_name) VALUES ('a-1', '데이터베이스', '서울');
INSERT INTO book (b_id, title, c_name) VALUES ('a-2', '데이터베이스', '경기');
INSERT INTO book (b_id, title, c_name) VALUES ('b-1', '운영체제', '부산');
INSERT INTO book (b_id, title, c_name) VALUES ('b-2', '운영체제', '인천');
INSERT INTO book (b_id, title, c_name) VALUES ('c-1', '워드', '경기');
INSERT INTO book (b_id, title, c_name) VALUES ('d-1', '엑셀', '대구');
INSERT INTO book (b_id, title, c_name) VALUES ('e-1', '파워포인트', '부산');
INSERT INTO book (b_id, title, c_name) VALUES ('f-1', '엑세스', '인천');
INSERT INTO book (b_id, title, c_name) VALUES ('f-2', '엑세스', '서울');

COMMIT;

SELECT *
FROM book;

-- 
CREATE TABLE danga(
      b_id  VARCHAR2(10)  NOT NULL  -- PK , FK
      ,price  NUMBER(7) NOT NULL    -- 책 가격
      
      ,CONSTRAINT PK_danga_id PRIMARY KEY(b_id)
      ,CONSTRAINT FK_danga_id FOREIGN KEY (b_id) --PK인 동시에 FK
              REFERENCES book(b_id)
              ON DELETE CASCADE
);

--(사진1) DANGA 테이블 - 변동되는 책값 기록 남겨야할때

INSERT INTO danga (b_id, price) VALUES ('a-1', 300);
INSERT INTO danga (b_id, price) VALUES ('a-2', 500);
INSERT INTO danga (b_id, price) VALUES ('b-1', 450);
INSERT INTO danga (b_id, price) VALUES ('b-2', 440);
INSERT INTO danga (b_id, price) VALUES ('c-1', 320);
INSERT INTO danga (b_id, price) VALUES ('d-1', 321);
INSERT INTO danga (b_id, price) VALUES ('e-1', 250);
INSERT INTO danga (b_id, price) VALUES ('f-1', 510);
INSERT INTO danga (b_id, price) VALUES ('f-2', 400);

COMMIT;

SELECT *
FROM danga;
--

CREATE TABLE au_book(
       id   number(5)  NOT NULL PRIMARY KEY
      ,b_id VARCHAR2(10)  NOT NULL  CONSTRAINT FK_AUBOOK_BID
            REFERENCES book(b_id) --ON DELETE CASCADE, 책 여러권일 수 있음
      ,name VARCHAR2(20)  NOT NULL
);
INSERT INTO au_book (id, b_id, name) VALUES (1, 'a-1', '저팔개');
INSERT INTO au_book (id, b_id, name) VALUES (2, 'b-1', '손오공');
INSERT INTO au_book (id, b_id, name) VALUES (3, 'a-1', '사오정');
INSERT INTO au_book (id, b_id, name) VALUES (4, 'b-1', '김유신');
INSERT INTO au_book (id, b_id, name) VALUES (5, 'c-1', '유관순');
INSERT INTO au_book (id, b_id, name) VALUES (6, 'd-1', '김하늘');
INSERT INTO au_book (id, b_id, name) VALUES (7, 'a-1', '심심해'); -- 3명이 저자
INSERT INTO au_book (id, b_id, name) VALUES (8, 'd-1', '허첨');
INSERT INTO au_book (id, b_id, name) VALUES (9, 'e-1', '이한나');
INSERT INTO au_book (id, b_id, name) VALUES (10, 'f-1', '정말자');
INSERT INTO au_book (id, b_id, name) VALUES (11, 'f-2', '이영애');

COMMIT;

SELECT * 
FROM au_book;

-- 서점이 고객
CREATE TABLE gogaek(
      g_id       NUMBER(5) NOT NULL PRIMARY KEY 
      ,g_name   VARCHAR2(20) NOT NULL
      ,g_tel      VARCHAR2(20)
);
 
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (1, '우리서점', '111-1111');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (2, '도시서점', '111-1111');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (3, '지구서점', '333-3333');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (4, '서울서점', '444-4444');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (5, '수도서점', '555-5555');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (6, '강남서점', '666-6666');
INSERT INTO gogaek (g_id, g_name, g_tel) VALUES (7, '강북서점', '777-7777');

COMMIT;

SELECT *
FROM gogaek;

CREATE TABLE panmai(
       id         NUMBER(5) NOT NULL PRIMARY KEY
      ,g_id       NUMBER(5) NOT NULL CONSTRAINT FK_PANMAI_GID
                     REFERENCES gogaek(g_id) ON DELETE CASCADE
      ,b_id       VARCHAR2(10)  NOT NULL CONSTRAINT FK_PANMAI_BID
                     REFERENCES book(b_id) ON DELETE CASCADE
      ,p_date     DATE DEFAULT SYSDATE
      ,p_su       NUMBER(5)  NOT NULL
);



INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (1, 1, 'a-1', '2000-10-10', 10);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (2, 2, 'a-1', '2000-03-04', 20);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (3, 1, 'b-1', DEFAULT, 13);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (4, 4, 'c-1', '2000-07-07', 5);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (5, 4, 'd-1', DEFAULT, 31);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (6, 6, 'f-1', DEFAULT, 21);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (7, 7, 'a-1', DEFAULT, 26);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (8, 6, 'a-1', DEFAULT, 17);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (9, 6, 'b-1', DEFAULT, 5);
INSERT INTO panmai (id, g_id, b_id, p_date, p_su) VALUES (10, 7, 'a-2', '2000-10-10', 15);

COMMIT;

SELECT *
FROM panmai;         



-- 조인 ( join ) ~
-- [문제] 책ID, 책제목, 출판사(c_name), 단가 출력...
-- BOOK : b_id, title, c_name
-- DANGA: b_id, price
-- 1)
SELECT book.b_id, title, c_name, price
FROM book, danga
WHERE book.b_id = danga.b_id;

-- 2) 별칭, 컬럼명
SELECT b.b_id, title, c_name, price
FROM book b, danga d
WHERE b.b_id = d.b_id;

-- 3) JOIN ~ ON 구문
SELECT b.b_id, title, c_name, price
FROM book b JOIN danga d ON b.b_id = d.b_id;

-- 4) USING 문
SELECT b_id, title, c_name, price
FROM book JOIN danga USING(b_id);
-- USING() 절을 사용할 때는 객체명.컬럼명 또는 별칭명.컬럼명을 사용하지 않습니다. 

--5) NATURAL JOIN 구문 -- 객체명을 붙이지 않습니다.
SELECT b_id, title, c_name, price
FROM book NATURAL JOIN danga;

-- [문제] 책id, 제목, 판매수량, 단가, 서점명(g_name), 판매금액(p_su*price) 출력.
-- BOOK : b_id, title, 
-- DANGA: b_id, price
-- GOGAEK: g_name
-- PANMAI: p_su, g_name

SELECT b.b_id, title, p_su, price, g_name,p_su*price
FROM book b, danga d, panmai p, gogaek g
WHERE b.b_id = d.b_id AND b.b_id = p.b_id AND p.g_id = g.g_id;

-- USING() 절 수정
SELECT b_id, title, p_su, price, g_name,p_su*price
FROM book JOIN danga USING(b_id)
        JOIN panmai USING(b_id)
        JOIN gogaek USING(g_id);
        
-- JOIN ON 구문 수정
SELECT b.b_id, title, p_su, price, g_name,p_su*price
FROM book b JOIN danga d ON b.b_id = d.b_id
            JOIN panmai p ON b.b_id = d.b_id
            JOIN gogaek g ON p.g_id = g.g_id;

-- 출판된 책들이 각각 총 몇권이 판매되었는지 조회  
-- (    책ID, 책제목, 총판매권수, 단가 컬럼 출력   )

SELECT b.b_id, b.title, SUM(p_su), price
FROM book b JOIN danga d ON b.b_id = d.b_id
            JOIN panmai p ON b.b_id = p.b_id
GROUP BY b.b_id, b.title, price
ORDER BY b.b_id;


select *
from panmai;

select *
from book;

-- [ 추가문제 ] 총판매권수가 20권 이상인 책들의 정보만 출력
SELECT b.b_id, b.title, SUM(p_su), price
FROM book b JOIN danga d ON b.b_id = d.b_id
            JOIN panmai p ON b.b_id = p.b_id
GROUP BY b.b_id, b.title, price
HAVING SUM(p_su) >= 20
ORDER BY b.b_id, b.title, price;

-- [ 문제 ] 가장 많이 팔린 책 정보를 조회
-- ( 책ID, 제목, 단가, 총판매권수 )
-- 1) TOP-N 방식
SELECT t.*, ROWNUM
FROM (
    SELECT b.b_id, b.title, SUM(p_su)총판매권수, price
    FROM book b JOIN danga d ON b.b_id = d.b_id
                JOIN panmai p ON b.b_id = p.b_id
    GROUP BY b.b_id, b.title, price
    ORDER BY 총판매권수 DESC    
    )t
WHERE rownum <=1;

-- 2) 순위 함수 사용
-- RANK() OVER
WITH a AS(
    SELECT b.b_id, b.title, SUM(p_su)총판매권수, price
            , rank() OVER( ORDER BY SUM(p_su) DESC )순위
    FROM book b JOIN danga d ON b.b_id = d.b_id
                JOIN panmai p ON b.b_id = p.b_id
    GROUP BY b.b_id, b.title, price
    ORDER BY b.b_id, b.title, price
                )
SELECT *
FROM a
WHERE 순위 = 1;

-- [홍길동]
-- 1)
WITH temp AS (
    SELECT MAX(b.b_id) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_id
    FROM book  b JOIN  panmai p ON b.b_id = p.b_id
                 JOIN danga d ON b.b_id = d.b_id
    GROUP BY  b.b_id, title, price
)
SELECT b.b_id, title, sum(p_su), price
FROM book  b JOIN  panmai p ON b.b_id = p.b_id
            JOIN danga d ON b.b_id = d.b_id
WHERE b.b_id = (SELECT max_id FROM temp)
GROUP BY b.b_id, title, price;

-- 2)
SELECT MAX(b.b_id) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_id
       , MAX(b.title) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_id
       , MAX(price) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_id
       , MAX(sum(P_su)) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_id
    FROM book  b JOIN  panmai p ON b.b_id = p.b_id
                 JOIN danga d ON b.b_id = d.b_id
    GROUP BY  b.b_id, title, price;

-- [문제] book 테이블에서 한 번도 판매된 적이 없는 책의 정보 조회
-- ( 책id, 제목, 단가 )
SELECT b.b_id, title, price
FROM book  b LEFT JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
WHERE b.b_id IN (
    SELECT b_id FROM book -- 9권
    MINUS
    SELECT b_id FROM panmai
);
SELECT DISTINCT b.b_id, title, price
FROM book  b LEFT JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
WHERE b.b_id NOT IN (
    SELECT DISTINCT b_id FROM panmai
);

-- [문제] book 테이블에서 한 번이라도 판매된 적이 있는 책의 정보 조회
-- ( 책id, 제목, 단가 )
-- 안티조인(ANTI JOIN)
SELECT DISTINCT b.b_id, title, price
FROM book  b LEFT JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
WHERE b.b_id NOT IN (
    SELECT b_id FROM book
    MINUS
    SELECT b_id FROM panmai
);
SELECT DISTINCT b.b_id, title, price
FROM book  b LEFT JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
WHERE b.b_id IN (
    SELECT DISTINCT b_id FROM panmai
);

-- 세미조인(SEMI JOIN)
SELECT DISTINCT b.b_id, title, price
FROM book  b LEFT JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
WHERE EXISTS (
    SELECT DISTINCT p.b_id 
    FROM panmai p
    WHERE p.b_id = b.b_id
);

-- (홍길동)
SELECT b.b_id, title, price, p_su
FROM book b LEFT JOIN panmai p ON b.b_id = p.b_id
            LEFT JOIN danga d On b.b_id = d.b_id
--WHERE p_su IS NULL;
WHERE p_su IS NOT NULL;

-- [ 문제 ] 고객 중에 판매 횟수가 가장 많은 고객 정보 조회 top 1
-- 고객명, 판매횟수, 

SELECT g_name, 판매횟수
FROm(
    select g_name, count(*)판매횟수, RANK() OVER(ORDER BY COUNT(*) DESC)순위
    from panmai p JOIN gogaek g on p.g_id = g.g_id
    GROUP BY g_name
    )
where 순위 = 1;



select *
from panmai;

--년도, 월별 판매 현황 구하기
--
--년도   월        판매금액( p_su * price )
------ -- ----------
--2000 03       6000
--2000 07       1600
--2000 10      10500
--2021 11      41661
DESC panmai;

SELECT 년도, 월, SUM(p_su*price)판매금액
FROM(
    select TO_CHAR(p_date, 'YYYY')년도, To_char(p_date, 'MM')월, p_su, price
    from panmai p join danga d on p.b_id = d.b_id
)
GROUP BY 년도, 월
ORDER BY 년도, 월;

-- [문제] 25년도에 가장 판매가 많은 책 정보 조회(id, 제목, 책 수량) 
SELECT b_id, title, 책수량, 순위
FROM(
SELECT p.b_id, title, sum(p_su)책수량, RANK() OVER(ORDER BY sum(p_su) DESC)순위
FROM panmai p join book b on p.b_id = b.b_id
where to_char(p_date, 'YYYY') = '2025'
group by p.b_id, title
)
where 순위 = 1;


SELECT b.b_id, title , 책수량, 순위
FROM(
SELECT b_id, sum(p_su)책수량, RANK() OVER(ORDER BY sum(p_su) DESC)순위
FROM panmai 
where to_char(p_date, 'YYYY') = '2025'
group by b_id
)t JOIN book b ON t.b_id = b.b_id 
where 순위 <= 1;

-- [문제]
--서점별 판매현황 구하기
--
--서점코드  서점명  판매금액합  비율(소수점 둘째반올림)  
------------ -------------------------- ----------------
--7       강북서점   15300      26%
--4       서울서점   11551      19%
--2       도시서점   6000      10%
--6       강남서점   18060      30%
--1       우리서점   8850      15%

with a as(
    select g.g_id, g_name, sum(p_su*price)판매금액합
            , ( select sum(p_su*price) from panmai p JOIN danga d ON p.b_id = d.b_id)총판매금액   
    from panmai p join gogaek g on p.g_id = g.g_id
                    join danga d on p.b_id = d.b_id
    group by g.g_id, g_name
    ) 
SELECT g_id, g_name, 판매금액합, ROUND(판매금액합/총판매금액, 2)*100||'%' 비율
FrOm a 
ORDER BY 비율 DESC;


-- PL/SQL에서 변수로 처리 --------------------------------------------------------
( select sum(p_su*price) from panmai p JOIN danga d ON p.b_id = d.b_id )총판매금액  
    select g.g_id, g_name, sum(p_su*price)판매금액합 
    from panmai p join gogaek g on p.g_id = g.g_id
                    join danga d on p.b_id = d.b_id
    group by g.g_id, g_name
--------------------------------------------------------------------------------


-- 뷰(View)
-- 계층적 질의
-- 데이터베이스 모델링 ( 세미프로젝트 5개 )
-- PL/SQL

-- FROM 테이블 또는 뷰
SELECT *
FROM user_tables; -- 뷰(view) 가상테이블, SELECT 쿼리만을 가짐


