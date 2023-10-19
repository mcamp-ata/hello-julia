{
  description = "A simple Poetry project that calls Julia!";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; };
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
          ${pkgs.poetry}/bin/poetry run python ${./hello.py}
        '';
      };

      defaultPackage = self.packages.${system}.hello-world;
    }
  );
}
