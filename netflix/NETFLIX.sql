--  목록을 출력하는 쿼리
CREATE OR REPLACE VIEW vw_content_basic_info AS
SELECT
    contentID,
    title,
    thumbnailURL
FROM
    content;


DECLARE
    v_sub_req     CHAR(1)                 := UPPER('&req_sub'); -- <<< 자막 여부(&req_sub)를 먼저 입력받음
    v_language    audioLang.Language%TYPE := '&req_lang';    -- <<< 언어(&req_lang)를 나중에 입력받음

    -- 커서 정의 (내부 로직은 변경 없음, PL/SQL 변수를 사용)
    CURSOR filtered_content_cursor IS
        SELECT
            cbi.title,
            cbi.thumbnailURL
        FROM
            vw_content_basic_info cbi -- 콘텐츠 기본 정보 뷰 사용 (미리 생성되어 있어야 함)
        WHERE
            EXISTS ( -- 이 콘텐츠(cbi)에 속한 비디오 중 아래 조건을 만족하는 것이 하나라도 있는지 확인
                SELECT 1
                FROM video v
                JOIN audioLang al ON v.audioLangID = al.audioLangID -- 비디오와 오디오 언어 조인
                WHERE v.contentID = cbi.contentID     -- 현재 뷰의 콘텐츠 ID와 비디오의 콘텐츠 ID 연결
                  AND al.Language = v_language        -- PL/SQL 변수 v_language 사용
                  AND (                               -- 자막 요구사항 확인 (괄호로 묶음)
                        v_sub_req = 'N'               -- PL/SQL 변수 v_sub_req 사용
                        OR
                        (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))
                      )
            )
        ORDER BY
            cbi.title ASC; -- 제목 오름차순으로 정렬

    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE; -- 결과 있는지 확인용

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN
       DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.');
       RETURN;
    END IF;

    -- 검색 조건 출력 (순서 맞춰주면 더 보기 좋음)
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req);
    DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 커서를 열고 데이터를 가져와 출력
    OPEN filtered_content_cursor;
    LOOP
        FETCH filtered_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN filtered_content_cursor%NOTFOUND; -- 더 이상 가져올 데이터가 없으면 루프 종료

        v_found := TRUE; -- 결과 찾음 표시
        -- 각 콘텐츠 정보(제목, 썸네일 URL)를 텍스트로 출력
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);

    END LOOP;
    CLOSE filtered_content_cursor; -- 커서 닫기

    -- 결과가 없는 경우 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 그 외 예외 발생 시
        IF filtered_content_cursor%ISOPEN THEN
            CLOSE filtered_content_cursor; -- 커서가 열려있으면 닫기
        END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM); -- 오류 메시지 출력
END;

/

-- 언어/자막/정렬(& 변수)로 필터링 + 선택적 정렬 + DBMS 출력 (최종)

