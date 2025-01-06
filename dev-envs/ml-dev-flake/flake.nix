{
  description = "Python 3.11 development environment";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.${system}.default = (pkgs.buildFHSEnv {
        name = "nvidia-fuck-you";
        targetPkgs = pkgs:
          (with pkgs; [
            linuxPackages.nvidia_x11_production
            libGLU
            libGL
            xorg.libXi
            xorg.libXmu
            freeglut
            xorg.libXext
            xorg.libX11
            xorg.libXv
            xorg.libXrandr
            zlib
            ncurses5
            stdenv.cc
            binutils
            ffmpeg
            zsh

            # Micromamba does the real legwork
            micromamba
          ]);

        profile = ''
          export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11_production}/lib"
          export CUDA_PATH="${pkgs.cudatoolkit}"
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_production}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          set -e 
          eval "$(micromamba shell hook --shell=posix)"
          if ! test -d $MAMBA_ROOT_PREFIX/envs/torch; then
              micromamba create --yes -q -n torch python=3.11 -c conda-forge
          fi
          micromamba activate torch
          set +e
        '';

        # again, you can remove this if you like bash
        runScript = "zsh";
      }).env;
    };
}
