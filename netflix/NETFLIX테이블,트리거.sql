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
   accountID INT NOT NULL, /* 계정 ID */
   email VARCHAR2(255) NOT NULL, /* 이메일 */
   phoneNumber VARCHAR2(30) NOT NULL, /* 전화번호 */
   pw VARCHAR2(255) NOT NULL, /* 비밀번호 */
   gender CHAR(1) NOT NULL, /* 성별 */
   profilepw VARCHAR2(6) NOT NULL, /* 본인확인pin번호 */
   adultverification CHAR(1) NOT NULL /* 성인인증 */
);

CREATE UNIQUE INDEX PK_account
   ON account (
      accountID ASC
   );

ALTER TABLE account
   ADD
      CONSTRAINT PK_account
      PRIMARY KEY (
         accountID
      );

/* 프로필 */
CREATE TABLE profile (
   profileID INT NOT NULL, /* 프로필 ID */
   nickname VARCHAR2(200) NOT NULL, /* 닉네임 */
   profileimage VARCHAR2(255), /* 프로필사진 */
   accessRestriction VARCHAR2(100), /* 접근제한 */
   accountID INT NOT NULL, /* 계정 ID */
   subtitleSettingID INT NOT NULL, /* 자막표시 ID */
   countryID INT NOT NULL /* 국가 ID */
);

CREATE UNIQUE INDEX PK_profile
   ON profile (
      profileID ASC
   );

ALTER TABLE profile
   ADD
      CONSTRAINT PK_profile
      PRIMARY KEY (
         profileID
      );

/* 자막표시설정 */
CREATE TABLE subtitleSetting (
   subtitleSettingID INT NOT NULL, /* 자막표시 ID */
   font VARCHAR2(100), /* 글꼴 */
   fontSize INT, /* 크기 */
   fontEffect VARCHAR2(50) /* 효과 */
);

CREATE UNIQUE INDEX PK_subtitleSetting
   ON subtitleSetting (
      subtitleSettingID ASC
   );

ALTER TABLE subtitleSetting
   ADD
      CONSTRAINT PK_subtitleSetting
      PRIMARY KEY (
         subtitleSettingID
      );

/* 시청기록 */
CREATE TABLE viewingHistory (
   viewingHistoryID INT NOT NULL, /* 시청기록 ID */
   isCompleted CHAR(1) NOT NULL, /* 시청 완료 여부 */
   lastViewat DATE NOT NULL, /* 시청날짜 */
   totalViewingTime INT NOT NULL, /* 총 시청 시간(초) */
   profileID INT NOT NULL, /* 프로필 ID */
   videoID INT NOT NULL /* 영상 ID */
);

CREATE UNIQUE INDEX PK_viewingHistory
   ON viewingHistory (
      viewingHistoryID ASC
   );

ALTER TABLE viewingHistory
   ADD
      CONSTRAINT PK_viewingHistory
      PRIMARY KEY (
         viewingHistoryID
      );

/* 찜하기 목록 */
CREATE TABLE wishList (
   wishlistID INT NOT NULL, /* 찜하기 ID */
   profileID INT NOT NULL, /* 프로필 ID */
   videoID INT NOT NULL /* 영상 ID */
);

CREATE UNIQUE INDEX PK_wishList
   ON wishList (
      wishlistID ASC
   );

ALTER TABLE wishList
   ADD
      CONSTRAINT PK_wishList
      PRIMARY KEY (
         wishlistID
      );

/* 사용중인 디바이스 */
CREATE TABLE device (
   deviceID INT NOT NULL, /* 사용디바이스 ID */
   deviceName VARCHAR2(100) NOT NULL, /* 디바이스명 */
   connectionTime DATE NOT NULL, /* 접속시간 */
   profileID INT NOT NULL /* 프로필 ID */
);

CREATE UNIQUE INDEX PK_device
   ON device (
      deviceID ASC
   );

ALTER TABLE device
   ADD
      CONSTRAINT PK_device
      PRIMARY KEY (
         deviceID
      );

/* 멤버쉽 */
CREATE TABLE membership (
   membershipID INT NOT NULL, /* 멤버쉽 ID */
   price INT NOT NULL, /* 월요금 */
   resolution VARCHAR2(100) NOT NULL, /* 해상도 */
   concurrentConnection INT NOT NULL, /* 접속자수 */
   ad INT NOT NULL, /* 광고여부 */
   audiotrackid INT NOT NULL /* 오디오 트랙 ID */
);

