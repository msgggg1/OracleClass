-- HR --
SELECT * -- emp 테이블의 모든 칼럼
FROM scott.emp; -- 시노님(약칭)

--  table or view does not exist : 철자x, 권한x -> SYS or scott(소유자)가 권한 부여

-- HR이 소유하고 있는 테이블 목록 조회
SELECT *
FROM user_tables;
-- employees 사원 테이블 조회

-- [문제] 사원번호, 사원명, 입사일자만 조회
SELECT employee_id,
-- JAVA: 문자열 연결 + 연산자, STring concat() 메서드
-- Oracle: 문자열 연결 || 연산자 , CONCAT (두개 인자만 , 세개 -> CONCAT 중첩) 메서드
--first_name,last_name
-- -- '+' 앞 뒤 숫자만 와야함 연결 ->||
--  first_name ||' ' || last_name AS "별칭" 쌍따옴표
--  first_name ||' ' || last_name AS "name"
--  first_name ||' ' || last_name "name" -- AS 생략가능
--  first_name ||' ' || last_name AS name -- 상따옴표 안붙여도됨
    first_name ||' ' || last_name AS "full name" -- 별칭 사이 공백있을때는 꼭 붙이기
-- 'Hello' ||' '|| 'World' -- 오라클 문자 도는 문자열 ''
    , CONCAT( CONCAT(first_name, ' '), last_name )
,hire_date
FROM employees;