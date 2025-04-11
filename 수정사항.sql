ALTER TABLE content
ADD CONSTRAINT uq_content_unique
UNIQUE (title, releaseDate, originLang, productionCountry);