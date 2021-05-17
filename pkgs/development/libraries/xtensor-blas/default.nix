{ lib, stdenv, fetchFromGitHub, cmake, xtl, xtensor, xsimd, openblas, gtest, gbenchmark }:

stdenv.mkDerivation rec {
  pname = "xtensor-blas";
  version = "0.19.1";

  #src = fetchFromGitHub {
  #  owner = "xtensor-stack";
  #  repo = pname;
  #  rev = version;
  #  sha256 = "1hlblvzyn2yr7kvjg92q2l13swvp92jwgpanqc0cn5msjzgz2m9c";
  #};
  src = /home/lsix/dev/tmp/xtensor-blas;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ xtl xtensor openblas ];

  #cmakeFlags = [ "-DBUILD_TESTS=ON" ];

  doCheck = true;
  checkInputs = [ gtest gbenchmark ];

  meta = with lib; {
    description = "Multi-dimensional arrays with broadcasting and lazy computing";
    homepage = "https://github.com/xtensor-stack/xtensor-blas";
    license = licenses.bsd3;
    maintainers = with maintainers; [ lsix ];
    platforms = platforms.all;
  };
}
