#!/usr/bin/env bash
# 3DCityDB setup --------------------------------------------------------------

# Set 3DCityDB version --------------------------------------------------------
if [ -z $CITYDB_VERSION ]; then
  # CITYDB_VERSION unset, read version from the version.txt file
  read -r CITYDB_VERSION < version.txt
fi

# Print commands and their arguments as they are executed
set -e

# ORACLE_PDB ------------------------------------------------------------------
if [ -z ${ORACLE_PDB+x} ]; then
  ORACLE_PDB="PDB1"
else
  ORACLE_PDB="$ORACLE_PDB"
fi

# DBHOST ----------------------------------------------------------------------
if [ -z ${ORACLE_PDB+x} ]; then
  DBHOST="localhost"
else
  DBHOST="$DBHOST"
fi

# DBPORT ----------------------------------------------------------------------
if [ -z ${ORACLE_PDB+x} ]; then
  DBPORT="1521"
else
  DBPORT="$DBPORT"
fi

# DBUSER ----------------------------------------------------------------------
if [ -z ${DBUSER+x} ]; then
  DBUSER="citydb"
else
  DBUSER="$DBUSER"
fi

# ORACLE_PWD ------------------------------------------------------------------
if [ -z ${ORACLE_PWD+x} ]; then
  echo
  echo "Password (ORACLE_PWD) must be set for Oracle Database users."
  exit
fi

# TABLESPACE ------------------------------------------------------------------
if [ -z ${TABLESPACE+x} ]; then
  TABLESPACE="users"
else
  TABLESPACE="$TABLESPACE"
fi

# VERSIONING ------------------------------------------------------------------
if [ -z ${VERSIONING+x} ]; then
  VERSIONING="no"
else
  VERSIONING="$VERSIONING"
fi

# CHANGELOG -------------------------------------------------------------------
if [ -z ${CHANGELOG+x} ]; then
  CHANGELOG="no"
else
  CHANGELOG="$CHANGELOG"
fi

# SRID ------------------------------------------------------------------------
regex_numeric='^[0-9]+$'
if [ -z ${SRID+x} ]; then
  # No SRID set -> give instructions on how to create a DB and do nothing
  echo
  echo "SRID is not set. No 3DCityDB instance will be created in database '$ORACLE_DB'."
  exit
else
  # SRID given, check if valid
  if [[ ! $SRID =~ $regex_numeric ]] || [ $SRID -le 0 ]; then
        echo
        echo 'Illegal input! Enter a positive integer for the SRID.'
  fi
fi

# SRS_NAME --------------------------------------------------------------------
if [ -z ${SRS_NAME+x} ]; then
  # SRS_NAME unset, set default SRS_NAME using HEIGHT_EPSG if set
  # HEIGHT EPSG ---------------------------------------------------------------
  if [ -z ${HEIGHT_EPSG+x} ]; then
    # No HEIGHT_EPSG given
    SRS_NAME="urn:ogc:def:crs:EPSG::$SRID"
  else
    if [ $HEIGHT_EPSG -gt 0 ]; then
      SRS_NAME="urn:ogc:def:crs,crs:EPSG::$SRID,crs:EPSG::$HEIGHT_EPSG"
    else
      SRS_NAME="urn:ogc:def:crs:EPSG::$SRID"
    fi
  fi
else
  if [ ! -z ${HEIGHT_EPSG+x} ]; then
    # SRS_NAME is set, HEIGHT_EPSG is ignored
    echo
    echo "!!! WARNING: SRS_NAME is set. HEIGHT_EPSG will be ignored."
  fi
fi

# Create user -----------------------------------------------------------------
echo
echo "Creating user $DBUSER ..."
echo "CREATE USER IF NOT EXISTS $DBUSER identified by $ORACLE_PWD QUOTA UNLIMITED ON $TABLESPACE;
      GRANT CONNECT, RESOURCE to $DBUSER;
      GRANT CREATE SESSION TO $DBUSER;
      GRANT DB_DEVELOPER_ROLE TO $DBUSER;" | sqlplus system/"$ORACLE_PWD"@"$DBHOST":"$DBPORT"/"$ORACLE_PDB"
echo "Creating user $DBUSER ... done!"
echo

# Enable GeoRaster (required since Oracle 19c)
echo "EXECUTE SDO_GEOR_ADMIN.ENABLEGEORASTER;" | sqlplus "$DBUSER"/"$ORACLE_PWD"@"$DBHOST":"$DBPORT"/"$ORACLE_PDB"

# Setup 3DCityDB schema -------------------------------------------------------
echo
echo "Setting up 3DCityDB database schema in database $DBUSER ..."
sqlplus -S -L "$DBUSER"/"$ORACLE_PWD"@"$DBHOST":"$DBPORT"/"$ORACLE_PDB" @CREATE_DB.sql "${SRID}" "${SRSNAME}" "${VERSIONING}"
echo "Setting up 3DCityDB schema in $DBUSER ...done!"
echo
echo "# Setting up 3DCityDB ... done! ################################################"

# Echo info -------------------------------------------------------------------
cat <<EOF


# 3DCityDB Docker Oracle ######################################################
#
# Oracle Version --------------------------------------------------------------
#
#   Latest Oracle Database Enterprise Edition from Oracle Container Registry
#   https://container-registry.oracle.com/database/enterprise:21.3.0.0
#   !! 23ai not yet available !!
#
#   Latest Oracle Database 23ai Free Edition from Oracle Container Registry
#   https://container-registry.oracle.com/database/free:latest
#
# 3DCityDB --------------------------------------------------------------------
#   3DCityDB version    $CITYDB_VERSION
#   ORACLE_PDB          $ORACLE_PDB
#   DBHOST              $DBHOST
#   DBPORT              $DBPORT
#   DBUSER              $DBUSER
#   ORACLE_PWD          $ORACLE_PWD
#   TABLESPACE          $TABLESPACE
#   VERSIONING enabled  $VERSIONING
#   CHANGELOG enabled   $CHANGELOG
#   SRID                $SRID
#   SRSNAME             $SRS_NAME
#   HEIGHT_EPSG         $HEIGHT_EPSG
#
# Maintainer ------------------------------------------------------------------
#   ...
#   ...
#   ...
#   ...
#   ...
#
################################################################################

EOF
