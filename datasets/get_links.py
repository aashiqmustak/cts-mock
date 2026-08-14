import urllib.request
import re
import ssl

ctx = ssl._create_unverified_context()
try:
    print("Fetching MEPS main data page...")
    url = 'https://meps.ahrq.gov/mepsweb/data_stats/download_data_files.jsp'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req, context=ctx).read().decode('utf-8', errors='ignore')
    
    # Print all links containing "zip" or "h24" or "h23"
    links = re.findall(r'href=["\']([^"\']+)["\']', html, re.I)
    print("Matching links:")
    for l in links:
        if 'h24' in l or 'h23' in l or 'zip' in l or 'puf' in l:
            print(l)
except Exception as e:
    print(f"Error: {e}")
