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
    fields='id, webViewLink, webContentLink',
    supportsAllDrives=True
).execute()

file_id = response['id']
# Prefer a direct download-style link; webViewLink is also fine
download_link = response.get('webContentLink') or f"https://drive.google.com/uc?export=download&id={file_id}"
print(f"DRIVE_LINK={download_link}")
print(f"FILE_ID={file_id}")
out = os.environ.get("GITHUB_OUTPUT")
if out:
    with open(out, "a", encoding="utf-8") as f:
        f.write(f"drive_link={download_link}\n")
        f.write(f"file_id={file_id}\n")

