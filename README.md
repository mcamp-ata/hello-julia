# README

This is an attempt at making an example project that uses Python + Julia in a Nix Flake. 

If you have `direnv` installed the project run `direnv allow` inside the project dir.


Example of how to run Julia code with Python

```
nix run github:mcamp-ata/hello-julia#devshell -- hello-world
```


Example of how to run Pluto

```
nix run github:mcamp-ata/hello-julia#devshell -- pluto
```
