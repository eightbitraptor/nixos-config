{
  description = "NixOS configuration for fern - Thinkpad X1 Carbon Gen 6";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    swayfx = {
      url = "github:WillPower3309/swayfx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, swayfx, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (import ./overlays/swayfx.nix { inherit swayfx; })
        ];
      };
    in
    {
      nixosConfigurations = {
        fern = nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          modules = [
            ./hosts/fern/hardware.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
            ./modules/nixos/common.nix
            ./hosts/fern/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mattvh = import ./users/mattvh/home.nix;
            }
          ];

          specialArgs = { inherit inputs; };
        };
        
        # Container configuration for testing
        container = nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          modules = [
            ./hosts/container/hardware.nix
            ./hosts/container/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mattvh = {
                home.username = "mattvh";
                home.homeDirectory = "/home/mattvh";
                home.stateVersion = "24.05";

                # Basic container packages
                home.packages = with pkgs; [
                  vim
                  git
                  tmux
                  ranger
                ];

                home.sessionVariables = {
                  EDITOR = "vim";
                  TERMINAL = "bash";
                };

                programs.home-manager.enable = true;
              };
            }
          ];

          specialArgs = { inherit inputs; };
        };
      };

      defaultPackage.${system} = self.nixosConfigurations.fern.config.system.build.toplevel;
    };
}
