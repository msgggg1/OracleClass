-- SCOTT --
drop table tbl_sample purge;
CREATE table tbl_sample
(
    id VARCHAR2(10)
    , name VARCHAR2(20)
    , age NUMBER(10)
    , birth DATE

);

SELECT *
from tabs
where regexp_like(table_name, '^TBL_');
where table_name like 'TBL_%';

DESC tbl_sample;

alter table tbl_sample
ADD(
    tel VARCHAR2(20)
    , bigo varchar2(255)
);

alter table tbl_sample
MODIFY ( bigo varchar2(100) );

SELECT bigo memo
FROM tbl_sample;

alter table tbl_sample
rename column bigo to memo;

alter table tbl_sample
drop column memo;

rename tbl_sample to tbl_example;

drop table tbl_board purge;
Create table tbl_board
(
    seq NUMBER(38) not null primary key
    , writer varchar2(20) not null
    , password varchar2(20) not null
    , title varchar2(15) not null
    , content clob
    , regdate date default sysdate
);

alter table tbl_board
add readed number(38) default 0;

insert into tbl_board (seq, writer, password, title, content)
values(1, '사쿠야', '1234', '빵 want', '나는 빵쿠야니까' );

ALTEr table tbl_board
modify (title varchar2(100) );

Update tbl_board
Set title = '빵 먹고싶다'
WHERE seq = 1;

select *
from tbl_board;

commit;

insert into tbl_board (seq, writer, password, title, content)
values(2, 'yushi', '1234', '불닭볶음면', '정도야 껌이지' );
insert into tbl_board (seq, writer, password, title, content)
values(3, '리쿠', '1234', '젤리주세요', '밥보다 젤리' );

commit;


create sequence seq_tbl_board
STart with 4;

select *
from user_sequences;

insert into tbl_board (seq, writer, password, title, content)
values ( seq_tbl_board.nextval, '료', '1234', '샄쿠사쿠', '팡-다');
commit;

select seq_tbl_board.nextval
from dual;

alter table tbl_board
rename column title to subject;

alter table tbl_board
modify (writer varchar2(40));

create table tbl_emp30
AS
select empno, ename, hiredate, job,  sal + NVL(comm,0) pay
FROM emp
WHERE deptno = 30;

select constraint_name, constraint_type, table_name
from user_constraints
where table_name LIKE'%EMP%';

alter table tbl_emp30
add constraint pk_tbl_emp30_empno primary key(empno);

drop table tbl_emp30;

drop table tbl_emp purge;

create table tbl_emp
AS
SELECT *
From emp
where 1 = 0;

select *
from tbl_emp;

drop table tbl_emp;

-- 1) empno, dname, ename, pay, deptno, grade, hiredate , mgr_name
--       컬럼들을 가진 새로운 tbl_emp 테이블 생성...

create table tbl_emp
AS
(
    SELECT  e.empno, d.dname, e.ename, e.sal+NVL(e.comm,0) pay
            ,d.deptno, s.grade, e.hiredate, m.ename mgr_name
    From emp e LEFT JOIN dept d ON e.deptno = d.deptno
               left JOIN emp m ON m.empno = e.mgr
            JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
);

-- 2) empno  PK 제약조건 추가
alter table tbl_emp
ADD CONSTRAINT pk_tbl_emp_empno  PRIMARY KEY (empno);
add primary key(empno);

rollback;

DROP TABLE tbl_emp PURGE;

CREATE TABLE tbl_emp10 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp20 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp30 AS ( SELECT * FROM emp WHERE 1=0 );
CREATE TABLE tbl_emp40 AS ( SELECT * FROM emp WHERE 1=0 );

Insert all 
    into tbl_emp10 values ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
     INTO tbl_emp20 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
    INTO tbl_emp30 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
    INTO tbl_emp40 (empno, ename, job, mgr) VALUES (empno, ename, job, mgr)
SELECT * 
FROM emp;

SELECT * FROM tbl_emp10;
SELECT * FROM tbl_emp20;
SELECT * FROM tbl_emp30;
SELECT * FROM tbl_emp40;

ROLLBACK;

