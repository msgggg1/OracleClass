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



-- =========================================
-- 데이터 초기화 (DELETE 문)
-- 외래 키 제약 조건을 고려하여 역순으로 삭제
-- =========================================

DELETE FROM download;
DELETE FROM subtitle;
DELETE FROM trailer;
DELETE FROM viewingHistory;
DELETE FROM wishList;
DELETE FROM userRating;
DELETE FROM featureViewCnt;
DELETE FROM genreViewCnt;
DELETE FROM device;
DELETE FROM payment;
DELETE FROM actorList;
DELETE FROM genreList;
DELETE FROM contentRating;
DELETE FROM creatorList;
DELETE FROM featureList;
DELETE FROM video;
DELETE FROM profile;
DELETE FROM audioLang;
DELETE FROM membership;
DELETE FROM content;
DELETE FROM account; -- account 데이터도 삭제
DELETE FROM subtitleSetting;
DELETE FROM audioTrack;
DELETE FROM genre;
DELETE FROM actor;
DELETE FROM feature;
DELETE FROM Country;
DELETE FROM creator;

COMMIT; -- 삭제 트랜잭션 커밋

-- =========================================
--  INSERT 문 (수정된 테이블 구조 반영)
-- =========================================

-- 1. 의존성이 적거나 없는 테이블

-- account (계정)
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('alice@example.com', '010-1234-5678', 'Alice2024!', 'F', '123456', 'Y');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('bob@example.com', '010-2345-6789', 'Bob#Secure1', 'M', '654321', 'N');
INSERT INTO account (email, phoneNumber, pw, gender, profilepw, adultverification) VALUES ('charlie@netflix.com', '010-3456-7890', 'C#h@rlie99', 'M', '112233', 'Y');

-- subtitleSetting (자막 설정)
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Arial', 100, 'Drop Shadow');
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('Times New Roman', 75, NULL);
INSERT INTO subtitleSetting (font, fontSize, fontEffect) VALUES ('돋움', 125, 'Outline');

-- audioTrack (오디오 트랙)
INSERT INTO audioTrack (audioDescription) VALUES ('Stereo');
INSERT INTO audioTrack (audioDescription) VALUES ('5.1 Surround');
INSERT INTO audioTrack (audioDescription) VALUES ('Dolby Atmos');
INSERT INTO audioTrack (audioDescription) VALUES ('Audio Description'); -- (음성 해설)

-- genre (장르)
INSERT INTO genre (genreName) VALUES ('액션');
INSERT INTO genre (genreName) VALUES ('코미디');
INSERT INTO genre (genreName) VALUES ('드라마');
INSERT INTO genre (genreName) VALUES ('SF');
INSERT INTO genre (genreName) VALUES ('스릴러');
INSERT INTO genre (genreName) VALUES ('로맨스');
INSERT INTO genre (genreName) VALUES ('다큐멘터리');

