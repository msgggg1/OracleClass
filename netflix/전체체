
View VW_CONTENT_BASIC_INFO이(가) 생성되었습니다.

이전:DECLARE
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

신규:DECLARE
    v_sub_req     CHAR(1)                 := UPPER('Y');
    v_language    audioLang.Language%TYPE := '영어';
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

PL/SQL 프로시저가 성공적으로 완료되었습니다.

이전:DECLARE
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

신규:DECLARE
    v_sub_req     CHAR(1)                 := UPPER('y');
    v_language    audioLang.Language%TYPE := '영어';
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

PL/SQL 프로시저가 성공적으로 완료되었습니다.


대체 취소

대체 취소

대체 취소

View VW_CONTENT_BASIC_INFO이(가) 생성되었습니다.

이전:DECLARE
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

신규:DECLARE
    v_sub_req     CHAR(1)                 := UPPER('Y');
    v_language    audioLang.Language%TYPE := '영어';
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
--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬: 제목 오름차순
-------------------------------------
--- 콘텐츠 목록 ---
제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
제목: 인셉션, 썸네일URL: thumb/inception.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

이전:DECLARE
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

신규:DECLARE
    v_sub_req     CHAR(1)                 := UPPER('ㅛ');
    v_language    audioLang.Language%TYPE := '영어';
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
DECLARE
*
오류 발생 행: 1:
ORA-06502: PL/SQL: numeric or value error: character string buffer too small
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-06502/


More Details :
https://docs.oracle.com/error-help/db/ora-06502/
https://docs.oracle.com/error-help/db/ora-06512/
이전:DECLARE
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

