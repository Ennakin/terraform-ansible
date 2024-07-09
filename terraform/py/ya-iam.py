import os
import jwt
import requests
import json
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from datetime import datetime, timedelta


class YandexConf:
    """Класс для создания IAM токена для сервисного аккаунта
    """

    def __init__(self, service_account_id: str, key_id: str, key_secret_file_path: str) -> None:
        """Конструктор

        Args:
            service_account_id (_type_): id сервисного аккаунта
            key_id (_type_): id ключа
            key_secret_file_path (_type_): путь до файла с приватной частью ключа
        """

        self.service_account_id = service_account_id
        self.key_id = key_id
        self.key_secret_file_path = key_secret_file_path

    def signed_token(self) -> str:
        """Создание JWT токена

        Returns:
            str: JWT токен
        """

        now = datetime.utcnow()

        claims = {
            'iss': self.service_account_id,
            'exp': now + timedelta(hours=1),
            'iat': now,
            'aud': ['https://iam.api.cloud.yandex.net/iam/v1/tokens']
        }

        with open(self.key_secret_file_path, 'rb') as f:
            private_key = serialization.load_pem_private_key(
                f.read(),
                password=None,
                backend=default_backend()
            )

        return jwt.encode(claims, private_key, algorithm='PS256', headers={'kid': self.key_id})

    def get_iam_token(self) -> str:
        """Получение IAM токена

        Raises:
            Exception: _description_

        Returns:
            str: IAM токен
        """

        jot = self.signed_token()

        response = requests.post(
            'https://iam.api.cloud.yandex.net/iam/v1/tokens',
            headers={'Content-Type': 'application/json'},
            data=json.dumps({'jwt': jot})
        )

        if response.status_code != 200:
            raise Exception(f'Failed to get IAM token: {response.text}')

        return response.json()['iamToken']


def get_env(key: str) -> str:
    """Получение значения переменной окружения

    Args:
        key (str): название переменной окружения

    Raises:
        Exception: _description_

    Returns:
        str: значение переменной окружения
    """

    value = os.getenv(key)

    if value is not None:
        return value
    else:
        raise Exception(f'{key} переменная не задана')


def main():
    """Точка входа
    """

    conf_path = os.path.dirname(os.path.dirname(__file__))
    conf_path = os.path.join(conf_path, 'conf', 'main_conf.json')

    with open(file=conf_path, mode='r') as file:
        conf = json.load(fp=file)

        service_account_id = conf.get('service-account', {}).get('id',
                                                                 None) if isinstance(conf, dict) else None
        key_id = conf.get('service-account', {}).get('key-id',
                                                     None) if isinstance(conf, dict) else None

    if service_account_id and key_id:
        yc = YandexConf(
            # # если переменные в .env, а не в .json
            # service_account_id=get_env('YC_SERVICE_ACCOUNT_ID'),
            # key_id=get_env('YC_KEY_ID'),
            service_account_id=service_account_id,
            key_id=key_id,
            key_secret_file_path=get_env('YC_KEY_SECRET')
        )

        iam_token = yc.get_iam_token()

        current_dir = os.path.dirname(os.path.abspath(__file__))
        envs_dir = os.path.dirname(current_dir)
        file_path = os.path.join(envs_dir, 'envs', 'prod', 'iam-token.env')

        with open(file=file_path, mode='w') as f:
            f.write(f'export TF_VAR_YC_IAM_TOKEN={iam_token}')

    else:
        print(
            f'conf_path is: ${conf_path} && service_account_id is: ${service_account_id} && key_id is: ${key_id}')


if __name__ == '__main__':
    main()
