-- SCOTT -- 
DROP TABLE tbl_emp PURGE;
--
CREATE TABLE tbl_emp(
    id number primary key, 
    name varchar2(10) not null,
    salary  number,
    bonus number default 100
);
-- Table TBL_EMP이(가) 생성되었습니다.
INSERT INTO tbl_emp(id,name,salary) VALUES (1001,'jijoe',150);
INSERT INTO tbl_emp(id,name,salary) VALUES(1002,'cho',130);
INSERT INTO tbl_emp(id,name,salary) VALUES(1003,'kim',140);
COMMIT;
Select * 
from tbl_emp;
--
CREATE TABLE tbl_bonus
(
  id number
  , bonus number default 100
);
-- Table TBL_BONUS이(가) 생성되었습니다.
INSERT INTO  tbl_bonus(id)
   (SELECT  e.id from tbl_emp e);
--
INSERT INTO tbl_bonus VALUES ( 1004, 50 );   
COMMIT;
SELECT * 
FROM tbl_bonus;
-- MERGE (병합) :  tbl_bonus(id, bonus) <- tbl_emp(id,bonus)   name,salary X
MERGE INTO tbl_bonus b 
USING ( SELECT id, salary FROM tbl_emp ) e
ON ( b.id = e.id )
WHEN MATCHED THEN
    UPDATE SET b.bonus = b.bonus + e.salary * 0.01
WHEN NOT MATCHED THEN
    INSERT (b.id, b.bonus) VALUES ( e.id, e.salary * 0.01 );
--
SELECT * 
FROM tbl_bonus;

-- [제약 조건(constraints)]
-- 1) user_constraints 뷰 - 제약조건 확인.
SELECT *
FROM user_constraints
WHERE table_name = 'EMP';
-- P( PK_EMP )   ,    R( FK_DEPTNO )

-- 2) 제약조건  ?
--   ㄴ  테이블에 행(레코드)를 추가,수정,삭제할 때 적용되는 규칙
--   ㄴ  데이터 무결성을 위해서.
-- 추가
INSERT INTO emp (empno, deptno) VALUES ( 9999, 90);
-- 삭제
DELETE FROM dept WHERE deptno = 10;
-- 수정
UPDATE emp SET  deptno = 90 WHERE empno = 7369;

INSERT INTO emp ( empno ) VALUES ( 9999 );
ROLLBACK;
INSERT INTO emp ( empno ) VALUES ( 7369 );
SELECT * FROM emp;
-- 데이터 무결성 3가지
-- 1) 개체
-- 2) 참조
-- 3) 도메인 

-- [급여 지급 테이블]
-- 사번  + 지급일자                       PK  역정규화.
사번  지급일자         지급액              순번
1    2025/01/23     5,000,-             1
[2]  2025/01/23     2,000,-             2  
:
UPDATE 급여 지급 테이블
SET 지급액 = 2500000
WHErE 사번 = 2 AND 지급일자 = '2025/01/23'
-- WHERE 지급일자 = '2025/01/23';
-- WHERE 사번 = 2;

-- [제약조건 생성]
1) 테이블 생성( CREATE TABLE) 
   (1) COLUMN LEVEL 방식 제약조건 추가
   (2) TABLE LEVEL 방식      "
   
2) 테이블 수정( ALTER TABLE)

-- [제약 조건 5가지 종류 ]
1) PRIMARY KEY ( PK ) -- 고유한 키  예) emp ( empno ) = UK (유일성) + NN ( NOT NULL )
2) FOREIGN KEY ( FK ) --     외래키                 참조키
--                          참조하는 키              참조되는 키
                            -- FK     
--                      emp( deptno )         dept ( deptno PK ) 10/20/30/40
--                        10~40, NULL
--                        KIING   NULL
3) UNIQUE KEY( UK)      폰번호/주민등록번호/사번/이메일 등등
4) NOT NULL  ( NN )     반드시 입력( 필수 입력 )
  예) 회원 가입  (  필수 입력 항목   ) 
