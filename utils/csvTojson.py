#!/usr/bin/python3
import json
import csv
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv', help='Csv File')
    parser.add_argument('--json', help='output json file ')
    parser.add_argument('--separator', help='Separator',default=";")
    parser.add_argument('--lineseparator', help='Line separator', default="\n")
    args = parser.parse_args()
    csv_to_json(args)


def csv_to_json(args):
    data = {}
    with open(args.csv , encoding='utf-8') as file_handler:
        reader = csv.DictReader(file_handler , delimiter=args.separator , lineterminator=args.lineseparator)
        data = [row for row in reader]
    with open(args.json, 'w') as jsonfile:
        json.dump(data, jsonfile,indent=4)


if __name__ == '__main__':
    main()
