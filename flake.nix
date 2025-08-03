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
        
        # 使用 riscv32-embedded 工具链，它默认支持 multilib
        riscv32-gcc-multilib = pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc;
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core development tools
            gcc
            glibc
            gdb
            gnumake
            git
            # LLVM 按照要求是11，看最新也可以
            llvm
            
            # Shell
            zsh
            
            # Libraries
            SDL2
            readline
            
            # Verilog/SystemVerilog tools
            verilator
            
            # RISC-V toolchain with multilib support
            riscv32-gcc-multilib
            pkgs.pkgsCross.riscv32-embedded.buildPackages.binutils
          ];
          shellHook = ''
            # Set up RISC-V toolchain environment
            export RISCV=${riscv32-gcc-multilib}
            export PATH=${riscv32-gcc-multilib}/bin:$PATH
            export PATH=${pkgs.pkgsCross.riscv32-embedded.buildPackages.binutils}/bin:$PATH
            
            # Set up cross-compilation environment
            export CROSS_COMPILE=riscv32-unknown-elf-
            export CC=riscv32-unknown-elf-gcc
            export CXX=riscv32-unknown-elf-g++
            export AR=riscv32-unknown-elf-ar
            export STRIP=riscv32-unknown-elf-strip
            
            echo "USTC CECS Lab Development Environment"
            echo "======================================"
            echo "Available tools:"
            echo "- Verilator: $(verilator --version 2>/dev/null | head -n1 || echo 'installed')"
            echo "- RISC-V GCC: $(riscv32-unknown-elf-gcc --version 2>/dev/null | head -n1 || echo 'Cross-compiler ready')"
            echo "- LLVM: $(llvm-config --version 2>/dev/null || echo '11.x')"
            echo "- Make: $(make --version | head -n1)"
            echo "- GDB: $(gdb --version | head -n1)"
            echo ""
            echo "Environment variables set:"
            echo "- RISCV=$RISCV"
            echo "- CROSS_COMPILE=$CROSS_COMPILE"
            echo ""
            
            # Check multilib support
            echo "Checking multilib support:"
            riscv32-unknown-elf-gcc -print-multi-lib 2>/dev/null || echo "Multilib not properly configured"
            echo ""
            
            # Switch to zsh if not already using it
            if [ "$SHELL" != "${pkgs.zsh}/bin/zsh" ]; then
              echo "Switching to zsh..."
              export SHELL=${pkgs.zsh}/bin/zsh
              exec $SHELL
            fi
          '';
          # Additional environment setup
          NIX_ENFORCE_PURITY = 0;
        };
      });
}