5) CHECK      ( CK)  
  예)    kor Number(3)   -999~999       CK     kor BETWEEN 0 AND 100
  INSERT, UPDATE kor = 111 X
-- 실습 --
-- tbl_constraint  테이블 생성.
-- 1) tbl_constraint  테이블 확인  +  테이블 삭제
;
SELECT * 
FROM tabs
WHERE REGEXP_LIKE( table_name , '^TBL_CON');
-- 
CREATE TABLE tbl_constraint
(
     empno NUMBER(4)
   , ename VARCHAR2(20)
   , deptno NUMBER(2)
   , kor NUMBER(3)
   , email VARCHAR2(250)
   , city VARCHAR2(20)
);
-- 
INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( null, null, null, null, null, null );
-- 1 행 이(가) 삽입되었습니다.
INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( 1111, '홍길동', null, null, null, null );
INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( 1111, '서영학', null, null, null, null );
--
UPDATE tbl_constraint
SET ename = '정창기'
WHERE empno = 1111;
--
DELETE tbl_constraint
WHErE empno = 1111;

-- 제약조건 설정 X -- 
DROP TABLE tbl_constraint PURGE;
-- 테이블 생성할 때   1) 컬럼레벨 방법
CREATE TABLE tbl_constraint
(
    -- 컬럼명 데이터타입 [CONSTRAINT constraint명] PRIMARY KEY
    --             SYS_
    --  수정/삭제,  또는 제약조건 비활성화/활성화 -> 이름 
     empno NUMBER(4)  NOT NULL  CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY
     -- 11:03 수업시작~ 
   , ename VARCHAR2(20)  NOT NULL
   
   -- dept 테이블의 deptno 컬럼을 참조하는 FK 설정
   --  컬럼명 데이터타입 CONSTRAINT constraint명 REFERENCES 참조테이블명 (참조컬럼명)
   --        [ON DELETE CASCADE | ON DELETE SET NULL]
   , deptno NUMBER(2) CONSTRAINT FK_tbl_constraint_deptno REFERENCES  dept( deptno)
   --    컬럼명 데이터타입 CONSTRAINT constraint명 CHECK (조건) 
   , kor NUMBER(3)      CONSTRAINT CK_tbl_constraint_kor CHECK ( kor BETWEEN 0 AND 100)
   -- 컬럼명 데이터타입 CONSTRAINT constraint명 UNIQUE
   , email VARCHAR2(250)  CONSTRAINT UK_tbl_constraint_email UNIQUE
   -- 서울, 부산, 인천   중에 1
   , city VARCHAR2(20)  CONSTRAINT CK_tbl_constraint_city CHECK ( city IN ('서울','부산','인천'))
);
-- Table TBL_CONSTRAINT이(가) 생성되었습니다.
SELECT *
FROM user_constraints
WHERE REGEXP_LIKE(table_name, '^TBL_CON');
-- NN
INSERT INTO tbl_constraint (empno, ename, deptno, kor, email, city )
VALUES ( null, 'kim', 10, 90, 'kim@naver.com', '서울');
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
SELECT * 
FROM user_indexes
WHERE REGEXP_LIKE(table_name, '^TBL_CON');
-- 
DROP TABLE tbl_constraint PURGE;
-- 
-- 테이블 생성할 때   2) 테이블 레벨 방법
CREATE TABLE tbl_constraint
( 
     empno NUMBER(4)     NOT NULL  
   , ename VARCHAR2(20)  NOT NULL 
   , deptno NUMBER(2) 
   , kor NUMBER(3)      
   , email VARCHAR2(250)  
   , city VARCHAR2(20)  
   
   , CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY (empno)
   , CONSTRAINT FK_tbl_constraint_deptno FOREIGN KEY(deptno) REFERENCES  dept( deptno) 
   , CONSTRAINT CK_tbl_constraint_kor CHECK ( kor BETWEEN 0 AND 100) 
   , CONSTRAINT UK_tbl_constraint_email UNIQUE (email)
   , CONSTRAINT CK_tbl_constraint_city CHECK ( city IN ('서울','부산','인천'))
);
-- 제약조건 확인..
-- [제약조건 수정]
--  제약조건 수정할 수가 없다. ( 삭제 -> 생성 )
--  테이블을 삭제하면 그 안의 모든 제약조건도 함께 삭제된다. 