CREATE UNIQUE INDEX PK_membership
   ON membership (
      membershipID ASC
   );

ALTER TABLE membership
   ADD
      CONSTRAINT PK_membership
      PRIMARY KEY (
         membershipID
      );

/* 결제방식 */
CREATE TABLE payment (
   payid INT NOT NULL, /* 결제id */
   paydate DATE NOT NULL, /* 결제날짜 */
   paymethod VARCHAR2(100) NOT NULL, /* 결제수단 */
   payamount VARCHAR2(100) NOT NULL, /* 결제금액 */
   useperiod VARCHAR2(200) NOT NULL, /* 기간설명 */
   membershipID INT NOT NULL, /* 멤버쉽 ID */
   accountID INT NOT NULL /* 계정 ID */
);

CREATE UNIQUE INDEX PK_payment
   ON payment (
      payid ASC
   );

ALTER TABLE payment
   ADD
      CONSTRAINT PK_payment
      PRIMARY KEY (
         payid
      );

/* 다운로드 */
CREATE TABLE download (
   downID INT NOT NULL, /* 다운로드 ID */
   deviceID INT NOT NULL, /* 사용디바이스 ID */
   videoID INT NOT NULL /* 영상 ID */
);

CREATE UNIQUE INDEX PK_download
   ON download (
      downID ASC
   );

ALTER TABLE download
   ADD
      CONSTRAINT PK_download
      PRIMARY KEY (
         downID
      );

/* 특징별시청횟수 */
CREATE TABLE featureViewCnt (
   featureViewCntID INT NOT NULL, /* 특징횟수 ID */
   cnt INT NOT NULL, /* count */
   defaultLang VARCHAR2(100), /* 기본사용언어 */
   profileID INT NOT NULL, /* 프로필 ID */
   featureID INT /* 특징 ID */
);

CREATE UNIQUE INDEX PK_featureViewCnt
   ON featureViewCnt (
      featureViewCntID ASC
   );

ALTER TABLE featureViewCnt
   ADD
      CONSTRAINT PK_featureViewCnt
      PRIMARY KEY (
         featureViewCntID
      );

/* 장르별시청횟수 */
CREATE TABLE genreViewCnt (
   genreViewCntID INT NOT NULL, /* 장르횟수 ID */
   cnt INT NOT NULL, /* count */
   defaultLang VARCHAR2(100), /* 기본사용언어 */
   profileID INT NOT NULL, /* 프로필 ID */
   genreID INT NOT NULL /* 장르 ID */
);

CREATE UNIQUE INDEX PK_genreViewCnt
   ON genreViewCnt (
      genreViewCntID ASC
   );

ALTER TABLE genreViewCnt
   ADD
      CONSTRAINT PK_genreViewCnt
      PRIMARY KEY (
         genreViewCntID
      );

