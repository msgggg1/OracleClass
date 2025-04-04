-- PL/SQL 
SELECT * FROM t_member;
SELECT * FROM t_poll;
SELECT * FROM t_pollsub; --집계함수보다 성능 좋음
SELECT * FROM t_voter;
--
SELECT *  
FROM user_constraints  
WHERE table_name LIKE 'T_M%'  AND constraint_type = 'P';
--
INSERT INTO   T_MEMBER (  MEMBERSEQ,MEMBERID,MEMBERPASSWD,MEMBERNAME,MEMBERPHONE,MEMBERADDRESS )
VALUES                 (  1,         'admin', '1234',  '관리자', '010-1111-1111', '서울 강남구' );
INSERT INTO   T_MEMBER (  MEMBERSEQ,MEMBERID,MEMBERPASSWD,MEMBERNAME,MEMBERPHONE,MEMBERADDRESS )
VALUES                 (  2,         'hong', '1234',  '홍길동', '010-1111-1112', '서울 동작구' );
INSERT INTO   T_MEMBER (  MEMBERSEQ,MEMBERID,MEMBERPASSWD,MEMBERNAME,MEMBERPHONE,MEMBERADDRESS )
VALUES                 (  3,         'kim', '1234',  '김준석', '010-1111-1341', '경기 남양주시' );
    COMMIT;
--
  SELECT * 
  FROM t_member;
 -- 
  ㄹ. 회원 정보 수정
  로그인 -> (홍길동) -> [내 정보] -> 내 정보 보기 -> [수정] -> [이름][][][][][][] -> [저장]
  PL/SQL
  UPDATE T_MEMBER
  SET    MEMBERNAME = , MEMBERPHONE = 
  WHERE MEMBERSEQ = 2;
  ㅁ. 회원 탈퇴
  DELETE FROM T_MEMBER -- UPDATE 탈퇴회원 
  WHERE MEMBERSEQ = 2;
