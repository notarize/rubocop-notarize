# lists available recipes
help:
    @just --list

# runs the specs
spec:
    bundle exec rspec spec

alias test := spec

# installs gem dependencies
install:
    bundle check || bundle install

alias i := install
