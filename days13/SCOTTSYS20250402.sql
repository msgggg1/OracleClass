drop table vote;

create table member (
        mid int PRIMARY KEY,
        name varchar2(30),
        "level" varchar2(20)
);
        
create table survey (
        sid int PRIMARY KEY,
        mid int,
        sCnt int,
        startDate date,
        endDate date,
        rdate date,
        voteCnt int,
        constraint fk_survey_writer FOREIGN key(mid) REFERENCES member(mid)
);

create table Question (
        qid int PRIMARY KEY,
        sid int,
        Qcontent varchar2(255),
        constraint fk_question_survey FOREIGN key(sid) REFERENCES survey(sid)
);

create table SurveyAnswer (
        aid int PRIMARY KEY,
        qid int,
        aContent varchar2(255),
        aCnt int,
        CONSTRAINT fk_answer_question FOREIGN key(qid) REFERENCES question(qid)
);
     
create table vote (
        vid int primary key,
        mid int,
        qid int,
        sid int,
        aid int,
        CONSTRAINT fk_vote_member FOREIGN KEY (mid) REFERENCES Member(mid),
        CONSTRAINT fk_vote_survey FOREIGN KEY (sid) REFERENCES Survey(sid),
        CONSTRAINT fk_vote_question FOREIGN KEY (qid) REFERENCES Question(qid),
        CONSTRAINT fk_vote_answer FOREIGN KEY (aid) REFERENCES SurveyAnswer(aid)
);