신규:DECLARE
    v_sub_req     CHAR(1)                 := UPPER('Y');
    v_language    audioLang.Language%TYPE := '영어';
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
    v_sub_req     CHAR(1)                 := UPPER('y');
    v_language    audioLang.Language%TYPE := 'DUDDU';
    v_profile_id  profile.profileID%TYPE  := Y; -- <<< 추천 기준 프로필 ID 입력

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
DECLARE
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "DECLARE" 
ORA-06550: line 38, column 9:
PLS-00103: Encountered the symbol "WITH" when expecting one of the following:

   ( select <a SQL statement>

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/

대체 취소

대체 취소
DECLARE
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "DECLARE" 
ORA-06550: line 38, column 9:
PLS-00103: Encountered the symbol "WITH" when expecting one of the following:

   ( select <a SQL statement>

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/
DECLARE
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "DECLARE" 
ORA-06550: line 38, column 9:
PLS-00103: Encountered the symbol "WITH" when expecting one of the following:

   ( select <a SQL statement>

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/

대체 취소
--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬: 제목 오름차순
-------------------------------------
--- 콘텐츠 목록 ---
제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
제목: 인셉션, 썸네일URL: thumb/inception.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

SET SERVEROUTPUT ON SIZE UNLIMITED;
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "SET" 

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/
SET SERVEROUTPUT ON SIZE UNLIMITED;
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "SET" 

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/
--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬: 추천순 (프로필: 앨리스_키즈)
-------------------------------------
--- 콘텐츠 목록 ---
[점수: 40] 제목: 인셉션, 썸네일URL: thumb/inception.jpg
[점수: 7] 제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

SP2-0552: 바인드 변수 "SUB"이(가) 선언되지 않았습니다.
SP2-0552: 바인드 변수 "SUB"이(가) 선언되지 않았습니다.
SP2-0552: 바인드 변수 "SUB"이(가) 선언되지 않았습니다.

View VW_CONTENT_BASIC_INFO이(가) 생성되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬: 제목 오름차순
-------------------------------------
--- 콘텐츠 목록 ---
제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
제목: 인셉션, 썸네일URL: thumb/inception.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬: 제목 내림차순
-------------------------------------
--- 콘텐츠 목록 ---
제목: 인셉션, 썸네일URL: thumb/inception.jpg
제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

SET SERVEROUTPUT ON SIZE UNLIMITED;
*
오류 발생 행: 32:
ORA-06550: line 32, column 1:
PLS-00103: Encountered the symbol "SET" 

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/

대체 취소
SP2-0552: 바인드 변수 "4"이(가) 선언되지 않았습니다.
SP2-0552: 바인드 변수 "4"이(가) 선언되지 않았습니다.
--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---
제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
제목: 인셉션, 썸네일URL: thumb/inception.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬 기준: RECOMMEND
추천 기준 프로필: 앨리스_메인 (ID: 1)
-------------------------------------
--- 콘텐츠 목록 ---
[점수: 37] 제목: 인셉션, 썸네일URL: thumb/inception.jpg
[점수: 16] 제목: 기묘한 이야기, 썸네일URL: thumb/stranger.jpg
-------------------------------------


PL/SQL 프로시저가 성공적으로 완료되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---
오류 발생: ORA-01008: not all variables bound


PL/SQL 프로시저가 성공적으로 완료되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---
오류 발생: ORA-01008: not all variables bound


PL/SQL 프로시저가 성공적으로 완료되었습니다.

--- 검색 조건 ---
자막 필수: Y
오디오 언어: 영어
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---
오류 발생: ORA-01008: not all variables bound


PL/SQL 프로시저가 성공적으로 완료되었습니다.


Procedure USP_GETCONTENTLIST이(가) 컴파일되었습니다.

BEGIN usp_GetContentList(p_profile_id => 1, p_sub_req => 'N', p_language => 'Korean', p_sort_option => 'RECOMMEND', p_result_cursor => :rcv); END;
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_GETCONTENTLIST", line 64
ORA-06512: at line 1

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/

RCV

BEGIN usp_GetContentList(p_profile_id => 1, p_sub_req => 'N', p_language => 'Korean', p_sort_option => 'RECOMMEND', p_result_cursor => :rcv); END;
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_GETCONTENTLIST", line 64
ORA-06512: at line 1

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
BEGIN usp_GetContentList(p_profile_id => 1, p_sub_req => 'N', p_language => 'Korean', p_sort_option => 'RECOMMEND', p_result_cursor => :rcv); END;
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_GETCONTENTLIST", line 64
ORA-06512: at line 1

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/

RCV


Procedure USP_GETCONTENTLIST이(가) 컴파일되었습니다.

BEGIN usp_GetContentList(p_profile_id => 1, p_sub_req => 'N', p_language => 'Korean', p_sort_option => 'RECOMMEND', p_result_cursor => :rcv); END;
*
오류 발생 행: 1:
ORA-00903: invalid table name
ORA-06512: at "NETFLIX.USP_GETCONTENTLIST", line 61
ORA-06512: at line 1

https://docs.oracle.com/error-help/db/ora-00903/


More Details :
https://docs.oracle.com/error-help/db/ora-00903/
https://docs.oracle.com/error-help/db/ora-06512/

RCV


Procedure USP_GETCONTENTLIST이(가) 컴파일되었습니다.

BEGIN usp_GetContentList(p_profile_id => 1, p_sub_req => 'N', p_language => 'Korean', p_sort_option => 'RECOMMEND', p_result_cursor => :rcv); END;
*
오류 발생 행: 1:
ORA-00903: invalid table name
ORA-06512: at "NETFLIX.USP_GETCONTENTLIST", line 61
ORA-06512: at line 1

https://docs.oracle.com/error-help/db/ora-00903/


More Details :
https://docs.oracle.com/error-help/db/ora-00903/
https://docs.oracle.com/error-help/db/ora-06512/

RCV


Procedure USP_GETCONTENTLIST이(가) 컴파일되었습니다.

BEGIN usp_GetContentList(p_profile_id => 1, p_result_cursor => :rcv); -- profile_id만 전달; END;
                                                                                            *
오류 발생 행: 1:
ORA-06550: line 1, column 93:
PLS-00103: Encountered the symbol "end-of-file" when expecting one of the following:

   ( begin case declare end exception exit for goto if loop mod
   null pragma raise return select update while with
   <an identifier> <a double-quoted delimited-identifier>
   <a bind variable> << continue close current delete fetch lock
   insert open rollback savepoint set sql execute commit forall
   merge pipe purge

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/

RCV

BEGIN usp_GetContentList(p_profile_id => 1, p_result_cursor => :rcv); -- profile_id만 전달; END;
                                                                                            *
오류 발생 행: 1:
ORA-06550: line 1, column 93:
PLS-00103: Encountered the symbol "end-of-file" when expecting one of the following:

   ( begin case declare end exception exit for goto if loop mod
   null pragma raise return select update while with
   <an identifier> <a double-quoted delimited-identifier>
   <a bind variable> << continue close current delete fetch lock
   insert open rollback savepoint set sql execute commit forall
   merge pipe purge

https://docs.oracle.com/error-help/db/ora-06550/


More Details :
https://docs.oracle.com/error-help/db/ora-06550/
https://docs.oracle.com/error-help/db/pls-00103/

Procedure USP_PRINTCONTENTLIST이(가) 컴파일되었습니다.

--- 검색 조건 ---
자막 필수: N
오디오 언어: English
정렬 기준: RECOMMEND
추천 기준 프로필: 앨리스_메인 (ID: 1)
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 97
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
--- 검색 조건 ---
자막 필수: N
오디오 언어: Korean
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 97
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
--- 검색 조건 ---
자막 필수: Y
오디오 언어: Japanese
정렬 기준: RELEASE_DATE
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 97
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/

Procedure USP_PRINTCONTENTLIST이(가) 컴파일되었습니다.

--- 검색 조건 ---
자막 필수: N
오디오 언어: English
정렬 기준: RECOMMEND
추천 기준 프로필: 앨리스_메인 (ID: 1)
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 77
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
--- 검색 조건 ---
자막 필수: N
오디오 언어: Korean
정렬 기준: TITLE_ASC
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 77
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
--- 검색 조건 ---
자막 필수: Y
오디오 언어: Japanese
정렬 기준: RELEASE_DATE
-------------------------------------
--- 콘텐츠 목록 ---

BEGIN
*
오류 발생 행: 1:
ORA-01008: not all variables bound
ORA-06512: at "NETFLIX.USP_PRINTCONTENTLIST", line 77
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-01008/


More Details :
https://docs.oracle.com/error-help/db/ora-01008/
https://docs.oracle.com/error-help/db/ora-06512/
