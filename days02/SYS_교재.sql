/* system계정에서 실행한다. 	*/
/* Oracle 12c 이상의 CDB 사용자 생성을 위해 c##을 붙인다 	*/
DROP USER c##madang CASCADE;
CREATE USER c##madang IDENTIFIED BY madang DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp PROFILE DEFAULT;
GRANT CONNECT, RESOURCE TO c##madang;
GRANT CREATE VIEW, CREATE SYNONYM TO c##madang;
GRANT UNLIMITED TABLESPACE TO c##madang;
ALTER USER c##madang ACCOUNT UNLOCK;

