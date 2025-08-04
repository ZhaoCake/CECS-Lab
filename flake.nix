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
        
        # 注意：这里使用自己编译的支持multilib的RISC-V工具链
        # 需要先编译工具链：
        # $ ../configure --prefix=/opt/riscv64 --enable-multilib --target=riscv64-linux-multilib
        # 工具链路径假设在项目上级目录的 riscv64-multilib 文件夹中
        riscv-toolchain-path = ../riscv64-multilib/bin;
        
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
            
            # 注意：RISC-V工具链使用自编译版本，不在buildInputs中
            # 请确保 ../riscv64-multilib/bin 路径存在并包含编译好的工具链
          ];
          shellHook = ''
            # Set up RISC-V toolchain environment
            # 使用自编译的multilib工具链
            export RISCV_TOOLCHAIN_PATH=$(pwd)/../riscv64-multilib/bin
            export PATH=$RISCV_TOOLCHAIN_PATH:$PATH
            
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
            echo "- RISCV_TOOLCHAIN_PATH=$RISCV_TOOLCHAIN_PATH"
            echo "- CROSS_COMPILE=$CROSS_COMPILE"
            echo ""
            
            # Check multilib support
            echo "Checking multilib support:"
            riscv64-unknown-linux-gnu-gcc -print-multi-lib 2>/dev/null || echo "Multilib not properly configured"
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