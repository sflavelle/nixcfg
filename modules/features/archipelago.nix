{ self, inputs, ... }: {

  flake.nixosModules.archipelago = { config, pkgs, ... }: {


      ### THIS DOESN'T WORK
      ### Basically what's going on is: if you have updates for worlds that are
      ### in the base Archipelago installation, they won't load. Specifically:
      ### if they are the old world folder style (OOT for example) they won't
      ### be updated at all.
      ### I thought .apworlds would be the same, but despite *indicating* that
      ### they have the same issue, they do at least load the updated version.
      ###
      ### Either way, you can't remove anything from this install (afaik)
      ### due to permission issues.

      # nixpkgs.overlays = [
      #     (final: prev: {
      #       archipelago = prev.archipelago.overrideAttrs (oldAttrs: {
      #         preInstall = (oldAttrs.preInstall or "") + ''
      #           cd ${oldAttrs.appimageContents}/opt/Archipelago/lib/worlds/

      #           # chmod -R +w oot tunic.apworld celeste_open_world.apworld
      #           rm -rf oot
      #         '';
      #       });
      #     })
      #   ];

      environment.systemPackages = with pkgs; [
        archipelago
        poptracker
      ];

  };
}
