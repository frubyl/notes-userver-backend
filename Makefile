CMAKE_COMMON_FLAGS ?= -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
CMAKE_DEBUG_FLAGS ?= -DUSERVER_SANITIZE='addr ub'
CMAKE_RELEASE_FLAGS ?=
NPROCS ?= $(shell nproc)
CLANG_FORMAT ?= clang-format
DOCKER_COMPOSE ?= docker-compose 

# NOTE: use Makefile.local to override the options defined above.
-include Makefile.local

CMAKE_DEBUG_FLAGS += -DCMAKE_BUILD_TYPE=Debug $(CMAKE_COMMON_FLAGS)
CMAKE_RELEASE_FLAGS += -DCMAKE_BUILD_TYPE=Release $(CMAKE_COMMON_FLAGS)

.PHONY: all
all: test-debug test-release

# Run cmake
.PHONY: cmake-debug
cmake-debug:
	cmake -B build_debug $(CMAKE_DEBUG_FLAGS)

.PHONY: cmake-release
cmake-release:
	cmake -B build_release $(CMAKE_RELEASE_FLAGS)

build_debug/CMakeCache.txt: cmake-debug
build_release/CMakeCache.txt: cmake-release

# Build using cmake
.PHONY: build-debug build-release
build-debug build-release: build-%: build_%/CMakeCache.txt
	mkdir -p build_$*/attachments
	cmake --build build_$* -j $(NPROCS) --target noteluoto

# Test
.PHONY: test-debug test-release
test-debug test-release: test-%: build-%
	cmake --build build_$* -j $(NPROCS) --target noteluoto_unittest
	cd build_$* && ((test -t 1 && GTEST_COLOR=1 PYTEST_ADDOPTS="--color=yes" ctest -V) || ctest -V)
	pycodestyle tests

# Start the service (via testsuite service runner)
.PHONY: start-debug start-release
start-debug start-release: start-%: build-%
	cmake --build build_$* -v --target start-noteluoto

.PHONY: service-start-debug service-start-release
service-start-debug service-start-release: service-start-%: start-%

# Cleanup data
.PHONY: clean-debug clean-release
clean-debug clean-release: clean-%:
	cmake --build build_$* --target clean

.PHONY: dist-clean
dist-clean:
	rm -rf build_*
	rm -rf tests/__pycache__/
	rm -rf tests/.pytest_cache/

# Install
.PHONY: install-debug install-release
install-debug install-release: install-%: build-%
	cmake --install build_$* -v --component noteluoto

.PHONY: install
install: install-release

# Format the sources
.PHONY: format
format:
	find src -name '*pp' -type f | xargs $(CLANG_FORMAT) -i
	find tests -name '*.py' -type f | xargs autopep8 -i

# Set environment for --in-docker-start
export DB_CONNECTION := postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@service-postgres:5432/${POSTGRES_DB}

# Internal hidden targets that are used only in docker environment
--in-docker-start-debug --in-docker-start-release: --in-docker-start-%: install-%
	psql ${DB_CONNECTION} -f ./postgresql/data/initial_data.sql
	/home/user/.local/bin/noteluoto \
		--config /home/user/.local/etc/noteluoto/static_config.yaml \
		--config_vars /home/user/.local/etc/noteluoto/config_vars.docker.yaml

# Build and run service in docker environment
.PHONY: docker-start-debug docker-start-release
docker-start-debug docker-start-release: docker-start-%:
	$(DOCKER_COMPOSE) run -p 8080:8080 -p 8090:8090 --rm noteluoto-container make -- --in-docker-start-$*

.PHONY: docker-start-service-debug docker-start-service-release
docker-start-service-debug docker-start-service-release: docker-start-service-%: docker-start-%

# Start targets makefile in docker environment
.PHONY: docker-cmake-debug docker-build-debug docker-test-debug docker-clean-debug docker-install-debug docker-cmake-release docker-build-release docker-test-release docker-clean-release docker-install-release
docker-cmake-debug docker-build-debug docker-test-debug docker-clean-debug docker-install-debug docker-cmake-release docker-build-release docker-test-release docker-clean-release docker-install-release: docker-%:
	$(DOCKER_COMPOSE) run --rm noteluoto-container make $*

# Stop docker container and remove PG data
.PHONY: docker-clean-data
docker-clean-data:
	$(DOCKER_COMPOSE) down -v
	rm -rf ./.pgdata
