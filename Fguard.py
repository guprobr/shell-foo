#!/usr/bin/env python3
import os
import ipaddress
import nmap
import asyncio
import aiohttp
import concurrent.futures
from dotenv import load_dotenv
from pprint import pprint
from termcolor import colored  # Added for colored output

# Check if .env file exists
if not os.path.isfile(".env"):
    print("Error: .env file not found.")
    exit(1)

# Load environment variables from .env file
load_dotenv()

# Default values
CENTREON_DEFAULT_URL = 'http://127.0.0.1:8888/centreon'
CENTREON_DEFAULT_USER = 'admin'
CENTREON_DEFAULT_PW = 'joshua'
SWITCH_INTERVAL_DEFAULT = 11
MAX_WORKERS_DEFAULT = 9999  # Increased to 20 for more parallelism
SCAN_PORTS_DEFAULT = [22]
ENABLE_CENTREON_DEFAULT = True

# Set default values after checking .env file
centreon_url = os.getenv('CENTREON_URL', CENTREON_DEFAULT_URL)
username = os.getenv('CENTREON_USER', CENTREON_DEFAULT_USER)
password = os.getenv('CENTREON_PW', CENTREON_DEFAULT_PW)
switch_interval = int(os.getenv('SWITCH_INTERVAL', SWITCH_INTERVAL_DEFAULT))
max_workers = int(os.getenv('MAX_WORKERS', MAX_WORKERS_DEFAULT))
scan_ports = [int(port) for port in os.getenv('SCAN_PORTS', ','.join(map(str, SCAN_PORTS_DEFAULT))).split(',')]
enable_centreon = os.getenv('ENABLE_CENTREON', ENABLE_CENTREON_DEFAULT)

# Centreon integration
async def integrate_with_centreon(session, host):
    host_data = {
            "action": "add",
            "object": "host",
            "values": str(host['ip']) + ";" + str(host['ip']) + ";" + str(host['ip']) + ";generic-host;central;Linux-SerVers"
        # Add more parameters as needed
    }
    try:
        async with session.post(centreon_url + '/api/index.php?action=action&object=centreon_clapi', data=host_data) as response:
            pprint(host_data)
    except Exception as e:
        print(f"Error integrating with Centreon: {e}")

# Host discovery function
def discover_host_ports(host, ports):
    print("Scanning host: " + colored(host, 'blue'))  # Colored output
    nm = nmap.PortScanner()
    try:
        nm.scan(hosts=host, ports=','.join(map(str, ports)), arguments='--open')
    except Exception as e:
        print(f"Error scanning host {host}: {e}")

    host_info = {'ip': host, 'ports': []}
    if host in nm.all_hosts():
        for port in nm[host]['tcp']:
            if nm[host]['tcp'][port]['state'] == 'open':
                host_info['ports'].append(port)

    return host_info

# IP range calculation function
def calculate_ip_range(subnet, mask_size):
    original_network = ipaddress.IPv4Network(subnet, strict=True)
    subnet_list = list(original_network.subnets(new_prefix=mask_size))
    ip_range = []
    for subnet in subnet_list:
        for ip in subnet.hosts():
            ip_range.append(str(ip))
    return ip_range

# Subnet sweeping function
async def sweep_subnet(session, subnet, mask_size, ports):
    print(f"DEBUG: Sweep subnet for {subnet}")  # Add a debug statement
    ip_range = calculate_ip_range(subnet, mask_size)

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Use map to execute the discover_host_ports function for each IP in parallel
        host_infos = list(executor.map(lambda host: discover_host_ports(host, ports), ip_range))

    for host_info in host_infos:
        if host_info['ports']:
            print("Host " + colored(host_info['ip'], 'green') + " is UP with open ports: " +
                  colored(', '.join(map(str, host_info['ports'])), 'red'))
            if enable_centreon:
                await integrate_with_centreon(session, host_info)

if __name__ == '__main__':
    try:
        load_dotenv()
        async def main():
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=60)) as session:
                subnet = '10.20.0.0/16'  # Changed to a larger subnet for more efficient IP range calculation
                await sweep_subnet(session, subnet, 24, scan_ports)

        asyncio.run(main())
    except Exception as e:
        print(f"Error in main function: {e}")