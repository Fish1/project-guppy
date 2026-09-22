{
  description = "project-guppy";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    zigflake = {
      url = "github:silversquirl/zig-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      utils,
      zigflake,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zigflake.packages.${system}.zig_0_16_0;
        zls = zigflake.packages.${system}.zig_0_16_0.zls;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            zig
            zls
            pkgs.sdl3
          ];
        };
      }
    );
}
