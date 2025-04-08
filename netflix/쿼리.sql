-- 메인화면
SELECT c.*
FROM content c
JOIN video v ON c.contentID = v.contentID
WHERE c.contentType = 'Series'
  AND ROWNUM = 1
ORDER BY DBMS_RANDOM.VALUE; -- 또는 최근 등록순, 평점순 등


SELECT c.title, c.thumbnailURL, v.videoID, v.epiTitle
FROM wishList w JOIN video v ON w.videoID = v.videoID
                JOIN content c ON v.contentID = c.contentID
WHERE w.profileID = :prof_id;

select *
from profile;

-- 내가 찜한 리스트
CREATE OR REPLACE VIEW vw_my_wishlist AS
SELECT
    w.profileID,
    c.contentID,
    c.title,
    c.thumbnailURL,
    c.videoQuality,
    v.videoID,
    v.epiTitle,
    v.releaseDate
FROM wishList w
JOIN video v ON w.videoID = v.videoID
JOIN content c ON v.contentID = c.contentID;

-- 시청 중인 콘텐츠
CREATE OR REPLACE VIEW vw_my_viewing AS
SELECT
    vh.profileID,
    c.contentID,
    c.title,
    c.thumbnailURL,
    vh.lastViewat,
    vh.isCompleted,
    v.videoID
FROM viewingHistory vh
JOIN video v ON vh.videoID = v.videoID
JOIN content c ON v.contentID = c.contentID
WHERE vh.isCompleted = 'N';

-- 메인추천 콘텐츠 -- 알고리즘 무(임의)
CREATE OR REPLACE VIEW vw_main_recommendation AS
SELECT *
FROM (
    SELECT
        c.contentID,
        c.title,
        c.mainImage,
        c.videoQuality,
        c.description,
        c.releaseDate,
    
    FROM content c
    ORDER BY DBMS_RANDOM.VALUE
)
WHERE ROWNUM = 1;

-- 메인 콘텐츠
SELECT * FROM vw_main_recommendation;

-- 내가 찜한 리스트
SELECT * FROM vw_my_wishlist WHERE profileID = :prof_id;

-- 시청 중인 콘텐츠
SELECT * FROM vw_my_viewing WHERE profileID = :prof_id;
