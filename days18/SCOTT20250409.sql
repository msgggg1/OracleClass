-- SCOTT --
-- [ 동적쿼리 ]
--자바 수업 - 동적 배열
--int [] m = null;
--int size = scanner.nextInt();
--m = new int [size];

-- 동적 쿼리 ? 쿼리 (SQL) 미완성. 컴파일 시에도 쿼리가 100퍼센트 정해지지 않음. (다나와 조건 선택)
-- 예) 다나와 사이트 : 노트북 검색
--  검색 조건 체크 개수 만큼
-- SELECT 
-- WHERE 체크한 만큼 조건절
1) 컴파일 시에 SQL 문장이 확정되지 않은 경우 (가장 많이 사용되는 경우)
    WHERE 조건절 
2) PL/SQL 블럭 안에서 DDL문을 사용하는 경우
-- CREATE, DROP, ALTER 문
3) PL/SQL 블럭 안에서 ALTER SYSTEM/SESSION 명령어를 사용하는 경우

-- [PL/SQL 동적 쿼리를 사용하는 방법 2가지 ]
--1) DBMS_SQL 패키지
--2) EXECUTE IMMEDIATE 문 ***
SELECT ename INTO vename 변수에 값을 할당

--형식)
--EXEC IMMEDIATE 동적쿼리문
--        [INTO 변수명, 변수명, ...]-- 없다면 생략
--        [USING IN/OUT/IN OUT 파라미터, 파라미터,...]

-- 예) 익명프로시저 
declare 
    vsql varchar2(1000); -- 동적쿼리문
    vdeptno emp.deptno%type;
    vempno emp.empno%type;
    vename emp.ename%type;
    vjob emp.job%type;
begin
    vsql := 'SELECT deptno, empno, ename, job ';
    vsql := vsql || 'FROM emp ';
    vsql := vsql || 'WHERE empno = 7369';

    DBMS_OUTPUT.put_line(vsql);
    
    EXECUTE immediate vsql
        into vdeptno, vempno, vename, vjob;
    
--    DBMS_OUTPUT.PUT_line        

--exception
end;

-- 예) 
create or replace procedure up_ds_emp
(
    pempno emp.empno%type
)
IS
    vsql varchar2(1000); -- 동적쿼리문
    vdeptno emp.deptno%type;
    vempno emp.empno%type;
    vename emp.ename%type;
    vjob emp.job%type;
begin
    vsql := 'SELECT deptno, empno, ename, job ';
    vsql := vsql || 'FROM emp ';
    vsql := vsql || 'WHERE empno = '||pempno;

    DBMS_OUTPUT.put_line(vsql);
    
    EXECUTE immediate vsql
        into vdeptno, vempno, vename, vjob;
    
    DBMS_OUTPUT.PUT_line( vdeptno || ', ' || vempno|| ', ' || vename|| ', ' || vjob );       

--exception
end;

-- 예)
create or replace procedure up_ds_emp
(
    pempno emp.empno%type
)
IS
    vsql varchar2(1000); -- 동적쿼리문
    vdeptno emp.deptno%type;
    vempno emp.empno%type;
    vename emp.ename%type;
    vjob emp.job%type;
begin
    vsql := 'SELECT deptno, empno, ename, job ';
    vsql := vsql || 'FROM emp ';
    vsql := vsql || 'WHERE empno = :pempno'; --*

    DBMS_OUTPUT.put_line(vsql);
    
    EXECUTE immediate vsql
        into vdeptno, vempno, vename, vjob
        USING IN pempno; --*
    
    DBMS_OUTPUT.PUT_line( vdeptno || ', ' || vempno|| ', ' || vename|| ', ' || vjob );       

--exception
end;


exec UP_DS_EMP(7369);


-- 예) 동적 쿼리를 사용해서 dept 테이블에 부서를 추가 
create or replace procedure up_ds_insert_dept
(
    pdname dept.dname%type := null
    , ploc dept.loc%type := null
)
IS
    vsql varchar2(1000); -- 동적쿼리문
    vdeptno dept.deptno%type;
   
begin
    select MAX(NVL(deptno,0)) + 10 into vdeptno
    from dept;


    vsql := 'INSERT INTO dept (deptno, dname, loc) ';
    vsql := vsql || 'VALUES (:vdeptno, :pdname, :ploc) ';

    DBMS_OUTPUT.put_line(vsql);
    
    EXECUTE immediate vsql
        USING IN vdeptno, pdname, ploc; --*
    
    DBMS_OUTPUT.PUT_line( 'insert complete');       

