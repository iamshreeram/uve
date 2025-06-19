# UVE - Lightweight UV Environment Manager

[![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/iamshreeram/uve/total?color=brightgreen&style=for-the-badge)](https://github.com/iamshreeram/uve/releases)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamshreeram/uve?label=Release&style=for-the-badge)](https://github.com/iamshreeram/uve/releases/latest)
[![License: MIT](https://img.shields.io/github/license/iamshreeram/uve?style=for-the-badge)](https://github.com/iamshreeram/uve/blob/main/LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/iamshreeram/uve/ci.yml?branch=main&style=for-the-badge)](https://github.com/iamshreeram/uve/actions)

---

**UVE** is a blazing-fast, conda-like workflow manager for [UV](https://github.com/astral-sh/uv) Python virtual environments, designed for speed, efficiency, and zero bloat.

---

## 🚀 Key Features

- **Create/Delete Python Environments**  
  Easily create or remove isolated Python environments from any directory.
- **Powered by UV**  
  Utilizes [UV](https://github.com/astral-sh/uv) for lightning-fast virtual environment operations.
- **Global Activation/Deactivation**  
  Activate or deactivate environments globally across your system.
- **Zero Bloat**  
  Minimal dependencies—no Anaconda overhead.
- **Auto-installs `uv` and `pip`**  
  Both tools are available in every new environment.
- **Cross-Platform**  
  Designed to work on macOS, Linux, and Windows.
- **Centralized Environment Management**  
  Manage all your UV environments from a single location.
- **Seamless UV Integration**  
  Leverages UV's strengths and features for optimal performance.

---

## ⚡ Quick Start

```bash
# Install UVE
curl -L https://github.com/iamshreeram/uve/releases/latest/download/uve-install.sh | bash

# Usage Examples
uve create myenv 3.11           # Create a new environment with Python 3.11
uve activate myenv              # Activate the environment
uve deactivate                  # Deactivate the environment
```

---

## 💡 Why UVE?

- **No Anaconda Bloat:** Pure, lightweight, and dependency-free.
- **Works Everywhere:** macOS, Linux, and Windows support.
- **Centralized Management:** Handle all your environments in one place.
- **Immediate User Benefit:** Replaces complex conda workflows with simple, fast commands.

---

## 🏗️ How It Works

### Minimal Changes, Maximum Benefit

1. **Leverages Existing UV Features:**  
   - Uses `uv venv --python` to set up base environments.
   - Manually copies installed packages (no new dependency resolution needed).

2. **Fits the Current Architecture:**  
   - Maintains the same environment layout as UV.
   - No database or heavy dependency changes required.

3. **Instant User Value:**  
   - Solves major pain points in the conda workflow.
   - More intuitive than manual environment recreation.

---

## 🧪 Testing the Feature

```bash
# Create an environment
uve create myenv 3.11
uve activate myenv
uv pip install numpy pandas

# Verify installation
python -c "import numpy; print(numpy.__version__)"
```

---

## 🌱 Future Enhancements

- [ ] **Automated UV Installation:**  
      Auto-install and configure UV for every environment.
- [ ] **Universal Shell Support:**  
      Seamless integration across bash, sh, zsh, and fish.
- [ ] **Concurrent Environment Activation:**  
      Activate a new environment without deactivating the current one.
- [ ] **Clone/Copy Environments:**  
      Effortlessly duplicate existing environments.

---

## 📣 Links

- [Releases](https://github.com/iamshreeram/uve/releases)
- [Issues](https://github.com/iamshreeram/uve/issues)
- [Discussions](https://github.com/iamshreeram/uve/discussions)
- [UV Project](https://github.com/astral-sh/uv)

---
