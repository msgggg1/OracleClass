-- SYS --
-- SYS이지만 scott
SELECT *
FROM emp;

select '<'||userenv('sessionid')
     ||'>SQL>' sq from dual;
     -- session id값 다름
     
-- 사용자 B
commit;
--
select *
FROM tbl_dept; -- 같은 테이블 확인됨

-- commit 전 추가한 데이터 안보임

delete from tbl_dept
where deptno = 40;
-- 트랜잭션 잠겨 잇음 - 실행 못함

commit;