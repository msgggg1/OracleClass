-- 1. Base Data Tables

-- account (계정) - 늘리기 (NULL 값 오류 수정)
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('alice@example.com', '010-1234-5678', 'Alice2024!', 'F', '123456', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('bob@example.com', '010-2345-6789', 'Bob#Secure1', 'M', '654321', 'N');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('charlie@netflix.com', '010-3456-7890', 'C#h@rlie99', 'M', '112233', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('david@domain.net', '010-4567-8901', 'DavidP@ssw0rd', 'M', '000000', 'Y'); -- NULL -> '000000' 수정
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('eve@mail.org', '010-5678-9012', 'EveSecret#7', 'F', '987654', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('frank@service.co.kr', '010-6789-0123', 'Fr@nkPass123', 'M', '000000', 'N'); -- NULL -> '000000' 수정
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('grace@internet.com', '010-7890-1234', 'Gr@ceful!', 'F', '000000', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('heidi@provider.net', '010-8901-2345', 'HeidiSecure#', 'F', '000000', 'Y'); -- NULL -> '000000' 수정
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('ivan@post.com', '010-9012-3456', 'Iv@nIsC00l', 'M', '102938', 'N');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('judy@mail.kr', '010-0123-4567', 'Judy#Pass567', 'F', '555111', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('kevin@sample.org', '010-1122-3344', 'Kev1n$Strong', 'M', '000000', 'Y'); -- NULL -> '000000' 수정

-- subtitleSetting (자막 설정) - 늘리기
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Arial', 100, 'Drop Shadow'); -- S1
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Times New Roman', 75, NULL); -- S2
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('돋움', 125, 'Outline'); -- S3
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('굴림', 100, NULL); -- S4
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Verdana', 90, 'Raised'); -- S5
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('맑은 고딕', 110, 'Drop Shadow'); -- S6
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('바탕', 100, 'Uniform'); -- S7
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Consolas', 85, NULL); -- S8
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('궁서', 130, 'Outline'); -- S9
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Helvetica', 100, 'Drop Shadow'); -- S10

-- audioTrack (오디오 트랙) - 늘리기
INSERT INTO audioTrack (audioDescription) VALUES ('Stereo'); -- A1
INSERT INTO audioTrack (audioDescription) VALUES ('5.1 Surround'); -- A2
INSERT INTO audioTrack (audioDescription) VALUES ('Dolby Atmos'); -- A3
INSERT INTO audioTrack (audioDescription) VALUES ('Audio Description'); -- A4 (음성 해설)
INSERT INTO audioTrack (audioDescription) VALUES ('Mono'); -- A5
INSERT INTO audioTrack (audioDescription) VALUES ('DTS-HD Master Audio 7.1'); -- A6
INSERT INTO audioTrack (audioDescription) VALUES ('Dolby Digital Plus'); -- A7
INSERT INTO audioTrack (audioDescription) VALUES ('Stereo - Commentary'); -- A8 (코멘터리)
INSERT INTO audioTrack (audioDescription) VALUES ('5.1 Surround - Commentary'); -- A9 (코멘터리)
INSERT INTO audioTrack (audioDescription) VALUES ('Auro-3D 11.1'); -- A10

-- genre (장르) - 늘리기
INSERT INTO genre (genreName) VALUES ('액션'); -- G1
INSERT INTO genre (genreName) VALUES ('코미디'); -- G2
INSERT INTO genre (genreName) VALUES ('드라마'); -- G3
INSERT INTO genre (genreName) VALUES ('SF'); -- G4
INSERT INTO genre (genreName) VALUES ('스릴러'); -- G5
INSERT INTO genre (genreName) VALUES ('로맨스'); -- G6
INSERT INTO genre (genreName) VALUES ('다큐멘터리'); -- G7
INSERT INTO genre (genreName) VALUES ('애니메이션'); -- G8
INSERT INTO genre (genreName) VALUES ('호러'); -- G9
INSERT INTO genre (genreName) VALUES ('판타지'); -- G10
INSERT INTO genre (genreName) VALUES ('음악'); -- G11
INSERT INTO genre (genreName) VALUES ('가족'); -- G12

-- actor (배우) - 늘리기
INSERT INTO actor (name, birthDate) VALUES ('Tom Hanks', TO_DATE('1956-07-09', 'YYYY-MM-DD')); -- A1
INSERT INTO actor (name, birthDate) VALUES ('Scarlett Johansson', TO_DATE('1984-11-22', 'YYYY-MM-DD')); -- A2
INSERT INTO actor (name, birthDate) VALUES ('송강호', TO_DATE('1967-01-17', 'YYYY-MM-DD')); -- A3
INSERT INTO actor (name, birthDate) VALUES ('김고은', TO_DATE('1991-07-02', 'YYYY-MM-DD')); -- A4
INSERT INTO actor (name, birthDate) VALUES ('Leonardo DiCaprio', TO_DATE('1974-11-11', 'YYYY-MM-DD')); -- A5
INSERT INTO actor (name, birthDate) VALUES ('Elliot Page', TO_DATE('1987-02-21', 'YYYY-MM-DD')); -- A6
INSERT INTO actor (name, birthDate) VALUES ('Millie Bobby Brown', TO_DATE('2004-02-19', 'YYYY-MM-DD')); -- A7
INSERT INTO actor (name, birthDate) VALUES ('최민식', TO_DATE('1962-04-27', 'YYYY-MM-DD')); -- A8
INSERT INTO actor (name, birthDate) VALUES ('전지현', TO_DATE('1981-10-30', 'YYYY-MM-DD')); -- A9
INSERT INTO actor (name, birthDate) VALUES ('Robert Downey Jr.', TO_DATE('1965-04-04', 'YYYY-MM-DD')); -- A10
INSERT INTO actor (name, birthDate) VALUES ('마동석', TO_DATE('1971-03-01', 'YYYY-MM-DD')); -- A11
INSERT INTO actor (name, birthDate) VALUES ('Zendaya', TO_DATE('1996-09-01', 'YYYY-MM-DD')); -- A12
INSERT INTO actor (name, birthDate) VALUES ('Timothée Chalamet', TO_DATE('1995-12-27', 'YYYY-MM-DD')); -- A13

-- feature (특징) - 늘리기
INSERT INTO feature (featureName) VALUES ('시각적으로 놀라운'); -- F1
INSERT INTO feature (featureName) VALUES ('비평가들의 찬사'); -- F2
INSERT INTO feature (featureName) VALUES ('기발한'); -- F3
INSERT INTO feature (featureName) VALUES ('현실 왜곡/복잡한'); -- F4
INSERT INTO feature (featureName) VALUES ('감동적인'); -- F5
INSERT INTO feature (featureName) VALUES ('긴장감 넘치는'); -- F6
INSERT INTO feature (featureName) VALUES ('생각할 거리를 던지는'); -- F7
INSERT INTO feature (featureName) VALUES ('가슴 따뜻한'); -- F8
INSERT INTO feature (featureName) VALUES ('다크'); -- F9
INSERT INTO feature (featureName) VALUES ('어워드 수상'); -- F10
INSERT INTO feature (featureName) VALUES ('컬트 클래식'); -- F11

-- Country (국가) - 늘리기
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Korean', 19); -- Co1 (한국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('English (US)', 18); -- Co2 (미국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Japanese', 18); -- Co3 (일본)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('English (UK)', 18); -- Co4 (영국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('French', 18); -- Co5 (프랑스)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('German', 18); -- Co6 (독일)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Spanish (Spain)', 18); -- Co7 (스페인)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Hindi', 18); -- Co8 (인도)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Chinese (Mandarin)', 18); -- Co9 (중국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Portuguese (Brazil)', 18); -- Co10 (브라질)

-- creator (제작자) - 늘리기
INSERT INTO creator (creatorName) VALUES ('봉준호'); -- Cr1
INSERT INTO creator (creatorName) VALUES ('크리스토퍼 놀란'); -- Cr2
INSERT INTO creator (creatorName) VALUES ('그레타 거윅'); -- Cr3
INSERT INTO creator (creatorName) VALUES ('스티븐 스필버그'); -- Cr4
INSERT INTO creator (creatorName) VALUES ('더퍼 형제'); -- Cr5
INSERT INTO creator (creatorName) VALUES ('쿠엔틴 타란티노'); -- Cr6
INSERT INTO creator (creatorName) VALUES ('박찬욱'); -- Cr7
INSERT INTO creator (creatorName) VALUES ('제임스 카메론'); -- Cr8
INSERT INTO creator (creatorName) VALUES ('미야자키 하야오'); -- Cr9
INSERT INTO creator (creatorName) VALUES ('타이카 와이티티'); -- Cr10
INSERT INTO creator (creatorName) VALUES ('드니 빌뇌브'); -- Cr11

-- membership (멤버십, audioTrack 테이블에 의존) - 기존 유지 또는 약간 수정 가능 (여기서는 기존 유지)
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (5500, '720p', 1, 1, 1); -- M1 (광고형 베이식, 스테레오(A1))
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (9500, '1080p', 2, 0, 2); -- M2 (스탠다드, 5.1 서라운드(A2))
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (13500, '4K+HDR', 4, 0, 3); -- M3 (프리미엄, 돌비 애트모스(A3))

-- audioLang (음성 언어, audioTrack 테이블에 의존) - 늘리기
INSERT INTO audioLang (Language, audioTrackID) VALUES ('한국어', 1); -- AL1 (한국어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 2); -- AL2 (영어 5.1 서라운드 - A2)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('일본어', 1); -- AL3 (일본어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('한국어', 4); -- AL4 (한국어 음성 해설 - A4)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 3); -- AL5 (영어 돌비 애트모스 - A3)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('스페인어', 1); -- AL6 (스페인어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('프랑스어', 2); -- AL7 (프랑스어 5.1 서라운드 - A2)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('독일어', 1); -- AL8 (독일어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 4); -- AL9 (영어 음성 해설 - A4)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('한국어', 3); -- AL10 (한국어 돌비 애트모스 - A3)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('일본어', 4); -- AL11 (일본어 음성 해설 - A4)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 8); -- AL12 (영어 코멘터리 스테레오 - A8)

-- 2. 콘텐츠 및 관련 연결 테이블

-- content (콘텐츠) - 늘리기
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '기생충', 'Parasite', '가난한 가족이 부유한 가족의 집에 고용되기 위해 계획을 세우는 이야기.', TO_DATE('2019-05-30', 'YYYY-MM-DD'), 2019, TO_DATE('2019-06-05', 'YYYY-MM-DD'), 132, 'thumb/parasite.jpg', 'main/parasite.jpg', 'Korean', '대한민국', SYSDATE, '전세계', '4K'); -- C1
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Series', '기묘한 이야기', 'Stranger Things', '어린 친구들이 초자연적인 힘과 비밀스러운 정부 실험을 목격하는 이야기.', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2016, TO_DATE('2016-07-15', 'YYYY-MM-DD'), 50, 'thumb/stranger.jpg', 'main/stranger.jpg', 'English', '미국', SYSDATE, '전세계', '4K+HDR'); -- C2
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '인셉션', 'Inception', '꿈 공유 기술을 사용하여 기업 비밀을 훔치는 도둑의 이야기.', TO_DATE('2010-07-16', 'YYYY-MM-DD'), 2010, TO_DATE('2010-07-21', 'YYYY-MM-DD'), 148, 'thumb/inception.jpg', 'main/inception.jpg', 'English', '미국', SYSDATE, '전세계', '1080p'); -- C3
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '올드보이', 'Oldboy', '15년간 감금된 남자가 복수를 계획하는 이야기.', TO_DATE('2003-11-21', 'YYYY-MM-DD'), 2003, TO_DATE('2003-11-21', 'YYYY-MM-DD'), 120, 'thumb/oldboy.jpg', 'main/oldboy.jpg', 'Korean', '대한민국', SYSDATE, '전세계', '1080p'); -- C4
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Series', '더 글로리', 'The Glory', '학교 폭력 피해자가 가해자들에게 복수하는 이야기.', TO_DATE('2022-12-30', 'YYYY-MM-DD'), 2022, TO_DATE('2022-12-30', 'YYYY-MM-DD'), 55, 'thumb/theglory.jpg', 'main/theglory.jpg', 'Korean', '대한민국', SYSDATE, '전세계', '4K'); -- C5
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '센과 치히로의 행방불명', 'Spirited Away', '소녀가 신들의 세계에 들어가 부모님을 구하는 모험.', TO_DATE('2001-07-20', 'YYYY-MM-DD'), 2001, TO_DATE('2002-06-28', 'YYYY-MM-DD'), 125, 'thumb/spirited.jpg', 'main/spirited.jpg', 'Japanese', '일본', SYSDATE, '전세계', '1080p'); -- C6
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '어벤져스: 엔드게임', 'Avengers: Endgame', '타노스에 의해 사라진 생명 절반을 되돌리려는 어벤져스의 최종 전투.', TO_DATE('2019-04-26', 'YYYY-MM-DD'), 2019, TO_DATE('2019-04-24', 'YYYY-MM-DD'), 181, 'thumb/endgame.jpg', 'main/endgame.jpg', 'English', '미국', SYSDATE, '전세계', '4K+HDR'); -- C7
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Series', '종이의 집', 'Money Heist', '교수가 이끄는 강도단이 스페인 조폐국과 중앙은행을 터는 이야기.', TO_DATE('2017-05-02', 'YYYY-MM-DD'), 2017, TO_DATE('2017-12-20', 'YYYY-MM-DD'), 45, 'thumb/moneyheist.jpg', 'main/moneyheist.jpg', 'Spanish', '스페인', SYSDATE, '전세계', '4K'); -- C8
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '듄', 'Dune', '우주에서 가장 귀한 자원을 둘러싼 가문들의 전쟁과 한 청년의 운명.', TO_DATE('2021-10-22', 'YYYY-MM-DD'), 2021, TO_DATE('2021-10-20', 'YYYY-MM-DD'), 155, 'thumb/dune.jpg', 'main/dune.jpg', 'English', '미국', SYSDATE, '전세계', '4K+HDR'); -- C9
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Series', '킹덤', 'Kingdom', '죽은 왕이 되살아나자 반역자로 몰린 왕세자가 향한 조선의 끝, 그곳에서 굶주림 끝에 괴물이 되어버린 이들의 비밀을 파헤치며 시작되는 미스터리 스릴러.', TO_DATE('2019-01-25', 'YYYY-MM-DD'), 2019, TO_DATE('2019-01-25', 'YYYY-MM-DD'), 50, 'thumb/kingdom.jpg', 'main/kingdom.jpg', 'Korean', '대한민국', SYSDATE, '전세계', '4K'); -- C10
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '조커', 'Joker', '고담시의 외로운 남자가 광기와 폭력의 상징 조커로 변모하는 과정.', TO_DATE('2019-10-04', 'YYYY-MM-DD'), 2019, TO_DATE('2019-10-02', 'YYYY-MM-DD'), 122, 'thumb/joker.jpg', 'main/joker.jpg', 'English', '미국', SYSDATE, '전세계', '4K'); -- C11

