import os
import shutil
import sys

# Ruta típica de SharedPreferences en Android emulador/dispositivo
# Modifica esto según tu paquete/app
PACKAGE_NAME = "tu.paquete.app"  # Cambia esto por el nombre real de tu paquete

# Ejemplo de ruta en Windows para emulador Android
# Puedes ajustar la ruta si usas un dispositivo físico o diferente emulador
SHAREDPREFS_PATH = os.path.expanduser(r"~/.android/avd")  # Emulador: busca el AVD

# Ruta en Android real: /data/data/<PACKAGE_NAME>/shared_prefs/
# Si tienes acceso root, puedes copiar desde ahí

# Nombre del archivo de SharedPreferences (puede variar)
PREFS_FILENAME = "user_statistics.xml"  # Cambia esto por el nombre real si es diferente

# Destino para guardar el backup
DEST_PATH = os.path.join(os.getcwd(), "sharedprefs_backup.xml")


def find_sharedprefs_file():
    # Busca el archivo en posibles ubicaciones
    for root, dirs, files in os.walk(SHAREDPREFS_PATH):
        for file in files:
            if file == PREFS_FILENAME:
                return os.path.join(root, file)
    return None


def backup_sharedprefs():
    src = find_sharedprefs_file()
    if not src:
        print(f"No se encontró el archivo {PREFS_FILENAME} en {SHAREDPREFS_PATH}")
        sys.exit(1)
    shutil.copy2(src, DEST_PATH)
    print(f"Backup realizado: {DEST_PATH}")


if __name__ == "__main__":
    backup_sharedprefs()
