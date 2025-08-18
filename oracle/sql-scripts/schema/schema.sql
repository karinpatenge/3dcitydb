-----------------------------------------------------
-- Author: Karin Patenge, Oracle
-- Last update: June 2025
-- Status: to be reviewed
-- This scripts requires Oracle Database version 23ai
-----------------------------------------------------

--
-- Clean up 3DCityDB tables
--

DROP TABLE IF EXISTS address CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS ade CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS codelist CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS codelist_entry CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS database_srs CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS feature CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS geometry_data CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS implicit_geometry CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS namespace CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS objectclass CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS tex_image CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS appearance CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS datatype CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS property CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS surface_data CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS surface_data_mapping CASCADE CONSTRAINTS PURGE;
DROP TABLE IF EXISTS appear_to_surface_data CASCADE CONSTRAINTS PURGE;

--
-- Create 3DCityDB tables belonging to the modules:
--   * Feature module
--   * Geometry module
--   * Appearance module
--   * CodeList module
--   * Metadata module
--

--
-- Table ADDRESS (Feature module)
--

CREATE TABLE IF NOT EXISTS address (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  objectid                      VARCHAR2(256),
  identifier                    VARCHAR2(256),
  identifier_codespace          VARCHAR2(1000),
  street                        VARCHAR2(256),
  house_number                  VARCHAR2(256),
  po_box                        VARCHAR2(256),
  zip_code                      VARCHAR2(256),
  city                          VARCHAR2(256),
  state                         VARCHAR2(256),
  country                       VARCHAR2(2),
  free_text                     JSON,
  multi_point                   SDO_GEOMETRY,
  content                       VARCHAR2(256),
  content_mime_type             VARCHAR2(256),
  CONSTRAINT address_pk PRIMARY KEY ( id ) ENABLE
);

-- Add comments

COMMENT ON TABLE address IS 'Although address is modelled as a feature type in CityGML conceptual model, it is exceptionally stored in a dedicated ADDRESS table rather than in the FEATURE table, since this design decision allows for more efficient data querying, indexing, and updates in support of e.g., location-based services.';

COMMENT ON COLUMN address.id IS 'Column ID uniquely identifies an address related to a feature property and serves as its primary key.';

--
-- Table FEATURE (Feature module)
--

CREATE TABLE IF NOT EXISTS feature (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  objectclass_id                NUMBER(38) NOT NULL,
  objectid                      VARCHAR2(256),
  identifier                    VARCHAR2(256),
  identifier_codespace          VARCHAR2(1000),
  envelope                      SDO_GEOMETRY,
  last_modification_date        TIMESTAMP WITH TIME ZONE,
  updating_person               VARCHAR2(256),
  reason_for_update             VARCHAR2(4000),
  lineage                       VARCHAR2(256),
  creation_date                 TIMESTAMP WITH TIME ZONE,
  termination_date              TIMESTAMP WITH TIME ZONE,
  valid_from                    TIMESTAMP WITH TIME ZONE,
  valid_to                      TIMESTAMP WITH TIME ZONE,
  CONSTRAINT feature_pk PRIMARY KEY ( id ) ENABLE
);

-- INSERT INTO USER_SDO_GEOM_METADATA ( ... );

-- Create indices

-- CREATE INDEX feature_envelope_sdx ON feature ( envelope ) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX feature_objectclass_idx ON feature ( objectclass_id );
CREATE INDEX feature_objectid_idx ON feature ( objectid );
CREATE INDEX feature_identifier_idx ON feature ( identifier, identifier_codespace );
CREATE INDEX feature_creation_date_idx ON feature ( creation_date );
CREATE INDEX feature_termination_date_idx ON feature ( termination_date );
CREATE INDEX feature_valid_from_idx ON feature ( valid_from );
CREATE INDEX feature_valid_to_idx ON feature ( valid_to );

-- Activate temporal validity

ALTER TABLE feature ADD PERIOD FOR valid_period (valid_from, valid_to);

