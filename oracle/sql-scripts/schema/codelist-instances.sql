----------------------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: Apr 2025
----------------------------------------------------------------

SET SERVEROUTPUT ON

TRUNCATE TABLE codelist DROP STORAGE;


-- Building class, function, and usage --

INSERT INTO codelist (ID, CODELIST_TYPE, URL, MIME_TYPE)
VALUES (0, 'bldg:BuildingClassValue', 'http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_class.xml', 'application/xml');

INSERT INTO codelist (ID, CODELIST_TYPE, URL, MIME_TYPE)
VALUES (1, 'bldg:BuildingFunctionValue', 'http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml', 'application/xml');

INSERT INTO codelist (ID, CODELIST_TYPE, URL, MIME_TYPE)
VALUES (2, 'bldg:BuildingUsageValue', 'http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_usage.xml', 'application/xml');

COMMIT;

--
-- Show errors
--
SHOW ERRORS;