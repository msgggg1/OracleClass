/* 계정 */
DROP TABLE account 
	CASCADE CONSTRAINTS;

/* 프로필 */
DROP TABLE profile 
	CASCADE CONSTRAINTS;

/* 자막표시설정 */
DROP TABLE subtitleSetting 
	CASCADE CONSTRAINTS;

/* 시청기록 */
DROP TABLE viewingHistory 
	CASCADE CONSTRAINTS;

/* 찜하기 목록 */
DROP TABLE wishList 
	CASCADE CONSTRAINTS;

/* 사용중인 디바이스 */
DROP TABLE device 
	CASCADE CONSTRAINTS;

/* 멤버쉽 */
DROP TABLE membership 
	CASCADE CONSTRAINTS;

/* 결제방식 */
DROP TABLE payment 
	CASCADE CONSTRAINTS;

/* 다운로드 */
DROP TABLE download 
	CASCADE CONSTRAINTS;

/* 특징별시청횟수 */
DROP TABLE featureViewCnt 
	CASCADE CONSTRAINTS;

/* 장르별시청횟수 */
DROP TABLE genreViewCnt 
	CASCADE CONSTRAINTS;

/* 콘텐츠 */
DROP TABLE content 
	CASCADE CONSTRAINTS;

/* 영상 */
DROP TABLE video 
	CASCADE CONSTRAINTS;

/* 장르 */
DROP TABLE genre 
	CASCADE CONSTRAINTS;

/* 장르 리스트 */
DROP TABLE genreList 
	CASCADE CONSTRAINTS;

/* 배우 */
DROP TABLE actor 
	CASCADE CONSTRAINTS;

/* 배우들 */
DROP TABLE actorList 
	CASCADE CONSTRAINTS;

/* 오디오 트랙 */
DROP TABLE audioTrack 
	CASCADE CONSTRAINTS;

/* 트레일러 */
DROP TABLE trailer 
	CASCADE CONSTRAINTS;

/* 사용자 평가 */
DROP TABLE userRating 
	CASCADE CONSTRAINTS;

/* 특징 */
DROP TABLE feature 
	CASCADE CONSTRAINTS;

/* 국가 */
DROP TABLE Country 
	CASCADE CONSTRAINTS;

/* 시청 등급 */
DROP TABLE contentRating 
	CASCADE CONSTRAINTS;

/* 크리에이터 */
DROP TABLE creator 
	CASCADE CONSTRAINTS;

/* 자막 */
DROP TABLE subtitle 
	CASCADE CONSTRAINTS;

/* 콘텐츠 제작자들 */
DROP TABLE creatorList 
	CASCADE CONSTRAINTS;

/* 특징 리스트 */
DROP TABLE featureList 
	CASCADE CONSTRAINTS;

/* 음성언어 */
DROP TABLE audioLang 
	CASCADE CONSTRAINTS;


/* 계정 */
CREATE TABLE account (
	accountID INT not null primary key, /* 계정 ID */
	email VARCHAR2(255) NOT NULL unique, /* 이메일 */
	phoneNumber VARCHAR2(30) NOT NULL unique, /* 전화번호 */
	pw VARCHAR2(255) NOT NULL, /* 비밀번호 */
	gender CHAR(1) NOT NULL, /* 성별 */
	profilepw VARCHAR2(6) NOT NULL, /* 본인확인pin번호 */
	adultverification CHAR(1) NOT NULL /* 성인인증 */
);

/* 자막표시설정 */
CREATE TABLE subtitleSetting (
	subtitleSettingID INT NOT NULL primary key, /* 자막표시 ID */
	font VARCHAR2(100), /* 글꼴 */
	fontSize INT, /* 크기 */
	fontEffect VARCHAR2(50) /* 효과 */
);

/* 국가 */
CREATE TABLE Country (
	countryID INT NOT NULL primary key, /* 국가 ID */
	baseLanguege VARCHAR2(30) NOT NULL, /* 기본언어 */
	maxRate VARCHAR2(20) /* 최고시청등급 */
);


/* 프로필 */
CREATE TABLE profile (
	profileID INT NOT NULL primary key, /* 프로필 ID */
	nickname VARCHAR2(200) NOT NULL, /* 닉네임 */
	profileimage VARCHAR2(255), /* 프로필사진 */
	accessRestriction VARCHAR2(100), /* 접근제한 */
	accountID INT NOT NULL, /* 계정 ID */
	subtitleSettingID INT NOT NULL, /* 자막표시 ID */
	countryID INT NOT NULL, /* 국가 ID */
    CONSTRAINT FK_account_TO_profile FOREIGN KEY (accountID) REFERENCES account(accountID),
    CONSTRAINT FK_subtitleSetting_TO_profile FOREIGN KEY (subtitleSettingID) REFERENCES subtitleSetting(subtitleSettingID),
    CONSTRAINT FK_Country_TO_profile FOREIGN KEY (countryID) REFERENCES Country(countryID)
);

