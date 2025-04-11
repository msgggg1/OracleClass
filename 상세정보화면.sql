-- 특정 콘텐츠(&content_title)의 상세 정보를 특정 프로필(&profile_id) 기준으로 DBMS 출력 (수정 4: NVL 오류 수정)
DECLARE
    -- 입력 변수
    v_content_title   content.title%TYPE     := '&content_title';
    v_profile_id      profile.profileID%TYPE := &profile_id;

    -- 조회 결과 저장 변수
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;

    -- 시청 중 정보 저장 변수
    v_is_watching             BOOLEAN := FALSE;
    v_watching_video_id       video.videoID%TYPE;
    v_watching_season_num     video.seasonNum%TYPE;
    v_watching_epi_num        video.epiNum%TYPE;
    v_watching_epi_title      video.epiTitle%TYPE;
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_epi_desc       video.epiDescription%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;

    -- 기타 필요한 변수
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;

BEGIN
    -- 1. 프로필 ID로 닉네임 조회
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;

    -- 2. 콘텐츠 제목으로 기본 정보 조회
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN;
              WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;

    -- 3. 시리즈 여부 및 총 시즌 수 확인
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL;
        IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE;
        ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF;
    END;

    -- 4. 현재 시청 중인 정보 확인 (ROWNUM 사용)
    BEGIN
        SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle
        INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title
        FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle
               FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID
               WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N'
               ORDER BY vh.lastViewat DESC )
        WHERE ROWNUM = 1;
        v_is_watching := TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE;
    END;

    -- 5. 시리즈물인데 시청 중이 아닐 경우, 첫 회차 정보 조회 (ROWNUM 사용)
    IF v_is_series AND NOT v_is_watching THEN
        BEGIN
            SELECT epiruntime INTO v_first_epi_runtime
            FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id
                   ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST )
            WHERE ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL;
        END;
    END IF;

    -- 6. 찜 목록 확인
    DECLARE v_wish_count NUMBER; BEGIN SELECT COUNT(*) INTO v_wish_count FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = v_content_id; IF v_wish_count > 0 THEN v_is_wishlisted := TRUE; ELSE v_is_wishlisted := FALSE; END IF; END; -- ELSE 추가
    -- 7. 평가 여부 확인
    DECLARE v_rating_count NUMBER; BEGIN SELECT COUNT(*) INTO v_rating_count FROM userRating ur WHERE ur.profileID = v_profile_id AND ur.contentID = v_content_id; IF v_rating_count > 0 THEN v_is_rated := TRUE; ELSE v_is_rated := FALSE; END IF; END; -- ELSE 추가
    -- 8. 자막 유무 확인
    DECLARE v_subtitle_count NUMBER; BEGIN SELECT COUNT(*) INTO v_subtitle_count FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_subtitle_count > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END; -- ELSE 추가
    -- 9. 시청 등급 가져오기 (하나만)
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;
    -- 10. 출연진, 장르, 특징 목록 가져오기 (LISTAGG 사용)
    BEGIN SELECT LISTAGG(a.name, ', ') WITHIN GROUP (ORDER BY al.actorListid) INTO v_cast FROM actor a JOIN actorList al ON a.actorid = al.actorid WHERE al.contentID = v_content_id;
          SELECT LISTAGG(g.genreName, ', ') WITHIN GROUP (ORDER BY g.genreName) INTO v_genres FROM genre g JOIN genreList gl ON g.genreID = gl.genreID WHERE gl.contentID = v_content_id;
          SELECT LISTAGG(f.featureName, ', ') WITHIN GROUP (ORDER BY f.featureName) INTO v_features FROM feature f JOIN featureList fl ON f.featureID = fl.featureID WHERE fl.contentID = v_content_id;
    END;

    -- 11. 출력할 정보들 조합
    IF v_is_series THEN IF v_is_watching THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF; -- TO_CHAR 추가
    IF v_is_series AND v_is_watching AND v_watching_epi_desc IS NOT NULL THEN v_display_desc := v_watching_epi_desc; ELSE v_display_desc := v_content_rec.description; END IF;

    -- 12. 최종 정보 출력
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || NVL(TO_CHAR(v_watching_epi_runtime),'?') || '분 중 ' || NVL(TO_CHAR(ROUND(v_watching_progress_sec / 60)),'?') || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF; -- TO_CHAR, NVL 추가
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear);
    IF v_is_series THEN
        -- *** 수정된 부분: NVL 사용 시 TO_CHAR 추가 ***
        DBMS_OUTPUT.PUT_LINE('총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개');
    END IF;
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('시청 등급: ' || NVL(v_ratingLabel, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('출연진: ' || NVL(SUBSTR(v_cast, 1, 500), '정보 없음') || CASE WHEN LENGTH(v_cast) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('장르: ' || NVL(v_genres, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('특징: ' || NVL(v_features, '정보 없음'));
    IF v_is_series AND v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 중 회차: 시즌 ' || v_watching_season_num || ' 에피소드 ' || v_watching_epi_num || ' (' || NVL(v_watching_epi_title, '제목 없음') || ')'); END IF; -- NVL 추가
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF v_content_id IS NULL THEN
             DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠를 찾을 수 없습니다.');
        ELSE -- 콘텐츠는 찾았으나 다른 조회(시청기록 등)에서 NO_DATA_FOUND 발생 시 (ROWNUM=1 필터링 때문일 수 있음)
             DBMS_OUTPUT.PUT_LINE('정보 조회 중 일부 데이터(시청기록 등)를 찾을 수 없습니다. (콘텐츠 ID: ' || v_content_id || ')');
             -- 여기서도 기본 정보는 출력 가능했으므로, 부분 성공으로 간주할 수 있음. 위에서 출력은 이미 됨.
             -- 또는 실패로 간주하고 아래처럼 처리
             -- DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
        END IF;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/





-- 특정 콘텐츠(&content_title)의 상세 정보 및 관련 목록을 특정 프로필(&profile_id) 기준으로 DBMS 출력 (수정 5: 커서 내 ROWNUM)
DECLARE
    -- 입력 변수
    v_content_title   content.title%TYPE     := '&content_title';
    v_profile_id      profile.profileID%TYPE := &profile_id;

    -- 기본 정보 저장 변수
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;

    -- 출력용 변수들
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;

    -- 시청 기록 임시 저장 (에피소드 목록 출력 시 사용)
    TYPE t_watch_hist_map IS TABLE OF viewingHistory.totalViewingTime%TYPE INDEX BY PLS_INTEGER; -- INDEX BY 수정
    v_watch_history   t_watch_hist_map;

    -- 루프용 변수
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_temp_num        NUMBER;
    v_found           BOOLEAN := FALSE;

    -- 시청 중 정보 저장 변수 (이전과 동일 - ROWNUM 수정됨)
    v_is_watching             BOOLEAN := FALSE;
    v_watching_video_id       video.videoID%TYPE;
    v_watching_season_num     video.seasonNum%TYPE;
    v_watching_epi_num        video.epiNum%TYPE;
    v_watching_epi_title      video.epiTitle%TYPE;
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_epi_desc       video.epiDescription%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;

    -- 기타 필요한 변수 (이전과 동일 - ROWNUM 수정됨)
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;

BEGIN
    -- ==========================================================
    -- 1. 기본 정보 조회 (프로필, 콘텐츠)
    -- ==========================================================
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN;
              WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL;
        IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE; ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF;
    END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_temp_num > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END;
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;

    -- ==========================================================
    -- 섹션 1: 회차 정보 (시리즈물인 경우)
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 (시즌 ' || v_total_seasons || ') ---');
        -- 시청 기록 조회 (ROWNUM 수정됨)
        BEGIN
            SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle
            INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title
            FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle
                   FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID
                   WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N'
                   ORDER BY vh.lastViewat DESC )
            WHERE ROWNUM = 1;
            v_is_watching := TRUE;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE;
        END;
        -- 첫 회차 정보 조회 (ROWNUM 수정됨)
        IF NOT v_is_watching THEN
             BEGIN
                 SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1;
             EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL;
             END;
        END IF;
        -- 에피소드 루프
        v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP
            v_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음'));
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END);
            IF v_is_watching AND v_watching_video_id = epi_rec.videoID THEN -- 현재 시청중인 에피소드면 진행도 표시
                DBMS_OUTPUT.PUT_LINE('    시청 위치: ' || ROUND(v_watching_progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분');
            END IF;
        END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;

    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (프로필 선호도 기반 추천 - 현재 콘텐츠 제외)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (추천) ---');
    DECLARE
        -- *** 수정된 커서 정의: FETCH FIRST 대신 ROWNUM 사용 ***
        CURSOR related_content_cursor IS
             SELECT * FROM ( -- <<< 서브쿼리 시작
                 WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID
                ), ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID
                )
                SELECT
                    c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                    (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                    (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season
                    , (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count
                FROM content c
                LEFT JOIN ContentGenreScores cgs ON c.contentID = cgs.contentID
                LEFT JOIN ContentFeatureScores cfs ON c.contentID = cfs.contentID
                WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                ORDER BY (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) DESC NULLS LAST, c.title ASC
            ) -- <<< 서브쿼리 종료
            WHERE ROWNUM <= 10; -- <<< ROWNUM으로 상위 10개 제한

        -- 내부 루프용 변수들 (이름 충돌 피하기 위해 접두사 rel_ 사용)
        v_rel_content_id  content.contentID%TYPE;
        v_rel_title       content.title%TYPE;
        v_rel_thumb       content.thumbnailURL%TYPE;
        v_rel_year        content.releaseYear%TYPE;
        v_rel_quality     content.videoQuality%TYPE;
        v_rel_desc        content.description%TYPE;
        v_rel_runtime     content.runtime%TYPE;
        v_rel_rating      contentRating.ratingLabel%TYPE;
        v_rel_max_season  NUMBER;
        v_rel_wish_count  NUMBER;
        v_rel_found       BOOLEAN := FALSE;
        v_episode_count   NUMBER; -- 에피소드 수 저장용
    BEGIN
        OPEN related_content_cursor;
        LOOP
            FETCH related_content_cursor INTO v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime, v_rel_rating, v_rel_max_season, v_rel_wish_count;
            EXIT WHEN related_content_cursor%NOTFOUND;

            v_rel_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN
                 BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END;
                 DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE
                 DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분');
            END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부: ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END);
        END LOOP;
        CLOSE related_content_cursor;

        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (함께 시청된 콘텐츠 추천 정보가 없습니다.)'); END IF;
    END; -- 내부 DECLARE 블록 종료
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 3: 예고편 및 다른 영상
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 예고편 및 다른 영상 ---');
    v_found := FALSE; -- 플래그 초기화
    FOR trailer_rec IN (SELECT t.title, t.trailerURL FROM trailer t JOIN video v ON t.videoID = v.videoID WHERE v.contentID = v_content_id ORDER BY t.title) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('  제목: ' || trailer_rec.title || ', URL: ' || trailer_rec.trailerURL);
    END LOOP;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (예고편 정보가 없습니다.)'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
        -- 필요시 열려있는 커서 닫는 로직 추가 (현재는 related_content_cursor만 명시적)
END;
/


-- 특정 콘텐츠 상세 정보 + 관련 콘텐츠 추천순 출력 (수정 7: 입력순서 변경, 점수 확인 추가)
DECLARE
    -- 입력 순서 변경: 프로필 ID 먼저, 그 다음 콘텐츠 제목
    v_profile_id      profile.profileID%TYPE := &profile_id;     -- <<< 1. 프로필 ID 입력
    v_content_title   content.title%TYPE     := '&content_title'; -- <<< 2. 콘텐츠 제목 입력

    -- 기본 정보 저장 변수
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;

    -- 출력용 변수들
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;

    -- 시청 기록 임시 저장 (에피소드 목록 출력 시 사용)
    TYPE t_watch_hist_map IS TABLE OF viewingHistory.totalViewingTime%TYPE INDEX BY PLS_INTEGER;
    v_watch_history   t_watch_hist_map;

    -- 루프용 변수
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_temp_num        NUMBER;
    v_found           BOOLEAN := FALSE;

    -- 시청 중 정보 저장 변수
    v_is_watching             BOOLEAN := FALSE;
    v_watching_video_id       video.videoID%TYPE;
    v_watching_season_num     video.seasonNum%TYPE;
    v_watching_epi_num        video.epiNum%TYPE;
    v_watching_epi_title      video.epiTitle%TYPE;
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_epi_desc       video.epiDescription%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;

    -- 기타 필요한 변수
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;

BEGIN
    -- ==========================================================
    -- 1. 기본 정보 조회 (프로필, 콘텐츠) - 순서 유지
    -- ==========================================================
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN;
              WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL; IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE; ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_temp_num > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END;
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;

    -- ==========================================================
    -- 섹션 1: 회차 정보 (시리즈물인 경우) - 변경 없음
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 (시즌 ' || v_total_seasons || ') ---');
        BEGIN SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N' ORDER BY vh.lastViewat DESC ) WHERE ROWNUM = 1; v_is_watching := TRUE; EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE; END;
        IF NOT v_is_watching THEN BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END; END IF;
        -- 시청 기록 미리 조회 (맵 사용 안 함, 에피소드 루프 내에서 직접 확인)
        v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP
            v_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음'));
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END);
            IF v_is_watching AND v_watching_video_id = epi_rec.videoID THEN
                DBMS_OUTPUT.PUT_LINE('    시청 위치: ' || ROUND(v_watching_progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분');
            END IF;
        END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;

    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (추천순 정렬 확인 위해 점수 출력 추가)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (추천) ---');
    DECLARE
        -- 커서 수정: 추천 점수(recommendation_score)를 SELECT 목록에 포함
        CURSOR related_content_cursor IS
             SELECT * FROM ( -- 서브쿼리 시작
                 WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID
                ), ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID
                )
                SELECT
                    c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                    (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                    (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season
                    , (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count
                    , (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) as recommendation_score -- <<< 점수 계산 포함
                FROM content c
                LEFT JOIN ContentGenreScores cgs ON c.contentID = cgs.contentID
                LEFT JOIN ContentFeatureScores cfs ON c.contentID = cfs.contentID
                WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                ORDER BY recommendation_score DESC NULLS LAST, c.title ASC -- <<< 점수 기준으로 정렬
            ) -- 서브쿼리 종료
            WHERE ROWNUM <= 10; -- 상위 10개

        -- 변수 추가: 추천 점수
        v_rel_recommend_score NUMBER;
        -- 나머지 변수들...
        v_rel_content_id  content.contentID%TYPE; v_rel_title content.title%TYPE; v_rel_thumb content.thumbnailURL%TYPE; v_rel_year content.releaseYear%TYPE; v_rel_quality content.videoQuality%TYPE; v_rel_desc content.description%TYPE; v_rel_runtime content.runtime%TYPE; v_rel_rating contentRating.ratingLabel%TYPE; v_rel_max_season NUMBER; v_rel_wish_count NUMBER; v_rel_found BOOLEAN := FALSE; v_episode_count NUMBER;
    BEGIN
        OPEN related_content_cursor;
        LOOP
            -- FETCH 목록에 점수 추가
            FETCH related_content_cursor INTO
                v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime,
                v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_recommend_score;
            EXIT WHEN related_content_cursor%NOTFOUND;

            v_rel_found := TRUE;
            -- 출력 수정: 점수 포함
            DBMS_OUTPUT.PUT_LINE('  --- [점수:' || v_rel_recommend_score || '] ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN
                 BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END;
                 DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE
                 DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분');
            END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부: ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END);
        END LOOP;
        CLOSE related_content_cursor;
        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (함께 시청된 콘텐츠 추천 정보가 없습니다.)'); END IF;
    END; -- 내부 DECLARE 블록 종료
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 3: 예고편 및 다른 영상 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 예고편 및 다른 영상 ---');
    v_found := FALSE; -- 플래그 초기화
    FOR trailer_rec IN (SELECT t.title, t.trailerURL FROM trailer t JOIN video v ON t.videoID = v.videoID WHERE v.contentID = v_content_id ORDER BY t.title) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('  제목: ' || trailer_rec.title || ', URL: ' || trailer_rec.trailerURL);
    END LOOP;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (예고편 정보가 없습니다.)'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- 기본 정보 다시 출력 (이전 코드에서 빠진 부분 보강)
    DBMS_OUTPUT.PUT_LINE('--- 기본 정보 다시 확인 ---');
    IF v_is_series THEN IF v_is_watching THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;
    IF v_is_series AND v_is_watching AND v_watching_epi_desc IS NOT NULL THEN v_display_desc := v_watching_epi_desc; ELSE v_display_desc := v_content_rec.description; END IF;
    BEGIN SELECT LISTAGG(a.name, ', ') WITHIN GROUP (ORDER BY al.actorListid) INTO v_cast FROM actor a JOIN actorList al ON a.actorid = al.actorid WHERE al.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(g.genreName, ', ') WITHIN GROUP (ORDER BY g.genreName) INTO v_genres FROM genre g JOIN genreList gl ON g.genreID = gl.genreID WHERE gl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(f.featureName, ', ') WITHIN GROUP (ORDER BY f.featureName) INTO v_features FROM feature f JOIN featureList fl ON f.featureID = fl.featureID WHERE fl.contentID = v_content_id; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_wishlisted := TRUE; ELSE v_is_wishlisted := FALSE; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM userRating ur WHERE ur.profileID = v_profile_id AND ur.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_rated := TRUE; ELSE v_is_rated := FALSE; END IF; END;

    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || NVL(TO_CHAR(v_watching_epi_runtime),'?') || '분 중 ' || NVL(TO_CHAR(ROUND(v_watching_progress_sec / 60)),'?') || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear);
    IF v_is_series THEN DBMS_OUTPUT.PUT_LINE('총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개'); END IF;
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('시청 등급: ' || NVL(v_ratingLabel, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('출연진: ' || NVL(SUBSTR(v_cast, 1, 500), '정보 없음') || CASE WHEN LENGTH(v_cast) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('장르: ' || NVL(v_genres, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('특징: ' || NVL(v_features, '정보 없음'));
    IF v_is_series AND v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 중 회차: 시즌 ' || v_watching_season_num || ' 에피소드 ' || v_watching_epi_num || ' (' || NVL(v_watching_epi_title, '제목 없음') || ')'); END IF;
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');


EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/

-- [통합 버전] 특정 콘텐츠(&content_title) 상세 정보 + 관련 목록을 특정 프로필(&profile_id) 기준으로 DBMS 출력

DECLARE
    -- 입력 변수 (프로필 ID 먼저)
    v_profile_id      profile.profileID%TYPE := &profile_id;
    v_content_title   content.title%TYPE     := '&content_title';

    -- 기본 정보 저장 변수
    v_content_id      content.contentID%TYPE;
    v_profile_nickname profile.nickname%TYPE;
    v_content_rec     content%ROWTYPE;
    v_is_series       BOOLEAN := FALSE;
    v_total_seasons   NUMBER;

    -- 추가 정보 저장 변수
    v_ratingLabel     contentRating.ratingLabel%TYPE;
    v_cast            VARCHAR2(4000);
    v_genres          VARCHAR2(1000);
    v_features        VARCHAR2(1000);
    v_creators        VARCHAR2(2000); -- 크리에이터 목록 변수 추가
    v_has_subtitles   BOOLEAN := FALSE;
    v_is_wishlisted   BOOLEAN := FALSE;
    v_is_rated        BOOLEAN := FALSE;

    -- 시청 기록 임시 저장 (에피소드 목록 출력 시 사용)
    TYPE t_watch_hist_map IS TABLE OF viewingHistory.totalViewingTime%TYPE INDEX BY PLS_INTEGER;
    v_watch_history   t_watch_hist_map;

    -- 루프용 변수
    v_title           content.title%TYPE;
    v_thumbnailURL    content.thumbnailURL%TYPE;
    v_temp_num        NUMBER;
    v_found           BOOLEAN := FALSE;

    -- 시청 중 정보 저장 변수
    v_is_watching             BOOLEAN := FALSE;
    v_watching_video_id       video.videoID%TYPE;
    v_watching_season_num     video.seasonNum%TYPE;
    v_watching_epi_num        video.epiNum%TYPE;
    v_watching_epi_title      video.epiTitle%TYPE;
    v_watching_epi_runtime    video.epiruntime%TYPE;
    v_watching_epi_desc       video.epiDescription%TYPE;
    v_watching_progress_sec   viewingHistory.totalViewingTime%TYPE;

    -- 기타 필요한 변수
    v_display_runtime   VARCHAR2(50);
    v_display_desc      VARCHAR2(3000);
    v_first_epi_runtime video.epiruntime%TYPE;

BEGIN
    -- ==========================================================
    -- 1. 기본 정보 조회 (프로필, 콘텐츠)
    -- ==========================================================
    BEGIN SELECT nickname INTO v_profile_nickname FROM profile WHERE profileID = v_profile_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 ID ' || v_profile_id || '를 찾을 수 없습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 프로필 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT * INTO v_content_rec FROM content WHERE title = v_content_title; v_content_id := v_content_rec.contentID;
    EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 제목 ''' || v_content_title || ''' 를 찾을 수 없습니다.'); RETURN;
              WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('오류: 제목 ''' || v_content_title || ''' 에 해당하는 콘텐츠가 여러 개 있습니다.'); RETURN;
              WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류: 콘텐츠 정보 조회 중 문제 발생 - ' || SQLERRM); RETURN;
    END;
    BEGIN SELECT MAX(v.seasonNum) INTO v_total_seasons FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL;
        IF v_total_seasons IS NOT NULL AND v_total_seasons >= 1 THEN v_is_series := TRUE; ELSE v_is_series := FALSE; v_total_seasons := NULL; END IF;
    END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM subtitle s JOIN video v ON s.videoID = v.videoID WHERE v.contentID = v_content_id; IF v_temp_num > 0 THEN v_has_subtitles := TRUE; ELSE v_has_subtitles := FALSE; END IF; END;
    BEGIN SELECT MAX(cr.ratingLabel) INTO v_ratingLabel FROM contentRating cr WHERE cr.contentID = v_content_id; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_wishlisted := TRUE; ELSE v_is_wishlisted := FALSE; END IF; END;
    BEGIN SELECT COUNT(*) INTO v_temp_num FROM userRating ur WHERE ur.profileID = v_profile_id AND ur.contentID = v_content_id; IF v_temp_num > 0 THEN v_is_rated := TRUE; ELSE v_is_rated := FALSE; END IF; END;

    -- 시청 중 정보 확인 (ROWNUM 사용)
    BEGIN
        SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle
        INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title
        FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle
               FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID
               WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N'
               ORDER BY vh.lastViewat DESC )
        WHERE ROWNUM = 1;
        v_is_watching := TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE;
    END;

    -- 첫 회차 정보 조회 (시리즈물이고 시청 중 아닐 때)
    IF v_is_series AND NOT v_is_watching THEN
        BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END;
    END IF;

    -- 출력용 러닝타임/설명 결정
    IF v_is_series THEN IF v_is_watching THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;
    IF v_is_series AND v_is_watching AND v_watching_epi_desc IS NOT NULL THEN v_display_desc := v_watching_epi_desc; ELSE v_display_desc := v_content_rec.description; END IF;

    -- LISTAGG 정보 조회
    BEGIN SELECT LISTAGG(a.name, ', ') WITHIN GROUP (ORDER BY al.actorListid) INTO v_cast FROM actor a JOIN actorList al ON a.actorid = al.actorid WHERE al.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(g.genreName, ', ') WITHIN GROUP (ORDER BY g.genreName) INTO v_genres FROM genre g JOIN genreList gl ON g.genreID = gl.genreID WHERE gl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(f.featureName, ', ') WITHIN GROUP (ORDER BY f.featureName) INTO v_features FROM feature f JOIN featureList fl ON f.featureID = fl.featureID WHERE fl.contentID = v_content_id; END;
    BEGIN SELECT LISTAGG(cr.creatorName, ', ') WITHIN GROUP (ORDER BY cr.creatorName) INTO v_creators FROM creator cr JOIN creatorList cl ON cr.creatorID = cl.creatorID WHERE cl.contentID = v_content_id; END; -- 크리에이터 정보 조회

    -- ==========================================================
    -- 1차 정보 출력 (화면 상단 부분)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear || ' / 시청 등급: ' || NVL(v_ratingLabel, '정보 없음') || CASE WHEN v_is_series THEN ' / 총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || NVL(TO_CHAR(v_watching_epi_runtime),'?') || '분 중 ' || NVL(TO_CHAR(ROUND(v_watching_progress_sec / 60)),'?') || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END || ' / 내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END || ' / 자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');


    -- ==========================================================
    -- 섹션 1: 회차 정보 (시리즈물인 경우)
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 ---');
        v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP
            v_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음'));
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END);
            IF v_is_watching AND v_watching_video_id = epi_rec.videoID THEN
                DBMS_OUTPUT.PUT_LINE('    ** 현재 시청 중 (진행: ' || ROUND(v_watching_progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분) **');
            END IF;
        END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;

    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (추천순, 점수 확인 추가됨)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (추천) ---');
    DECLARE
        CURSOR related_content_cursor IS SELECT * FROM (...) WHERE ROWNUM <= 10; -- 내부 로직은 이전과 동일 (점수 포함)
        -- ... (내부 변수 선언 및 루프는 이전 답변과 동일하게 유지, 점수 포함하여 출력) ...
         CURSOR related_content_cursor IS
             SELECT * FROM ( -- 서브쿼리 시작
                 WITH ProfileGenrePrefs AS (SELECT genreID, cnt FROM genreViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ProfileFeaturePrefs AS (SELECT featureID, cnt FROM featureViewCnt WHERE profileID = v_profile_id AND cnt > 0
                ), ContentGenreScores AS (SELECT gl.contentID, SUM(NVL(pgp.cnt, 0)) as total_genre_score FROM genreList gl LEFT JOIN ProfileGenrePrefs pgp ON gl.genreID = pgp.genreID GROUP BY gl.contentID
                ), ContentFeatureScores AS (SELECT fl.contentID, SUM(NVL(pfp.cnt, 0)) as total_feature_score FROM featureList fl LEFT JOIN ProfileFeaturePrefs pfp ON fl.featureID = pfp.featureID GROUP BY fl.contentID
                )
                SELECT
                    c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                    (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                    (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season
                    , (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count
                    , (NVL(cgs.total_genre_score, 0) + NVL(cfs.total_feature_score, 0)) as recommendation_score -- <<< 점수 계산 포함
                FROM content c
                LEFT JOIN ContentGenreScores cgs ON c.contentID = cgs.contentID
                LEFT JOIN ContentFeatureScores cfs ON c.contentID = cfs.contentID
                WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                ORDER BY recommendation_score DESC NULLS LAST, c.title ASC -- <<< 점수 기준으로 정렬
            ) -- 서브쿼리 종료
            WHERE ROWNUM <= 10; -- 상위 10개

        v_rel_recommend_score NUMBER;
        v_rel_content_id  content.contentID%TYPE; v_rel_title content.title%TYPE; v_rel_thumb content.thumbnailURL%TYPE; v_rel_year content.releaseYear%TYPE; v_rel_quality content.videoQuality%TYPE; v_rel_desc content.description%TYPE; v_rel_runtime content.runtime%TYPE; v_rel_rating contentRating.ratingLabel%TYPE; v_rel_max_season NUMBER; v_rel_wish_count NUMBER; v_rel_found BOOLEAN := FALSE; v_episode_count NUMBER;
    BEGIN
        OPEN related_content_cursor; LOOP
            FETCH related_content_cursor INTO v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime, v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_recommend_score;
            EXIT WHEN related_content_cursor%NOTFOUND; v_rel_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('  --- [점수:' || v_rel_recommend_score || '] ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END; DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분'); END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부 ('||v_profile_nickname||'님): ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END); -- 찜 여부 프로필 명시
        END LOOP; CLOSE related_content_cursor;
        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (함께 시청된 콘텐츠 추천 정보가 없습니다.)'); END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');


    -- ==========================================================
    -- 섹션 3: 예고편 및 다른 영상 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 예고편 및 다른 영상 ---');
    v_found := FALSE;
    FOR trailer_rec IN (SELECT t.title, t.trailerURL FROM trailer t JOIN video v ON t.videoID = v.videoID WHERE v.contentID = v_content_id ORDER BY t.title) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE('  제목: ' || trailer_rec.title || ', URL: ' || trailer_rec.trailerURL);
    END LOOP;
    IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (예고편 정보가 없습니다.)'); END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');

    -- ==========================================================
    -- 섹션 4: 주요 정보 요약 (요청된 필드만)
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

-- 특정 콘텐츠 상세 정보 + 관련 콘텐츠 추천순 출력 (수정 8: 추천 로직 재적용)

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
    BEGIN SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N' ORDER BY vh.lastViewat DESC ) WHERE ROWNUM = 1; v_is_watching := TRUE; EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE; END;
    IF v_is_series AND NOT v_is_watching THEN BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END; END IF;
    IF v_is_series THEN IF v_is_watching THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;
    IF v_is_series AND v_is_watching AND v_watching_epi_desc IS NOT NULL THEN v_display_desc := v_watching_epi_desc; ELSE v_display_desc := v_content_rec.description; END IF;


    -- ==========================================================
    -- 1차 정보 출력 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear || ' / 시청 등급: ' || NVL(v_ratingLabel, '정보 없음') || CASE WHEN v_is_series THEN ' / 총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || NVL(TO_CHAR(v_watching_epi_runtime),'?') || '분 중 ' || NVL(TO_CHAR(ROUND(v_watching_progress_sec / 60)),'?') || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END || ' / 내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END || ' / 자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

    -- ==========================================================
    -- 섹션 1: 회차 정보 - 변경 없음
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 ---');
        v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP v_found := TRUE; DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---'); DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음')); DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END); IF v_is_watching AND v_watching_video_id = epi_rec.videoID THEN DBMS_OUTPUT.PUT_LINE('    ** 현재 시청 중 (진행: ' || ROUND(v_watching_progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분) **'); END IF; END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;

  -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (*** 추천 점수 출력 추가 ***)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (추천) ---');
    DECLARE 
        -- 커서 정의: 추천 점수(recommendation_score)를 SELECT 목록에 포함 (이전과 동일)
        CURSOR related_content_cursor IS
             SELECT * FROM ( -- 서브쿼리 시작 (ROWNUM 필터링용)
                SELECT
                    c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                    (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                    (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season,
                    (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count,
                    -- 추천 점수 계산 (스칼라 서브쿼리 사용)
                    (SELECT SUM(NVL(gv.cnt, 0)) FROM genreViewCnt gv JOIN genreList gl ON gv.genreID = gl.genreID WHERE gv.profileID = v_profile_id AND gl.contentID = c.contentID AND gv.cnt > 0) +
                    (SELECT SUM(NVL(fv.cnt, 0)) FROM featureViewCnt fv JOIN featureList fl ON fv.featureID = fl.featureID WHERE fv.profileID = v_profile_id AND fl.contentID = c.contentID AND fv.cnt > 0)
                    as recommendation_score
                FROM content c
                WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                ORDER BY recommendation_score DESC NULLS LAST, c.title ASC -- 점수 기준으로 정렬
            ) -- 서브쿼리 종료
            WHERE ROWNUM <= 10; -- 상위 10개

        -- 내부 루프용 변수들
        v_rel_recommend_score NUMBER; -- 점수 저장 변수
        v_rel_content_id  content.contentID%TYPE;
        v_rel_title       content.title%TYPE;
        v_rel_thumb       content.thumbnailURL%TYPE;
        v_rel_year        content.releaseYear%TYPE;
        v_rel_quality     content.videoQuality%TYPE;
        v_rel_desc        content.description%TYPE;
        v_rel_runtime     content.runtime%TYPE;
        v_rel_rating      contentRating.ratingLabel%TYPE;
        v_rel_max_season  NUMBER;
        v_rel_wish_count  NUMBER;
        v_rel_found       BOOLEAN := FALSE;
        v_episode_count   NUMBER;
    BEGIN
        OPEN related_content_cursor;
        LOOP
            -- FETCH 목록에 추천 점수 포함
            FETCH related_content_cursor INTO
                v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime,
                v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_recommend_score;
            EXIT WHEN related_content_cursor%NOTFOUND;

            v_rel_found := TRUE;
            -- *** 출력 수정: 제목 앞에 [점수:XX] 형태로 점수 표시 ***
            DBMS_OUTPUT.PUT_LINE('  --- [점수:' || NVL(v_rel_recommend_score, 0) || '] ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN
                 BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END;
                 DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE
                 DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분');
            END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부 ('||v_profile_nickname||'님): ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END);
        END LOOP;
        CLOSE related_content_cursor;
        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (함께 시청된 콘텐츠 추천 정보가 없습니다.)'); END IF;
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

-- 특정 콘텐츠 상세 정보 + 관련 콘텐츠 (콘텐츠 유사성 기반 추천) + DBMS 출력
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
    BEGIN SELECT videoID, totalViewingTime, epiruntime, epiDescription, seasonNum, epiNum, epiTitle INTO v_watching_video_id, v_watching_progress_sec, v_watching_epi_runtime, v_watching_epi_desc, v_watching_season_num, v_watching_epi_num, v_watching_epi_title FROM ( SELECT vh.videoID, vh.totalViewingTime, v.epiruntime, v.epiDescription, v.seasonNum, v.epiNum, v.epiTitle FROM viewingHistory vh JOIN video v ON vh.videoID = v.videoID WHERE vh.profileID = v_profile_id AND v.contentID = v_content_id AND vh.isCompleted = 'N' ORDER BY vh.lastViewat DESC ) WHERE ROWNUM = 1; v_is_watching := TRUE; EXCEPTION WHEN NO_DATA_FOUND THEN v_is_watching := FALSE; END;
    IF v_is_series AND NOT v_is_watching THEN BEGIN SELECT epiruntime INTO v_first_epi_runtime FROM ( SELECT v.epiruntime FROM video v WHERE v.contentID = v_content_id ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST ) WHERE ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_first_epi_runtime := NULL; END; END IF;
    IF v_is_series THEN IF v_is_watching THEN v_display_runtime := NVL(TO_CHAR(v_watching_epi_runtime), '정보 없음') || '분'; ELSE v_display_runtime := NVL(TO_CHAR(v_first_epi_runtime), TO_CHAR(v_content_rec.runtime)) || '분 (첫 회)'; END IF; ELSE v_display_runtime := v_content_rec.runtime || '분'; END IF;
    IF v_is_series AND v_is_watching AND v_watching_epi_desc IS NOT NULL THEN v_display_desc := v_watching_epi_desc; ELSE v_display_desc := v_content_rec.description; END IF;


    -- ==========================================================
    -- 1차 정보 출력 - 변경 없음
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 콘텐츠 상세 정보 (' || v_profile_nickname || ' 님 기준) ---');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('콘텐츠 썸네일: ' || NVL(v_content_rec.thumbnailURL, '없음'));
    DBMS_OUTPUT.PUT_LINE('제목: ' || v_content_rec.title);
    DBMS_OUTPUT.PUT_LINE('개봉년도: ' || v_content_rec.releaseYear || ' / 시청 등급: ' || NVL(v_ratingLabel, '정보 없음') || CASE WHEN v_is_series THEN ' / 총 시즌: ' || NVL(TO_CHAR(v_total_seasons), '정보 없음') || '개' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('러닝타임: ' || v_display_runtime);
    IF v_is_watching THEN DBMS_OUTPUT.PUT_LINE('시청 위치: 총 ' || NVL(TO_CHAR(v_watching_epi_runtime),'?') || '분 중 ' || NVL(TO_CHAR(ROUND(v_watching_progress_sec / 60)),'?') || '분 시청'); ELSE DBMS_OUTPUT.PUT_LINE('시청 위치: 시청 중 아님'); END IF;
    DBMS_OUTPUT.PUT_LINE('찜 여부: ' || CASE WHEN v_is_wishlisted THEN 'Y' ELSE 'N' END || ' / 내 평가: ' || CASE WHEN v_is_rated THEN '평가함' ELSE '평가 안함' END || ' / 자막 유무: ' || CASE WHEN v_has_subtitles THEN 'Y' ELSE 'N' END);
    DBMS_OUTPUT.PUT_LINE('화질 정보: ' || NVL(v_content_rec.videoQuality, '정보 없음'));
    DBMS_OUTPUT.PUT_LINE('설명: ' || SUBSTR(NVL(v_display_desc, '없음'), 1, 500) || CASE WHEN LENGTH(v_display_desc) > 500 THEN '...' ELSE '' END);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');

    -- ==========================================================
    -- 섹션 1: 회차 정보 - 변경 없음
    -- ==========================================================
    IF v_is_series THEN
        DBMS_OUTPUT.PUT_LINE('--- 회차 정보 ---');
        v_found := FALSE;
        FOR epi_rec IN (SELECT v.videoID, v.seasonNum, v.epiNum, v.epiTitle, v.epiImageURL, v.epiDescription, v.epiruntime FROM video v WHERE v.contentID = v_content_id AND v.seasonNum IS NOT NULL ORDER BY v.seasonNum ASC NULLS LAST, v.epiNum ASC NULLS LAST) LOOP v_found := TRUE; DBMS_OUTPUT.PUT_LINE('  --- S' || epi_rec.seasonNum || ' E' || epi_rec.epiNum || ': ' || epi_rec.epiTitle || ' (' || epi_rec.epiruntime || '분) ---'); DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(epi_rec.epiImageURL, '없음')); DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(epi_rec.epiDescription, '없음'), 1, 100) || CASE WHEN LENGTH(epi_rec.epiDescription) > 100 THEN '...' ELSE '' END); IF v_is_watching AND v_watching_video_id = epi_rec.videoID THEN DBMS_OUTPUT.PUT_LINE('    ** 현재 시청 중 (진행: ' || ROUND(v_watching_progress_sec / 60) || '분 / ' || epi_rec.epiruntime || '분) **'); END IF; END LOOP;
        IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('  (회차 정보가 없습니다.)'); END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END IF;

    -- ==========================================================
    -- 섹션 2: 함께 시청된 콘텐츠 (*** 콘텐츠 유사성 기반 추천 로직으로 변경 ***)
    -- ==========================================================
    DBMS_OUTPUT.PUT_LINE('--- 함께 시청된 콘텐츠 (유사 콘텐츠) ---'); -- 헤더 변경
    DECLARE
        -- *** 수정된 커서 정의: 콘텐츠 유사성 점수 계산 ***
        CURSOR related_content_cursor IS
            SELECT * FROM ( -- 서브쿼리 시작 (ROWNUM 필터링용)
                SELECT
                    c.contentID, c.title, c.thumbnailURL, c.releaseYear, c.videoQuality, c.description, c.runtime,
                    (SELECT MAX(cr.ratingLabel) FROM contentRating cr WHERE cr.contentID = c.contentID) as rating_label,
                    (SELECT MAX(v.seasonNum) FROM video v WHERE v.contentID = c.contentID AND v.seasonNum IS NOT NULL) as max_season,
                    -- 찜 여부는 여전히 현재 프로필 기준
                    (SELECT COUNT(*) FROM wishList wl JOIN video v ON wl.videoID = v.videoID WHERE wl.profileID = v_profile_id AND v.contentID = c.contentID) as wish_count,
                    -- 유사도 점수 계산 (공유 장르 수 + 공유 특징 수)
                    ( -- 공유 장르 수 계산
                      SELECT COUNT(*)
                      FROM genreList gl
                      WHERE gl.contentID = c.contentID -- 다른 콘텐츠(c)의 장르 중
                        AND gl.genreID IN (SELECT genreID FROM genreList WHERE contentID = v_content_id) -- 현재 콘텐츠(v_content_id)의 장르에 포함되는 것
                    ) +
                    ( -- 공유 특징 수 계산
                      SELECT COUNT(*)
                      FROM featureList fl
                      WHERE fl.contentID = c.contentID -- 다른 콘텐츠(c)의 특징 중
                        AND fl.featureID IN (SELECT featureID FROM featureList WHERE contentID = v_content_id) -- 현재 콘텐츠(v_content_id)의 특징에 포함되는 것
                    ) as similarity_score
                FROM content c
                WHERE c.contentID != v_content_id -- 현재 콘텐츠 제외
                ORDER BY similarity_score DESC NULLS LAST, c.title ASC -- <<< 유사도 점수 기준으로 정렬
            ) -- 서브쿼리 종료
            WHERE ROWNUM <= 10; -- 상위 10개

        -- 내부 루프용 변수들 (v_rel_recommend_score -> v_rel_similarity_score 변경)
        v_rel_similarity_score NUMBER;
        v_rel_content_id  content.contentID%TYPE; v_rel_title content.title%TYPE; v_rel_thumb content.thumbnailURL%TYPE; v_rel_year content.releaseYear%TYPE; v_rel_quality content.videoQuality%TYPE; v_rel_desc content.description%TYPE; v_rel_runtime content.runtime%TYPE; v_rel_rating contentRating.ratingLabel%TYPE; v_rel_max_season NUMBER; v_rel_wish_count NUMBER; v_rel_found BOOLEAN := FALSE; v_episode_count NUMBER;
    BEGIN
        OPEN related_content_cursor;
        LOOP
            -- FETCH 목록 및 변수명 변경 (recommend -> similarity)
            FETCH related_content_cursor INTO
                v_rel_content_id, v_rel_title, v_rel_thumb, v_rel_year, v_rel_quality, v_rel_desc, v_rel_runtime,
                v_rel_rating, v_rel_max_season, v_rel_wish_count, v_rel_similarity_score;
            EXIT WHEN related_content_cursor%NOTFOUND;

            v_rel_found := TRUE;
            -- 출력 수정: 유사도 점수 표시
            DBMS_OUTPUT.PUT_LINE('  --- [유사도:' || NVL(v_rel_similarity_score, 0) || '] ' || v_rel_title || ' ---');
            DBMS_OUTPUT.PUT_LINE('    썸네일URL: ' || NVL(v_rel_thumb, '없음'));
            IF v_rel_max_season IS NOT NULL THEN BEGIN SELECT COUNT(*) INTO v_episode_count FROM video v WHERE v.contentID = v_rel_content_id AND v.seasonNum IS NOT NULL; EXCEPTION WHEN OTHERS THEN v_episode_count := 0; END; DBMS_OUTPUT.PUT_LINE('    정보: 시즌 ' || v_rel_max_season || '개 / 총 ' || v_episode_count || ' 화');
            ELSE DBMS_OUTPUT.PUT_LINE('    정보: 러닝타임 ' || v_rel_runtime || '분'); END IF;
            DBMS_OUTPUT.PUT_LINE('    등급: ' || NVL(v_rel_rating, '정보 없음') || ' / 화질: ' || NVL(v_rel_quality, '정보 없음') || ' / 출시: ' || v_rel_year);
            DBMS_OUTPUT.PUT_LINE('    설명: ' || SUBSTR(NVL(v_rel_desc, '없음'), 1, 100) || CASE WHEN LENGTH(v_rel_desc) > 100 THEN '...' ELSE '' END);
            DBMS_OUTPUT.PUT_LINE('    찜 여부 ('||v_profile_nickname||'님): ' || CASE WHEN v_rel_wish_count > 0 THEN 'Y' ELSE 'N' END);
        END LOOP;
        CLOSE related_content_cursor;
        IF NOT v_rel_found THEN DBMS_OUTPUT.PUT_LINE('  (유사한 콘텐츠 정보가 없습니다.)'); END IF; -- 메시지 변경
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

-- 사용한 & 변수 정의 해제
UNDEFINE profile_id
UNDEFINE content_title