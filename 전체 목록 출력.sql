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
-- !!! 수정: 입력 순서 변경 (프로필 ID -> 자막 -> 언어), 추천 점수 출력 추가 !!!

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF; -- & 변수 확인 메시지 끄기 (선택적)

DECLARE
    -- 입력 변수 (& 사용, 순서 변경: 프로필 -> 자막 -> 언어)
    v_profile_id      profile.profileID%TYPE := &profile_id;     -- <<< 1. 추천 기준 프로필 ID 입력
    v_sub_req         CHAR(1)                := UPPER('&req_sub'); -- <<< 2. 자막 여부 (Y/N)
    v_language        audioLang.Language%TYPE := '&req_lang';    -- <<< 3. 언어 (예: Korean)

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
        WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                      WHERE v.contentID = cbi.contentID AND al.Language = v_language -- PL/SQL 변수 사용
                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) -- PL/SQL 변수 사용
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
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;

    -- 프로필 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req);
    DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
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



-- [통합 + & 입력] 언어/자막/정렬/프로필ID(& 변수)로 필터링 + 선택적 정렬 + DBMS 출력 (수정 11: 바인드 변수 오류 수정)
-- [통합 + & 입력] ... (수정 13: 정적 커서 및 개별 루프 사용)

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

DECLARE
    -- 입력 변수 (프로필 ID 먼저)
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


-- [동적 쿼리 - 최종 재시도] 언어/자막/정렬/프로필ID(& 변수)로 필터링 + 선택적 정렬 + DBMS 출력
-- !!! 경고: 이 방식은 사용자 환경에서 SP2-0552 또는 ORA-01008 오류를 반복적으로 유발했습니다. !!!
-- !!! 클라이언트 환경에 따라 여전히 오류가 발생할 수 있습니다. !!!

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

DECLARE
    -- PL/SQL 변수에 & 치환 변수 값 할당 (프로필 ID -> 자막 -> 언어 -> 정렬 순서)
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_sub_req         CHAR(1)                := UPPER('&req_sub');
    v_language        audioLang.Language%TYPE := '&req_lang';
    v_sort_option     VARCHAR2(20)           := UPPER('&req_sort');

    ref_cursor      SYS_REFCURSOR;
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_score         NUMBER; -- 추천 점수 저장용
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    IF v_sort_option NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN DBMS_OUTPUT.PUT_LINE('오류: 유효하지 않은 정렬 기준입니다.'); RETURN; END IF;

    -- 프로필 닉네임 조회
    IF v_sort_option = 'RECOMMEND' THEN BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END; END IF;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option);
    IF v_sort_option = 'RECOMMEND' THEN DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname || ' (ID: ' || v_profile_id || ')'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 정렬 기준에 따라 다른 쿼리를 OPEN FOR ... USING ...
    IF v_sort_option = 'TITLE_ASC' THEN
        OPEN ref_cursor FOR -- 위치 기반 바인드 변수 :1, :2 사용
            'SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi ' ||
            'WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title ASC'
        USING v_language, v_sub_req;

    ELSIF v_sort_option = 'TITLE_DESC' THEN
        OPEN ref_cursor FOR -- 위치 기반 바인드 변수 :1, :2 사용
            'SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi ' ||
            'WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title DESC'
        USING v_language, v_sub_req;

    ELSIF v_sort_option = 'RELEASE_DATE' THEN
        OPEN ref_cursor FOR -- 위치 기반 바인드 변수 :1, :2 사용
            'SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi JOIN content c ON cbi.contentID = c.contentID ' ||
            'WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY c.releaseDate DESC, cbi.title ASC'
        USING v_language, v_sub_req;

    ELSIF v_sort_option = 'RECOMMEND' THEN
        OPEN ref_cursor FOR -- 이름 지정 바인드 변수 사용 (:p_id1, :p_id2, :lang, :sub)
            'WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = :p_id1 AND cnt > 0), ' ||
            '     ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = :p_id2 AND cnt > 0), ' ||
            '     ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID), ' ||
            '     ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID) ' ||
            'SELECT cbi.title, cbi.thumbnailURL, (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score ' ||
            'FROM vw_content_basic_info cbi LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID ' ||
            'WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :lang AND (:sub = ''N'' OR (:sub = ''Y'' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) ORDER BY final_score DESC NULLS LAST, cbi.title ASC'
        USING v_profile_id, v_profile_id, v_language, v_sub_req; -- 순서: :p_id1, :p_id2, :lang, :sub

    END IF;

    -- 공통 루프
    LOOP
        IF v_sort_option = 'RECOMMEND' THEN FETCH ref_cursor INTO v_title, v_thumbnailURL, v_score; EXIT WHEN ref_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        ELSE FETCH ref_cursor INTO v_title, v_thumbnailURL; EXIT WHEN ref_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END IF;
    END LOOP;
    CLOSE ref_cursor;

    -- Footer...
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF ref_cursor%ISOPEN THEN CLOSE ref_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/


