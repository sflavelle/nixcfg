{ self, inputs, ... }: {

  flake.nixosModules.snatcherHermes = { config, pkgs, ... }:

  {
    home-manager.sharedModules =
      [ 
        inputs.hermes-agent.homeManagerModules.default
      ];

      age = {
        secrets = {
          "hermes-env" = {
            file = ../../../secrets/hermes.yaml;
            owner = "lily";
            group = "users";
            mode = "770";
          };
        };
      };

    home-manager.users.lily = {
      services.hermes-agent = {
        enable = true;
        gateway.enable = true;
        backend.mode = "dashboard"; # + the browser dashboard on 127.0.0.1:9119
        backend.port = 9119;
        configFile = ./hermes.yaml;
        environmentFiles = [
          config.age.secrets."hermes-env".path
        ];
      };
      programs.hermes-agent = {
        enable = true;
        desktop.enable = true;
      };
    };
  };
}