INSERT  FIRST
    WHEN deptno = 10 THEN
        INTO tbl_emp10 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
    WHEN sal >= 1500 THEN
        INTO tbl_emp20 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
    WHEN deptno = 30 THEN
        INTO tbl_emp30 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
    ELSE -- 40
        INTO tbl_emp40 VALUES ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
SELECT * 
FROM emp
;
CREATE TABLE tbl_sales(
    employee_id        number(6),
    week_id            number(2),
    sales_mon          number(8,2),
    sales_tue          number(8,2),
    sales_wed          number(8,2),
    sales_thu          number(8,2),
    sales_fri          number(8,2)
)
;
INSERT INTO tbl_sales VALUES(1101,4,100,150,80,60,120);
INSERT INTO tbl_sales VALUES(1102,5,300,300,230,120,150);
commit;

SELECT *
FROM tbl_sales;

CREATE TABLE  tbl_sales_data(
     employee_id        number(6),
     week_id            number(2),
     days               varchar2(10),
     sales              number(8,2)
 );
 
 SELECT * 
FROM tbl_sales_data;

INSERT ALL
    INTO tbl_sales_data VALUES(employee_id, week_id, 'mon' ,sales_mon)
    INTO tbl_sales_data VALUES(employee_id, week_id, 'tue',sales_tue)
    INTO tbl_sales_data VALUES(employee_id, week_id, 'wed',sales_wed)
    INTO tbl_sales_data VALUES(employee_id, week_id, 'thu', sales_thu)
    INTO tbl_sales_data VALUES(employee_id, week_id, 'fri',sales_fri)
SELECT employee_id, week_id, sales_mon, sales_tue, sales_wed,
        sales_thu, sales_fri
FROM tbl_sales;

drop table tbl_sales_data;

-- [문제] tbl_score 테이블 생성
--       insa 기존 있는 테이블의   num, name 컬럼을 복사해서 
--        num <= 1005
-- ( 조건:  서브쿼리를 사용해서 테이블 생성.  )
create table tbl_score
AS
(
    Select num, name
    From insa
    Where num <= 1005

);

select *
from user_constraints
where regexp_Like(table_name, '^tbl_s', 'i');

alter table tbl_score
ADD constraint pk_tbl_score_num primary key(num);

alter table tbl_score
ADD (
     kor number(3) default 0
     , eng number(3) default 0
     , mat number(3) default 0
     , tot  NUMBER(3) DEFAULT 0
     , avg number(5,2) default 0
     , grade char(1 char)
     , rank number(3)
);

SELECT ROUND(DBMS_RANDOM.value*100)
        ,TRUNC(DBMS_RANDOM.value*101)
        ,FLOOR(Dbms_random.value(0,101))
From dual;

update tbl_score
set kor = FLOOR(Dbms_random.value(0,101))
, eng = FLOOR(DBMS_RANDOM.VALUE *101)
, mat = FLOOR(DBMS_RANDOM.VALUE *101);

select *
from tbl_score;


-- [문제] 1005 번 학생의 국,영 점수가 1001 학생의 국-1, 영-1 점수로 UPDATE
update tbl_score
set (kor, eng) = (select kor-1, eng -1 From tbl_score where num = 1001)
where num = 1005;

update tbl_score
set tot = kor + eng + mat
    , avg = (kor + eng + mat) / 3;
    
update tbl_score c
set rank = (
        select r
        from (
                select num, tot, 
                        rank() OVER(ORDER BY tot DESC)r
                from tbl_score s
        ) 
        where c.num = num 

);

update tbl_score
set grade = DECODE( Trunc(avg/10) , 10, '수', 9, '수', 8, '우', 7, '미', 6, '양', '가' );

-- [문제] tbl_score 테이블에서 남학생들만 국어점수 10 감소. ( UPDATE )
--       (문제점) tbl_score 테이블에는 성별을 구분할 수 있는 컬럼 X
--               insa 테이블의 ssn 가지고 성별 파악해서 UPDATE  완성...
update tbl_score
Set kor = CASE 
            WHEN kor -10 < 0 THEN 0
            ELSE kor-10
            END
where num in (
    SELECT num
    from insa
    where mod( substr(ssn,-7,1), 2 ) = 1 AND num<=1005
    );