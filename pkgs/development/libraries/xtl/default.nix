{ lib, stdenv, fetchFromGitHub, cmake, gtest }:

stdenv.mkDerivation rec {
  pname = "xtl";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "xtensor-stack";
    repo = pname;
    rev = version;
    sha256 = "177ym67sz544wdylksfkkpi6bqn34kagycfnb3cv0nkmpipqj9lg";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUILD_TESTS=ON" ];

  doCheck = true;
  checkInputs = [ gtest ];

  meta = with lib; {
    description = "Basic tools used by other quantstack packages";
    homepage = "https://github.com/xtensor-stack/xtl";
    license = licenses.bsd3;
    maintainers = with maintainers; [ lsix ];
    platforms = platforms.all;
  };
}
