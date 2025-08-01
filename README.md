# xmake C++ Library Template [![C++ CI with xmake](https://github.com/zenshosan/xmake-template/actions/workflows/ci.yml/badge.svg)](https://github.com/zenshosan/xmake-template/actions/workflows/ci.yml)

A comprehensive template project for C++ library development using xmake.

## Features

- Windows (x64) and Linux (x86_64) support
- debug, release, coverage, sanitizers (asan, msan, lsan, ubsan, tsan) build modes
- Google Test integration, coverage measurement, Valgrind support
- Automatic Git information and version generation
- Sample code for various sanitizer demonstrations
- GitHub Actions CI/CD pipeline

## Requirements

- xmake 3.0.1 or higher
- C++ compiler (MSVC, GCC, Clang)
- gcovr and valgrind required on Linux

## Usage

```bash
# Build the project
xmake

# Run tests
xmake run unit_test

# Coverage measurement (Linux)
xmake -m coverage
xmake run cov

# Sanitizer examples (Linux)
xmake -m asan
xmake run ovr_stack  # Stack buffer overflow detection example
```

## Project Structure

```
├── include/          # Header files
├── src/             # Source files
├── tests/           # Test code
├── examples/        # Sanitizer demonstration samples
└── xmake.lua        # Build configuration
```

## License

MIT License

## Coverage Report

Code coverage report is available at: [Coverage Report](https://zenshosan.github.io/xmake-template/) 