-- Add comments (also for future use with SELECT AI)

COMMENT ON TABLE feature IS 'The FEATURE table is the central table serving as the primary storage for all objects such as buildings, roads, or vegetation.';

COMMENT ON COLUMN feature.id IS 'Column ID uniquely identifies each feature and serves as its primary key.';
COMMENT ON COLUMN feature.identifier IS 'Column IDENTIFIER accompanied by column IDENTIFIER_CODESPACE allows distinguishing features across different systems and feature versions globally.';
COMMENT ON COLUMN feature.objectclass_id IS 'Column OBJECTCLASS_ID indicates the feature type and references the OBJECTCLASS table.';
COMMENT ON COLUMN feature.identifier_codespace IS 'Column IDENTIFIER_CODESPACE accompanies column IDENTIFIER and allow to distinguish features across different systems and feature versions globally.';
COMMENT ON COLUMN feature.objectid IS 'Column OBJECTID is a string identifier for referencing within databases and datasets.';
COMMENT ON COLUMN feature.envelope IS 'Column ENVELOPE stores the minimal 3D bounding box of every feature and can be used for fast spatial querying';
COMMENT ON COLUMN feature.valid_from IS 'Column VALID_FROM defines when a feature has become valid or active. It refers to the bitemporal lifespan information managed through the columns CREATION_DATE and TERMINATION_DATE, and VALID_FROM and VALID_TO.';
COMMENT ON COLUMN feature.valid_to IS 'Column VALID_TO defines when a feature has become invalid or inactive. It refers to the bitemporal lifespan information managed through the columns CREATION_DATE and TERMINATION_DATE, and VALID_FROM and VALID_TO.';
COMMENT ON COLUMN feature.creation_date IS 'Column CREATION_DATE defines when a feature was created or originated. It refers to the bitemporal lifespan information managed through the columns CREATION_DATE and TERMINATION_DATE, and VALID_FROM and VALID_TO.';
COMMENT ON COLUMN feature.termination_date IS 'Column TERMINATION_DATE defines when a feature was terminated. It refers to the bitemporal lifespan information managed through the columns CREATION_DATE and TERMINATION_DATE, and VALID_FROM and VALID_TO.';
COMMENT ON COLUMN feature.updating_person IS 'Column UPDATING_PERSON provides insights into the origin and update history. It specifies who has last updated the feature.';
COMMENT ON COLUMN feature.last_modification_date IS 'Column LAST_MODIFICATION_DATE provides insights into the origin and update history. It specifies when the feature was last updated.';
COMMENT ON COLUMN feature.reason_for_update IS 'Column REASON_FOR_UPDATE provides insights into the origin and update history. It specifies why  the feature was last updated.';
COMMENT ON COLUMN feature.lineage IS 'Column LINEAGE provides additional insights into the origin and update history.';

--
-- Table PROPERTY (Feature module)
--

