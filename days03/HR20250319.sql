-- HR --
SELECT first_name, last_name
        , first_name || ' ' || last_name
        ,CONCAT(CONCAT(first_name, ' ' ),last_name)
FROM employees;

-- [ LIKE  ESCAPE 구문 설명 ]
select * -- last_name, salary 
from employees
where last_name LIKE '%a\_b%' ESCAPE'\'
--where last_name LIKE 'a_b%'
--where last_name LIKE '%a_b%' 
--where last_name LIKE '%A\_B%' ESCAPE '\'  --☜ last_name문자중에 ...A_B...와 같은 경우
order by salary;

-- employee_id 사원번호 154 사원의 last_name 'Cambrault' -> 수정 'a_brault'
-- DML 문 - INSERT, UPDATE, DELETE
UPDATE 테이블명
SET 수정할칼럼=칼럼값...여러개 올 수 있음
WHERE 수정할 조건;

UPDATE employees
SET last_name = 'a_brault'
WHERE employee_id = 154;

-- [문제] 100, 101, 102 사원의 last_name %들어간 이름으로 수정
100   Steven   K%ing
101   Neena   Koch%har
102   Lex   De Ha%an

UPDATE employees
SET last_name = 'K%ing'
WHERE employee_id = 100;

UPDATE employees
SET last_name = 'Koch%har'
WHERE employee_id = 101;

UPDATE employees
SET last_name = 'Ha%an'
WHERE employee_id = 102;

select * -- last_name, salary 
from employees;


-- [문제] last_name 속에 %가 있는 사원의 정보를 조회
SELECT *
FROM employees
WHERE last_name LIKE'%\%%' ESCAPE '\';

ROLLBACK; -- DML 후 항상 COMMIT or ROLLBACK

-- REGEXP_LIKE 함수 // LIKE는 연산자
SELECT *
FROM employees;

SELECT last_name, RPAD(' ',salary/1000/1, '*') "Salary"
FROM employees
WHERE department_id = 80
ORDER BY last_name, "Salary";
-- (풀이)
-- 오라클 나눗셈 연산자 / 자바 x 소수점 아래도 출력
SELECT last_name
--        , salary
--        , salary/1000 -- 정수/정수 -> 소수점까지 다 나옴
--        , ROUND ( salary /1000)
        ,RPAD( ' ', ROUND( salary /1000 )+1,'#' ) "Salary2"  --  , 자리수,
FROM employees
WHERE department_id = 80
ORDER BY last_name, "Salary2" ;

--
SELECT REGEXP_REPLACE(
        phone_number,
        '([[:digit:]]{3})\.([[:digit:]]{3})\.([[:digit:]]{4})',--\d,0-9 다 가능
        '(\1) \2-\3') "REGEXP_REPLACE"
FROM employees
ORDER BY "REGEXP_REPLACE";
--
SELECT last_name 
FROM employees
WHERE REGEXP_LIKE (last_name, '([aeiou])\1','i') -- 앞의 패턴 한번 더. \n -> 그룹화한 번호
ORDER BY last_name;






