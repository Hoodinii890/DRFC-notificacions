import subprocess
import os
import sys

def log_message(message):
    print(message, file=sys.stderr, flush=True)

def get_installed_packages():
    result = subprocess.run([sys.executable, "-m", "pip", "freeze"], capture_output=True, text=True)
    return set(result.stdout.splitlines())

def update_requirements():
    log_message("Ejecutando actualización de requirements...")
    current_packages = get_installed_packages()
    log_message(f"Paquetes actuales: {len(current_packages)}")
    
    if os.path.exists("requirements.txt"):
        with open("requirements.txt", "r") as f:
            old_packages = set(f.read().splitlines())
        log_message(f"Paquetes antiguos: {len(old_packages)}")
    else:
        log_message("Creando nuevo archivo requirements.txt")
        old_packages = set()
    
    if current_packages != old_packages:
        with open("requirements.txt", "w") as f:
            f.write("\n".join(sorted(current_packages)))
        log_message("Requirements actualizados debido a cambios en paquetes.")
        log_message(f"Añadidos: {current_packages - old_packages}")
        log_message(f"Eliminados: {old_packages - current_packages}")
    else:
        log_message("No se detectaron cambios en los paquetes.")
    
    result = subprocess.run(["git", "diff", "--exit-code", "requirements.txt"], capture_output=True, text=True)
    if result.returncode != 0:
        log_message("Se han detectado cambios en requirements.txt")
        log_message("Por favor, revisa los cambios, añádelos con 'git add requirements.txt' y vuelve a intentar el commit.")
        sys.exit(1)
    else:
        log_message("No se requieren cambios en requirements.txt")

if __name__ == "__main__":
    update_requirements()