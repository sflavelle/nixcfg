{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # ARM projects
#     mobile-nixos.url = "github:mobile-nixos/mobile-nixos";
#     mobile-nixos.flake = false;

    # Helpers
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Program Wrappers
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # Other programs
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.url = "github:4evy/nixcord";
    demucs.url = "github:mukize/demucs.nix";

    comfyui-nix = {
      url = "github:utensils/comfyui-nix";
      inputs.flake-parts.follows = "flake-parts";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.systems.follows = "systems";
      # inputs.treefmt-nix.follows = "nur-xddxdd/treefmt-nix";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    (inputs.import-tree ./modules);
}
