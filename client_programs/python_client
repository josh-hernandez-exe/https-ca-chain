#!/usr/bin/python
import os
import sys
import json
import requests

"""
Example Uses:

./client.py
./client.py 1
./client.py 1 --parent-type master
./client.py --parent-type master
./client.py --parent-type master 1
"""


client_suffix = ""
parent_type = "intermediate"

is_arg_used = [False for _ in sys.argv]

for index,arg in enumerate(sys.argv):
    if arg == "python":
        continue

    elif arg.endswith(".py") or arg.endswith(".pyc") or arg.endswith(".pyo"):
        continue

    elif arg == "--parent-type" and len(sys.argv) >= index :
        parent_type = sys.argv[index+1]

        is_arg_used[index] = True
        is_arg_used[index+1] = True

    elif not is_arg_used[index] and not client_suffix:
        client_suffix = arg
        is_arg_used[index] = True


client_name = "client"+ client_suffix

client_folder = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "client"
)

client_key_file = os.path.join(
    client_folder,
    "private",
    "{client_name}.key.pem".format(client_name=client_name)
)

client_cert_file = os.path.join(
    client_folder,
    "certs",
    "{client_name}.cert.pem".format(client_name=client_name)
)

client_cert_chain_file = os.path.join(
    client_folder,
    "certs",
    "{client_name}.chain.cert.pem".format(client_name=client_name)
)

config = json.loads(open("config.json").read())

url = "{protocol}://{domain}:{port}/".format(
    protocol="https",
    domain=config["hostname"],
    port=config["port"],
)

r = requests.get(
    url,
    cert=(client_cert_file, client_key_file),
    verify=config[parent_type]["chain"],
)

print(r)
