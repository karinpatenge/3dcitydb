-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: July 2025
-- Status: work in progress
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

/*****************************************************************
* PL/SQL PACKAGE citydb_srs
*
* Utility methods for spatial reference system in the database
******************************************************************/
CREATE OR REPLACE PACKAGE citydb_srs
AS
  FUNCTION transform_or_null (geom IN MDSYS.SDO_GEOMETRY, srid IN INTEGER) RETURN MDSYS.SDO_GEOMETRY;
  FUNCTION check_srid (srid IN INTEGER DEFAULT 0) RETURN INTEGER;
  FUNCTION is_coord_ref_sys_3d (schema_srid IN INTEGER) RETURN INTEGER;
  FUNCTION is_db_coord_ref_sys_3d RETURN INTEGER;
  FUNCTION get_dim (schema_name VARCHAR2 := USER, table_name VARCHAR2, column_name VARCHAR2) RETURN INTEGER;
  PROCEDURE change_column_srid (table_name IN VARCHAR2, column_name IN VARCHAR2, dim IN INTEGER, target_srid IN INTEGER, transform IN INTEGER DEFAULT 0);
  PROCEDURE change_schema_srid (schema_srid IN INTEGER, schema_gml_srs_name IN VARCHAR2, transform IN INTEGER DEFAULT 0);
END citydb_srs;
/

CREATE OR REPLACE PACKAGE BODY citydb_srs
AS

  /*****************************************************************
  * Function TRANSFORM_OR_NULL
  *
  * Parameters:
  *   - GEOM => The geometry to transform to another coordinate system
  *   - SRID => The SRID of the coordinate system to be used for the transformation
  *
  * Return value:
  *   - SDO_GEOMETRY => The transformed geometry representation
  ******************************************************************/
  FUNCTION transform_or_null (
    geom IN MDSYS.SDO_GEOMETRY,
    srid IN INTEGER
  )
  RETURN MDSYS.SDO_GEOMETRY
  IS
  BEGIN
    IF geom IS NOT NULL THEN
      RETURN sdo_cs.transform(geom, srid);
    ELSE
      RETURN NULL;
    END IF;
  END transform_or_null;

  /*******************************************************************
  * Function CHECK_SRID
  *
  * Parameters:
  *   - SRID => The SRID to be checked
  *
  * Return value:
  *   - BOOLEAN => The boolean result encoded as INTEGER: 0 = false, 1 = true
  *******************************************************************/
  FUNCTION check_srid (
    srid IN INTEGER DEFAULT 0
  )
  RETURN INTEGER
  IS
    l_srid INTEGER;
    unknown_srs_ex EXCEPTION;
  BEGIN
    SELECT COUNT(srid) INTO l_srid
    FROM mdsys.cs_srs
    WHERE srid = srid;

    IF l_srid = 0 THEN
      RAISE unknown_srs_ex;
    ELSE
      RETURN 1;
    END IF;

    EXCEPTION
      WHEN unknown_srs_ex THEN
        dbms_output.put_line('Table MDSYS.CS_SRS does not contain the SRID ' || srid || '.');
        RETURN 0;

  END check_srid;

  /*****************************************************************
  * Function IS_COORD_REF_SYS_3D
  *
  * Parameters:
  *   - SRID => the SRID of the coordinate system to be checked
  *
  * Return value:
  *   - INTEGER => The boolean result encoded as INTEGER: 0 = false, 1 = true
  ******************************************************************/
  FUNCTION is_coord_ref_sys_3d (
    schema_srid IN INTEGER
  )
    RETURN INTEGER
  IS
    l_is_3d INTEGER := 0;
  BEGIN
    SELECT COALESCE (
      (SELECT 1 FROM sdo_crs_compound WHERE srid = schema_srid),
      (SELECT 1 FROM sdo_crs_geographic3d WHERE srid = schema_srid),
      0
    ) INTO l_is_3d
    FROM dual;

    RETURN l_is_3d;
  END is_coord_ref_sys_3d;

  /*****************************************************************
  * Function IS_DB_COORD_REF_SYS_3D
  *
  * Return value:
  *   - INTEGER => The boolean result encoded as INTEGER: 0 = false, 1 = true
  ******************************************************************/
  FUNCTION is_db_coord_ref_sys_3d
  RETURN INTEGER
  IS
    l_srid INTEGER;
    l_schema_name VARCHAR2(128);
  BEGIN
    l_schema_name := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    EXECUTE IMMEDIATE
      'SELECT srid FROM ' || DBMS_ASSERT.SCHEMA_NAME(l_schema_name) || '.database_srs'
      INTO l_srid;
    RETURN is_coord_ref_sys_3d(l_srid);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 0;
  END is_db_coord_ref_sys_3d;

  /*****************************************************************
  * get_dim
  *
  * @param schema_name name of schema
  * @param tab_name name of the table
  * @param col_name name of the column
  * @RETURN INTEGER number of dimension
  ******************************************************************/

 /* ToDo: Check if parameter SCHEMA_NAME can be omitted by referencing metadata view USER_SDO_GEOM_METADATA */

  FUNCTION get_dim (
    schema_name IN VARCHAR2 := USER,
    table_name IN VARCHAR2,
    column_name IN VARCHAR2
    ) RETURN INTEGER
  IS
    l_is_3d INTEGER := 0;
