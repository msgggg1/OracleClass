-- SCOTT --
-- [트랜잭션(Transaction)]
-- 일의 처리가 완료되지 않은 중간 과정을 취소하여 일의 시작 전 단계로 되돌리는 기능이다. 
-- 즉, 결과가 도출되기까지의 중간 단계에서 문제가 발생하였을 경우 모든 중간 과정을 무효화하여 작업의 처음 시작 전 단계로 되돌리는 것이라 할 수 있다. 
-- 일의 완료를 알리는 commit과 일의 취소를 알리는 rollback이 쓰인다.
예) 계좌 이체 (A -> B 이체)
트랜잭션 처리 시 잠금(LOCK)
1) A계좌에서 이체할 금액만큼 인출하는 UPDATE문 실행 
2) B계좌에 인출한 금액만큼을 UPDATE 문 실행
위의 1) + 2) DML 문을 실행

-- 모든 DML문이 성공(완료)  COMMIT 작업   --> lock 해제
-- 하나라도 DML문이 실패    ROLLBACK 작업 --> lock 해제

저장 프로시저 : B ~ Commit/Rollback E
테이블 DML 트리거 C/R 필요 없음 (트리거안에서는 C/R 필요없다)

select '<'||userenv('sessionid')
     ||'>SQL>' sq from dual;

-- 사용자A
commit;
drop table tbl_dept purge;

create table tbl_dept
AS
    select * from dept;
--
select *
FROM tbl_dept;
-- 1) INSERT
INSERT into tbl_dept values(50, 'QC', 'SEOUL');

select *
FROM tbl_dept;
-- 
SAVEPOINT a;
-- DML 문 사용 but C/R X -> 아직 잠금
-- 2) UPDATE 
update tbl_dept
set loc = 'SEOUL'
where deptno = 40;
-- DML 문 사용 but C/R X -> 아직 잠금

-- rollbavk; -- insert, update 취소
--rollback to savepoint a;
rollback to a;
commit;

-- 40 삭제했으나 그대로 



dMl - 꼭 C/R
SELECT 문은 안잠김
잠그고 싶으면 select for update of 문

C O R 프로시저명
()
IS
BEGIN
    SELECT
    INSERT
    UPDATE
    INSERT
    :
    COMMIT;
EXCEPTION
    WHEN THEN
        ROLLBACK; -- 예외 발생 시 명시적으로 트랜젝션 처리
    WHEN THEN
END;
-- PL/SQL - 익프/저프/저함/트, [패키지]
-- 아래는 패키지 명세서
CREATE OR REPLACE PACKAGE employee_pkg -- 패키지 명
as 
    procedure print_ename(p_empno number); --프로시저명(파라미터 값)
    procedure print_sal(p_empno number); 
end employee_pkg; -- end;로 끝나돔.
  / 
--Package EMPLOYEE_PKG이(가) 컴파일되었습니다.


CREATE OR REPLACE PACKAGE BODY employee_pkg as --body 몸체 부분
 
    procedure print_ename(p_empno number) -- create or replace만 생략된 프로시저 코딩
    is 
      l_ename emp.ename%type; 
    begin 
      select ename 
        into l_ename 
        from emp 
        where empno = p_empno; 
       dbms_output.put_line(l_ename); 
     exception 
       when NO_DATA_FOUND then 
         dbms_output.put_line('Invalid employee number'); 
     end print_ename; 
  
   procedure print_sal(p_empno number) is 
     l_sal emp.sal%type; 
   begin 
     select sal 
       into l_sal 
       from emp 
       where empno = p_empno; 
     dbms_output.put_line(l_sal); 
   exception 
     when NO_DATA_FOUND then 
       dbms_output.put_line('Invalid employee number'); 
   end print_sal; 
end employee_pkg; 
/


 execute employee_pkg.print_ename(7369); 



-- [ 패키지 ]
-- Package EMPLOYEE_PKG이(가) 컴파일되었습니다.
-- 패키지의 명세서 부분
CREATE OR REPLACE PACKAGE employee_pkg 
AS
    -- 서브프로그램 ( 저장 프로시저, 저장 함수 만 )
    procedure print_ename(p_empno number); 
    procedure print_sal(p_empno number); 
    -- 만나이, 나이..
    FUNCTION uf_age
    (
        pssn IN VARCHAR2
        , ptype IN NUMBER
    )
    RETURN NUMBER;
END employee_pkg; 


-- 패키지 몸체 부분
CREATE OR REPLACE PACKAGE BODY employee_pkg 
AS 
   
      procedure print_ename(p_empno number) is 
         l_ename emp.ename%type; 
       begin 
         select ename 
           into l_ename 
           from emp 
           where empno = p_empno; 
       dbms_output.put_line(l_ename); 
      exception 
        when NO_DATA_FOUND then 
         dbms_output.put_line('Invalid employee number'); 
     end print_ename; 
   
   procedure print_sal(p_empno number) is 
      l_sal emp.sal%type; 
    begin 
      select sal 
       into l_sal 
        from emp 
        where empno = p_empno; 
     dbms_output.put_line(l_sal); 
    exception 
      when NO_DATA_FOUND then 
        dbms_output.put_line('Invalid employee number'); 
   end print_sal;  
   
   FUNCTION uf_age
(
   pssn IN VARCHAR2 
  ,ptype IN NUMBER --  1(세는 나이)  0(만나이)
)
RETURN NUMBER
IS
   ㄱ NUMBER(4);  -- 올해년도
   ㄴ NUMBER(4);  -- 생일년도
   ㄷ NUMBER(1);  -- 생일 지남 여부    -1 , 0 , 1
   vcounting_age NUMBER(3); -- 세는 나이 
   vamerican_age NUMBER(3); -- 만 나이 
BEGIN
   -- 만나이 = 올해년도 - 생일년도    생일지남여부X  -1 결정.
   --       =  세는나이 -1  
   -- 세는나이 = 올해년도 - 생일년도 +1 ;
   ㄱ := TO_CHAR(SYSDATE, 'YYYY');
   ㄴ := CASE 
          WHEN SUBSTR(pssn,8,1) IN (1,2,5,6) THEN 1900
          WHEN SUBSTR(pssn,8,1) IN (3,4,7,8) THEN 2000
          ELSE 1800
        END + SUBSTR(pssn,1,2);
   ㄷ :=  SIGN(TO_DATE(SUBSTR(pssn,3,4), 'MMDD') - TRUNC(SYSDATE));  -- 1 (생일X)

   vcounting_age := ㄱ - ㄴ +1 ;
   -- PLS-00204: function or pseudo-column 'DECODE' may be used inside a SQL statement only
   -- vamerican_age := vcounting_age - 1 + DECODE( ㄷ, 1, -1, 0 );
   vamerican_age := vcounting_age - 1 + CASE ㄷ
                                         WHEN 1 THEN -1
                                         ELSE 0
                                        END;

   IF ptype = 1 THEN
      RETURN vcounting_age;
   ELSE 
      RETURN (vamerican_age);
   END IF;
--EXCEPTION
END uf_age;
  
END employee_pkg; 
-- Package Body EMPLOYEE_PKG이(가) 컴파일되었습니다.


SELECT name, ssn,   EMPLOYEE_PKG.UF_AGE( ssn, 1) age
FROM insa;





