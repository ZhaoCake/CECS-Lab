{
  description = "USTC CECS Lab Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # RISC-V GCC multilib toolchain
        riscv-gcc = pkgs.pkgsCross.riscv64.buildPackages.gcc.override {
          enableMultilib = true;
        };
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core development tools
            gcc
            glibc
            gdb
            make
            git
            
            # LLVM 11 (using closest available version)
            llvm_11
            
            # System tools
            man
            zsh
            
            # Libraries
            SDL2
            readline
            
            # Verilog/SystemVerilog tools
            verilator
            
            # RISC-V toolchain
            pkgsCross.riscv64.buildPackages.gcc
            pkgsCross.riscv64.buildPackages.binutils
            pkgsCross.riscv64.buildPackages.glibc
          ];

          shellHook = ''
            # Switch to zsh if not already using it
            if [ "$SHELL" != "${pkgs.zsh}/bin/zsh" ]; then
              echo "Switching to zsh..."
              export SHELL=${pkgs.zsh}/bin/zsh
              exec $SHELL
            fi
            
            # Set up RISC-V toolchain environment
            export RISCV=/opt/riscv64
            export PATH=${pkgs.pkgsCross.riscv64.buildPackages.gcc}/bin:$PATH
            export PATH=${pkgs.pkgsCross.riscv64.buildPackages.binutils}/bin:$PATH
            
            # Set up cross-compilation environment
            export CROSS_COMPILE=riscv64-unknown-linux-gnu-
            export CC=riscv64-unknown-linux-gnu-gcc
            export CXX=riscv64-unknown-linux-gnu-g++
            export AR=riscv64-unknown-linux-gnu-ar
            export STRIP=riscv64-unknown-linux-gnu-strip
            
            echo "USTC CECS Lab Development Environment"
            echo "======================================"
            echo "Available tools:"
            echo "- Verilator: $(verilator --version 2>/dev/null | head -n1 || echo 'installed')"
            echo "- RISC-V GCC: $(riscv64-unknown-linux-gnu-gcc --version 2>/dev/null | head -n1 || echo 'Cross-compiler ready')"
            echo "- LLVM: $(llvm-config --version 2>/dev/null || echo '11.x')"
            echo "- Make: $(make --version | head -n1)"
            echo "- GDB: $(gdb --version | head -n1)"
            echo ""
            echo "Environment variables set:"
            echo "- RISCV=$RISCV"
            echo "- CROSS_COMPILE=$CROSS_COMPILE"
            echo ""
          '';

          # Additional environment setup
          NIX_ENFORCE_PURITY = 0;
        };
      });
}