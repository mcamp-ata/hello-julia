{
  description = "A simple Poetry project that calls Julia!";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";
  inputs.devshell.url = "github:numtide/devshell";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, devshell, flake-utils, poetry2nix, ... }: 
    flake-utils.lib.eachDefaultSystem (system: {
    apps.devshell = self.outputs.devShells.${system}.default.flakeApp;
    devShells.default = 
      let 
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            devshell.overlays.default
          ];
        };
        # This is required if you get odd errors
        # read the https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md
        pypkgs-build-requirements = {
          pyjulia = [ "setuptools"];
          julia = [ "setuptools" ];
          juliapkg = [ "setuptools" ];
          urllib3 = [ "hatchling" ];
          juliacall = [ "setuptools" ];
          pandas = [ "versioneer" ];
          # contourpy = [ "mesonpy" ];
          # numpy = [ "setuptools" ];
        };
        p2n-overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super:
          builtins.mapAttrs (package: build-requirements:
            (builtins.getAttr package super).overridePythonAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ (builtins.map (pkg: if builtins.isString pkg then builtins.getAttr pkg super else pkg) build-requirements);
            })
          ) pypkgs-build-requirements
        );
        hello-world = pkgs.poetry2nix.mkPoetryEnv  {
          projectDir = ./.;
          python = pkgs.python3;
          overrides = p2n-overrides;
          preferWheels = true;
        };
        thisProject = pkgs.stdenv.mkDerivation {
          name = "boat_models";
          src = ./.;  # Copy the entire project directory into the Nix store
          installPhase = ''
            mkdir -p $out
            cp -r ./* $out/
          '';
        };
        hello_py = pkgs.writeText "hello.py" (builtins.readFile ./hello.py);

        startPlutoScript = pkgs.writeText "start_pluto.jl" ''
          using Pkg
          Pkg.add("Pluto")
          Pkg.add("ArgParse")
          using Pluto
          using ArgParse

          function main()
              s = ArgParseSettings()

              @add_arg_table s begin
                  "--port", "-p"
                      arg_type = Int
                      default = 1234
                      help = "Port number to start Pluto on."
              end

              parsed_args = parse_args(ARGS, s)

              port = parsed_args["port"]

              Pluto.run(port=port)
          end

          main()
        '';
        pluto = pkgs.writeShellScript "pluto" ''
        ${pkgs.julia}/bin/julia ${startPlutoScript}
        '';
        randomFiglet = pkgs.writeShellScript "randomFiglet" ''
          phrases=("Nix Your Problems Away!" "One Flake to Rule Them All!" "Why Fix It, When You Can Nix It?" "Nixify Life" "Just Nix It" "Powered by Nix")
          random_index=$((RANDOM % 6))
          case $random_index in
            0) ${pkgs.figlet}/bin/figlet "Nixify Life";;
            1) ${pkgs.figlet}/bin/figlet "Just Nix It";;
            2) ${pkgs.figlet}/bin/figlet "Powered by Nix";;
            3) ${pkgs.figlet}/bin/figlet "Nix Your Problems Away!";;
            4) ${pkgs.figlet}/bin/figlet "One Flake to Rule Them All!";;
            5) ${pkgs.figlet}/bin/figlet "Why Fix It, When You Can Nix It?";;
          esac
        '';
      in
      pkgs.devshell.mkShell ({config,...}: {
        imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
        name = "boat-model";
        motd = ''
                 {214}👁️  Welcome to Boat Model devshell 👁️{reset}
                 $( ${randomFiglet} | ${pkgs.lolcat}/bin/lolcat -f )
                 $(type -p menu &>/dev/null && menu)
               '';
        commands = [
          {
            name = "pluto";
            command = ''
            ${pkgs.julia}/bin/julia ${startPlutoScript}
            '';
          }
          {
            # TODO: Fix poetry environment
            name = "hello-world";
            command = ''
            ${hello-world}/bin/python3 ${thisProject}/hello.py
            '';
          }
        ];
        env = [
          {
            name = "LD_LIBRARY_PATH";
            value = "${pkgs.gcc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH";
          }
          {
            name = "PYTHON";
            value = "${pkgs.python3}/bin/python";
          }
          {
            name = "JULIA_CONDAPKG_BACKEND";
            value = "Null";
          }
          {
            name = "JULIA_PYTHONCALL_EXE";
            value = "${pkgs.python3}/bin/python";
          }
        ];
      });
  });
}
