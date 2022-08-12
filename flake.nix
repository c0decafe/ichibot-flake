{
  description = "ichibot-client-app";
  nixConfig.bash-prompt = "ichibot-dev> ";
  inputs.src.url = gitlab:Ichimikichiki/ichibot-client-app;
  inputs.src.flake = false;

  outputs = {
    self,
      nixpkgs,
      src
  }:
    let
      name = "ichibot";
      supportedSystems = nixpkgs.lib.systems.flakeExposed;
    in {
      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        ichibot = nixpkgs.legacyPackages.${system}.mkYarnPackage {
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
      });

      devShell = nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          pkgs.mkShell {
            buildInputs = [
              pkgs.nodejs
              pkgs.yarn
            ];
          }
      );

      overlay = _: super: self.packages.${super.stdenv.hostPlatform.system} or { };
    };
}
