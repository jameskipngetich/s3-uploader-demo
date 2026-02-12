# AWS S3 Presigned URL Demo

This project demonstrates how to securely generate **Presigned URLs** for Amazon S3 uploads using an EC2 instance.

**Key Concepts:**
* **Security:** Uses AWS IAM Roles (Instance Profiles) instead of hardcoded Access Keys.
* **Regional Compliance:** Correctly handles AWS Regions (e.g., `eu-north-1`) using `boto3` Config to enforce Signature Version 4.
* **Presigned URLs:** Allows a client to upload a file directly to S3 without needing permanent credentials.

## Prerequisites
* An active AWS Account.
* An S3 Bucket (created in a specific region, e.g., `eu-north-1`).
* An EC2 Instance running Amazon Linux 2023.

## Quick Start

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/jameskipngetich/s3-uploader-demo.git
    cd s3-uploader-demo
    ```

2.  **Install Dependencies:**
    ```bash
    pip3 install boto3 requests
    ```

3.  **Run the Upload Demo:**
    ```bash
    # Syntax: python3 main.py <BUCKET_NAME> <FILE_TO_UPLOAD> <ACTION>
    
    # Example: Create a dummy file and upload it
    echo "Hello S3" > test.txt
    python3 main.py my-demo-bucket-123 test.txt put
    ```