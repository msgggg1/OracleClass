

--search = 원어, 언어, 출력, 검색어 를 입력받아 내용을 찾는 쿼리
-- 뷰생성
CREATE OR REPLACE VIEW ContentViewWithAudioLang AS
SELECT
    c.contentID,
    c.title,
    c.originTitle,
    c.contentType,
    c.description,
    c.releaseYear,
    c.originLang,
    c.productionCountry,
    c.videoQuality,
    c.thumbnailURL,
    c.mainImage,
    v.videoID,
    v.seasonNum,
    v.epiNum,
    v.epiTitle,
    al.Language AS AvailableAudioLanguage,
    al.audioLangID
FROM content c
JOIN video v ON c.contentID = v.contentID
JOIN audioLang al ON v.audioLangID = al.audioLangID;


DECLARE
    -- 사용자 입력을 받을 변수 선언 (치환 변수 사용)
    -- SQL*Plus/SQLcl 에서는 값 입력 시 문자열은 작은따옴표(')로 묶어주는 것이 좋습니다.
    -- SQL Developer 에서는 보통 팝업창이 뜨며, 문자열에 따옴표를 입력할 필요 없습니다.
    input_origin_lang    VARCHAR2(50) := '&input_origin_lang';   -- 예: 'English' 또는 '' (입력 안 함)
    input_available_lang VARCHAR2(50) := '&input_available_lang';-- 예: '한국어' 또는 ''
    input_release_year   VARCHAR2(10) := '&input_release_year';  -- 예: 2010 또는 '' (문자열로 받아서 처리)
    input_keyword        VARCHAR2(100) := '&input_keyword';       -- 예: 'Inception' 또는 ''

    -- 쿼리에서 사용할 실제 조건 변수
    v_origin_lang      VARCHAR2(50);
    v_available_lang   VARCHAR2(50);
    v_release_year     NUMBER;
    v_keyword          VARCHAR2(100);

BEGIN
    -- 입력값이 비어있으면 NULL로 처리 (해당 조건 무시용)
    v_origin_lang    := CASE WHEN input_origin_lang IS NULL OR TRIM(input_origin_lang) = '' THEN NULL ELSE input_origin_lang END;
    v_available_lang := CASE WHEN input_available_lang IS NULL OR TRIM(input_available_lang) = '' THEN NULL ELSE input_available_lang END;
    v_keyword        := CASE WHEN input_keyword IS NULL OR TRIM(input_keyword) = '' THEN NULL ELSE input_keyword END;

    -- 출시 년도 입력값 처리 (숫자 변환 시도, 오류 시 NULL)
    BEGIN
        v_release_year := CASE WHEN input_release_year IS NULL OR TRIM(input_release_year) = '' THEN NULL ELSE TO_NUMBER(input_release_year) END;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('경고: 유효하지 않은 출시 년도 입력 [' || input_release_year || ']. 년도 필터링을 무시합니다.');
            v_release_year := NULL;
    END;

    -- 입력받은 조건으로 ContentViewWithAudioLang 뷰 검색
    FOR rec IN (
        SELECT DISTINCT
            contentID,
            title,
            originTitle,
            contentType,
            description,
            releaseYear,
            originLang,
            AvailableAudioLanguage
        FROM ContentViewWithAudioLang
        WHERE 1=1  -- 조건 시작을 용이하게 하기 위한 더미 조건
          AND (v_origin_lang IS NULL OR originLang = v_origin_lang) -- 원본 언어 조건 (NULL이면 무시)
          AND (v_available_lang IS NULL OR AvailableAudioLanguage = v_available_lang) -- 오디오 언어 조건 (NULL이면 무시)
          AND (v_release_year IS NULL OR releaseYear = v_release_year) -- 출시 년도 조건 (NULL이면 무시)
          AND ( -- 키워드 조건 (NULL이면 무시)
                v_keyword IS NULL OR
                LOWER(title) LIKE '%' || LOWER(v_keyword) || '%'
             OR LOWER(originTitle) LIKE '%' || LOWER(v_keyword) || '%'
             OR LOWER(description) LIKE '%' || LOWER(v_keyword) || '%'
              )
    ) LOOP
        -- 결과 출력
        DBMS_OUTPUT.PUT_LINE('제목: ' || rec.title);
        DBMS_OUTPUT.PUT_LINE('원제: ' || rec.originTitle);
        DBMS_OUTPUT.PUT_LINE('유형: ' || rec.contentType);
        DBMS_OUTPUT.PUT_LINE('출시년도: ' || rec.releaseYear);
        DBMS_OUTPUT.PUT_LINE('원본 언어: ' || rec.originLang);
        DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || rec.AvailableAudioLanguage);
        DBMS_OUTPUT.PUT_LINE('내용: ' || rec.description);
        DBMS_OUTPUT.PUT_LINE('---------------------------');
    END LOOP;

    -- 검색 결과가 없는 경우 메시지 출력 (선택 사항)
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 검색 결과가 없습니다.');
    END IF;

END;
/

--인기순 TOP 10 출력
CREATE OR REPLACE PROCEDURE sp_show_popular_cat_content (
    p_profile_id IN profile.profileID%TYPE
)
AS
    -- 커서: 사용자 평가, 시청 시간, 시청자 수 기반으로 콘텐츠 정렬
    CURSOR popular_content_cursor IS -- 커서 이름 변경 고려 가능 (예: popular_content_cursor)
        WITH RatingsSummary AS (
            -- 콘텐츠별 긍정적 평가(좋아요) 집계
            SELECT contentID, COUNT(*) as positive_ratings
            FROM userRating
            WHERE ratingType = 1 -- '좋아요'를 1로 가정 (필요시 다른 타입 추가 가능: IN (1, 2))
            GROUP BY contentID
        ),
        WatchTimeSummary AS (
            -- 콘텐츠별 총 시청 시간(초) 집계
            SELECT v.contentID, SUM(vh.totalViewingTime) as total_watch_seconds
            FROM viewingHistory vh
            JOIN video v ON vh.videoID = v.videoID
            GROUP BY v.contentID
        ),
        ViewCountSummary AS (
            -- 콘텐츠별 고유 시청자 수 집계
            SELECT v.contentID, COUNT(DISTINCT vh.profileID) as distinct_viewers
            FROM viewingHistory vh
            JOIN video v ON vh.videoID = v.videoID
            GROUP BY v.contentID
        )
        -- 메인 쿼리: 콘텐츠 정보와 집계된 점수들을 결합하여 정렬
        SELECT
            c.contentID, -- 결과 확인 및 디버깅 위해 contentID 포함
            c.title,
            c.thumbnailURL,
            NVL(vc.distinct_viewers, 0) as viewers,       -- 결과 확인용 (출력 안해도 됨)
            NVL(wt.total_watch_seconds, 0) as watch_secs, -- 결과 확인용 (출력 안해도 됨)
            NVL(rs.positive_ratings, 0) as ratings        -- 결과 확인용 (출력 안해도 됨)
        FROM content c
        LEFT JOIN ViewCountSummary vc ON c.contentID = vc.contentID -- 조회수 정보 결합
        LEFT JOIN WatchTimeSummary wt ON c.contentID = wt.contentID -- 시청시간 정보 결합
        LEFT JOIN RatingsSummary rs ON c.contentID = rs.contentID   -- 평가 정보 결합
        ORDER BY
            viewers DESC,        -- 1순위: 고유 시청자 수 내림차순
            watch_secs DESC,     -- 2순위: 총 시청 시간 내림차순
            ratings DESC,        -- 3순위: 긍정 평가 수 내림차순
            c.title ASC;         -- 4순위: 제목 오름차순

    v_profile_nickname profile.nickname%TYPE;
    v_found BOOLEAN := FALSE;