-- 다나와
-- emp 테이블에서 검색 기능 구현
-- 1) 검색조건    : 1 부서번호, 2 사원명, 3 잡
-- 2) 검색어      : [     ]
CREATE OR REPLACE PROCEDURE up_ndsSearchEmp
(
    profileID NUMBER
    , req_subtitle NUMBER -- 1. Y, 2. N
    , lang varchar(50) -- 1. title_asc, 2. title_desc, 3. 최신, 4. 추천
    , psearchWord VARCHAR2
)
IS
  vsql  VARCHAR2(2000);
  vcur  SYS_REFCURSOR ;   -- 커서 타입으로 변수 선언  9i  REF CURSOR
  vrow emp%ROWTYPE;
BEGIN
  vsql := 'SELECT * ';
  vsql := vsql || ' FROM vw_content_basic_info ';
  
  IF psearchCondition = 1 THEN -- title_asc
    vsql := vsql || ' WHERE  deptno = :psearchWord AND profileID = :profileID AND and lang = :lang ' || 'ORDER BY title ASC';
  ELSIF psearchCondition = 2 THEN -- 사원명
    vsql := vsql || ' WHERE  deptno = :psearchWord AND profileID = :profileID AND and lang = :lang ' || 'ORDER BY title DESC';    
  ELSIF psearchCondition = 3  THEN 
    vsql := vsql || ' WHERE  deptno = :psearchWord AND profileID = :profileID AND and lang = :lang ' || 'ORDER BY public DESC'; 
  ELSIF psearchCondition = 3  THEN 
    vsql := vsql || ' WHERE  deptno = :psearchWord AND profileID = :profileID AND and lang = :lang ' || 'ORDER BY 추천순'; 
  END IF; 
   
  OPEN vcur  FOR vsql USING psearchWord;
  LOOP  
    FETCH vcur INTO vrow;
    EXIT WHEN vcur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE( vrow.empno || ' '  || vrow.ename || ' ' || vrow.job );
  END LOOP;   
  CLOSE vcur; 
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, '>EMP DATA NOT FOUND...');
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004, '>OTHER ERROR...');
END;

EXEC UP_NDSSEARCHEMP(1, '20'); 
EXEC UP_NDSSEARCHEMP(2, 'L'); 
EXEC UP_NDSSEARCHEMP(3, 's'); 





