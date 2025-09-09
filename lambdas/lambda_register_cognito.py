import boto3
import os
import sys

# Setea el ClientId del App Client de Cognito como variable de entorno
USER_POOL_APP_CLIENT_ID = os.environ['USER_POOL_APP_CLIENT_ID']

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    if 'username' not in event or 'password' not in event:
        return {
            'status': 'fail',
            'msg': 'Username, password y email son requeridos'
        }
    resp, msg = register_user(event['username'], event['password'], event['email'])
    if msg is not None:
        return {
            'status': 'fail',
            'msg': msg
        }
    return {
        'status': 'success',
        'msg': 'Usuario registrado correctamente',
        'response': resp
    }

def register_user(username, password, email):
    try:
        resp = client.sign_up(
            ClientId=USER_POOL_APP_CLIENT_ID,
            Username=username,
            Password=password,
            UserAttributes=[
                {'Name': 'email', 'Value': email}
            ]
        )
    except client.exceptions.UsernameExistsException:
        return None, "El usuario ya existe"
    except client.exceptions.InvalidPasswordException:
        return None, "La contraseña no cumple los requisitos"
    except client.exceptions.InvalidParameterException as e:
        return None, "Parámetros inválidos"
    except Exception as e:
        print("Uncaught exception:", e, file=sys.stderr)
        return None, "Error desconocido"
    return resp, None
