-- [문제] emp테이블에서 10번 부서원 20% 인상, 20번 부서원 10% 인상
-- 그 외 부서는 15% 인상
-- PL/SQL의 익명 프로시적 작성해서 처리

--1) 그냥
BEGIN
    update emp
    set sal = Decode(deptno, 10, sal*1.2, 20 , sal*1.1, sal*1.15);
    /*
    set sal = CASE deptno
                WHEN 10 THEN sal*1.2
                WHEN 20 THEN sal*1.1
                ELSE sal *1.15
                END;
                */
--EXCEPTION
END;

select * 
from emp;

rollback;

--2) PL/SQL 익명 프로시저
--DECLARE
--    vsal emp.sal%type;
--    vdept10 emp.deptno%type := 10;
--    vdept20 emp.deptno%type := 20;

-- FOR문 사용해서 SELECT
DECLARE
    vename varchar2(10);
    vhiredate emp.hiredate%type;
    -- vrow emp%rowtype; for 문의 반복변수 선언 안해도됨
begin 
-- [2] 커서 : 암(묵)시적 커서 -- 여러개 뿌릴때 반복문 사용됨
    FOR vrow IN (select  ename, hiredate, job from emp )
    LOOP
         DBMS_OUTPUT.PUT_LINE(vrow.ename|| ', '||vrow.hiredate||', '||vrow.job);
    END LOOP;
    /*
     [1] 커서 (CURSOR) - 암/명시적 커서
    select  ename, hiredate into vename, vhiredate
    from emp 
--    where empno = 7369;
    
    DBMS_OUTPUT.PUT_LINE(vename|| ', '||vhiredate);
    */
    
--exception
end;

-- [사용자 정의 구조체 타입 선언] 예제
-- 1) %TYPE 변수
declare
    vdeptno dept.deptno%type ;
    vdname dept.dname%type ;
    vempno emp.empno%type ;
    vename emp.ename%type ;
    vpay number;
begin
    select d.deptno, dname, empno, ename, sal+NVL(comm,0) pay
        into vdeptno, vdname, vempno, vename, vpay
    from dept d join emp e on d.deptno = e.deptno
    where empno = 7369;
     DBMS_OUTPUT.PUT_LINE(vdeptno ||', '|| vdname ||', '|| vempno ||', '|| vename||', '|| vpay);
--exception
end;
-- 2) %ROWTYPE 변수 -- 조인 테이블 개수만큼
declare 
    vdrow dept%rowtype; 
    verow emp%rowtype;
    vpay number;
begin
    select d.deptno, dname, empno, ename, sal+NVL(comm,0) pay
        into vdrow.deptno, vdrow.dname, verow.empno, verow.ename, vpay
    from dept d join emp e on d.deptno = e.deptno
    where empno = 7369;
     DBMS_OUTPUT.PUT_LINE(vdrow.deptno ||', '|| vdrow.dname ||', '|| verow.empno ||', '|| verow.ename||', '|| vpay);
--exception
end;
-- 3) 사용자 정의 구조체 타입 -> 사용 // 여러테이블이 섞여있는 칼럼을 가지고 있는경우 그 칼럼들을 가지고 있는 자료형 생성
declare 
    -- ㄱ. 사용자 정의 구조체 타입 선언(새로운 자료형 선언)
--    TYPE 구조체명 IS RECORD -- 하나의 행
    TYPE EmpDeptType IS RECORD
    (
        deptno dept.deptno%type, -- 자료형 선언 시에는 콤마
        dname dept.dname%type,
        empno emp.empno%type,
        ename emp.ename%type,
        sal emp.sal%type,
        comm emp.comm%type
    ); 
    -- ㄴ. 변수 선언
    vrow EmpDeptType;
    vpay number;
    BEGIN
         SELECT d.deptno, d.dname, e.empno, e.ename, e.sal + NVL(e.comm, 0)
            into vrow.deptno, vrow.dname, vrow.empno, vrow.ename, vpay
    from dept d join emp e on d.deptno = e.deptno
    where empno = 7369;
     DBMS_OUTPUT.PUT_LINE(vrow.deptno ||', '|| vrow.dname ||', '|| vrow.empno ||', '|| vrow.ename||', '|| vpay);