--
   INSERT INTO T_POLL (PollSeq,Question,SDate, EDAte , ItemCount,PollTotal, RegDate, MemberSEQ )
   VALUES             ( 1  ,'좋아하는 여배우?'
                          , TO_DATE( '2025-03-20 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , TO_DATE( '2025-03-30 18:00:00'   ,'YYYY-MM-DD HH24:MI:SS') 
                          , 5
                          , 0
                          , TO_DATE( '2025-01-01 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , 1
                    );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (1 ,'배슬기', 0, 1 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (2 ,'김옥빈', 0, 1 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (3 ,'아이유', 0, 1 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (4 ,'김선아', 0, 1 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (5 ,'홍길동', 0, 1 );      
   COMMIT;
--
 INSERT INTO T_POLL (PollSeq,Question,SDate, EDAte , ItemCount,PollTotal, RegDate, MemberSEQ )
   VALUES             ( 2  ,'좋아하는 과목?'
                          , TO_DATE( '2025-04-01 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , TO_DATE( '2025-04-15 18:00:00'   ,'YYYY-MM-DD HH24:MI:SS') 
                          , 4
                          , 0
                          , TO_DATE( '2024-03-20 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , 1
                    );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (6 ,'자바', 0, 2 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (7 ,'오라클', 0, 2 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (8 ,'HTML5', 0, 2 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (9 ,'JSP', 0, 2 );
   
   COMMIT;
--
   INSERT INTO T_POLL (PollSeq,Question,SDate, EDAte , ItemCount,PollTotal, RegDate, MemberSEQ )
   VALUES             ( 3  ,'좋아하는 색?'
                          , TO_DATE( '2025-04-11 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , TO_DATE( '2025-04-28 18:00:00'   ,'YYYY-MM-DD HH24:MI:SS') 
                          , 3
                          , 0
                          , TO_DATE( '2024-04-01 00:00:00'   ,'YYYY-MM-DD HH24:MI:SS')
                          , 1
                    );

INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (10 ,'빨강', 0, 3 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (11 ,'녹색', 0, 3 );
INSERT INTO T_PollSub (PollSubSeq          , Answer , ACount , PollSeq  ) 
VALUES                (12 ,'파랑', 0, 3 ); 
   
   COMMIT;                    
--
SELECT * FROM t_member;
SELECT * FROM t_poll;
SELECT * FROM t_pollsub;
SELECT * FROM t_voter;
--
-- 목록 뿌리기
SELECT *
FROM (
    SELECT  pollseq 번호, question 질문, membername 작성자 -- 실행계획 F10
         , sdate 시작일, edate 종료일
         , itemcount 항목수, polltotal 참여자수
         , CASE 
              WHEN  SYSDATE > edate THEN  '종료'
              WHEN  SYSDATE BETWEEN  sdate AND edate THEN '진행 중'
              ELSE '시작 전'
           END 상태 -- 추출속성   종료, 진행 중, 시작 전
    FROM t_poll p JOIN  t_member m ON m.memberseq = p.memberseq
    ORDER BY 번호 DESC
) t 
WHERE 상태 != '시작 전';  
-- 
SELECT question, membername
               , TO_CHAR(regdate, 'YYYY-MM-DD AM hh:mi:ss')
               , TO_CHAR(sdate, 'YYYY-MM-DD')
               , TO_CHAR(edate, 'YYYY-MM-DD')
               , CASE 
                  WHEN  SYSDATE > edate THEN  '종료'
                  WHEN  SYSDATE BETWEEN  sdate AND edate THEN '진행 중'
                  ELSE '시작 전'
               END 상태
               , itemcount
           FROM t_poll p JOIN t_member m ON p.memberseq = m.memberseq
           WHERE pollseq = 2;
--
  SELECT answer
           FROM t_pollsub
           WHERE pollseq = 2;
--
SELECT  polltotal  
FROM t_poll
WHERE pollseq = 2;
    -- 
SELECT answer, acount
    , ( SELECT  polltotal      FROM t_poll p   WHERE p.pollseq = ps.pollseq ) totalCount
    -- ,  막대그래프
    , ROUND (acount /  ( SELECT  polltotal      FROM t_poll    WHERE pollseq = 2 ) * 100) || '%'
 FROM t_pollsub ps
WHERE pollseq = 1;
select *
from t_member;
--
 INSERT INTO t_voter 
    ( vectorseq, username, regdate, pollseq, pollsubseq, memberseq )
    VALUES
    (      3   ,  '김준석'  , SYSDATE,   1  ,     3 ,        3 );
    
    COMMIT;
  -- 1)         2/3 자동 UPDATE  [트리거]
    -- (2) t_poll   totalCount = 1증가
    UPDATE   t_poll
    SET polltotal = polltotal + 1
    WHERE pollseq = 1;
    
    -- (3)t_pollsub   account = 1증가
    UPDATE   t_pollsub
    SET acount = acount + 1
    WHERE  pollsubseq = 3;
    
    commit; 
    
    
-- PL/SQL
-- 무조건 다 작성하고 시작
DECLARE -- 익명 프로시저, 한번만 쓰고 끝내겠다. 
    -- 선언블럭 : 변수 선언, 상수 선언, 매개변수
BEGIN
/* PL/SQL 안에서의 주석처리
    -- 실행블럭
        SELECT
        SELECT
        :
        INSERT; -- select 후
        INSERT;
        INSERT;
        :
        UPDATE;
        UPDATE; -- 여러개 올 수 있음
        UPDATE;
        :
        DELETE;
        DELETE;
        DELETE;
        DELETE;
        :
        */
EXCEPTION
    -- 예외처리블럭: 나중- 자바에서 처리'
END ;

-- 선언블럭, 
BEGIN 
END

-- 뷰, PL/SQL로 프로젝트 진행

-- 익명 프로시저 선언
DESC emp;
DECLARE
    -- 선언블럭 : [ 사원이름, 급여 저장할 변수 ], 상수
    -- vename VARCHAR2(10) ; -- 원래 자료형과 동일하게 -- ,(콤마) 인식못함. 금지
    -- %TYPE형 변수로 수정
    vename emp.ename%TYPE; -- DESC 안해도됨. 자료형 바꿨을때 프로시저도 바꿔야함 -> 안해도 됨. / 성능은 느리나 유지보수력 높음
    
    vpay NUMBER; -- 최대, emp테이블에 없어서 %type 못씀
    -- 상수선언 : 자바와 개념 동일함
    -- final double PI = 3.141592
    vPI CONSTANT NUMBER := 3.141592; -- CONSTANT 키워드 사용, 초기값이 있는 변수 선언
    -- := 대입연산자
    
BEGIN
    -- 실행블럭
    SELECT ename, sal+NVL(comm,0) pay
        INTO vename, vpay
--        INTO vpay
    FROM emp
    where empno = 7369;
    -- put()  ,  put_line()
    -- print(),  println()
    DBMS_output.put_line(vename || ', '||vpay);
    
-- EXCEPTION
END;
-- PL/SQL 실행 시 -> 무조건 블럭잡고 실행(중간중간 ;)

-- [문제] 30부서의 지역명을 얻어와서
-- 10번 부서의 지역명으로 설정하는 익명 프로시저 작성 + 테스트
update dept
set loc = (
    SELECT loc
    FROM dept
    WHERE deptno = 30
)
where deptno = 10;

rollback;

-- 익명프로시저
DECLARE
    vloc dept.loc%TYPE;
begin
    --1)
    SELECT loc INTO vloc
    FROM dept
    WHERE deptno = 30;
    --2) 
    UPDATE dept
    set loc = vloc
    where deptno = 10;
    -- commit
--exception
    -- rollback
end;


select *
from dept;

-- [문제] 30번 부서원들 중에 최고 급여(pay)를 받는 사원의 정보를 출력하는 쿼리 작성
-- ( empno, ename, hiredate, job, sal, comm )
-- 1) PL/SQL 사용하지 않고
    -- ㄱ. TOP-N
SELECT empno, ename, hiredate, job, pay
FROM(
    SELECT empno, ename, hiredate, job, sal+NVL(comm, 0)pay, rownum
    FROM emp 
    where deptno = 30
    ORDER BY sal+NVL(comm, 0) DESC
    ) t
    WHERE rownum = 1;
    -- ㄴ. RANK 함수
SELECT t.*
FROM(
    SELECT empno, ename, hiredate, job, sal+NVL(comm, 0)pay
            ,rank() OVER(ORDER BY sal+NVL(comm, 0) DESC) 순위
    FROM emp 
    where deptno = 30
    )t
Where 순위 = 1;
    
    -- ㄷ. 서브쿼리
SELECT t.*
FROM(
    SELECT empno, ename, hiredate, job, sal+NVL(comm, 0)pay
    FROM emp 
    where deptno = 30
    )t 
where t.pay = (SELECT MAX(sal+NVL(comm, 0)) FROM emp);



-- 2) PL/SQL 익명프로시저 사용
DECLARE--vloc dept.loc%TYPE;
    vmaxpay NUMBER;
    vdeptno dept.deptno%TYPE := 30;
    vempno emp.empno%TYPE;
    vename emp.ename%TYPE;
    vhiredate emp.hiredate%TYPE; 
    vjob emp.job%TYPE;
    vsal emp.sal%TYPE;
    vcomm emp.comm%TYPE;
BEGIN
    -- 1) 30번 부서에서 최고 급여액 조회
   SELECT MAX( sal + NVL(comm, 0) ) INTO vmaxpay
   FROM emp
   WHERE deptno = vdeptno;
   --2) 
   SELECT empno, ename, hiredate, job, sal, comm
    INTO vempno, vename, vhiredate, vjob, vsal, vcomm
   FROM emp
   WHERE deptno = vdeptno AND sal + NVL(comm, 0) =  vmaxpay;
    
    DBMS_OUTPUT.PUT_LINE('사원번호:' || vempno);
    DBMS_OUTPUT.PUT_LINE('사원명:' || vename);
    DBMS_OUTPUT.PUT_LINE('입사일자:' || vhiredate);
    
-- EXCEPTION
END;

-- 2-2) PL/SQL 익명프로시저 사용 + (%rowtype 변수)
DECLARE--vloc dept.loc%TYPE;
    vmaxpay NUMBER;
    vdeptno dept.deptno%TYPE := 30;
    
    vemprow emp%ROWTYPE;
BEGIN
    -- 1) 30번 부서에서 최고 급여액 조회
   SELECT MAX( sal + NVL(comm, 0) ) INTO vmaxpay
   FROM emp
   WHERE deptno = vdeptno;
   --2) 
   SELECT empno, ename, hiredate, job, sal, comm
    INTO vemprow.empno, vemprow.ename, vemprow.hiredate, vemprow.job, vemprow.sal, vemprow.comm
   FROM emp
   WHERE deptno = vdeptno AND sal + NVL(comm, 0) =  vmaxpay;
    
    DBMS_OUTPUT.PUT_LINE('> 사원번호:' || vemprow.empno);
    DBMS_OUTPUT.PUT_LINE('> 사원명:' || vemprow.ename);
    DBMS_OUTPUT.PUT_LINE('> 입사일자:' || vemprow.hiredate);
-- EXCEPTION
END;


DECLARE
    vename emp.ename%TYPE;
    vpay NUMBER;    
    vPI CONSTANT NUMBER := 3.141592; 
BEGIN
    SELECT ename, sal+NVL(comm,0) pay
        INTO vename, vpay -- 대입은 하나만, where 조건 없으면 오류
        --  커서(cursor) 사용하여 처리
    FROM emp;
   -- where empno = 7369;

    DBMS_output.put_line(vename || ', '||vpay);   
-- EXCEPTION
END;

-- := 대입 연산자
DECLARE 
    va NUMBER := 10;
    vb NUMBER;
    vc NUMBER;
begin
    vb := 20;
    vc := va + vb;
    DBMS_OUtpUT.put_line(va || '+'||vb||'='||vc);
--exception
end;

-- PL/SQL : 제어문
-- 자바: 
-- if( 조건식 ){
    -- 명령코딩
--}

IF 조건식 THEN
END IF;
-- 
if(조건식) {
}else{
}

IF 조건식 THEN
eLSE
END IF;

-- 
if( 조건식 ){
} else if{
}
:
else

-- 
IF 조건식 THEN
ELSIF 조건식 THEN
ELSIF 조건식 THEN
ELSIF 조건식 THEN
ELSE
END IF

-- [문제] 정수를 입력받아서 변수에 대입하고
--      홀수/짝수 라고 출력
DECLARE
    vnum NUMBER(4) := 0;
    vresult VARCHAR2(6);
BEGIN 
    vnum := :bindNumber; -- 바인드변수
    IF MOD(vnum,2) = 0 THEN vresult := '짝수';
    ELSE vresult := '홀수';
    END IF;
    DBMS_OUTPUT.PUT_LINE(vresult);
-- exception
END;

-- [문제] PL/SQL IF문 사용해서
-- 국어점수 입력받아서 수/우/미/양/가 출력 (익명 프로시저)

DECLARE
    vkor NUMBER(3);
    vgrade VARCHAR(3);
BEGIN
    vkor := :bindNumber;
    
    IF vkor between 0 and 100 then
        IF vkor >= 90 THEN 
            vgrade := '수';
        ELSIF vkor >= 80 THEN 
            vgrade := '우';
        ELSIF vkor >= 70 THEN 
            vgrade := '미';
        ELSIF vkor >= 60 THEN 
            vgrade := '양';
        ELSE vgrade := '가';
        END IF;
    ELSE
     RAISE_APPLICATION_ERROR(-20009, 'ScoreOutOfBound Exception.');
    END IF;
     
    DBMS_OUTPUT.PUT_LINE(vgrade);

exception
    WHEN OTHERS tHEn -- 어떤 예외가 발생하더라도
        DBMS_OUTPUT.PUT_line('점수입력 잘못(0~100)!!');
--    WHEN 예외 THEN
END;


DECLARE
    vkor NUMBER(3);
    vgrade VARCHAR(3);
BEGIN
    vkor := :bindNumber;
    
    IF vkor between 0 and 100 then
        
        CASE TRUNC(vkor/10)
            WHEN 10 then vgrade :='수'
            WHEN 9 then vgrade :='수'
            WHEN 8 then vgrade :='우'
            WHEN 7 then vgrade :='미'
            WHEN 6 then vgrade :='양'
            ELSE vgrade :='가'
         END   ;
    ELSE
     RAISE_APPLICATION_ERROR(-20009, 'ScoreOutOfBound Exception.');
    END IF;
     
    DBMS_OUTPUT.PUT_LINE(vgrade);

exception
    WHEN OTHERS tHEn -- 어떤 예외가 발생하더라도
        DBMS_OUTPUT.PUT_line('점수입력 잘못(0~100)!!');
--    WHEN 예외 THEN
END;

-- 
while(조건식){

}

WHILE 조건식
LOOP 
    명령코딩;
END LOOP;
--
while(true){
    if (참) break;
}

LOOP 
    -- 명령코딩;
    EXIT WHEM 조건식;
END LOOP;

-- [문제] 1~10까지의 합 출력 ( PL/SQL + WHILE 문 )
--출력형식 )  1+2+3+..+8+9+10 =55
DECLARE
    vi number(2) := 1;
    vsum number(3) := 0;
BEGIN
    WHILE ( vi <= 10)
    LOOP
        IF vi = 10 
        THEN DBMS_OUTPUT.PUT(vi);
        ELSE  DBMS_OUTPUT.PUT(vi||'+');
        END IF;
       
        vsum := vsum + vi;
        vi := vi + 1;
    END LOOP;
        DBMS_OUTPUT.PUT_line('='||vsum); -- 마지막엔 항상 Put_line 사용해야 출력스트림에 넣어놨다가 출력함. 출력하는 잡업
    
--    LOOP
--        vsum := vsum + vi;
--        vi := vi + 1;
--        EXIT WHEN vi = 11;
--    END LOOP;
    
END;

-- [문제] 1~10까지의 합 출력 ( PL/SQL + FOR 문 )

DECLARE
--    vi number(2) := 1; for문에서 사용되는 반복 변수 선언 하지 않아도 됨. 2,5씩 증가 등 여기서 못함. 
    vsum number(3) := 0;
BEGIN
    FOR vi IN REVERSE 1..10 
    LOOP
        IF vi = 10 
        THEN DBMS_OUTPUT.PUT(vi);
        ELSE  DBMS_OUTPUT.PUT(vi||'+');
        END IF;
         vsum := vsum + vi;
    END LOOP;

        DBMS_OUTPUT.PUT_line('='||vsum); 
END;

-- [ GOTO문 ]
DECLARE
    vchk NUMBER := 0;
    
BEGIN
     -- 강제로 이동 
    <<top>>
    vchk := vchk + 1;
    DBMS_OUTPUT.PUT_line(vchk);
    IF vchk != 5 then 
        GOTO top;
    END if;
--EXCEPTION
END;

-- GOTO 문 가능하면 사용하지 말아야
--
-- DECLARE
BEGIN
  --
  GOTO first_proc;
  --
  <<second_proc>>
  DBMS_OUTPUT.PUT_LINE('> 2 처리 ');
  GOTO third_proc; 
  -- 
  --
  <<first_proc>>
  DBMS_OUTPUT.PUT_LINE('> 1 처리 ');
  GOTO second_proc; 
  -- 
  --
  --
  <<third_proc>>
  DBMS_OUTPUT.PUT_LINE('> 3 처리 '); 
--EXCEPTION
END;

-- [문제] WHiLE문사용 구구단 2단~9단(가로)
WHILE 조건식
LOOP 
    명령코딩;
END LOOP;

DECLARE
    vdan number(2) := 2;
    vx number(2) := 1;
BEGIN
    WHILE (vdan <= 9)
    LOOP 
        vx := 1;
        WHILE ( vx <= 9)
        LOOP
          DBMS_OUTPUT.PUT(RPAD(vdan||'*'||vx || '=' || vdan*vx, 10)); 
          vx := vx + 1;
        END LOOP;
      vdan := vdan + 1;
      DBMS_OUTPUT.PUT_line(' '); 
    END LOOP;
        
END;

-- [문제] WHiLE문사용 구구단 2단~9단(세로)
DECLARE
    vdan number(2) := 2;
    vx number(2) := 1;
BEGIN
    WHILE (vx <= 9)
    LOOP 
        vdan := 2;
        WHILE ( vdan <= 9)
        LOOP
          DBMS_OUTPUT.PUT(RPAD(vdan||'*'||vx || '=' || vdan * vx , 10)); 
          vdan := vdan + 1;
        END LOOP;
      vx := vx + 1;
      DBMS_OUTPUT.PUT_line(' '); 
    END LOOP;
        
END;

-- [문제] FOR문사용 구구단 2단~9단(가로)
BEGIN
    For vdan in 2..9
        LOOP
        for vx in 1..9
            LOOP 
            DBMS_OUTPUT.PUT(RPAD(vdan||'*'||vx || '=' || vdan*vx, 10)); 
            END LOOP;
      DBMS_OUTPUT.PUT_line(' '); 
    END LOOP;
        
END;


-- [문제] FOR문사용 구구단 2단~9단(세로)
BEGIN
    for vx in 1..9
    LOOP
        for vdan in 2..9
        LOOP 
          DBMS_OUTPUT.PUT(RPAD(vdan||'*'||vx || '=' || vdan * vx , 10)); 
        END LOOP;
      DBMS_OUTPUT.PUT_line(' '); 
    END LOOP;
        
END;


DECLARE
    vdan number(2) := 2;
    vx number(2) := 1;
BEGIN
    FOR vx in 1..9
    LOOP 
        vdan := 2;
        FOR vdan in 2..9
        LOOP
          DBMS_OUTPUT.PUT(RPAD(vdan||'*'||vx || '=' || vdan * vx , 10)); 
        END LOOP;
      DBMS_OUTPUT.PUT_line(' '); 
    END LOOP;
        
END;


DECLARE
  vdan NUMBER := 2;
  vnum NUMBER;
  vres NUMBER;
BEGIN
  FOR vdan IN 2..9 LOOP
    FOR vnum IN 1..9 LOOP
      vres := vdan * vnum;
      IF vres < 10 THEN
        DBMS_OUTPUT.PUT(vdan || ' * ' || vnum || ' =  ' || vres || '    '); -- 한 자리 수일 경우 앞에 공백 추가
      ELSE
        DBMS_OUTPUT.PUT(vdan || ' * ' || vnum || ' = ' || vres || '    ');
      END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
END;

DECLARE
    vdan NUMBER := 2;
    vnum NUMBER;
    vres NUMBER;
BEGIN
  FOR vnum IN 1..9 LOOP
    FOR vdan IN 2..9 LOOP
        vres := vdan * vnum;
        IF vres < 10 THEN
            DBMS_OUTPUT.PUT(vdan || ' * ' || vnum || ' =  ' || vres || '    '); -- 한 자리 수일 경우 앞에 공백 추가
        ELSE
            DBMS_OUTPUT.PUT(vdan || ' * ' || vnum || ' = ' || vres || '    ');
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
END;

