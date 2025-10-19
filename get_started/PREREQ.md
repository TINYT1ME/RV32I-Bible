# 📋 Prerequisites

This project uses [Apio](https://github.com/FPGAwars/apio), [Verilator](https://verilator.org/guide/latest/install.html), and [cocotb](https://github.com/cocotb/cocotb) for FPGA development and testing.


### Git & Python
Make sure you have Git and Python installed on your system:

```bash
python3 --version  # Tested with Python 3.13
git --version
```

## Quick Setup

### 1. Clone & Setup Environment

```bash
# Clone the repository
git clone https://github.com/TINYT1ME/RV32I-Bible

# Navigate to project directory
cd RV32I-Bible

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate     # Windows
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

## Verilator Installation

### macOS (using Homebrew)
```bash
brew install verilator
```

### Ubuntu/Debian
```bash
sudo apt-get install verilator
```

### Windows
As Verilator isn't natively built for Windows, you must use [MSYS2](https://sourceforge.net/projects/msys2/). Instructions can be found [here](https://gist.github.com/sgherbst/036456f807dc8aa84ffb2493d1536afd).


---
### [Back to Get Started](README.md)