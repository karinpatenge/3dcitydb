-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: July 2025
-- Status: to be reviewed
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

-----------------------------------------------------
-- Notes for reviewers:
--   Check BFILE approach.
--   Alternative approach: Create domains with JSON VALIDATE'<json-schema>'
--     (See https://blogs.oracle.com/coretec/post/less-coding-with-sql-domains-in-23c)
-----------------------------------------------------

TRUNCATE TABLE datatype DROP STORAGE;

-- Core Module --
CREATE OR REPLACE DIRECTORY dt_core_dir AS '/schema-mapping/data-types/core';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1, null, 'Undefined', 1, 1, BFILENAME('DT_CORE_DIR','Undefined.json')),
  (2, null, 'Boolean', 0, 1, BFILENAME('DT_CORE_DIR','Boolean.json')),
  (3, null, 'Integer', 0, 1, BFILENAME('DT_CORE_DIR','Integer.json')),
  (4, null, 'Double', 0, 1, BFILENAME('DT_CORE_DIR','Double.json')),
  (5, null, 'String', 0, 1, BFILENAME('DT_CORE_DIR','String.json')),
  (6, null, 'URI', 0, 1, BFILENAME('DT_CORE_DIR','URI.json')),
  (7, null, 'Timestamp', 0, 1, BFILENAME('DT_CORE_DIR','Timestamp.json')),
  (8, null, 'AddressProperty', 0, 1, BFILENAME('DT_CORE_DIR','AddressProperty.json')),
  (9, null, 'AppearanceProperty', 0, 1, BFILENAME('DT_CORE_DIR','AppearanceProperty.json')),
  (10, null, 'FeatureProperty', 0, 1, BFILENAME('DT_CORE_DIR','FeatureProperty.json')),
  (11, null, 'GeometryProperty', 0, 1, BFILENAME('DT_CORE_DIR','GeometryProperty.json')),
  (12, null, 'Reference', 0, 1, BFILENAME('DT_CORE_DIR','Reference.json')),
  (13, null, 'CityObjectRelation', 0, 1, BFILENAME('DT_CORE_DIR','CityObjectRelation.json')),
  (14, null, 'Code', 0, 1, BFILENAME('DT_CORE_DIR','Code.json')),
  (15, null, 'ExternalReference', 0, 1, BFILENAME('DT_CORE_DIR','ExternalReference.json')),
  (16, null, 'ImplicitGeometryProperty', 0, 1, BFILENAME('DT_CORE_DIR','ImplicitGeometryProperty.json')),
  (17, null, 'Measure', 0, 1, BFILENAME('DT_CORE_DIR','Measure.json')),
  (18, null, 'MeasureOrNilReasonList', 0, 1, BFILENAME('DT_CORE_DIR','MeasureOrNilReasonList.json')),
  (19, null, 'Occupancy', 0, 1, BFILENAME('DT_CORE_DIR','Occupancy.json')),
  (20, null, 'QualifiedArea', 0, 1, BFILENAME('DT_CORE_DIR','QualifiedArea.json')),
  (21, null, 'QualifiedVolume', 0, 1, BFILENAME('DT_CORE_DIR','QualifiedVolume.json')),
  (22, null, 'StringOrRef', 0, 1, BFILENAME('DT_CORE_DIR','StringOrRef.json')),
  (23, null, 'TimePosition', 0, 1, BFILENAME('DT_CORE_DIR','TimePosition.json')),
  (24, null, 'Duration', 0, 1, BFILENAME('DT_CORE_DIR','Duration.json')),
  (50, null, 'ADEOfAbstractCityObject', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractCityObject.json')),
  (51, null, 'ADEOfAbstractDynamizer', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractDynamizer.json')),
  (52, null, 'ADEOfAbstractFeature', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractFeature.json')),
  (53, null, 'ADEOfAbstractFeatureWithLifespan', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractFeatureWithLifespan.json')),
  (54, null, 'ADEOfAbstractLogicalSpace', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractLogicalSpace.json')),
  (55, null, 'ADEOfAbstractOccupiedSpace', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractOccupiedSpace.json')),
  (56, null, 'ADEOfAbstractPhysicalSpace', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractPhysicalSpace.json')),
  (57, null, 'ADEOfAbstractPointCloud', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractPointCloud.json')),
  (58, null, 'ADEOfAbstractSpace', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractSpace.json')),
  (59, null, 'ADEOfAbstractSpaceBoundary', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractSpaceBoundary.json')),
  (60, null, 'ADEOfAbstractThematicSurface', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractThematicSurface.json')),
  (61, null, 'ADEOfAbstractUnoccupiedSpace', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractUnoccupiedSpace.json')),
  (62, null, 'ADEOfAbstractVersion', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractVersion.json')),
  (63, null, 'ADEOfAbstractVersionTransition', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfAbstractVersionTransition.json')),
  (64, null, 'ADEOfCityModel', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfCityModel.json')),
  (65, null, 'ADEOfClosureSurface', 1, 1, BFILENAME('DT_CORE_DIR','ADEOfClosureSurface.json'));

COMMIT;

-- Dynamizer Module --

CREATE OR REPLACE DIRECTORY dt_dyn_dir AS '/schema-mapping/data-types/dynamizer';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (100, null, 'AbstractTimeValuePair', 1, 2, BFILENAME('DT_DYN_DIR','AbstractTimeValuePair.json')),
  (101, null, 'AttributeReference', 0, 2, BFILENAME('DT_DYN_DIR','AttributeReference.json')),
  (102, null, 'SensorConnection', 0, 2, BFILENAME('DT_DYN_DIR','SensorConnection.json')),
  (103, 100, 'TimeAppearance', 0, 2, BFILENAME('DT_DYN_DIR','TimeAppearance.json')),
  (104, 100, 'TimeBoolean', 0, 2, BFILENAME('DT_DYN_DIR','TimeBoolean.json')),
  (105, 100, 'TimeDouble', 0, 2, BFILENAME('DT_DYN_DIR','TimeDouble.json')),
  (106, 100, 'TimeGeometry', 0, 2, BFILENAME('DT_DYN_DIR','TimeGeometry.json')),
  (107, 100, 'TimeImplicitGeometry', 0, 2, BFILENAME('DT_DYN_DIR','TimeImplicitGeometry.json')),
  (108, 100, 'TimeInteger', 0, 2, BFILENAME('DT_DYN_DIR','TimeInteger.json')),
  (109, null, 'TimeseriesComponent', 0, 2, BFILENAME('DT_DYN_DIR','TimeseriesComponent.json')),
  (110, 100, 'TimeString', 0, 2, BFILENAME('DT_DYN_DIR','TimeString.json')),
  (111, 100, 'TimeURI', 0, 2, BFILENAME('DT_DYN_DIR','TimeURI.json')),
  (112, null, 'ADEOfAbstractAtomicTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfAbstractAtomicTimeseries.json')),
  (113, null, 'ADEOfAbstractTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfAbstractTimeseries.json')),
  (114, null, 'ADEOfCompositeTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfCompositeTimeseries.json')),
  (115, null, 'ADEOfDynamizer', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfDynamizer.json')),
  (116, null, 'ADEOfGenericTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfGenericTimeseries.json')),
  (117, null, 'ADEOfStandardFileTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfStandardFileTimeseries.json')),
  (118, null, 'ADEOfTabulatedFileTimeseries', 1, 2, BFILENAME('DT_DYN_DIR','ADEOfTabulatedFileTimeseries.json'));

COMMIT;

-- Generics Module --

CREATE OR REPLACE DIRECTORY dt_gen_dir AS '/schema-mapping/data-types/generics';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (200, null, 'GenericAttributeSet', 0, 3, BFILENAME('DT_GEN_DIR','GenericAttributeSet.json')),
  (201, null, 'ADEOfGenericLogicalSpace', 1, 3, BFILENAME('DT_GEN_DIR','ADEOfGenericLogicalSpace.json')),
  (202, null, 'ADEOfGenericOccupiedSpace', 1, 3, BFILENAME('DT_GEN_DIR','ADEOfGenericOccupiedSpace.json')),
  (203, null, 'ADEOfGenericThematicSurface', 1, 3, BFILENAME('DT_GEN_DIR','ADEOfGenericThematicSurface.json')),
  (204, null, 'ADEOfGenericUnoccupiedSpace', 1, 3, BFILENAME('DT_GEN_DIR','ADEOfGenericUnoccupiedSpace.json'));

COMMIT;

-- LandUse Module --

CREATE OR REPLACE DIRECTORY dt_luse_dir AS '/schema-mapping/data-types/landuse';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (300, null, 'ADEOfLandUse', 1, 4, BFILENAME('DT_LUSE_DIR','ADEOfLandUse.json'));

COMMIT;

-- PointCloud Module --

CREATE OR REPLACE DIRECTORY dt_pcl_dir AS '/schema-mapping/data-types/pointcloud';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (400, null, 'ADEOfPointCloud', 1, 5, BFILENAME('DT_PCL_DIR','ADEOfPointCloud.json'));

COMMIT;

-- Relief Module --

CREATE OR REPLACE DIRECTORY DT_DEM_DIR AS '/schema-mapping/data-types/relief';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (500, null, 'ADEOfAbstractReliefComponent', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfAbstractReliefComponent.json')),
  (501, null, 'ADEOfBreaklineRelief', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfBreaklineRelief.json')),
  (502, null, 'ADEOfMassPointRelief', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfMassPointRelief.json')),
  (503, null, 'ADEOfRasterRelief', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfRasterRelief.json')),
  (504, null, 'ADEOfReliefFeature', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfReliefFeature.json')),
  (505, null, 'ADEOfTINRelief', 1, 6, BFILENAME('DT_DEM_DIR','ADEOfTINRelief.json'));

COMMIT;

-- Transportation Module --

CREATE OR REPLACE DIRECTORY dt_tran_dir AS '/schema-mapping/data-types/transportation';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (600, null, 'ADEOfAbstractTransportationSpace', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfAbstractTransportationSpace.json')),
  (601, null, 'ADEOfAuxiliaryTrafficArea', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfAuxiliaryTrafficArea.json')),
  (602, null, 'ADEOfAuxiliaryTrafficSpace', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfAuxiliaryTrafficSpace.json')),
  (603, null, 'ADEOfClearanceSpace', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfClearanceSpace.json')),
  (604, null, 'ADEOfHole', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfHole.json')),
  (605, null, 'ADEOfHoleSurface', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfHoleSurface.json')),
  (606, null, 'ADEOfIntersection', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfIntersection.json')),
  (607, null, 'ADEOfMarking', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfMarking.json')),
  (608, null, 'ADEOfRailway', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfRailway.json')),
  (609, null, 'ADEOfRoad', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfRoad.json')),
  (610, null, 'ADEOfSection', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfSection.json')),
  (611, null, 'ADEOfSquare', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfSquare.json')),
  (612, null, 'ADEOfTrack', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfTrack.json')),
  (613, null, 'ADEOfTrafficArea', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfTrafficArea.json')),
  (614, null, 'ADEOfTrafficSpace', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfTrafficSpace.json')),
  (615, null, 'ADEOfWaterway', 1, 7, BFILENAME('DT_TRAN_DIR','ADEOfWaterway.json'));

COMMIT;

-- Construction Module --

CREATE OR REPLACE DIRECTORY dt_con_dir AS '/schema-mapping/data-types/construction';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (700, null, 'ConstructionEvent', 0, 8, BFILENAME('DT_CON_DIR','ConstructionEvent.json')),
  (701, null, 'Elevation', 0, 8, BFILENAME('DT_CON_DIR','Elevation.json')),
  (702, null, 'Height', 0, 8, BFILENAME('DT_CON_DIR','Height.json')),
  (703, null, 'ADEOfAbstractConstruction', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractConstruction.json')),
  (704, null, 'ADEOfAbstractConstructionSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractConstructionSurface.json')),
  (705, null, 'ADEOfAbstractConstructiveElement', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractConstructiveElement.json')),
  (706, null, 'ADEOfAbstractFillingElement', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractFillingElement.json')),
  (707, null, 'ADEOfAbstractFillingSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractFillingSurface.json')),
  (708, null, 'ADEOfAbstractFurniture', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractFurniture.json')),
  (709, null, 'ADEOfAbstractInstallation', 1, 8, BFILENAME('DT_CON_DIR','ADEOfAbstractInstallation.json')),
  (710, null, 'ADEOfCeilingSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfCeilingSurface.json')),
  (711, null, 'ADEOfDoor', 1, 8, BFILENAME('DT_CON_DIR','ADEOfDoor.json')),
  (712, null, 'ADEOfDoorSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfDoorSurface.json')),
  (713, null, 'ADEOfFloorSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfFloorSurface.json')),
  (714, null, 'ADEOfGroundSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfGroundSurface.json')),
  (715, null, 'ADEOfInteriorWallSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfInteriorWallSurface.json')),
  (716, null, 'ADEOfOtherConstruction', 1, 8, BFILENAME('DT_CON_DIR','ADEOfOtherConstruction.json')),
  (717, null, 'ADEOfOuterCeilingSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfOuterCeilingSurface.json')),
  (718, null, 'ADEOfOuterFloorSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfOuterFloorSurface.json')),
  (719, null, 'ADEOfRoofSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfRoofSurface.json')),
  (720, null, 'ADEOfWallSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfWallSurface.json')),
  (721, null, 'ADEOfWindow', 1, 8, BFILENAME('DT_CON_DIR','ADEOfWindow.json')),
  (722, null, 'ADEOfWindowSurface', 1, 8, BFILENAME('DT_CON_DIR','ADEOfWindowSurface.json'));

COMMIT;

-- Tunnel Module --

CREATE OR REPLACE DIRECTORY dt_tun_dir AS '/schema-mapping/data-types/tunnel';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (800, null, 'ADEOfAbstractTunnel', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfAbstractTunnel.json')),
  (801, null, 'ADEOfHollowSpace', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfHollowSpace.json')),
  (802, null, 'ADEOfTunnel', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfTunnel.json')),
  (803, null, 'ADEOfTunnelConstructiveElement', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfTunnelConstructiveElement.json')),
  (804, null, 'ADEOfTunnelFurniture', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfTunnelFurniture.json')),
  (805, null, 'ADEOfTunnelInstallation', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfTunnelInstallation.json')),
  (806, null, 'ADEOfTunnelPart', 1, 9, BFILENAME('DT_TUN_DIR','ADEOfTunnelPart.json'));

COMMIT;

-- Building Module --

CREATE OR REPLACE DIRECTORY dt_bldg_dir AS '/schema-mapping/data-types/building';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (900, null, 'RoomHeight', 0, 10, BFILENAME('DT_BLDG_DIR','RoomHeight.json')),
  (901, null, 'ADEOfAbstractBuilding', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfAbstractBuilding.json')),
  (902, null, 'ADEOfAbstractBuildingSubdivision', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfAbstractBuildingSubdivision.json')),
  (903, null, 'ADEOfBuilding', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuilding.json')),
  (904, null, 'ADEOfBuildingConstructiveElement', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingConstructiveElement.json')),
  (905, null, 'ADEOfBuildingFurniture', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingFurniture.json')),
  (906, null, 'ADEOfBuildingInstallation', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingInstallation.json')),
  (907, null, 'ADEOfBuildingPart', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingPart.json')),
  (908, null, 'ADEOfBuildingRoom', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingRoom.json')),
  (909, null, 'ADEOfBuildingUnit', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfBuildingUnit.json')),
  (910, null, 'ADEOfStorey', 1, 10, BFILENAME('DT_BLDG_DIR','ADEOfStorey.json'));

COMMIT;

-- Bridge Module --

CREATE OR REPLACE DIRECTORY dt_brid_dir AS '/schema-mapping/data-types/bridge';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1000, null, 'ADEOfAbstractBridge', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfAbstractBridge.json')),
  (1001, null, 'ADEOfBridge', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridge.json')),
  (1002, null, 'ADEOfBridgeConstructiveElement', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridgeConstructiveElement.json')),
  (1003, null, 'ADEOfBridgeFurniture', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridgeFurniture.json')),
  (1004, null, 'ADEOfBridgeInstallation', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridgeInstallation.json')),
  (1005, null, 'ADEOfBridgePart', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridgePart.json')),
  (1006, null, 'ADEOfBridgeRoom', 1, 11, BFILENAME('DT_BRID_DIR','ADEOfBridgeRoom.json'));

COMMIT;

-- CityObjectGroup Module --

CREATE OR REPLACE DIRECTORY dt_grp_dir AS '/schema-mapping/data-types/cityobjectgroup';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1200, null, 'Role', 0, 13, BFILENAME('DT_GRP_DIR','Role.json')),
  (1201, null, 'ADEOfCityObjectGroup', 1, 13, BFILENAME('DT_GRP_DIR','ADEOfCityObjectGroup.json'));

COMMIT;

-- Vegetation Module --

CREATE OR REPLACE DIRECTORY dt_veg_dir AS '/schema-mapping/data-types/vegetation';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1300, null, 'ADEOfAbstractVegetationObject', 1, 14, BFILENAME('DT_VEG_DIR','ADEOfAbstractVegetationObject.json')),
  (1301, null, 'ADEOfPlantCover', 1, 14, BFILENAME('DT_VEG_DIR','ADEOfPlantCover.json')),
  (1302, null, 'ADEOfSolitaryVegetationObject', 1, 14, BFILENAME('DT_VEG_DIR','ADEOfSolitaryVegetationObject.json'));

COMMIT;

-- Versioning Module --

CREATE OR REPLACE DIRECTORY dt_vers_dir AS '/schema-mapping/data-types/versioning';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1400, null, 'Transaction', 0, 15, BFILENAME('DT_VERS_DIR','Transaction.json')),
  (1401, null, 'ADEOfVersion', 1, 15, BFILENAME('DT_VERS_DIR','ADEOfVersion.json')),
  (1402, null, 'ADEOfVersionTransition', 1, 15, BFILENAME('DT_VERS_DIR','ADEOfVersionTransition.json'));

COMMIT;

-- WaterBody Module --

CREATE OR REPLACE DIRECTORY dt_wtr_dir AS '/schema-mapping/data-types/waterbody';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1500, null, 'ADEOfAbstractWaterBoundarySurface', 1, 16, BFILENAME('DT_WTR_DIR','ADEOfAbstractWaterBoundarySurface.json')),
  (1501, null, 'ADEOfWaterBody', 1, 16, BFILENAME('DT_WTR_DIR','ADEOfWaterBody.json')),
  (1502, null, 'ADEOfWaterGroundSurface', 1, 16, BFILENAME('DT_WTR_DIR','ADEOfWaterGroundSurface.json')),
  (1503, null, 'ADEOfWaterSurface', 1, 16, BFILENAME('DT_WTR_DIR','ADEOfWaterSurface.json'));

COMMIT;

-- CityFurniture Module --

CREATE OR REPLACE DIRECTORY dt_frn_dir AS '/schema-mapping/data-types/cityfurniture';

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1600, null, 'ADEOfCityFurniture', 1, 17, BFILENAME('DT_FRN_DIR','ADEOfCityFurniture.json'));

COMMIT;