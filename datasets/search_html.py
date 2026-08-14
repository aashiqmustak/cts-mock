import urllib.request
import re
import ssl

ctx = ssl._create_unverified_context()
try:
    url = 'https://meps.ahrq.gov/data_stats/download_data/pufs/h243/h243doc.shtml'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req, context=ctx).read().decode('utf-8', errors='ignore')
    
    # Print lines containing "zip" or "ssp" or "dat"
    lines = html.split('\n')
    print("Matching lines:")
    for i, line in enumerate(lines):
        if any(term in line.lower() for term in ["zip", "ssp", "dat", "h243"]):
            print(f"{i}: {line.strip()[:150]}")
except Exception as e:
    print(f"Error: {e}")
