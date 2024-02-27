############################################################################
#
#  Nix commands related to the local machine
#  Src: https://nixos-and-flakes.thiscute.world/best-practices/simplify-nixos-related-commands
#
############################################################################
set shell := ["fish", "-c"]

machine := `cat /etc/hostname`
ip := if machine == "minion" {
	"10.0.2.2"
} else if machine == "snatcher" {
	"10.0.2.1"
} else if machine == "neurariodotcom" {
	"neurario.com"
} else if machine == "conductor" {
	"10.0.0.3"
} else { "" }

default:
	@just --list

@ deploy mode='switch':
	if test {{machine}} != (cat /etc/hostname); nixos-rebuild {{mode}} --flake git+https://git.neurario.com/splatsune/nixcfg.git#{{machine}} --target-host {{ip}} --use-remote-sudo --show-trace; end
	if test {{machine}} = (cat /etc/hostname); sudo nixos-rebuild {{mode}} --flake git+https://git.neurario.com/splatsune/nixcfg.git#{{machine}} --use-remote-sudo --show-trace; end

deploy-list +MACHINES:
	@test -n "{{MACHINES}}" || echo "Supply a list of machines to deploy."
	@for m in {{MACHINES}}; echo "Updating $m..."; just machine=$m deploy switch; end

sanitycheck:
	@for m in minion snatcher conductor neurariodotcom; echo "Dry-activating $m (no deployment)..."; nixos-rebuild dry-activate --flake git+https://git.neurario.com/splatsune/nixcfg.git#$m --show-trace; end

debug:
	nixos-rebuild switch --flake git+https://git.neurario.com/splatsune/nixcfg.git#{{machine}} --use-remote-sudo --show-trace --verbose

update:
	sudo nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

gc:
	# remove all generations older than 7 days
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

	# garbage collect all unused nix store entries
	sudo nix store gc --debug

reboot +machines:
	@for m in {{machines}}; ssh -t $m sudo systemctl reboot; end