-- actor (배우)
INSERT INTO actor (name, birthDate) VALUES ('Tom Hanks', TO_DATE('1956-07-09', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('Scarlett Johansson', TO_DATE('1984-11-22', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('송강호', TO_DATE('1967-01-17', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('김고은', TO_DATE('1991-07-02', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('Leonardo DiCaprio', TO_DATE('1974-11-11', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('Elliot Page', TO_DATE('1987-02-21', 'YYYY-MM-DD'));
INSERT INTO actor (name, birthDate) VALUES ('Millie Bobby Brown', TO_DATE('2004-02-19', 'YYYY-MM-DD'));

-- feature (특징)
INSERT INTO feature (featureName) VALUES ('시각적으로 놀라운');
INSERT INTO feature (featureName) VALUES ('비평가들의 찬사');
INSERT INTO feature (featureName) VALUES ('기발한');
INSERT INTO feature (featureName) VALUES ('현실 왜곡/복잡한');
INSERT INTO feature (featureName) VALUES ('감동적인');

-- Country (국가)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Korean', 19); -- (한국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('English (US)', 18); -- (미국)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('Japanese', 18); -- (일본)
INSERT INTO Country (baseLanguege, maxRate) VALUES ('English (UK)', 18); -- (영국)

-- creator (제작자)
INSERT INTO creator (creatorName) VALUES ('봉준호');
INSERT INTO creator (creatorName) VALUES ('크리스토퍼 놀란');
INSERT INTO creator (creatorName) VALUES ('그레타 거윅');
INSERT INTO creator (creatorName) VALUES ('스티븐 스필버그');
INSERT INTO creator (creatorName) VALUES ('더퍼 형제');

-- membership (멤버십, audioTrack 테이블에 의존) -- 컬럼명 audiotrackid 로 수정됨
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (5500, '720p', 1, 1, 1); -- (광고형 베이식, 스테레오(A1))
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (9500, '1080p', 2, 0, 2); -- (스탠다드, 5.1 서라운드(A2))
INSERT INTO membership (price, resolution, concurrentConnection, ad, audiotrackid) VALUES (13500, '4K+HDR', 4, 0, 3); -- (프리미엄, 돌비 애트모스(A3))

-- audioLang (음성 언어, audioTrack 테이블에 의존)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('한국어', 1); -- (한국어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 2); -- (영어 5.1 서라운드 - A2)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('일본어', 1); -- (일본어 스테레오 - A1)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('한국어', 4); -- (한국어 음성 해설 - A4)
INSERT INTO audioLang (Language, audioTrackID) VALUES ('영어', 3); -- (영어 돌비 애트모스 - A3)

-- 2. 콘텐츠 및 관련 연결 테이블

-- content (콘텐츠)
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '기생충', 'Parasite', '가난한 가족이 부유한 가족의 집에 고용되기 위해 계획을 세우는 이야기.', TO_DATE('2019-05-30', 'YYYY-MM-DD'), 2019, TO_DATE('2019-06-05', 'YYYY-MM-DD'), 132, 'thumb/parasite.jpg', 'main/parasite.jpg', 'Korean', '대한민국', SYSDATE, '전세계', '4K'); -- (영화)
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Series', '기묘한 이야기', 'Stranger Things', '어린 친구들이 초자연적인 힘과 비밀스러운 정부 실험을 목격하는 이야기.', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2016, TO_DATE('2016-07-15', 'YYYY-MM-DD'), 50, 'thumb/stranger.jpg', 'main/stranger.jpg', 'English', '미국', SYSDATE, '전세계', '4K+HDR'); -- (시리즈)
INSERT INTO content (contentType, title, originTitle, description, releaseDate, releaseYear, publicDate, runtime, thumbnailURL, mainImage, originLang, productionCountry, registeredAt, availableCountry, videoQuality)
VALUES ('Movie', '인셉션', 'Inception', '꿈 공유 기술을 사용하여 기업 비밀을 훔치는 도둑의 이야기.', TO_DATE('2010-07-16', 'YYYY-MM-DD'), 2010, TO_DATE('2010-07-21', 'YYYY-MM-DD'), 148, 'thumb/inception.jpg', 'main/inception.jpg', 'English', '미국', SYSDATE, '전세계', '1080p'); -- (영화)

-- genreList (장르 목록, genre와 content 연결)
INSERT INTO genreList (genreID, contentID) VALUES (3, 1); -- 드라마(G3), 기생충(C1)
INSERT INTO genreList (genreID, contentID) VALUES (5, 1); -- 스릴러(G5), 기생충(C1)
INSERT INTO genreList (genreID, contentID) VALUES (4, 2); -- SF(G4), 기묘한 이야기(C2)
INSERT INTO genreList (genreID, contentID) VALUES (5, 2); -- 스릴러(G5), 기묘한 이야기(C2)
INSERT INTO genreList (genreID, contentID) VALUES (1, 3); -- 액션(G1), 인셉션(C3)
INSERT INTO genreList (genreID, contentID) VALUES (4, 3); -- SF(G4), 인셉션(C3)
INSERT INTO genreList (genreID, contentID) VALUES (5, 3); -- 스릴러(G5), 인셉션(C3)

-- actorList (배우 목록, actor와 content 연결)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '김기택', 1, 3); -- 송강호(A3) in 기생충(C1)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '코브', 3, 5); -- 레오나르도 디카프리오(A5) in 인셉션(C3)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('조연', '아리아드네', 3, 6); -- 엘리엇 페이지(A6) in 인셉션(C3)
INSERT INTO actorList (role, roleName, contentID, actorid) VALUES ('주연', '일레븐', 2, 7); -- 밀리 바비 브라운(A7) in 기묘한 이야기(C2)

-- contentRating (콘텐츠 등급, content와 Country 연결)
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('18', 1, 1); -- 기생충(C1), 한국(Co1), 18세 이상
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('R', 1, 2); -- 기생충(C1), 미국(Co2), R등급
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('TV-14', 2, 2); -- 기묘한 이야기(C2), 미국(Co2), TV-14
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('15', 2, 4); -- 기묘한 이야기(C2), 영국(Co4), 15세 이상
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('PG-13', 3, 2); -- 인셉션(C3), 미국(Co2), PG-13
INSERT INTO contentRating (ratingLabel, contentID, countryID) VALUES ('12', 3, 4); -- 인셉션(C3), 영국(Co4), 12세 이상

-- creatorList (제작자 목록, creator와 content 연결)
INSERT INTO creatorList (contentID, creatorID) VALUES (1, 1); -- 기생충(C1), 봉준호(Cr1)
INSERT INTO creatorList (contentID, creatorID) VALUES (3, 2); -- 인셉션(C3), 크리스토퍼 놀란(Cr2)
INSERT INTO creatorList (contentID, creatorID) VALUES (2, 5); -- 기묘한 이야기(C2), 더퍼 형제(Cr5)

-- featureList (특징 목록, feature와 content 연결)
INSERT INTO featureList (featureID, contentID) VALUES (2, 1); -- 비평가들의 찬사(F2), 기생충(C1)
INSERT INTO featureList (featureID, contentID) VALUES (4, 3); -- 현실 왜곡/복잡한(F4), 인셉션(C3)
INSERT INTO featureList (featureID, contentID) VALUES (1, 3); -- 시각적으로 놀라운(F1), 인셉션(C3)
INSERT INTO featureList (featureID, contentID) VALUES (5, 2); -- 감동적인(F5), 기묘한 이야기(C2)

-- 3. 비디오 (에피소드/영화), content 및 audioLang 테이블에 의존

-- video (비디오)
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '기생충', '영화 기생충 전체 영상', 132, 'epi/parasite.jpg', TO_DATE('2019-06-05', 'YYYY-MM-DD'), 1, 1); -- (기생충 영화(C1), 한국어 스테레오(AL1))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 1, 'Chapter One: The Vanishing of Will Byers', '어린 소년 윌 바이어스가 사라지다.', 47, 'epi/st_s1e1.jpg', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2, 2); -- (기묘한 이야기(C2) 시즌1 1화, 영어 5.1(AL2))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (1, 2, 'Chapter Two: The Weirdo on Maple Street', '소년들이 메이플가의 이상한 소녀를 발견하다.', 55, 'epi/st_s1e2.jpg', TO_DATE('2016-07-15', 'YYYY-MM-DD'), 2, 2); -- (기묘한 이야기(C2) 시즌1 2화, 영어 5.1(AL2))
INSERT INTO video (seasonNum, epiNum, epiTitle, epiDescription, epiruntime, epiImageURL, releaseDate, contentID, audioLangID)
VALUES (NULL, NULL, '인셉션', '영화 인셉션 전체 영상', 148, 'epi/inception.jpg', TO_DATE('2010-07-21', 'YYYY-MM-DD'), 3, 5); -- (인셉션 영화(C3), 영어 돌비 애트모스(AL5))

-- 4. 사용자 프로필 관련 테이블 (account, subtitleSetting, Country, video, feature, genre 테이블에 의존)

-- profile (프로필, account, subtitleSetting, Country 테이블에 의존)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('앨리스_메인', 'img/alice1.png', NULL, 1, 1, 1); -- (앨리스(Acc1), Arial 자막(S1), 한국(Co1))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('앨리스_키즈', 'img/alice_kid.png', '12', 1, 3, 1); -- (앨리스(Acc1), 돋움 자막(S3), 한국(Co1), 12세 이상 제한)
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('밥_액션팬', 'img/bob.png', NULL, 2, 2, 2); -- (밥(Acc2), Times New Roman 자막(S2), 미국(Co2))
INSERT INTO profile (nickname, profileimage, accessRestriction, accountID, subtitleSettingID, countryID)
VALUES ('찰리1', NULL, NULL, 3, 1, 2); -- (찰리(Acc3), Arial 자막(S1), 미국(Co2))

-- payment (결제 정보, membership, account 테이블에 의존)
INSERT INTO payment (paydate, paymethod, payamount, useperiod, membershipID, accountID)
VALUES (SYSDATE, '신용카드 ****1234', '13500', '2025-04-08 ~ 2025-05-07', 3, 1); -- 앨리스(Acc1), 프리미엄(M3) 결제
INSERT INTO payment (paydate, paymethod, payamount, useperiod, membershipID, accountID)
VALUES (TO_DATE('2025-03-20', 'YYYY-MM-DD'), 'PayPal bob@example.com', '9500', '2025-03-20 ~ 2025-04-19', 2, 2); -- 밥(Acc2), 스탠다드(M2) 결제
INSERT INTO payment (paydate, paymethod, payamount, useperiod, membershipID, accountID)
VALUES (SYSDATE, '휴대폰 결제', '5500', '2025-04-01 ~ 2025-04-30', 1, 3); -- 찰리(Acc3), 광고형 베이식(M1) 결제

-- device (사용 기기, profile 테이블에 의존)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('삼성 스마트 TV', SYSDATE, 1); -- (앨리스_메인(P1) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('앨리스 아이폰 14', SYSDATE, 1); -- (앨리스_메인(P1) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('밥 윈도우 PC', TO_DATE('2025-04-08 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3); -- (밥_액션팬(P3) 기기)
INSERT INTO device (deviceName, connectionTime, profileID)
VALUES ('아이패드 에어', SYSDATE, 2); -- (앨리스_키즈(P2) 기기)

-- viewingHistory (시청 기록, profile, video 테이블에 의존)
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('N', SYSDATE, 7200, 1, 1); -- 앨리스_메인(P1)이 기생충(V1) 2시간(7200초) 시청, 완료 안함.
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('Y', TO_DATE('2025-04-07', 'YYYY-MM-DD'), 2820, 3, 2); -- 밥_액션팬(P3)이 기묘한 이야기 S1E1(V2) 완료 (47분 = 2820초).
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('N', SYSDATE, 1800, 3, 3); -- 밥_액션팬(P3)이 기묘한 이야기 S1E2(V3) 30분(1800초) 시청 중.
INSERT INTO viewingHistory (isCompleted, lastViewat, totalViewingTime, profileID, videoID)
VALUES ('Y', TO_DATE('2025-04-02', 'YYYY-MM-DD'), 8880, 4, 4); -- 찰리1(P4)이 인셉션(V4) 완료 (148분 = 8880초).

-- wishList (찜 목록, profile, video 테이블에 의존) -- 컬럼명 videoID 로 수정됨
INSERT INTO wishList (profileID, videoID) VALUES (1, 4); -- 앨리스_메인(P1)이 인셉션(V4) 찜.
INSERT INTO wishList (profileID, videoID) VALUES (1, 2); -- 앨리스_메인(P1)이 기묘한 이야기 S1E1(V2) 찜.
INSERT INTO wishList (profileID, videoID) VALUES (3, 1); -- 밥_액션팬(P3)이 기생충(V1) 찜.

-- userRating (사용자 평가, content, profile 테이블에 의존)
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (1, SYSDATE, 1, 1); -- 앨리스_메인(P1)이 기생충(C1) 좋아요(1) 평가. (1=좋아요, 0=싫어요 가정)
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (1, TO_DATE('2025-04-07', 'YYYY-MM-DD'), 3, 2); -- 밥_액션팬(P3)이 기묘한 이야기(C2) 좋아요(1) 평가.
INSERT INTO userRating (ratingType, ratingTime, profileID, contentID)
VALUES (0, SYSDATE, 1, 3); -- 앨리스_메인(P1)이 인셉션(C3) 싫어요(0) 평가.

-- featureViewCnt (특징별 시청 횟수, profile, feature 테이블에 의존)
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID)
VALUES (5, 'Korean', 1, 2); -- 앨리스_메인(P1)이 비평가 찬사(F2) 콘텐츠 5개 시청. 기본 언어 한국어.
INSERT INTO featureViewCnt (cnt, defaultLang, profileID, featureID)
VALUES (10, 'English', 3, 1); -- 밥_액션팬(P3)이 시각적으로 놀라운(F1) 콘텐츠 10개 시청. 기본 언어 영어.

-- genreViewCnt (장르별 시청 횟수, profile, genre 테이블에 의존)
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (15, 'Korean', 1, 3); -- 앨리스_메인(P1)이 드라마(G3) 콘텐츠 15개 시청. 기본 언어 한국어.
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (20, 'English', 3, 1); -- 밥_액션팬(P3)이 액션(G1) 콘텐츠 20개 시청. 기본 언어 영어.
INSERT INTO genreViewCnt (cnt, defaultLang, profileID, genreID)
VALUES (8, 'English', 3, 4); -- 밥_액션팬(P3)이 SF(G4) 콘텐츠 8개 시청. 기본 언어 영어.

-- 5. 비디오 특정 기능 테이블 (video, audioLang, subtitleSetting, device 테이블에 의존)

-- trailer (예고편, video, audioLang 테이블에 의존)
INSERT INTO trailer (trailerURL, title, videoID, audioLangID)
VALUES ('trailer/parasite_kr.mp4', '기생충 메인 예고편', 1, 1); -- 기생충(V1) 예고편, 한국어 스테레오(AL1)
INSERT INTO trailer (trailerURL, title, videoID, audioLangID)
VALUES ('trailer/st_s1_en.mp4', '기묘한 이야기 시즌 1 예고편', 2, 2); -- 기묘한 이야기 S1E1(V2) 예고편, 영어 5.1(AL2)
INSERT INTO trailer (trailerURL, title, videoID, audioLangID)
VALUES ('trailer/inception_en.mp4', '인셉션 메인 예고편', 4, 5); -- 인셉션(V4) 예고편, 영어 돌비 애트모스(AL5)

-- subtitle (자막, video, subtitleSetting 테이블에 의존)
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/parasite_en.srt', NULL, 1, 1); -- 기생충(V1) 영어 자막, Arial 스타일(S1) 사용
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/parasite_ko_sdh.srt', 'Y', 1, 1); -- 기생충(V1) 한국어 청각 장애인용 자막 (SDH), Arial 스타일(S1)
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/st_s1e1_ko.srt', NULL, 2, 3); -- 기묘한 이야기 S1E1(V2) 한국어 자막, 돋움 스타일(S3) 사용
INSERT INTO subtitle (subtitleFileURL, screenDiscription, videoID, subtitleSettingID)
VALUES ('sub/inception_ko.srt', NULL, 4, 2); -- 인셉션(V4) 한국어 자막, Times New Roman 스타일(S2) 사용

-- download (다운로드 목록, device, video 테이블에 의존) -- 컬럼명 videoID 로 수정됨
INSERT INTO download (deviceID, videoID) VALUES (2, 1); -- 앨리스 아이폰 14(D2)에 기생충(V1) 다운로드.
INSERT INTO download (deviceID, videoID) VALUES (4, 2); -- 앨리스 키즈 아이패드 에어(D4)에 기묘한 이야기 S1E1(V2) 다운로드.
INSERT INTO download (deviceID, videoID) VALUES (4, 3); -- 앨리스 키즈 아이패드 에어(D4)에 기묘한 이야기 S1E2(V3) 다운로드.

COMMIT; -- 모든 삽입 후 트랜잭션 커밋

ALTER TABLE content
ADD CONSTRAINT uq_content_unique
UNIQUE (title, releaseDate, originLang, productionCountry);


