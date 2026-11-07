#!/usr/bin/env python3
import json
import os
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

sa_key = json.loads(os.environ['GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY'])
creds = Credentials.from_service_account_info(sa_key, scopes=['https://www.googleapis.com/auth/drive'])
drive = build('drive', 'v3', credentials=creds)

FOLDER_ID = '1FAslY7-NI2TBG0ksUxUhwOe15yV1KFh0'
iso_path = os.environ['ISO_PATH']
iso_name = os.environ['ISO_NAME']

file_metadata = {'name': iso_name, 'parents': [FOLDER_ID]}
media = MediaFileUpload(iso_path, mimetype='application/x-iso9660', resumable=True)

response = drive.files().create(
    body=file_metadata,
    media_body=media,
    fields='id, webContentLink',
    supportsAllDrives=True
).execute()

print(f'Uploaded: {response["webContentLink"]}')
