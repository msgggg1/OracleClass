-- [통합 + & 입력] ... (수정 15: 개별 정적 커서 및 루프 사용)
-- DECLARE: 이제부터 PL/SQL 코드 블록에서 사용할 변수들을 선언(정의)할 거야~ 라는 의미입니다.
DECLARE
    -- === 입력 변수 선언 및 값 받기 ===
    -- &profile_id 같은 &변수(치환 변수)는 코드가 실행될 때 사용자에게 값을 물어봅니다.
    -- := 는 오른쪽에 있는 값을 왼쪽 변수에 할당(저장)하라는 의미입니다.
    -- %TYPE은 직접 VARCHAR2(30) 같이 타입을 쓰는 대신, 다른 테이블 컬럼의 타입을 그대로 가져와서 쓰겠다는 의미입니다. (실수로 타입 틀리는 것 방지)
    -- UPPER() 함수는 입력된 영어 값을 모두 대문자로 바꿔서 나중에 비교하기 편하게 합니다.
    v_profile_id      profile.profileID%TYPE := &profile_id;     -- 1. 프로필 ID 입력받아 v_profile_id 변수에 저장
    v_sub_req         CHAR(1)                := UPPER('&req_sub'); -- 2. 자막 여부(Y/N) 입력받아 v_sub_req 변수에 저장 (대문자로)
    v_language        content.originlang%TYPE := '&req_lang';    -- 3. 언어 입력받아 v_language 변수에 저장
    v_sort_option     VARCHAR2(20)           := UPPER('&req_sort'); -- 4. 정렬 기준 입력받아 v_sort_option 변수에 저장 (대문자로)

    -- === 커서(CURSOR) 선언 ===
    -- 커서는 특정 SQL 쿼리의 결과(여러 행일 수 있음)를 가리키는 포인터(책갈피 같은 것)라고 생각하면 쉽습니다.
    -- 각 정렬 방식별로 다른 SQL 쿼리를 실행해야 하므로, 각 경우에 맞는 커서를 미리 4개 정의합니다.
    -- 이 커서들은 '정적(Static)' 커서입니다. 왜냐하면 안에 있는 SQL 쿼리 내용이 실행 중 바뀌지 않고 고정되어 있기 때문입니다.
    -- 커서 내부의 SQL을 보면...
    -- SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi ... : 우리가 만든 뷰에서 제목과 썸네일을 가져옵니다.
    -- WHERE EXISTS (...) : 이 조건을 만족하는 콘텐츠만 가져옵니다.
    --      SELECT 1 FROM video v JOIN audioLang al ... : 비디오와 오디오 언어 테이블을 연결해서
    --      WHERE v.contentID = cbi.contentID : 현재 뷰에서 보고 있는 콘텐츠(cbi)와 같은 비디오(v) 중에서
    --        AND al.Language = v_language : 언어가 입력받은 언어(v_language)와 같고,
    --        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (... subtitle ...))) : 자막 불필요('N')이거나, 또는 자막 필요('Y')이면서 실제로 subtitle 테이블에 자막이 존재하는 경우
    --      ... 이런 조건을 만족하는 비디오가 하나라도 EXISTS(존재하면) TRUE가 되어 해당 콘텐츠(cbi)를 선택합니다.
    -- ORDER BY ... : 각 커서마다 이 부분만 다릅니다. 결과를 정렬하는 기준입니다.

    CURSOR title_asc_cursor IS -- 제목 오름차순용 커서
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 
                        FROM video v JOIN content c ON v.contentID = c.contentID
                        WHERE c.originLang = v_language
                                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) 
                        ORDER BY cbi.title ASC;

    CURSOR title_desc_cursor IS -- 제목 내림차순용 커서
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi
        WHERE EXISTS (SELECT 1 FROM video v JOIN content c 
                                            WHERE v.contentID = c.contentID
                                                        AND c.originLang = v_language
                                                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) 
                                            ORDER BY cbi.title DESC;

    CURSOR release_date_cursor IS -- 출시일 최신순용 커서
        SELECT cbi.title, cbi.thumbnailURL FROM vw_content_basic_info cbi JOIN content c ON cbi.contentID = c.contentID -- 출시일 컬럼 위해 content 테이블 조인
        WHERE EXISTS (SELECT 1 FROM video v JOIN content c WHERE v.contentID = c.contentID
                                                        AND c.originLang = v_language
                                                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) 
                                                        ORDER BY c.releaseDate DESC, cbi.title ASC;

    CURSOR recommendation_cursor IS -- 추천순용 커서
        -- WITH 절 (CTE): 복잡한 쿼리를 단계별로 나누어 작성하는 방법입니다. 임시 테이블처럼 이름을 붙여 사용합니다.
        WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0), -- 프로필의 장르별 시청횟수
             ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0), -- 프로필의 특징별 시청횟수
             ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID), -- 콘텐츠별 총 장르 점수 계산
             ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID) -- 콘텐츠별 총 특징 점수 계산
        -- 메인 SELECT: 뷰와 계산된 점수 테이블을 조인하고, 점수를 합산하여 최종 점수(final_score) 계산
        SELECT cbi.title, cbi.thumbnailURL, (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score
        FROM vw_content_basic_info cbi
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        -- WHERE 절은 다른 커서들과 동일 (언어/자막 필터링)
        WHERE EXISTS (SELECT 1 FROM video v JOIN content c WHERE v.contentID = c.contentID
                                                        AND c.originLang = v_language
                                                        AND (v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM subtitle s WHERE s.videoID = v.videoID)))) 
        ORDER BY final_score DESC NULLS LAST, cbi.title ASC; -- 최종 점수(final_score)로 정렬, NULLS LAST는 점수가 없는(NULL) 항목을 맨 뒤로 보냄

    -- === 루프 및 출력용 변수 선언 ===
    v_title         vw_content_basic_info.title%TYPE; -- 커서에서 읽어온 제목 저장
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE; -- 커서에서 읽어온 썸네일 URL 저장
    v_score         NUMBER; -- 추천순 정렬 시 커서에서 읽어온 점수 저장
    v_found         BOOLEAN := FALSE; -- 결과가 한 건이라도 있었는지 표시하는 깃발(Flag) 변수, 처음엔 FALSE(없음)
    v_profile_nickname profile.nickname%TYPE; -- 조회된 프로필 닉네임 저장