-- [제약조건 삭제]
-- 1) PK 제약조건 삭제
ALTER TABLE tbl_constraint 
DROP PRIMARY KEY;
--
ALTER TABLE tbl_constraint 
DROP CONSTRAINT PK_tbl_constraint_empno;
-- Table TBL_CONSTRAINT이(가) 변경되었습니다.
-- email UK 제약조건 삭제
ALTER TABLE tbl_constraint 
DROP UNIQUE(email);
DROP CONSTRAINT 제약조건명;
-- Table TBL_CONSTRAINT이(가) 변경되었습니다.

-- [제약조건 2개 삭제 : PK, UK ]
-- 새로 제약조건 2개를 다시 추가.. 
-- 테이블 생성이 완료된 후에   제약조건을 추가.
ALTER TABLE tbl_constraint
ADD (
      CONSTRAINT PK_tbl_constraint_empno PRIMARY KEY(empno)
     , CONSTRAINT UK_tbl_constraint_email UNIQUE(email)
);
-- Table TBL_CONSTRAINT이(가) 변경되었습니다.
--ADD ( COLUMN  컬럼들...);

-- 제약조건 비활성화/활성화
ALTER TABLE 테이블명
DISABLE CONSTRAINT 제약조건명;
-- 
ALTER TABLE 테이블명
ENABLE CONSTRAINT 제약조건명;

-- [         컬럼명 데이터타입 CONSTRAINT constraint명 ]
-- FK 제약조건을 설정할 때 + 옵션
-- 	REFERENCES 참조테이블명 (참조컬럼명) 
--           [ON DELETE CASCADE | ON DELETE SET NULL]  옵션 설명...
-- 1) ON DELETE CASCADE
--   부모테이블의 참조키가 삭제될때 자동으로 자식테이블의 참조한 레코드도 동시에 삭제.
-- 2) ON DELETE SET NULL
--   부모테이블의 참조키가 삭제될때 자동으로 자식테이블의 참조한 컬럼값은 NULL로 설정된다.

-- 실습)  서브쿼리를 사용해서 테이블 생성, 제약조건 복사 X, 모든 레코드는 복사.
-- emp -> tbl_emp 생성
-- dept -> tbl_dept 생성
DROP TABLE tbl_emp PURGE;
DROP TABLE tbl_dept PURGE;
-- 
CREATE TABLE tbl_emp 
AS
( SELECT * FROM emp );
-- Table TBL_EMP이(가) 생성되었습니다.
CREATE TABLE tbl_dept
AS
( SELECT * FROM dept );
-- Table TBL_DEPT이(가) 생성되었습니다.
SELECT * FROM tbl_emp;
SELECT * FROM tbl_dept;
-- NN 그 외 제약 조건은 X
-- 테이블 생성 후에 제약 조건을 추가.
-- 1) tbl_dept     deptno(PK)
ALTER TABLE tbl_dept
ADD ( 
    CONSTRAINT PK_tbl_dept_deptno PRIMARY KEY(deptno)
);
-- tbl_emp      empno(PK)/     deptno(FK) + ON DELETE 옵션 추가 테스트
ALTER TABLE tbl_emp
ADD ( 
      CONSTRAINT PK_tbl_emp_empno PRIMARY KEY(empno)
    , CONSTRAINT FK_tbl_emp_deptno FOREIGN KEY(deptno) REFERENCES tbl_dept(deptno)
);
--  ORA-02292: integrity constraint (SCOTT.FK_DEPTNO) violated - child record found
DELETE FROM dept
WHERE deptno = 30;
-- FK 제약조건 수정 X = 삭제 + 추가
ALTER TABLE tbl_emp
DROP CONSTRAINT FK_tbl_emp_deptno;
-- 다시 추가.
ALTER TABLE tbl_emp
ADD ( 
  CONSTRAINT FK_tbl_emp_deptno FOREIGN KEY(deptno) 
  -- REFERENCES tbl_dept(deptno) ON DELETE CASCADE
  REFERENCES tbl_dept(deptno) ON DELETE SET NULL
);
-- 
ROLLBACK;
--
SELECT * 
FROM tbl_emp 
WHERE deptno=30;
--
DELETE FROM tbl_dept
WHERE deptno = 30;
--
SELECT * 
FROM dept;