--exception
end;

-- [문제] insa 테이블에서 사원번호(num) = 1001
-- 급여파악 -> 2500000 많으면 세금을 2.5%, 2000000 많으면 2%
--            0% 출력
declare
    vname insa.name%type;
    vpay NUMBER;
    vtax number;
    vsil number; -- vpay - vtax; 실수령액
begin
    select  name, basicpay + sudang
        into vname, vpay
    from insa
    where num = 1001;
    
    IF vpay  >= 2500000 THEN
        vtax := vpay * 0.025;
    ELSIF vpay  >= 2000000 THEN
        vtax := vpay *0.02;
    ELSE
     vtax := 0;
    END IF;
    
    -- 실 수령액
    vsil := vpay - vtax;
    DBMS_OUTPUT.PUT_LINE(vname || ', ' ||vpay|| ', ' || vtax || ', ' || vsil);
--exception
end;

-- [커서 (cursor)]
-- 1. 명시적 커서 사용 예제
declare 
    TYPE EmpDeptType IS RECORD
    (
        deptno dept.deptno%type,
        dname dept.dname%type,
        empno emp.empno%type,
        ename emp.ename%type,
        pay number
    ); 
    vrow EmpDeptType;
    -- ㄱ. 커서 선언
--    CURSOR 커서명 IS (SELECT문)
    CURSOR vdecursor IS (
    SELECT d.deptno, dname, empno, ename, sal + NVL(comm, 0)pay
    from dept d join emp e on d.deptno = e.deptno
    );
    BEGIN
         -- ㄴ. OPEN : select문 실행
         OPEN vdecursor;
         -- ㄷ. FETCH : 가져오다 -> 반복적으로 처리
         LOOP 
          DBMS_OUTPUT.PUT_LINE('>읽어온 레코드 수: ' || vdecursor%rowcount);
          FETCH vdecursor INTO vrow;
          EXIT wHEN vdecursor%notfound;
           DBMS_OUTPUT.PUT_LINE(vrow.deptno ||', '|| vrow.dname ||', '|| vrow.empno ||', '|| vrow.ename||', '|| vpay);
         END LOOP;
         -- ㄹ. CLOSE
         CLOSE vdecursor;
       
--exception
end;


-- 2. 명시적 커서 사용 예제
 BEGIN
        FOR vrow in (
             SELECT d.deptno, dname, empno, ename, sal + NVL(comm, 0)pay
            from dept d join emp e on d.deptno = e.deptno
            )
        LOOP
            DBMS_OUTPUT.PUT_LINE(vrow.deptno ||', '|| vrow.dname ||', '|| vrow.empno ||', '|| vrow.ename||', '|| vrow.pay);
        END LOOP;
        
--exception
end;


-- 3. 

declare -- 변수, 상수 선언하는 곳
 CURSOR vdecursor IS (
    SELECT d.deptno, dname, empno, ename, sal + NVL(comm, 0)pay
    from dept d join emp e on d.deptno = e.deptno
    );
BEGIN 
    --open vdecursor;
    for vrow in vdecursor
    loop
     DBMS_OUTPUT.PUT_LINE(vrow.deptno ||', '|| vrow.dname ||', '|| vrow.empno ||', '|| vrow.ename||', '|| vrow.pay);
    end loop;
END;
-- for문, cursor, 서브 쿼리 오픈,close, fetch 작업 다 포함되어있음. 

-- 저장 프로시저( Stored Procedure )
-- 저장 프로시저 선언 형식)
--CREATE OR REPLACE PROCEDURE up프로시저명
CREATE OR REPLACE PROCEDURE up프로시저명
--cf) DECLARE -- 로 시작: 익명프로시저
 -- 변수, 상수 선언
