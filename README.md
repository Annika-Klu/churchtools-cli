# PowerShell Project Template

A simple template for structuring PowerShell projects.

## 📁 Contents

- **`requirements.psd1`** — Defines required external modules (e.g. from the [PowerShell Gallery](https://www.powershellgallery.com/)).
- **`install-requirements.ps1`** — Installs any modules listed in `requirements.psd1` if they are not already installed.
- **`run.ps1`** — The main entry point for your script. Loads all classes and modules, reads your `.env` file, and starts your logic.
- **`Modules/`** — Contains your custom `.psm1` module files, which are imported automatically by `run.ps1`.
- **`Classes/`** — Contains `.ps1` files with your custom classes, which are dot-sourced in `run.ps1` (since PowerShell doesn’t export classes from modules in every version).
- **`.env.example`** — Example file showing how to define environment variables (e.g. secrets, API keys).
- **`.gitignore`** — Make sure to add `.env` and any log or secrets folders here to keep sensitive data out of version control.

---

## 🚀 Usage

1. **Clone this repository**  

    ```bash
    git clone https://github.com/Annika-Klu/powershell-template
    cd powershell-template
    ```

2. **Install required modules**

    If you need any modules, add them to `requirements.psd1` and run

    ```powershell
    .\install-requirements.ps1
    ```

    Alternatively, you may add this line to `run.ps1` to check for new modules to install every time the script runs:

    ```powershell
    . "$PSScriptRoot/install-requirements.ps1"
    ```

3. **Create your `.env`**

    ```bash
    cp .env.example .env
    ```

4. **Code your project**

    Add logic according to your project's needs.

    ⚠️ For PowerShell 5.x and 7.x, be mindful of differences in module and class handling.

5. **Run your script**

    ```powershell
    .\run.ps1
    ```