-- 조인(JOIN)--
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
      ,CONSTRAINT FK_danga_id FOREIGN KEY (b_id)
              REFERENCES book(b_id)
              ON DELETE CASCADE
);

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
            REFERENCES book(b_id) -- ON DELETE CASCADE
      ,name VARCHAR2(20)  NOT NULL
);
INSERT INTO au_book (id, b_id, name) VALUES (1, 'a-1', '저팔개');
INSERT INTO au_book (id, b_id, name) VALUES (2, 'b-1', '손오공');
INSERT INTO au_book (id, b_id, name) VALUES (3, 'a-1', '사오정');
INSERT INTO au_book (id, b_id, name) VALUES (4, 'b-1', '김유신');
INSERT INTO au_book (id, b_id, name) VALUES (5, 'c-1', '유관순');
INSERT INTO au_book (id, b_id, name) VALUES (6, 'd-1', '김하늘');
INSERT INTO au_book (id, b_id, name) VALUES (7, 'a-1', '심심해');
INSERT INTO au_book (id, b_id, name) VALUES (8, 'd-1', '허첨');
INSERT INTO au_book (id, b_id, name) VALUES (9, 'e-1', '이한나');
INSERT INTO au_book (id, b_id, name) VALUES (10, 'f-1', '정말자');
INSERT INTO au_book (id, b_id, name) VALUES (11, 'f-2', '이영애');

COMMIT;

SELECT * 
FROM au_book;

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
-- DANGA : b_id, price
-- 1)
--SELECT book.b_id, book.title, book.c_name, dnaga.pricae
;
SELECT book.b_id, title,  c_name,  price
FROM book , danga
WHERE book.b_id  = danga.b_id;

-- 2) 별칭.컬럼명
SELECT b.b_id, title,  c_name,  price
FROM book b, danga d
WHERE b.b_id  = d.b_id;

-- 3) JOIN ~ ON 구문
SELECT b.b_id, title,  c_name,  price
FROM book b JOIN  danga d ON  b.b_id  = d.b_id;

-- 4) USING 문
SELECT b_id, title,  c_name,  price
FROM book JOIN danga USING(b_id);
-- USING() 절을 사용할 때는 객체명.컬럼명 또는 별칭명.컬럼명을 사용하지 않습니다. 

-- 5) NATURAL JOIN 구문  -- 객체명을 붙이지 않습니다. 
SELECT b_id, title, c_name, price
FROM book NATURAL JOIN danga;

-- [문제] *책id, *제목, 판매수량, *단가, 서점명(g_name), 판매금액( p_su * price) 출력.
-- BOOK : b_id, title, 
-- DANGA : b_id, price
-- GOGAEK : g_name
-- PANMAI : p_su, g_name

SELECT b.b_id, title, p_su, price, g_name , p_su*price 
FROM book b, danga d, panmai p, gogaek g
WHERE b.b_id = d.b_id AND b.b_id = p.b_id AND  p.g_id = g.g_id;
-- USING() 절 수정.
SELECT b_id, title, p_su, price, g_name , p_su*price 
FROM book JOIN danga  USING(b_id)
          JOIN panmai USING(b_id)
          JOIN gogaek USING(g_id);
-- JOIN ON 구문 수정.
SELECT b.b_id, title, p_su, price, g_name , p_su*price 
FROM book b JOIN danga  d ON b.b_id = d.b_id
          JOIN panmai p ON b.b_id = p.b_id
          JOIN gogaek g ON p.g_id = g.g_id;
          