CREATE OR REPLACE PROCEDURE up프로시저명
(    
    -- 매개변수 선언 -- 저장 프로시저 외부에서 호출 시 전달하는 값,  ", " 사용 , ; X
    -- 자료형 크기 할당하지 않음
    pssn IN VARCHAR2,
    pename emp.ename%TYPE, -- 모드 생략 -> IN 기본값 = 입력용 매개변수라는 뜻
    pssn OUT VARCHAR2, -- 출력용 매개변수
    pssn INOUT varchar2 -- 입, 출력용 매개변수
)
IS -- 영역 구분
    -- 변수, 상수 선언 -- 블럭 내에서 사용할
    vname varchar2(10) := '홍길동';
begin 
exception
end;

-- 저장 프로시저를 실행하는 방법 (3가지) -- 실행문 안에 commit, rollback까지 있어야 함. 
-- 1) EXEC[UTE] 문으로 실행
-- 2) 익명 프로시저에서 호출해서 실행
-- 3) 또 다른 저장 프로시저 안에서 호출해서 실행

-- [ 문제 ] emp 복사 -> tbl_emp 테이블 생성 ( 구조복사 + 데이터 복사 )
drop table tbl_emp;

CREATE TABLE tbl_emp 
AS
(
    select *
    from emp
);
-- tbl_emp 에 사원번호를 입력받아서 사원을 삭제 쿼리 작성
delete from tbl_emp
where empno = 7369;
 rollback;

-- 사원 삭제하는 저장 프로시저 생성 + 처리
create or replace procedure updeltblemp
is
begin
    delete from tbl_emp
    where empno = 7369;
--exception
end;
-- Procedure UPDELTBLEMP이(가) 컴파일되었습니다. --> 메모리에 올라감.실행하면됨

-- 
EXECUTE updeltblemp(삭제할 사원번호); -- input용 파라미터
CREATE OR REPLACE PROCedure updeltblemp
(
--    pempno IN number
    pempno IN tbl_emp.empno%type    
)
IS
    -- v변수 X
begin
    delete from tbl_emp
    where empno = pempno;
end;

select *
from tbl_emp;

-- 1 번째 실행 : EXECUTE 문 사용
EXECUTE updeltblemp(7369); -- input용 파라미터
EXECUTE updeltblemp(7499); -- input용 파라미터

 2번째 실행 : 익명 프로시저에서 실행
--declare
begin 
    updeltblemp(7521);
    commit;
-- exception
end;

-- 3 번재 실행 : 또 다른 저장 프로시저에서 실행
create or replace procedure upother
(
    pempno In tbl_emp.empno%type
)
is
begin
    updeltblemp(pempno);
    commit;
--exception
end;

execute upother(7566);

commit;

-- [문제 ] dept -> tbl_dept 테이블 생성
--        CRUD 저장 프로시저 만들어서 테스트 
-- 1) 
drop table tbl_dept purge;

--
create table tbl_dept
AS 
    (SELECT * from dept);

-- 2) tbl_dept 테이블에 제약조건 확인
-- deptno 컬럼에 PK 제약조건 추가
SELEct *
from user_constraints
where table_name = 'TBL_DEPT';

ALTER table tbl_dept
ADD constraint pk_tbl_dept_deptno PRimary key(deptno);

-- 3) tbl_dept 모든 레코드를 읽어와서 출력하는 select : upseltbldept
create or replace procedure upseltbldept
is 
    -- 1) 커서 선언
    cursor vdcursor IS ( select deptno, dname, loc From tbl_dept );
    vrow tbl_dept%rowtype;
begin 
    -- 2) 커서 open
    open vdcursor;
    -- 3) fetch
    loop 
        fetch vdcursor into vrow;
        exit when vdcursor%notfound;
        dbms_output.put(vdcursor%rowcount || ' : ');
         dbms_output.put_line(vrow.deptno || ',' ||vrow.dname || ',' ||vrow.loc);
    end loop; 
    -- 4) close
    close vdcursor;
