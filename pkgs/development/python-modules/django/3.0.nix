{ stdenv, buildPythonPackage, isPy3k, fetchPypi, substituteAll
, geos, gdal, withGdal ? false
, asgiref, pytz, sqlparse
}:

buildPythonPackage rec {
  pname = "Django";
  version = "3.0.6";

  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "00ay7gpkb0c61bkqvyyv5pfy7hzah9jcaj59k06qy6wfcw4nmals";
  };

  patches = stdenv.lib.optional withGdal
    (substituteAll {
      src = ./3.0-gis-libs.template.patch;
      geos = geos;
      gdal = gdal;
      extension = stdenv.hostPlatform.extensions.sharedLibrary;
    });

  propagatedBuildInputs = [ asgiref pytz sqlparse ];

  # too complicated to setup
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A high-level Python Web framework";
    homepage = "https://www.djangoproject.com/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ georgewhewell lsix ];
  };
}
