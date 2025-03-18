-- [ SYS ]
SELECT *
--FROM user_users; -- 접속한 계정의 정보 하나 나타냄
FROM dba_users; -- 나머지 다른 정보들도 보임 (모든 사용자 정보)
FROM all_users; -- 대상(테이블명, 뷰명) -- 3개의 칼럼만

--
SELECT *
FROM dba_tablespaces;
FROM dba_data_files; -- C:\ORACLEXE\APP\ORACLE\ORADATA\XE 테이블 스페이스 이름


-- HR 계정 유무 확인 / SCOTT 계정과 같은 샘플용 계정임
SELECT *
FROM all_users;
-- HR 계정의 비밀번호를 새로 설정(SYS임) (lion)
-- DDL : CREATE, ALTER, DROP
-- 계정 생성 CREATE USER
--          ALTER USER
ALTER USER hr IDENTIFIED BY lion; -- User HR이(가) 변경되었습니다. (비밀번호 변경)
-- hr 계정의 잠김 상태 확인 + 해제
ALTER USER hr ACCOUNT UNLOCK;
-- 비번변경 + 잠금해제
ALTER USER hr IDENTIFIED BY lion
              ACCOUNT UNLOCK;
--          DROP USER

-- 
SELECT *
FROM dba_sys_privs;
FROM dba_roles;

-- 20250318 - scott.sql 롤 부여
-- GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO SCOTT IDENTIFIED BY tiger;

-----

SELECT * -- emp 테이블의 모든 칼럼
FROM scott.emp; -- 시노님(약칭)
FROM 스키마.emp; -- 스키마.객체명(테이블명) 스키마=계정이름
-- 테이블 소유자 SCOTT / SYS아님  --> 스키마.emp