BEGIN
    -- 프로필 닉네임 조회
    BEGIN
        SELECT nickname INTO v_profile_nickname
        FROM profile
        WHERE profileID = p_profile_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_profile_nickname := '알 수 없음';
    END;

    -- 출력 메시지 헤더 (정렬 기준 반영하여 수정)
    DBMS_OUTPUT.PUT_LINE('--- 프로필 [' || v_profile_nickname || '] (ID: ' || p_profile_id || ') 님, 현재 인기 콘텐츠 목록입니다 ---');
    DBMS_OUTPUT.PUT_LINE('-- (고유 시청자 수, 총 시청 시간, 좋아요 평가 수 기반 정렬) --');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------');

    -- 커서 루프 실행 (수정된 커서 사용)
    FOR rec IN popular_content_cursor LOOP
        v_found := TRUE;
        -- 출력 형식 (필요시 정렬 기준 점수도 함께 출력하여 확인 가능)
        DBMS_OUTPUT.PUT_LINE('제목: ' || rec.title || ', 썸네일: ' || rec.thumbnailURL);
        -- DBMS_OUTPUT.PUT_LINE('  (시청자: ' || rec.viewers || ', 시청시간(초): ' || rec.watch_secs || ', 좋아요: ' || rec.ratings || ')'); -- 디버깅/확인용
    END LOOP;

    -- 커서 결과가 없을 때 메시지
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('현재 집계된 인기 콘텐츠가 없습니다.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        -- 오류 메시지 수정 (프로시저 목적 반영)
        DBMS_OUTPUT.PUT_LINE('오류 발생: 프로필 ID ' || p_profile_id || '에 대한 인기 콘텐츠 조회 중 문제 발생 - ' || SQLERRM);
END;
/
-- 인기순 TOP 10 프로시저 실행 부분
 BEGIN
     sp_show_popular_cat_content(p_profile_id => &profile_id); -- 프로시저 이름은 유지
 END;
 /


-- 신작/구작 인기순 (신/구작 기준: 1년)

CREATE OR REPLACE PROCEDURE sp_show_new_old_content (
    p_profile_id IN profile.profileID%TYPE
)
AS
    c_new_release_days CONSTANT NUMBER := 365; -- '신작' 기준 정의 상수 (1년 = 365일)

    CURSOR content_cursor (cv_filter_type VARCHAR2) IS
        WITH RatingsSummary AS (
            SELECT contentID, COUNT(*) as positive_ratings
            FROM userRating
            WHERE ratingType = 1
            GROUP BY contentID
        ),
        WatchTimeSummary AS (
            SELECT v.contentID, SUM(vh.totalViewingTime) as total_watch_seconds
            FROM viewingHistory vh
            JOIN video v ON vh.videoID = v.videoID
            GROUP BY v.contentID
        ),
        ViewCountSummary AS (
            SELECT v.contentID, COUNT(DISTINCT vh.profileID) as distinct_viewers
            FROM viewingHistory vh
            JOIN video v ON vh.videoID = v.videoID
            GROUP BY v.contentID
        )
        SELECT
            c.contentID,
            c.title,
            c.thumbnailURL,
            c.releaseDate,
            NVL(vc.distinct_viewers, 0) as viewers,
            NVL(wt.total_watch_seconds, 0) as watch_secs,
            NVL(rs.positive_ratings, 0) as ratings -- '좋아요' 수는 내부 정렬에는 사용되지만 출력에서는 제외됨
        FROM content c
        LEFT JOIN ViewCountSummary vc ON c.contentID = vc.contentID
        LEFT JOIN WatchTimeSummary wt ON c.contentID = wt.contentID
        LEFT JOIN RatingsSummary rs ON c.contentID = rs.contentID
        WHERE
            (UPPER(cv_filter_type) = 'NEW' AND c.releaseDate >= SYSDATE - c_new_release_days)
         OR (UPPER(cv_filter_type) = 'OLD' AND c.releaseDate < SYSDATE - c_new_release_days)
        ORDER BY
            viewers DESC,
            watch_secs DESC,
            ratings DESC, -- 정렬 기준에는 '좋아요'가 여전히 포함됨
            CASE WHEN UPPER(cv_filter_type) = 'NEW' THEN c.releaseDate END DESC NULLS LAST,
            CASE WHEN UPPER(cv_filter_type) = 'OLD' THEN c.releaseDate END ASC NULLS LAST,
            c.title ASC;

    v_profile_nickname profile.nickname%TYPE;
    v_found            BOOLEAN;

BEGIN
    BEGIN
        SELECT nickname INTO v_profile_nickname
        FROM profile
        WHERE profileID = p_profile_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || p_profile_id || '를 찾을 수 없습니다.'); -- 이모티콘 제거
            RETURN;
    END;

    -- 헤더 출력 (이모티콘 제거)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('프로필 [' || v_profile_nickname || '] (ID: ' || p_profile_id || ') - 신작/구작 콘텐츠 목록');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 80, '='));

    -- 섹션 1: 신작 목록 (지난 1년 이내)
    DBMS_OUTPUT.PUT_LINE('인기 **신작** 목록 (' || c_new_release_days || '일 이내)'); -- 이모티콘 제거
    -- DBMS_OUTPUT.PUT_LINE('정렬 기준: ...'); -- 정렬 기준 설명 줄 제거
    v_found := FALSE;
    FOR rec IN content_cursor('NEW') LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('  - [' || rec.title || ']');
        DBMS_OUTPUT.PUT_LINE('    썸네일: ' || rec.thumbnailURL);
        -- '좋아요' 출력 부분 제거
        DBMS_OUTPUT.PUT_LINE('    출시일: ' || TO_CHAR(rec.releaseDate, 'YYYY-MM-DD') ||
                             ' | 시청자: ' || rec.viewers ||
                             ' | 총시청(초): ' || rec.watch_secs);
    END LOOP;
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('  (해당하는 신작 콘텐츠가 없습니다.)');
    END IF;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));

    -- 섹션 2: 구작 목록 (1년 이전 출시)
    DBMS_OUTPUT.PUT_LINE('인기 **구작** 목록 (출시 ' || c_new_release_days || '일 이전)'); -- 이모티콘 제거
    -- DBMS_OUTPUT.PUT_LINE('정렬 기준: ...'); -- 정렬 기준 설명 줄 제거
    v_found := FALSE;
    FOR rec IN content_cursor('OLD') LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('  - [' || rec.title || ']');
        DBMS_OUTPUT.PUT_LINE('    썸네일: ' || rec.thumbnailURL);
        -- '좋아요' 출력 부분 제거
        DBMS_OUTPUT.PUT_LINE('    출시일: ' || TO_CHAR(rec.releaseDate, 'YYYY-MM-DD') ||
                             ' | 시청자: ' || rec.viewers ||
                             ' | 총시청(초): ' || rec.watch_secs);
    END LOOP;
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('  (해당하는 구작 콘텐츠가 없습니다.)');
    END IF;
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 80, '='));

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('예외 발생: sp_show_new_old_content 실행 중 오류: ' || SQLERRM); -- 이모티콘 제거
END;
/

-- ==================================
-- 2. 프로시저 테스트 실행 (Execution)
-- ==================================
-- SQL 클라이언트에서 DBMS_OUTPUT 활성화 필요 (예: SET SERVEROUTPUT ON;)
BEGIN
    sp_show_new_old_content(1); -- 프로필 ID 1에 대해 프로시저 실행
END;
/



--------------------------------------------------------------------------------
-- 뷰 생성
CREATE OR REPLACE VIEW vw_content_basic_info AS
SELECT
    contentID,
    title,
    thumbnailURL
FROM
    content;
/

-- [탐색] 자막유무/언어/정렬(오름차순,내림차순,신작순,추천순)
-- 추천순 : 사용자 선호도 반영
DECLARE
    -- 입력 변수
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_sub_req         CHAR(1)                := UPPER('&req_sub');
    v_language        audioLang.Language%TYPE := '&req_lang';
    v_sort_option     VARCHAR2(20)           := UPPER('&req_sort');

    -- 각 정렬 방식에 대한 커서 선언
    CURSOR title_asc_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = v_language AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title ASC;

    CURSOR title_desc_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = v_language AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title DESC;

    CURSOR release_date_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi JOIN content c ON cbi.contentID = c.contentID
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = v_language AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY c.releaseDate DESC, cbi.title ASC;

    CURSOR recommendation_cursor IS
        WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0), ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0), ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID), ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID)
        SELECT cbi.title, cbi.thumbnailURL, (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score
        FROM vw_content_basic_info cbi LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = v_language AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY final_score DESC NULLS LAST, cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_score         NUMBER;
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    IF v_sort_option NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN DBMS_OUTPUT.PUT_LINE('오류: 유효하지 않은 정렬 기준입니다. (TITLE_ASC, TITLE_DESC, RELEASE_DATE, RECOMMEND)'); RETURN; END IF;

    -- 프로필 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option);
    IF v_sort_option = 'RECOMMEND' THEN DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname || ' (ID: ' || v_profile_id || ')'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 정렬 기준에 따라 해당 커서 사용 및 루프 실행
    IF v_sort_option = 'TITLE_ASC' THEN
        OPEN title_asc_cursor; LOOP FETCH title_asc_cursor INTO v_title, v_thumbnailURL; EXIT WHEN title_asc_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE title_asc_cursor;

    ELSIF v_sort_option = 'TITLE_DESC' THEN
        OPEN title_desc_cursor; LOOP FETCH title_desc_cursor INTO v_title, v_thumbnailURL; EXIT WHEN title_desc_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE title_desc_cursor;

    ELSIF v_sort_option = 'RELEASE_DATE' THEN
        OPEN release_date_cursor; LOOP FETCH release_date_cursor INTO v_title, v_thumbnailURL; EXIT WHEN release_date_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE release_date_cursor;

    ELSIF v_sort_option = 'RECOMMEND' THEN
        OPEN recommendation_cursor; LOOP FETCH recommendation_cursor INTO v_title, v_thumbnailURL, v_score; EXIT WHEN recommendation_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE recommendation_cursor;

    END IF;

    -- 결과 없는 경우 메시지 출력
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        -- 각 커서가 열려 있는지 확인하고 닫기 (더욱 안전하게)
        IF title_asc_cursor%ISOPEN THEN CLOSE title_asc_cursor; END IF;
        IF title_desc_cursor%ISOPEN THEN CLOSE title_desc_cursor; END IF;
        IF release_date_cursor%ISOPEN THEN CLOSE release_date_cursor; END IF;
        IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/




