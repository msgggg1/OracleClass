--HR--
SELECT *
FROM arirang;
-- ORA-00942: table or view does not exist
-- 이유 ? hr 계정은 scott.emp을 SELECT 권한 X/ scott.emp 자체를 조회 못함. 단지 쉽게 부르는 것. 
-- 해결? scott 소유자가 hr 계정에게 SELECT 권한 부여
