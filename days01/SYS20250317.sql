-- 모든 사용자 계정 정보를 조회하는 쿼리(SQL문)을/를 작성하세요 
-- Query(DQL) 데이터 검색(조회) : SELECT
SELECT * -- 조회하겠다.
FROM all_users; -- CTRL + ENTER -- 암기
--FROM 대상(테이블 또는 뷰)

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

-- 미리 정의된 롤 확인 : dba_roles 뷰
SELECT *
FROM dba_roles;

-- 미리 정의된 롤에 부여된 건환을 확인 : DBA_SYS_PRIVS뷰
SELECT *
FROM dba_sys_privs;
--
-- GRANT 롤, 권한 등 TO scott;
GRANT 롤, 권한 등 TO scott;