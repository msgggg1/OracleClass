-- 설문진행중인 최신질문 가져오는 쿼리
with a AS(
    select rdate, row_number() over(order by rdate DESC)newest
    from survey
)
select content
from survey s JOIN a ON s.rdate = a.rdate
                JOIN question q ON q.sid = s.sid
where a.newest = 1 
    AND SYSDATE >= startDate AND SYSDATE <=endDate

UNION; 
-- 위 최신질문의 항목 가져오는 쿼리
with a AS(
    select rdate, row_number() over(order by rdate DESC)newest
    from survey
)
select aContent
from surveyanswer
where 
;
----------------------------------------------------------------------------
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
 

-- 설문 결과         
with a as(
    select (select count(v.aid) from vote v where v.sid = sa.sid)"총 참여자 수"
            ,aContent 항목
            ,(select count(v.aid) from vote v where v.aid = sa.aid)"항목별 투표수"
    FROm surveyanswer sa
)
select NVL("총 참여자 수",0) AS "총 참여자 수" 
        , 항목
        ,NVL( RPAD('■' , NVL("항목별 투표수"/"총 참여자 수"*30,0) , '■'),'|' )그래프
        ,NVL("항목별 투표수",0) AS "항목별 투표수"
        ,DECODE( "총 참여자 수", 0, '0%', ROUND("항목별 투표수"/"총 참여자 수"*100, 2)||'%')비율
from a;



SELECT 
    (SELECT COUNT(*) FROM vote v WHERE v.sid = 6) AS "총 참여자 수",
    sa.aContent AS "항목내용",
    COUNT(v.aid) AS "항목별 투표수",
    ROUND(COUNT(v.aid) * 100.0 / NULLIF((SELECT COUNT(*) FROM vote WHERE sid = 6), 0), 2) || '%' AS "퍼센트",
    RPAD('*', COUNT(v.aid), '*') AS "막대그래프"
FROM 
    SurveyAnswer sa
LEFT JOIN 
    Vote v ON sa.aid = v.aid

GROUP BY 
    sa.aContent
ORDER BY 
    "항목별 투표수" DESC;
    
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