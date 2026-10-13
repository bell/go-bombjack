{
  description = "Bomb Jack Go development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          linuxLibraries = with pkgs; [
            alsa-lib
            libGL
            libx11
            libxcursor
            libxi
            libxinerama
            libxrandr
            libxxf86vm
          ];
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ go_1_27 gnumake pkg-config python3 stdenv.cc ]
              ++ lib.optionals stdenv.hostPlatform.isLinux linuxLibraries;

            shellHook = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath linuxLibraries}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              # GLVND needs the host's GPU driver, beyond the build libraries.
              if [ -d /run/opengl-driver/lib ]; then
                export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"
              fi
            '';
          };
        });
    };
}
