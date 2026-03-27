git submodule update --init --recursive

git config --global --add safe.directory /workspaces/chip-invaders/librelane

nix profile add nixpkgs#verible
apt install -y universal-ctags verilator iverilog