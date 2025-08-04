## Lab1 TODO: create Makefile for functest here

## Lab1 functest Makefile - 支持编译单个或所有测试

# 配置变量
BASE_PORT = $(abspath ../../software/base-port)

# 获取所有测试文件名（去掉.c扩展名）
ALL_TESTS = $(basename $(notdir $(wildcard src/*.c)))
TRAP_INC = -I$(abspath ./include)

# 默认目标和命令行参数处理
ifeq ($(MAKECMDGOALS),)
  MAKECMDGOALS = all
  .DEFAULT_GOAL = all
endif

# 支持的目标
.PHONY: all clean list help $(ALL_TESTS)

# 帮助信息
help:
	@echo "Available targets:"
	@echo "  all          - 编译所有测试"
	@echo "  clean        - 清理所有构建文件"
	@echo "  list         - 列出所有可用的测试"
	@echo "  <test_name>  - 编译指定的测试"
	@echo ""
	@echo "Available tests:"
	@$(foreach test,$(ALL_TESTS),echo "  $(test)";)
	@echo ""
	@echo "Usage examples:"
	@echo "  make all                # 编译所有测试"
	@echo "  make add                # 编译add测试"
	@echo "  make NAMES='add sub'    # 编译指定的多个测试"

# 列出所有测试
list:
	@echo "Available tests: $(ALL_TESTS)"

# 编译所有测试
all:
	@$(MAKE) NAMES="$(ALL_TESTS)" build-tests

# 编译指定的测试（单个目标）
$(ALL_TESTS):
	@$(MAKE) NAMES="$@" build-tests

# 实际的构建过程
build-tests:
	@if [ -z "$(NAMES)" ]; then \
		echo "Error: No test names specified"; \
		exit 1; \
	fi; \
	for test in $(NAMES); do \
		echo "Building test: $$test"; \
		if [ ! -f "src/$$test.c" ]; then \
			echo "Error: src/$$test.c not found"; \
			continue; \
		fi; \
		mkdir -p build/$$test; \
		echo "# Generated Makefile for $$test" > build/$$test/Makefile; \
		echo "# Base configuration" >> build/$$test/Makefile; \
		echo "BASE_PORT = $(BASE_PORT)" >> build/$$test/Makefile; \
		echo "SIM_PATH = $(SIM_PATH)" >> build/$$test/Makefile; \
		echo "# Include base Makefile" >> build/$$test/Makefile; \
		echo "-include \$$(BASE_PORT)/Makefile" >> build/$$test/Makefile; \
		echo "" >> build/$$test/Makefile; \
		echo "# Include path for trap.h (must be before base Makefile)" >> build/$$test/Makefile; \
		echo "INC_PATH += -I$(BASE_PORT)/../functest/include" >> build/$$test/Makefile; \
		echo "INC_PATH += -I$(BASE_PORT)/../functest/include"; \
		echo "" >> build/$$test/Makefile; \
		echo "# Test-specific variables" >> build/$$test/Makefile; \
		echo "NAMES = $$test" >> build/$$test/Makefile; \
		echo "SRCS = ../../src/$$test.c" >> build/$$test/Makefile; \
		echo "" >> build/$$test/Makefile; \
		echo "# Override build directories to avoid conflicts" >> build/$$test/Makefile; \
		echo "BUILD_DIR = \$$(abspath ./build)" >> build/$$test/Makefile; \
		echo "IMAGE = \$$(BUILD_DIR)/$$test-riscv32" >> build/$$test/Makefile; \
		echo "TAR_DIR = \$$(BUILD_DIR)/riscv32" >> build/$$test/Makefile; \
		echo "OBJS = \$$(addprefix \$$(TAR_DIR)/, \$$(addsuffix .o, \$$(basename \$$(SRCS))))" >> build/$$test/Makefile; \
		echo "" >> build/$$test/Makefile; \
		$(MAKE) -C build/$$test image || echo "Failed to build $$test"; \
	done

# 清理所有构建文件
clean:
	rm -rf build

# 运行指定测试（需要先构建）
run-%:
	@test_name=$(patsubst run-%,%,$@); \
	if [ ! -f "build/$$test_name/build/$$test_name-riscv32.bin" ]; then \
		echo "Test $$test_name not built, building now..."; \
		$(MAKE) $$test_name; \
	fi; \
	$(MAKE) -C build/$$test_name run

# 调试指定测试
gdb-%:
	@test_name=$(patsubst gdb-%,%,$@); \
	if [ ! -f "build/$$test_name/build/$$test_name-riscv32.bin" ]; then \
		echo "Test $$test_name not built, building now..."; \
		$(MAKE) $$test_name; \
	fi; \
	$(MAKE) -C build/$$test_name gdb