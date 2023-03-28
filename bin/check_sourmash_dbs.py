#!/usr/bin/env python3

import os
import csv
import argparse

def check_csv_file(csv_file_path):
    valid_rows = []
    with open(csv_file_path, 'r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            is_valid = True
            for key, value in row.items():
                if ' ' in value:
                    print(f'Error: {key} column contains a space.')
                    is_valid = False
                    break
            if not os.path.isfile(row['database_path']):
                print(f'Error: {row["database_path"]} does not exist.')
                is_valid = False
            if not os.path.isfile(row['lineage_path']):
                print(f'Error: {row["lineage_path"]} does not exist.')
                is_valid = False
            if not row['lineage_path'].endswith('.csv'):
                print(f'Error: {row["lineage_path"]} does not end with .csv')
                is_valid = False
            if is_valid:
                valid_rows.append(row)
    return valid_rows

def main():
    parser = argparse.ArgumentParser(description='Validate CSV file')
    parser.add_argument('csv_file', type=str, help='Path to CSV file')
    parser.add_argument('-o', '--output', type=str, help='Path to output validated CSV file', default='valid_databases.csv')
    args = parser.parse_args()

    csv_file_path = args.csv_file
    output_file_path = args.output
    valid_rows = check_csv_file(csv_file_path)
    if valid_rows:
        with open(output_file_path, 'w', newline='') as csv_file:
            fieldnames = ['database', 'database_path', 'lineage_path']
            csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
            csv_writer.writeheader()
            for row in valid_rows:
                csv_writer.writerow(row)
        print(f'Valid databases written to {output_file_path}')

if __name__ == '__main__':
    main()
