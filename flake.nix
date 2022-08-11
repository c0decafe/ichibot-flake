{
  description = "ichibot-client-app";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.src.url = gitlab:Ichimikichiki/ichibot-client-app;
  inputs.src.flake = false;

  outputs = {
    self,
      nixpkgs,
      flake-utils,
      src
  }: flake-utils.lib.eachDefaultSystem (system:
    let
      name = "ichibot";
      pkgs = nixpkgs.legacyPackages.${system};

      defaultPackage = pkgs.mkYarnPackage {
        inherit src name;
        yarnFlags = [ "--offline" "--frozen-lockfile" "--ignore-engines" ];
        postConfigure = ''
          cd deps/${name}
          yarn tsc
          sed -i '1i#!/usr/bin/env node' dist/index.js
          chmod +x dist/index.js
          cd ../..
        '';
      };

      overlay = final: prev: {
        ichibot = defaultPackage;
      };

      devShell =
        pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs-14_x
            pkgs.yarn
            pkgs.yarn2nix
          ];
        };
    in {
      inherit defaultPackage overlay devShell;
    }
  );
}
