DROP VIEW IF EXISTS users_no_from_subquery_in_views;

CREATE VIEW users_no_from_subquery_in_views AS
  SELECT NetID netid, TRUE admin FROM employee
  UNION ALL SELECT NetID netid, netid IN(SELECT NetID FROM employee) admin FROM reserveout
  UNION ALL
  SELECT NetID netid, netid IN(SELECT NetID FROM employee) admin FROM checkout
  ;

DROP TABLE IF EXISTS users;

CREATE TABLE users AS
  SELECT * FROM users_no_from_subquery_in_views GROUP BY netid;
  ;

DROP TABLE IF EXISTS checked_out;

CREATE TABLE checked_out AS
  SELECT
  `COPY` `copy`,
  `callnumber` `call`,
  `NETID` `netid`,
  `DUEDATETIME` `due`,
  '::ROBO::' `attendant` -- the attendants aren't listed, so make an obviously fake one
  FROM `checkout` JOIN
  titles ON titles.AQNO = checkout.AQNO

  UNION ALL

  SELECT
  `COPY` `copy`,
  `callnumber` `call`,
  `NETID` `netid`,
  `DUEDATETIME` `due`,
  '::ROBO::' `attendant` -- the attendants aren't listed, so make an obviously fake one
  FROM `reserveout` JOIN
  titles ON titles.AQNO = reserveout.AQNO
  ;

DROP TABLE IF EXISTS inventory;

-- TODO: are volumes applicable here at all?
CREATE TABLE inventory AS
  -- TITLES TABLE
  SELECT
  callnumber `call`,
  title,
  (SELECT COUNT(*) FROM titles WHERE callnumber = `call`) quantity,
  IF(
    STR_TO_DATE(`aquired`,'%m-%d-%y') IS NULL,
    STR_TO_DATE(`aquired`,'%m/%d/%y'),
    STR_TO_DATE(`aquired`,'%m-%d-%y')
  ) date_added,
  IF(`online`, TRUE, FALSE) on_hummedia,
  notes,
  FALSE is_reserve,
  IF(`duplicate` = 'Y', TRUE, FALSE) is_duplicatable
  FROM titles WHERE `callnumber` NOT IN(SELECT `callnumber` FROM reserveitems)

  UNION ALL

  -- RESERVE TABLE
  SELECT
  callnumber `call`,
  title,
  (SELECT COUNT(*) FROM `reserveitems` WHERE callnumber = `call`) quantity,
  NULL date_added,
  NULL on_hummedia,
  CONCAT(
    notes, ' [',
    'Return Type: ', returntype, '. ',
    'Instructor: ', instructor, '. ',
    'Dropped by: ', droppedby, '.]'
  ) notes,
  TRUE is_reserve,
  FALSE is_duplicatable
  FROM reserveitems
  ;

DROP TABLE IF EXISTS media_items;

CREATE TABLE media_items AS
  SELECT description `medium`, callnumber `call`
  FROM titles JOIN media ON media.code = titles.media;

DROP TABLE IF EXISTS languages_items;

CREATE TABLE languages_items AS
  SELECT
    CASE code
      WHEN 'AF' THEN 'afr'
      WHEN 'AM' THEN 'hye'
      WHEN 'AR' THEN 'ara'
      WHEN 'BU' THEN 'bul'
      WHEN 'CA' THEN 'yue'
      WHEN 'CB' THEN 'ceb'
      WHEN 'CH' THEN 'cmn'
      WHEN 'CM' THEN 'khm'
      WHEN 'CZ' THEN 'ces'
      WHEN 'DN' THEN 'dan'
      WHEN 'DU' THEN 'nld'
      WHEN 'EG' THEN 'eng'
      WHEN 'EN' THEN 'eng'
      WHEN 'EP' THEN 'epo'
      WHEN 'EQ' THEN NULL -- Equipment
      WHEN 'ES' THEN 'eng' -- ESL
      WHEN 'FJ' THEN 'fij'
      WHEN 'FL' THEN 'fil'
      WHEN 'FN' THEN 'fin'
      WHEN 'FR' THEN 'fra'
      WHEN 'GG' THEN 'eng' -- TODO: figure out the reason for all the English codes
      WHEN 'GK' THEN 'ell'
      WHEN 'GR' THEN 'deu'
      WHEN 'HA' THEN 'haw'
      WHEN 'HB' THEN 'heb'
      WHEN 'HG' THEN 'hun'
      WHEN 'HM' THEN 'hmn'
      WHEN 'IC' THEN 'isl'
      WHEN 'IN' THEN 'ind'
      WHEN 'IT' THEN 'ita'
      WHEN 'JP' THEN 'jpn'
      WHEN 'KO' THEN 'kor'
      WHEN 'LA' THEN 'lat'
      WHEN 'LI' THEN NULL -- Linguistics
      WHEN 'LO' THEN 'lao'
      WHEN 'MG' THEN 'mlg'
      WHEN 'MO' THEN 'mon'
      WHEN 'MU' THEN NULL -- MUSIC
      WHEN 'NO' THEN 'nor'
      WHEN 'NR' THEN 'nor'
      WHEN 'NV' THEN 'nav'
      WHEN 'PG' THEN 'por'
      WHEN 'PL' THEN 'pol'
      WHEN 'PN' THEN 'fas'
      WHEN 'QC' THEN 'quc'
      WHEN 'RN' THEN 'ron'
      WHEN 'RU' THEN 'rus'
      WHEN 'SA' THEN 'smo'
      WHEN 'SC' THEN NULL -- Scandinavian. Not a specific language.
      WHEN 'SI' THEN 'swa'
      WHEN 'SP' THEN 'spa'
      WHEN 'SR' THEN 'srp'
      WHEN 'SW' THEN 'swe'
      WHEN 'TG' THEN 'tgl'
      WHEN 'TH' THEN 'tha'
      WHEN 'TJ' THEN 'tgk'
      WHEN 'TL' THEN 'tel'
      WHEN 'TN' THEN 'ton'
      WHEN 'TR' THEN 'tur'
      WHEN 'TS' THEN 'eng' -- TOEFL. Counting as English.
      WHEN 'TY' THEN 'tah'
      WHEN 'UR' THEN 'urd'
      WHEN 'UZ' THEN 'uzb'
      WHEN 'VT' THEN 'vie'
      WHEN 'WL' THEN 'cym'
      ELSE NULL
    END as language_code,
    titles.callnumber AS inventory_call
  FROM  languages
  JOIN titles ON titles.lang = languages.code;
