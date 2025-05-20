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
    response = requests.get(api_baseurl + "/management/identities", headers=headers, params=params)
    data = response.json()
    return data

def set_identity(uid,status):
    api_baseurl = os.getenv('API_BASEURL')
    api_token = os.getenv('API_TOKEN')
    headers = {
            "Authorization": f"Bearer {api_token}",
            "Content-Type": "application/json; charset=utf-8",
        }
    resp=get_identity(uid)
    data_json = resp['data'][0]
    data_json['dataStatus']=status
    del data_json['metadata']
    id=resp['data'][0]['_id']
    response=requests.patch(api_baseurl +"/management/identities/" + id , headers=headers,json=data_json)
    return response

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--uid', help='uid', default='')
    parser.add_argument( '--status',help="disable | enable")
    args = parser.parse_args()
    status=-3
    if args.status == "enable":
        status=1

    data=set_identity(args.uid,status)
    rep=data.json()
    print("Status request: " + str(rep['statusCode']) +"\n")