-- [문제] 출판된 책들이 각각 총 몇권이 판매되었는지 조회  
--  (    책ID, 책제목, 총판매권수, 단가 컬럼 출력   )
-- BOOK : b_id, title
-- PANMAI : p_su  판매권수
SELECT b.b_id, title, SUM( p_su ), price
FROM book  b JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
GROUP BY  b.b_id, title, price
ORDER BY  b.b_id;

--  [추가문제] 총판매권수가 20권 이상인 책들의 정보만 출력.
  --    ( HAVING 절 질문 )
SELECT b.b_id, title, SUM( p_su ), price
FROM book  b JOIN  panmai p ON b.b_id = p.b_id
             JOIN danga d ON b.b_id = d.b_id
GROUP BY  b.b_id, title, price
HAVING SUM( p_su ) >= 20
ORDER BY  b.b_id;

-- [문제] 가장 많이 팔린 책 정보를 조회...
-- ( 책ID, 제목, 단가, 총판매권수 )
-- 1) TOP-N 방식
--    정렬
--    ROWNUM 의사컬럼.
SELECT t.*, ROWNUM
FROM (
    SELECT b.b_id, title, SUM( p_su )  t_psu, price
    FROM book  b JOIN  panmai p ON b.b_id = p.b_id
                 JOIN danga d ON b.b_id = d.b_id
    GROUP BY  b.b_id, title, price 
    ORDER BY   t_psu dESC
) t
WHERE ROWNUM = 1;

-- 2) 순위 함수 사용.
SELECT *
FROM (
    SELECT b.b_id, title, SUM( p_su )  t_psu , price
       , RANK() OVER(ORDER BY SUM( p_su ) DESC) 순위
    FROM book  b JOIN  panmai p ON b.b_id = p.b_id
                 JOIN danga d ON b.b_id = d.b_id
    GROUP BY  b.b_id, title, price 
) 
WHERE 순위 = 1;
-- (홍길동)
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
-- (2)
SELECT
    MAX(b.b_id) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_bid
  , MAX(b.title) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_bid
  , MAX(price) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_bid
  , MAX(sum(p_su)) KEEP (DENSE_RANK FIRST ORDER BY SUM(p_su) DESC ) max_bid
FROM book  b JOIN  panmai p ON b.b_id = p.b_id
                 JOIN danga d ON b.b_id = d.b_id
GROUP BY  b.b_id, title, price;

-- [문제] book 테이블에서 한 번도 판매가 된 적이 없는 책의 정보 조회...
-- ( 책id, 제목, 단가 )
-- 9권 BOOK
SELECT b_id, title
FROM book;
--7권 판매된 BOOK 
SELECT  DISTINCT b_id
FROM panmai;
-- 판매가 된 적이 없는 책 ID
-- 안티 조인( AntiJOIN)
SELECT b.b_id, title, price
FROM book b JOIN  danga d ON b.b_id = d.b_id
WHERE b.b_id NOT IN (
        SELECT b_id 
        FROM book
        MINUS
        SELECT  DISTINCT b_id
        FROM panmai
);

-- [문제] book 테이블에서 한 번이라도 판매가 된 적이 있는 책의 정보 조회...
-- ( 책id, 제목, 단가 )
SELECT b.b_id, title, price
FROM book b JOIN  danga d ON b.b_id = d.b_id
WHERE b.b_id NOT  IN (
        SELECT  DISTINCT b_id
        FROM panmai
);
-- 세미조인( SEMI JOIN )
SELECT b.b_id, title, price
FROM book b JOIN  danga d ON b.b_id = d.b_id
WHERE  EXISTS (
        SELECT  DISTINCT p.b_id
        FROM panmai p
        WHERE p.b_id = b.b_id
);
-- (홍길동)
SELECT DISTINCT b.b_id, title, price -- ,  p_su
FROM book b LEFT JOIN panmai p ON b.b_id = p.b_id
            LEFT JOIN danga  d ON b.b_id = d.b_id
WHERE p_su IS NOT  NULL       ;
WHERE p_su IS NULL       ;

