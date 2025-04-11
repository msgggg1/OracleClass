-- SCOTT --
select *
from tbl_dept;

delete from tbl_dept;
commit;

--[ 작업 스케줄러 ]
작업 스케줄러 
-- 데이터베이스 내에 생성한 프로시저, 함수들에 대해 데이터베이스 내의 스케쥴러에 지정한 시간에 
-- 자동으로 작업이 진행될 수 있도록 하는 기능이다.

--***1) DBMS_JOB 패키지
        ㄱ. PL/SQL 블럭 생성 ( 프로시저, 함수 ) 생성
        ㄴ. 스케줄 설정
        ㄷ. 잡 생성 / 삭제 / 중지 기능 체크
--2) DBMS_SCHEDULER 패키지 ( 오라클 10g 이후 ) 권장

-- 실습 ) 테이블 생성
create table tbl_job
(
    seq number
        , insert_date date
);
--Table TBL_JOB이(가) 생성되었습니다.

create or replace procedure up_job
--()
IS
    vseq number;
begin
    -- 시퀀스 역할
    select MAX(NVL(seq,0)) + 1 into vseq
    from tbl_job;
    -- 
    insert into tbl_job values (vseq, sysdate);
    
    commit;
exception
    when others then 
        rollback;
        DBMS_OUTPUT.put_line(sqlERRM);
end;
--Procedure UP_JOB이(가) 컴파일되었습니다.

-- JOB 등록 ( DBMS_JOB.SUBMIT() 저장프로시저) excute, 익명 , 또 다른 저장프로시저
-- 익명프로시저
-- ? 등록된 잡코드 번호를 알아와서 잡 중지/삭제 하려고
declare 
    vjob_no number;
begin
    dbms_job.submit(
        job => vjob_no   -- output용(출력용) 파라미터
        , what => 'UP_JOB;'  --주기적으로 실행할 pl/sql 블럭 (저장 프로시저)
        , next_date => SYSDATE -- 최초 실행 시점 :job 이 등록되자마자 실행
         -- , interval => 'SYSDATE + 1'  하루에 한 번  문자열 설정
       -- , interval => 'SYSDATE + 1/24'
       -- , interval => 'NEXT_DAY(TRUNC(SYSDATE),'일요일') + 15/24'
       --    매주 일요일 오후3시 마다.
       -- , interval => 'LAST_DAY(TRUNC(SYSDATE)) + 18/24 + 30/60/24'
       --    매월 마지막 일의   6시 30분 마다..
       , interval => 'SYSDATE + 1/24/60' -- 매 분 마다     
    );
        commit;
        dbms_output.put_line( '잡 등록된 번호'|| vjob_no);
--exception
end;

select *
from user_jobs;

-- job 삭제
begin
    dbms_job.remove(1);
    commit;
end;

-- 
select seq, to_char( insert_date, 'DL TS')
from tbl_job;

-- 잡 삭제 : DBMS_JOB.remove(41);
-- 잡 일시중지
begin
    dbms_job.broken(1, true);
    commit;
end;

-- 잡 일시중지 -> 재시작
begin
    dbms_job.broken(1, false);
    commit;
end;

-- job의 실행 주기와 상관없이 실행하고자 할때 
begin
    dbms_job.run(1);
end;

-- 잡 속성 변경 : DBMS_job.change() 저장 프로시저를 사용하면 된다.
-- 