{ lib, stdenv, fetchFromGitHub, cmake, xtl, xsimd, tbb, gtest }:

stdenv.mkDerivation rec {
  pname = "xtensor";
  version = "0.23.9";

  src = fetchFromGitHub {
    owner = "xtensor-stack";
    repo = pname;
    rev = version;
    sha256 = "0fim11ip2f4bdjaxahscqlznnkww59fc1ljwpm89s80arvr9ragn";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ xtl xsimd tbb ];

  cmakeFlags = [
    "-DBUILD_TESTS=ON"
    "-DXTENSOR_USE_XSIMD=ON"
  ];

  doCheck = true;
  checkInputs = [ gtest ];
  checkTarget = "xtest";

  meta = with lib; {
    description = "Multi-dimensional arrays with broadcasting and lazy computing";
    homepage = "https://github.com/xtensor-stack/xtensor";
    license = licenses.bsd3;
    maintainers = with maintainers; [ lsix ];
    platforms = platforms.all;
  };
}
