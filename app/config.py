from dotenv import load_dotenv
import os

load_dotenv()  # Carga variables desde .env si existe

class Config:
    MENSAJE = "¡Hola desde Config base!"

class LocalConfig(Config):
    MENSAJE = "¡Hola desde LOCAL!"

class DevConfig(Config):
    MENSAJE = "¡Hola desde DEV!"

class QAConfig(Config):
    MENSAJE = "¡Hola desde QA!"

class ProdConfig(Config):
    MENSAJE = "¡Hola desde PROD!"

def get_config(env_name):
    envs = {
        "local": LocalConfig,
        "dev": DevConfig,
        "qa": QAConfig,
        "prod": ProdConfig,
    }
    return envs.get(env_name.lower(), Config)