import boto3
import os
import sys

USER_POOL_APP_CLIENT_ID = os.environ['USER_POOL_APP_CLIENT_ID']
client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    if 'username' not in event or 'confirmation_code' not in event:
        return {
            'status': 'fail',
            'msg': 'Username y confirmation_code son requeridos'
        }
    resp, msg = confirm_user(event['username'], event['confirmation_code'])
    if msg is not None:
        return {
            'status': 'fail',
            'msg': msg
        }
    return {
        'status': 'success',
        'msg': 'Usuario confirmado correctamente',
        'response': resp
    }

def confirm_user(username, confirmation_code):
    try:
        resp = client.confirm_sign_up(
            ClientId=USER_POOL_APP_CLIENT_ID,
            Username=username,
            ConfirmationCode=confirmation_code
        )
    except client.exceptions.CodeMismatchException:
        return None, "El código de confirmación es incorrecto"
    except client.exceptions.ExpiredCodeException:
        return None, "El código de confirmación ha expirado"
    except client.exceptions.UserNotFoundException:
        return None, "Usuario no encontrado"
    except Exception as e:
        print("Uncaught exception:", e, file=sys.stderr)
        return None, "Error desconocido"
    return resp, None
