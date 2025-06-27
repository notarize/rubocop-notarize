{ pkgs, lib, config, proof, nixpkgs-ruby, ... }:
{
  warnings =
    let
      nixWorldVersion = config.languages.ruby.package.version.version;
      outerWorldVersion = (nixpkgs-ruby.lib.readRubyVersionFile ./.ruby-version).version;
    in
    lib.optional (nixWorldVersion != outerWorldVersion) ''
      Nix devenv is using a different version of Ruby than the repo specifies in the .ruby-version file.
        - Nix devenv version: ${nixWorldVersion}
        - .ruby-version: ${outerWorldVersion}
    '';

  dotenv.disableHint = true;

  proof.just = {
    enable = true;
    recipes = {
      install = {
        aliases = [ "i" ];
        documentation = "Install bundle dependencies";
        commands = "bundle check || bundle install";
      };
      "test +globs" = {
        documentation = "Run rspec on the given spec files";
        commands = "bundle exec rspec {{globs}}";
      };
      "lint *globs" = {
        documentation = "Run rubocop on whole repo or given file globs";
        commands = "bundle exec rubocop -a {{globs}}";
      };
    };
  };

  languages.ruby = {
    enable = true;
    package = pkgs."ruby-3.4.3";
  };

}
