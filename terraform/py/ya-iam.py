import os
import jwt
import requests
import json
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from datetime import datetime, timedelta


class YandexConf:
    def __init__(self, service_account_id, key_id, key_secret_file_path):
        self.service_account_id = service_account_id
        self.key_id = key_id
        self.key_secret_file_path = key_secret_file_path

    def signed_token(self):
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

    def get_iam_token(self):
        jot = self.signed_token()
        response = requests.post(
            "https://iam.api.cloud.yandex.net/iam/v1/tokens",
            headers={"Content-Type": "application/json"},
            data=json.dumps({"jwt": jot})
        )
        if response.status_code != 200:
            raise Exception(f"Failed to get IAM token: {response.text}")
        return response.json()["iamToken"]


def get_env(key):
    value = os.getenv(key)
    if value is not None:
        return value
    else:
        raise Exception(f"{key} переменная не задана")


def main():
    print('Hello World!')
    yc = YandexConf(
        get_env("YC_SERVICE_ACCOUNT_ID"),
        get_env("YC_KEY_ID"),
        get_env("YC_KEY_SECRET_FILE_PATH")
    )

    iam_token = yc.get_iam_token()

    with open(file='./iam-token.env', mode='w') as f:
        f.write(f'export TF_VAR_token={iam_token}')

    # print(yc.get_iam_token())


if __name__ == "__main__":
    main()