/* 콘텐츠 */
CREATE TABLE content (
	contentID INT NOT NULL primary key, /* 콘텐츠 ID */
	contentType VARCHAR2(50) NOT NULL, /* 콘텐츠 유형 */
	title VARCHAR2(200) NOT NULL, /* 제목 */
	originTitle VARCHAR2(200) NOT NULL, /* 원제 */
	description VARCHAR2(3000), /* 설명 */
	releaseDate DATE NOT NULL, /* 출시 일자 */
	releaseYear NUMBER(4) NOT NULL, /* 출시 년도 */
	publicDate DATE NOT NULL, /* 공개일 */
	runtime INT NOT NULL, /* 재생 시간(분) */
	thumbnailURL VARCHAR2(255), /* 썸네일 이미지 URL */
	mainImage VARCHAR2(255), /* 대표 이미지 URL */
	originLang VARCHAR2(50) NOT NULL, /* 원본 언어 */
	productionCountry VARCHAR2(50) NOT NULL, /* 제작 국가 */
	registeredAt DATE NOT NULL, /* 등록 일시 */
	updatedAt DATE, /* 수정 일시 */
	availableCountry VARCHAR2(50) NOT NULL, /* 공개 국가 */
	videoQuality VARCHAR2(20) NOT NULL /* 제공 화질 */
);

/* 오디오 트랙 */
CREATE TABLE audioTrack (
	audioTrackID INT NOT NULL primary key, /* 오디오 트랙 ID */
	audioTrackName varchar(50) not null, /*오디오 트랙 명*/
    audioDescription VARCHAR2(255) /* 오디오 설명 */
);

/* 음성언어 */
CREATE TABLE audioLang (
    audioLangID INT NOT NULL primary key, /* 음성언어 ID */
    Language VARCHAR2(30) NOT NULL, /* 언어 */
    audioTrackID INT NOT NULL, /* 오디오 트랙 ID */
    CONSTRAINT FK_audioTrack_TO_audioLang FOREIGN KEY (audioTrackID) REFERENCES audioTrack(audioTrackID)
);


/* 영상 */
CREATE TABLE video (
	videoID INT NOT NULL primary key, /* 영상 ID */
	seasonNum INT, /* 시즌 번호 */
	epiNum INT, /* 에피소드 화수 */
	epiTitle VARCHAR2(150) NOT NULL, /* 에피소드 제목 */
	epiDescription VARCHAR2(1000), /* 에피소드 설명 */
	epiruntime INT NOT NULL, /* 에피소드 재생시간(분) */
	epiImageURL VARCHAR2(255) NOT NULL, /* 에피소드 썸네일 URL */
	releaseDate DATE NOT NULL, /* 공개일 */
	contentID INT NOT NULL, /* 콘텐츠 ID */
	audioLangID INT NOT NULL, /* 음성언어 ID */
    CONSTRAINT FK_content_TO_video FOREIGN KEY (contentID) REFERENCES content(contentID),
    CONSTRAINT FK_audioLang_TO_video FOREIGN KEY (audioLangID) REFERENCES audioLang(audioLangID)
);

/* 시청기록 */
CREATE TABLE viewingHistory (
	viewingHistoryID INT NOT NULL primary key, /* 시청기록 ID */
	isCompleted CHAR(1) NOT NULL, /* 시청 완료 여부 */
	lastViewat DATE NOT NULL, /* 시청날짜 */
	totalViewingTime INT NOT NULL, /* 총 시청 시간(초) */
	profileID INT NOT NULL, /* 프로필 ID */
	videoID INT NOT NULL, /* 영상 ID */
    CONSTRAINT FK_profile_TO_viewingHistory FOREIGN KEY (profileID) REFERENCES profile(profileID),
    CONSTRAINT FK_video_TO_viewingHistory FOREIGN KEY (videoID) REFERENCES video(videoID)
);

/* 찜하기 목록 */
CREATE TABLE wishList (
	wishlistID INT NOT NULL primary key, /* 찜하기 ID */
	profileID INT NOT NULL, /* 프로필 ID */
	videoID INT NOT NULL, /* 영상 ID */
    CONSTRAINT FK_profile_TO_wishList FOREIGN KEY (profileID) REFERENCES profile(profileID),
    CONSTRAINT FK_video_TO_wishList FOREIGN KEY (videoID) REFERENCES video(videoID)
);


