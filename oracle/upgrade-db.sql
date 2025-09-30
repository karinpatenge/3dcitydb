-- ToDos: <tbr>

SET SERVEROUTPUT ON
SET FEEDBACK ON
SET VER OFF

DEFINE NEW_MAJOR=<tbr>;
DEFINE NEW_MINOR=<tbr>;
DEFINE NEW_REVISION=<tbr>;

SELECT '3DCityDB upgrade started!' as message from DUAL;

-- check current version
SELECT 'Checking version of the 3DCityDB instance ...' as message from DUAL;
VARIABLE major NUMBER;
VARIABLE minor NUMBER;
VARIABLE revision NUMBER;
BEGIN
  SELECT major_version, minor_version, minor_revision INTO :major, :minor, :revision FROM TABLE(citydb_util.citydb_version);
END;
/

SELECT :major || '.' || :minor || '.' || :revision as message from DUAL;

-- choose action depending on current version
column script new_value DO_ACTION
SELECT CASE
  WHEN &NEW_MAJOR = :major
       AND ( (&NEW_MINOR = :minor AND &NEW_REVISION > :revision)
	   OR &NEW_MINOR > :minor ) THEN 'upgrade.sql'
  WHEN :major < &NEW_MAJOR THEN '<tbr>.sql'
  ELSE 'do-nothing.sql'
  END AS script
FROM dual;

@@&DO_ACTION

SHOW ERRORS;
COMMIT;

SELECT '3DCityDB upgrade completed!' as message from DUAL;

QUIT;
/