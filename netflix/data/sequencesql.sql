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

select *
from user_constraints;

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