/* 멤버쉽 */
CREATE TABLE membership (
	membershipID INT NOT NULL primary key, /* 멤버쉽 ID */
	price INT NOT NULL, /* 월요금 */
	resolution VARCHAR2(100) NOT NULL, /* 해상도 */
	concurrentConnection INT NOT NULL, /* 접속자수 */
	ad INT NOT NULL, /* 광고여부 */
    downDeviceCnt int not null,
	audiotrackid INT NOT NULL, /* 오디오 트랙 ID */
    CONSTRAINT FK_audioTrack_TO_membership FOREIGN KEY (audiotrackid) REFERENCES audioTrack(audiotrackid)
);

/* 결제방식 */
CREATE TABLE payment (
	payid INT NOT NULL primary key, /* 결제id */
	paydate DATE NOT NULL, /* 결제날짜 */
	paymethod VARCHAR2(100) NOT NULL, /* 결제수단 */
	payamount VARCHAR2(100) NOT NULL, /* 결제금액 */
	useperiod VARCHAR2(200) NOT NULL, /* 기간설명 */
	membershipID INT NOT NULL, /* 멤버쉽 ID */
	accountID INT NOT NULL, /* 계정 ID */
    CONSTRAINT FK_membership_TO_payment FOREIGN KEY (membershipID) REFERENCES membership(membershipID),
    CONSTRAINT FK_account_TO_payment FOREIGN KEY (accountID) REFERENCES account(accountID)
);

/* 사용중인 디바이스 */
CREATE TABLE device (
	deviceID INT NOT NULL primary key, /* 사용디바이스 ID */
	deviceName VARCHAR2(100) NOT NULL, /* 디바이스명 */
	connectionTime DATE NOT NULL, /* 접속시간 */
	accountId INT NOT NULL, /* 프로필 ID */
    CONSTRAINT FK_account_TO_device FOREIGN KEY (accountId) REFERENCES account(accountId)
);

/* 다운로드 */
CREATE TABLE download (
	downID INT NOT NULL primary key, /* 다운로드 ID */
	deviceID INT NOT NULL, /* 사용디바이스 ID */
	videoID INT NOT NULL, /* 영상 ID */
    CONSTRAINT FK_device_TO_download FOREIGN KEY (deviceID) REFERENCES device(deviceID),
    CONSTRAINT FK_video_TO_download FOREIGN KEY (videoID) REFERENCES video(videoID)
);









/* 특징 */
CREATE TABLE feature (
	featureID INT NOT NULL primary key, /* 특징 ID */
	featureName VARCHAR2(50) NOT NULL unique /* 특징명 */
);

/* 장르 */
CREATE TABLE genre (
	genreID INT NOT NULL primary key, /* 장르 ID */
	genreName VARCHAR2(20) NOT NULL unique /* 장르명 */
);

/* 특징 리스트 */
CREATE TABLE featureList (
    featureListid INT NOT NULL primary key, /* 특징리스트 ID */
    featureID INT NOT NULL, /* 특징 ID */
    contentID INT NOT NULL, /* 콘텐츠 ID */
    CONSTRAINT FK_feature_TO_featureList FOREIGN KEY (featureID) REFERENCES feature(featureID),
    CONSTRAINT FK_content_TO_featureList FOREIGN KEY (contentID) REFERENCES content(contentID)
);

/* 장르 리스트 */
CREATE TABLE genreList (
	genreListid INT NOT NULL primary key, /* 장르리스트 ID */
	genreID INT NOT NULL, /* 장르 ID */
	contentID INT NOT NULL, /* 콘텐츠 ID */
    CONSTRAINT FK_genre_TO_genreList FOREIGN KEY (genreID) REFERENCES genre(genreID),
    CONSTRAINT FK_content_TO_genreList FOREIGN KEY (contentID) REFERENCES content(contentID)
);

/* 특징별시청횟수 */
CREATE TABLE featureViewCnt (
	featureViewCntID INT NOT NULL primary key, /* 특징횟수 ID */
	cnt INT NOT NULL, /* count */
	profileID INT NOT NULL, /* 프로필 ID */
	featureID INT not null, /* 특징 ID */
    CONSTRAINT FK_profile_TO_featureViewCnt FOREIGN KEY (profileID) REFERENCES profile(profileID),
    CONSTRAINT FK_feature_TO_featureViewCnt FOREIGN KEY (featureID) REFERENCES feature(featureID)
);

