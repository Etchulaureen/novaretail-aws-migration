#!/usr/bin/env python3
import argparse, socket, sys, time
from urllib.parse import urlparse
from urllib.request import Request, urlopen

def dns(host):
    try:
        ips=socket.gethostbyname_ex(host)[2]
        print(f"PASS DNS: {host} -> {', '.join(ips)}")
        return True
    except Exception as e:
        print(f"FAIL DNS: {e}"); return False

def http(url, timeout):
    try:
        start=time.time(); req=Request(url,headers={"User-Agent":"novaretail-validator/1.0"})
        with urlopen(req,timeout=timeout) as r:
            ms=(time.time()-start)*1000; ok=200 <= r.status < 400
            print(f"{'PASS' if ok else 'FAIL'} HTTP: status={r.status} latency_ms={ms:.1f}")
            return ok
    except Exception as e:
        print(f"FAIL HTTP: {e}"); return False

def tcp(host,port,timeout):
    try:
        with socket.create_connection((host,port),timeout=timeout): pass
        print(f"PASS TCP: {host}:{port}"); return True
    except Exception as e:
        print(f"FAIL TCP: {host}:{port}: {e}"); return False

def main():
    p=argparse.ArgumentParser(); p.add_argument('--url',required=True); p.add_argument('--db-host'); p.add_argument('--db-port',type=int,default=5432); p.add_argument('--timeout',type=int,default=10)
    a=p.parse_args(); parsed=urlparse(a.url)
    if not parsed.hostname: return 2
    results=[dns(parsed.hostname),http(a.url,a.timeout)]
    if a.db_host: results.append(tcp(a.db_host,a.db_port,a.timeout))
    print(f"Result: {sum(results)}/{len(results)} checks passed")
    return 0 if all(results) else 1

if __name__=='__main__': sys.exit(main())
