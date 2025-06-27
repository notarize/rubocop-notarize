{
  description = "Proof Rubocop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proof = {
      url = "git+ssh://git@github.com/notarize/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, proof } @ inputs: {
    inherit (proof) formatter;

    devShells = proof.lib.devenv.mapDefaultDevShells (system: {
      name = "rubocop-notarize";
      modules = import ./devenv.nix;
      inherit inputs self;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nixpkgs-ruby.overlays.default # Mixin the nixpkgs-ruby to get every version of Ruby
        ];
      };
    });
  };
}