/* 장르별시청횟수 */
CREATE TABLE genreViewCnt (
	genreViewCntID INT NOT NULL primary key, /* 장르횟수 ID */
	cnt INT NOT NULL, /* count */
	profileID INT NOT NULL, /* 프로필 ID */
	genreID INT NOT NULL, /* 장르 ID */
    CONSTRAINT FK_profile_TO_genreViewCnt FOREIGN KEY (profileID) REFERENCES profile(profileID),
    CONSTRAINT FK_genre_TO_genreViewCnt FOREIGN KEY (genreID) REFERENCES genre(genreID)
);


/* 배우 */
CREATE TABLE actor (
	actorid INT NOT NULL primary key, /* 인물 ID */
	name VARCHAR2(255) NOT NULL, /* 인물 이름 */
	birthDate DATE NOT NULL /* 생년월일 */
);

/* 배우들 */
CREATE TABLE actorList (
	actorListid INT NOT NULL primary key, /* 배우리스트 ID */
	role VARCHAR2(255), /* 역할 */
	roleName VARCHAR2(255), /* 배역명 */
	contentID INT NOT NULL, /* 콘텐츠 ID */
	actorid INT NOT NULL, /* 인물 ID */
    CONSTRAINT FK_content_TO_actorList FOREIGN KEY (contentID) REFERENCES content(contentID),
    CONSTRAINT FK_actor_TO_actorList FOREIGN KEY (actorid) REFERENCES actor(actorid)
);

/* 크리에이터 */
CREATE TABLE creator (
	creatorID INT NOT NULL primary key, /* 크리에이터 ID */
	creatorName VARCHAR2(255) NOT NULL /* 크리에이터 이름 */
);

/* 콘텐츠 제작자들 */
CREATE TABLE creatorList (
    creatorListid INT NOT NULL primary key, /* 크리에이터리스트 ID */
    role varchar2(30) not null,
    contentID INT NOT NULL, /* 콘텐츠 ID */
    creatorID INT NOT NULL, /* 크리에이터 ID */
    CONSTRAINT FK_content_TO_creatorList FOREIGN KEY (contentID) REFERENCES content(contentID),
    CONSTRAINT FK_creator_TO_creatorList FOREIGN KEY (creatorID) REFERENCES creator(creatorID)
);






/* 트레일러 */
CREATE TABLE trailer (
	trailerID INT NOT NULL primary key, /* 트레일러 ID */
	trailerURL VARCHAR2(255) NOT NULL, /* 트레일러 URL */
	title VARCHAR2(255) NOT NULL, /* 제목 */
	videoID INT NOT NULL, /* 영상 ID */
	audioLangID INT NOT NULL, /* 음성언어 ID */
    CONSTRAINT FK_video_TO_trailer FOREIGN KEY (videoID) REFERENCES video(videoID),
    CONSTRAINT FK_audioLang_TO_trailer FOREIGN KEY (audioLangID) REFERENCES audioLang(audioLangID)
);

/* 사용자 평가 */
CREATE TABLE userRating (
	ratingID INT NOT NULL primary key, /* 평가 ID */
	ratingType INT NOT NULL, /* 평가 유형 */
	ratingTime DATE NOT NULL, /* 평가 시각 */
	profileID INT NOT NULL, /* 프로필 ID */
	contentID INT NOT NULL, /* 콘텐츠 ID */
    CONSTRAINT FK_profile_TO_userRating FOREIGN KEY (profileID) REFERENCES profile(profileID),
    CONSTRAINT FK_content_TO_userRating FOREIGN KEY (contentID) REFERENCES content(contentID)
);


/* 시청 등급 */
CREATE TABLE contentRating (
	contentRatingID INT NOT NULL primary key, /* 시청 등급 ID */
	ratingLabel VARCHAR2(50) NOT NULL, /* 시청 등급 */
	contentID INT NOT NULL, /* 콘텐츠 ID */
	countryID INT NOT NULL, /* 국가 ID */
    CONSTRAINT FK_content_TO_contentRating FOREIGN KEY (contentID) REFERENCES content(contentID),
    CONSTRAINT FK_Country_TO_contentRating FOREIGN KEY (countryID) REFERENCES Country(countryID)
);

/* 자막 */
CREATE TABLE subtitle (
	subtitleID INT NOT NULL primary key, /* 자막 ID */
	subtitleFileURL VARCHAR2(255), /* 자막 파일 URL */
	lang VARCHAR2(30), /* 자막 */
	videoID INT NOT NULL, /* 영상 ID */
	subtitleSettingID INT NOT NULL, /* 자막표시 ID */
    CONSTRAINT FK_video_TO_subtitle FOREIGN KEY (videoID) REFERENCES video(videoID),
    CONSTRAINT FK_subtitleSetting_TO_subtitle FOREIGN KEY (subtitleSettingID) REFERENCES subtitleSetting(subtitleSettingID)
);
