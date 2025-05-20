import requests
import os
import argparse

def get_identity(uid):
    api_baseurl = os.getenv('API_BASEURL')
    api_token = os.getenv('API_TOKEN')
    headers = {
            "Authorization": f"Bearer {api_token}",
            "Content-Type": "application/json; charset=utf-8",
        }
    params = {
        "filters[inetOrgPerson.uid]": uid
    }
    response=requests.get(api_baseurl +"/management/identities",headers=headers,params=params)
    data=response.json()
    return data

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--uid', help='uid', default='')
    args = parser.parse_args()
    data=get_identity(args.uid)
    print("Status request: " + data.statusCode +"\n")
    print("found : " + data.statusCode + "\n")





