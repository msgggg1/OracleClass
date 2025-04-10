CREATE OR REPLACE VIEW vw_content_basic_info AS
SELECT
    contentID,
    title,
    thumbnailURL
FROM
    content;
/

-- [제목 오름차순] 언어(&req_lang) 및 자막 필요 여부(&req_sub)로 필터링 후 DBMS 출력
-- 실행 시 자막(Y/N), 언어 순서로 입력 요구

DECLARE
    v_sub_req     CHAR(1)                 := UPPER('&req_sub');
    v_language    audioLang.Language%TYPE := '&req_lang';
    CURSOR filtered_content_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                      WHERE v.contentID = cbi.contentID AND al.Language = v_language
                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
        ORDER BY cbi.title ASC;
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
BEGIN
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬: 제목 오름차순');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');
    OPEN filtered_content_cursor;
    LOOP FETCH filtered_content_cursor INTO v_title, v_thumbnailURL; EXIT WHEN filtered_content_cursor%NOTFOUND;
        v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP; CLOSE filtered_content_cursor;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
EXCEPTION WHEN OTHERS THEN IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/


-- [제목 내림차순] 언어(&req_lang) 및 자막 필요 여부(&req_sub)로 필터링 후 DBMS 출력
-- 실행 시 자막(Y/N), 언어 순서로 입력 요구

DECLARE
    v_sub_req     CHAR(1)                 := UPPER('&req_sub');
    v_language    audioLang.Language%TYPE := '&req_lang';
    CURSOR filtered_content_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                      WHERE v.contentID = cbi.contentID AND al.Language = v_language
                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
        ORDER BY cbi.title DESC; -- ORDER BY 변경
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
BEGIN
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬: 제목 내림차순');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');
    OPEN filtered_content_cursor;
    LOOP FETCH filtered_content_cursor INTO v_title, v_thumbnailURL; EXIT WHEN filtered_content_cursor%NOTFOUND;
        v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP; CLOSE filtered_content_cursor;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
EXCEPTION WHEN OTHERS THEN IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- [출시일 최신순] 언어(&req_lang) 및 자막 필요 여부(&req_sub)로 필터링 후 DBMS 출력
-- 실행 시 자막(Y/N), 언어 순서로 입력 요구

DECLARE
    v_sub_req     CHAR(1)                 := UPPER('&req_sub');
    v_language    audioLang.Language%TYPE := '&req_lang';
    CURSOR filtered_content_cursor IS
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi JOIN content c ON cbi.contentID = c.contentID -- content 조인
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                      WHERE v.contentID = cbi.contentID AND al.Language = v_language
                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
        ORDER BY c.releaseDate DESC, cbi.title ASC; -- ORDER BY 변경
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
BEGIN
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬: 출시일 최신순');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');
    OPEN filtered_content_cursor;
    LOOP FETCH filtered_content_cursor INTO v_title, v_thumbnailURL; EXIT WHEN filtered_content_cursor%NOTFOUND;
        v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP; CLOSE filtered_content_cursor;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
EXCEPTION WHEN OTHERS THEN IF filtered_content_cursor%ISOPEN THEN CLOSE filtered_content_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;


-- [추천순] 언어(&req_lang), 자막(&req_sub), 프로필ID(&profile_id)로 필터링/계산 후 DBMS 출력
-- 실행 시 자막(Y/N), 언어, 프로필 ID 순서로 입력 요구

DECLARE
    v_sub_req     CHAR(1)                 := UPPER('&req_sub');
    v_language    audioLang.Language%TYPE := '&req_lang';
    v_profile_id  profile.profileID%TYPE  := &profile_id; -- <<< 추천 기준 프로필 ID 입력

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
        SELECT cbi.title, cbi.thumbnailURL
        FROM vw_content_basic_info cbi
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                      WHERE v.contentID = cbi.contentID AND al.Language = v_language
                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
        ORDER BY (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST, cbi.title ASC; -- ORDER BY 변경

    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;
BEGIN
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬: 추천순 (프로필: ' || v_profile_nickname || ')');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');
    OPEN recommendation_cursor;
    LOOP FETCH recommendation_cursor INTO v_title, v_thumbnailURL; EXIT WHEN recommendation_cursor%NOTFOUND;
        v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP; CLOSE recommendation_cursor;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
EXCEPTION WHEN OTHERS THEN IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/
