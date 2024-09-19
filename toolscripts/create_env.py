import secrets
import os

def create_env():
    env_content = f'SECRET_KEY="django-insecure-{secrets.token_urlsafe(50)}"\nDEBUG=True\nALLOWED_HOSTS=*'
    try:
        with open('.env', 'w') as f:
            f.write(env_content)
        print("Archivo .env creado con SECRET_KEY generada aleatoriamente.")
    except Exception as e:
        print(f"No se pudo crear .env: {e}")

if __name__ == "__main__":
    create_env()