#!/usr/bin/env python3
import csv
from pathlib import Path
rows=[{"id":1,"customer":"Acme Retail","status":"active"},{"id":2,"customer":"Blue Market","status":"active"},{"id":3,"customer":"City Shop","status":"inactive"}]
out=Path(__file__).resolve().parents[1]/'sample-data'/'customers.csv'
with out.open('w',newline='',encoding='utf-8') as f:
    wr=csv.DictWriter(f,fieldnames=rows[0].keys()); wr.writeheader(); wr.writerows(rows)
print(f"Wrote {len(rows)} rows to {out}")
