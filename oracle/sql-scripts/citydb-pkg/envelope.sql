/*****************************************************************
* CONTENT: PL/SQL Package CITYDB_ENVELOPE
*
* FUNCTIONS:
*   - get_feature_envelope
*   - box2envelope
*   - update_bounds
*   - calc_implicit_geometry_envelope
******************************************************************/

-- Package declaration
CREATE OR REPLACE PACKAGE citydb_envelope AS
  FUNCTION get_feature_envelope (
    fid NUMBER,
    set_envelope INTEGER DEFAULT 0
  ) RETURN SDO_GEOMETRY;
  FUNCTION box2envelope (
    box SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY;
  FUNCTION update_bounds (
    old_bbox SDO_GEOMETRY,
    new_bbox SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY;
  FUNCTION calc_implicit_geometry_envelope (
    gid NUMBER,
    ref_pt SDO_GEOMETRY,
    matrix VARCHAR2
  ) RETURN SDO_GEOMETRY;
--  TYPE params_array AS VARRAY(16) OF DOUBLE;
END citydb_envelope;
/

-- Package body definition
CREATE OR REPLACE PACKAGE BODY citydb_envelope
AS

/*****************************************************************
* returns the envelope geometry of a given feature
* if the parameter set_envelope = 1 (default = 0), the ENVELOPE column of the FEATURE table will be updated
******************************************************************/
  FUNCTION get_feature_envelope (
    fid number,
    set_envelope integer default 0
  ) RETURN SDO_GEOMETRY IS
    bbox SDO_GEOMETRY;
    bbox_tmp SDO_GEOMETRY;

  BEGIN

    FOR rec IN (
      SELECT
        p.val_feature_id
      FROM
        property p
      WHERE
        p.id = fid AND p.val_feature_id IS NOT NULL AND p.val_relation_type = 1
    ) LOOP
      bbox_tmp := citydb_pkg.get_feature_envelope(rec.id, set_envelope);
      bbox := citydb_pkg.update_bounds(bbox, bbox_tmp);
    END LOOP;

    SELECT
      citydb_pkg.box2envelope(SDO_GEOM_MBR(geom)) INTO bbox_tmp
    FROM (
      SELECT
        gd.geometry AS geom
      FROM
        geometry_data gd, property p
      WHERE
        gd.id = p.val_geometry_id AND p.feature_id = fid AND gd.geometry IS NOT NULL
      UNION ALL
      SELECT
        citydb_pkg.calc_implicit_geometry_envelope(val_implicitgeom_id, val_implicitgeom_refpoint, val_array, schema_name) AS geom
      FROM
        property p
      WHERE
        p.feature_id = fid AND p.val_implicitgeom_id IS NOT NULL
    ) g;

    bbox := citydb_pkg.update_bounds(bbox, bbox_tmp);

    IF set_envelope <> 0 THEN
      UPDATE feature SET envelope = bbox WHERE id = fid;
    END IF;

    RETURN bbox;

  END;
  -- End of function

/*****************************************************************
* returns the envelope geometry of a given
******************************************************************/

  FUNCTION box2envelope (
    box SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY IS
    bbox    SDO_GEOMETRY;
    db_srid NUMBER;

  BEGIN
    IF box IS NULL THEN
      RETURN NULL;
    ELSE
      -- get reference system of input geometry
      IF box.sdo_srid IS NULL OR box.sdo_srid = 0 THEN
        SELECT
          srid
        INTO
          db_srid
        FROM
          database_srs;
      ELSE
        db_srid := box.sdo_srid;
      END IF;

      -- Return 3D geometry with its 3D CRS.
      -- If the SRID is not specified in the input geometry, then set it to the default defined in DATABASE_SRS.
      bbox := MDSYS.SDO_GEOMETRY(
        3003,
        db_srid,
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
          SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 1), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 2), SDO_GEOM.SDO_MAX_MBR_ORDINATE(box, 3),
        )
      );
    END IF;
    RETURN bbox;

  END;
  -- End of function


/*****************************************************************
* returns the envelope geometry of two bounding boxes
******************************************************************/
  FUNCTION citydb_pkg.update_bounds(
    old_bbox SDO_GEOMETRY,
    new_bbox SDO_GEOMETRY
  ) RETURN SDO_GEOMETRY IS

  BEGIN

    IF old_bbox IS NULL AND new_bbox IS NULL THEN
      RETURN NULL;
    ELSE
      IF old_bbox IS NULL THEN
        RETURN new_bbox;
      END IF;

      IF new_bbox IS NULL THEN
        RETURN old_bbox;
      END IF;

      RETURN citydb_pkg.box2envelope(SDO_GEOM_MBR(SDO_UTIL.APPEND(old_bbox, new_bbox)));
    END IF;
  END;
  -- End of function

/*****************************************************************
* returns the envelope geometry of a given implicit geometry
******************************************************************/

--
-- Translation to PL/SQL yet finished
--

  FUNCTION citydb_pkg.calc_implicit_geometry_envelope(
    gid NUMBER,
    ref_pt SDO_GEOMETRY,
    matrix JSON
  ) RETURN SDO_GEOMETRY IS
    envelope SDO_GEOMETRY;

  BEGIN

    --params := params_array();

    SELECT
      SDO_GEOM_MBR(gd.implicit_geometry) INTO envelope
    FROM
      geometry_data gd,
      implicit_geometry ig
    WHERE
      gd.id = ig.relative_geometry_id AND ig.id = gid AND gd.implicit_geometry IS NOT NULL;

    IF matrix IS NOT NULL THEN
      params := ARRAY(SELECT json_array_elements_text(matrix))::float8[];
      IF array_length(params, 1) < 12 THEN
        RAISE EXCEPTION 'Malformed transformation matrix: %', matrix USING HINT = '16 values are required';
      END IF;
    ELSE
      params := '{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1}';
    END IF;

    IF ref_pt IS NOT NULL THEN
      params[4] := params[4] + SDO_POINT.X(ref_pt);
      params[8] := params[8] + SDO_POINT.Y(ref_pt);
      params[12] := params[12] + SDO_POINT.Z(ref_pt);
    END IF;

    IF envelope IS NOT NULL THEN
      envelope := SDO_UTIL.AFFINETRANSFORMS(
        param => envelope,
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
        param => params[12]);
    END IF;

    RETURN envelope;
  END;


-- End of package body
END citydb_envelope;
/