-- genreList (장르 목록, genre와 content 연결) - 늘리기
INSERT INTO genreList (genreID, contentID) VALUES (3, 1); -- 드라마(G3), 기생충(C1)
INSERT INTO genreList (genreID, contentID) VALUES (5, 1); -- 스릴러(G5), 기생충(C1)
INSERT INTO genreList (genreID, contentID) VALUES (4, 2); -- SF(G4), 기묘한 이야기(C2)
INSERT INTO genreList (genreID, contentID) VALUES (5, 2); -- 스릴러(G5), 기묘한 이야기(C2)
INSERT INTO genreList (genreID, contentID) VALUES (10, 2); -- 판타지(G10), 기묘한 이야기(C2)
INSERT INTO genreList (genreID, contentID) VALUES (1, 3); -- 액션(G1), 인셉션(C3)
INSERT INTO genreList (genreID, contentID) VALUES (4, 3); -- SF(G4), 인셉션(C3)
INSERT INTO genreList (genreID, contentID) VALUES (5, 3); -- 스릴러(G5), 인셉션(C3)
INSERT INTO genreList (genreID, contentID) VALUES (1, 4); -- 액션(G1), 올드보이(C4)
INSERT INTO genreList (genreID, contentID) VALUES (3, 4); -- 드라마(G3), 올드보이(C4)
INSERT INTO genreList (genreID, contentID) VALUES (5, 4); -- 스릴러(G5), 올드보이(C4)
INSERT INTO genreList (genreID, contentID) VALUES (3, 5); -- 드라마(G3), 더 글로리(C5)
INSERT INTO genreList (genreID, contentID) VALUES (5, 5); -- 스릴러(G5), 더 글로리(C5)
INSERT INTO genreList (genreID, contentID) VALUES (8, 6); -- 애니메이션(G8), 센과 치히로(C6)
INSERT INTO genreList (genreID, contentID) VALUES (10, 6); -- 판타지(G10), 센과 치히로(C6)
INSERT INTO genreList (genreID, contentID) VALUES (12, 6); -- 가족(G12), 센과 치히로(C6)
INSERT INTO genreList (genreID, contentID) VALUES (1, 7); -- 액션(G1), 어벤져스(C7)
INSERT INTO genreList (genreID, contentID) VALUES (4, 7); -- SF(G4), 어벤져스(C7)
INSERT INTO genreList (genreID, contentID) VALUES (1, 8); -- 액션(G1), 종이의 집(C8)
INSERT INTO genreList (genreID, contentID) VALUES (5, 8); -- 스릴러(G5), 종이의 집(C8)
INSERT INTO genreList (genreID, contentID) VALUES (1, 9); -- 액션(G1), 듄(C9)
INSERT INTO genreList (genreID, contentID) VALUES (3, 9); -- 드라마(G3), 듄(C9)
INSERT INTO genreList (genreID, contentID) VALUES (4, 9); -- SF(G4), 듄(C9)
INSERT INTO genreList (genreID, contentID) VALUES (1, 10); -- 액션(G1), 킹덤(C10)
INSERT INTO genreList (genreID, contentID) VALUES (5, 10); -- 스릴러(G5), 킹덤(C10)
INSERT INTO genreList (genreID, contentID) VALUES (9, 10); -- 호러(G9), 킹덤(C10)
INSERT INTO genreList (genreID, contentID) VALUES (3, 11); -- 드라마(G3), 조커(C11)
INSERT INTO genreList (genreID, contentID) VALUES (5, 11); -- 스릴러(G5), 조커(C11)

