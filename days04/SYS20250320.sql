-- SYS --
SELECT *
FROM all_tables
WHERE table_name LIKE 'DUAL';
--
DESC dual;
-- DUMMY    VARCHAR2(1) 컬럼 1개
SELECT *
FROM dual;
-- 1개의 행만 있다.
SELECT *
--FROM emp; -- 오류 -> 스키마.테이블명
FROM scott.emp;

-- SYS
SELECT *
FROM scott.emp; -- scott.emp -> arirang 시노님
-- 시노님 생성, 삭제 : DBA 만 가능
--【형식】
--	CREATE [PUBLIC] SYNONYM [schema.]synonym명
--  	FOR [schema.]object명(내가 사용하고자 하는);
CREATE PUBLIC SYNONYM arirang
FOR scott.emp;
--SYNONYM ARIRANG이(가) 생성되었습니다.

SELECT *
FROM arirang; -- 실행가능

-- emp 테이블의 소유자 (owner)
SELECT owner
FROM all_tables
WHERE table_name = 'EMP';

-- PUBLIC 시노님을 삭제 : DBA만 가능
--【형식】
--	DROP [PUBLIC] SYNONYM synonym명;

DROP PUBLIC SYNONYM arirang; -- SYNONYM ARIRANG이(가) 삭제되었습니다.

-- 시노님 목록 조회해서 정말 삭제되었는지 확인
SELECT *
FROM all_synonyms
WHERE synonym_name LIKE UPPER('arirang');