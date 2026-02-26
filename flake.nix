{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
    };

    proof = {
      url = "git+ssh://git@github.com/notarize/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, proof } @ inputs: {
    inherit (proof) formatter;

    devShells = proof.lib.devenv.mapDefaultDevShells (system:
      let
        ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
          inherit system;
          file = ./.ruby-version;
        };
      in
      {
        name = "rubocop-notarize";
        modules = import ./devenv.nix { inherit ruby; };
        inherit self;
        pkgs = import nixpkgs {
          inherit system;
        };
      });
  };
}