-- actorList (배우 목록, actor와 content 연결) - 늘리기
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '김기택', 1, 3); -- 송강호(A3) in 기생충(C1)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '코브', 3, 5); -- 레오나르도 디카프리오(A5) in 인셉션(C3)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('조연', '아리아드네', 3, 6); -- 엘리엇 페이지(A6) in 인셉션(C3)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '일레븐', 2, 7); -- 밀리 바비 브라운(A7) in 기묘한 이야기(C2)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '오대수', 4, 8); -- 최민식(A8) in 올드보이(C4)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '문동은', 5, 4); -- 김고은(A4) -> 실제 송혜교지만 예시로 김고은 사용 in 더 글로리(C5)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '아이언맨', 7, 10); -- 로버트 다우니 주니어(A10) in 어벤져스(C7)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '캡틴 아메리카', 7, 2); -- 스칼렛 요한슨(A2) -> 실제 크리스 에반스지만 예시로 스칼렛 사용 in 어벤져스(C7)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '폴 아트레이데스', 9, 13); -- 티모시 샬라메(A13) in 듄(C9)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '챠니', 9, 12); -- 젠데이아(A12) in 듄(C9)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '이창', 10, 9); -- 전지현(A9) -> 실제 주지훈이지만 예시로 전지현 사용 in 킹덤(C10)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('조연', '아서 플렉', 11, 5); -- 레오나르도 디카프리오(A5) -> 실제 호아킨 피닉스지만 예시로 레오 사용 in 조커(C11)

