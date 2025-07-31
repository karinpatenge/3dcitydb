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

TRUNCATE TABLE objectclass DROP STORAGE;

-- Core Module --
CREATE OR REPLACE DIRECTORY ft_core_dir AS '/schema-mapping/feature-types/core';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1, null, 'Undefined', 1, 0, 1, BFILENAME('FT_CORE_DIR','Undefined.json')),
  (2, null, 'AbstractObject', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractObject.json')),
  (3, 2, 'AbstractFeature', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractFeature.json')),
  (4, null, 'Address', 0, 0, 1, BFILENAME('FT_CORE_DIR','Address.json')),
  (5, 3, 'AbstractPointCloud', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractPointCloud.json')),
  (6, 3, 'AbstractFeatureWithLifespan', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractFeatureWithLifespan.json')),
  (7, 6, 'AbstractCityObject', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractCityObject.json')),
  (8, 7, 'AbstractSpace', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractSpace.json')),
  (9, 8, 'AbstractLogicalSpace', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractLogicalSpace.json')),
  (10, 8, 'AbstractPhysicalSpace', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractPhysicalSpace.json')),
  (11, 10, 'AbstractUnoccupiedSpace', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractUnoccupiedSpace.json')),
  (12, 10, 'AbstractOccupiedSpace', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractOccupiedSpace.json')),
  (13, 7, 'AbstractSpaceBoundary', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractSpaceBoundary.json')),
  (14, 13, 'AbstractThematicSurface', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractThematicSurface.json')),
  (15, 14, 'ClosureSurface', 0, 0, 1, BFILENAME('FT_CORE_DIR','ClosureSurface.json')),
  (16, 6, 'AbstractDynamizer', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractDynamizer.json')),
  (17, 6, 'AbstractVersionTransition', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractVersionTransition.json')),
  (18, 6, 'CityModel', 0, 0, 1, BFILENAME('FT_CORE_DIR','CityModel.json')),
  (19, 6, 'AbstractVersion', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractVersion.json')),
  (20, null, 'AbstractAppearance', 1, 0, 1, BFILENAME('FT_CORE_DIR','AbstractAppearance.json')),
  (21, null, 'ImplicitGeometry', 0, 0, 1, BFILENAME('FT_CORE_DIR','ImplicitGeometry.json'));

-- Dynamizer Module --
CREATE OR REPLACE DIRECTORY ft_dyn_dir AS '/schema-mapping/feature-types/dynamizer';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (100, 16, 'Dynamizer', 0, 0, 2, BFILENAME('FT_DYN_DIR','Dynamizer.json')),
  (101, 3, 'AbstractTimeseries', 1, 0, 2, BFILENAME('FT_DYN_DIR','AbstractTimeseries.json')),
  (102, 101, 'AbstractAtomicTimeseries', 1, 0, 2, BFILENAME('FT_DYN_DIR','AbstractAtomicTimeseries.json')),
  (103, 102, 'TabulatedFileTimeseries', 0, 0, 2, BFILENAME('FT_DYN_DIR','TabulatedFileTimeseries.json')),
  (104, 102, 'StandardFileTimeseries', 0, 0, 2, BFILENAME('FT_DYN_DIR','StandardFileTimeseries.json')),
  (105, 102, 'GenericTimeseries', 0, 0, 2, BFILENAME('FT_DYN_DIR','GenericTimeseries.json')),
  (106, 101, 'CompositeTimeseries', 0, 0, 2, BFILENAME('FT_DYN_DIR','CompositeTimeseries.json'));

-- Generics Module --
CREATE OR REPLACE DIRECTORY ft_gen_dir AS '/schema-mapping/feature-types/generics';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (200, 9, 'GenericLogicalSpace', 0, 1, 3, BFILENAME('FT_GEN_DIR','GenericLogicalSpace.json')),
  (201, 12, 'GenericOccupiedSpace', 0, 1, 3, BFILENAME('FT_GEN_DIR','GenericOccupiedSpace.json')),
  (202, 11, 'GenericUnoccupiedSpace', 0, 1, 3, BFILENAME('FT_GEN_DIR','GenericUnoccupiedSpace.json')),
  (203, 14, 'GenericThematicSurface', 0, 0, 3, BFILENAME('FT_GEN_DIR','GenericThematicSurface.json'));

-- LandUse Module --
CREATE OR REPLACE DIRECTORY ft_luse_dir AS '/schema-mapping/feature-types/landuse';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (300, 14, 'LandUse', 0, 1, 4, BFILENAME('FT_LUSE_DIR','LandUse.json'));

-- PointCloud Module --
CREATE OR REPLACE DIRECTORY ft_pcl_dir AS '/schema-mapping/feature-types/pointcloud';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (400, 5, 'PointCloud', 0, 0, 5, BFILENAME('FT_PCL_DIR','PointCloud.json'));

-- Relief Module --
CREATE OR REPLACE DIRECTORY ft_dem_dir AS '/schema-mapping/feature-types/relief';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (500, 13, 'ReliefFeature', 0, 1, 6, BFILENAME('FT_DEM_DIR','ReliefFeature.json')),
  (501, 13, 'AbstractReliefComponent', 1, 0, 6, BFILENAME('FT_DEM_DIR','AbstractReliefComponent.json')),
  (502, 501, 'TINRelief', 0, 0, 6, BFILENAME('FT_DEM_DIR','TINRelief.json')),
  (503, 501, 'MassPointRelief', 0, 0, 6, BFILENAME('FT_DEM_DIR','MassPointRelief.json')),
  (504, 501, 'BreaklineRelief', 0, 0, 6, BFILENAME('FT_DEM_DIR','BreaklineRelief.json')),
  (505, 501, 'RasterRelief', 0, 0, 6, BFILENAME('FT_DEM_DIR','RasterRelief.json'));

-- Transportation Module --
CREATE OR REPLACE DIRECTORY ft_tran_dir AS '/schema-mapping/feature-types/tran';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (600, 11, 'AbstractTransportationSpace', 1, 0, 7, BFILENAME('FT_DEM_DIR','AbstractTransportationSpace.json')),
  (601, 600, 'Railway', 0, 1, 7, BFILENAME('FT_DEM_DIR','Railway.json')),
  (602, 600, 'Section', 0, 0, 7, BFILENAME('FT_DEM_DIR','Section.json')),
  (603, 600, 'Waterway', 0, 1, 7, BFILENAME('FT_DEM_DIR','Waterway.json')),
  (604, 600, 'Intersection', 0, 0, 7, BFILENAME('FT_DEM_DIR','Intersection.json')),
  (605, 600, 'Square', 0, 1, 7, BFILENAME('FT_DEM_DIR','Square.json')),
  (606, 600, 'Track', 0, 1, 7, BFILENAME('FT_DEM_DIR','Track.json')),
  (607, 600, 'Road', 0, 1, 7, BFILENAME('FT_DEM_DIR','Road.json')),
  (608, 11, 'AuxiliaryTrafficSpace', 0, 0, 7, BFILENAME('FT_DEM_DIR','AuxiliaryTrafficSpace.json')),
  (609, 11, 'ClearanceSpace', 0, 0, 7, BFILENAME('FT_DEM_DIR','ClearanceSpace.json')),
  (610, 11, 'TrafficSpace', 0, 0, 7, BFILENAME('FT_DEM_DIR','TrafficSpace.json')),
  (611, 11, 'Hole', 0, 0, 7, BFILENAME('FT_DEM_DIR','Hole.json')),
  (612, 14, 'AuxiliaryTrafficArea', 0, 0, 7, BFILENAME('FT_DEM_DIR','AuxiliaryTrafficArea.json')),
  (613, 14, 'TrafficArea', 0, 0, 7, BFILENAME('FT_DEM_DIR','TrafficArea.json')),
  (614, 14, 'Marking', 0, 0, 7, BFILENAME('FT_DEM_DIR','Marking.json')),
  (615, 14, 'HoleSurface', 0, 0, 7, BFILENAME('FT_DEM_DIR','HoleSurface.json'));

-- Construction Module --
CREATE OR REPLACE DIRECTORY ft_con_dir AS '/schema-mapping/feature-types/construction';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (700, 12, 'AbstractConstruction', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractConstruction.json')),
  (701, 700, 'OtherConstruction', 0, 1, 8, BFILENAME('FT_CON_DIR','OtherConstruction.json')),
  (702, 12, 'AbstractConstructiveElement', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractConstructiveElement.json')),
  (703, 12, 'AbstractFillingElement', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractFillingElement.json')),
  (704, 703, 'Window', 0, 0, 8, BFILENAME('FT_CON_DIR','Window.json')),
  (705, 703, 'Door', 0, 0, 8, BFILENAME('FT_CON_DIR','Door.json')),
  (706, 12, 'AbstractFurniture', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractFurniture.json')),
  (707, 12, 'AbstractInstallation', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractInstallation.json')),
  (708, 14, 'AbstractConstructionSurface', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractConstructionSurface.json')),
  (709, 708, 'WallSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','WallSurface.json')),
  (710, 708, 'GroundSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','GroundSurface.json')),
  (711, 708, 'InteriorWallSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','InteriorWallSurface.json')),
  (712, 708, 'RoofSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','RoofSurface.json')),
  (713, 708, 'FloorSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','FloorSurface.json')),
  (714, 708, 'OuterFloorSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','OuterFloorSurface.json')),
  (715, 708, 'CeilingSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','CeilingSurface.json')),
  (716, 708, 'OuterCeilingSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','OuterCeilingSurface.json')),
  (717, 14, 'AbstractFillingSurface', 1, 0, 8, BFILENAME('FT_CON_DIR','AbstractFillingSurface.json')),
  (718, 717, 'DoorSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','DoorSurface.json')),
  (719, 717, 'WindowSurface', 0, 0, 8, BFILENAME('FT_CON_DIR','WindowSurface.json'));

-- Tunnel Module --
CREATE OR REPLACE DIRECTORY ft_tun_dir AS '/schema-mapping/feature-types/tunnel';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (800, 700, 'AbstractTunnel', 1, 0, 9, BFILENAME('FT_TUN_DIR','AbstractTunnel.json')),
  (801, 800, 'Tunnel', 0, 1, 9, BFILENAME('FT_TUN_DIR','Tunnel.json')),
  (802, 800, 'TunnelPart', 0, 0, 9, BFILENAME('FT_TUN_DIR','TunnelPart.json')),
  (803, 702, 'TunnelConstructiveElement', 0, 0, 9, BFILENAME('FT_TUN_DIR','TunnelConstructiveElement.json')),
  (804, 11, 'HollowSpace', 0, 0, 9, BFILENAME('FT_TUN_DIR','HollowSpace.json')),
  (805, 707, 'TunnelInstallation', 0, 0, 9, BFILENAME('FT_TUN_DIR','TunnelInstallation.json')),
  (806, 706, 'TunnelFurniture', 0, 0, 9, BFILENAME('FT_TUN_DIR','TunnelFurniture.json'));

-- Building Module --
CREATE OR REPLACE DIRECTORY ft_bldg_dir AS '/schema-mapping/feature-types/building';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (900, 700, 'AbstractBuilding', 1, 0, 10, BFILENAME('FT_BLDG_DIR','AbstractBuilding.json')),
  (901, 900, 'Building', 0, 1, 10, BFILENAME('FT_BLDG_DIR','Building.json')),
  (902, 900, 'BuildingPart', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingPart.json')),
  (903, 702, 'BuildingConstructiveElement', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingConstructiveElement.json')),
  (904, 11, 'BuildingRoom', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingRoom.json')),
  (905, 707, 'BuildingInstallation', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingInstallation.json')),
  (906, 706, 'BuildingFurniture', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingFurniture.json')),
  (907, 9, 'AbstractBuildingSubdivision', 1, 0, 10, BFILENAME('FT_BLDG_DIR','AbstractBuildingSubdivision.json')),
  (908, 907, 'BuildingUnit', 0, 0, 10, BFILENAME('FT_BLDG_DIR','BuildingUnit.json')),
  (909, 907, 'Storey', 0, 0, 10, BFILENAME('FT_BLDG_DIR','Storey.json'));

-- Bridge Module --
CREATE OR REPLACE DIRECTORY ft_brid_dir AS '/schema-mapping/feature-types/bridge';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1000, 700, 'AbstractBridge', 1, 0, 11, BFILENAME('FT_BRID_DIR','AbstractBridge.json')),
  (1001, 1000, 'Bridge', 0, 1, 11, BFILENAME('FT_BRID_DIR','Bridge.json')),
  (1002, 1000, 'BridgePart', 0, 0, 11, BFILENAME('FT_BRID_DIR','BridgePart.json')),
  (1003, 702, 'BridgeConstructiveElement', 0, 0, 11, BFILENAME('FT_BRID_DIR','BridgeConstructiveElement.json')),
  (1004, 11, 'BridgeRoom', 0, 0, 11, BFILENAME('FT_BRID_DIR','BridgeRoom.json')),
  (1005, 707, 'BridgeInstallation', 0, 0, 11, BFILENAME('FT_BRID_DIR','BridgeInstallation.json')),
  (1006, 706, 'BridgeFurniture', 0, 0, 11, BFILENAME('FT_BRID_DIR','BridgeFurniture.json'));

-- Appearance Module --
CREATE OR REPLACE DIRECTORY ft_app_dir AS '/schema-mapping/feature-types/appearance';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1100, 20, 'Appearance', 0, 0, 12, BFILENAME('FT_APP_DIR','Appearance.json')),
  (1101, null, 'AbstractSurfaceData', 1, 0, 12, BFILENAME('FT_APP_DIR','AbstractSurfaceData.json')),
  (1102, 1101, 'X3DMaterial', 0, 0, 12, BFILENAME('FT_APP_DIR','X3DMaterial.json')),
  (1103, 1101, 'AbstractTexture', 1, 0, 12, BFILENAME('FT_APP_DIR','AbstractTexture.json')),
  (1104, 1103, 'ParameterizedTexture', 0, 0, 12, BFILENAME('FT_APP_DIR','ParameterizedTexture.json')),
  (1105, 1103, 'GeoreferencedTexture', 0, 0, 12, BFILENAME('FT_APP_DIR','GeoreferencedTexture.json'));

-- CityObjectGroup Module --
CREATE OR REPLACE DIRECTORY ft_grp_dir AS '/schema-mapping/feature-types/cityobjectgroup';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1200, 9, 'CityObjectGroup', 0, 1, 13, BFILENAME('FT_GRP_DIR','CityObjectGroup.json'));

-- Vegetation Module --
CREATE OR REPLACE DIRECTORY ft_veg_dir AS '/schema-mapping/feature-types/vegetation';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1300, 12, 'AbstractVegetationObject', 1, 0, 14, BFILENAME('FT_VEG_DIR','AbstractVegetationObject.json')),
  (1301, 1300, 'SolitaryVegetationObject', 0, 1, 14, BFILENAME('FT_VEG_DIR','SolitaryVegetationObject.json')),
  (1302, 1300, 'PlantCover', 0, 1, 14, BFILENAME('FT_VEG_DIR','PlantCover.json'));

-- Versioning Module --
CREATE OR REPLACE DIRECTORY ft_vers_dir AS '/schema-mapping/feature-types/versioning';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1400, 19, 'Version', 0, 0, 15, BFILENAME('FT_VERS_DIR','Version.json')),
  (1401, 17, 'VersionTransition', 0, 0, 15, BFILENAME('FT_VERS_DIR','VersionTransition.json'));

-- WaterBody Module --
CREATE OR REPLACE DIRECTORY ft_wtr_dir AS '/schema-mapping/feature-types/water';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1500, 12, 'WaterBody', 0, 1, 16, BFILENAME('FT_WTR_DIR','WaterBody.json')),
  (1501, 14, 'AbstractWaterBoundarySurface', 1, 0, 16, BFILENAME('FT_WTR_DIR','AbstractWaterBoundarySurface.json')),
  (1502, 1501, 'WaterSurface', 0, 0, 16, BFILENAME('FT_WTR_DIR','WaterSurface.json')),
  (1503, 1501, 'WaterGroundSurface', 0, 0, 16, BFILENAME('FT_WTR_DIR','WaterGroundSurface.json'));

-- CityFurniture Module --
CREATE OR REPLACE DIRECTORY ft_frn_dir AS '/schema-mapping/feature-types/furniture';

INSERT INTO objectclass (ID, SUPERCLASS_ID, CLASSNAME, IS_ABSTRACT, IS_TOPLEVEL, NAMESPACE_ID, SCHEMA)
VALUES
  (1600, 12, 'CityFurniture', 0, 1, 17, BFILENAME('FT_FRN_DIR','CityFurniture.json'));

COMMIT;