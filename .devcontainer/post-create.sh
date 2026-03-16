git submodule update --init --recursive

if [ ! -d /workspaces/chip-invaders/chipinvaders/pdk/ihp-sg13cmos5l/.git ]; then
  git clone https://github.com/IHP-GmbH/ihp-sg13cmos5l.git /workspaces/chip-invaders/chipinvaders/pdk/ihp-sg13cmos5l
fi

git config --global --add safe.directory /workspaces/chip-invaders/chipinvaders/librelane

nix profile add nixpkgs#verible
apt install -y universal-ctags verilator iverilog