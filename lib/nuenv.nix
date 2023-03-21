nushell:

# nixpkgs.system (from overlay)
sys:

{ name                # The name of the derivation
, src                 # The derivation's sources
, packages ? [ ]      # Packages provided to the realisation process
, system ? sys        # The build system
, build ? ""          # The build phase
, debug ? true        # Run in debug mode
, outputs ? [ "out" ] # Outputs to provide
, ...                 # Catch user-supplied env vars
}@attrs:

let
  # Gather arbitrary user-supplied env vars
  reservedAttrs = [
    "build"
    "debug"
    "name"
    "outputs"
    "packages"
    "src"
    "system"
    "__nu_debug"
    "__nu_extra_attrs"
    "__nu_packages"
    "__nu_user_env_file"
  ];

  extraAttrs = removeAttrs attrs reservedAttrs;
in
derivation {
  # Derivation
  inherit name outputs src system;

  # Phases
  inherit build;

  # Build logic
  builder = "${nushell}/bin/nu";
  args = [ ./nushell/builder.nu ];

  # When this is set, Nix writes the environment to a JSON file at
  # $NIX_BUILD_TOP/.attrs.json. Because Nushell can handle JSON natively, this approach
  # is generally cleaner than parsing environment variables as strings.
  __structuredAttrs = true;

  # Attributes passed to the environment (prefaced with __nu_ to avoid naming collisions)
  __nu_debug = debug;
  __nu_extra_attrs = extraAttrs;
  __nu_packages = packages;
  __nu_user_env_file = ./nushell/user-env.nu;
}