CREATE TABLE IF NOT EXISTS property (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  feature_id                    NUMBER(38),
  parent_id                     NUMBER(38),
  datatype_id                   NUMBER(38),
  namespace_id                  NUMBER(38),
  name                          VARCHAR2(256),
  val_int                       NUMBER(38),
  val_double                    NUMBER(38,3),
  val_string                    VARCHAR2(4000),
  val_timestamp                 TIMESTAMP WITH TIME ZONE,
  val_uri                       VARCHAR2(4000),
  val_codespace                 VARCHAR2(256),
  val_uom                       VARCHAR2(4000),
  val_array                     JSON,
  val_lod                       VARCHAR2(256),
  val_geometry_id               NUMBER(38),
  val_implicitgeom_id           NUMBER(38),
  val_implicitgeom_refpoint     SDO_GEOMETRY,
  val_appearance_id             NUMBER(38),
  val_address_id                NUMBER(38),
  val_feature_id                NUMBER(38),
  val_relation_type             NUMBER(38),
  val_content                   VARCHAR2(256),
  val_content_mime_type         VARCHAR2(256),
  CONSTRAINT property_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX property_feature_idx ON property ( feature_id );
CREATE INDEX property_parent_idx ON property ( parent_id );
CREATE INDEX property_namespace_idx ON property ( namespace_id );
CREATE INDEX property_name_idx ON property ( name );
CREATE INDEX property_val_int_idx ON property ( val_int );
CREATE INDEX property_val_double_idx ON property ( val_double );
CREATE INDEX property_val_string_idx ON property ( val_string );
CREATE INDEX property_val_timestamp_idx ON property ( val_timestamp );
CREATE INDEX property_val_uri_idx ON property ( val_uri );
CREATE INDEX property_val_uom_idx ON property ( val_uom );
CREATE INDEX property_val_lod_idx ON property ( val_lod );
CREATE INDEX property_val_geometry_idx ON property ( val_geometry_id );
CREATE INDEX property_val_implicitgeom_idx ON property ( val_implicitgeom_id );
CREATE INDEX property_val_appearance_idx ON property ( val_appearance_id );
CREATE INDEX property_val_address_idx ON property ( val_address_id );
CREATE INDEX property_val_feature_idx ON property ( val_feature_id );
CREATE INDEX property_val_relation_type_idx ON property ( val_relation_type );

-- Add comments (also for future use with SELECT AI)

COMMENT ON TABLE property IS 'The PROPERTY table serves as the central storage location for feature properties. Additionally, the table also represents the semantic relationships between features and other entities. Each property is basically defined by its name, namespace, data type, and value based on a key-value pair design pattern. Based on a type-forced approach, property values are stored in one or more predefined columns that correspond to specific data types allowing for efficient storage and query performance.';

COMMENT ON COLUMN property.id IS 'Column ID uniquely identifies each property and serves as its primary key.';
COMMENT ON COLUMN property.feature_id IS 'Column FEATURE_ID links to the related feature in table FEATURE.';
COMMENT ON COLUMN property.parent_id IS 'Complex attributes with nested structures are not stored in a single JSON column. Instead, they are either stored within a single row or represented in a hierarchical manner across multiple rows linked via the PARENT_ID column.';
COMMENT ON COLUMN property.datatype_id IS 'Column DATATYPE_ID determines the data type of the property and references a dedicated metadata table called DATATYPE in the metadata module';
COMMENT ON COLUMN property.namespace_id IS 'Column NAMESPACE_ID determines the namespace of the property and it is linked to table NAMESPACE.';
COMMENT ON COLUMN property.name IS 'Column NAME stores the property name.';
COMMENT ON COLUMN property.val_int IS 'Column VAL_INT stores integer values as simple primitive types.';
COMMENT ON COLUMN property.val_double IS 'Column VAL_DOUBLE stores double values as simple primitive types.';
COMMENT ON COLUMN property.val_string IS 'Column VAL_STRING stores string values as simple primitive types.';
COMMENT ON COLUMN property.val_timestamp IS 'Column VAL_TIMESTAMP stores timestamp values as simple primitive types.';
COMMENT ON COLUMN property.val_uri IS '';
COMMENT ON COLUMN property.val_codespace IS '';
COMMENT ON COLUMN property.val_uom IS 'Column VAL_UOM stores the unit of measure.';
COMMENT ON COLUMN property.val_array IS 'Column VAL_ARRAY stores array values as JSON structures. It is a non-primitive type or attribute.';
COMMENT ON COLUMN property.val_lod IS 'Column VAL_LOD qualifies the level of detail and is related to column VAL_GEOMETRY_ID.';
COMMENT ON COLUMN property.val_geometry_id IS 'Column VAL_GEOMETRY_ID stores geometric associations referencing table GEOMETRY_DATA and may optionally be qualified by a level of detail via the VAL_LOD column';
COMMENT ON COLUMN property.val_implicitgeom_id IS 'Implicit geometries are referenced through the VAL_IMPLICITGEOM_ID column combined with the transformation data stored in the VAL_ARRAY and VAL_IMPLICITGEOM_REFPOINT columns.';
COMMENT ON COLUMN property.val_implicitgeom_refpoint IS 'Column VAL_IMPLICITGEOM_REFPOINT is related to column VAL_IMPLICITGEOM_ID.';
COMMENT ON COLUMN property.val_appearance_id IS 'Column VAL_APPEARANCE_ID stores additional associations of the property. It is linked to table APPEARANCE.';
COMMENT ON COLUMN property.val_address_id IS 'Column VAL_ADDRESS_ID stores additional associations of the property. It is linked to table ADDRESS.';
COMMENT ON COLUMN property.val_feature_id IS 'Column VAL_FEATURE_ID stores references to other features.';
COMMENT ON COLUMN property.val_relation_type IS '';
COMMENT ON COLUMN property.val_content IS 'Column VAL_CONTENT stores arbitrary binary content. It corresponds with column VAL_CONTENT_MIME_TYPE.';
COMMENT ON COLUMN property.val_content_mime_type IS 'Column VAL_CONTENT_MIME_TYPE stores the mime type of arbitrary binary content. It corresponds with column VAL_CONTENT.';

--
-- Table GEOMETRY_DATA (Geometry module)
--

CREATE TABLE IF NOT EXISTS geometry_data (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  geometry                      SDO_GEOMETRY,
  implicit_geometry             SDO_GEOMETRY,
  geometry_properties           JSON,
  feature_id                    NUMBER(38),
  CONSTRAINT geometry_data_pk PRIMARY KEY ( id ) ENABLE
);

-- INSERT INTO USER_SDO_GEOM_METADATA ( ... )

-- Create indices

-- CREATE INDEX geometry_data_sdx ON geometry_data ( geometry ) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
CREATE INDEX geometry_data_feature_idx ON geometry_data ( feature_id );

-- Add comments (also for future use with SELECT AI)

COMMENT ON TABLE geometry_data IS 'The GEOMETRY_DATA table serves as the central location for storing both explicit and implicit geometry data of the features stored in the database. It supports various geometry types, including points, lines, surfaces, and volume geometries.';

COMMENT ON COLUMN geometry_data.id IS 'Column ID uniquely identifies an explicit feature geometry and serves as its primary key.';
COMMENT ON COLUMN geometry_data.geometry IS 'Column GEOMETRY stores explicit feature geometries, which are geometries with real-world coordinates. This column uses the datatype SDO_GEOMETRY to represent the geometry data. All explicit geometries must be stored using 3D coordinates in the coordinate reference system defined for the 3DCityDB instance.';
COMMENT ON COLUMN geometry_data.implicit_geometry IS 'Column IMPLICIT_GEOMETRY stores implicit feature geometries';
COMMENT ON COLUMN geometry_data.geometry_properties IS 'Column GEOMETRY_PROPERTIES links to the related properties in table PROPERTY.';
COMMENT ON COLUMN geometry_data.feature_id IS 'Column FEATURE_ID links to the related feature in table FEATURE.';

--
-- Table IMPLICIT_GEOMETRY (Geometry module)
--

CREATE TABLE IF NOT EXISTS implicit_geometry (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  objectid                      VARCHAR2(256),
  mime_type                     VARCHAR2(256) ,
  mime_type_codespace           VARCHAR2(256),
  reference_to_library          VARCHAR2(256),
  library_object                BLOB,
  relative_geometry_id          NUMBER(38),
  CONSTRAINT implicit_geometry_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX implicit_geometry_objectid_idx ON implicit_geometry ( objectid );
CREATE INDEX implicit_geometry_relative_geometry_idx ON implicit_geometry ( relative_geometry_id );

-- Add comments (also for future use with SELECT AI)

COMMENT ON TABLE implicit_geometry IS 'Table IMPLICIT_GEOMETRY stores implicit geometries, which can be reused as templates for multiple features according to the CityGML implicit geometry concept.';

COMMENT ON COLUMN implicit_geometry.id IS 'Column ID uniquely identifies an implicit feature geometry and serves as its primary key.';

--
-- Table TEX_IMAGE (Appearance module)
--

CREATE TABLE IF NOT EXISTS tex_image (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  image_uri                     VARCHAR2(4000),
  image_data                    BLOB,
  mime_type                     VARCHAR2(256),
  mime_type_codespace           VARCHAR2(4000),
  CONSTRAINT tex_image_pk PRIMARY KEY ( id ) ENABLE
 );

--
-- Table APPEARANCE (Appearance module)
--

CREATE TABLE IF NOT EXISTS appearance (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY,
  objectid                      VARCHAR2(256),
  identifier                    VARCHAR2(256),
  identifier_codespace          VARCHAR2(1000),
  theme                         VARCHAR2(256),
  is_global                     NUMBER(1),
  feature_id                    NUMBER(38),
  implicit_geometry_id          NUMBER(38),
  CONSTRAINT appearance_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX appearance_feature_idx ON appearance ( feature_id );
CREATE INDEX appearance_implicit_geometry_idx ON appearance ( implicit_geometry_id );

--
-- Table SURFACE_DATA (Appearance module)
--

CREATE TABLE IF NOT EXISTS surface_data (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  objectid                      VARCHAR2(256),
  identifier                    VARCHAR2(256),
  identifier_codespace          VARCHAR2(1000),
  is_front                      NUMBER(1),
  objectclass_id                NUMBER(38) NOT NULL,
  x3d_shininess                 BINARY_DOUBLE,
  x3d_transparency              BINARY_DOUBLE,
  x3d_ambient_intensity         BINARY_DOUBLE,
  x3d_specular_color            VARCHAR2(256),
  x3d_diffuse_color             VARCHAR2(256),
  x3d_emissive_color            VARCHAR2(256),
  x3d_is_smooth                 NUMBER(1),
  tex_image_id                  NUMBER(38),
  tex_texture_type              VARCHAR2(256),
  tex_wrap_mode                 VARCHAR2(256),
  tex_border_color              VARCHAR2(256),
  gt_orientation                JSON,
  gt_reference_point            SDO_GEOMETRY,
  CONSTRAINT surface_data_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX surface_data_tex_image_idx ON surface_data ( tex_image_id );
CREATE INDEX surface_data_objectclass_idx ON surface_data ( objectclass_id );

--
-- Table SURFACE_DATA_MAPPING (Appearance module)
--

CREATE TABLE IF NOT EXISTS surface_data_mapping (
  surface_data_id               NUMBER(38) NOT NULL,
  geometry_data_id              NUMBER(38) NOT NULL,
  material_mapping              JSON,
  texture_mapping               JSON ,
  world_to_texture_mapping      JSON,
  georeferenced_texture_mapping JSON,
  CONSTRAINT surface_data_mapping_pk PRIMARY KEY ( geometry_data_id, surface_data_id ) ENABLE
);

-- Create indices

CREATE INDEX surface_data_mapping_geometry_data_idx ON surface_data_mapping ( geometry_data_id );
CREATE INDEX surface_data_mapping_surface_data_idx ON surface_data_mapping ( surface_data_id );

--
-- Table APPEAR_TO_SURFACE_DATA (Appearance module)
--

CREATE TABLE IF NOT EXISTS appear_to_surface_data (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  appearance_id                 NUMBER(38) NOT NULL,
  surface_data_id               NUMBER(38),
  CONSTRAINT appear_to_surface_data_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX appear_to_surface_data_appearance_idx ON appear_to_surface_data ( appearance_id );
CREATE INDEX appear_to_surface_data_surface_data_idx ON appear_to_surface_data ( surface_data_id );

--
-- Table CODELIST (Codelist module)
--

CREATE TABLE IF NOT EXISTS codelist (
  id                            NUMBER(38),
  codelist_type                 VARCHAR2(256),
  url                           VARCHAR2(4000),
  mime_type                     VARCHAR2(256),
  CONSTRAINT codelist_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX codelist_codelist_type_idx ON codelist ( codelist_type );

--
-- Table CODELIST_ENTRY (Codelist module)
--

CREATE TABLE IF NOT EXISTS codelist_entry (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
	codelist_id                   NUMBER(38) NOT NULL,
	code                          VARCHAR2(256),
	definition                    VARCHAR2(256),
	CONSTRAINT codelist_entry_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX codelist_entry_codelist_idx ON codelist_entry ( codelist_id );

--
-- Table ADE (Metadata module)
--

CREATE TABLE IF NOT EXISTS ade (
  id                            NUMBER(38) GENERATED ALWAYS AS IDENTITY (START WITH 1),
  name                          VARCHAR2(1000) NOT NULL,
  description                   VARCHAR2(4000),
  version                       VARCHAR2(256),
  CONSTRAINT ade_pk PRIMARY KEY ( id ) ENABLE
);

--
-- Table DATABASE_SRS (Metadata module)
--

CREATE TABLE IF NOT EXISTS database_srs (
	srid                          NUMBER(38) NOT NULL,
	srs_name                      VARCHAR2(1000) ,
	CONSTRAINT database_srs_pk PRIMARY KEY ( srid ) ENABLE
);

--
-- Table NAMESPACE (Metadata module)
--

CREATE TABLE IF NOT EXISTS namespace (
  id                            NUMBER(38),
  alias                         VARCHAR2(256),
  namespace                     VARCHAR2(4000),
  ade_id                        NUMBER(38),
  CONSTRAINT namespace_pk PRIMARY KEY ( id ) ENABLE
);

--
-- Table OBJECTCLASS (Metadata module)
--

CREATE TABLE IF NOT EXISTS objectclass (
  id                            NUMBER(38) NOT NULL,
  superclass_id                 NUMBER(38),
  classname                     VARCHAR2(256),
  is_abstract                   NUMBER(1),
  is_toplevel                   NUMBER(1),
  ade_id                        NUMBER(38),
  namespace_id                  NUMBER(38),
  schema                        BFILE,
  CONSTRAINT objectclass_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX objectclass_superclass_idx ON objectclass ( superclass_id );

--
-- Table DATA_TYPE (Metadata module)
--

CREATE TABLE IF NOT EXISTS datatype (
  id                            NUMBER(38),
  supertype_id                  NUMBER(38),
  typename                      VARCHAR2(256),
  is_abstract                   NUMBER(1),
  ade_id                        NUMBER(38),
  namespace_id                  NUMBER(38),
  schema                        BFILE,
  CONSTRAINT datatype_pk PRIMARY KEY ( id ) ENABLE
);

-- Create indices

CREATE INDEX datatype_supertype_idx ON datatype ( supertype_id );

--
-- Add constraints
--

ALTER TABLE property ADD CONSTRAINT property_parent_fk FOREIGN KEY ( parent_id ) REFERENCES property ( id ) ON DELETE SET NULL;
ALTER TABLE property ADD CONSTRAINT property_feature_fk FOREIGN KEY ( feature_id ) REFERENCES feature ( id ) ON DELETE CASCADE;
ALTER TABLE property ADD CONSTRAINT property_val_geometry_fk FOREIGN KEY ( val_geometry_id ) REFERENCES geometry_data ( id ) ON DELETE CASCADE;
ALTER TABLE property ADD CONSTRAINT property_val_implicitgeom_fk FOREIGN KEY ( val_implicitgeom_id ) REFERENCES implicit_geometry ( id ) ON DELETE CASCADE;
ALTER TABLE property ADD CONSTRAINT property_val_appearance_fk FOREIGN KEY ( val_appearance_id ) REFERENCES appearance ( id ) ON DELETE CASCADE;
ALTER TABLE property ADD CONSTRAINT property_val_address_fk FOREIGN KEY ( val_address_id ) REFERENCES address ( id ) ON DELETE CASCADE;
ALTER TABLE property ADD CONSTRAINT property_val_feature_fk FOREIGN KEY ( val_feature_id ) REFERENCES feature ( id ) ON DELETE CASCADE;

ALTER TABLE geometry_data ADD CONSTRAINT geometry_data_feature_fk FOREIGN KEY ( feature_id ) REFERENCES feature ( id ) ON DELETE SET NULL;

ALTER TABLE implicit_geometry ADD CONSTRAINT implicit_geometry_relative_geometry_fk FOREIGN KEY ( relative_geometry_id ) REFERENCES geometry_data ( id ) ON DELETE CASCADE;

ALTER TABLE appearance ADD CONSTRAINT appearance_feature_fk FOREIGN KEY ( feature_id ) REFERENCES feature ( id ) ON DELETE SET NULL;
ALTER TABLE appearance ADD CONSTRAINT appearance_implicit_geometry_fk FOREIGN KEY ( implicit_geometry_id ) REFERENCES implicit_geometry ( id ) ON DELETE CASCADE;

ALTER TABLE surface_data ADD CONSTRAINT surface_data_tex_image_fk FOREIGN KEY ( tex_image_id ) REFERENCES tex_image ( id ) ON DELETE SET NULL;
ALTER TABLE surface_data ADD CONSTRAINT surface_data_objectclass_fk FOREIGN KEY ( objectclass_id ) REFERENCES objectclass ( id ) ON DELETE SET NULL;

ALTER TABLE surface_data_mapping ADD CONSTRAINT surface_data_mapping_geometry_data_fk FOREIGN KEY ( geometry_data_id ) REFERENCES geometry_data ( id ) ON DELETE CASCADE;
ALTER TABLE surface_data_mapping ADD CONSTRAINT surface_data_mapping_surface_data_fk FOREIGN KEY ( surface_data_id ) REFERENCES surface_data ( id ) ON DELETE CASCADE;

ALTER TABLE appear_to_surface_data ADD CONSTRAINT appear_to_surface_data_appearance_fk FOREIGN KEY ( appearance_id ) REFERENCES appearance ( id ) ON DELETE CASCADE;
ALTER TABLE appear_to_surface_data ADD CONSTRAINT appear_to_surface_data_surface_data_fk FOREIGN KEY ( surface_data_id ) REFERENCES surface_data ( id ) ON DELETE CASCADE;

ALTER TABLE codelist_entry ADD CONSTRAINT codelist_entry_codelist_fk FOREIGN KEY ( codelist_id )  REFERENCES codelist ( id ) ON DELETE CASCADE;

ALTER TABLE namespace ADD CONSTRAINT namespace_ade_fk FOREIGN KEY ( ade_id ) REFERENCES ade ( id ) ON DELETE CASCADE;

ALTER TABLE objectclass ADD CONSTRAINT objectclass_superclass_fk FOREIGN KEY ( superclass_id ) REFERENCES objectclass ( id ) ON DELETE CASCADE;
ALTER TABLE objectclass ADD CONSTRAINT objectclass_ade_fk FOREIGN KEY ( ade_id ) REFERENCES ade ( id ) ON DELETE CASCADE;
ALTER TABLE objectclass ADD CONSTRAINT objectclass_namespace_fk FOREIGN KEY ( namespace_id ) REFERENCES namespace ( id ) ON DELETE CASCADE;

ALTER TABLE datatype ADD CONSTRAINT datatype_superclass_fk FOREIGN KEY ( supertype_id ) REFERENCES datatype ( id ) ON DELETE CASCADE;
ALTER TABLE datatype ADD CONSTRAINT datatype_ade_fk FOREIGN KEY ( ade_id ) REFERENCES ade ( id );
ALTER TABLE datatype ADD CONSTRAINT datatype_namespace_fk FOREIGN KEY ( namespace_id ) REFERENCES namespace ( id ) ON DELETE CASCADE;