/* 콘텐츠 */
CREATE TABLE content (
   contentID INT NOT NULL, /* 콘텐츠 ID */
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

CREATE UNIQUE INDEX PK_content
   ON content (
      contentID ASC
   );

ALTER TABLE content
   ADD
      CONSTRAINT PK_content
      PRIMARY KEY (
         contentID
      );

/* 영상 */
CREATE TABLE video (
   videoID INT NOT NULL, /* 영상 ID */
   seasonNum INT, /* 시즌 번호 */
   epiNum INT, /* 에피소드 화수 */
   epiTitle VARCHAR2(150) NOT NULL, /* 에피소드 제목 */
   epiDescription VARCHAR2(1000), /* 에피소드 설명 */
   epiruntime INT NOT NULL, /* 에피소드 재생시간(분) */
   epiImageURL VARCHAR2(255) NOT NULL, /* 에피소드 썸네일 URL */
   releaseDate DATE NOT NULL, /* 공개일 */
   contentID INT NOT NULL, /* 콘텐츠 ID */
   audioLangID INT NOT NULL /* 음성언어 ID */
);

CREATE UNIQUE INDEX PK_video
   ON video (
      videoID ASC
   );

ALTER TABLE video
   ADD
      CONSTRAINT PK_video
      PRIMARY KEY (
         videoID
      );

/* 장르 */
CREATE TABLE genre (
   genreID INT NOT NULL, /* 장르 ID */
   genreName VARCHAR2(20) NOT NULL /* 장르명 */
);

CREATE UNIQUE INDEX PK_genre
   ON genre (
      genreID ASC
   );

ALTER TABLE genre
   ADD
      CONSTRAINT PK_genre
      PRIMARY KEY (
         genreID
      );

/* 장르 리스트 */
CREATE TABLE genreList (
   genreListid INT NOT NULL, /* 장르리스트 ID */
   genreID INT NOT NULL, /* 장르 ID */
   contentID INT NOT NULL /* 콘텐츠 ID */
);

CREATE UNIQUE INDEX PK_genreList
   ON genreList (
      genreListid ASC
   );

ALTER TABLE genreList
   ADD
      CONSTRAINT PK_genreList
      PRIMARY KEY (
         genreListid
      );

/* 배우 */
CREATE TABLE actor (
   actorid INT NOT NULL, /* 인물 ID */
   name VARCHAR2(255) NOT NULL, /* 인물 이름 */
   birthDate DATE NOT NULL /* 생년월일 */
);

CREATE UNIQUE INDEX PK_actor
   ON actor (
      actorid ASC
   );

ALTER TABLE actor
   ADD
      CONSTRAINT PK_actor
      PRIMARY KEY (
         actorid
      );

/* 배우들 */
CREATE TABLE actorList (
   actorListid INT NOT NULL, /* 배우리스트 ID */
   role VARCHAR2(255), /* 역할 */
   roleName VARCHAR2(255), /* 배역명 */
   contentID INT NOT NULL, /* 콘텐츠 ID */
   actorid INT NOT NULL /* 인물 ID */
);

CREATE UNIQUE INDEX PK_actorList
   ON actorList (
      actorListid ASC
   );

ALTER TABLE actorList
   ADD
      CONSTRAINT PK_actorList
      PRIMARY KEY (
         actorListid
      );

/* 오디오 트랙 */
CREATE TABLE audioTrack (
   audioTrackID INT NOT NULL, /* 오디오 트랙 ID */
   audioDescription VARCHAR2(255) /* 오디오 설명 */
);

CREATE UNIQUE INDEX PK_audioTrack
   ON audioTrack (
      audioTrackID ASC
   );

ALTER TABLE audioTrack
   ADD
      CONSTRAINT PK_audioTrack
      PRIMARY KEY (
         audioTrackID
      );

/* 트레일러 */
CREATE TABLE trailer (
   trailerID INT NOT NULL, /* 트레일러 ID */
   trailerURL VARCHAR2(255) NOT NULL, /* 트레일러 URL */
   title VARCHAR2(255) NOT NULL, /* 제목 */
   videoID INT NOT NULL, /* 영상 ID */
   audioLangID INT NOT NULL /* 음성언어 ID */
);

CREATE UNIQUE INDEX PK_trailer
   ON trailer (
      trailerID ASC
   );

ALTER TABLE trailer
   ADD
      CONSTRAINT PK_trailer
      PRIMARY KEY (
         trailerID
      );

/* 사용자 평가 */
CREATE TABLE userRating (
   ratingID INT NOT NULL, /* 평가 ID */
   ratingType INT NOT NULL, /* 평가 유형 */
   ratingTime DATE NOT NULL, /* 평가 시각 */
   profileID INT NOT NULL, /* 프로필 ID */
   contentID INT NOT NULL /* 콘텐츠 ID */
);

CREATE UNIQUE INDEX PK_userRating
   ON userRating (
      ratingID ASC
   );

ALTER TABLE userRating
   ADD
      CONSTRAINT PK_userRating
      PRIMARY KEY (
         ratingID
      );

/* 특징 */
CREATE TABLE feature (
   featureID INT NOT NULL, /* 특징 ID */
   featureName VARCHAR2(50) NOT NULL /* 특징명 */
);

CREATE UNIQUE INDEX PK_feature
   ON feature (
      featureID ASC
   );

ALTER TABLE feature
   ADD
      CONSTRAINT PK_feature
      PRIMARY KEY (
         featureID
      );

/* 국가 */
CREATE TABLE Country (
   countryID INT NOT NULL, /* 국가 ID */
   baseLanguege VARCHAR2(30) NOT NULL, /* 기본언어 */
   maxRate VARCHAR2(20) /* 최고시청등급 */
);

CREATE UNIQUE INDEX PK_Country
   ON Country (
      countryID ASC
   );

ALTER TABLE Country
   ADD
      CONSTRAINT PK_Country
      PRIMARY KEY (
         countryID
      );

/* 시청 등급 */
CREATE TABLE contentRating (
   contentRatingID INT NOT NULL, /* 시청 등급 ID */
   ratingLabel VARCHAR2(50) NOT NULL, /* 시청 등급 */
   contentID INT NOT NULL, /* 콘텐츠 ID */
   countryID INT NOT NULL /* 국가 ID */
);

CREATE UNIQUE INDEX PK_contentRating
   ON contentRating (
      contentRatingID ASC
   );

ALTER TABLE contentRating
   ADD
      CONSTRAINT PK_contentRating
      PRIMARY KEY (
         contentRatingID
      );

/* 크리에이터 */
CREATE TABLE creator (
   creatorID INT NOT NULL, /* 크리에이터 ID */
   creatorName VARCHAR2(255) NOT NULL /* 크리에이터 이름 */
);

CREATE UNIQUE INDEX PK_creator
   ON creator (
      creatorID ASC
   );

ALTER TABLE creator
   ADD
      CONSTRAINT PK_creator
      PRIMARY KEY (
         creatorID
      );

/* 자막 */
CREATE TABLE subtitle (
   subtitleID INT NOT NULL, /* 자막 ID */
   subtitleFileURL VARCHAR2(255), /* 자막 파일 URL */
   screenDiscription VARCHAR2(30), /* 화면해설 */
   videoID INT NOT NULL, /* 영상 ID */
   subtitleSettingID INT NOT NULL /* 자막표시 ID */
);

CREATE UNIQUE INDEX PK_subtitle
   ON subtitle (
      subtitleID ASC
   );

ALTER TABLE subtitle
   ADD
      CONSTRAINT PK_subtitle
      PRIMARY KEY (
         subtitleID
      );

/* 콘텐츠 제작자들 */
CREATE TABLE creatorList (
   creatorListid INT NOT NULL, /* 크리에이터리스트 ID */
   contentID INT NOT NULL, /* 콘텐츠 ID */
   creatorID INT NOT NULL /* 크리에이터 ID */
);

CREATE UNIQUE INDEX PK_creatorList
   ON creatorList (
      creatorListid ASC
   );

ALTER TABLE creatorList
   ADD
      CONSTRAINT PK_creatorList
      PRIMARY KEY (
         creatorListid
      );

/* 특징 리스트 */
CREATE TABLE featureList (
   featureListid INT NOT NULL, /* 특징리스트 ID */
   featureID INT NOT NULL, /* 특징 ID */
   contentID INT NOT NULL /* 콘텐츠 ID */
);

CREATE UNIQUE INDEX PK_featureList
   ON featureList (
      featureListid ASC
   );

ALTER TABLE featureList
   ADD
      CONSTRAINT PK_featureList
      PRIMARY KEY (
         featureListid
      );

/* 음성언어 */
CREATE TABLE audioLang (
   audioLangID INT NOT NULL, /* 음성언어 ID */
   Language VARCHAR2(30) NOT NULL, /* 언어 */
   audioTrackID INT NOT NULL /* 오디오 트랙 ID */
);

CREATE UNIQUE INDEX PK_audioLang
   ON audioLang (
      audioLangID ASC
   );

ALTER TABLE audioLang
   ADD
      CONSTRAINT PK_audioLang
      PRIMARY KEY (
         audioLangID
      );

ALTER TABLE profile
   ADD
      CONSTRAINT FK_account_TO_profile
      FOREIGN KEY (
         accountID
      )
      REFERENCES account (
         accountID
      );

ALTER TABLE profile
   ADD
      CONSTRAINT FK_subtitleSetting_TO_profile
      FOREIGN KEY (
         subtitleSettingID
      )
      REFERENCES subtitleSetting (
         subtitleSettingID
      );

ALTER TABLE profile
   ADD
      CONSTRAINT FK_Country_TO_profile
      FOREIGN KEY (
         countryID
      )
      REFERENCES Country (
         countryID
      );

ALTER TABLE viewingHistory
   ADD
      CONSTRAINT FK_profile_TO_viewingHistory
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE viewingHistory
   ADD
      CONSTRAINT FK_video_TO_viewingHistory
      FOREIGN KEY (
         videoID
      )
      REFERENCES video (
         videoID
      );

ALTER TABLE wishList
   ADD
      CONSTRAINT FK_profile_TO_wishList
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE wishList
   ADD
      CONSTRAINT FK_video_TO_wishList
      FOREIGN KEY (
         videoID
      )
      REFERENCES video (
         videoID
      );

ALTER TABLE device
   ADD
      CONSTRAINT FK_profile_TO_device
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE membership
   ADD
      CONSTRAINT FK_audioTrack_TO_membership
      FOREIGN KEY (
         audiotrackid
      )
      REFERENCES audioTrack (
         audioTrackID
      );

ALTER TABLE payment
   ADD
      CONSTRAINT FK_membership_TO_payment
      FOREIGN KEY (
         membershipID
      )
      REFERENCES membership (
         membershipID
      );

ALTER TABLE payment
   ADD
      CONSTRAINT FK_account_TO_payment
      FOREIGN KEY (
         accountID
      )
      REFERENCES account (
         accountID
      );

ALTER TABLE download
   ADD
      CONSTRAINT FK_device_TO_download
      FOREIGN KEY (
         deviceID
      )
      REFERENCES device (
         deviceID
      );

ALTER TABLE download
   ADD
      CONSTRAINT FK_video_TO_download
      FOREIGN KEY (
         videoID
      )
      REFERENCES video (
         videoID
      );

ALTER TABLE featureViewCnt
   ADD
      CONSTRAINT FK_profile_TO_featureViewCnt
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE featureViewCnt
   ADD
      CONSTRAINT FK_feature_TO_featureViewCnt
      FOREIGN KEY (
         featureID
      )
      REFERENCES feature (
         featureID
      );

ALTER TABLE genreViewCnt
   ADD
      CONSTRAINT FK_profile_TO_genreViewCnt
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE genreViewCnt
   ADD
      CONSTRAINT FK_genre_TO_genreViewCnt
      FOREIGN KEY (
         genreID
      )
      REFERENCES genre (
         genreID
      );

ALTER TABLE video
   ADD
      CONSTRAINT FK_content_TO_video
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE video
   ADD
      CONSTRAINT FK_audioLang_TO_video
      FOREIGN KEY (
         audioLangID
      )
      REFERENCES audioLang (
         audioLangID
      );

ALTER TABLE genreList
   ADD
      CONSTRAINT FK_genre_TO_genreList
      FOREIGN KEY (
         genreID
      )
      REFERENCES genre (
         genreID
      );

ALTER TABLE genreList
   ADD
      CONSTRAINT FK_content_TO_genreList
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE actorList
   ADD
      CONSTRAINT FK_content_TO_actorList
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE actorList
   ADD
      CONSTRAINT FK_actor_TO_actorList
      FOREIGN KEY (
         actorid
      )
      REFERENCES actor (
         actorid
      );

ALTER TABLE trailer
   ADD
      CONSTRAINT FK_video_TO_trailer
      FOREIGN KEY (
         videoID
      )
      REFERENCES video (
         videoID
      );

ALTER TABLE trailer
   ADD
      CONSTRAINT FK_audioLang_TO_trailer
      FOREIGN KEY (
         audioLangID
      )
      REFERENCES audioLang (
         audioLangID
      );

ALTER TABLE userRating
   ADD
      CONSTRAINT FK_content_TO_userRating
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE userRating
   ADD
      CONSTRAINT FK_profile_TO_userRating
      FOREIGN KEY (
         profileID
      )
      REFERENCES profile (
         profileID
      );

ALTER TABLE contentRating
   ADD
      CONSTRAINT FK_content_TO_contentRating
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE contentRating
   ADD
      CONSTRAINT FK_Country_TO_contentRating
      FOREIGN KEY (
         countryID
      )
      REFERENCES Country (
         countryID
      );

ALTER TABLE subtitle
   ADD
      CONSTRAINT FK_video_TO_subtitle
      FOREIGN KEY (
         videoID
      )
      REFERENCES video (
         videoID
      );

ALTER TABLE subtitle
   ADD
      CONSTRAINT FK_subtitleSetting_TO_subtitle
      FOREIGN KEY (
         subtitleSettingID
      )
      REFERENCES subtitleSetting (
         subtitleSettingID
      );

ALTER TABLE creatorList
   ADD
      CONSTRAINT FK_content_TO_creatorList
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE creatorList
   ADD
      CONSTRAINT FK_creator_TO_creatorList
      FOREIGN KEY (
         creatorID
      )
      REFERENCES creator (
         creatorID
      );

ALTER TABLE featureList
   ADD
      CONSTRAINT FK_feature_TO_featureList
      FOREIGN KEY (
         featureID
      )
      REFERENCES feature (
         featureID
      );

ALTER TABLE featureList
   ADD
      CONSTRAINT FK_content_TO_featureList
      FOREIGN KEY (
         contentID
      )
      REFERENCES content (
         contentID
      );

ALTER TABLE audioLang
   ADD
      CONSTRAINT FK_audioTrack_TO_audioLang
      FOREIGN KEY (
         audioTrackID
      )
      REFERENCES audioTrack (
         audioTrackID
      );


-- 시퀀스 드랍
DROP SEQUENCE account_seq;
DROP SEQUENCE profile_seq;
DROP SEQUENCE subtitleSetting_seq;
DROP SEQUENCE viewingHistory_seq;
DROP SEQUENCE wishList_seq;
DROP SEQUENCE device_seq;
DROP SEQUENCE membership_seq;
DROP SEQUENCE payment_seq;
DROP SEQUENCE download_seq;
DROP SEQUENCE featureViewCnt_seq;
DROP SEQUENCE genreViewCnt_seq;
DROP SEQUENCE content_seq;
DROP SEQUENCE video_seq;
DROP SEQUENCE genre_seq;
DROP SEQUENCE genreList_seq;
DROP SEQUENCE actor_seq;
DROP SEQUENCE actorList_seq;
DROP SEQUENCE audioTrack_seq;
DROP SEQUENCE trailer_seq;
DROP SEQUENCE userRating_seq;
DROP SEQUENCE feature_seq;
DROP SEQUENCE Country_seq;
DROP SEQUENCE contentRating_seq;
DROP SEQUENCE creator_seq;
DROP SEQUENCE subtitle_seq;
DROP SEQUENCE creatorList_seq;
DROP SEQUENCE featureList_seq;
DROP SEQUENCE audioLang_seq;

-- account 테이블용 시퀀스
CREATE SEQUENCE account_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- profile 테이블용 시퀀스
CREATE SEQUENCE profile_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- subtitleSetting 테이블용 시퀀스
CREATE SEQUENCE subtitleSetting_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- viewingHistory 테이블용 시퀀스
CREATE SEQUENCE viewingHistory_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- wishList 테이블용 시퀀스
CREATE SEQUENCE wishList_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- device 테이블용 시퀀스
CREATE SEQUENCE device_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- membership 테이블용 시퀀스
CREATE SEQUENCE membership_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- payment 테이블용 시퀀스
CREATE SEQUENCE payment_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- download 테이블용 시퀀스
CREATE SEQUENCE download_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- featureViewCnt 테이블용 시퀀스
CREATE SEQUENCE featureViewCnt_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- genreViewCnt 테이블용 시퀀스
CREATE SEQUENCE genreViewCnt_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- content 테이블용 시퀀스
CREATE SEQUENCE content_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- video 테이블용 시퀀스
CREATE SEQUENCE video_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- genre 테이블용 시퀀스
CREATE SEQUENCE genre_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- genreList 테이블용 시퀀스
CREATE SEQUENCE genreList_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- actor 테이블용 시퀀스
CREATE SEQUENCE actor_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- actorList 테이블용 시퀀스
CREATE SEQUENCE actorList_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- audioTrack 테이블용 시퀀스
CREATE SEQUENCE audioTrack_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- trailer 테이블용 시퀀스
CREATE SEQUENCE trailer_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- userRating 테이블용 시퀀스
CREATE SEQUENCE userRating_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- feature 테이블용 시퀀스
CREATE SEQUENCE feature_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Country 테이블용 시퀀스
CREATE SEQUENCE Country_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- contentRating 테이블용 시퀀스
CREATE SEQUENCE contentRating_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- creator 테이블용 시퀀스
CREATE SEQUENCE creator_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- subtitle 테이블용 시퀀스
CREATE SEQUENCE subtitle_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- creatorList 테이블용 시퀀스
CREATE SEQUENCE creatorList_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- featureList 테이블용 시퀀스
CREATE SEQUENCE featureList_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- audioLang 테이블용 시퀀스
CREATE SEQUENCE audioLang_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;






DROP trigger trg_account_seq;

-- account 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_account_seq
BEFORE INSERT ON account
FOR EACH ROW
BEGIN
  SELECT account_seq.NEXTVAL
  INTO :NEW.accountID
  FROM dual;
END;
/
DROP trigger trg_profile_seq;
-- profile 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_profile_seq
BEFORE INSERT ON profile
FOR EACH ROW
BEGIN
  SELECT profile_seq.NEXTVAL
  INTO :NEW.profileID
  FROM dual;
END;
/
-- subtitleSetting 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_subtitleSetting_seq
BEFORE INSERT ON subtitleSetting
FOR EACH ROW
BEGIN
  SELECT subtitleSetting_seq.NEXTVAL
  INTO :NEW.subtitleSettingID
  FROM dual;
END;
/
-- viewingHistory 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_viewingHistory_seq
BEFORE INSERT ON viewingHistory
FOR EACH ROW
BEGIN
  SELECT viewingHistory_seq.NEXTVAL
  INTO :NEW.viewingHistoryID
  FROM dual;
END;
/
-- wishList 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_wishList_seq
BEFORE INSERT ON wishList
FOR EACH ROW
BEGIN
  SELECT wishList_seq.NEXTVAL
  INTO :NEW.wishListID
  FROM dual;
END;
/
-- device 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_device_seq
BEFORE INSERT ON device
FOR EACH ROW
BEGIN
  SELECT device_seq.NEXTVAL
  INTO :NEW.deviceID
  FROM dual;
END;
/
-- membership 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_membership_seq
BEFORE INSERT ON membership
FOR EACH ROW
BEGIN
  SELECT membership_seq.NEXTVAL
  INTO :NEW.membershipID
  FROM dual;
END;
/
-- payment 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_payment_seq
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
  SELECT payment_seq.NEXTVAL
  INTO :NEW.payid
  FROM dual;
END;
/
-- download 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_download_seq
BEFORE INSERT ON download
FOR EACH ROW
BEGIN
  SELECT download_seq.NEXTVAL
  INTO :NEW.downID
  FROM dual;
END;
/
-- featureViewCnt 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_featureViewCnt_seq
BEFORE INSERT ON featureViewCnt
FOR EACH ROW
BEGIN
  SELECT featureViewCnt_seq.NEXTVAL
  INTO :NEW.featureViewCntID
  FROM dual;
END;
/
-- genreViewCnt 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_genreViewCnt_seq
BEFORE INSERT ON genreViewCnt
FOR EACH ROW
BEGIN
  SELECT genreViewCnt_seq.NEXTVAL
  INTO :NEW.genreViewCntID
  FROM dual;
END;
/
-- content 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_content_seq
BEFORE INSERT ON content
FOR EACH ROW
BEGIN
  SELECT content_seq.NEXTVAL
  INTO :NEW.contentID
  FROM dual;
END;
/
-- video 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_video_seq
BEFORE INSERT ON video
FOR EACH ROW
BEGIN
  SELECT video_seq.NEXTVAL
  INTO :NEW.videoID
  FROM dual;
END;
/
-- genre 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_genre_seq
BEFORE INSERT ON genre
FOR EACH ROW
BEGIN
  SELECT genre_seq.NEXTVAL
  INTO :NEW.genreID
  FROM dual;
END;
/
-- genreList 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_genreList_seq
BEFORE INSERT ON genreList
FOR EACH ROW
BEGIN
  SELECT genreList_seq.NEXTVAL
  INTO :NEW.genreListID
  FROM dual;
END;
/
-- actor 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_actor_seq
BEFORE INSERT ON actor
FOR EACH ROW
BEGIN
  SELECT actor_seq.NEXTVAL
  INTO :NEW.actorID
  FROM dual;
END;
/
-- actorList 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_actorList_seq
BEFORE INSERT ON actorList
FOR EACH ROW
BEGIN
  SELECT actorList_seq.NEXTVAL
  INTO :NEW.actorListID
  FROM dual;
END;
/
-- audioTrack 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_audioTrack_seq
BEFORE INSERT ON audioTrack
FOR EACH ROW
BEGIN
  SELECT audioTrack_seq.NEXTVAL
  INTO :NEW.audioTrackID
  FROM dual;
END;
/
-- trailer 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_trailer_seq
BEFORE INSERT ON trailer
FOR EACH ROW
BEGIN
  SELECT trailer_seq.NEXTVAL
  INTO :NEW.trailerID
  FROM dual;
END;
/
-- userRating 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_userRating_seq
BEFORE INSERT ON userRating
FOR EACH ROW
BEGIN
  SELECT userRating_seq.NEXTVAL
  INTO :NEW.ratingID
  FROM dual;
END;
/
-- feature 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_feature_seq
BEFORE INSERT ON feature
FOR EACH ROW
BEGIN
  SELECT feature_seq.NEXTVAL
  INTO :NEW.featureID
  FROM dual;
END;
/
-- Country 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_Country_seq
BEFORE INSERT ON Country
FOR EACH ROW
BEGIN
  SELECT country_seq.NEXTVAL
  INTO :NEW.countryID
  FROM dual;
END;
/
-- contentRating 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_contentRating_seq
BEFORE INSERT ON contentRating
FOR EACH ROW
BEGIN
  SELECT contentRating_seq.NEXTVAL
  INTO :NEW.contentRatingID
  FROM dual;
END;
/
-- creator 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_creator_seq
BEFORE INSERT ON creator
FOR EACH ROW
BEGIN
  SELECT creator_seq.NEXTVAL
  INTO :NEW.creatorID
  FROM dual;
END;
/
-- subtitle 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_subtitle_seq
BEFORE INSERT ON subtitle
FOR EACH ROW
BEGIN
  SELECT subtitle_seq.NEXTVAL
  INTO :NEW.subtitleID
  FROM dual;
END;
/
-- creatorList 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_creatorList_seq
BEFORE INSERT ON creatorList
FOR EACH ROW
BEGIN
  SELECT creatorList_seq.NEXTVAL
  INTO :NEW.creatorListID
  FROM dual;
END;
/
-- featureList 테이블용 시퀀스 트리거
CREATE OR REPLACE TRIGGER trg_featureList_seq
BEFORE INSERT ON featureList
FOR EACH ROW
BEGIN
  SELECT featureList_seq.NEXTVAL
  INTO :NEW.featureListID
  FROM dual;
END;
/
-- audioLang 테이블 시퀀스용 트리거
CREATE OR REPLACE TRIGGER trg_audioLang_seq
BEFORE INSERT ON audioLang
FOR EACH ROW
BEGIN
  SELECT audioLang_seq.NEXTVAL
  INTO :NEW.audioLangID
  FROM dual;
END;
/
-- 이메일 유니크 조건
ALTER TABLE ACCOUNT
ADD CONSTRAINT uq_account_email UNIQUE (email);
-- 전화번호 유니크 조건
ALTER TABLE ACCOUNT
ADD CONSTRAINT uq_account_phoneNumber UNIQUE (phoneNumber);
-- 장르명 유니크 조건
ALTER TABLE genre
ADD CONSTRAINT uq_genre_genreName UNIQUE (genreName);
-- 특징명 유니크 조건
ALTER TABLE feature
ADD CONSTRAINT uq_feature_featureName UNIQUE (featureName);


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

-- 목록 확인
SELECT
    trigger_name,
    table_owner,
    table_name,
    triggering_event,
    status
FROM
    user_triggers
ORDER BY
    trigger_name;

-- 시퀀스 목록 확인
SELECT
    sequence_name,
    min_value,
    max_value,
    increment_by,
    last_number
FROM
    user_sequences
ORDER BY
    sequence_name;
