-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: July 2025
-- Status: work in progress
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

/*****************************************************************
* TYPE STRARRAY
*
* global type for arrays of strings, e.g. used for log messages
* and reports
******************************************************************/
CREATE OR REPLACE TYPE STRARRAY IS TABLE OF VARCHAR2(32767);
/

/*****************************************************************
* TYPE ID_ARRAY
*
* global type for arrays of number values
******************************************************************/
CREATE OR REPLACE TYPE ID_ARRAY IS TABLE OF NUMBER;
/

/*****************************************************************
* TYPE DB_VERSION_OBJ and DB_VERSION_TABLE
*
* global type for database version information
******************************************************************/
CREATE OR REPLACE TYPE DB_VERSION_OBJ AS OBJECT(
  VERSION VARCHAR2(10),
  MAJOR_VERSION NUMBER,
  MINOR_VERSION NUMBER,
  MINOR_REVISION NUMBER
);
/

CREATE OR REPLACE TYPE DB_VERSION_TABLE IS TABLE OF DB_VERSION_OBJ;
/

/*****************************************************************
* TYPE DB_INFO_OBJ and DB_INFO_TABLE
*
* global type for database metadata
******************************************************************/
CREATE OR REPLACE TYPE DB_INFO_OBJ AS OBJECT(
  SCHEMA_SRID NUMBER,
  SCHEMA_GML_SRS_NAME VARCHAR2(1000),
  COORD_REF_SYS_NAME VARCHAR2(80),
  COORD_REF_SYS_KIND VARCHAR2(24),
  WKTEXT VARCHAR2(4000),
  VERSIONING VARCHAR2(100)
);
/

CREATE OR REPLACE TYPE DB_INFO_TABLE IS TABLE OF DB_INFO_OBJ;
/


/*****************************************************************
* PACKAGE citydb_util
*
* utility methods for applications and subpackages
******************************************************************/
CREATE OR REPLACE PACKAGE citydb_util
AS
  FUNCTION citydb_version RETURN DB_VERSION_TABLE;
  FUNCTION versioning_table(tab_name VARCHAR2, schema_name VARCHAR2 := USER) RETURN VARCHAR2;
  FUNCTION versioning_db(schema_name VARCHAR2 := USER) RETURN VARCHAR2;
  FUNCTION db_metadata(schema_name VARCHAR2 := USER) RETURN DB_INFO_TABLE;
  FUNCTION split(list VARCHAR2, delim VARCHAR2 := ',') RETURN STRARRAY;
  FUNCTION min(a NUMBER, b NUMBER) RETURN NUMBER;
  FUNCTION get_seq_values(seq_name VARCHAR2, seq_count NUMBER) RETURN ID_ARRAY;
  FUNCTION string2id_array(str VARCHAR2, delim VARCHAR2 := ',') RETURN ID_ARRAY;
  FUNCTION get_id_array_size(id_arr ID_ARRAY) RETURN NUMBER;
  FUNCTION construct_solid(geom_root_id NUMBER) RETURN SDO_GEOMETRY;
  FUNCTION to_2d(geom MDSYS.SDO_GEOMETRY, srid NUMBER) RETURN MDSYS.SDO_GEOMETRY;
  FUNCTION sdo2geojson3d(p_geometry in SDO_GEOMETRY, p_decimal_places in pls_integer default 2, p_compress_tags in pls_integer default 0, p_relative2mbr in pls_integer default 0) RETURN CLOB DETERMINISTIC;
  FUNCTION ST_Affine(p_geometry IN mdsys.SDO_GEOMETRY, p_a IN NUMBER, p_b IN NUMBER, p_c IN NUMBER, p_d IN NUMBER, p_e IN NUMBER, p_f IN NUMBER, p_g IN NUMBER, p_h IN NUMBER, p_i IN NUMBER, p_xoff IN NUMBER, p_yoff IN NUMBER, p_zoff IN NUMBER) RETURN mdsys.SDO_GEOMETRY DETERMINISTIC;
  PROCEDURE db_info(schema_name VARCHAR2 := USER, schema_srid OUT INTEGER, schema_gml_srs_name OUT VARCHAR2, versioning OUT VARCHAR2);
  PROCEDURE drop_tmp_tables(schema_name VARCHAR2 := USER);
END citydb_util;
/

