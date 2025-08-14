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

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1, null, 'Undefined', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Undefined.json')),
  (2, null, 'Boolean', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Boolean.json')),
  (3, null, 'Integer', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Integer.json')),
  (4, null, 'Double', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Double.json')),
  (5, null, 'String', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/String.json')),
  (6, null, 'URI', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/URI.json')),
  (7, null, 'Timestamp', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Timestamp.json')),
  (8, null, 'AddressProperty', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/AddressProperty.json')),
  (9, null, 'AppearanceProperty', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/AppearanceProperty.json')),
  (10, null, 'FeatureProperty', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/FeatureProperty.json')),
  (11, null, 'GeometryProperty', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/GeometryProperty.json')),
  (12, null, 'Reference', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Reference.json')),
  (13, null, 'CityObjectRelation', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/CityObjectRelation.json')),
  (14, null, 'Code', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Code.json')),
  (15, null, 'ExternalReference', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ExternalReference.json')),
  (16, null, 'ImplicitGeometryProperty', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ImplicitGeometryProperty.json')),
  (17, null, 'Measure', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Measure.json')),
  (18, null, 'MeasureOrNilReasonList', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/MeasureOrNilReasonList.json')),
  (19, null, 'Occupancy', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Occupancy.json')),
  (20, null, 'QualifiedArea', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/QualifiedArea.json')),
  (21, null, 'QualifiedVolume', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/QualifiedVolume.json')),
  (22, null, 'StringOrRef', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/StringOrRef.json')),
  (23, null, 'TimePosition', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/TimePosition.json')),
  (24, null, 'Duration', 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/Duration.json')),
  (50, null, 'ADEOfAbstractCityObject', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractCityObject.json')),
  (51, null, 'ADEOfAbstractDynamizer', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractDynamizer.json')),
  (52, null, 'ADEOfAbstractFeature', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractFeature.json')),
  (53, null, 'ADEOfAbstractFeatureWithLifespan', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractFeatureWithLifespan.json')),
  (54, null, 'ADEOfAbstractLogicalSpace', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractLogicalSpace.json')),
  (55, null, 'ADEOfAbstractOccupiedSpace', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractOccupiedSpace.json')),
  (56, null, 'ADEOfAbstractPhysicalSpace', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractPhysicalSpace.json')),
  (57, null, 'ADEOfAbstractPointCloud', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractPointCloud.json')),
  (58, null, 'ADEOfAbstractSpace', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractSpace.json')),
  (59, null, 'ADEOfAbstractSpaceBoundary', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractSpaceBoundary.json')),
  (60, null, 'ADEOfAbstractThematicSurface', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractThematicSurface.json')),
  (61, null, 'ADEOfAbstractUnoccupiedSpace', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractUnoccupiedSpace.json')),
  (62, null, 'ADEOfAbstractVersion', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractVersion.json')),
  (63, null, 'ADEOfAbstractVersionTransition', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfAbstractVersionTransition.json')),
  (64, null, 'ADEOfCityModel', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfCityModel.json')),
  (65, null, 'ADEOfClosureSurface', 1, 1, BFILENAME('SCHEMA_MAPPING_DIR','data-types/core/ADEOfClosureSurface.json'));

COMMIT;

-- Dynamizer Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (100, null, 'AbstractTimeValuePair', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/AbstractTimeValuePair.json')),
  (101, null, 'AttributeReference', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/AttributeReference.json')),
  (102, null, 'SensorConnection', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/SensorConnection.json')),
  (103, 100, 'TimeAppearance', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeAppearance.json')),
  (104, 100, 'TimeBoolean', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeBoolean.json')),
  (105, 100, 'TimeDouble', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeDouble.json')),
  (106, 100, 'TimeGeometry', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeGeometry.json')),
  (107, 100, 'TimeImplicitGeometry', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeImplicitGeometry.json')),
  (108, 100, 'TimeInteger', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeInteger.json')),
  (109, null, 'TimeseriesComponent', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeseriesComponent.json')),
  (110, 100, 'TimeString', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeString.json')),
  (111, 100, 'TimeURI', 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/TimeURI.json')),
  (112, null, 'ADEOfAbstractAtomicTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfAbstractAtomicTimeseries.json')),
  (113, null, 'ADEOfAbstractTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfAbstractTimeseries.json')),
  (114, null, 'ADEOfCompositeTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfCompositeTimeseries.json')),
  (115, null, 'ADEOfDynamizer', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfDynamizer.json')),
  (116, null, 'ADEOfGenericTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfGenericTimeseries.json')),
  (117, null, 'ADEOfStandardFileTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfStandardFileTimeseries.json')),
  (118, null, 'ADEOfTabulatedFileTimeseries', 1, 2, BFILENAME('SCHEMA_MAPPING_DIR','data-types/dynamizer/ADEOfTabulatedFileTimeseries.json'));

COMMIT;

-- Generics Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (200, null, 'GenericAttributeSet', 0, 3, BFILENAME('SCHEMA_MAPPING_DIR','data-types/generics/GenericAttributeSet.json')),
  (201, null, 'ADEOfGenericLogicalSpace', 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','data-types/generics/ADEOfGenericLogicalSpace.json')),
  (202, null, 'ADEOfGenericOccupiedSpace', 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','data-types/generics/ADEOfGenericOccupiedSpace.json')),
  (203, null, 'ADEOfGenericThematicSurface', 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','data-types/generics/ADEOfGenericThematicSurface.json')),
  (204, null, 'ADEOfGenericUnoccupiedSpace', 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','data-types/generics/ADEOfGenericUnoccupiedSpace.json'));

COMMIT;

-- LandUse Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (300, null, 'ADEOfLandUse', 1, 4, BFILENAME('SCHEMA_MAPPING_DIR','data-types/landuse/ADEOfLandUse.json'));

COMMIT;

-- PointCloud Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (400, null, 'ADEOfPointCloud', 1, 5, BFILENAME('SCHEMA_MAPPING_DIR','data-types/pointcloud/ADEOfPointCloud.json'));

COMMIT;

-- Relief Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (500, null, 'ADEOfAbstractReliefComponent', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfAbstractReliefComponent.json')),
  (501, null, 'ADEOfBreaklineRelief', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfBreaklineRelief.json')),
  (502, null, 'ADEOfMassPointRelief', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfMassPointRelief.json')),
  (503, null, 'ADEOfRasterRelief', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfRasterRelief.json')),
  (504, null, 'ADEOfReliefFeature', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfReliefFeature.json')),
  (505, null, 'ADEOfTINRelief', 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','data-types/relief/ADEOfTINRelief.json'));

COMMIT;

-- Transportation Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (600, null, 'ADEOfAbstractTransportationSpace', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfAbstractTransportationSpace.json')),
  (601, null, 'ADEOfAuxiliaryTrafficArea', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfAuxiliaryTrafficArea.json')),
  (602, null, 'ADEOfAuxiliaryTrafficSpace', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfAuxiliaryTrafficSpace.json')),
  (603, null, 'ADEOfClearanceSpace', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfClearanceSpace.json')),
  (604, null, 'ADEOfHole', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfHole.json')),
  (605, null, 'ADEOfHoleSurface', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfHoleSurface.json')),
  (606, null, 'ADEOfIntersection', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfIntersection.json')),
  (607, null, 'ADEOfMarking', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfMarking.json')),
  (608, null, 'ADEOfRailway', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfRailway.json')),
  (609, null, 'ADEOfRoad', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfRoad.json')),
  (610, null, 'ADEOfSection', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfSection.json')),
  (611, null, 'ADEOfSquare', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfSquare.json')),
  (612, null, 'ADEOfTrack', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfTrack.json')),
  (613, null, 'ADEOfTrafficArea', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfTrafficArea.json')),
  (614, null, 'ADEOfTrafficSpace', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfTrafficSpace.json')),
  (615, null, 'ADEOfWaterway', 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','data-types/transportation/ADEOfWaterway.json'));

COMMIT;

-- Construction Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (700, null, 'ConstructionEvent', 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ConstructionEvent.json')),
  (701, null, 'Elevation', 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/Elevation.json')),
  (702, null, 'Height', 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/Height.json')),
  (703, null, 'ADEOfAbstractConstruction', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractConstruction.json')),
  (704, null, 'ADEOfAbstractConstructionSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractConstructionSurface.json')),
  (705, null, 'ADEOfAbstractConstructiveElement', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractConstructiveElement.json')),
  (706, null, 'ADEOfAbstractFillingElement', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractFillingElement.json')),
  (707, null, 'ADEOfAbstractFillingSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractFillingSurface.json')),
  (708, null, 'ADEOfAbstractFurniture', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractFurniture.json')),
  (709, null, 'ADEOfAbstractInstallation', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfAbstractInstallation.json')),
  (710, null, 'ADEOfCeilingSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfCeilingSurface.json')),
  (711, null, 'ADEOfDoor', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfDoor.json')),
  (712, null, 'ADEOfDoorSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfDoorSurface.json')),
  (713, null, 'ADEOfFloorSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfFloorSurface.json')),
  (714, null, 'ADEOfGroundSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfGroundSurface.json')),
  (715, null, 'ADEOfInteriorWallSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfInteriorWallSurface.json')),
  (716, null, 'ADEOfOtherConstruction', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfOtherConstruction.json')),
  (717, null, 'ADEOfOuterCeilingSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfOuterCeilingSurface.json')),
  (718, null, 'ADEOfOuterFloorSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfOuterFloorSurface.json')),
  (719, null, 'ADEOfRoofSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfRoofSurface.json')),
  (720, null, 'ADEOfWallSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfWallSurface.json')),
  (721, null, 'ADEOfWindow', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfWindow.json')),
  (722, null, 'ADEOfWindowSurface', 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','data-types/construction/ADEOfWindowSurface.json'));

COMMIT;

-- Tunnel Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (800, null, 'ADEOfAbstractTunnel', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfAbstractTunnel.json')),
  (801, null, 'ADEOfHollowSpace', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfHollowSpace.json')),
  (802, null, 'ADEOfTunnel', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfTunnel.json')),
  (803, null, 'ADEOfTunnelConstructiveElement', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfTunnelConstructiveElement.json')),
  (804, null, 'ADEOfTunnelFurniture', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfTunnelFurniture.json')),
  (805, null, 'ADEOfTunnelInstallation', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfTunnelInstallation.json')),
  (806, null, 'ADEOfTunnelPart', 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','data-types/tunnel/ADEOfTunnelPart.json'));

COMMIT;

-- Building Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (900, null, 'RoomHeight', 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/RoomHeight.json')),
  (901, null, 'ADEOfAbstractBuilding', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfAbstractBuilding.json')),
  (902, null, 'ADEOfAbstractBuildingSubdivision', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfAbstractBuildingSubdivision.json')),
  (903, null, 'ADEOfBuilding', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuilding.json')),
  (904, null, 'ADEOfBuildingConstructiveElement', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingConstructiveElement.json')),
  (905, null, 'ADEOfBuildingFurniture', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingFurniture.json')),
  (906, null, 'ADEOfBuildingInstallation', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingInstallation.json')),
  (907, null, 'ADEOfBuildingPart', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingPart.json')),
  (908, null, 'ADEOfBuildingRoom', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingRoom.json')),
  (909, null, 'ADEOfBuildingUnit', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfBuildingUnit.json')),
  (910, null, 'ADEOfStorey', 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','data-types/building/ADEOfStorey.json'));

COMMIT;

-- Bridge Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1000, null, 'ADEOfAbstractBridge', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfAbstractBridge.json')),
  (1001, null, 'ADEOfBridge', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridge.json')),
  (1002, null, 'ADEOfBridgeConstructiveElement', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridgeConstructiveElement.json')),
  (1003, null, 'ADEOfBridgeFurniture', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridgeFurniture.json')),
  (1004, null, 'ADEOfBridgeInstallation', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridgeInstallation.json')),
  (1005, null, 'ADEOfBridgePart', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridgePart.json')),
  (1006, null, 'ADEOfBridgeRoom', 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','data-types/bridge/ADEOfBridgeRoom.json'));

COMMIT;

-- CityObjectGroup Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1200, null, 'Role', 0, 13, BFILENAME('SCHEMA_MAPPING_DIR','data-types/cityobjectgroup/Role.json')),
  (1201, null, 'ADEOfCityObjectGroup', 1, 13, BFILENAME('SCHEMA_MAPPING_DIR','data-types/cityobjectgroup/ADEOfCityObjectGroup.json'));

COMMIT;

-- Vegetation Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1300, null, 'ADEOfAbstractVegetationObject', 1, 14, BFILENAME('SCHEMA_MAPPING_DIR','data-types/vegetation/ADEOfAbstractVegetationObject.json')),
  (1301, null, 'ADEOfPlantCover', 1, 14, BFILENAME('SCHEMA_MAPPING_DIR','data-types/vegetation/ADEOfPlantCover.json')),
  (1302, null, 'ADEOfSolitaryVegetationObject', 1, 14, BFILENAME('SCHEMA_MAPPING_DIR','data-types/vegetation/ADEOfSolitaryVegetationObject.json'));

COMMIT;

-- Versioning Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1400, null, 'Transaction', 0, 15, BFILENAME('SCHEMA_MAPPING_DIR','data-types/versioning/Transaction.json')),
  (1401, null, 'ADEOfVersion', 1, 15, BFILENAME('SCHEMA_MAPPING_DIR','data-types/versioning/ADEOfVersion.json')),
  (1402, null, 'ADEOfVersionTransition', 1, 15, BFILENAME('SCHEMA_MAPPING_DIR','data-types/versioning/ADEOfVersionTransition.json'));

COMMIT;

-- WaterBody Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1500, null, 'ADEOfAbstractWaterBoundarySurface', 1, 16, BFILENAME('SCHEMA_MAPPING_DIR','data-types/waterbody/ADEOfAbstractWaterBoundarySurface.json')),
  (1501, null, 'ADEOfWaterBody', 1, 16, BFILENAME('SCHEMA_MAPPING_DIR','data-types/waterbody/ADEOfWaterBody.json')),
  (1502, null, 'ADEOfWaterGroundSurface', 1, 16, BFILENAME('SCHEMA_MAPPING_DIR','data-types/waterbody/ADEOfWaterGroundSurface.json')),
  (1503, null, 'ADEOfWaterSurface', 1, 16, BFILENAME('SCHEMA_MAPPING_DIR','data-types/waterbody/ADEOfWaterSurface.json'));

COMMIT;

-- CityFurniture Module --

INSERT INTO datatype (ID, SUPERTYPE_ID, TYPENAME, IS_ABSTRACT, NAMESPACE_ID, SCHEMA)
VALUES
  (1600, null, 'ADEOfCityFurniture', 1, 17, BFILENAME('SCHEMA_MAPPING_DIR','data-types/cityfurniture/ADEOfCityFurniture.json'));

COMMIT;