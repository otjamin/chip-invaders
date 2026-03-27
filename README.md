# chip-invaders
DYC26

## Getting started
Open the repo in the Devcontainer.

### Running the librelane flow
1. Open a librelane nix-shell.
```sh
nix-shell librelane/
```

2. To run the flow:
```sh
make librelane
```

3. To view the results:
```sh
make view-results
```

### Building and loading onto an FPGA
1. Start the xc7 dev env.
```sh
nix develop github:openxc7/toolchain-nix
```

2. To build the bitstream:
```sh
make bits # For Nexys A7
make TARGET=basys bits # For Basys 3
```

3. To load onto the FPGA:
```sh
make program # For Nexys A7
make TARGET=basys program # For Basys 3
```

### Loading without devcontainer
If you encounter issues loading with the Devcontainer, you can use the openFPGALoader without it. Please refer to the [documentation](https://trabucayre.github.io/openFPGALoader/guide/install.html) for information on installing it on your device.

To run openFPGALoader:
```sh
openFPGALoader --board nexys_a7_100 --bitstream chipinvaders.bit # For Nexys A7
openFPGALoader --board basys3 --bitstream chipinvaders.bit # For Basys 3
```