--exception
end;

execute upseltbldept;



-- FOR 묵시적 커서 사용 코딩
create or replace procedure upseltbldept
is 
    -- 1) 커서 선언
    cursor vdcursor IS ( select deptno, dname, loc From tbl_dept );
begin 

    for vrow in vdcursor
    loop 
        dbms_output.put(vdcursor%rowcount || ' : ');
         dbms_output.put_line(vrow.deptno || ',' ||vrow.dname || ',' ||vrow.loc);
    end loop; 
--exception
end;

execute upseltbldept;

-- 2) INSERT 저장 프로시저: upinserttbldept
-- 시퀀스 생성 40    50      60
【형식】
	CREATE SEQUENCE 시퀀스명
	[ INCREMENT BY 정수]
	[ START WITH 정수]
	[ MAXVALUE n ¦ NOMAXVALUE]
	[ MINVALUE n ¦ NOMINVALUE]
	[ CYCLE ¦ NOCYCLE]
	[ CACHE n ¦ NOCACHE];
-- tbl_dept 테이블의 deptno을 자동으로 입력하기 위한 시퀀스 생성
CREATE SEQUENCE seq_tbl_dept
	INCREMENT BY 10
	START WITH 50
	MAXVALUE 90
	MINVALUE 10 
	NOCYCLE
	NOCACHE; -- 미리 번호표 뽑지 않음

create or replace procedure upinserttbldept
(
    pdname in tbl_dept.dname%type default null,
    ploc in tbl_dept.loc%type := null -- default null 과 같은 코딩
)
IS
 --    --vdeptno tbl_Dept.deptno%TYE;
begin
-- sequence 없었다면 
--    select MAX(deptno) + 10 into vdeptno
--    from tbl_dept;
    insert into tbl_dept (deptno, dname, loc )
    values (SEQ_TBL_DEPT.nextval, pdname, ploc);
    commit;
-- exception
end;
--
execute upinserttbldept( 'QC', 'SEOUL' ); -- pdname => 생략
execute upinserttbldept( pdname => 'QC2' );
execute upinserttbldept( ploc => 'POHANG' );
execute upinserttbldept;
--
desc tbl_dept;

select *
from tbl_dept;

--
-- [문제] 삭제할 부서번호를 입력받아서 해당 부서를 삭제하는 프로시저 생성
-- updeltbldept

create or replace procedure updeltbldept
(
    pdeptno in tbl_dept.deptno%type
)
IS
begin
    Delete from tbl_dept
    where deptno = pdeptno;
    commit;
-- exception
end;
--Procedure UPDELTBLDEPT이(가) 컴파일되었습니다.

-- [문제] tbl_dept 테이블의 레코드 수정 upupdatetbldept
EXEC upupdatetbldept( 50, 'X', 'Y' );  -- dname, loc
EXEC upupdatetbldept( pdeptno=>50,  pdname=>'QC3' );  -- loc
EXEC upupdatetbldept( pdeptno=>60,  ploc=>'SEOUL' );  -- 

create or replace procedure upupdatetbldept
(
    pdeptno in tbl_dept.deptno%type,
    pdname in tbl_dept.dname%type default null, 
    ploc in tbl_dept.loc%type default null 
)
IS
    vdname tbl_dept.dname%type;
    , vloc tbl_dept.loc%type;
begin
    -- 1) 수정 전의 dname, loc 변수에 저장
    select dname, loc into vdname, vloc
    from tbl_dept
    where deptno = pdeptno;
    
    IF pdname IS null then 
        pdname = vdname;
    END IF;
    
    IF ploc is null then
        ploc = vloc;
    END IF;
    
    UPdate tbl_dept
    SET  dname = pdname, loc = ploc 
    WHERE deptno = pdeptno;
    commit;
END;

