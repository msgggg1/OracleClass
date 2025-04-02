select * from all_tables;

drop table vote;
drop table SurveyAnswer;
drop table Question;
drop table survey;
drop table member;

create table grade (
    gid int primary key, 
    grade varchar2(20)
);

create table member (
        mid int PRIMARY KEY,
        gid int,
        name varchar2(30),
        constraint fk_member_grade FOREIGN key(gid) REFERENCES grade(gid)
);
        
create table survey (
        sid int PRIMARY KEY,
        mid int,
        startDate date,
        endDate date,
        rdate date,
        voteCnt int,
        content varchar2(255),
        constraint fk_survey_writer FOREIGN key(mid) REFERENCES member(mid)
);

create table SurveyAnswer (
        aid int PRIMARY KEY,
        sid int,
        aContent varchar2(255),
        CONSTRAINT fk_answer_question FOREIGN key(sid) REFERENCES survey(sid)
);
     
create table vote (
        vid int primary key,
        mid int,
        sid int,
        aid int,
        CONSTRAINT fk_vote_member FOREIGN KEY (mid) REFERENCES Member(mid),
        CONSTRAINT fk_vote_survey FOREIGN KEY (sid) REFERENCES Survey(sid),
        CONSTRAINT fk_vote_answer FOREIGN KEY (aid) REFERENCES SurveyAnswer(aid)
);
select *
from surveyanswer;

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

INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (1, 1, '2023-01-01', '2023-01-15', '2023-01-16', 100, '어떤 음식을 가장 좋아하시나요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (2, 2, '2023-02-01', '2023-02-28', '2023-03-01', 250, '가장 좋아하는 영화 장르는 무엇인가요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (3, 3, '2023-03-01', '2023-03-15', '2023-03-16', 150, '여행 가고 싶은 나라는 어디인가요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (4, 4, '2023-04-01', '2023-04-30', '2023-05-01', 300, '가장 좋아하는 운동은 무엇인가요?');
INSERT INTO survey (sid, mid, startDate, endDate, rdate, voteCnt, content) VALUES (5, 5, '2023-05-01', '2023-05-15', '2023-05-16', 200, '가장 좋아하는 음악 장르는 무엇인가요?');
select * from survey;

INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (1, 1, '한식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (2, 1, '양식');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (3, 2, '로맨스');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (4, 2, '액션');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (5, 3, '프랑스');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (6, 3, '이탈리아');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (7, 4, '축구');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (8, 4, '농구');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (9, 5, '팝');
INSERT INTO SurveyAnswer (aid, sid, aContent) VALUES (10, 5, '락');
select * from SurveyAnswer;

INSERT INTO vote (vid, mid, sid, aid) VALUES (1, 1, 1, 1);
INSERT INTO vote (vid, mid, sid, aid) VALUES (2, 2, 2, 3);
INSERT INTO vote (vid, mid, sid, aid) VALUES (3, 3, 3, 5);
INSERT INTO vote (vid, mid, sid, aid) VALUES (4, 4, 4, 7);
INSERT INTO vote (vid, mid, sid, aid) VALUES (5, 5, 5, 9);
INSERT INTO vote (vid, mid, sid, aid) VALUES (6, 1, 1, 2);
INSERT INTO vote (vid, mid, sid, aid) VALUES (7, 2, 2, 4);
INSERT INTO vote (vid, mid, sid, aid) VALUES (8, 3, 3, 6);
INSERT INTO vote (vid, mid, sid, aid) VALUES (9, 4, 4, 8);
INSERT INTO vote (vid, mid, sid, aid) VALUES (10, 5, 5, 10);
select * from vote;

-------------------------------------------------------------------------
UPDATE survey
SET
    startDate = DATE '2025-01-01' + DBMS_RANDOM.VALUE(0, 150),
    endDate = DATE '2025-01-01' + DBMS_RANDOM.VALUE(0, 150),
    rdate = DATE '2025-01-01' + DBMS_RANDOM.VALUE(0, 150)
WHERE
    startDate < DATE '2025-06-01' AND endDate < DATE '2025-06-01' AND rdate < DATE '2025-06-01';

UPDATE survey
SET
    startDate = LEAST(startDate, endDate),
    endDate = GREATEST(startDate, endDate),
    rdate = LEAST(rdate, startDate);


----------------------------------------------------------------------
select * from all_tables;

drop table vote;
drop table SurveyAnswer;
drop table survey;
drop table member;
drop table grade;

create table grade (
    gid int primary key, 
    grade varchar2(20)
);

create table member (
        mid int PRIMARY KEY,
        gid int,
        name varchar2(30),
        constraint fk_member_grade FOREIGN key(gid) REFERENCES grade(gid)
);
        
create table survey (
        sid int PRIMARY KEY,
        mid int,
        startDate date,
        endDate date,
        rdate date,
        voteCnt int,
        content varchar2(255),
        constraint fk_survey_writer FOREIGN key(mid) REFERENCES member(mid)
);

create table SurveyAnswer (
        aid int PRIMARY KEY,
        sid int,
        aContent varchar2(255),
        CONSTRAINT fk_answer_question FOREIGN key(sid) REFERENCES survey(sid)
);
     
create table vote (
        vid int primary key,
        mid int,
        sid int,
        aid int,
        CONSTRAINT fk_vote_member FOREIGN KEY (mid) REFERENCES Member(mid),
        CONSTRAINT fk_vote_survey FOREIGN KEY (sid) REFERENCES Survey(sid),
        CONSTRAINT fk_vote_answer FOREIGN KEY (aid) REFERENCES SurveyAnswer(aid)
);


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
















