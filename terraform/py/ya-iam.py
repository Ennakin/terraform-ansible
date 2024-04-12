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
            "https://iam.api.cloud.yandex.net/iam/v1/tokens",
            headers={"Content-Type": "application/json"},
            data=json.dumps({"jwt": jot})
        )

        if response.status_code != 200:
            raise Exception(f"Failed to get IAM token: {response.text}")

        return response.json()["iamToken"]


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
        raise Exception(f"{key} переменная не задана")


def main():
    """Точка входа
    """

    yc = YandexConf(
        get_env("YC_SERVICE_ACCOUNT_ID"),
        get_env("YC_KEY_ID"),
        get_env("YC_KEY_SECRET_FILE_PATH")
    )

    iam_token = yc.get_iam_token()

    current_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(current_dir, 'iam-token.env')

    with open(file=file_path, mode='w') as f:
        f.write(f'export TF_VAR_token={iam_token}')


if __name__ == "__main__":
    main()
