-- SYS --
-- employees 테이블은 누가 OWNER인가?
SELECT owner
FROM dba_tables
--FROM all_tables
WHERE table_name = UPPER('employees');

-- 오라클 예약어(keyword) 확인 쿼리
SELECT *
FROM V$RESERVED_WORDS
WHERE keyword = UPPER('date');