-- contentRating (콘텐츠 등급, content와 Country 연결) - 늘리기
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 1, 1); -- 기생충(C1), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('R', 1, 2); -- 기생충(C1), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('15', 1, 4); -- 기생충(C1), 영국(Co4)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('TV-14', 2, 2); -- 기묘한 이야기(C2), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('15', 2, 4); -- 기묘한 이야기(C2), 영국(Co4)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('15', 2, 1); -- 기묘한 이야기(C2), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('PG-13', 3, 2); -- 인셉션(C3), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('12', 3, 4); -- 인셉션(C3), 영국(Co4)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('12', 3, 1); -- 인셉션(C3), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 4, 1); -- 올드보이(C4), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('R', 4, 2); -- 올드보이(C4), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 5, 1); -- 더 글로리(C5), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('TV-MA', 5, 2); -- 더 글로리(C5), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('G', 6, 2); -- 센과 치히로(C6), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('All', 6, 1); -- 센과 치히로(C6), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('PG-13', 7, 2); -- 어벤져스(C7), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('12', 7, 1); -- 어벤져스(C7), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('TV-MA', 8, 2); -- 종이의 집(C8), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 8, 1); -- 종이의 집(C8), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('PG-13', 9, 2); -- 듄(C9), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('12', 9, 1); -- 듄(C9), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 10, 1); -- 킹덤(C10), 한국(Co1)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('TV-MA', 10, 2); -- 킹덤(C10), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('R', 11, 2); -- 조커(C11), 미국(Co2)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('15', 11, 1); -- 조커(C11), 한국(Co1)

