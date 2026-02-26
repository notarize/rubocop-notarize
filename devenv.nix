{ ruby }:
{ pkgs, proof, ... }:
{
  languages.ruby = {
    enable = true;
    package = ruby;
  };

  dotenv.disableHint = true;

  proof.just = {
    enable = true;
    recipes = {
      install = {
        aliases = [ "i" ];
        documentation = "installs gem dependencies";
        commands = "bundle check || bundle install";
      };
      spec = {
        aliases = [ "test" ];
        documentation = "runs the specs";
        commands = "bundle exec rspec spec";
      };
    };
  };
}
