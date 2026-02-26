{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-ruby }: let
    systems = [ "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems f;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
      ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
        inherit system;
        file = ./.ruby-version;
      };
    in {
      default = pkgs.mkShell {
        buildInputs = [ ruby pkgs.just ];
      };
    });
  };
}