-- 2)
create or replace procedure upupdatetbldept
(
    pdeptno in tbl_dept.deptno%type,
    pdname in tbl_dept.dname%type default null, 
    ploc in tbl_dept.loc%type default null 
)
IS
begin
    UPdate tbl_dept
    SET  dname = NVL(pdname, dname)
        , loc = CASE
                    WHEN ploc is null then loc
                    ELSE ploc
                END
    WHERE deptno = pdeptno;
    commit;
END;

select *
from tbl_dept;

-- [문제] 명시적 커서를 사용해서 모든 부서원 조회 : upselecttblemp
create or replace procedure upselecttblemp
(
    pdeptno tbl_emp.deptno%type := null
)
is
    cursor vecursor is (
        select * 
        from tbl_emp
        where deptno = NVL(pdeptno, 10)
    );
    verow tbl_emp%rowtype;
begin
    open vecursor;
    LOOP
        fetch vecursor into verow;
        exit when vecursor%notfound;
        DBMS_OUTPUT.PUT( vecursor%ROWCOUNT || ' : '  );
        DBMS_OUTPUT.PUT_LINE( verow.deptno || ', ' || verow.ename 
        || ', ' ||  verow.hiredate);  
    END LOOP;
    close vecursor;
--exception
end;
--
execute upselecttblemp(30);
execute upselecttblemp;

-- [문제] 명시적 커서를 사용해서 모든 부서원 조회
-- (커서에 파라미터를 이용하는 방법)
create or replace procedure upselecttblemp
(
    pdeptno tbl_emp.deptno%type
)
is
    cursor vecursor ( cdeptno tbl_emp.deptno%type ) is (
        select * 
        from tbl_emp
        where deptno = NVL(pdeptno, 10)
    );
    verow tbl_emp%rowtype;
begin
    open vecursor(pdeptno);
    LOOP
        fetch vecursor into verow;
        exit when vecursor%notfound;
        DBMS_OUTPUT.PUT( vecursor%ROWCOUNT || ' : '  );
        DBMS_OUTPUT.PUT_LINE( verow.deptno || ', ' || verow.ename 
        || ', ' ||  verow.hiredate);  
    END LOOP;
    close vecursor;
--exception
end;

execute upselecttblemp(30);
execute upselecttblemp;


---- (FOR 문을 이용하는 방법)
create or replace procedure upselecttblemp
(
    pdeptno tbl_emp.deptno%type
)
is
begin
    FOR verow in (
                 select * 
                from tbl_emp
                where deptno = NVL(pdeptno, 10)
                    )
    LOOP
        DBMS_OUTPUT.PUT_LINE( verow.deptno || ', ' || verow.ename 
        || ', ' ||  verow.hiredate);  
    END LOOP;
--exception
end;

execute upselecttblemp(20);
execute upselecttblemp;

-- [ 파라미터 모드(mode) : IN, OUT, IN OUT ]
-- [문제 ] insa 테이블에 사원번호를 매개변수로 받아서 
-- 사원명, 주민번호 등등 반환하는 출력용 매개변수를 사용하는
-- 저장 프로시저를 생성 + 테스트
create or replace procedure upselectinsa
(
    pnum IN insa.num%type,
    pname out insa.name%type,
    pssn out insa.ssn%type
)
is
    vssn insa.ssn%type;
begin
    select name, ssn into pname, vssn -- 주민등록번호 변환해서 보내기위해
    from insa
    where num = pnum;
    
    pssn := RPAD( SUBSTR(vssn, 0, 8), 14, '*');
--exception
end;
-- 테스트
-- execute upsel~ X
declare
    vname insa.name%type;
    vssn insa.ssn%type;
begin
    upselectinsa(1001, vname, vssn); -- 담아오겠다. 
    dbms_output.put_line(vname ||', ' || vssn);
end;

-- IN/OUT 입출력용으로 사용되는 파라미터를 가지는 저장 프로시저
create or replace procedure upssn
(
    pssn in out varchar2 -- 크기 쓰지 않는다.
)
is
begin
    pssn := substr(pssn,0,6);
--exception
end;

declare
    vssn varchar2(14) := '911213-2345124'; 