DECLARE
    -- PL/SQL 변수에 & 치환 변수 값 할당 (원하는 프롬프트 순서대로 선언)
    v_sub_req     CHAR(1)                 := UPPER('&req_sub'); -- 1. 자막 여부 (&req_sub)
    v_language    audioLang.Language%TYPE := '&req_lang';    -- 2. 언어 (&req_lang)
    v_sort_option VARCHAR2(20)            := UPPER('&req_sort'); -- 3. 정렬 기준 (&req_sort)

    -- 결과를 받을 커서 변수
    ref_cursor      SYS_REFCURSOR;

    -- 커서에서 읽어올 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;
    v_profile_id    profile.profileID%TYPE := 1; -- 추천 정렬 기준 프로필 ID (예: 1번 프로필)
                                                -- 이 ID도 &으로 받으려면 변수 선언 추가 필요

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN
       DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.');
       RETURN;
    END IF;
    IF v_sort_option NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN
       DBMS_OUTPUT.PUT_LINE('오류: 유효하지 않은 정렬 기준입니다. (TITLE_ASC, TITLE_DESC, RELEASE_DATE, RECOMMEND)');
       RETURN;
    END IF;

    -- 프로필 닉네임 조회 (출력 및 추천 정렬 시 사용)
    BEGIN
        SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')';
    END;

    -- 검색 조건 출력 (PL/SQL 변수 값 사용)
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req);
    DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option);
    IF v_sort_option = 'RECOMMEND' THEN
         DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname);
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 정렬 기준에 따라 다른 **정적 SQL** 쿼리를 ref_cursor에 OPEN
    -- (동적 SQL 문자열 구성 대신 OPEN FOR 문에 직접 쿼리 작성)
    IF v_sort_option = 'TITLE_ASC' THEN
        OPEN ref_cursor FOR
            SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
            WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                          WHERE v.contentID = cbi.contentID AND al.Language = :1 -- 바인드 변수 1: 언어
                            AND (:2 = 'N' OR (:2 = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) -- 바인드 변수 2: 자막
            ORDER BY cbi.title ASC
        USING v_language, v_sub_req; -- USING 절에 PL/SQL 변수 값 전달

    ELSIF v_sort_option = 'TITLE_DESC' THEN
        OPEN ref_cursor FOR
            SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
            WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                          WHERE v.contentID = cbi.contentID AND al.Language = :1
                            AND (:2 = 'N' OR (:2 = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
            ORDER BY cbi.title DESC
        USING v_language, v_sub_req;

    ELSIF v_sort_option = 'RELEASE_DATE' THEN
        OPEN ref_cursor FOR
            SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi JOIN content c ON cbi.contentID = c.contentID
            WHERE EXISTS (SELECT 1 FROM video v JOIN audioLang al ON v.audioLangID = al.audioLangID
                          WHERE v.contentID = cbi.contentID AND al.Language = :1
                            AND (:2 = 'N' OR (:2 = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID))))
            ORDER BY c.releaseDate DESC, cbi.title ASC
        USING v_language, v_sub_req;

    ELSIF v_sort_option = 'RECOMMEND' THEN
        OPEN ref_cursor FOR
            WITH ProfileGenrePrefs AS (
                SELECT genreID, cnt FROM genreViewCnt WHERE profileID = :p_id1 AND cnt > 0 -- 바인드 변수 :p_id1
            ), ProfileFeaturePrefs AS (
                SELECT featureID, cnt FROM featureViewCnt WHERE profileID = :p_id2 AND cnt > 0 -- 바인드 변수 :p_id2
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
                          WHERE v.contentID = cbi.contentID AND al.Language = :lang -- 바인드 변수 :lang
                            AND (:sub = 'N' OR (:sub = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) -- 바인드 변수 :sub
            ORDER BY (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST, cbi.title ASC
        USING v_profile_id, v_profile_id, v_language, v_sub_req; -- USING 절 순서: :p_id1, :p_id2, :lang, :sub

    END IF;

    -- 공통 루프: ref_cursor에서 데이터 가져와 출력
    LOOP
        FETCH ref_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN ref_cursor%NOTFOUND;
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE ref_cursor;

    -- 결과 없는 경우 메시지 출력
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF ref_cursor%ISOPEN THEN CLOSE ref_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/


--- 영화만 / 드라마만 / 애니만




DESC audioLang;



--- 배우에 맞춰서
--- 크리에이터에 맞춰서
--- 인기작
--- 신작
--- 구작
--- top 10 출력 => 결정 방식 고민
--
--한 영상의 모든 정보 출력 - 정보, 에피소드, 관련 영상, 배우
--
--계정
--- 현재 적용한 멤버쉽
--- 가지고 있는 프로필
--- 각 프로필의 정보
--- 각 프로필의 찜 목록





--- 사용자 선호도 고려 전체 출력
CREATE OR REPLACE VIEW vw_content_basic_info AS
SELECT
    contentID,
    title,
    thumbnailURL
FROM
    content;

CREATE OR REPLACE PROCEDURE sp_recommend_score_by_sum (
    p_profile_id IN profile.profileID%TYPE -- 입력받을 프로필 ID
)
AS
    -- 커서: genreViewCnt/featureViewCnt 기반 점수 합산 방식으로 콘텐츠 추천 순서 정렬
    CURSOR recommendation_cursor IS
        WITH ProfileGenrePrefs AS (
            -- 1a. 입력된 프로필의 장르별 시청 횟수(cnt) 조회
            SELECT genreID, cnt
            FROM genreViewCnt
            WHERE profileID = p_profile_id AND cnt > 0
        ),
        ProfileFeaturePrefs AS (
            -- 1b. 입력된 프로필의 특징별 시청 횟수(cnt) 조회
            SELECT featureID, cnt
            FROM featureViewCnt
            WHERE profileID = p_profile_id AND cnt > 0
        ),
        ContentGenreScores AS (
            -- 2a. 각 콘텐츠별 '총 장르 선호도 점수' 계산 (ProfileGenrePrefs의 cnt 값 합산)
            SELECT
                gl.contentID,
                SUM(NVL(pgp.cnt, 0)) as total_genre_score
            FROM genreList gl
            LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID
            GROUP BY gl.contentID
        ),
        ContentFeatureScores AS (
            -- 2b. 각 콘텐츠별 '총 특징 선호도 점수' 계산 (ProfileFeaturePrefs의 cnt 값 합산)
            SELECT
                fl.contentID,
                SUM(NVL(pfp.cnt, 0)) as total_feature_score
            FROM featureList fl
            LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID
            GROUP BY fl.contentID
        )
        -- 3. 최종 결과: 콘텐츠 정보와 계산된 점수를 결합하고 정렬
        SELECT
            cbi.title,        -- 콘텐츠 제목 (뷰에서 가져옴)
            cbi.thumbnailURL  -- 콘텐츠 썸네일 URL (뷰에서 가져옴)
            -- , (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score -- 최종 점수 확인용
        FROM
            vw_content_basic_info cbi -- 기본 콘텐츠 정보 뷰 사용
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID -- 콘텐츠별 장르 점수 연결
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID -- 콘텐츠별 특징 점수 연결
        ORDER BY
            -- 최종 추천 점수 (장르 점수 합 + 특징 점수 합) 내림차순 정렬
            (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST,
            -- 점수 동일 시 제목 오름차순 정렬
            cbi.title ASC;

    v_profile_nickname profile.nickname%TYPE; -- 프로필 닉네임 저장 변수

BEGIN
    -- 1. 프로필 닉네임 조회
    BEGIN
        SELECT nickname INTO v_profile_nickname
        FROM profile
        WHERE profileID = p_profile_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_profile_nickname := '알 수 없음';
    END;

    -- 2. 결과 출력 시작
    DBMS_OUTPUT.PUT_LINE('--- 프로필 [' || v_profile_nickname || '] (ID: ' || p_profile_id || ') 맞춤 콘텐츠 추천 목록 ---');
    DBMS_OUTPUT.PUT_LINE('-- (선호도 점수 합산 방식) --'); -- 로직 명시
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');

    -- 3. 커서를 열고 루프를 돌며 결과 출력
    FOR rec IN recommendation_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('  제목: ' || rec.title || ', 썸네일: ' || rec.thumbnailURL);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 예외 처리
        DBMS_OUTPUT.PUT_LINE('오류 발생: 프로필 ID ' || p_profile_id || ' 추천 생성 중 문제 발생 - ' || SQLERRM);
END;
/

-- SQL*Plus, SQL Developer 등에서 실행

-- 1. 서버 출력 활성화
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- 2. 점수 합산 방식 추천 프로시저 호출 블록 실행
BEGIN
    -- sp_recommend_score_by_sum 프로시저 호출
    -- p_profile_id 매개변수에 &profile_id 치환 변수로 입력받은 값을 전달
    sp_recommend_score_by_sum(p_profile_id => &profile_id);
END;
/

-- 3. (선택 사항) 사용한 치환 변수 정의 해제
UNDEFINE profile_id



-- 시청 날짜 DEFAULT SYSDATE
ALTER TABLE viewingHistory
MODIFY lastViewat DEFAULT SYSDATE;
-- 결제 날짜 DEFAULT SYSDATE
ALTER TABLE payment
MODIFY paydate DEFAULT SYSDATE;
-- 접속 날짜 DEFAULT SYSDATE
ALTER TABLE device
MODIFY connectionTime DEFAULT SYSDATE;
-- 평가 날짜 DEFAULT SYSDATE
ALTER TABLE userRating
MODIFY ratingTime DEFAULT SYSDATE;