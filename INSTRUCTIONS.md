# Lab Guide: Infrastructure Setup

Follow these steps to recreate the demo environment in the AWS Console.

## Phase 1: Create the S3 Bucket
1.  Go to the **S3 Console**.
2.  Click **Create bucket**.
3.  **Bucket Name:** Give it a unique name (e.g., `demo-upload-bucket-YOURNAME`).
4.  **Region:** Select **Stockholm (eu-north-1)**.
    * *Note: If you choose a different region, you must update the `region_name` in `main.py`.*
5.  Keep all other settings as default and click **Create bucket**.

## Phase 2: Create the IAM Role
*We use an IAM Role so the EC2 instance has permission to talk to S3 without using secret keys.*

1.  Go to the **IAM Console** and click **Roles** > **Create role**.
2.  **Trusted Entity Type:** Select **AWS Service**.
3.  **Service or Use Case:** Select **EC2** and click **Next**.
4.  **Add Permissions:**
    * Search for `AmazonS3FullAccess` and check the box.
    * *(Optional)*: If your bucket uses KMS encryption, you may need `AWSKeyManagementServicePowerUser`.
5.  **Name:** Enter `EC2-S3-Access-Role`.
6.  Click **Create role**.

## Phase 3: Launch the EC2 Instance
1.  Go to the **EC2 Console** and click **Launch Instances**.
2.  **Name:** `S3-Uploader-Demo`.
3.  **OS Image:** Select **Amazon Linux 2023**.
4.  **Instance Type:** `t3.micro` (Free Tier eligible).
5.  **Key Pair:** Select your key pair (so you can SSH in).
6.  **Network Settings:** Ensure "Allow SSH traffic" is checked.
7.  **Advanced Details (Crucial Step):**
    * Scroll down to **IAM instance profile**.
    * Select the role you created: `EC2-S3-Access-Role`.
8.  Click **Launch Instance**.

## Phase 4: Deploy and Test
1.  **Connect to your instance** (via SSH or EC2 Instance Connect).
2.  **Install Git and Python:**
    ```bash
    sudo dnf update -y
    sudo dnf install git python3-pip -y
    ```
3.  **Clone the Repository:**
    ```bash
    git clone https://github.com/jameskipngetich/s3-uploader-demo.git
    cd s3-uploader-demo
    ```
4.  **Install Requirements:**
    ```bash
    pip3 install boto3 requests
    ```
5.  **Run the Test:**
    Create a dummy file and try to upload it using the script.
    ```bash
    echo "This is a test upload" > demo.txt
    python3 main.py <YOUR_BUCKET_NAME> demo.txt put
    ```

**Success Criteria:**
You should see `Status: 200` in the output. If you see `403 Forbidden`, check your IAM Role permissions.