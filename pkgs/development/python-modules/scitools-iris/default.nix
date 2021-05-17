{ buildPythonPackage
, fetchPypi
, cartopy
, cf-units
, cftime
, dask
, matplotlib
, netcdf4
, numpy
, scipy
, xxhash
, pyke
, nose
, pillow
, black
}:

buildPythonPackage rec {
  pname = "scitools-iris";
  version = "3.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03gdjrasl83sjw060g5mkzkvgs9lxnvna7wi2lw6w8nbm2h0f3fm";
  };

  patchPhase = ''
    substituteInPlace requirements/core.txt \
      --replace \
        "cftime<1.3.0" \
        "cftime"
    substituteInPlace requirements/test.txt \
      --replace \
        "pillow<7" \
        "pillow"
  '';

  propagatedBuildInputs = [
    pyke
    cartopy
    cf-units
    cftime
    dask
    matplotlib
    netcdf4
    numpy
    scipy
    xxhash
    black
  ];

  checkInputs = [
    nose
    pillow
  ];
}