--exception
end;

exec up_ds_insert_dept('qc', 'seoul');
rollback;

-- 예) 동적 쿼리 - (테이블을 동적으로 생성하는 DDL 문 사용)
declare -- 익명 프로시저
    vsql varchar2(1000); -- 동적쿼리문
    vtableName varchar2(20);
   
begin
    vtableName := 'TBL_DS_SAMPLE';

    vsql := 'create table ' || vtableName || ' ';
    vsql := vsql ||'(';
    vsql := vsql ||'   id Number primary key ';
    vsql := vsql ||'   , name varchar2(20) ';
    vsql := vsql ||'   , age number(3) ';
    vsql := vsql ||')';
    
    DBMS_OUTPUT.put_line(vsql);
    
    EXECUTE immediate vsql;
    
    DBMS_OUTPUT.PUT_line('성공');       

--exception
end;

-- *** 동적 쿼리 INSERT/UPDATE/DELETE
--     동적 쿼리 SELECT
--    [ 동적 쿼리 SELECT 여러 개의 행을 조회 ]
-- 사원테이블에서 부서번호를 파라미터로 SELECT
create or replace procedure up_ds_select_emp
(
    pdeptno emp.deptno%type
)
IS
    vsql varchar2(1000); -- 동적쿼리문
    vrow emp%rowtype;
    vcursor SYS_REFCURSOR; -- 커서 자료형. 오라클9i: REF CURSOR 옛날 코딩임 
    
begin

    vsql := 'SELECT * ';
    vsql := vsql || 'FROM emp ';
    vsql := vsql || 'WHERE deptno = :pdeptno ';
    
    DBMS_OUTPUT.put_line(vsql);
    
--    EXECUTE immediate 동적쿼리문; : DML, SELECT 1개 행 시 사용
--    여러개의 행 SELECT -> PL/SQL 여러 개의 행 처리 : 커서(CURSOR) + 동적 쿼리
    -- OPEN ~ FOR 문 사용
--   형식) OPEN 커서명 FOR 동적쿼리 USING 파라미터;
OPEN vcursor for vsql using pdeptno;

loop
    FETCH vcursor INTO vrow;
    EXIT WHEN vcursor%NOTFOUND;
    DBMS_OUTPUT.PUT_line( vrow.empno|| ', ' || vrow.ename);  
end loop;

close vcursor;

    
    DBMS_OUTPUT.PUT_line( 'select complete');       

--exception
end;

exec UP_DS_SELECT_EMP(30);



-- 다나와
-- emp 테이블에서 검색 기능 구현
-- 1) 검색조건    : 1 부서번호, 2 사원명, 3 잡
-- 2) 검색어      : [     ]
CREATE OR REPLACE PROCEDURE up_ndsSearchEmp
(
  psearchCondition NUMBER -- 1. 부서번호, 2.사원명, 3. 잡
  , psearchWord VARCHAR2
)
IS
  vsql  VARCHAR2(2000);
  vcur  SYS_REFCURSOR;   -- 커서 타입으로 변수 선언  9i  REF CURSOR
  vrow emp%ROWTYPE;
BEGIN
  vsql := 'SELECT * ';
  vsql := vsql || ' FROM emp ';
  
  IF psearchCondition = 1 THEN -- 부서번호로 검색
    vsql := vsql || ' WHERE  deptno = :psearchWord ';
  ELSIF psearchCondition = 2 THEN -- 사원명
    vsql := vsql || ' WHERE  REGEXP_LIKE( ename , :psearchWord )';    
  ELSIF psearchCondition = 3  THEN -- job
    vsql := vsql || ' WHERE  REGEXP_LIKE( job , :psearchWord , ''i'')';
  END IF; 
   
  OPEN vcur  FOR vsql USING psearchWord;
  LOOP  
    FETCH vcur INTO vrow;
    EXIT WHEN vcur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE( vrow.empno || ' '  || vrow.ename || ' ' || vrow.job );
  END LOOP;   
  CLOSE vcur; 
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, '>EMP DATA NOT FOUND...');
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004, '>OTHER ERROR...');
END;

EXEC UP_NDSSEARCHEMP(1, '20'); 
EXEC UP_NDSSEARCHEMP(2, 'L'); 
EXEC UP_NDSSEARCHEMP(3, 's'); 














