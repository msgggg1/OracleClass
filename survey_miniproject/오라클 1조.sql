-- 전체 테이블 확인
select * from all_tables;

-- 테이블 제거
drop table vote;
drop table SurveyAnswer;
drop table survey;
drop table member;
drop table grade;

-- 테이블 생성
create table grade (
    gid int primary key, 
    grade varchar2(20) not null
);

create table member (
        mid int PRIMARY KEY,
        gid int not null,
        name varchar2(30)  not null,
        constraint fk_member_grade FOREIGN key(gid) REFERENCES grade(gid)
);
        
create table survey (
        sid int PRIMARY KEY,
        mid int not null,
        startDate date not null,
        endDate date not null,
        rdate date not null,
        voteCnt int not null,
        content varchar2(255)  not null,
        constraint fk_survey_writer FOREIGN key(mid) REFERENCES member(mid)
);

create table SurveyAnswer (
        aid int PRIMARY KEY,
        sid int not null,
        aContent varchar2(255) not null,
        CONSTRAINT fk_answer_question FOREIGN key(sid) REFERENCES survey(sid)
);
     
create table vote (
        vid int primary key,
        mid int not null,
        sid int not null,
        aid int not null,
        CONSTRAINT fk_vote_member FOREIGN KEY (mid) REFERENCES Member(mid),
        CONSTRAINT fk_vote_survey FOREIGN KEY (sid) REFERENCES Survey(sid),
        CONSTRAINT fk_vote_answer FOREIGN KEY (aid) REFERENCES SurveyAnswer(aid)
);

-- 더미데이터 추가 및 확인
INSERT INTO grade (gid, grade) VALUES (1, '일반회원');
INSERT INTO grade (gid, grade) VALUES (2, '우수회원');
INSERT INTO grade (gid, grade) VALUES (3, '관리자');
select * from grade;

INSERT INTO member (mid, gid, name) VALUES (1, 1, '김철수');
INSERT INTO member (mid, gid, name) VALUES (2, 2, '박영희');
INSERT INTO member (mid, gid, name) VALUES (3, 3, '최민수');
INSERT INTO member (mid, gid, name) VALUES (4, 1, '이지은');
INSERT INTO member (mid, gid, name) VALUES (5, 2, '송중기');
select * from member;

INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (1, 1, '2025-04-06', '2025-05-26', '2025-01-18', 4, '어떤 음식을 가장 좋아하시나요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (2, 2, '2025-04-05', '2025-04-16', '2025-04-04', 4, '가장 좋아하는 영화 장르는 무엇인가요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (3, 3, '2025-02-04', '2025-05-19', '2025-02-04', 4, '여행 가고 싶은 나라는 어디인가요?');
select * from survey;

INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (1, 1, '한식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (2, 1, '양식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (3, 1, '중식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (4, 1, '일식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (5, 2, '로맨스');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (6, 2, '액션');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (7, 2, '판타지');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (8, 2, '뮤지컬');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (9, 3, '프랑스');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (10, 3, '이탈리아');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (11, 3, '미국');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (12, 3, '한국');
select * from SurveyAnswer;

INSERT INTO vote (vid, mid, sid, aid) VALUES (1, 1, 1, 1);
INSERT INTO vote (vid, mid, sid, aid) VALUES (2, 3, 1, 2);
INSERT INTO vote (vid, mid, sid, aid) VALUES (3, 2, 1, 3);
INSERT INTO vote (vid, mid, sid, aid) VALUES (4, 2, 2, 6);
INSERT INTO vote (vid, mid, sid, aid) VALUES (5, 3, 2, 5);
INSERT INTO vote (vid, mid, sid, aid) VALUES (6, 4, 2, 7);
INSERT INTO vote (vid, mid, sid, aid) VALUES (7, 4, 3, 9);
INSERT INTO vote (vid, mid, sid, aid) VALUES (8, 2, 3, 9);
INSERT INTO vote (vid, mid, sid, aid) VALUES (9, 1, 3, 11);
INSERT INTO vote (vid, mid, sid, aid) VALUES (10, 5, 3, 10);
select * from vote;

-- 1) 최신 설문조사 질문과 문항 출력하는 쿼리 작성
SELECT 
    s.sid AS 설문번호,
    s.content AS 설문질문,
    a.aid AS 보기번호,
    a.aContent AS 보기내용
FROM 
    survey s
JOIN 
    SurveyAnswer a ON s.sid = a.sid
WHERE 
    s.rdate = (SELECT MAX(rdate) FROM survey)
ORDER BY 
    a.aid;   

-- 2) 설문 목록
select
sid 번호
, content 질문
, (select mid from member where mid = s.mid) 작성자
, startDate 시작일
, endDate 종료일
, voteCnt 항목수
, (select count(*) from vote v where v.sid = s.sid) 참여자수
, case when startDate < sysdate and endDate > sysdate then '진행중'
       when startDate > sysdate then '준비중'
       when endDate < sysdate then '종료' end 상태
from survey s;

select sysdate from dual;

-- 3) 설문 질문 추가
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) 
VALUES (4, 4, '2025-02-04', '2025-05-19', '2025-02-04', 5, '가장 좋아하는 여자 연애인은?');

INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (13, 4, '배슬기');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (14, 4, '김옥빈');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (15, 4, '아이비');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (16, 4, '한효주');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (17, 4, '김선아');

-- 4) 내용
-- 설문 상세보기
select content 질문, name 작성자
        , TO_CHAR(rdate, 'YYYY-MM-DD pm HH12:mm:ss') 작성일
        , TO_CHAR(startDate, 'YYYY-MM-DD') 설문시작일
        , TO_CHAR(endDate, 'YYYY-MM-DD') 설문종료일
        , CASE
            WHEN SYSDATE BETWEEN startDate AND endDate THEN '진행중'
            WHEN SYSDATE < startDate THEN '진행전'
            ELSE '종료'
         END 상태
        , (SELECT COUNT(aContent) FROM surveyAnswer sa2 where sa2.sid = s.sid)항목수
         , (SELECT LISTAGG(aContent, ', ') WITHIN GROUP (ORDER BY sa2.aid) 
            FROM SurveyAnswer sa2 where sa2.sid = s.sid)항목
from survey s JOIN member m ON s.mid= m.mid;

-- 설문 결과 출력
with a as(
    select (select count(v.aid) from vote v where v.sid = sa.sid)"총 참여자 수"
            ,aContent 항목
            ,(select count(v.aid) from vote v where v.aid = sa.aid)"항목별 투표수"
    FROm surveyanswer sa
)
select NVL("총 참여자 수",0) AS "총 참여자 수" 
        , 항목
        , NVL(RPAD(' ', ROUND(NVL("항목별 투표수" / NULLIF("총 참여자 수", 0) * 30 , 0)), '■'), ' |') AS 그래프
        , NVL("항목별 투표수",0) AS "항목별 투표수"
        ,DECODE( "총 참여자 수", 0, '0%', ROUND("항목별 투표수"/"총 참여자 수"*100, 2)||'%')비율
from a;

