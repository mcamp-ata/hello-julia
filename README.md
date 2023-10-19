# README

This is an attempt at making an example project that uses Python + Julia in a Nix Flake. 
This is not perfect and currently requires you to clone this repo an do the following:

1. `git clone <this repo>`
2. `nix develop` from within the repo
3. `poetry install`
4. Go forth and do things. You can run `nix run .#run-hello-world` to see the hello world program work that uses Julia
to say Hello. 
