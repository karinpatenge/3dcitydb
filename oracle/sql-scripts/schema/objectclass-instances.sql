-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: July 2025
-- Status: to be reviewed
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

-----------------------------------------------------
-- Notes for reviewers:
--   Implementation using BFILE
--   Alternative approach: Create domains with JSON VALIDATE'<json-schema>'
--     (See https://blogs.oracle.com/coretec/post/less-coding-with-sql-domains-in-23c)
-----------------------------------------------------

TRUNCATE TABLE objectclass DROP STORAGE;


-- Core Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1, null, 'Undefined', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/Undefined.json')),
  (2, null, 'AbstractObject', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractObject.json')),
  (3, 2, 'AbstractFeature', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractFeature.json')),
  (4, null, 'Address', 0, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/Address.json')),
  (5, 3, 'AbstractPointCloud', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractPointCloud.json')),
  (6, 3, 'AbstractFeatureWithLifespan', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractFeatureWithLifespan.json')),
  (7, 6, 'AbstractCityObject', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractCityObject.json')),
  (8, 7, 'AbstractSpace', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractSpace.json')),
  (9, 8, 'AbstractLogicalSpace', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractLogicalSpace.json')),
  (10, 8, 'AbstractPhysicalSpace', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractPhysicalSpace.json')),
  (11, 10, 'AbstractUnoccupiedSpace', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractUnoccupiedSpace.json')),
  (12, 10, 'AbstractOccupiedSpace', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractOccupiedSpace.json')),
  (13, 7, 'AbstractSpaceBoundary', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractSpaceBoundary.json')),
  (14, 13, 'AbstractThematicSurface', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractThematicSurface.json')),
  (15, 14, 'ClosureSurface', 0, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/ClosureSurface.json')),
  (16, 6, 'AbstractDynamizer', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractDynamizer.json')),
  (17, 6, 'AbstractVersionTransition', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractVersionTransition.json')),
  (18, 6, 'CityModel', 0, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/CityModel.json')),
  (19, 6, 'AbstractVersion', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractVersion.json')),
  (20, null, 'AbstractAppearance', 1, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/AbstractAppearance.json')),
  (21, null, 'ImplicitGeometry', 0, 0, 1, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/core/ImplicitGeometry.json'));

-- Dynamizer Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (100, 16, 'Dynamizer', 0, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/Dynamizer.json')),
  (101, 3, 'AbstractTimeseries', 1, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/AbstractTimeseries.json')),
  (102, 101, 'AbstractAtomicTimeseries', 1, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/AbstractAtomicTimeseries.json')),
  (103, 102, 'TabulatedFileTimeseries', 0, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/TabulatedFileTimeseries.json')),
  (104, 102, 'StandardFileTimeseries', 0, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/StandardFileTimeseries.json')),
  (105, 102, 'GenericTimeseries', 0, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/GenericTimeseries.json')),
  (106, 101, 'CompositeTimeseries', 0, 0, 2, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/dynamizer/CompositeTimeseries.json'));

-- Generics Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (200, 9, 'GenericLogicalSpace', 0, 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/generics/GenericLogicalSpace.json')),
  (201, 12, 'GenericOccupiedSpace', 0, 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/generics/GenericOccupiedSpace.json')),
  (202, 11, 'GenericUnoccupiedSpace', 0, 1, 3, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/generics/GenericUnoccupiedSpace.json')),
  (203, 14, 'GenericThematicSurface', 0, 0, 3, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/generics/GenericThematicSurface.json'));

-- LandUse Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (300, 14, 'LandUse', 0, 1, 4, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/landuse/LandUse.json'));

-- PointCloud Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (400, 5, 'PointCloud', 0, 0, 5, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/pointcloud/PointCloud.json'));

-- Relief Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (500, 13, 'ReliefFeature', 0, 1, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/ReliefFeature.json')),
  (501, 13, 'AbstractReliefComponent', 1, 0, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/AbstractReliefComponent.json')),
  (502, 501, 'TINRelief', 0, 0, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/TINRelief.json')),
  (503, 501, 'MassPointRelief', 0, 0, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/MassPointRelief.json')),
  (504, 501, 'BreaklineRelief', 0, 0, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/BreaklineRelief.json')),
  (505, 501, 'RasterRelief', 0, 0, 6, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/relief/RasterRelief.json'));

-- Transportation Module --
CREATE OR REPLACE DIRECTORY ft_tran_dir AS '/schema-mapping/feature-types/tran';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (600, 11, 'AbstractTransportationSpace', 1, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/AbstractTransportationSpace.json')),
  (601, 600, 'Railway', 0, 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Railway.json')),
  (602, 600, 'Section', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Section.json')),
  (603, 600, 'Waterway', 0, 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Waterway.json')),
  (604, 600, 'Intersection', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Intersection.json')),
  (605, 600, 'Square', 0, 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Square.json')),
  (606, 600, 'Track', 0, 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Track.json')),
  (607, 600, 'Road', 0, 1, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Road.json')),
  (608, 11, 'AuxiliaryTrafficSpace', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/AuxiliaryTrafficSpace.json')),
  (609, 11, 'ClearanceSpace', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/ClearanceSpace.json')),
  (610, 11, 'TrafficSpace', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/TrafficSpace.json')),
  (611, 11, 'Hole', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Hole.json')),
  (612, 14, 'AuxiliaryTrafficArea', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/AuxiliaryTrafficArea.json')),
  (613, 14, 'TrafficArea', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/TrafficArea.json')),
  (614, 14, 'Marking', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/Marking.json')),
  (615, 14, 'HoleSurface', 0, 0, 7, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tran/HoleSurface.json'));

-- Construction Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (700, 12, 'AbstractConstruction', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractConstruction.json')),
  (701, 700, 'OtherConstruction', 0, 1, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/OtherConstruction.json')),
  (702, 12, 'AbstractConstructiveElement', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractConstructiveElement.json')),
  (703, 12, 'AbstractFillingElement', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractFillingElement.json')),
  (704, 703, 'Window', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/Window.json')),
  (705, 703, 'Door', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/Door.json')),
  (706, 12, 'AbstractFurniture', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractFurniture.json')),
  (707, 12, 'AbstractInstallation', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractInstallation.json')),
  (708, 14, 'AbstractConstructionSurface', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractConstructionSurface.json')),
  (709, 708, 'WallSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/WallSurface.json')),
  (710, 708, 'GroundSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/GroundSurface.json')),
  (711, 708, 'InteriorWallSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/InteriorWallSurface.json')),
  (712, 708, 'RoofSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/RoofSurface.json')),
  (713, 708, 'FloorSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/FloorSurface.json')),
  (714, 708, 'OuterFloorSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/OuterFloorSurface.json')),
  (715, 708, 'CeilingSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/CeilingSurface.json')),
  (716, 708, 'OuterCeilingSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/OuterCeilingSurface.json')),
  (717, 14, 'AbstractFillingSurface', 1, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/AbstractFillingSurface.json')),
  (718, 717, 'DoorSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/DoorSurface.json')),
  (719, 717, 'WindowSurface', 0, 0, 8, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/construction/WindowSurface.json'));

-- Tunnel Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (800, 700, 'AbstractTunnel', 1, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/AbstractTunnel.json')),
  (801, 800, 'Tunnel', 0, 1, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/Tunnel.json')),
  (802, 800, 'TunnelPart', 0, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/TunnelPart.json')),
  (803, 702, 'TunnelConstructiveElement', 0, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/TunnelConstructiveElement.json')),
  (804, 11, 'HollowSpace', 0, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/HollowSpace.json')),
  (805, 707, 'TunnelInstallation', 0, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/TunnelInstallation.json')),
  (806, 706, 'TunnelFurniture', 0, 0, 9, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/tunnel/TunnelFurniture.json'));

-- Building Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (900, 700, 'AbstractBuilding', 1, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/AbstractBuilding.json')),
  (901, 900, 'Building', 0, 1, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/Building.json')),
  (902, 900, 'BuildingPart', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingPart.json')),
  (903, 702, 'BuildingConstructiveElement', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingConstructiveElement.json')),
  (904, 11, 'BuildingRoom', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingRoom.json')),
  (905, 707, 'BuildingInstallation', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingInstallation.json')),
  (906, 706, 'BuildingFurniture', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingFurniture.json')),
  (907, 9, 'AbstractBuildingSubdivision', 1, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/AbstractBuildingSubdivision.json')),
  (908, 907, 'BuildingUnit', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/BuildingUnit.json')),
  (909, 907, 'Storey', 0, 0, 10, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/building/Storey.json'));

-- Bridge Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1000, 700, 'AbstractBridge', 1, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/AbstractBridge.json')),
  (1001, 1000, 'Bridge', 0, 1, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/Bridge.json')),
  (1002, 1000, 'BridgePart', 0, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/BridgePart.json')),
  (1003, 702, 'BridgeConstructiveElement', 0, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/BridgeConstructiveElement.json')),
  (1004, 11, 'BridgeRoom', 0, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/BridgeRoom.json')),
  (1005, 707, 'BridgeInstallation', 0, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/BridgeInstallation.json')),
  (1006, 706, 'BridgeFurniture', 0, 0, 11, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/bridge/BridgeFurniture.json'));

-- Appearance Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1100, 20, 'Appearance', 0, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/Appearance.json')),
  (1101, null, 'AbstractSurfaceData', 1, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/AbstractSurfaceData.json')),
  (1102, 1101, 'X3DMaterial', 0, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/X3DMaterial.json')),
  (1103, 1101, 'AbstractTexture', 1, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/AbstractTexture.json')),
  (1104, 1103, 'ParameterizedTexture', 0, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/ParameterizedTexture.json')),
  (1105, 1103, 'GeoreferencedTexture', 0, 0, 12, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/appearance/GeoreferencedTexture.json'));

-- CityObjectGroup Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1200, 9, 'CityObjectGroup', 0, 1, 13, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/cityobjectgroup/CityObjectGroup.json'));

-- Vegetation Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1300, 12, 'AbstractVegetationObject', 1, 0, 14, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/vegetation/AbstractVegetationObject.json')),
  (1301, 1300, 'SolitaryVegetationObject', 0, 1, 14, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/vegetation/SolitaryVegetationObject.json')),
  (1302, 1300, 'PlantCover', 0, 1, 14, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/vegetation/PlantCover.json'));

-- Versioning Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1400, 19, 'Version', 0, 0, 15, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/versioning/Version.json')),
  (1401, 17, 'VersionTransition', 0, 0, 15, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/versioning/VersionTransition.json'));

-- WaterBody Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1500, 12, 'WaterBody', 0, 1, 16, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/water/WaterBody.json')),
  (1501, 14, 'AbstractWaterBoundarySurface', 1, 0, 16, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/water/AbstractWaterBoundarySurface.json')),
  (1502, 1501, 'WaterSurface', 0, 0, 16, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/water/WaterSurface.json')),
  (1503, 1501, 'WaterGroundSurface', 0, 0, 16, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/water/WaterGroundSurface.json'));

-- CityFurniture Module --

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1600, 12, 'CityFurniture', 0, 1, 17, BFILENAME('SCHEMA_MAPPING_DIR','feature-types/furniture/CityFurniture.json'));

COMMIT;