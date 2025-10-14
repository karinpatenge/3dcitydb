-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: Okt 14, 2025
-- Status: work in progress
-----------------------------------------------------

SET SERVEROUTPUT ON
SET FEEDBACK ON

--
-- Register SDO metadata
--

-- ENTRIES INTO USER_SDO_GEOM_METADATA WITH BOUNDING VOLUME WITH 10000km EXTENT FOR X,Y AND 11km FOR Z


--
-- Create spatial indexes
--

CREATE INDEX address_multipoint_sidx ON address (multi_point) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX feature_envelope_sidx ON feature (envelope) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX geometry_data_geometry_sidx ON geometry_data (geometry) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX property_val_implicitgeom_refpoint_sidx ON property (val_implicitgeom_refpoint) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2 (PARAMETERS 'layer_gtype=point');
CREATE INDEX surface_data_gt_reference_point_sidx ON surface_data (gt_reference_point) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2 (PARAMETERS 'layer_gtype=point');
