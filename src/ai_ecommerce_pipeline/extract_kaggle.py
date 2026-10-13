# Imports

import os
import csv
from dotenv import load_dotenv
from kaggle.api.kaggle_api_extended import KaggleApi
from azure.storage.blob import BlobServiceClient
from groq import Groq

load_dotenv()

# Setup & Security
def translate_reviews_with_AI(file_path):
    print("Initializing Groq AI translation....")
    client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    translated_rows = []

    with open(file_path, mode='r', encoding='utf-8') as infile:
        reader = csv.reader(infile)
        header = next(reader)
        translated_rows.append(header + ["english_translation"])

        # Iterator,control flow

        for i, row in enumerate(reader):
            if i >= 50:
                break

            review_text = row[4]
            if not review_text:
                translated_rows.append(row + [""])
                continue

            try:
                chat_completion = client.chat.completions.create(
                    messages=[
                        {
                            "role": "user",
                            "content": f"Translate this Portuguese e-commerce review to English. Only return the English text, no pleasantries: '{review_text}'"
                        }
                    ],
                    model="openai/gpt-oss-20b"
                )
                translation = chat_completion.choices[0].message.content.strip()
                translated_rows.append(row + [translation])
            except Exception as e:
                print(f"AI translation failed for row {i}: {e}")
                translated_rows.append(row + ["Error"])

    with open(file_path, mode='w', encoding='utf-8', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerows(translated_rows)
    print("AI Translation Complete.")


# Kaggle data extraction
def run_extraction():
    print("Authenticating with Kaggle....")
    api = KaggleApi()
    api.authenticate()
    dataset_name = "olistbr/brazilian-ecommerce"
    download_path = "./olist_raw_data"
    print(f"Downloading {dataset_name}....")
    api.dataset_download_files(dataset_name, path=download_path, unzip=True)


    # Conditional AI Trigger
    reviews_file = os.path.join(download_path, "olist_order_reviews_dataset.csv")
    if os.path.exists(reviews_file):
        translate_reviews_with_AI(reviews_file)

    # Cloud Loading
    print("Authenticating with Azure....")
    connection_string = os.getenv("AZURE_CONNECTION_STRING")
    if not connection_string:
        raise ValueError("Azure connection string not found in .env")

    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    container_client = blob_service_client.get_container_client("ecommerce-raw")

    if not container_client.exists():
        container_client.create_container()

    print("Uploading files to Azure Data Lake...")
    for file_name in os.listdir(download_path):
        if file_name.endswith(".csv"):
            file_path = os.path.join(download_path, file_name)
            blob_client = container_client.get_blob_client(blob=file_name)
            with open(file_path, "rb") as data:
                blob_client.upload_blob(data, overwrite=True)
            print(f"Uploaded {file_name}")

    print("Extraction Complete.")