-- BEGIN: 이제부터 실제 코드 실행 시작!
BEGIN
    -- === 입력값 유효성 검사 ===
    -- 사용자가 입력한 자막여부(v_sub_req)가 'Y' 또는 'N'이 아니면 오류 메시지 출력 후 종료(RETURN)
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    -- 사용자가 입력한 정렬기준(v_sort_option)이 4가지 중 하나가 아니면 오류 메시지 출력 후 종료
    IF v_sort_option NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN DBMS_OUTPUT.PUT_LINE('오류: 유효하지 않은 정렬 기준입니다.'); RETURN; END IF;

    -- === 프로필 닉네임 조회 ===
    -- 입력받은 v_profile_id로 profile 테이블에서 nickname을 찾아 v_profile_nickname 변수에 저장
    BEGIN -- 별도 블록으로 묶어 예외처리
        SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; -- 프로필 없으면 기본값 설정
    END; -- 별도 블록 종료

    -- === 검색 조건 및 헤더 출력 ===
    -- DBMS_OUTPUT.PUT_LINE: 괄호 안의 내용을 DBMS 출력 창에 보여주는 명령어
    -- || : 문자열들을 서로 연결하는 연산자
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('오디오 언어: ' || v_language);
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option);
    IF v_sort_option = 'RECOMMEND' THEN DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname || ' (ID: ' || v_profile_id || ')'); END IF; -- 추천순일 때만 프로필 정보 추가 출력
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- === 정렬 기준에 따른 커서 처리 ===
    -- 사용자가 입력한 v_sort_option 값에 따라 해당하는 IF 또는 ELSIF 블록 안의 코드만 실행됨
    IF v_sort_option = 'TITLE_ASC' THEN
        OPEN title_asc_cursor; -- 제목 오름차순 커서 열기
        LOOP -- 루프 시작
            FETCH title_asc_cursor INTO v_title, v_thumbnailURL; -- 커서에서 한 행 데이터 가져와 변수에 저장
            EXIT WHEN title_asc_cursor%NOTFOUND; -- 더 이상 가져올 데이터 없으면 루프 나가기 (%NOTFOUND는 '데이터 없음' 상태인지 확인)
            v_found := TRUE; -- 데이터가 한 건이라도 있었음을 표시 (깃발 올리기)
            DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); -- 결과 출력
        END LOOP; -- 루프 끝
        CLOSE title_asc_cursor; -- 커서 닫기 (자원 해제)

    ELSIF v_sort_option = 'TITLE_DESC' THEN
        -- 위와 동일한 구조로 title_desc_cursor 사용
        OPEN title_desc_cursor; LOOP FETCH title_desc_cursor INTO v_title, v_thumbnailURL; EXIT WHEN title_desc_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE title_desc_cursor;

    ELSIF v_sort_option = 'RELEASE_DATE' THEN
        -- 위와 동일한 구조로 release_date_cursor 사용
        OPEN release_date_cursor; LOOP FETCH release_date_cursor INTO v_title, v_thumbnailURL; EXIT WHEN release_date_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL);
        END LOOP; CLOSE release_date_cursor;

    ELSIF v_sort_option = 'RECOMMEND' THEN
        -- 위와 동일한 구조로 recommendation_cursor 사용 (점수(v_score)까지 FETCH하고 출력)
        OPEN recommendation_cursor; LOOP FETCH recommendation_cursor INTO v_title, v_thumbnailURL, v_score; EXIT WHEN recommendation_cursor%NOTFOUND;
            v_found := TRUE; DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); -- NVL(v_score, 0)은 점수가 NULL일 경우 0으로 표시
        END LOOP; CLOSE recommendation_cursor;

    END IF; -- IF/ELSIF 구문 종료

    -- === 결과 없음 메시지 처리 ===
    -- 위 루프들이 한 번도 실행되지 않았다면(v_found가 여전히 FALSE라면) 결과 없다는 메시지 출력
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); -- 최종 구분선