-- creatorList (제작자 목록, creator와 content 연결) - 늘리기
INSERT INTO creatorList (contentID, creatorID) VALUES (1, 1); -- 기생충(C1), 봉준호(Cr1)
INSERT INTO creatorList (contentID, creatorID) VALUES (3, 2); -- 인셉션(C3), 크리스토퍼 놀란(Cr2)
INSERT INTO creatorList (contentID, creatorID) VALUES (2, 5); -- 기묘한 이야기(C2), 더퍼 형제(Cr5)
INSERT INTO creatorList (contentID, creatorID) VALUES (4, 7); -- 올드보이(C4), 박찬욱(Cr7)
INSERT INTO creatorList (contentID, creatorID) VALUES (6, 9); -- 센과 치히로(C6), 미야자키 하야오(Cr9)
INSERT INTO creatorList (contentID, creatorID) VALUES (7, 4); -- 어벤져스(C7), 스티븐 스필버그(Cr4) -> 실제 루소 형제지만 예시로 스필버그 사용
INSERT INTO creatorList (contentID, creatorID) VALUES (9, 11); -- 듄(C9), 드니 빌뇌브(Cr11)
-- 더 글로리(C5), 종이의 집(C8), 킹덤(C10), 조커(C11) 등 추가 제작자 연결 가능

-- featureList (특징 목록, feature와 content 연결) - 늘리기
INSERT INTO featureList (featureID, contentID) VALUES (2, 1); -- 비평가들의 찬사(F2), 기생충(C1)
INSERT INTO featureList (featureID, contentID) VALUES (10, 1); -- 어워드 수상(F10), 기생충(C1)
INSERT INTO featureList (featureID, contentID) VALUES (7, 1); -- 생각할 거리를 던지는(F7), 기생충(C1)
INSERT INTO featureList (featureID, contentID) VALUES (6, 2); -- 긴장감 넘치는(F6), 기묘한 이야기(C2) -- 감동적인(F5) -> 긴장감 넘치는(F6)으로 수정
INSERT INTO featureList (featureID, contentID) VALUES (3, 2); -- 기발한(F3), 기묘한 이야기(C2) -- 신규 추가
INSERT INTO featureList (featureID, contentID) VALUES (4, 3); -- 현실 왜곡/복잡한(F4), 인셉션(C3)
INSERT INTO featureList (featureID, contentID) VALUES (1, 3); -- 시각적으로 놀라운(F1), 인셉션(C3)
INSERT INTO featureList (featureID, contentID) VALUES (7, 3); -- 생각할 거리를 던지는(F7), 인셉션(C3)
INSERT INTO featureList (featureID, contentID) VALUES (6, 4); -- 긴장감 넘치는(F6), 올드보이(C4)
INSERT INTO featureList (featureID, contentID) VALUES (9, 4); -- 다크(F9), 올드보이(C4)
INSERT INTO featureList (featureID, contentID) VALUES (11, 4); -- 컬트 클래식(F11), 올드보이(C4)
INSERT INTO featureList (featureID, contentID) VALUES (6, 5); -- 긴장감 넘치는(F6), 더 글로리(C5)
INSERT INTO featureList (featureID, contentID) VALUES (9, 5); -- 다크(F9), 더 글로리(C5)
INSERT INTO featureList (featureID, contentID) VALUES (1, 6); -- 시각적으로 놀라운(F1), 센과 치히로(C6)
INSERT INTO featureList (featureID, contentID) VALUES (8, 6); -- 가슴 따뜻한(F8), 센과 치히로(C6)
INSERT INTO featureList (featureID, contentID) VALUES (10, 6); -- 어워드 수상(F10), 센과 치히로(C6)
INSERT INTO featureList (featureID, contentID) VALUES (1, 7); -- 시각적으로 놀라운(F1), 어벤져스(C7)
INSERT INTO featureList (featureID, contentID) VALUES (5, 7); -- 감동적인(F5), 어벤져스(C7)
INSERT INTO featureList (featureID, contentID) VALUES (6, 8); -- 긴장감 넘치는(F6), 종이의 집(C8)
INSERT INTO featureList (featureID, contentID) VALUES (1, 9); -- 시각적으로 놀라운(F1), 듄(C9)
INSERT INTO featureList (featureID, contentID) VALUES (10, 9); -- 어워드 수상(F10), 듄(C9)
INSERT INTO featureList (featureID, contentID) VALUES (6, 10); -- 긴장감 넘치는(F6), 킹덤(C10)
INSERT INTO featureList (featureID, contentID) VALUES (9, 10); -- 다크(F9), 킹덤(C10)
INSERT INTO featureList (featureID, contentID) VALUES (2, 11); -- 비평가들의 찬사(F2), 조커(C11)
INSERT INTO featureList (featureID, contentID) VALUES (9, 11); -- 다크(F9), 조커(C11)
INSERT INTO featureList (featureID, contentID) VALUES (10, 11); -- 어워드 수상(F10), 조커(C11)

-- 3. 비디오 (에피소드/영화), content 및 audioLang 테이블에 의존

