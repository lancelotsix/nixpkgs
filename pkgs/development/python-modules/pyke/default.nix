{ buildPythonPackage
, fetchurl
, wxPython_4_0
}:

buildPythonPackage rec {
  pname = "pyke";
  version = "1.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/${pname}/${pname}3-${version}.zip";
    sha256 = "1p5ndiwlrxy6qqxcm617zim2fiz9zn9akhwp3p0aqbhawy8b6xxq";
  };

  propagatedBuildInputs = [
    wxPython_4_0
  ];

  doCheck = false;
}
