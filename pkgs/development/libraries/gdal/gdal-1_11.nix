{ stdenv, fetchurl, unzip, libjpeg, libtiff, zlib
, postgresql, mysql, libgeotiff, python, pythonPackages, proj, geos, openssl
, libpng }:

stdenv.mkDerivation rec {
  version = "1.11.5";
  name = "gdal-${version}";

  src = fetchurl {
    url = "http://download.osgeo.org/gdal/${version}/${name}.tar.xz";
    sha256 = "0hphxzvy23v3vqxx1y22hhhg4cypihrb8555y12nb4mrhzlw7zfl";
  };

  buildInputs = [ unzip libjpeg libtiff libpng python pythonPackages.numpy proj openssl ];

  patches = [
    # This ensures that the python package is installed into gdal's prefix,
    # rather than trying to install into python's prefix.
    ./python.patch
  ];

  hardeningDisable = [ "format" ];

  # Unset CC and CXX as they confuse libtool.
  preConfigure = "unset CC CXX";

  configureFlags = [
    "--with-jpeg=${libjpeg.dev}"
    "--with-libtiff=${libtiff.dev}" # optional
    "--with-libpng=${libpng.dev}"   # optional
    "--with-libz=${zlib.dev}"       # optional

    "--with-pg=${postgresql}/bin/pg_config"
    "--with-mysql=${mysql.lib.dev}/bin/mysql_config"
    "--with-geotiff=${libgeotiff}"
    "--with-python"               # optional
    "--with-static-proj4=${proj}" # optional
    "--with-geos=${geos}/bin/geos-config"# optional
  ];

  # Prevent this:
  #
  #   Checking .pth file support in /nix/store/xkrmb8xnvqxzjwsdmasqmsdh1a5y2y99-gdal-1.11.2/lib/python2.7/site-packages/
  #   /nix/store/pbi1lgank10fy0xpjckbdpgacqw34dsz-python-2.7.9/bin/python -E -c pass
  #   TEST FAILED: /nix/store/xkrmb8xnvqxzjwsdmasqmsdh1a5y2y99-gdal-1.11.2/lib/python2.7/site-packages/ does NOT support .pth files
  #   error: bad install directory or PYTHONPATH
  preBuild = ''
    pythonInstallDir=$out/lib/${python.libPrefix}/site-packages
    mkdir -p $pythonInstallDir
    export PYTHONPATH=''${PYTHONPATH:+''${PYTHONPATH}:}$pythonInstallDir
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Translator library for raster geospatial data formats";
    homepage = http://www.gdal.org/;
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.marcweber ];
    platforms = stdenv.lib.platforms.linux;
  };
}