-- EXCEPTION: 코드 실행 중 오류가 발생했을 때 처리하는 부분
EXCEPTION
    WHEN OTHERS THEN -- 어떤 종류의 오류든 다 잡음 (NO_DATA_FOUND 등 특정 오류만 잡을 수도 있음)
        -- 오류 발생 시, 혹시라도 커서가 열려있을 수 있으니 안전하게 닫아줌
        IF title_asc_cursor%ISOPEN THEN CLOSE title_asc_cursor; END IF; -- %ISOPEN은 커서가 열려있는 상태인지 확인
        IF title_desc_cursor%ISOPEN THEN CLOSE title_desc_cursor; END IF;
        IF release_date_cursor%ISOPEN THEN CLOSE release_date_cursor; END IF;
        IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM); -- SQLERRM은 오라클 내부 오류 메시지 변수
END; -- 전체 PL/SQL 블록 종료
/ -- PL/SQL 블록 실행 명령어 (SQL*Plus, SQL Developer 등에서)


-- [통합 + & 입력] ... (수정 16: originLang 필터링 및 ORA-00905 오류 수정)

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

DECLARE
    -- 입력 변수 (프로필 ID 먼저)
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_sub_req         CHAR(1)                := UPPER('&req_sub');
    v_language        content.originLang%TYPE := '&req_lang'; -- 타입을 content.originLang으로 변경
    v_sort_option     VARCHAR2(20)           := UPPER('&req_sort');

    -- === 각 정렬 방식별 정적 커서 선언 (WHERE 절 수정됨) ===
    CURSOR title_asc_cursor IS
        SELECT cbi.title, cbi.thumbnailURL
        FROM vw_content_basic_info cbi
        JOIN content c ON cbi.contentID = c.contentID -- originLang 접근 위해 조인
        WHERE c.originLang = v_language -- 1. 원어 필터
          AND ( -- 2. 자막 필터
                v_sub_req = 'N'
                OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM video v JOIN subtitle s ON v.videoID = s.videoID WHERE v.contentID = cbi.contentID))
              )
        ORDER BY cbi.title ASC;

    CURSOR title_desc_cursor IS
        SELECT cbi.title, cbi.thumbnailURL
        FROM vw_content_basic_info cbi
        JOIN content c ON cbi.contentID = c.contentID
        WHERE c.originLang = v_language
          AND ( v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM video v JOIN subtitle s ON v.videoID = s.videoID WHERE v.contentID = cbi.contentID)))
        ORDER BY cbi.title DESC;

    CURSOR release_date_cursor IS
        SELECT cbi.title, cbi.thumbnailURL
        FROM vw_content_basic_info cbi
        JOIN content c ON cbi.contentID = c.contentID -- releaseDate, originLang 접근 위해 조인
        WHERE c.originLang = v_language
          AND ( v_sub_req = 'N' OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM video v JOIN subtitle s ON v.videoID = s.videoID WHERE v.contentID = cbi.contentID)))
        ORDER BY c.releaseDate DESC, cbi.title ASC;

    CURSOR recommendation_cursor IS
        WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0),
             ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0),
             ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID),
             ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID)
        SELECT cbi.title, cbi.thumbnailURL, (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) AS final_score
        FROM vw_content_basic_info cbi
        JOIN content c ON cbi.contentID = c.contentID -- originLang 접근 위해 조인
        LEFT JOIN ContentGenreScores cgs ON cbi.contentID = cgs.contentID
        LEFT JOIN ContentFeatureScores cfs ON cbi.contentID = cfs.contentID
        WHERE c.originLang = v_language -- 1. 원어 필터
          AND ( -- 2. 자막 필터
                v_sub_req = 'N'
                OR (v_sub_req = 'Y' AND EXISTS (SELECT 1 FROM video v JOIN subtitle s ON v.videoID = s.videoID WHERE v.contentID = cbi.contentID))
              )
        ORDER BY final_score DESC NULLS LAST, cbi.title ASC;

    -- 루프 및 출력용 변수
    v_title         vw_content_basic_info.title%TYPE;
    v_thumbnailURL  vw_content_basic_info.thumbnailURL%TYPE;
    v_score         NUMBER;
    v_found         BOOLEAN := FALSE;
    v_profile_nickname profile.nickname%TYPE;

