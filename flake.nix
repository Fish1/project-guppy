{
	description = "project-guppy";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:numtide/flake-utils";
		
		zig-overlay = {
			url = "github:silversquirl/zig-flake/compat";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		zls-overlay = {
			url = "github:zigtools/zls/techatrix/update-zig";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.zig-overlay.follows = "zig-overlay";
		};
	};

	outputs = { nixpkgs, utils, zig-overlay, zls-overlay, ... }:
	utils.lib.eachDefaultSystem(system:
		let
			pkgs = nixpkgs.legacyPackages.${system};
			zig = zig-overlay.packages.${system}.zig_0_16_0;
			zls = zls-overlay.packages.${system}.zls.overrideAttrs(
				old: {
					nativeBuildInputs = [
						zig
					];
				}
			);
		in {
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
