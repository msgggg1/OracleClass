CREATE OR REPLACE VIEW vw_content_basic_info AS
SELECT
    contentID,
    title,
    thumbnailURL
FROM
    content;
/

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

-- [시리즈물] 선택적 장르(&req_genre) 필터링 + 추천순(&profile_id) 정렬 + DBMS 출력
-- 실행 시 장르(또는 Enter), 프로필 ID 순서로 입력 요구

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

DECLARE
    -- 입력 변수 (& 사용)
    v_req_genre_input VARCHAR2(100) := '&req_genre'; -- 장르 입력 (빈 값 허용 -> '전체')
    v_profile_id      profile.profileID%TYPE  := &profile_id; -- 추천 기준 프로필 ID

    -- 실제 필터링/계산에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- 커서: 시리즈물 필터 + 장르 필터 + 추천 점수 계산 및 정렬
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
            cbi.thumbnailURL
            -- , (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score -- 점수 확인용
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
            (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST,
            cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
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
        FETCH recommendation_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN recommendation_cursor%NOTFOUND;
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
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
-- 실행 시 장르(또는 Enter), 프로필 ID 순서로 입력 요구

DECLARE
    -- 입력 변수 (& 사용)
    v_req_genre_input VARCHAR2(100) := '&req_genre';
    v_profile_id      profile.profileID%TYPE  := &profile_id;

    -- 실제 필터링/계산에 사용할 변수
    v_filter_genre genre.genreName%TYPE;

    -- 커서: 영화 필터 + 장르 필터 + 추천 점수 계산 및 정렬
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
            cbi.thumbnailURL
        FROM
            vw_content_basic_info cbi
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
            (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST,
            cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_found         BOOLEAN := FALSE;
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
        FETCH recommendation_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN recommendation_cursor%NOTFOUND;
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE recommendation_cursor;

    -- 결과 없을 시 메시지
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION WHEN OTHERS THEN IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF; DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/



-- 배우에 맞춰서
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


네, 알겠습니다. 이전의 배우 검색 로직을 크리에이터(감독, 작가 등) 에 맞춰 수정해 드리겠습니다.

**크리에이터 이름(&creator_name)**을 입력받아, 해당 크리에이터가 참여한 모든 콘텐츠의 목록(제목, 썸네일 URL)을 DBMS 출력 창에 표시하는 PL/SQL 코드입니다. 첨부해주신 이미지의 테이블(크리에이터, 콘텐츠 크리에이터 매핑) 구조를 사용합니다.

SQL

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



-- 특정 프로필(&profile_id)의 시청 중인 콘텐츠 목록 출력 (커서 수정됨)

DECLARE
    v_profile_id      profile.profileID%TYPE  := &profile_id; -- & 변수로 프로필 ID 입력
    v_profile_nickname profile.nickname%TYPE;
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_found           BOOLEAN := FALSE;

    -- 커서: 특정 프로필의 시청 중인(isCompleted='N') 고유 콘텐츠 조회
    CURSOR watching_content_cursor (p_profile_id IN profile.profileID%TYPE) IS
        SELECT DISTINCT c.title, c.thumbnailURL
        FROM viewingHistory vh -- <<< 시작 테이블 지정
        JOIN video v ON vh.videoID = v.videoID      -- <<< video 테이블 조인
        JOIN content c ON v.contentID = c.contentID     -- <<< content 테이블 조인
        WHERE vh.profileID = p_profile_id -- 입력받은 프로필 ID로 필터링
          AND vh.isCompleted = 'N'      -- 완료 안된 것만
        ORDER BY c.title ASC;

BEGIN
    -- 1. 입력된 프로필 ID로 닉네임 조회
    BEGIN
        SELECT nickname INTO v_profile_nickname
        FROM profile
        WHERE profileID = v_profile_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.');
            RETURN; -- 프로필 없으면 종료
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM);
            RETURN;
    END;

    -- 2. 헤더 출력
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE(v_profile_nickname || ' 님이 시청중인 콘텐츠');
    DBMS_OUTPUT.PUT_LINE('---'); -- 간단한 구분선

    -- 3. 커서 열고 결과 출력
    OPEN watching_content_cursor(p_profile_id => v_profile_id);
    LOOP
        FETCH watching_content_cursor INTO v_title, v_thumbnailURL;
        EXIT WHEN watching_content_cursor%NOTFOUND;
        v_found := TRUE; -- 결과 찾음 표시
        DBMS_OUTPUT.PUT_LINE('  제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
    END LOOP;
    CLOSE watching_content_cursor;

    -- 4. 시청 중인 콘텐츠가 없는 경우 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('  (시청 중인 콘텐츠가 없습니다.)');
    END IF;

    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN -- 그 외 예외 처리
        IF watching_content_cursor%ISOPEN THEN CLOSE watching_content_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
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