begin
    upssn(vssn);
    dbms_OUtput.put_line(vssn);
END;

-- [문제]
DROP TABLE tbl_score PURGE;
CREATE TABLE tbl_score
(
     num   NUMBER(4) PRIMARY KEY
   , name  VARCHAR2(20)
   , kor   NUMBER(3)  
   , eng   NUMBER(3)
   , mat   NUMBER(3)  
   , tot   NUMBER(3)
   , avg   NUMBER(5,2)
   , rank  NUMBER(4) 
   , grade CHAR(1 CHAR)
);

-- 1/2/3/4 학생번호 seq 생성
create sequence seq_tbl_score; -- 디폴트 1부터 1증가


-- 문제1) 학생 추가하는 저장 프로시저 생성/테스트 
create or replace procedure up_insertscore
(
    pname tbl_score.name%type,
    pkor tbl_score.kor%type := 0,
    peng tbl_score.eng%type := 0,
    pmat tbl_score.mat%type := 0
)
is
    vtot number(3) := 0;
    vavg number(5,2);
    vgrade char(1 char);
begin
    vtot := pkor+peng+pmat;
    vavg := vtot/3;
    -- 평균이 90점 이상 A, 80 이상 B, 70 C ~ F
    IF vavg >= 90 then vgrade := 'A';
    ELSIF vavg >= 80 then vgrade := 'B';
    ELSIF vavg >= 70 then vgrade := 'C';
    ELSIF vavg >= 60 then vgrade := 'D';
    ELSE vgrade := 'F';
    END IF;

    insert into tbl_score(num, name, kor, eng, mat, tot, avg, rank, grade)
        values(seq_tbl_score.nextval, pname, pkor, peng, pmat, vtot, vavg, 1, vgrade);
        
    -- 등수처리 프로시저 또는 함수를 호출
    up_rankscore;
    commit;
--exception
end;

EXEC up_insertscore( '홍길동', 89,44,55 );
EXEC up_insertscore( '윤재민', 49,55,95 );
EXEC up_insertscore( '김도균', 90,94,95 );

EXEC up_insertscore( '이시훈', 89,75,15 );
EXEC up_insertscore( '송세호', 67,44,75 );

select *
from tbl_score;

---- 문제2) up_updateScore 저장프로시적
SELECT * 
FROM tbl_score;

EXEC up_updateScore( 1, 100, 100, 100 );
EXEC up_updateScore( 1, pkor =>34 );
EXEC up_updateScore( 1, pkor =>34, pmat => 90 );
EXEC up_updateScore( 1, peng =>45, pmat => 90 );

create or replace procedure up_updateScore
(
    pnum tbl_score.num%type,
    pkor tbl_score.kor%type := null, -- 0점일때 원래 0점? 입력안된건지 구분하기 위해
    peng tbl_score.eng%type := null,
    pmat tbl_score.mat%type := null
)
is
    vtot number(3) := 0;
    vavg number(5,2);
    vgrade char(1 char);
    
    vkor number(3); -- 수정 전의 원래 점수값
    veng number(3);
    vmat number(3);
    
begin
    select kor, eng, mat into vkor, veng, vmat
    from tbl_score
    where num = pnum;

    vtot := pkor+peng+pmat;
    vavg := vtot/3;
    -- 평균이 90점 이상 A, 80 이상 B, 70 C ~ F
    IF vavg >= 90 then vgrade := 'A';
    ELSIF vavg >= 80 then vgrade := 'B';
    ELSIF vavg >= 70 then vgrade := 'C';
    ELSIF vavg >= 60 then vgrade := 'D';
    ELSE vgrade := 'F';
    END IF;

    update tbl_score
    set  kor = NVL(pkor, kor)
        , eng = NVL(peng , eng)
        , mat = NVL(pmat, mat)
        , tot = vtot
        , avg = vavg
        , rank = rank
        , grade = vgrade
    where num = pnum;
        
    up_rankscore;
    commit;