-- 드라마만 출력 ->
-- 시즌 있는 콘텐츠 + 선택적 장르(&req_genre) 필터링 (기본값 '전체') + DBMS 출력
DECLARE
    -- & 변수로 사용자 입력 받기 (빈 값 허용됨)
    v_req_genre_input VARCHAR2(100) := '&req_genre';

    -- 실제 필터링에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- 커서 정의: 시즌 필터 + 조건부 장르 필터(v_filter_genre 사용)
    CURSOR filtered_content_cursor IS
        SELECT
            cbi.title,
            cbi.thumbnailURL
        FROM
            vw_content_basic_info cbi -- 뷰 사용 (미리 생성되어 있어야 함)
        WHERE
            -- 1. 시즌 필터: seasonNum이 NULL이 아닌 video가 있는지 확인
            EXISTS (
                SELECT 1 FROM video v
                WHERE v.contentID = cbi.contentID AND v.seasonNum IS NOT NULL
            )
            AND
            -- 2. 장르 필터: v_filter_genre 변수 값에 따라 조건부 실행
            (
                v_filter_genre = '전체' -- v_filter_genre가 '전체'이거나
                OR
                EXISTS (                -- 또는 해당 장르가 존재하는 경우
                    SELECT 1 FROM genreList gl JOIN genre g ON gl.genreID = g.genreID
                    WHERE gl.contentID = cbi.contentID AND g.genreName = v_filter_genre
                )
            )
        ORDER BY
            cbi.title ASC; -- 제목 오름차순 정렬

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;

BEGIN
    -- *** 입력값 처리: 입력이 없거나 공백이면 '전체'로 설정 ***
    IF v_req_genre_input IS NULL OR TRIM(v_req_genre_input) = '' THEN
        v_filter_genre := '전체'; -- 기본값 설정
    ELSE
        v_filter_genre := TRIM(v_req_genre_input); -- 사용자 입력값 사용 (앞뒤 공백 제거)
    END IF;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 유형: 시즌 있는 콘텐츠');
    DBMS_OUTPUT.PUT_LINE('선택 장르: ' || v_filter_genre); -- 실제 적용된 필터 값 출력
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 커서 열고, 데이터 가져와서 DBMS_OUTPUT으로 출력
    OPEN filtered_content_cursor;
    LOOP
        FETCH filtered_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN filtered_content_cursor%NOTFOUND;
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE filtered_content_cursor;

    -- 결과 없을 시 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 오류 처리
        IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 드라마만 출력 ->
-- [시리즈물] 선택적 장르(&req_genre, 기본 '전체') + 추천순(&profile_id) 정렬 + 추천 점수 포함 DBMS 출력

