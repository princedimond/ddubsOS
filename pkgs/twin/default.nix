{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, ncurses }:

stdenv.mkDerivation rec {
  pname = "twin";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "cosmos72";
    repo = "twin";
    # Use the default branch until a tagged release is verified; we will pin the sha256.
    rev = "master";
    # Pinned after prefetch on master 2025-09-02
    sha256 = "sha256-O3b0xaQGZ3gmZjGvE5i00uKiF03aXFuB0S537z6OfdQ=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ ncurses ];

  enableParallelBuilding = true;
  doCheck = false;

  meta = with lib; {
    description = "Text mode window environment (terminal multiplexer with windows and mouse support)";
    homepage = "https://github.com/cosmos72/twin";
    platforms = platforms.linux;
    maintainers = [ maintainers.none ];
  };
}