--exception
end;

 -- [문제] tbl_score 테이블의 모든 학생들의 등수를 처리하는 프로시저 생성
create or replace procedure up_rankscore
is
begin
    update tbl_score p
    set rank = (select count(*) + 1 from tbl_score where p.tot<tot );
    commit;
--exception
end;

execute up_rankscore;









-- 
create or replace procedure up_selectinsa
is
--    vicursor 커서자료형; 
    vicursor SYS_REFCURSOR; -- 커서 타입의 변수 선언 -- select 문 적용x 실행
begin
-- open ~for 문 사용
    open vicursor for select name, city, basicpay from insa; -- 명시적 커서의 1,2번 합쳐진 구조
    
    UP_XXXX(vicursor); -- LOOP~FETCH /CLOSE
-- excetpion
end;

-- 
SELECT name, ssn
    , uf_age(ssn, 1)
    
from insa;
-- 저장프로시저 일반 쿼리안에서 못씀. execute or 다른 프로시저

-- 저장 함수 --
-- power(2,3)
-- [문제]주민등록번호 ->성별 '남자'/'여자' 반환하는 함수
create or replace function uf_gender
(
    pssn insa.ssn%type
)
return VARCHAR2
is
    vgender varchar2(6) := '남자';
begin 
    IF MOD(SUBSTR(pssn, -7, 1),2) = 0 then
        vgender := '여자';
    END if;
    
    return (vgender);
--excetpion
end;

select name, scott.uf_gender(ssn) 성별 -- 다른 계정이 사용하려면 권한 +scott.
from insa;

-- ssn -> 만나이/세는나이
-- uf_age
-- ssn, 1 만나이
--      0 세는나이 

create or replace function uf_age
(
    pssn insa.ssn%type,
    ptype number -- 0 세는 나이, 1 만 나이
)
return number -- 크기 안줌
IS
    ㄱ number(4); -- 올해 년도
    ㄴ number(4); -- 생일년도
    ㄷ number(1); -- 생일 지남 여부 -1 , 0 , 1
    vcountingage number(3); -- 세는 나이
    vamericanage number(3); -- 만 나이
begin
    -- 세는 나이 = 올해 년도 - 생일 년도 + 1
    -- 만 나이 = 올해 년도 - 생일년도   +  (생일지남여부 -1)
--                = 세는 나이 -1
    ㄱ := TO_CHAR( SYSDATE, 'YYYY' );
    ㄴ := CASE 
             WHEN SUBSTR(pssn, -7, 1) IN (1,2,5,6) THEN 1900
             WHEN REGEXP_LIKE(SUBSTR(pssn, -7, 1), '[3478]') THEN 2000
             ELSE 1800
         END + SUBSTR( pssn, 1, 2);
    ㄷ := SIGN( TO_DATE( SUBSTR( pssn, 3,4)  , 'MMDD' ) - TRUNC( SYSDATE ) );
    vcountingage := ㄱ - ㄴ +1;
    vamericanage := vcountingage - 1 - CASE ㄷ
                                       WHEN 1 THEN 1
                                       ELSE 0
                                       END;

     IF ptype = 0 THEN return vcountingage;
        ELSE return vamericanage;
        END IF;

--exception
end;

-- [문제] ssn -> "1998.01.20(화)" uf_birth
create or replace function uf_birth
(
    pssn insa.ssn%type
)
return char
IS
    ㄱ varchar2; -- 생년
    ㄴ varchar2; -- 월일
    ㄷ date; -- 생년월일
begin
    ㄱ := CASE 
            when substr(pssn, -7, 1) in (1,2,5,6) then 19
            when regexp_like(substr(pssn, -7, 1),'[3478]') then 20
            ELSE 18
            END
            + (substr(pssn, 1,2));
    ㄴ := substr(pssn, 3,4);
    ㄷ := TO_date(ㄱ||ㄴ, 'yyyymmdd');
    
    return TO_char(ㄷ, 'YYYY.MM.DD(DY)');
    
end;

select uf_birth(ssn)
from insa;