DECLARE
    -- 입력 변수 (& 사용, 순서 변경: 프로필 -> 장르)
    v_profile_id      profile.profileID%TYPE := &profile_id; -- <<< 1. 추천 기준 프로필 ID 입력
    v_req_genre_input VARCHAR2(100)          := '&req_genre'; -- <<< 2. 장르 입력 (빈 값 허용 -> '전체')

    -- 실제 필터링/계산에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- *** 커서 수정: SELECT 목록에 추천 점수(final_score) 추가 ***
    CURSOR recommendation_cursor IS
        WITH ProfileGenrePrefs AS (
            SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0
        ), ProfileFeaturePrefs AS (
            SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0
        ), ContentGenreScores AS (
            SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score
            FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID
        ), ContentFeatureScores AS (
            SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score
            FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID
        )
        SELECT
            cbi.title,
            cbi.thumbnailURL,
            -- 추천 점수 계산 및 선택
            (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score
        FROM
            vw_content_basic_info cbi -- 뷰 사용
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        WHERE
            -- 1. 시리즈물 필터 (seasonNum 존재)
            EXISTS (
                SELECT 1 FROM video v
                WHERE v.contentID = cbi.contentID AND v.seasonNum IS NOT NULL
            )
            AND
            -- 2. 장르 필터 (v_filter_genre 변수 사용)
            (
                v_filter_genre = '전체'
                OR
                EXISTS (
                    SELECT 1 FROM genreList gl JOIN genre g ON gl.genreID = g.genreID
                    WHERE gl.contentID = cbi.contentID AND g.genreName = v_filter_genre
                )
            )
        ORDER BY
            -- 추천 점수 내림차순, 점수 같으면 제목 오름차순
            final_score DESC NULLS LAST, -- SELECT 목록의 별칭 사용 가능
            cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title           vw_content_basic_info.title%TYPE;
    v_thumbnailURL    vw_content_basic_info.thumbnailURL%TYPE;
    v_score           NUMBER; -- <<< 추천 점수 저장 변수 추가
    v_found           BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;

BEGIN
    -- 입력값 처리: 장르 입력 없으면 '전체'
    IF v_req_genre_input IS NULL OR TRIM(v_req_genre_input) = '' THEN
        v_filter_genre := '전체';
    ELSE
        v_filter_genre := TRIM(v_req_genre_input);
    END IF;

    -- 프로필 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 유형: 시리즈물');
    DBMS_OUTPUT.PUT_LINE('선택 장르: ' || v_filter_genre);
    DBMS_OUTPUT.PUT_LINE('정렬: 추천순 (프로필: ' || v_profile_nickname || ')');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 커서 열고 결과 출력
    OPEN recommendation_cursor;
    LOOP
        -- *** FETCH 수정: 점수 변수(v_score) 추가 ***
        FETCH recommendation_cursor INTO v_title, v_thumbnailURL, v_score;
        EXIT WHEN recommendation_cursor%NOTFOUND;
        v_found := TRUE;
        -- *** 출력 수정: 점수 포함 ***
        DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE recommendation_cursor;

    -- 결과 없을 시 메시지
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/




-- 영화(시즌 없는 콘텐츠) + 선택적 장르(&req_genre) 필터링 (기본값 '전체') + DBMS 출력
DECLARE
    -- & 변수로 사용자 입력 받기 (빈 값 허용됨)
    v_req_genre_input VARCHAR2(100) := '&req_genre';

    -- 실제 필터링에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- 커서 정의: 영화 필터 + 조건부 장르 필터(v_filter_genre 사용)
    CURSOR filtered_content_cursor IS
        SELECT
            cbi.title,
            cbi.thumbnailURL
        FROM
            vw_content_basic_info cbi -- 뷰 사용 (미리 생성되어 있어야 함)
        WHERE
            -- *** 조건 1: 영화 필터 (seasonNum이 없는 콘텐츠) ***
            NOT EXISTS ( -- 이 콘텐츠(cbi)에 연결된 비디오 중 seasonNum이 NULL이 아닌 것이 없는지 확인
                SELECT 1
                FROM video v
                WHERE v.contentID = cbi.contentID
                  AND v.seasonNum IS NOT NULL -- seasonNum을 가진 비디오가 존재하지 않아야 함
            )
            AND
            -- 조건 2: 장르 필터 (v_filter_genre 변수 값에 따라 조건부 실행)
            (
                v_filter_genre = '전체' -- v_filter_genre가 '전체'이거나
                OR
                EXISTS (                -- 또는 해당 장르가 존재하는 경우
                    SELECT 1 FROM genreList gl JOIN genre g ON gl.genreID = g.genreID
                    WHERE gl.contentID = cbi.contentID AND g.genreName = v_filter_genre
                )
            )
        ORDER BY
            cbi.title ASC; -- 제목 오름차순 정렬

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;

BEGIN
    -- 입력값 처리: 입력이 없거나 공백이면 '전체'로 설정
    IF v_req_genre_input IS NULL OR TRIM(v_req_genre_input) = '' THEN
        v_filter_genre := '전체'; -- 기본값 설정
    ELSE
        v_filter_genre := TRIM(v_req_genre_input); -- 사용자 입력값 사용 (앞뒤 공백 제거)
    END IF;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 유형: 영화 (시즌 없는 콘텐츠)'); -- 조건 변경 명시
    DBMS_OUTPUT.PUT_LINE('선택 장르: ' || v_filter_genre);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 커서 열고, 데이터 가져와서 DBMS_OUTPUT으로 출력
    OPEN filtered_content_cursor;
    LOOP
        FETCH filtered_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN filtered_content_cursor%NOTFOUND;
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE filtered_content_cursor;

    -- 결과 없을 시 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 오류 처리
        IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- [영화 등] 선택적 장르(&req_genre) 필터링 + 추천순(&profile_id) 정렬 + DBMS 출력


DECLARE
    -- 입력 변수 (& 사용, 순서 변경: 프로필 -> 장르)
    v_profile_id      profile.profileID%TYPE := &profile_id;     -- <<< 1. 추천 기준 프로필 ID 입력
    v_req_genre_input VARCHAR2(100)          := '&req_genre'; -- <<< 2. 장르 입력 (빈 값 허용 -> '전체')

    -- 실제 필터링/계산에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- *** 커서 수정: SELECT 목록에 추천 점수(final_score) 추가 ***
    CURSOR recommendation_cursor IS
        WITH ProfileGenrePrefs AS (
            SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0
        ), ProfileFeaturePrefs AS (
            SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0
        ), ContentGenreScores AS (
            SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score
            FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID
        ), ContentFeatureScores AS (
            SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score
            FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID
        )
        SELECT
            cbi.title,
            cbi.thumbnailURL,
            -- 추천 점수 계산 및 선택
            (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score
        FROM
            vw_content_basic_info cbi -- 뷰 사용
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        WHERE
            -- 1. 영화 필터 (seasonNum 없음)
            NOT EXISTS (
                SELECT 1 FROM video v
                WHERE v.contentID = cbi.contentID AND v.seasonNum IS NOT NULL
            )
            AND
            -- 2. 장르 필터 (v_filter_genre 변수 사용)
            (
                v_filter_genre = '전체'
                OR
                EXISTS (
                    SELECT 1 FROM genreList gl JOIN genre g ON gl.genreID = g.genreID
                    WHERE gl.contentID = cbi.contentID AND g.genreName = v_filter_genre
                )
            )
        ORDER BY
            -- 추천 점수 내림차순, 점수 같으면 제목 오름차순
            final_score DESC NULLS LAST, -- SELECT 목록의 별칭 사용 가능
            cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title           vw_content_basic_info.title%TYPE;
    v_thumbnailURL    vw_content_basic_info.thumbnailURL%TYPE;
    v_score           NUMBER; -- <<< 추천 점수 저장 변수 추가
    v_found           BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;

BEGIN
    -- 입력값 처리: 장르 입력 없으면 '전체'
    IF v_req_genre_input IS NULL OR TRIM(v_req_genre_input) = '' THEN
        v_filter_genre := '전체';
    ELSE
        v_filter_genre := TRIM(v_req_genre_input);
    END IF;

    -- 프로필 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 유형: 영화 등 (시즌 없는 콘텐츠)');
    DBMS_OUTPUT.PUT_LINE('선택 장르: ' || v_filter_genre);
    DBMS_OUTPUT.PUT_LINE('정렬: 추천순 (프로필: ' || v_profile_nickname || ')');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 커서 열고 결과 출력
    OPEN recommendation_cursor;
    LOOP
        -- *** FETCH 수정: 점수 변수(v_score) 추가 ***
        FETCH recommendation_cursor INTO v_title, v_thumbnailURL, v_score;
        EXIT WHEN recommendation_cursor%NOTFOUND;
        v_found := TRUE;
        -- *** 출력 수정: 점수 포함 ***
        DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE recommendation_cursor;

    -- 결과 없을 시 메시지
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/




-- 배우 이름(&actor_name)을 입력받아 해당 배우가 출연한 '모든 콘텐츠' 목록 출력

DECLARE
    -- & 변수로 배우 이름 입력받음
    v_actor_name    actor.name%TYPE      := '&actor_name';
    -- 찾은 배우 ID 저장용 변수
    v_actor_id      actor.actorid%TYPE;

    -- 커서: 특정 배우 ID(p_actor_id)가 출연한 '모든 콘텐츠' 조회 (영화 필터 제거됨)
    CURSOR filtered_content_cursor (p_actor_id IN actor.actorid%TYPE) IS
        SELECT
            c.title,           -- 콘텐츠 제목
            c.thumbnailURL     -- 콘텐츠 썸네일 URL
        FROM
            content c          -- 콘텐츠 테이블
        JOIN
            actorList al ON c.contentID = al.contentID -- 콘텐츠와 배우 목록 연결
        WHERE
            -- c.contentType = '영화'  -- <<< 영화만 필터링하는 조건 제거!
            al.actorid = p_actor_id  -- 해당 배우 ID와 일치하는 것만 필터링
        ORDER BY
            c.title ASC;       -- 제목 오름차순 정렬

    -- 루프 및 출력용 변수
    v_title         content.title%TYPE;
    v_thumbnailURL  content.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;

BEGIN
    -- 1. 입력받은 이름으로 배우 ID 찾기
    BEGIN
        SELECT actorid INTO v_actor_id
        FROM actor -- 인물 테이블
        WHERE name = v_actor_name; -- 입력받은 이름과 일치하는 배우 검색
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('오류: 배우 ''' || v_actor_name || ''' 님을 찾을 수 없습니다.');
            RETURN; -- 배우 없으면 블록 종료
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('오류: 이름 ''' || v_actor_name || ''' 에 해당하는 배우가 여러 명 있습니다. 데이터 확인이 필요합니다.');
            RETURN; -- 동명이인 처리 필요 시 로직 수정 (여기서는 종료)
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('오류: 배우 정보 조회 중 문제 발생 - ' || SQLERRM);
            RETURN;
    END;

    -- 2. 검색 조건 및 결과 헤더 출력 (콘텐츠 유형 필터 제거됨)
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('배우 이름: ' || v_actor_name || ' (ID: ' || v_actor_id || ')');
    -- DBMS_OUTPUT.PUT_LINE('콘텐츠 유형: 영화'); -- 영화 필터 제거했으므로 이 라인 삭제 또는 주석 처리
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 출연 콘텐츠 목록 (전체 유형) ---'); -- 헤더 텍스트 수정

    -- 3. 커서 열고, 데이터 가져와서 DBMS_OUTPUT으로 출력
    OPEN filtered_content_cursor(p_actor_id => v_actor_id); -- 커서 열 때 찾은 배우 ID 전달
    LOOP
        FETCH filtered_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN filtered_content_cursor%NOTFOUND; -- 더 이상 데이터 없으면 종료
        v_found := TRUE; -- 결과 찾음 표시
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE filtered_content_cursor; -- 커서 닫기

    -- 4. 결과 없을 시 메시지 출력 (메시지 수정)
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 배우가 출연한 콘텐츠 정보를 찾을 수 없습니다.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 그 외 예외 처리
        IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF; -- 커서 열려있으면 닫기
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/



-- 크리에이터 이름(&creator_name)을 입력받아 해당 크리에이터의 '모든 참여 콘텐츠' 목록 출력
DECLARE
    -- & 변수로 크리에이터 이름 입력받음
    v_creator_name  creator.creatorName%TYPE := '&creator_name';
    -- 찾은 크리에이터 ID 저장용 변수
    v_creator_id    creator.creatorID%TYPE;

    -- 커서: 특정 크리에이터 ID(p_creator_id)의 모든 참여 콘텐츠 조회
    CURSOR filtered_content_cursor (p_creator_id IN creator.creatorID%TYPE) IS
        SELECT
            c.title,           -- 콘텐츠 제목
            c.thumbnailURL     -- 콘텐츠 썸네일 URL
        FROM
            content c          -- 콘텐츠 테이블
        JOIN
            creatorList cl ON c.contentID = cl.contentID -- 콘텐츠와 크리에이터 목록 연결
        WHERE
            cl.creatorID = p_creator_id  -- 해당 크리에이터 ID와 일치하는 것만 필터링
        ORDER BY
            c.title ASC;       -- 제목 오름차순 정렬

    -- 루프 및 출력용 변수
    v_title         content.title%TYPE;
    v_thumbnailURL  content.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;

BEGIN
    -- 1. 입력받은 이름으로 크리에이터 ID 찾기
    BEGIN
        SELECT creatorID INTO v_creator_id
        FROM creator -- 크리에이터 테이블
        WHERE creatorName = v_creator_name; -- 입력받은 이름과 일치하는 크리에이터 검색
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('오류: 크리에이터 ''' || v_creator_name || ''' 님을 찾을 수 없습니다.');
            RETURN; -- 크리에이터 없으면 블록 종료
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('오류: 이름 ''' || v_creator_name || ''' 에 해당하는 크리에이터가 여러 명 있습니다. 데이터 확인이 필요합니다.');
            RETURN;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('오류: 크리에이터 정보 조회 중 문제 발생 - ' || SQLERRM);
            RETURN;
    END;

    -- 2. 검색 조건 및 결과 헤더 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('크리에이터 이름: ' || v_creator_name || ' (ID: ' || v_creator_id || ')');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 참여 콘텐츠 목록 ---'); -- 헤더 텍스트 변경

    -- 3. 커서 열고, 데이터 가져와서 DBMS_OUTPUT으로 출력
    OPEN filtered_content_cursor(p_creator_id => v_creator_id); -- 커서 열 때 찾은 크리에이터 ID 전달
    LOOP
        FETCH filtered_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN filtered_content_cursor%NOTFOUND; -- 더 이상 데이터 없으면 종료
        v_found := TRUE; -- 결과 찾음 표시
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE filtered_content_cursor; -- 커서 닫기

    -- 4. 결과 없을 시 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 크리에이터가 참여한 콘텐츠 정보를 찾을 수 없습니다.'); -- 메시지 변경
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 그 외 예외 처리
        IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF; -- 커서 열려있으면 닫기
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/


-- 특정 프로필(&profile_id)의 시청 기록(최신) 및 조건부 다음화 보기 출력 (수정 11: 타입 오류 수정)
DECLARE
    v_profile_id      profile.profileID%TYPE  := &profile_id;
    v_profile_nickname profile.nickname%TYPE;

    -- 마지막 에피소드 정보 저장용 타입 및 변수
    TYPE t_final_epi_rec IS RECORD (max_season NUMBER, max_epi NUMBER);
    -- *** 수정: INDEX BY 타입을 PLS_INTEGER로 변경 ***
    TYPE t_final_epi_map IS TABLE OF t_final_epi_rec INDEX BY PLS_INTEGER;
    v_final_episode_map t_final_epi_map; -- 시리즈별 마지막 시즌/에피 정보 저장

    -- 시청 기록 저장을 위한 타입 및 변수
    TYPE t_watch_rec IS RECORD (
        is_completed    viewingHistory.isCompleted%TYPE, -- CHAR(1)
        progress_sec    NUMBER
    );
    TYPE t_watch_hist_map IS TABLE OF t_watch_rec INDEX BY PLS_INTEGER; -- videoID를 키로 사용 (PLS_INTEGER)
    v_watch_history   t_watch_hist_map; -- 해당 콘텐츠의 모든 비디오 시청 상태 저장

    -- 임시 테이블 타입 (BULK COLLECT용)
    TYPE t_watch_history_rec IS RECORD (
        videoID         viewingHistory.videoID%TYPE,
        isCompleted     viewingHistory.isCompleted%TYPE,
        totalViewingTime NUMBER
    );
    TYPE t_watch_history_tab IS TABLE OF t_watch_history_rec INDEX BY BINARY_INTEGER;
    v_temp_hist_tab t_watch_history_tab;

    -- 루프용 변수 (이하 다른 변수 선언은 이전과 동일)
    v_content_id        content.contentID%TYPE;
    v_title             content.title%TYPE;
    v_thumbnailURL      content.thumbnailURL%TYPE;
    v_progress_sec      viewingHistory.totalViewingTime%TYPE;
    v_total_runtime_min video.epiruntime%TYPE;
    v_season            video.seasonNum%TYPE;
    v_epi_num           video.epiNum%TYPE;
    v_epi_title         video.epiTitle%TYPE;
    v_is_completed      viewingHistory.isCompleted%TYPE;
    v_found             BOOLEAN := FALSE;
    v_max_season_num        video.seasonNum%TYPE; -- 시리즈 여부 확인 및 헤더 출력용
    v_max_epi_num_in_last_season video.epiNum%TYPE; -- 마지막 화 확인용


BEGIN
    -- 1. 프로필 닉네임 조회 (변경 없음)
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN; WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN; END;

    -- 2. 시리즈 콘텐츠들의 마지막 시즌/에피소드 정보 미리 조회 (맵 사용, 이전과 동일)
    v_final_episode_map.DELETE;
    FOR rec IN (SELECT contentID, MAX(seasonNum) as max_s FROM video WHERE seasonNum IS NOT NULL GROUP BY contentID) LOOP
        v_final_episode_map(rec.contentID).max_season := rec.max_s; -- <<< 이제 오류 없이 할당 가능
        SELECT MAX(epiNum) INTO v_final_episode_map(rec.contentID).max_epi FROM video WHERE contentID = rec.contentID AND seasonNum = rec.max_s; -- <<< 이제 오류 없이 할당 가능
    END LOOP;

    -- 3. 헤더 출력 (변경 없음)
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE(v_profile_nickname || ' 님의 시청 기록 (최신 상태)');
    DBMS_OUTPUT.PUT_LINE('---');

    -- 4. 모든 관련 시청 기록의 '최신 상태'를 맵에 저장 (이전과 동일)
    v_watch_history.DELETE;
    BEGIN SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime BULK COLLECT INTO v_temp_hist_tab FROM ( SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime, ROW_NUMBER() OVER(PARTITION BY vh.videoID ORDER BY vh.lastViewat DESC) as rn FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id) vh WHERE rn = 1; IF v_temp_hist_tab.COUNT > 0 THEN FOR i IN v_temp_hist_tab.FIRST .. v_temp_hist_tab.LAST LOOP v_watch_history(v_temp_hist_tab(i).videoID).is_completed := v_temp_hist_tab(i).isCompleted; v_watch_history(v_temp_hist_tab(i).videoID).progress_sec := v_temp_hist_tab(i).totalViewingTime; END LOOP; END IF; EXCEPTION WHEN NO_DATA_FOUND THEN NULL; END;

    -- 5. 커서 열고 결과 출력 (이전과 동일 - 최신 기록 커서)
    DECLARE -- 커서 선언을 위한 내부 블록
        CURSOR latest_history_cursor (p_profile_id IN profile.profileID%TYPE) IS
            SELECT contentID, title, thumbnailURL, totalViewingTime, epiruntime, seasonNum, epiNum, epiTitle, isCompleted
            FROM ( SELECT c.contentID, c.title, c.thumbnailURL, vh.totalViewingTime, v.epiruntime, v.seasonNum, v.epiNum, v.epiTitle, vh.isCompleted, ROW_NUMBER() OVER (PARTITION BY vh.videoID ORDER BY vh.lastViewat DESC) as rn FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID JOIN content c ON v.contentID = c.contentID WHERE vh.profileID = p_profile_id )
            WHERE rn = 1 ORDER BY title ASC, seasonNum ASC NULLS LAST, epiNum ASC NULLS LAST;
    BEGIN
        v_found := FALSE; -- 루프 전 초기화
        OPEN latest_history_cursor(p_profile_id => v_profile_id);
        LOOP
            FETCH latest_history_cursor INTO v_content_id, v_title, v_thumbnailURL, v_progress_sec, v_total_runtime_min, v_season, v_epi_num, v_epi_title, v_is_completed;
            EXIT WHEN latest_history_cursor%NOTFOUND;
            v_found := TRUE;

            DBMS_OUTPUT.PUT_LINE('  제목: ' || v_title);
            IF v_season IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('    회차: 시즌 ' || v_season || ' 에피소드 ' || v_epi_num || ' (' || NVL(v_epi_title, '제목 없음') || ')'); END IF;
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_thumbnailURL, '없음'));

            -- 시청 상태 및 조건부 다음화 보기 출력 (로직은 이전과 동일하나, v_final_episode_map 참조가 이제 유효함)
            IF v_is_completed = 'Y' THEN
                DBMS_OUTPUT.PUT_LINE('    ** 시청 완료 **');
                IF v_season IS NOT NULL AND v_final_episode_map.EXISTS(v_content_id) AND NOT (v_season = v_final_episode_map(v_content_id).max_season AND v_epi_num = v_final_episode_map(v_content_id).max_epi) THEN
                    DECLARE v_next_season video.seasonNum%TYPE; v_next_epi_num video.epiNum%TYPE; v_next_epi_title video.epiTitle%TYPE; v_next_found BOOLEAN := FALSE;
                    BEGIN BEGIN SELECT seasonNum, epiNum, epiTitle INTO v_next_season, v_next_epi_num, v_next_epi_title FROM video v WHERE v.contentID = v_content_id AND v.seasonNum = v_season AND v.epiNum = v_epi_num + 1; v_next_found := TRUE;
                          EXCEPTION WHEN NO_DATA_FOUND THEN BEGIN SELECT seasonNum, epiNum, epiTitle INTO v_next_season, v_next_epi_num, v_next_epi_title FROM video v WHERE v.contentID = v_content_id AND v.seasonNum = v_season + 1 AND v.epiNum = 1; v_next_found := TRUE; EXCEPTION WHEN NO_DATA_FOUND THEN v_next_found := FALSE; END; END;
                          IF v_next_found THEN DBMS_OUTPUT.PUT_LINE('    >> 다음화 보기: 시즌 ' || v_next_season || ' 에피소드 ' || v_next_epi_num || ' (' || NVL(v_next_epi_title,'제목 없음') || ')'); END IF;
                    END;
                END IF;
            ELSIF v_is_completed = 'N' THEN
                DBMS_OUTPUT.PUT_LINE('    ** 시청 중 (진행: ' || ROUND(v_progress_sec / 60) || '분 / ' || v_total_runtime_min || '분) **');
            END IF;
            DBMS_OUTPUT.PUT_LINE('  ---');
        END LOOP;
        CLOSE latest_history_cursor;

        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (시청 기록이 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END; -- 커서 처리를 위한 내부 블록 종료

EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM); -- 커서는 내부 블록에서 닫힘
END;
/





-- 신작(공개일 기준 2주 이내) 콘텐츠의 제목과 썸네일 출력 (뷰 활용)

DECLARE
    -- 커서: 뷰와 content 테이블을 조인하여 신작 필터링 및 정렬
    CURSOR new_releases_cursor IS
        SELECT
            v.title,        -- 콘텐츠 제목 (뷰에서 가져옴)
            v.thumbnailURL, -- 콘텐츠 썸네일 URL (뷰에서 가져옴)
            c.publicDate    -- 공개일 (content 테이블에서 가져옴, 확인 및 정렬용)
        FROM
            vw_content_basic_info v -- 기존 뷰 사용
        JOIN
            content c ON v.contentID = c.contentID -- publicDate 컬럼을 위해 content 테이블 조인
        WHERE
            -- content 테이블의 publicDate 컬럼으로 필터링
            c.publicDate >= TRUNC(SYSDATE) - 13 -- 오늘 포함 최근 14일(2주) 이내 공개된 콘텐츠
        ORDER BY
            c.publicDate DESC, -- 최신 공개일 순서
            v.title ASC;       -- 공개일 같으면 제목 순서

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_publicDate    content.publicDate%TYPE;
    v_found         BOOLEAN := FALSE; -- 결과가 하나라도 있었는지 확인하는 플래그

BEGIN
    -- 헤더 출력
    DBMS_OUTPUT.PUT_LINE('--- 신작 콘텐츠 목록 (최근 2주 이내) ---');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------');

    -- 커서 열고, 데이터 가져와서 DBMS_OUTPUT으로 한 줄씩 출력
    OPEN new_releases_cursor;
    LOOP
        FETCH new_releases_cursor INTO v_title, v_thumbnailURL, v_publicDate;
        EXIT WHEN new_releases_cursor%NOTFOUND; -- 더 이상 데이터 없으면 루프 종료

        v_found := TRUE; -- 결과 찾음 표시
        -- 출력 형식: 제목, 썸네일 URL, 공개일(YYYY-MM-DD 형식)
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL || ', 공개일: ' || TO_CHAR(v_publicDate, 'YYYY-MM-DD'));

    END LOOP;
    CLOSE new_releases_cursor; -- 커서 닫기

    -- 결과가 없는 경우 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('최근 2주 이내 신작 콘텐츠가 없습니다.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 오류 처리
        IF new_releases_cursor%ISOPEN THEN CLOSE new_releases_cursor; END IF; -- 커서가 열려있으면 닫기
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- [시리즈물] 중 선택적 장르(&req_genre, 기본 '전체')에서 랜덤으로 1개 선택 후 상세 정보 DBMS 출력 (ROWNUM 수정)

DECLARE
    v_req_genre_input VARCHAR2(100) := '&req_genre';
    v_filter_genre    genre.genreName%TYPE;
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_description     content.description%TYPE;
    v_ratingLabel     contentRating.ratingLabel%TYPE;
BEGIN
    -- Handle default genre
    IF v_req_genre_input IS NULL OR TRIM(v_req_genre_input) = '' THEN
        v_filter_genre := '전체';
    ELSE
        v_filter_genre := TRIM(v_req_genre_input);
    END IF;

    -- 수정: SELECT INTO 문 내에서 FETCH FIRST 대신 ROWNUM = 1 사용
    SELECT title, thumbnailURL, description, ratingLabel
    INTO v_title, v_thumbnailURL, v_description, v_ratingLabel
    FROM ( -- <<< 인라인 뷰(서브쿼리) 시작
        SELECT
            c.title, c.thumbnailURL, c.description,
            (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as ratingLabel -- MAX() 사용 유지
        FROM content c
        WHERE
            EXISTS (SELECT 1 FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) -- Series Filter
            AND (v_filter_genre = '전체' OR EXISTS (SELECT 1 FROM genreList gl JOIN genre g ON gl.genreID = g.genreID WHERE gl.contentID = c.contentID AND g.genreName = v_filter_genre)) -- Genre Filter
        ORDER BY DBMS_RANDOM.VALUE -- <<< 서브쿼리 내에서 랜덤 정렬
    ) -- <<< 인라인 뷰(서브쿼리) 종료
    WHERE ROWNUM = 1; -- <<< 랜덤 정렬된 결과 중 첫 번째 행만 선택

    -- Output results
    DBMS_OUTPUT.PUT_LINE('--- 랜덤 추천 결과 (시리즈 / 장르: ' || v_filter_genre || ') ---');
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_title);
    DBMS_OUTPUT.PUT_LINE('썸네일URL: ' || v_thumbnailURL);
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(v_description, 1, 200) || CASE WHEN LENGTH(v_description) > 200 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('시청 등급: ' || NVL(v_ratingLabel, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

EXCEPTION
    WHEN NO_DATA_FOUND THEN -- 조건에 맞는 콘텐츠가 하나도 없거나 랜덤 선택 실패 시
        DBMS_OUTPUT.PUT_LINE('해당 조건(시리즈 / 장르: ' || v_filter_genre || ')에 맞는 콘텐츠가 없습니다.');
    WHEN OTHERS THEN -- 그 외 오류 처리
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 특정 콘텐츠 상세 정보 + 관련 콘텐츠 (콘텐츠 유사성 기반 추천) + DBMS 출력 (수정 9: 관련 콘텐츠 커서 구조 변경)

DECLARE
    -- 입력 변수 (프로필 ID 먼저)
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_content_title   content.title%TYPE     := '&content_title';

    -- 기본 정보 저장 변수 (이전과 동일)
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_creators        VARCHAR2(2000);
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;
    TYPE t_watch_hist_map IS TABLE OF viewingHistory.totalViewingTime%TYPE INDEX BY PLS_INTEGER;
    v_watch_history   t_watch_hist_map;
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_temp_num        NUMBER;
    v_found           BOOLEAN := FALSE;
    v_is_watching             BOOLEAN := FALSE;
    v_watching_video_id       video.videoID%TYPE;
    v_watching_season_num     video.seasonNum%TYPE;
    v_watching_epi_num        video.epiNum%TYPE;
    v_watching_epi_title      video.epiTitle%TYPE;
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_epi_desc       video.epiDescription%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;
    -- 임시 테이블 타입 (BULK COLLECT용)
    TYPE t_watch_history_rec IS RECORD (
        videoID         viewingHistory.videoID%TYPE,
        isCompleted     viewingHistory.isCompleted%TYPE,
        totalViewingTime viewingHistory.totalViewingTime%TYPE
    );
    TYPE t_watch_history_tab IS TABLE OF t_watch_history_rec INDEX BY BINARY_INTEGER;
    v_temp_hist_tab t_watch_history_tab;


BEGIN
    -- ==========================================================
    -- 1. 기본 정보 조회 (프로필, 콘텐츠) - 변경 없음
    -- ==========================================================
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN; WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN; END;
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID; EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN; WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN; WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN; END;
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL; IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE; ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_temp_num > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END;
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_wishlisted := TRUE; ELSE v_is_wishlisted := FALSE; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM userRating ur WHERE ur.profileID = v_profile_id AND ur.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_rated := TRUE; ELSE v_is_rated := FALSE; END IF; END;
    BEGIN SELECT LISTAGG(a.name, ', ') WITHIN GROUP (ORDER BY al.actorListid) INTO v_cast FROM actor a JOIN actorList al ON a.actorid = al.actorid WHERE al.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(g.genreName, ', ') WITHIN GROUP (ORDER BY g.genreName) INTO v_genres FROM genre g JOIN genreList gl ON g.genreID = gl.genreID WHERE gl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(f.featureName, ', ') WITHIN GROUP (ORDER BY f.featureName) INTO v_features FROM feature f JOIN featureList fl ON f.featureID = fl.featureID WHERE fl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(cr.creatorName, ', ') WITHIN GROUP (ORDER BY cr.creatorName) INTO v_creators FROM creator cr JOIN creatorList cl ON cr.creatorID = cl.creatorID WHERE cl.contentID = v_content_id; END;

    -- 모든 관련 시청 기록의 '최신 상태'를 맵에 저장 (이전과 동일 - ROWNUM 수정됨)
    v_watch_history.DELETE;
    BEGIN SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime BULK COLLECT INTO v_temp_hist_tab FROM ( SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime, ROW_NUMBER() OVER(PARTITION BY vh.videoID ORDER BY vh.lastViewat DESC) as rn FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id ) vh WHERE rn = 1;
        IF v_temp_hist_tab.COUNT > 0 THEN FOR i IN v_temp_hist_tab.FIRST .. v_temp_hist_tab.LAST LOOP v_watch_history(v_temp_hist_tab(i).videoID).is_completed := v_temp_hist_tab(i).isCompleted; v_watch_history(v_temp_hist_tab(i).videoID).progress_sec := v_temp_hist_tab(i).totalViewingTime; END LOOP; END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL; -- 데이터 없으면 그냥 넘어감
    END;
    -- 대표 '시청 중' 정보 설정 (이전과 동일 - ROWNUM 수정됨)
    BEGIN SELECT epiruntime, totalViewingTime INTO v_watching_epi_runtime, v_watching_progress_sec FROM ( SELECT v.epiruntime, vh.totalViewingTime FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N' ORDER BY vh.lastViewat DESC ) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_watching_epi_runtime := NULL; v_watching_progress_sec := NULL; END;
    -- 첫 회차 정보 조회 (이전과 동일 - ROWNUM 수정됨)
    IF v_is_series AND NOT v_watch_history.EXISTS(v_watching_video_id) THEN BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END; END IF; -- 시청중('N') 기록 없을때만 조회하도록 수정
    -- 설명 정보 설정 (이전과 동일)
    IF v_is_series AND v_watch_history.COUNT > 0 THEN DECLARE temp_desc video.epiDescription%TYPE; BEGIN SELECT epiDescription INTO temp_desc FROM ( SELECT v.epiDescription FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id ORDER BY vh.lastViewat DESC) WHERE ROWNUM = 1; v_display_desc := NVL(temp_desc, v_content_rec.description); EXCEPTION WHEN NO_DATA_FOUND THEN v_display_desc := v_content_rec.description; END; ELSE v_display_desc := v_content_rec.description; END IF;
    -- 러닝타임 정보 설정 (이전과 동일)
    IF v_is_series THEN IF v_watching_epi_runtime IS NOT NULL THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분 (시청 중)'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;


    -- ==========================================================
    -- 1차 정보 출력 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear || ' / 시청 등급: ' || NVL(v_ratingLabel, '정보 없음') || CASE WHEN v_is_series THEN ' / 총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_watching_progress_sec IS NOT NULL AND v_watching_epi_runtime IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || v_watching_epi_runtime || '분 중 ' || ROUND(v_watching_progress_sec / 60) || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END || ' / 내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END || ' / 자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

    -- ==========================================================
    -- 섹션 1: 회차 정보 - 변경 없음
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 ---'); v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---'); DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음')); DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END);
            IF v_watch_history.EXISTS(epi_rec.videoID) THEN IF v_watch_history(epi_rec.videoID).is_completed = 'Y' THEN DBMS_OUTPUT.PUT_LINE('    ** 시청 완료 **'); ELSIF v_watch_history(epi_rec.videoID).is_completed = 'N' THEN DBMS_OUTPUT.PUT_LINE('    ** 시청 중 (진행: ' || ROUND(v_watch_history(epi_rec.videoID).progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분) **'); END IF; END IF;
        END LOOP; IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF; DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;


    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (*** 커서 재수정: CTE + JOIN 방식 ***)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (유사 콘텐츠) ---');
    DECLARE
        -- *** 수정된 커서 정의: CTE + JOIN 방식으로 유사도 점수 계산 ***
        CURSOR related_content_cursor IS
             SELECT * FROM ( -- 서브쿼리 시작 (ROWNUM 필터링용)
                 WITH TargetGenres AS ( -- 현재 콘텐츠의 장르 ID 목록
                    SELECT genreID FROM genreList WHERE contentID = v_content_id
                 ), TargetFeatures AS ( -- 현재 콘텐츠의 특징 ID 목록
                    SELECT featureID FROM featureList WHERE contentID = v_content_id
                 ), SharedGenreCounts AS ( -- 다른 콘텐츠별 공유 장르 수 계산
                    SELECT gl.contentID, COUNT(tg.genreID) as shared_genre_count
                    FROM genreList gl JOIN TargetGenres tg ON gl.genreID = tg.genreID
                    WHERE gl.contentID != v_content_id -- 현재 콘텐츠 제외
                    GROUP BY gl.contentID
                 ), SharedFeatureCounts AS ( -- 다른 콘텐츠별 공유 특징 수 계산
                    SELECT fl.contentID, COUNT(tf.featureID) as shared_feature_count
                    FROM featureList fl JOIN TargetFeatures tf ON fl.featureID = tf.featureID
                    WHERE fl.contentID != v_content_id -- 현재 콘텐츠 제외
                    GROUP BY fl.contentID
                 )
                 -- 메인 쿼리: 콘텐츠 정보 + 유사도 점수 계산 및 정렬
                 SELECT
                     c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                     (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                     (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season,
                     -- 찜 여부는 여전히 현재 프로필 기준
                     (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count,
                     -- 유사도 점수 계산 (사전 계산된 공유 카운트 사용)
                     (NVL(sgc.shared_genre_count, 0) + NVL(sfc.shared_feature_count, 0)) as similarity_score
                 FROM content c
                 LEFT JOIN SharedGenreCounts sgc ON c.contentID = sgc.contentID -- 공유 장르 수 조인
                 LEFT JOIN SharedFeatureCounts sfc ON c.contentID = sfc.contentID -- 공유 특징 수 조인
                 WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                 ORDER BY similarity_score DESC NULLS LAST, c.title ASC -- <<< 유사도 점수 기준으로 정렬
             ) -- 서브쿼리 종료
             WHERE ROWNUM <= 10; -- 상위 10개

        -- 내부 루프용 변수들
        v_rel_similarity_score NUMBER;
        v_rel_content_id  content.contentID%TYPE; v_rel_title content.title%TYPE; v_rel_thumb content.thumbnailURL%TYPE; v_rel_year content.releaseYear%TYPE; v_rel_quality content.videoQuality%TYPE; v_rel_desc content.description%TYPE; v_rel_runtime content.runtime%TYPE; v_rel_rating contentRating.ratingLabel%TYPE; v_rel_max_season NUMBER; v_rel_wish_count NUMBER; v_rel_found BOOLEAN := FALSE; v_episode_count NUMBER;
    BEGIN
        OPEN related_content_cursor;
        LOOP
            -- FETCH 목록 변경 (similarity_score)
            FETCH related_content_cursor INTO
                v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime,
                v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_similarity_score;
            EXIT WHEN related_content_cursor%NOTFOUND;

            v_rel_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- [유사도:' || NVL(v_rel_similarity_score, 0) || '] ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END; DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분'); END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부 ('||v_profile_nickname||'님): ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END);
        END LOOP;
        CLOSE related_content_cursor;
        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (유사한 콘텐츠 정보가 없습니다.)'); END IF;
    END; -- 내부 DECLARE 블록 종료
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');


    -- ==========================================================
    -- 섹션 3: 예고편 및 다른 영상 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 예고편 및 다른 영상 ---');
    v_found := FALSE; FOR trailer_rec IN (SELECT t.title, t.trailerURL FROM trailer t JOIN video v ON t.videoID = v.videoID WHERE v.contentID = v_content_id ORDER BY t.title) LOOP v_found := TRUE; DBMS_OUTPUT.PUT_LINE('  제목: ' || trailer_rec.title || ', URL: ' || trailer_rec.trailerURL); END LOOP;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (예고편 정보가 없습니다.)'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 4: 주요 정보 요약 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 주요 정보 요약 ---');
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('크리에이터: ' || NVL(v_creators, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('출연: ' || NVL(SUBSTR(v_cast, 1, 500), '정보 없음') || CASE WHEN LENGTH(v_cast) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('장르: ' || NVL(v_genres, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('특징: ' || NVL(v_features, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('시청등급: ' || NVL(v_ratingLabel, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');


EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('최종 오류 발생: ' || SQLERRM);
END;
/

-- 사용한 & 변수 정의 해제
UNDEFINE profile_id
UNDEFINE content_title





-- 특정 콘텐츠 상세 정보 + 관련 목록 + 회차별 시청상태 표시 (최종 수정: 시청 완료 상태 표시)

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

DECLARE
    -- 입력 변수 (프로필 ID 먼저)
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_content_title   content.title%TYPE     := '&content_title';

    -- 기본 정보 저장 변수 (이전과 동일)
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_creators        VARCHAR2(2000);
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;

    -- 시청 기록 저장을 위한 타입 및 변수 (수정됨: 필드 이름 변경 및 타입 확인)
    TYPE t_watch_rec IS RECORD (
        is_completed    viewingHistory.isCompleted%TYPE, -- CHAR(1)
        progress_sec    NUMBER -- viewingHistory.totalViewingTime%TYPE -> NUMBER로 변경
    );
    TYPE t_watch_hist_map IS TABLE OF t_watch_rec INDEX BY PLS_INTEGER; -- videoID를 키로 사용 (PLS_INTEGER)
    v_watch_history   t_watch_hist_map; -- 해당 콘텐츠의 모든 비디오 시청 상태 저장

    -- 루프용 변수
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_temp_num        NUMBER;
    v_found           BOOLEAN := FALSE;

    -- 시청 중 '대표' 정보 저장 변수
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;

    -- 기타 필요한 변수
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;

    -- 임시 테이블 타입 (BULK COLLECT용)
    TYPE t_watch_history_rec IS RECORD (
        videoID         viewingHistory.videoID%TYPE,
        isCompleted     viewingHistory.isCompleted%TYPE,
        totalViewingTime NUMBER -- viewingHistory.totalViewingTime%TYPE -> NUMBER로 변경
    );
    TYPE t_watch_history_tab IS TABLE OF t_watch_history_rec INDEX BY BINARY_INTEGER;
    v_temp_hist_tab t_watch_history_tab;


BEGIN
    -- ==========================================================
    -- 1. 기본 정보 조회 (프로필, 콘텐츠) - 변경 없음
    -- ==========================================================
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN; WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN; END;
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID; EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN; WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN; WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN; END;
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL; IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE; ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_temp_num > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END;
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_wishlisted := TRUE; ELSE v_is_wishlisted := FALSE; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM userRating ur WHERE ur.profileID = v_profile_id AND ur.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_rated := TRUE; ELSE v_is_rated := FALSE; END IF; END;
    BEGIN SELECT LISTAGG(a.name, ', ') WITHIN GROUP (ORDER BY al.actorListid) INTO v_cast FROM actor a JOIN actorList al ON a.actorid = al.actorid WHERE al.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(g.genreName, ', ') WITHIN GROUP (ORDER BY g.genreName) INTO v_genres FROM genre g JOIN genreList gl ON g.genreID = gl.genreID WHERE gl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(f.featureName, ', ') WITHIN GROUP (ORDER BY f.featureName) INTO v_features FROM feature f JOIN featureList fl ON f.featureID = fl.featureID WHERE fl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(cr.creatorName, ', ') WITHIN GROUP (ORDER BY cr.creatorName) INTO v_creators FROM creator cr JOIN creatorList cl ON cr.creatorID = cl.creatorID WHERE cl.contentID = v_content_id; END;

    -- 4. 모든 관련 시청 기록의 '최신 상태'를 맵에 저장 (이전과 동일)
    v_watch_history.DELETE;
    BEGIN
        SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime BULK COLLECT INTO v_temp_hist_tab
        FROM ( SELECT vh.videoID, vh.isCompleted, vh.totalViewingTime, ROW_NUMBER() OVER(PARTITION BY vh.videoID ORDER BY vh.lastViewat DESC) as rn FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id ) vh WHERE rn = 1;
        IF v_temp_hist_tab.COUNT > 0 THEN FOR i IN v_temp_hist_tab.FIRST .. v_temp_hist_tab.LAST LOOP v_watch_history(v_temp_hist_tab(i).videoID).is_completed := v_temp_hist_tab(i).isCompleted; v_watch_history(v_temp_hist_tab(i).videoID).progress_sec := v_temp_hist_tab(i).totalViewingTime; END LOOP; END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL; END;

    -- 대표 '시청 중' 정보 설정 (화면 상단 표시용)
    BEGIN SELECT epiruntime, totalViewingTime INTO v_watching_epi_runtime, v_watching_progress_sec FROM ( SELECT v.epiruntime, vh.totalViewingTime FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N' ORDER BY vh.lastViewat DESC ) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_watching_epi_runtime := NULL; v_watching_progress_sec := NULL; END;
    -- 첫 회차 정보 조회 (이전과 동일)
    IF v_is_series AND v_watching_epi_runtime IS NULL THEN BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END; END IF; -- 시청중('N') 기록 없을때만 조회하도록 수정
    -- 설명 정보 설정 (이전과 동일)
    IF v_is_series AND v_watch_history.COUNT > 0 THEN DECLARE temp_desc video.epiDescription%TYPE; BEGIN SELECT epiDescription INTO temp_desc FROM ( SELECT v.epiDescription FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id ORDER BY vh.lastViewat DESC) WHERE ROWNUM = 1; v_display_desc := NVL(temp_desc, v_content_rec.description); EXCEPTION WHEN NO_DATA_FOUND THEN v_display_desc := v_content_rec.description; END; ELSE v_display_desc := v_content_rec.description; END IF;
    -- 러닝타임 정보 설정 (이전과 동일)
    IF v_is_series THEN IF v_watching_epi_runtime IS NOT NULL THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분 (시청 중)'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;


    -- ==========================================================
    -- 1차 정보 출력 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear || ' / 시청 등급: ' || NVL(v_ratingLabel, '정보 없음') || CASE WHEN v_is_series THEN ' / 총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_watching_progress_sec IS NOT NULL AND v_watching_epi_runtime IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || v_watching_epi_runtime || '분 중 ' || ROUND(v_watching_progress_sec / 60) || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END || ' / 내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END || ' / 자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');


    -- ==========================================================
    -- 섹션 1: 회차 정보 (*** 시청 완료 상태 표시 로직 추가 ***)
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 ---');
        v_found := FALSE; -- 루프 내 결과 확인용 플래그
        -- 모든 에피소드 루프
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP
            v_found := TRUE; -- 일단 에피소드는 존재함
            DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음'));
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END);

            -- *** 시청 상태 확인 및 출력 (맵 사용) ***
            IF v_watch_history.EXISTS(epi_rec.videoID) THEN
                -- 해당 에피소드의 시청 기록(가장 마지막 상태)이 맵에 있으면
                IF v_watch_history(epi_rec.videoID).is_completed = 'Y' THEN
                    DBMS_OUTPUT.PUT_LINE('    ** 시청 완료 **');
                ELSIF v_watch_history(epi_rec.videoID).is_completed = 'N' THEN
                    DBMS_OUTPUT.PUT_LINE('    ** 시청 중 (진행: ' || ROUND(v_watch_history(epi_rec.videoID).progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분) **');
                END IF;
                -- 다른 isCompleted 값 ('X', NULL 등)은 무시하고 출력 안 함
            END IF;
            -- *** 시청 상태 확인 종료 ***

        END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;


    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (유사 콘텐츠) ---');
    DECLARE CURSOR related_content_cursor IS SELECT * FROM ( WITH TargetGenres AS (SELECT genreID FROM genreList WHERE contentID = v_content_id), TargetFeatures AS (SELECT featureID FROM featureList WHERE contentID = v_content_id), SharedGenreCounts AS (SELECT gl.contentID, COUNT(tg.genreID) as shared_genre_count FROM genreList gl JOIN TargetGenres tg ON gl.genreID = tg.genreID WHERE gl.contentID != v_content_id GROUP BY gl.contentID), SharedFeatureCounts AS (SELECT fl.contentID, COUNT(tf.featureID) as shared_feature_count FROM featureList fl JOIN TargetFeatures tf ON fl.featureID = tf.featureID WHERE fl.contentID != v_content_id GROUP BY fl.contentID) SELECT c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime, (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label, (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season, (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count, (NVL(sgc.shared_genre_count, 0) + NVL(sfc.shared_feature_count, 0)) as similarity_score FROM content c LEFT JOIN SharedGenreCounts sgc ON c.contentID = sgc.contentID LEFT JOIN SharedFeatureCounts sfc ON c.contentID = sfc.contentID WHERE c.contentID != v_content_id ORDER BY similarity_score DESC NULLS LAST, c.title ASC ) WHERE ROWNUM <= 10;
        v_rel_similarity_score NUMBER; v_rel_content_id  content.contentID%TYPE; v_rel_title content.title%TYPE; v_rel_thumb content.thumbnailURL%TYPE; v_rel_year content.releaseYear%TYPE; v_rel_quality content.videoQuality%TYPE; v_rel_desc content.description%TYPE; v_rel_runtime content.runtime%TYPE; v_rel_rating contentRating.ratingLabel%TYPE; v_rel_max_season NUMBER; v_rel_wish_count NUMBER; v_rel_found BOOLEAN := FALSE; v_episode_count NUMBER;
    BEGIN OPEN related_content_cursor; LOOP FETCH related_content_cursor INTO v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime, v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_similarity_score; EXIT WHEN related_content_cursor%NOTFOUND; v_rel_found := TRUE; DBMS_OUTPUT.PUT_LINE('  --- [유사도:' || NVL(v_rel_similarity_score, 0) || '] ' || v_rel_title || ' ---'); DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음')); IF v_rel_max_season IS NOT NULL THEN BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END; DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화'); ELSE DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분'); END IF; DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year); DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END); DBMS_OUTPUT.PUT_LINE('    찜 여부 ('||v_profile_nickname||'님): ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END); END LOOP; CLOSE related_content_cursor; IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (유사한 콘텐츠 정보가 없습니다.)'); END IF; END;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 3: 예고편 및 다른 영상 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 예고편 및 다른 영상 ---');
    v_found := FALSE; FOR trailer_rec IN (SELECT t.title, t.trailerURL FROM trailer t JOIN video v ON t.videoID = v.videoID WHERE v.contentID = v_content_id ORDER BY t.title) LOOP v_found := TRUE; DBMS_OUTPUT.PUT_LINE('  제목: ' || trailer_rec.title || ', URL: ' || trailer_rec.trailerURL); END LOOP;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (예고편 정보가 없습니다.)'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 4: 주요 정보 요약 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 주요 정보 요약 ---');
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('크리에이터: ' || NVL(v_creators, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('출연: ' || NVL(SUBSTR(v_cast, 1, 500), '정보 없음') || CASE WHEN LENGTH(v_cast) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('장르: ' || NVL(v_genres, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('특징: ' || NVL(v_features, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('시청등급: ' || NVL(v_ratingLabel, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');


EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('최종 오류 발생: ' || SQLERRM);
END;
/

