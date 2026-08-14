import urllib.request
import urllib.error
import zipfile
import os
import ssl
import time

print("Starting FULL dataset download process (with HTTP resume, 416 handler, and timeouts)...", flush=True)

# Output folder
output_dir = "datasets"
os.makedirs(output_dir, exist_ok=True)

# Create an unverified SSL context to bypass certificate issues
ssl_ctx = ssl._create_unverified_context()

def download_file_with_resume(url, output_path, max_retries=20):
    print(f"\nTarget: {url} -> {output_path}", flush=True)
    req_headers = {'User-Agent': 'Mozilla/5.0'}
    
    downloaded_bytes = 0
    if os.path.exists(output_path):
        downloaded_bytes = os.path.getsize(output_path)
        print(f"Found partial download: {downloaded_bytes / (1024*1024):.2f} MB. Attempting to resume...", flush=True)
        
    for attempt in range(1, max_retries + 1):
        try:
            req = urllib.request.Request(url, headers=req_headers)
            if downloaded_bytes > 0:
                req.add_header('Range', f'bytes={downloaded_bytes}-')
                
            with urllib.request.urlopen(req, context=ssl_ctx, timeout=20) as response:
                meta = response.info()
                content_length = int(meta.get("Content-Length", 0))
                status = response.getcode() if hasattr(response, 'getcode') else 200
                
                if status == 206:
                    total_size = downloaded_bytes + content_length
                    print(f"Resuming download from byte {downloaded_bytes}. Remaining: {content_length / (1024*1024):.2f} MB", flush=True)
                else:
                    downloaded_bytes = 0
                    total_size = content_length
                    print(f"Starting fresh download. Total size: {total_size / (1024*1024):.2f} MB", flush=True)
                
                chunk_size = 512 * 1024  # 512 KB
                mode = "ab" if downloaded_bytes > 0 else "wb"
                
                with open(output_path, mode) as out_file:
                    while True:
                        chunk = response.read(chunk_size)
                        if not chunk:
                            break
                        out_file.write(chunk)
                        downloaded_bytes += len(chunk)
                        if total_size > 0:
                            print(f"Progress: {downloaded_bytes / total_size * 100:.1f}% ({downloaded_bytes / (1024*1024):.1f} MB / {total_size / (1024*1024):.1f} MB)", end="\n", flush=True)
                        else:
                            print(f"Progress: {downloaded_bytes / (1024*1024):.1f} MB downloaded", end="\n", flush=True)
                print("Download complete.", flush=True)
                return  # Success!
                
        except urllib.error.HTTPError as e:
            if e.code == 416:
                print("\nFile is already fully downloaded (Range Not Satisfiable).", flush=True)
                return  # Success!
            print(f"\n[Attempt {attempt}/{max_retries}] HTTP Error {e.code}: {e.reason}", flush=True)
            if attempt == max_retries:
                raise e
            print("Retrying in 5 seconds...", flush=True)
            time.sleep(5)
        except Exception as e:
            print(f"\n[Attempt {attempt}/{max_retries}] Connection issue: {e}", flush=True)
            if attempt == max_retries:
                raise e
            if os.path.exists(output_path):
                downloaded_bytes = os.path.getsize(output_path)
            print("Retrying in 5 seconds...", flush=True)
            time.sleep(5)

def extract_zip(zip_path, extract_to):
    print(f"Extracting: {zip_path} -> {extract_to}", flush=True)
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print("Extraction complete.", flush=True)

# Helper to verify zip file integrity
def is_zip_valid(file_path):
    if not os.path.exists(file_path):
        return False
    try:
        with zipfile.ZipFile(file_path) as z:
            return z.testzip() is None
    except Exception:
        return False

# 1. Download & Extract FDA NDC Directory Dataset
fda_zip = os.path.join(output_dir, "fda_ndc.zip")
fda_url = "https://download.open.fda.gov/drug/ndc/drug-ndc-0001-of-0001.json.zip"
try:
    if not is_zip_valid(fda_zip):
        print("FDA ZIP is missing or corrupt. Downloading fresh...", flush=True)
        if os.path.exists(fda_zip):
            os.remove(fda_zip)
        download_file_with_resume(fda_url, fda_zip)
        
    extract_zip(fda_zip, output_dir)
    if os.path.exists(fda_zip):
        os.remove(fda_zip)
    print("FDA Dataset processed successfully.", flush=True)
except Exception as e:
    print(f"Error processing FDA dataset: {e}", flush=True)

# 2. Download & Extract MEPS 2022 Full Year Consolidated File (SAS format)
meps_zip = os.path.join(output_dir, "meps_hc243.zip")
meps_url = "https://meps.ahrq.gov/mepsweb/data_files/pufs/h243/h243ssp.zip"
try:
    if not is_zip_valid(meps_zip):
        print("MEPS ZIP is missing or corrupt. Downloading fresh...", flush=True)
        if os.path.exists(meps_zip):
            os.remove(meps_zip)
        download_file_with_resume(meps_url, meps_zip)
        
    extract_zip(meps_zip, output_dir)
    if os.path.exists(meps_zip):
        os.remove(meps_zip)
    print("MEPS Dataset processed successfully.", flush=True)
except Exception as e:
    print(f"Error processing MEPS dataset: {e}", flush=True)

# 3. Download CMS Provider Utilization Data (Medicare Physician 2024 CSV)
cms_csv = os.path.join(output_dir, "cms_utilization_full.csv")
cms_url = "https://data.cms.gov/sites/default/files/2026-05/b5ebab5a-f490-418a-9bce-4b9f31419356/PHY_R26_P05_V10_D24_Prov_Svc.csv"
try:
    download_file_with_resume(cms_url, cms_csv)
    print("CMS Dataset processed successfully.", flush=True)
except Exception as e:
    print(f"Error processing CMS dataset: {e}", flush=True)

print("\nDataset download task finished!", flush=True)
