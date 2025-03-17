-- 모든 사용자 계정 정보를 조회하는 쿼리(SQL문)을/를 작성하세요 
-- Query(DQL) 데이터 검색(조회) : SELECT
SELECT * -- 조회하겠다.
FROM all_users;  -- 암기
--FROM 대상(테이블 또는 뷰) -- CTRL + ENTER

--PL/SQL 제어문 변수선언 등을 추가환 확장된 질의 언어
-- SQL*Plus 

-- SQL? PL SQL? SQL*Plus?
-- 현재 접속자 확인 쿼리 (show user)
-- SQL 문장 5가지 종류

-- ctrl + f7 -> 예약어 대문자로

-- 일반 사용자 계정 생성
-- ( scott /tiger )
-- DDL - CREATE 문
CREATE USER scott IDENTIFIED BY tiger;
-- 상태: 실패 -테스트 실패: ORA-01045: user SCOTT lacks CREATE SESSION privilege; logon denied
-- SYS -> SCOTT CREATE SESSION 권한 부여
-- DCL : GRANT
-- 신입사원 : 50명 + 신입사원역할(롤)
--    신입 권한 50개 / 회수
--          영업부롤 - 30개
--          총무부롤 - 60개
--          개발부롤 - 45개
--            ㄴ 서주원 : 영업부롤 1개 부여/회수,  개발부롤 1개부여
--            :  

--  신입사원역할(롤) : 50개 권한
-- 미리 정의된 롤 확인 : dba_roles 뷰

SELECT *
FROM dba_roles;

-- 미리 정의된 롤에 부여된 권환을 확인 : DBA_SYS_PRIVS뷰
SELECT *
FROM dba_sys_privs;
--
-- GRANT 롤, 권한 등 TO scott;
GRANT 롤, 권한 등 TO scott;