CREATE OR REPLACE PACKAGE BODY citydb_util
AS
  TYPE REF_CURSOR IS REF CURSOR;

  /*****************************************************************
  * citydb_version
  *
  ******************************************************************/
  FUNCTION citydb_version RETURN DB_VERSION_TABLE
  IS
    version_ret DB_VERSION_TABLE;
    version_tmp DB_VERSION_OBJ;
  BEGIN
    version_ret := DB_VERSION_TABLE();
    version_ret.extend;

    version_tmp := DB_VERSION_OBJ('4.4.2', 4, 4, 2);

    version_ret(version_ret.count) := version_tmp;
    RETURN version_ret;
  END;

  /*****************************************************************
  * versioning_table
  *
  * @param tab_name     name of the unversioned table, i.e., omit
  *                     suffixes such as _LT
  * @param schema_name  name of schema of target table
  * @return VARCHAR2 'ON' for version-enabled, 'OFF' otherwise
  ******************************************************************/
  FUNCTION versioning_table(
    tab_name VARCHAR2,
    schema_name VARCHAR2 := USER
    ) RETURN VARCHAR2
  IS
    tab_status ALL_TABLES.STATUS%TYPE;
  BEGIN
    SELECT
      status
    INTO
      tab_status
    FROM
      all_tables
    WHERE
      owner = upper(schema_name)
      AND table_name = upper(tab_name) || '_LT';

    RETURN 'ON';

    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'OFF';
  END;

  /*****************************************************************
  * versioning_db
  *
  * @param schema_name name of schema
  * @return VARCHAR2 'ON' for version-enabled, 'PARTLY' and 'OFF'
  ******************************************************************/
  FUNCTION versioning_db(schema_name VARCHAR2 := USER) RETURN VARCHAR2
  IS
    table_names STRARRAY;
    is_versioned BOOLEAN := FALSE;
    not_versioned BOOLEAN := FALSE;
  BEGIN
    table_names := split('ADDRESS,ADDRESS_TO_BRIDGE,ADDRESS_TO_BUILDING,APPEAR_TO_SURFACE_DATA,APPEARANCE,BREAKLINE_RELIEF,BRIDGE,BRIDGE_CONSTR_ELEMENT,BRIDGE_FURNITURE,BRIDGE_INSTALLATION,BRIDGE_OPEN_TO_THEM_SRF,BRIDGE_OPENING,BRIDGE_ROOM,BRIDGE_THEMATIC_SURFACE,BUILDING,BUILDING_FURNITURE,BUILDING_INSTALLATION,CITY_FURNITURE,CITYMODEL,CITYOBJECT,CITYOBJECT_GENERICATTRIB,CITYOBJECT_MEMBER,CITYOBJECTGROUP,EXTERNAL_REFERENCE,GENERALIZATION,GENERIC_CITYOBJECT,GROUP_TO_CITYOBJECT,IMPLICIT_GEOMETRY,LAND_USE,MASSPOINT_RELIEF,OPENING,OPENING_TO_THEM_SURFACE,PLANT_COVER,GRID_COVERAGE_RDT,RASTER_RELIEF,RELIEF_COMPONENT,RELIEF_FEAT_TO_REL_COMP,RELIEF_FEATURE,ROOM,SOLITARY_VEGETAT_OBJECT,SURFACE_DATA,SURFACE_GEOMETRY,TEX_IMAGE,TEXTUREPARAM,THEMATIC_SURFACE,TIN_RELIEF,TRAFFIC_AREA,TRANSPORTATION_COMPLEX,TUNNEL,TUNNEL_FURNITURE,TUNNEL_HOLLOW_SPACE,TUNNEL_INSTALLATION,TUNNEL_OPEN_TO_THEM_SRF,TUNNEL_OPENING,TUNNEL_THEMATIC_SURFACE,WATERBOD_TO_WATERBND_SRF,WATERBODY,WATERBOUNDARY_SURFACE');

    FOR i IN table_names.first .. table_names.last LOOP
      IF versioning_table(table_names(i), schema_name) = 'ON' THEN
        is_versioned := TRUE;
      ELSE
        not_versioned := TRUE;
      END IF;
    END LOOP;

    IF is_versioned AND NOT not_versioned THEN
      RETURN 'ON';
    ELSIF is_versioned AND not_versioned THEN
      RETURN 'PARTLY';
    ELSE
      RETURN 'OFF';
    END IF;
  END;

  /*****************************************************************
  * db_info
  *
  * @param schema_name name of user schema
  * @param schema_srid database srid
  * @param schema_gml_srs_name database srs name
  * @param versioning database versioning
  ******************************************************************/
  PROCEDURE db_info(
    schema_name VARCHAR2 := USER,
    schema_srid OUT INTEGER,
    schema_gml_srs_name OUT VARCHAR2,
    versioning OUT VARCHAR2
  )
  IS
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT srid, gml_srs_name FROM '||schema_name||'.database_srs'
       INTO schema_srid, schema_gml_srs_name;

    versioning := versioning_db(schema_name);
  END;

  /*****************************************************************
  * db_metadata
  *
  * @param schema_name name of user schema
  * @return DB_INFO_TABLE object
  ******************************************************************/
  FUNCTION db_metadata(schema_name VARCHAR2 := USER) RETURN DB_INFO_TABLE
  IS
    info_ret DB_INFO_TABLE;
    info_tmp DB_INFO_OBJ;
    wktext3d_exists number;
  BEGIN
    info_ret := DB_INFO_TABLE();
    info_ret.extEND;

    info_tmp := DB_INFO_OBJ(0, NULL, NULL, 0, NULL, NULL);

    EXECUTE IMMEDIATE
      'SELECT srid, gml_srs_name FROM '||schema_name||'.database_srs'
       INTO info_tmp.schema_srid, info_tmp.schema_gml_srs_name;

    SELECT
      coord_ref_sys_name,
      coord_ref_sys_kind
    INTO
      info_tmp.coord_ref_sys_name,
      info_tmp.coord_ref_sys_kind
    FROM
      sdo_coord_ref_sys
    WHERE srid = info_tmp.schema_srid;

    SELECT
      count(*)
    INTO
      wktext3d_exists
    FROM
      all_tab_cols
    WHERE
      column_name = 'WKTEXT3D'
      AND table_name = 'CS_SRS';

    IF wktext3d_exists = 1 THEN
      SELECT
        NVL(wktext3d, wktext)
      INTO
        info_tmp.wktext
      FROM
        cs_srs
      WHERE
        srid = info_tmp.schema_srid;
    ELSE
      SELECT
        wktext
      INTO
        info_tmp.wktext
      FROM
        cs_srs
      WHERE
        srid = info_tmp.schema_srid;
    END IF;

    info_tmp.versioning := versioning_db(schema_name);
    info_ret(info_ret.count) := info_tmp;
    RETURN info_ret;
  END;

  /*****************************************************************
  * split
  *
  * @param list string to be splitted
  * @param delim delimiter used for splitting, defaults to ','
  * @return STRARRAY array of strings containing split tokens
  ******************************************************************/
  FUNCTION split(list VARCHAR2, delim VARCHAR2 := ',') RETURN STRARRAY
  IS
    results STRARRAY := STRARRAY();
    idx PLS_INTEGER;
    tmp_list VARCHAR2(32767) := list;
  BEGIN
    LOOP
      idx := instr(tmp_list,delim);
      IF idx > 0 THEN
        results.extEND;
        results(results.count) := substr(tmp_list, 1, idx-1);
        tmp_list := substr(tmp_list, idx + length(delim));
      ELSE
        results.extEND;
        results(results.count) := tmp_list;
        EXIT;
      END IF;
    END LOOP;

    RETURN results;
  END;

  /*****************************************************************
  * min
  *
  * @param a first number value
  * @param b second number value
  * @return NUMBER the smaller of the two input number values
  ******************************************************************/
  FUNCTION min(a NUMBER, b NUMBER) RETURN NUMBER
  IS
  BEGIN
    IF a < b THEN
      RETURN a;
    ELSE
      RETURN b;
    END IF;
  END;

  /*****************************************************************
  * get_seq_values
  *
  * @param seq_name name of the sequence
  * @param count number of values to be queried from the sequence
  * @return ID_ARRAY array of sequence values
  ******************************************************************/
  FUNCTION get_seq_values(
    seq_name VARCHAR2,
    seq_count NUMBER
    ) RETURN ID_ARRAY
  IS
    seq_tbl ID_ARRAY;
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT ' || upper(seq_name) || '.nextval '
      || 'FROM dual CONNECT BY level <= :1'
      BULK COLLECT INTO seq_tbl
      USING seq_count;

    RETURN seq_tbl;
  END;

  /*****************************************************************
  * string2id_array
  *
  * converts a string into an ID_ARRAY object
  *
  * @param str string to be splitted
  * @param delim delimiter used for splitting, defaults to ','
  * @return ID_ARRAY array of number containing split tokens
  ******************************************************************/
  FUNCTION string2id_array(str VARCHAR2, delim VARCHAR2 := ',') RETURN ID_ARRAY
  IS
    arr ID_ARRAY;
  BEGIN
    WITH split_str AS (
      SELECT
        regexp_substr(str, '[^'||delim||']+', 1, LEVEL) AS str_parts
      FROM
        dual
      CONNECT BY
        regexp_substr(str, '[^'||delim||']+', 1, LEVEL) IS NOT NULL
    )
    SELECT
      to_number(replace(str_parts,'.',','))
    BULK COLLECT INTO
      arr
    FROM
      split_str;

    RETURN arr;
  END;

  /*****************************************************************
  * get_id_array_size
  *
  * returns the size of a given ID_ARRAY object
  *
  * @param id_arr passed ID_ARRAY object
  * @return size of ID_ARRAY object
  ******************************************************************/
  FUNCTION get_id_array_size(id_arr ID_ARRAY) RETURN NUMBER
  IS
    arr_count NUMBER := 0;
  BEGIN
    arr_count := id_arr.count;
    RETURN arr_count;
  END;

  /*****************************************************************
  * construct_solid
  *
  * @param geom_root_id identifier to group geometries of a solid
  * @return SDO_GEOMETRY the constructed solid geometry
  ******************************************************************/
  FUNCTION construct_solid(
    geom_root_id NUMBER
    ) RETURN SDO_GEOMETRY
  IS
    column_srid NUMBER;
    geom_cur REF_CURSOR;
    solid_part SDO_GEOMETRY;
    solid_geom SDO_GEOMETRY;
    elem_count NUMBER := 1;
    solid_offset NUMBER := 0;
    solid_null_ex EXCEPTION;
    --solid_invalid_ex EXCEPTION;
  BEGIN
    SELECT
      srid
    INTO
      column_srid
    FROM
      user_sdo_geom_metadata
    WHERE
      table_name = 'SURFACE_GEOMETRY'
      AND column_name = 'SOLID_GEOMETRY';

    OPEN geom_cur FOR
      SELECT
        geometry
      FROM
        surface_geometry
      WHERE
        (root_id = geom_root_id
        OR parent_id = geom_root_id)
        AND geometry IS NOT NULL
      ORDER BY
        id;
    LOOP
      FETCH geom_cur INTO solid_part;
      EXIT WHEN geom_cur%NOTFOUND;

      IF solid_geom IS NULL THEN
        -- construct an empty solid
        solid_geom := mdsys.SDO_GEOMETRY(
                      3008, column_srid, null,
                      mdsys.sdo_elem_info_array (), mdsys.sdo_ordinate_array ()
                      );

        solid_geom.sdo_elem_info.extEND(6);
        solid_geom.sdo_elem_info(1) := 1;
        solid_geom.sdo_elem_info(2) := 1007;
        solid_geom.sdo_elem_info(3) := 1;
        solid_geom.sdo_elem_info(4) := 1;
        solid_geom.sdo_elem_info(5) := 1006;
        solid_geom.sdo_elem_info(6) := 0;
      END IF;

      IF (solid_part.sdo_elem_info IS NOT NULL) THEN
        -- fill elem_info_array
        FOR i IN solid_part.sdo_elem_info.FIRST .. solid_part.sdo_elem_info.LAST LOOP
          solid_geom.sdo_elem_info.extEND;

          -- set correct offset
          -- the following equation will always be 0 for the first position of one or more ELEM_INFO_ARRAYs
          IF (elem_count - (i + 2) / 3) = 0 THEN
            solid_geom.sdo_elem_info(solid_geom.sdo_elem_info.count) := solid_offset + solid_part.sdo_elem_info(i);
            elem_count := elem_count + 1;
          ELSE
            solid_geom.sdo_elem_info(solid_geom.sdo_elem_info.count) := solid_part.sdo_elem_info(i);
          END IF;
        END LOOP;

        -- fill ordinates_array
        IF (solid_part.sdo_ordinates IS NOT NULL) THEN
          FOR i IN solid_part.sdo_ordinates.FIRST .. solid_part.sdo_ordinates.LAST LOOP
            solid_geom.sdo_ordinates.extEND;
            solid_geom.sdo_ordinates(solid_geom.sdo_ordinates.count) := solid_part.sdo_ordinates(i);
          END LOOP;
          -- update offset
          solid_offset := solid_geom.sdo_ordinates.count;
        END IF;

        -- update sdo_elem_info of solid and reset elem_count
        solid_geom.sdo_elem_info(6) := solid_geom.sdo_elem_info(6) + solid_part.sdo_elem_info.count / 3;
        elem_count := 1;
      END IF;
    END LOOP;
    CLOSE geom_cur;

    -- loop stops when last solid is complete but before the corresponding update is commited
    -- therefore it has to be done here
    IF solid_geom IS NOT NULL THEN
      --IF sdo_geom.validate_geometry(solid_geom, 0.001) = 'TRUE' THEN
        RETURN solid_geom;
      /*ELSE
        RAISE solid_invalid_ex;
      END IF;*/
    ELSE
      RAISE solid_null_ex;
    END IF;

    EXCEPTION
      WHEN solid_null_ex THEN
        dbms_output.put_line('Empty solid. Propably no entries exist in the database for chosen ID');
        RETURN NULL;
      /*WHEN solid_invalid_ex THEN
        dbms_output.put_line('Constructed solid is not valid.');
        RETURN NULL;*/
      WHEN OTHERS THEN
        dbms_output.put_line('An error occured when executing FUNCTION citydb_util.construct_solid. Error: ' || SQLERRM);
  END;


  /*
  * code taken from http://forums.oracle.com/forums/thread.jspa?messageID=960492&#960492
  */
  FUNCTION to_2d (geom mdsys.SDO_GEOMETRY, srid number)
  return mdsys.SDO_GEOMETRY
  is
    geom_2d mdsys.SDO_GEOMETRY;
    dim_count integer; -- number of dimensions in layer
    gtype integer; -- geometry type (single digit)
    n_points integer; -- number of points in ordinates array
    n_ordinates integer; -- number of ordinates
    i integer;
    j integer;
    k integer;
    offset integer;
  BEGIN
    -- If the input geometry is null, just return null
    if geom is null then
      return (null);
    END if;

    -- Get the number of dimensions from the gtype
    if length (geom.sdo_gtype) = 4 then
      dim_count := substr (geom.sdo_gtype, 1, 1);
      gtype := substr (geom.sdo_gtype, 4, 1);
    else
    -- Indicate failure
      raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
    END if;

    if dim_count = 2 then
      -- Nothing to do, geometry is already 2D
      return (geom);
    END if;

    -- Construct and prepare the output geometry
    geom_2d := mdsys.SDO_GEOMETRY (
                2000+gtype, srid, geom.sdo_point,
                mdsys.sdo_elem_info_array (), mdsys.sdo_ordinate_array()
                );

    -- Process the point structure
    if geom_2d.sdo_point is not null then
      geom_2D.sdo_point.z := null;
    else
      -- It is not a point
      -- Process the ordinates array

      -- Prepare the size of the output array
      n_points := geom.sdo_ordinates.count / dim_count;
      n_ordinates := n_points * 2;
      geom_2d.sdo_ordinates.extEND(n_ordinates);

      -- Copy the ordinates array
      j := geom.sdo_ordinates.first; -- index into input elem_info array
      k := 1; -- index into output ordinate array
      for i in 1..n_points loop
        geom_2d.sdo_ordinates (k) := geom.sdo_ordinates (j); -- copy X
        geom_2d.sdo_ordinates (k+1) := geom.sdo_ordinates (j+1); -- copy Y
        j := j + dim_count;
        k := k + 2;
      END loop;

      -- Process the element info array

      -- Copy the input array into the output array
      geom_2d.sdo_elem_info := geom.sdo_elem_info;

      -- Adjust the offsets
      i := geom_2d.sdo_elem_info.first;
      while i < geom_2d.sdo_elem_info.last loop
        offset := geom_2d.sdo_elem_info(i);
        geom_2d.sdo_elem_info(i) := (offset-1)/dim_count*2+1;
        i := i + 3;
      END loop;
    END if;

    return geom_2d;
  exception
    when others then
      dbms_output.put_line('to_2d: ' || SQLERRM);
      return null;
  END;

  /*
  * code taken from https://gist.github.com/nathanvda/a61ab4b094c4c3429a39
  * Author: Simon Greener, Nathan Van der Auwera
  */
  FUNCTION sdo2geojson3d(p_geometry in SDO_GEOMETRY,
    p_decimal_places in pls_integer default 2,
    p_compress_tags in pls_integer default 0,
    p_relative2mbr in pls_integer default 0
  ) return clob deterministic

    /* Note: Does not support curved geometries.
     *        If required, stroke geometry before calling FUNCTION.
     * If Compressed apply bbox to coordinates.....
     * { "type": "Feature",
     *   "bbox": [-180.0, -90.0, 180.0, 90.0],
     *   "geometry": {
     *   "type": "Polygon",
     *   "coordinates": [[ [-180.0, 10.0], [20.0, 90.0], [180.0, -5.0], [-30.0, -90.0] ]]
     *  }
     *  ...
     * }
    */

  as
    v_relative      boolean := case when p_relative2mbr<>0  then true else false END;

    v_result        clob;
    v_type          varchar2(50);
    v_compress_tags boolean       := case when p_compress_tags<>0 then true else false END;
    v_feature_key   varchar2(100) := case when v_compress_tags then 'F'  else '"Feature"'      END;
    v_bbox_tag      varchar2(100) := case when v_compress_tags then 'b:' else '"bbox":'        END;
    v_coord_tag     varchar2(100) := case when v_compress_tags then 'c:' else '"coordinates":' END;
    v_geometry_tag  varchar2(100) := case when v_compress_tags then 'g:' else '"Geometry":'    END;
    v_type_tag      varchar2(100) := case when v_compress_tags then 't:' else '"type":'        END;
    v_temp_string   varchar2(30000);

    v_precision     pls_integer  := nvl(p_decimal_places,2);
    v_i             pls_integer;
    v_num_rings     pls_integer;
    v_num_elements  pls_integer;
    v_element_no    pls_integer;
    v_vertices      mdsys.vertex_set_type;
    v_element       mdsys.SDO_GEOMETRY;
    v_ring          mdsys.SDO_GEOMETRY;
    v_mbr           mdsys.SDO_GEOMETRY;
    v_geometry      mdsys.SDO_GEOMETRY := p_geometry;

    FUNCTION hasRectangles( p_elem_info in mdsys.sdo_elem_info_array  )
      Return Pls_Integer
    Is
       v_rectangle_count number := 0;
       v_etype           pls_integer;
       v_interpretation  pls_integer;
       v_elements        pls_integer;
    BEGIN
       If ( p_elem_info is null ) Then
          return 0;
       END If;
       v_elements := ( ( p_elem_info.COUNT / 3 ) - 1 );
       <<element_extraction>>
       for v_i IN 0 .. v_elements LOOP
         v_etype := p_elem_info(v_i * 3 + 2);
         v_interpretation := p_elem_info(v_i * 3 + 3);
         If  ( v_etype in (1003,2003) AND v_interpretation = 3  ) Then
             v_rectangle_count := v_rectangle_count + 1;
         END If;
       END loop element_extraction;
       Return v_rectangle_Count;
    END hasRectangles;

    FUNCTION hasCircularArcs(p_elem_info in mdsys.sdo_elem_info_array)
       return boolean
     Is
       v_elements  number;
     BEGIN
       v_elements := ( ( p_elem_info.COUNT / 3 ) - 1 );
       <<element_extraction>>
       for v_i IN 0 .. v_elements LOOP
          if ( ( /* etype */         p_elem_info(v_i * 3 + 2) = 2 AND
                 /* interpretation*/ p_elem_info(v_i * 3 + 3) = 2 )
               OR
               ( /* etype */         p_elem_info(v_i * 3 + 2) in (1003,2003) AND
                 /* interpretation*/ p_elem_info(v_i * 3 + 3) IN (2,4) ) ) then
                 return true;
          END If;
       END loop element_extraction;
       return false;
    END hasCircularArcs;

    FUNCTION GetNumRings( p_geometry  in mdsys.SDO_GEOMETRY,
                          p_ring_type in integer default 0 /* 0 = ALL; 1 = OUTER; 2 = INNER */ )
      Return Number
    Is
       v_ring_count number := 0;
       v_ring_type  number := p_ring_type;
       v_elements   number;
       v_etype      pls_integer;
    BEGIN
       If ( p_geometry is null ) Then
          return 0;
       END If;
       If ( p_geometry.sdo_elem_info is null ) Then
          return 0;
       END If;
       If ( v_ring_type not in (0,1,2) ) Then
          v_ring_type := 0;
       END If;
       v_elements := ( ( p_geometry.sdo_elem_info.COUNT / 3 ) - 1 );
       <<element_extraction>>
       for v_i IN 0 .. v_elements LOOP
         v_etype := p_geometry.sdo_elem_info(v_i * 3 + 2);
         If  ( v_etype in (1003,1005,2003,2005) and 0 = v_ring_type )
          OR ( v_etype in (1003,1005)           and 1 = v_ring_type )
          OR ( v_etype in (2003,2005)           and 2 = v_ring_type ) Then
             v_ring_count := v_ring_count + 1;
         END If;
       END loop element_extraction;
       Return v_ring_count;
    END GetNumRings;

    PROCEDURE ADD_Coordinate( p_ordinates  in out nocopy mdsys.sdo_ordinate_array,
                              p_dim        in number,
                              p_x_coord    in number,
                              p_y_coord    in number,
                              p_z_coord    in number,
                              p_m_coord    in number,
                              p_measured   in boolean := false,
                              p_duplicates in boolean := false)
      IS
        FUNCTION Duplicate
          Return Boolean
        Is
        BEGIN
          Return case when p_ordinates is null or p_ordinates.count = 0
                      then False
                      Else case p_dim
                                when 2
                                then ( p_ordinates(p_ordinates.COUNT)   = p_y_coord
                                       AND
                                       p_ordinates(p_ordinates.COUNT-1) = p_x_coord )
                                when 3
                                then ( p_ordinates(p_ordinates.COUNT)   =  case when p_measured then p_m_coord else p_z_coord END
                                       AND
                                       p_ordinates(p_ordinates.COUNT-1) = p_y_coord
                                       AND
                                       p_ordinates(p_ordinates.COUNT-2) = p_x_coord )
                                when 4
                                then ( p_ordinates(p_ordinates.COUNT)   = p_m_coord
                                       AND
                                       p_ordinates(p_ordinates.COUNT-1) = p_z_coord
                                       AND
                                       p_ordinates(p_ordinates.COUNT-2) = p_y_coord
                                       AND
                                       p_ordinates(p_ordinates.COUNT-3) = p_x_coord )
                            END
                    END;
        END Duplicate;

    BEGIN
      If ( p_ordinates is null ) Then
         p_ordinates := new mdsys.sdo_ordinate_array(null);
         p_ordinates.DELETE;
      END If;
      If ( p_duplicates or Not Duplicate() ) Then
        IF ( p_dim >= 2 ) Then
          p_ordinates.extEND(2);
          p_ordinates(p_ordinates.count-1) := p_x_coord;
          p_ordinates(p_ordinates.count  ) := p_y_coord;
        END IF;
        IF ( p_dim >= 3 ) Then
          p_ordinates.extEND(1);
          p_ordinates(p_ordinates.count)   := case when p_dim = 3 And p_measured
                                                   then p_m_coord
                                                   else p_z_coord
                                              END;
        END IF;
        IF ( p_dim = 4 ) Then
          p_ordinates.extEND(1);
          p_ordinates(p_ordinates.count)   := p_m_coord;
        END IF;
      END If;
    END ADD_Coordinate;

    FUNCTION Rectangle2Polygon(p_geometry in mdsys.SDO_GEOMETRY)
      return mdsys.SDO_GEOMETRY
    As
      v_dims      pls_integer;
      v_ordinates mdsys.sdo_ordinate_array := new mdsys.sdo_ordinate_array(null);
      v_vertices  mdsys.vertex_set_type;
      v_etype     pls_integer;
      v_start_coord mdsys.vertex_type;
      v_END_coord   mdsys.vertex_type;
    BEGIN
        v_ordinates.DELETE;
        v_dims        := p_geometry.get_dims();
        v_etype       := p_geometry.sdo_elem_info(2);
        v_vertices    := sdo_util.getVertices(p_geometry);
        v_start_coord := v_vertices(1);
        v_END_coord   := v_vertices(2);
        -- First coordinate
        ADD_Coordinate( v_ordinates, v_dims, v_start_coord.x, v_start_coord.y, v_start_coord.z, v_start_coord.w );
        -- Second coordinate
        If ( v_etype = 1003 ) Then
          ADD_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_start_coord.y,(v_start_coord.z + v_END_coord.z) /2, v_start_coord.w);
        Else
          ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_END_coord.y,(v_start_coord.z + v_END_coord.z) /2,
              (v_END_coord.w - v_start_coord.w) * ((v_END_coord.x - v_start_coord.x) /
             ((v_END_coord.x - v_start_coord.x) + (v_END_coord.y - v_start_coord.y)) ));
        END If;
        -- 3rd or middle coordinate
        ADD_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_END_coord.y,v_END_coord.z,v_END_coord.w);
        -- 4th coordinate
        If ( v_etype = 1003 ) Then
          ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_END_coord.y,(v_start_coord.z + v_END_coord.z) /2,v_start_coord.w);
        Else
          Add_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_start_coord.y,(v_start_coord.z + v_END_coord.z) /2,
              (v_END_coord.w - v_start_coord.w) * ((v_END_coord.x - v_start_coord.x) /
             ((v_END_coord.x - v_start_coord.x) + (v_END_coord.y - v_start_coord.y)) ));
        END If;
        -- Last coordinate
        ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_start_coord.y,v_start_coord.z,v_start_coord.w);
        return mdsys.SDO_GEOMETRY(p_geometry.sdo_gtype,p_geometry.sdo_srid,null,mdsys.sdo_elem_info_array(1,v_etype,1),v_ordinates);
    END Rectangle2Polygon;


    FUNCTION formatNumber(pos in number)
      return varchar2
    As
      v_temp number;
      v_result varchar2(100);
    BEGIN
      v_temp := round(pos, v_precision);

      if ((v_temp >=0) and (v_temp < 1)) then
        v_result := '0' || to_char(v_temp);
      elsif ((v_temp < 0) and (v_temp > -1)) then
        v_result := '-0' || to_char(abs(v_temp));
      else
        v_result := to_char(v_temp);
      END if;
      return v_result;
    END formatNumber;

    FUNCTION formatCoord(p_x        in number,
                         p_y        in number,
                         p_z        in number,
                         p_relative in boolean)
      return varchar2
    As
    BEGIN
        return '[' ||
               case when p_relative
                    then formatNumber(p_x - v_mbr.sdo_ordinates(1)) || ',' || formatNumber(p_y - v_mbr.sdo_ordinates(2))
                    else formatNumber(p_x) || ',' || formatNumber(p_y) || ',' || formatNumber(p_z)
                END ||
                ']';
    END formatCoord;

  BEGIN
     if ( p_geometry is null ) then
        return null;
    END if;

    -- Currently, we do not support compound objects
    --
    If ( p_geometry.get_gtype() not in (1,2,3,5,6,7) ) Then
      RETURN NULL;
    END If;

    EXECUTE IMMEDIATE 'ALTER SESSION set NLS_TERRITORY=''AMERICA''';
    EXECUTE IMMEDIATE 'ALTER SESSION set NLS_LANGUAGE=''AMERICAN''';

    DBMS_LOB.createtemporary (lob_loc => v_result, cache => TRUE);

    v_type := case when v_compress_tags
                   then case p_geometry.get_gtype()
                             when 1 then 'P'
                             when 2 then 'LS'
                             when 3 then 'PG'
                             when 5 then 'MP'
                             when 6 then 'MLS'
                             when 7 then 'MPG'
                         END
                   else case p_geometry.get_gtype()
                             when 1 then '"Point"'
                             when 2 then '"LineString"'
                             when 3 then '"Polygon"'
                             when 5 then '"MultiPoint"'
                             when 6 then '"MultiLineString"'
                             when 7 then '"MultiPolygon"'
                         END
               END;

    v_temp_string := '{';

    if ( p_geometry.get_gtype() = 1 ) then
        v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;
        if (p_geometry.SDO_POINT is not null ) then
            v_temp_string := v_temp_string || formatCoord(p_geometry.SDO_POINT.X, p_geometry.SDO_POINT.Y, p_geometry.SDO_POINT.Z, false);
        else
            v_temp_string := v_temp_string || formatCoord(p_geometry.sdo_ordinates(1), p_geometry.sdo_ordinates(2), p_geometry.sdo_ordinates(3), false);
        END If;
        v_temp_string := v_temp_string || '}';

        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => 1,
                       buffer => v_temp_string );
        return v_result;
    END If;

    if ( v_relative ) then
       v_mbr := SDO_GEOM.SDO_MBR(p_geometry);
       if ( v_mbr is not null ) then
           v_temp_string := v_temp_string ||
                            v_type_tag || v_feature_key || ',' ||
                            v_bbox_tag || '[' ||
                            v_mbr.sdo_ordinates(1) || ',' ||
                            v_mbr.sdo_ordinates(2) || ',' ||
                            v_mbr.sdo_ordinates(3) || ',' ||
                            v_mbr.sdo_ordinates(4) || ',' ||
                            '],' || v_geometry_tag || '{';
       END If;
    END If;
    v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;

    -- Write header
    DBMS_LOB.write(lob_loc => v_result,
                   amount => LENGTH (v_temp_string),
                   offset => 1,
                   buffer => v_temp_string);

    If ( hasCircularArcs(p_geometry.sdo_elem_info) ) then
        return null;
    END If;

    v_num_elements := mdsys.sdo_util.GetNumElem(p_geometry);
    <<for_all_elements>>
    FOR v_element_no IN 1..v_num_elements LOOP
       v_element := mdsys.sdo_util.Extract(p_geometry,v_element_no);   -- Extract element with all sub-elements
       If ( v_element.get_gtype() in (1,2,5) ) Then
          if (v_element_no = 1) Then
             v_temp_string := '[';
          elsif ( v_element.get_gtype() = 2 ) Then
             v_temp_string := '],[';
          END If;
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );
          v_vertices := mdsys.sdo_util.getVertices(v_element);
          v_temp_string := formatCoord(v_vertices(1).x,v_vertices(1).y,v_vertices(1).z,v_relative);
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );
          <<for_all_vertices>>
          for j in 2..v_vertices.count loop
              v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_vertices(j).z,v_relative);
              DBMS_LOB.write(lob_loc => v_result,
                             amount => LENGTH (v_temp_string),
                             offset => DBMS_LOB.GETLENGTH(v_result)+1,
                             buffer => v_temp_string );
          END loop for_all_vertices;
       Else
          if (v_element_no = 1) Then
             v_temp_string := '[';
          else
             v_temp_string := '],[';
          END If;
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );
          v_num_rings := GetNumRings(v_element);
          <<for_all_rings>>
          FOR v_ring_no in 1..v_num_rings Loop
            v_ring := MDSYS.SDO_UTIL.EXTRACT(p_geometry,v_element_no,v_ring_no);  -- Extract ring from element .. must do it this way, can't correctly extract from v_element.
            If (hasRectangles(v_ring.sdo_elem_info)>0) Then
               v_ring := Rectangle2Polygon(v_ring);
            END If;
            if ( v_ring_no > 1 ) Then
               v_temp_string := ',';
               DBMS_LOB.write(lob_loc => v_result,
                              amount => LENGTH (v_temp_string),
                              offset => DBMS_LOB.GETLENGTH(v_result)+1,
                              buffer => v_temp_string );
            END If;
            v_vertices := mdsys.sdo_util.getVertices(v_ring);
            v_temp_string := '[' || formatCoord(v_vertices(1).x,v_vertices(1).y,v_vertices(1).z,v_relative);
            DBMS_LOB.write(lob_loc => v_result,
                           amount => LENGTH (v_temp_string),
                           offset => DBMS_LOB.GETLENGTH(v_result)+1,
                           buffer => v_temp_string );

            <<for_all_vertices>>
            for j in 2..v_vertices.count loop
                v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_vertices(j).z,v_relative);
                DBMS_LOB.write(lob_loc => v_result,
                               amount => LENGTH (v_temp_string),
                               offset => DBMS_LOB.GETLENGTH(v_result)+1,
                               buffer => v_temp_string );
            END loop for_all_vertices;
            v_temp_string := ']';  -- Close Ring
            DBMS_LOB.write(lob_loc => v_result,
                           amount => LENGTH (v_temp_string),
                           offset => DBMS_LOB.GETLENGTH(v_result)+1,
                           buffer => v_temp_string );
          END Loop for_all_rings;
       END If;
    END LOOP for_all_elements;

    -- Closing tag
    v_temp_string := ']}';
    if ( v_relative and p_geometry.get_gtype() <> 1 ) then
        v_temp_string := v_temp_string || '}';
    END if;

    DBMS_LOB.write(lob_loc => v_result,
                   amount => LENGTH (v_temp_string),
                   offset => DBMS_LOB.GETLENGTH(v_result)+1,
                   buffer => v_temp_string );
    return v_result;
  END sdo2geojson3d;

  /* ----------------------------------------------------------------------------------------
  * Applies a 3d affine transformation to the geometry to do things like translate, rotate, scale in one step.
  * To apply a 2D affine transformation only supply a, b, d, e, xoff, yoff
  *
  * @return     : newGeom  : MDSYS.SDO_GEOMETRY : Transformed input geometry.
  *
  * @param      : p_geom  : MDSYS.SDO_GEOMETRY : The geometry to transform.
  * @param      : a, b, c, d, e, f, g, h, i, xoff, yoff, zoff :
  *               Represent the transformation matrix
  *                 / a  b  c  xoff \
  *                 | d  e  f  yoff |
  *                 | g  h  i  zoff |
  *                 \ 0  0  0     1 /
  *               and the vertices are transformed as follows:
  *                 x' = a*x + b*y + c*z + xoff
  *                 y' = d*x + e*y + f*z + yoff
  *                 z' = g*x + h*y + i*z + zoff
  *
  * Adapted from https://spatialdbadvisor.com/oracle_spatial_tips_tricks/296/affine-wrappers-for-sdo_utilaffine
  **/
  FUNCTION ST_Affine(
    p_geometry IN mdsys.SDO_GEOMETRY,
    p_a IN NUMBER,
    p_b IN NUMBER,
    p_c IN NUMBER,
    p_d IN NUMBER,
    p_e IN NUMBER,
    p_f IN NUMBER,
    p_g IN NUMBER,
    p_h IN NUMBER,
    p_i IN NUMBER,
    p_xoff IN NUMBER,
    p_yoff IN NUMBER,
    p_zoff IN NUMBER) RETURN mdsys.SDO_GEOMETRY
  IS
    -- Transformation matrix is represented by:
    -- / a  b  c  xoff \
    -- | d  e  f  yoff |
    -- | g  h  i  zoff |
    -- \ 0  0  0     1 /
    --
    -- For 2D only need to supply: a, b, d, e, xoff, yoff
    v_A SYS.UTL_NLA_ARRAY_DBL := SYS.UTL_NLA_ARRAY_DBL(
      p_a, p_d, NVL(p_g, 0), 0,
      p_b, p_e, NVL(p_h,0), 0,
      NVL(p_c, 0), NVL(p_f, 0), NVL(p_i, 1), 0,
      p_xoff, p_yoff, NVL(p_zoff, 0), 1); -- column wise 4x4 matrix A

    v_x SYS.UTL_NLA_ARRAY_DBL; -- vector x to be transformed
    v_y SYS.UTL_NLA_ARRAY_DBL; -- result vector y = Ax

    -- Geometry variables
    v_dims PLS_Integer;
    v_ord PLS_Integer;
    v_sdo_point mdsys.sdo_point_type;
    v_trans_point mdsys.sdo_point_type;
    v_vertices mdsys.vertex_set_type;
    v_ordinates mdsys.sdo_ordinate_array;

    -- exceptions
    NULL_GEOMETRY  EXCEPTION;
    NULL_PARAMETER EXCEPTION;

    FUNCTION TransformPoint(
      p_x IN NUMBER,
      p_y IN NUMBER,
      p_z IN NUMBER) RETURN mdsys.sdo_point_type
    IS
    BEGIN
      v_x := SYS.UTL_NLA_ARRAY_DBL(p_x, p_y, p_z, 1);
      v_y := SYS.UTL_NLA_ARRAY_DBL();

      --  Vertices are transformed as follows:
      --  x' = a*x + b*y + c*z + xoff
      --  y' = d*x + e*y + f*z + yoff
      --  z' = g*x + h*y + i*z + zoff
      SYS.UTL_NLA.BLAS_GEMV(
        trans  => 'N',
        m      => 4,
        n      => 4,
        alpha  => 1,
        a      => v_A,
        lda    => 4,
        x      => v_x,
        incx   => 1,
        beta   => 0,
        y      => v_y,
        incy   => 1,
        pack   => 'C');

      RETURN mdsys.sdo_point_type(v_y(1), v_y(2), v_y(3));
    END TransformPoint;

  BEGIN
    IF p_geometry IS NULL THEN
      raise NULL_GEOMETRY;
    END IF;

    IF p_a IS NULL OR p_b IS NULL OR p_d IS NULL OR p_e IS NULL OR p_xoff IS NULL OR p_yoff IS NULL THEN
      raise NULL_PARAMETER;
    END IF;

    -- Transform a point in the geometry object
    IF p_geometry.sdo_point IS NOT NULL THEN
      v_sdo_point := TransformPoint(p_geometry.sdo_point.x, p_geometry.sdo_point.y, p_geometry.sdo_point.z);
    END IF;

    -- Transform coordinates of the geometry object
    v_dims := p_geometry.get_dims();
    IF p_geometry.sdo_ordinates IS NOT NULL THEN
      v_ordinates := mdsys.sdo_ordinate_array();
      v_ordinates.EXTEND(p_geometry.sdo_ordinates.COUNT);
      v_ord := 1;

      -- Loop around coordinates and apply matrix to them.
      v_vertices := mdsys.sdo_util.getVertices(p_geometry);
      FOR v_id IN v_vertices.FIRST..v_vertices.LAST
      LOOP
        v_trans_point := TransformPoint(v_vertices(v_id).x, v_vertices(v_id).y, NVL(v_vertices(v_id).z, 0));
        v_ordinates(v_ord) := v_trans_point.x;
        v_ord := v_ord + 1;
        v_ordinates(v_ord) := v_trans_point.y;
        v_ord := v_ord + 1;
        IF v_dims >= 3 THEN
          v_ordinates(v_ord) := v_trans_point.z;
          v_ord := v_ord + 1;
        END IF;
      END LOOP;
    END IF;

    RETURN mdsys.SDO_GEOMETRY(p_geometry.sdo_gtype, p_geometry.sdo_srid, v_sdo_point, p_geometry.sdo_elem_info, v_ordinates);

  EXCEPTION
    WHEN NULL_GEOMETRY THEN
      raise_application_error(-20120, 'Input geometry must not be null', TRUE);
    WHEN NULL_PARAMETER THEN
      raise_application_error(-20127, 'Input parameters must not be null', TRUE);
  END ST_Affine;

  /*****************************************************************
  * drop_tmp_tables
  *
  * drop all tables prefixed with "tmp_"
  *
  * @param schema_name name of user schema
  ******************************************************************/
  PROCEDURE drop_tmp_tables(
    schema_name VARCHAR2 := USER
    )
  IS
  BEGIN
    FOR rec IN (
      SELECT
        table_name
      FROM
        all_tables
      WHERE
        owner = upper(schema_name)
        AND table_name LIKE '%TMP_%'
    ) LOOP
        EXECUTE IMMEDIATE
          'DROP TABLE '
          || upper(schema_name) || '.' || upper(rec.table_name);
    END LOOP;
  END;

END citydb_util;
/