-- video (비디오) - 늘리기
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '기생충', '영화 기생충 전체 영상', 132, 'epi/parasite.jpg', TO_DATE('2019-06-05', 'YYYY-MM-DD'), 1, 1); -- V1 (기생충 영화(C1), 한국어 스테레오(AL1))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 1, 'Chapter One: The Vanishing of Will Byers', '어린 소년 윌 바이어스가 사라지다.', 47, 'epi/st_s1e1.jpg', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2, 2); -- V2 (기묘한 이야기(C2) S1E1, 영어 5.1(AL2))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 2, 'Chapter Two: The Weirdo on Maple Street', '소년들이 메이플가의 이상한 소녀를 발견하다.', 55, 'epi/st_s1e2.jpg', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2, 2); -- V3 (기묘한 이야기(C2) S1E2, 영어 5.1(AL2))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '인셉션', '영화 인셉션 전체 영상', 148, 'epi/inception.jpg', TO_DATE('2010-07-21', 'YYYY-MM-DD'), 3, 5); -- V4 (인셉션 영화(C3), 영어 돌비 애트모스(AL5))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '올드보이', '영화 올드보이 전체 영상', 120, 'epi/oldboy.jpg', TO_DATE('2003-11-21', 'YYYY-MM-DD'), 4, 1); -- V5 (올드보이 영화(C4), 한국어 스테레오(AL1))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 1, '1화', '문동은의 복수가 시작된다.', 52, 'epi/glory_s1e1.jpg', TO_DATE('2022-12-30', 'YYYY-MM-DD'), 5, 10); -- V6 (더 글로리(C5) S1E1, 한국어 돌비 애트모스(AL10))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 2, '2화', '과거의 상처가 현재를 찌르다.', 58, 'epi/glory_s1e2.jpg', TO_DATE('2022-12-30', 'YYYY-MM-DD'), 5, 10); -- V7 (더 글로리(C5) S1E2, 한국어 돌비 애트모스(AL10))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '센과 치히로의 행방불명', '영화 센과 치히로의 행방불명 전체 영상', 125, 'epi/spirited.jpg', TO_DATE('2002-06-28', 'YYYY-MM-DD'), 6, 3); -- V8 (센과 치히로 영화(C6), 일본어 스테레오(AL3))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '어벤져스: 엔드게임', '영화 어벤져스: 엔드게임 전체 영상', 181, 'epi/endgame.jpg', TO_DATE('2019-04-24', 'YYYY-MM-DD'), 7, 5); -- V9 (어벤져스 영화(C7), 영어 돌비 애트모스(AL5))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 1, '에피소드 1', '교수가 강도단을 모으다.', 48, 'epi/moneyheist_s1e1.jpg', TO_DATE('2017-12-20', 'YYYY-MM-DD'), 8, 6); -- V10 (종이의 집(C8) S1E1, 스페인어 스테레오(AL6))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 2, '에피소드 2', '조폐국 침투 작전 개시.', 41, 'epi/moneyheist_s1e2.jpg', TO_DATE('2017-12-20', 'YYYY-MM-DD'), 8, 6); -- V11 (종이의 집(C8) S1E2, 스페인어 스테레오(AL6))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '듄', '영화 듄 파트 1 전체 영상', 155, 'epi/dune.jpg', TO_DATE('2021-10-20', 'YYYY-MM-DD'), 9, 5); -- V12 (듄 영화(C9), 영어 돌비 애트모스(AL5))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 1, '1화', '왕이 좀비가 되다.', 56, 'epi/kingdom_s1e1.jpg', TO_DATE('2019-01-25', 'YYYY-MM-DD'), 10, 1); -- V13 (킹덤(C10) S1E1, 한국어 스테레오(AL1))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 2, '2화', '역병의 시작.', 43, 'epi/kingdom_s1e2.jpg', TO_DATE('2019-01-25', 'YYYY-MM-DD'), 10, 1); -- V14 (킹덤(C10) S1E2, 한국어 스테레오(AL1))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '조커', '영화 조커 전체 영상', 122, 'epi/joker.jpg', TO_DATE('2019-10-02', 'YYYY-MM-DD'), 11, 5); -- V15 (조커 영화(C11), 영어 돌비 애트모스(AL5))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 3, 'Chapter Three: Holly, Jolly', '호킨스 연구소의 비밀이 드러나기 시작한다.', 51, 'epi/st_s1e3.jpg', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2, 2); -- V16 (기묘한 이야기(C2) S1E3, 영어 5.1(AL2))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (2, 1, 'Chapter One: MADMAX', '새로운 전학생 맥스가 등장한다.', 48, 'epi/st_s2e1.jpg', TO_DATE('2017-10-27', 'YYYY-MM-DD'), 2, 2); -- V17 (기묘한 이야기(C2) S2E1, 영어 5.1(AL2))

-- 4. 사용자 프로필 관련 테이블 (account, subtitleSetting, Country, video, feature, genre 테이블에 의존)