--    is_3d NUMBER(1, 0);
  BEGIN
    SELECT
      3
    INTO
      l_is_3d
    FROM
      all_sdo_geom_metadata m,
      TABLE(m.diminfo) dim
    WHERE
      m.table_name = upper(table_name)
      AND m.column_name = upper(column_name)
      AND dim.sdo_dimname = 'Z'
      AND m.owner = upper(schema_name);

    RETURN l_is_3d;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 2;
  END get_dim;

  /*****************************************************************
  * Procedure CHANGE_COLUMN_SRID
  *
  * Parameters:
  *   - TABLE_NAME => name of the table
  *   - COLUMN_NAME => name of the column
  *   - DIM => dimension of spatial index
  *   - TARGET_SRID => the SRID of the coordinate system to be further used in the database
  *   - TRANSFORM => 1 if existing data shall be transformed, 0 if not
  *   - GEOM_TYPE => The geometry type of the given spatial column
  ******************************************************************/
  PROCEDURE change_column_srid (
    table_name  IN VARCHAR2,
    column_name IN VARCHAR2,
    dim         IN INTEGER,
    target_srid IN INTEGER,
    transform   IN INTEGER DEFAULT 0
    -- geom_type     IN VARCHAR2 DEFAULT 'GEOMETRY'
  )
  IS
    l_schema_name   VARCHAR2(128);
    l_table_name    VARCHAR2(128);
    l_column_name   VARCHAR2(128);
    l_sidx_name     VARCHAR2(128);
    l_sidx_dim      VARCHAR2(128);
    -- l_geom_type     VARCHAR2(128);
    l_is_versioned  BOOLEAN;
    l_is_valid      VARCHAR2(128);
  BEGIN
    l_schema_name := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');

    IF table_name LIKE '%\_LT' ESCAPE '\' THEN
      l_is_versioned := true;
      l_table_name := substr(table_name, 1, length(table_name) - 3);
    ELSE
      l_table_name := table_name;
    END IF;

    l_column_name := column_name;
    l_sidx_dim := dim;

    -- Check the existence of a spatial index defined for a table and column
    SELECT sdo_index_name INTO l_sidx_name
    FROM user_sdo_index_metadata
    WHERE sdo_index_owner = l_schema_name AND sdo_table_name = l_table_name AND sdo_column_name = l_column_name;

    -- Drop the existing spatial index
    EXECUTE IMMEDIATE 'DROP INDEX IF EXISTS ' || l_sidx_name || ' FORCE';

    -- Delete existing USER_SDO_GEOM_METADATA for the old SRID
    EXECUTE IMMEDIATE 'DELETE FROM user_sdo_geom_metadata WHERE table_name = ' || l_table_name || ' AND column_name = ' || l_column_name;

    -- Insert SDO metadata for the new SRID
    EXECUTE IMMEDIATE 'INSERT INTO user_sdo_geom_metadata ...';

    -- Recreate the spatial index for the new SRID
    EXECUTE IMMEDIATE 'CREATE INDEX IF NOT EXISTS ' || l_sidx_name || ' ON ' || l_table_name || ' ( ' || l_column_name || ') INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2 PARAMETERS ( '' sdo_indx_dims = ' || l_sidx_dim || ''') ';


    IF transform <> 0 THEN
      -- coordinates of existent geometries will be transformed inline
      EXECUTE IMMEDIATE
        'UPDATE ' || l_table_name || ' SET ' || l_column_name || ' = sdo_cs.transform( ' || l_column_name || ', :1) WHERE ' || l_column_name || ' IS NOT NULL'
        USING target_srid;
    END IF;
    COMMIT;

  END change_column_srid;

  /*****************************************************************
  * change_schema_srid
  *
  * @param schema_srid the SRID of the coordinate system to be further used in the database
  * @param schema_gml_srs_name the GML_SRS_NAME of the coordinate system to be further used in the database
  * @param transform 1 if existing data shall be transformed, 0 if not
  ******************************************************************/
  PROCEDURE change_schema_srid (
    schema_srid IN INTEGER,
    schema_gml_srs_name IN VARCHAR2,
    transform IN INTEGER DEFAULT 0
  )
  IS
  BEGIN
    -- check if user selected srid is valid
    -- will raise an exception if not
    IF citydb_srs.check_srid(schema_srid) = 0 THEN
      dbms_output.put_line('The chosen SRID ' || schema_srid || ' was not found in the MDSYS.CS_SRS table.');
      RETURN;
    END IF;

    -- update entry in DATABASE_SRS table first
    EXECUTE IMMEDIATE 'TRUNCATE TABLE database_srs DROP STORAGE';
    EXECUTE IMMEDIATE 'INSERT INTO database_srs (srid, gml_srs_name) VALUES (:1, :2)' USING schema_srid, schema_gml_srs_name;

    -- change srid of spatial columns in given schema
    FOR rec IN (
      SELECT
        table_name AS t,
        column_name AS c,
        citydb_srs.get_dim(USER, table_name, column_name) AS dim
      FROM
        user_sdo_geom_metadata
      WHERE
        column_name NOT IN ('IMPLICIT_GEOMETRY', 'RELATIVE_OTHER_GEOM', 'TEXTURE_COORDINATES')
      ORDER BY
        table_name,
        column_name
      )
    LOOP
      change_column_srid(rec.t, rec.c, rec.dim, schema_srid, transform);
    END LOOP;
    dbms_output.put_line('Schema SRID successfully changed to ' || schema_srid || '.');
  END;

END citydb_srs;
/