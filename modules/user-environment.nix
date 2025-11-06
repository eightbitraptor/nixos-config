{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userEnvironment;
  
  # Helper function to create a wrapped package
  mkWrappedPackage = { package, name ? package.pname or package.name, configDir ? null, configFile ? null, envVars ? {}, wrapperFlags ? [] }:
    let
      envVarsStr = concatStringsSep " " (mapAttrsToList (name: value: ''--set ${name} "${value}"'') envVars);
      wrapperFlagsStr = concatStringsSep " " wrapperFlags;
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ package ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        ${optionalString (configDir != null) ''
          wrapProgram $out/bin/* \
            --set XDG_CONFIG_HOME "${configDir}" \
            ${envVarsStr} \
            ${wrapperFlagsStr}
        ''}
        ${optionalString (configFile != null && configDir == null) ''
          wrapProgram $out/bin/* \
            ${envVarsStr} \
            ${wrapperFlagsStr}
        ''}
        ${optionalString (configDir == null && configFile == null && envVars != {}) ''
          wrapProgram $out/bin/* \
            ${envVarsStr} \
            ${wrapperFlagsStr}
        ''}
      '';
    };

  # User configuration type
  userConfigType = types.submodule {
    options = {
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "List of packages to install for this user";
      };
      
      wrappedPackages = mkOption {
        type = types.listOf (types.submodule {
          options = {
            package = mkOption {
              type = types.package;
              description = "The package to wrap";
            };
            name = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Optional custom name for the wrapped package";
            };
            configDir = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Configuration directory to set as XDG_CONFIG_HOME";
            };
            configFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Single configuration file (if applicable)";
            };
            envVars = mkOption {
              type = types.attrsOf types.str;
              default = {};
              description = "Environment variables to set";
            };
            wrapperFlags = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Additional flags to pass to makeWrapper";
            };
          };
        });
        default = [];
        description = "List of packages to wrap with configurations";
      };
      
      sessionVariables = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables to set for the user session";
      };
      
      activationScripts = mkOption {
        type = types.attrsOf types.lines;
        default = {};
        description = "Activation scripts to run for the user";
      };
      
      shell = mkOption {
        type = types.package;
        default = pkgs.bash;
        description = "User's shell";
      };
    };
  };
in
{
  options.userEnvironment = {
    users = mkOption {
      type = types.attrsOf userConfigType;
      default = {};
      description = "User-specific environment configurations";
    };
  };
  
  config = mkIf (cfg.users != {}) {
    # For each user, set up their environment
    users.users = mapAttrs (userName: userCfg: {
      packages = userCfg.packages ++ (map (wrapped:
        mkWrappedPackage {
          inherit (wrapped) package envVars wrapperFlags;
          name = if wrapped.name != null then wrapped.name else wrapped.package.pname or wrapped.package.name;
          configDir = wrapped.configDir;
          configFile = wrapped.configFile;
        }
      ) userCfg.wrappedPackages);
      
      shell = userCfg.shell;
    }) cfg.users;
    
    # Set up session variables
    environment.sessionVariables = mkMerge (mapAttrsToList (userName: userCfg:
      userCfg.sessionVariables
    ) cfg.users);
    
    # Set up activation scripts
    system.activationScripts = mkMerge (mapAttrsToList (userName: userCfg:
      mapAttrs' (scriptName: script: nameValuePair "userEnvironment-${userName}-${scriptName}" ''
        # User activation script for ${userName}: ${scriptName}
        ${script}
      '') userCfg.activationScripts
    ) cfg.users);
  };
}