BEGIN
    -- 입력값 유효성 검사
    IF v_sub_req NOT IN ('Y', 'N') THEN DBMS_OUTPUT.PUT_LINE('오류: 자막 필요 여부는 Y 또는 N 으로만 입력해야 합니다.'); RETURN; END IF;
    IF v_sort_option NOT IN ('TITLE_ASC', 'TITLE_DESC', 'RELEASE_DATE', 'RECOMMEND') THEN DBMS_OUTPUT.PUT_LINE('오류: 유효하지 않은 정렬 기준입니다.'); RETURN; END IF;
    -- 언어 입력값 자체는 여기서 검증하기 어려움 (테이블에 존재하는지 등)

    -- 프로필 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id; EXCEPTION WHEN NO_DATA_FOUND THEN v_profile_nickname := '알 수 없음 (ID:' || v_profile_id || ')'; END;

    -- 검색 조건 출력
    DBMS_OUTPUT.PUT_LINE('--- 검색 조건 ---');
    DBMS_OUTPUT.PUT_LINE('자막 필수: ' || v_sub_req); DBMS_OUTPUT.PUT_LINE('콘텐츠 원어: ' || v_language); -- '오디오 언어' -> '콘텐츠 원어'
    DBMS_OUTPUT.PUT_LINE('정렬 기준: ' || v_sort_option);
    IF v_sort_option = 'RECOMMEND' THEN DBMS_OUTPUT.PUT_LINE('추천 기준 프로필: ' || v_profile_nickname || ' (ID: ' || v_profile_id || ')'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------'); DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 목록 ---');

    -- 정렬 기준에 따라 해당 커서 사용 및 루프 실행 (이전과 동일)
    IF v_sort_option = 'TITLE_ASC' THEN
        OPEN title_asc_cursor; LOOP FETCH title_asc_cursor INTO v_title, v_thumbnailURL; EXIT WHEN title_asc_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END LOOP; CLOSE title_asc_cursor;
    ELSIF v_sort_option = 'TITLE_DESC' THEN
        OPEN title_desc_cursor; LOOP FETCH title_desc_cursor INTO v_title, v_thumbnailURL; EXIT WHEN title_desc_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END LOOP; CLOSE title_desc_cursor;
    ELSIF v_sort_option = 'RELEASE_DATE' THEN
        OPEN release_date_cursor; LOOP FETCH release_date_cursor INTO v_title, v_thumbnailURL; EXIT WHEN release_date_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END LOOP; CLOSE release_date_cursor;
    ELSIF v_sort_option = 'RECOMMEND' THEN
        OPEN recommendation_cursor; LOOP FETCH recommendation_cursor INTO v_title, v_thumbnailURL, v_score; EXIT WHEN recommendation_cursor%NOTFOUND; v_found := TRUE; DBMS_OUTPUT.PUT_LINE('[점수: ' || NVL(v_score, 0) || '] 제목: ' || v_title || ', 썸네일URL: ' || v_thumbnailURL); END LOOP; CLOSE recommendation_cursor;
    END IF;

    -- 결과 없는 경우 메시지 출력
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('해당 조건에 맞는 콘텐츠가 없습니다.'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        IF title_asc_cursor%ISOPEN THEN CLOSE title_asc_cursor; END IF; IF title_desc_cursor%ISOPEN THEN CLOSE title_desc_cursor; END IF; IF release_date_cursor%ISOPEN THEN CLOSE release_date_cursor; END IF; IF recommendation_cursor%ISOPEN THEN CLOSE recommendation_cursor; END IF;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- 사용한 변수 정의 해제 (정렬 기준 변수 이름 확인)
UNDEFINE profile_id
UNDEFINE req_sub
UNDEFINE req_lang
UNDEFINE req_sort
