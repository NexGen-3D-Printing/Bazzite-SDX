#!/usr/bin/env python3
import json
import os
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

client_id = os.environ["GOOGLE_OAUTH_CLIENT_ID"]
client_secret = os.environ["GOOGLE_OAUTH_CLIENT_SECRET"]
refresh_token = os.environ["GOOGLE_OAUTH_REFRESH_TOKEN"]

creds = Credentials(
    token=None,
    refresh_token=refresh_token,
    token_uri="https://oauth2.googleapis.com/token",
    client_id=client_id,
    client_secret=client_secret,
    scopes=["https://www.googleapis.com/auth/drive"],
)
creds.refresh(Request())

drive = build("drive", "v3", credentials=creds)

# Show which account is authenticated
try:
    about = drive.about().get(fields="user(emailAddress,displayName)").execute()
    user = about.get("user", {})
    print(f"Authenticated as: {user.get('displayName')} <{user.get('emailAddress')}>")
except Exception as e:
    print(f"Could not determine authenticated user: {e}")

FOLDER_ID = os.environ.get("GOOGLE_DRIVE_FOLDER_ID", "1FAslY7-NI2TBG0ksUxUhwOe15yV1KFh0")
iso_path = os.environ["ISO_PATH"]
iso_name = os.environ["ISO_NAME"]

# Verify folder exists and is accessible
try:
    folder = drive.files().get(
        fileId=FOLDER_ID, fields="id,name,driveId", supportsAllDrives=True
    ).execute()
    print(f"Using Drive folder: {folder.get('name')} ({folder.get('id')})")
except HttpError as e:
    print(f"Cannot access target folder {FOLDER_ID}: {e}")
    print("Ensure the authorized Google account has access to this folder and GOOGLE_DRIVE_FOLDER_ID is correct.")
    raise

file_metadata = {"name": iso_name, "parents": [FOLDER_ID]}
media = MediaFileUpload(iso_path, mimetype="application/x-iso9660", resumable=True)

try:
    response = drive.files().create(
        body=file_metadata,
        media_body=media,
        fields="id, webViewLink, webContentLink",
        supportsAllDrives=True,
    ).execute()
except HttpError as e:
    print(f"Google Drive upload failed: {e}")
    try:
        print(f"Details: {e.error_details}")
    except Exception:
        pass
    raise

file_id = response["id"]
download_link = response.get("webContentLink") or f"https://drive.google.com/uc?export=download&id={file_id}"
print(f"DRIVE_LINK={download_link}")
print(f"FILE_ID={file_id}")
out = os.environ.get("GITHUB_OUTPUT")
if out:
    with open(out, "a", encoding="utf-8") as f:
        f.write(f"drive_link={download_link}\n")
        f.write(f"file_id={file_id}\n")
