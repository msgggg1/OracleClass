-- SCOTT --
DROP TABLE tbl_emp PURGE;
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

CREATE TABLE tbl_bonus
(
  id number
  , bonus number default 100
);

INSERT INTO  tbl_bonus(id)
   (SELECT  e.id from tbl_emp e);
   
select *
from tbl_bonus;

INSERT INTO tbl_bonus VALUES ( 1004, 50 );   
COMMIT;
SELECT * 
FROM tbl_bonus;

merge into tbl_bonus b
using (select id, salary from tbl_emp) e
ON (b.id = e.id)
WHEN matched then 
    update set b.bonus = b.bonus + e.salary *.01
when not matched then 
    insert (b.id, b.bonus) values (e.id, e.salary*.01);

select *
from tbl_bonus;

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

INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( null, null, null, null, null, null );
-- 1 행 이(가) 삽입되었습니다.
INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( 1111, '홍길동', null, null, null, null );
INSERT INTO tbl_constraint ( empno, ename, deptno, kor, email, city )
VALUES ( 1111, '서영학', null, null, null, null );

UPDATE tbl_constraint
SET ename = '정창기'
WHERE empno = 1111;

delete tbl_constraint
where empno = 1111;

DROP table tbl_constraint;

create table tbl_constraint
(
   empno number(4) not null primary key
   , ename varchar2(20) not null
   , deptno number(2) constraint fk_tbl_constraint_deptno REFERENCES dept(deptno)
   , kor number(3) constraint CK_tbl_constraint_kor CHECK( kor between 0 and 100)
   , email varchar2(250) constraint uk_tbl_constraint_email unique
   , city varchar2(20) constraint CK_tbl_constraint_city check (city in ('서울', '부산', '인천'))
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

select *
from user_indexes
where regexp_like (table_name, 'TBL_CON');

drop table tbl_constraint purge;


create table tbl_constraint
(
   empno number(4) not null 
   , ename varchar2(20) not null
   , deptno number(2) 
   , kor number(3) 
   , email varchar2(250) 
   , city varchar2(20) 
   , constraint PK_tbl_constraint_empno primary key(empno)
   , constraint fk_tbl_constraint_deptno foreign key(deptno) REFERENCES dept(deptno)
   , constraint CK_tbl_constraint_kor CHECK( kor between 0 and 100)
   , constraint uk_tbl_constraint_email unique(email)
   , constraint CK_tbl_constraint_city check (city in ('서울', '부산', '인천'))
);
















