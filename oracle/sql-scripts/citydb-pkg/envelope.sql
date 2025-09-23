-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: September 2025
-- Status: work in progress
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

/*****************************************************************
 * CONTENT: PL/SQL Package CITYDB_ENVELOPE
 *
 * Methods to handle ...
 *****************************************************************/

-- Package declaration
CREATE OR REPLACE PACKAGE citydb_envelope AS

  --  TYPE params_array AS VARRAY(16) OF DOUBLE;

  FUNCTION get_feature_envelope (p_fid NUMBER, p_set_envelope INTEGER DEFAULT 0) RETURN SDO_GEOMETRY;
  FUNCTION box2envelope (p_box SDO_GEOMETRY) RETURN SDO_GEOMETRY;
  FUNCTION update_bounds (p_old_bbox SDO_GEOMETRY, p_new_bbox SDO_GEOMETRY) RETURN SDO_GEOMETRY;
  FUNCTION calc_implicit_geometry_envelope (p_gid NUMBER, p_ref_pt SDO_GEOMETRY, p_matrix VARCHAR2) RETURN SDO_GEOMETRY;

END citydb_envelope;
-- End of package declaration
/

-- Package body definition
CREATE OR REPLACE PACKAGE BODY citydb_envelope
AS

  /*****************************************************************
  * returns the envelope geometry of a given feature
  * if the parameter p_set_envelope = 1 (default = 0), the ENVELOPE column of the FEATURE table will be updated
  ******************************************************************/
  FUNCTION get_feature_envelope (
    p_fid number,
    p_set_envelope integer default 0
  ) RETURN SDO_GEOMETRY
  IS
    v_bbox SDO_GEOMETRY;
    v_bbox_tmp SDO_GEOMETRY;

  BEGIN

    FOR rec IN (
      SELECT
        p.val_feature_id
      FROM
        property p
      WHERE
        p.id = p_fid AND p.val_feature_id IS NOT NULL AND p.val_relation_type = 1
    ) LOOP
      v_bbox_tmp := citydb_pkg.get_feature_envelope(rec.id, p_set_envelope);
      v_bbox := citydb_pkg.update_bounds(v_bbox, v_bbox_tmp);
    END LOOP;

    SELECT
      citydb_pkg.box2envelope(SDO_GEOM_MBR(geom)) INTO v_bbox_tmp
    FROM (
      SELECT
        gd.geometry AS geom
      FROM
        geometry_data gd, property p
      WHERE
        gd.id = p.val_geometry_id AND p.feature_id = p_fid AND gd.geometry IS NOT NULL
      UNION ALL
      SELECT
        citydb_pkg.calc_implicit_geometry_envelope(val_implicitgeom_id, val_implicitgeom_refpoint, val_array, schema_name) AS geom
      FROM
        property p
      WHERE
        p.feature_id = p_fid AND p.val_implicitgeom_id IS NOT NULL
    ) g;

    v_bbox := citydb_pkg.update_bounds(v_bbox, v_bbox_tmp);

    IF p_set_envelope <> 0 THEN
      UPDATE feature SET envelope = v_bbox WHERE id = p_fid;
    END IF;

    RETURN v_bbox;

  END;
  -- End of function

  /*****************************************************************
  * returns the envelope geometry of a given
  ******************************************************************/

  FUNCTION box2envelope (
    p_box SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY
  IS
    v_bbox    SDO_GEOMETRY;
    v_srid NUMBER;

  BEGIN
    IF p_box IS NULL THEN
      RETURN NULL;
    ELSE
      -- get reference system of input geometry
      IF p_box.sdo_srid IS NULL OR p_box.sdo_srid = 0 THEN
        SELECT
          srid
        INTO
          v_srid
        FROM
          database_srs;
      ELSE
        v_srid := p_box.sdo_srid;
      END IF;

      -- Return 3D geometry with its 3D CRS.
      -- If the SRID is not specified in the input geometry, then set it to the default defined in DATABASE_SRS.
      v_bbox := SDO_GEOMETRY(
        3003,
        v_srid,
        NULL,
  /*
          MDSYS.sdo_elem_info_array(1, 1003, 1),
          MDSYS.sdo_ordinate_array(
            SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 3),
            SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 3),
            SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 3),
            SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 3),
            SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 3)
  */
        MDSYS.sdo_elem_info_array(1, 1003, 3),
        MDSYS.sdo_ordinate_array(
          SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MIN_MBR_ORDINATE(box, 3),
          SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 3)
        )
      );
    END IF;
    RETURN v_bbox;
  END box2envelope;
  -- End of function

  /*****************************************************************
  * returns the envelope geometry of two bounding boxes
  ******************************************************************/
  FUNCTION citydb_pkg.update_bounds (
    p_old_bbox SDO_GEOMETRY,
    p_new_bbox SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY
  IS

  BEGIN

    IF p_old_bbox IS NULL AND p_new_bbox IS NULL THEN
      RETURN NULL;
    ELSE
      IF p_old_bbox IS NULL THEN
        RETURN p_new_bbox;
      END IF;

      IF p_new_bbox IS NULL THEN
        RETURN p_old_bbox;
      END IF;

      RETURN citydb_pkg.box2envelope(SDO_GEOM_MBR(SDO_UTIL.APPEND(p_old_bbox, p_new_bbox)));
    END IF;
  END update_bounds;
  -- End of function

  /*****************************************************************
  * returns the envelope geometry of a given implicit geometry
  ******************************************************************/

  FUNCTION citydb_pkg.calc_implicit_geometry_envelope (
    p_gid NUMBER,
    p_ref_pt SDO_GEOMETRY,
    p_matrix JSON
  ) RETURN SDO_GEOMETRY
  IS
    v_envelope SDO_GEOMETRY;

  BEGIN

    --params := params_array();

    SELECT
      SDO_GEOM_MBR(gd.implicit_geometry) INTO v_envelope
    FROM
      geometry_data gd,
      implicit_geometry ig
    WHERE
      gd.id = ig.relative_geometry_id AND ig.id = p_gid AND gd.implicit_geometry IS NOT NULL;

/* ToDo from here

    IF p_matrix IS NOT NULL THEN
      params := ARRAY(SELECT json_array_elements_text(matrix))::float8[];
      IF array_length(params, 1) < 12 THEN
        RAISE EXCEPTION 'Malformed transformation matrix: %', matrix USING HINT = '16 values are required';
      END IF;
    ELSE
      params := '{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
      }';
    END IF;

  till here */

    IF p_ref_pt IS NOT NULL THEN
      params[4] := params[4] + SDO_POINT.X(p_ref_pt);
      params[8] := params[8] + SDO_POINT.Y(p_ref_pt);
      params[12] := params[12] + SDO_POINT.Z(p_ref_pt);
    END IF;

    IF envelope IS NOT NULL THEN
      v_envelope := SDO_UTIL.AFFINETRANSFORMS(
        param => v_envelope,
        param => params[1],
        param => params[2],
        param => params[3],
        param => params[5],
        param => params[6],
        param => params[7],
        param => params[9],
        param => params[10],
        param => params[11],
        param => params[4],
        param => params[8],
        param => params[12]
      );
    END IF;

    RETURN v_envelope;
  END calc_implicit_geometry_envelope;
  -- End of function

END citydb_envelope;
-- End of package body
/