-- profile (프로필, account, subtitleSetting, Country 테이블에 의존) - 늘리기 (이제 FK 오류 없음)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('앨리스_메인', 'img/alice1.png', NULL, 1, 1, 1); -- P1 (앨리스(Acc1), Arial 자막(S1), 한국(Co1))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('앨리스_키즈', 'img/alice_kid.png', '12', 1, 3, 1); -- P2 (앨리스(Acc1), 돋움 자막(S3), 한국(Co1), 12세 미만)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('밥_액션팬', 'img/bob.png', NULL, 2, 2, 2); -- P3 (밥(Acc2), Times 자막(S2), 미국(Co2))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('찰리1', NULL, NULL, 3, 1, 2); -- P4 (찰리(Acc3), Arial 자막(S1), 미국(Co2))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('David_Main', 'img/david.png', NULL, 4, 6, 2); -- P5 (데이빗(Acc4), 맑은 고딕(S6), 미국(Co2))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('Eve_Cinephile', 'img/eve.png', NULL, 5, 5, 4); -- P6 (이브(Acc5), Verdana(S5), 영국(Co4))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('프랭크', 'img/frank.png', '7', 6, 4, 1); -- P7 (프랭크(Acc6), 굴림(S4), 한국(Co1), 7세 미만)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('Grace_K-Drama', 'img/grace.png', NULL, 7, 7, 1); -- P8 (그레이스(Acc7), 바탕(S7), 한국(Co1))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('하이디', 'img/heidi.png', NULL, 8, 9, 6); -- P9 (하이디(Acc8), 궁서(S9), 독일(Co6))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('Ivan_SciFi', 'img/ivan.png', '15', 9, 8, 2); -- P10 (이반(Acc9), Consolas(S8), 미국(Co2), 15세 미만)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('주디', NULL, NULL, 10, 10, 1); -- P11 (주디(Acc10), Helvetica(S10), 한국(Co1))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('Kevin_General', 'img/kevin.png', NULL, 11, 1, 3); -- P12 (케빈(Acc11), Arial(S1), 일본(Co3))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('앨리스_남편', 'img/alice_husband.png', NULL, 1, 2, 1); -- P13 (앨리스 계정 추가 프로필)

-- payment (결제 정보, membership, account 테이블에 의존) - 기존 3개 + 1개 추가
INSERT INTO payment (paydate, paymethod, payamount, useperiod, membershipID, accountID)
VALUES (SYSDATE - 5, '신용카드 ****1234', '13500', '2025-04-03 ~ 2025-05-02', 3, 1); -- 앨리스(Acc1), 프리미엄(M3) 갱신 (기존 것 외 추가)
INSERT INTO payment (paydate, paymethod, payamount, useperiod, membershipID, accountID)
VALUES (SYSDATE, 'PayPal charlie@netflix.com', '5500', '2025-04-09 ~ 2025-05-08', 1, 3); -- 찰리(Acc3), 광고형 베이식(M1) 갱신

-- device (사용 기기, profile 테이블에 의존) - 기존 4개 + 4개 추가 (ID는 시퀀스에 의해 자동 생성됨)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('Bob Android Phone', SYSDATE, 3); -- D1 (밥_액션팬(P3) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('Charlie Roku TV', SYSDATE - 1, 4); -- D2 (찰리1(P4) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('Alice Macbook Pro', SYSDATE, 1); -- D3 (앨리스_메인(P1) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('LG Smart TV', SYSDATE - 2, 3); -- D4 (밥_액션팬(P3) 다른 기기)

-- viewingHistory (시청 기록, profile, video 테이블에 의존) - 기존 4개 + 5개 추가
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('Y', SYSDATE - 1, 7920, 1, 1); -- 앨리스_메인(P1)이 기생충(V1) 시청 완료 (132분 = 7920초).
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('N', SYSDATE, 3600, 3, 4); -- 밥_액션팬(P3)이 인셉션(V4) 1시간(3600초) 시청 중.
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('Y', SYSDATE - 3, 2820, 2, 2); -- 앨리스_키즈(P2)가 기묘한 이야기 S1E1(V2) 완료 (47분 = 2820초).
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('N', SYSDATE, 600, 2, 3); -- 앨리스_키즈(P2)가 기묘한 이야기 S1E2(V3) 10분(600초) 시청 중.
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('Y', SYSDATE - 1, 8880, 4, 4); -- 찰리1(P4)이 인셉션(V4) 재시청 완료 (148분 = 8880초).

-- wishList (찜 목록, profile, video 테이블에 의존) - 기존 3개 + 3개 추가
INSERT INTO wishList (profileID, videoID) VALUES (3, 3); -- 밥_액션팬(P3)이 기묘한 이야기 S1E2(V3) 찜.
INSERT INTO wishList (profileID, videoID) VALUES (4, 1); -- 찰리1(P4)이 기생충(V1) 찜.
INSERT INTO wishList (profileID, videoID) VALUES (2, 4); -- 앨리스_키즈(P2)가 인셉션(V4) 찜 (연령 제한 걸릴 수 있음).

-- userRating (사용자 평가, content, profile 테이블에 의존) - 기존 3개 + 3개 추가
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (0, SYSDATE, 3, 3); -- 밥_액션팬(P3)이 인셉션(C3) 싫어요(0) 평가.
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (1, SYSDATE - 1, 4, 3); -- 찰리1(P4)이 인셉션(C3) 좋아요(1) 평가.
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (1, SYSDATE - 3, 2, 2); -- 앨리스_키즈(P2)가 기묘한 이야기(C2) 좋아요(1) 평가.

-- featureViewCnt (특징별 시청 횟수, profile, feature 테이블에 의존) - 기존 2개 + 3개 추가
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID)
VALUES (8, 'Korean', 1, 5); -- 앨리스_메인(P1)이 감동적인(F5) 콘텐츠 8개 시청. 기본 언어 한국어.
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID)
VALUES (3, 'English', 4, 1); -- 찰리1(P4)이 시각적으로 놀라운(F1) 콘텐츠 3개 시청. 기본 언어 영어.
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID)
VALUES (12, 'English', 3, 4); -- 밥_액션팬(P3)이 현실 왜곡/복잡한(F4) 콘텐츠 12개 시청. 기본 언어 영어.

