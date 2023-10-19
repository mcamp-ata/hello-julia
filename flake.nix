{
  description = "A simple Poetry project that calls Julia!";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; };
      hello_py = "./hello.py";
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
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.python3
          pkgs.poetry
          pkgs.zlib
          pkgs.libstdcxx5
          pkgs.gcc
          pkgs.julia

        ];
        shellHook = ''
          export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
          export LD_LIBRARY_PATH="${pkgs.gcc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH"
          export PYTHON="${pkgs.python3}/bin/python"
          export JULIA_CONDAPKG_BACKEND="Null"
          export JULIA_PYTHONCALL_EXE="${pkgs.python3}/bin/python"
          zsh
        '';
      };

      packages = {
        hello-world = poetry2nix.mkPoetryApplication {
          projectDir = ./.;
          python = pkgs.python3;
        };
        run-hello-world = pkgs.writeShellScriptBin "run-hello-world" ''
          ${pkgs.poetry}/bin/poetry run python ${hello_py}
        '';
        pluto = pkgs.writeShellScriptBin "pluto" ''
          ${pkgs.julia}/bin/julia ${startPlutoScript}
        '';
      };

      defaultPackage = self.packages.${system}.hello-world;
    }
  );
}