-- [문제] 고객 중에 판매금액 X, 판매횟수 가장 많은 TOP 1 고객 정보 조회...
--      ( 고객명, 판매횟수 조회. )
-- ORA-00979: not a GROUP BY expression
-- ORA-00918: column ambiguously defined
SELECT *
FROM (
    SELECT g.g_id, g_name,  COUNT(*) 
         , RANK() OVER(ORDER BY  COUNT(*) DESC ) 판매횟수순위
    FROM panmai p JOIN gogaek g ON g.g_id = p.g_id
    GROUP BY g.g_id , g_name
) 
WHERE 판매횟수순위 <= 3;

-- [문제] 년도, 월별 판매 현황 구하기
--    년도   월     판매금액( p_su * price )
--    ---- -- ----------
--  2000	03	6000
--  2000	07	1600
--  2000	10	10500
--  2024	08	41661

-- 년도별 월별 group by 질문...
-- ORA-00979: not a GROUP BY expression
SELECT   TO_CHAR( p_date, 'YYYY') 년도
       , TO_CHAR( p_date, 'MM') 월
       , SUM(p_su * price)
FROM panmai p JOIN danga d ON p.b_id = d.b_id
GROUP BY TO_CHAR( p_date, 'YYYY'),  TO_CHAR( p_date, 'MM')
ORDER BY TO_CHAR( p_date, 'YYYY'),  TO_CHAR( p_date, 'MM')
;
-- [문제] 24년도에 가장 판매가 많은 책 정보 조회 ( id, 제목, 책 수량 )
--         올해에 
--SELECT * 
--FROM panmai;

-- ORA-00904: "P_DATA": invalid identifier
-- ORA-00979: not a GROUP BY expression
;
--SELECT TO_CHAR(p_date, 'YYYY'), SUM(p_su)
--FROM panmai
--GROUP BY TO_CHAR(p_date, 'YYYY')
--HAVING TO_CHAR(p_date, 'YYYY') =  '2024' ;  -- TO_CHAR( SYSDATE, 'YYYY');

-- ORA-00979: not a GROUP BY expression
SELECT b.b_id, title,  t_psu, 판매순위
FROM (
    SELECT b_id, SUM(p_su) t_psu
       , RANK() OVER( ORDER BY SUM(p_su) DESC ) 판매순위
    FROM panmai
    WHERE TO_CHAR(p_date, 'YYYY') =  '2024'
    GROUP BY b_id
) t JOIN book b ON t.b_id = b.b_id
WHERE 판매순위<=3;

-- [문제] 서점별 판매현황 구하기
--서점코드  서점명  판매금액합  비율(소수점 둘째반올림)  
-- g_id    g_name
------------ -------------------------- ----------------
--7	    강북서점	 15300		26%
--4	    서울서점	 11551		19%
--2	    도시서점	 6000		10%
--6	    강남서점	 18060		30%
--1	    우리서점	 8850		15%

SELECT SUM(p_su * price)  
FROM panmai p JOIN danga d ON p.b_id = d.b_id ;

-- PL/SQL  변수 저장
SELECT t.g_id, t.g_name, t.판매금액합
     , ROUND( t.판매금액합/t.전체판매금액합, 2) *100 || '%' 비율
FROM (
    SELECT g.g_id, g_name ,  SUM ( p_su * price)  판매금액합   -- , p.b_id
         , (SELECT SUM(p_su * price) FROM panmai p JOIN danga d ON p.b_id = d.b_id) 전체판매금액합
    FROM panmai p JOIN gogaek g ON p.g_id = g.g_id
                  JOIN danga  d ON p.b_id = d.b_id 
    GROUP BY   g.g_id, g_name  
) t;

-- 뷰(View)

-- 데이터베이스 모델링 (  세미프로젝트 5 개 )
-- 계층적 질의
-- PL/SQL
--   (  토/일/월~금 토/일  )   월 (발표)
-- FROM 테이블 또는 뷰
SELECT *
FROM user_tables;  -- 뷰(view)    가상 테이블   SLECT 쿼리 뿐 