CREATE OR REPLACE PROCEDURE usp_PrintContentList (
    p_profile_id    IN NUMBER,
    p_sub_req       IN CHAR     DEFAULT 'N',
    p_language      IN VARCHAR2 DEFAULT 'English',
    p_sort_option   IN VARCHAR2 DEFAULT 'RECOMMEND'
)
IS
    v_sql           VARCHAR2(4000);
    v_sort_option_upper VARCHAR2(20) := UPPER(p_sort_option);
    v_sub_req_upper   CHAR(1)      := UPPER(p_sub_req);

    v_cursor        SYS_REFCURSOR;
    v_title         content.title%TYPE;
    v_thumbnailURL  content.thumbnailURL%TYPE;
    v_score         NUMBER;
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;
    v_schema_name   VARCHAR2(30) := 'NETFLIX'; -- <<< 사용자 스키마로 변경!

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req_upper NOT IN ('Y', 'N') OR p_language IS NULL OR v_sort_option_upper NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid input parameter value.');
    END IF;

    -- 프로필 닉네임 조회
    IF v_sort_option_upper = 'RECOMMEND' THEN BEGIN SELECT nickname INTO v_profile_nickname FROM NETFLIX.profile WHERE profileID = p_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || p_profile_id || ')'; END; END IF;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req_upper); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || p_language);
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option_upper);
    IF v_sort_option_upper = 'RECOMMEND' THEN DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname || ' (ID: ' || p_profile_id || ')'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 정렬 기준에 따라 다른 쿼리를 OPEN (모든 Bind 변수 위치 기반 :1, :2 ... 사용)
    IF v_sort_option_upper = 'TITLE_ASC' THEN
        v_sql := 'SELECT cbi.title, cbi.thumbnailURL FROM '||v_schema_name||'.vw_content_basic_info cbi ' ||
                 'WHERE EXISTS (SELECT 1 FROM '||v_schema_name||'.video v JOIN '||v_schema_name||'.audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM '||v_schema_name||'.subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title ASC';
        OPEN v_cursor FOR v_sql USING p_language, v_sub_req_upper; -- USING 2개 (:1, :2)

    ELSIF v_sort_option_upper = 'TITLE_DESC' THEN
        v_sql := 'SELECT cbi.title, cbi.thumbnailURL FROM '||v_schema_name||'.vw_content_basic_info cbi ' ||
                 'WHERE EXISTS (SELECT 1 FROM '||v_schema_name||'.video v JOIN '||v_schema_name||'.audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM '||v_schema_name||'.subtitle s WHERE s.videoID = v.videoID)))) ORDER BY cbi.title DESC';
        OPEN v_cursor FOR v_sql USING p_language, v_sub_req_upper; -- USING 2개 (:1, :2)

    ELSIF v_sort_option_upper = 'RELEASE_DATE' THEN
         v_sql := 'SELECT c.title, c.thumbnailURL FROM '||v_schema_name||'.content c ' || -- vw_content_basic_info 대신 content 직접 사용, alias 'c'
                  'WHERE EXISTS (SELECT 1 FROM '||v_schema_name||'.video v JOIN '||v_schema_name||'.audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = c.contentID AND al.Language = :1 AND (:2 = ''N'' OR (:2 = ''Y'' AND EXISTS (SELECT 1 FROM '||v_schema_name||'.subtitle s WHERE s.videoID = v.videoID)))) ORDER BY c.releaseDate DESC, c.title ASC';
         OPEN v_cursor FOR v_sql USING p_language, v_sub_req_upper; -- USING 2개 (:1, :2)

    ELSIF v_sort_option_upper = 'RECOMMEND' THEN
        -- 위치 기반 바인드 변수 :1 (pid1), :2 (pid2), :3 (lang), :4 (sub) 사용
        v_sql := 'WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM '||v_schema_name||'.genreViewCnt WHERE profileID = :1 AND cnt > 0), ' ||
                 '     ProfileFeaturePrefs AS (SELECT featureID, cnt FROM '||v_schema_name||'.featureViewCnt WHERE profileID = :2 AND cnt > 0), ' ||
                 '     ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM '||v_schema_name||'.genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID), ' ||
                 '     ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM '||v_schema_name||'.featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID) ' ||
                 'SELECT cbi.title, cbi.thumbnailURL, (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score ' ||
                 'FROM '||v_schema_name||'.vw_content_basic_info cbi LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID ' ||
                 'WHERE EXISTS (SELECT 1 FROM '||v_schema_name||'.video v JOIN '||v_schema_name||'.audioLang al ON v.audioLangID = al.audioLangID WHERE v.contentID = cbi.contentID AND al.Language = :3 AND (:4 = ''N'' OR (:4 = ''Y'' AND EXISTS (SELECT 1 FROM '||v_schema_name||'.subtitle s WHERE s.videoID = v.videoID)))) ' ||
                 'ORDER BY final_score DESC NULLS LAST, cbi.title ASC';
        OPEN v_cursor FOR v_sql USING p_profile_id, p_profile_id, p_language, v_sub_req_upper; -- USING 4개 (:1, :2, :3, :4 순서대로)

    END IF;

    -- FETCH 루프 (이전과 동일)
    LOOP
        IF v_sort_option_upper = 'RECOMMEND' THEN FETCH v_cursor INTO v_title, v_thumbnailURL, v_score; EXIT WHEN v_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        ELSE FETCH v_cursor INTO v_title, v_thumbnailURL; EXIT WHEN v_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END IF;
    END LOOP;
    CLOSE v_cursor;

    -- Footer...
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF v_cursor%ISOPEN THEN CLOSE v_cursor; END IF; RAISE; END;

/
-- 예시 1: 기본값 사용 (자막 N, 언어 English, 정렬 RECOMMEND)
BEGIN
  usp_PrintContentList(p_profile_id => 1);
END;
/

-- 예시 2: 언어와 정렬 기준 변경
BEGIN
  usp_PrintContentList(p_profile_id => 1, p_language => 'Korean', p_sort_option => 'TITLE_ASC');
END;
/

-- 예시 3: 모든 값 직접 지정
BEGIN
  usp_PrintContentList(p_profile_id => 2, p_sub_req => 'Y', p_language => 'Japanese', p_sort_option => 'RELEASE_DATE');
END;
/