-- genreViewCnt (장르별 시청 횟수, profile, genre 테이블에 의존) - 기존 3개 + 4개 추가
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (10, 'Korean', 1, 5); -- 앨리스_메인(P1)이 스릴러(G5) 콘텐츠 10개 시청. 기본 언어 한국어.
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (5, 'English', 4, 4); -- 찰리1(P4)이 SF(G4) 콘텐츠 5개 시청. 기본 언어 영어.
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (7, 'Korean', 2, 4); -- 앨리스_키즈(P2)가 SF(G4) 콘텐츠 7개 시청. 기본 언어 한국어.
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (6, 'English', 4, 1); -- 찰리1(P4)이 액션(G1) 콘텐츠 6개 시청. 기본 언어 영어.

-- trailer (예고편, video, audioLang 테이블에 의존) - 기존 3개 + 2개 추가
INSERT INTO trailer (trailerURL, title, videoID, audioLangID)
VALUES ('trailer/st_s1_kr.mp4', '기묘한 이야기 시즌 1 한국어 예고편', 2, 1); -- 기묘한 이야기 S1E1(V2) 예고편, 한국어 스테레오(AL1)
INSERT INTO trailer (trailerURL, title, videoID, audioLangID)
VALUES ('trailer/inception_kr.mp4', '인셉션 한국어 예고편', 4, 1); -- 인셉션(V4) 예고편, 한국어 스테레오(AL1)

-- subtitle (자막, video, subtitleSetting 테이블에 의존) - 기존 4개 + 4개 추가
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/st_s1e1_en.srt', NULL, 2, 2); -- 기묘한 이야기 S1E1(V2) 영어 자막, Times New Roman 스타일(S2) 사용
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/inception_en_sdh.srt', 'Y', 4, 1); -- 인셉션(V4) 영어 청각 장애인용 자막 (SDH), Arial 스타일(S1)
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/st_s1e2_ko.srt', NULL, 3, 3); -- 기묘한 이야기 S1E2(V3) 한국어 자막, 돋움 스타일(S3) 사용
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/st_s1e2_en.srt', NULL, 3, 2); -- 기묘한 이야기 S1E2(V3) 영어 자막, Times New Roman 스타일(S2) 사용

-- download (다운로드 목록, device, video 테이블에 의존) - 기존 3개 + 3개 추가 (deviceID 오류 수정)
-- 참고: deviceID는 device 테이블 insert 시 시퀀스에 의해 결정됩니다.
-- 아래는 시퀀스가 1, 2, 3, 4 순서로 deviceID를 생성했다고 가정하고 작성되었습니다.
-- 실제 환경에서는 device 테이블 insert 후 생성된 ID를 확인하고 사용해야 할 수 있습니다.
INSERT INTO download (deviceID, videoID) VALUES (1, 4); -- Bob Android Phone(D1)에 인셉션(V4) 다운로드. (원래 deviceID 3 이었으나, 첫번째 device insert로 가정하여 1로 변경)
INSERT INTO download (deviceID, videoID) VALUES (2, 1); -- Charlie Roku TV(D2)에 기생충(V1) 다운로드. (원래 deviceID 6이었으나, 두번째 device insert로 가정하여 2로 변경)
INSERT INTO download (deviceID, videoID) VALUES (3, 2); -- Alice Macbook Pro(D3)에 기묘한 이야기 S1E1(V2) 다운로드. (원래 deviceID 5였으나, 세번째 device insert로 가정하여 3으로 변경)

COMMIT; -- 모든 삽입 후 트랜잭션 커밋


-- featureViewCnt 테이블 더미 데이터 추가

-- Profile 1 (기존 feature 5 외 추가)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (5, 'Korean', 1, 2);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (12, 'Korean', 1, 7);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (3, 'Korean', 1, 10);

-- Profile 2 (새 데이터)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (15, 'Korean', 2, 1);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (7, 'Korean', 2, 4);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (9, 'Korean', 2, 8);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (4, 'Korean', 2, 11);


-- Profile 3 (기존 feature 4 외 추가)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (22, 'English', 3, 1);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (6, 'English', 3, 6);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (10, 'English', 3, 9);


-- Profile 4 (기존 feature 1 외 추가)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (11, 'English', 4, 3);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (2, 'English', 4, 5);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (14, 'English', 4, 10);


-- Profile 5 (새 데이터)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (18, 'English', 5, 2);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (7, 'English', 5, 7);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (13, 'English', 5, 11);
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID) VALUES (5, 'English', 5, 3);

COMMIT; -- 변경사항 최종 저장


-- genreViewCnt 테이블 더미 데이터 추가

-- Profile 1 (기존 genre 5 외 추가)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (15, 'Korean', 1, 1);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (8, 'Korean', 1, 3);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (12, 'Korean', 1, 7);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (6, 'Korean', 1, 10);

-- Profile 2 (기존 genre 4 외 추가)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (11, 'Korean', 2, 1);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (9, 'Korean', 2, 6);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (5, 'Korean', 2, 9);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (14, 'Korean', 2, 11);

-- Profile 3 (새 데이터)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (10, 'English', 3, 2);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (18, 'English', 3, 5);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (4, 'English', 3, 8);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (7, 'English', 3, 12);

-- Profile 4 (기존 genre 4, 1 외 추가)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (13, 'English', 4, 2);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (9, 'English', 4, 6);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (16, 'English', 4, 10);

-- Profile 5 (새 데이터)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (20, 'English', 5, 3);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (6, 'English', 5, 5);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (14, 'English', 5, 7);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (8, 'English', 5, 11);
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID) VALUES (17, 'English', 5, 12);

COMMIT; -- 변경사항 최종 저장