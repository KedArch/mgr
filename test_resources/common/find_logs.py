import os
import re
import csv
import sys
import subprocess
from datetime import datetime

def parse_timestamp(timestamp_str):
    try:
        if timestamp_str[2] == ':':
            if '.' in timestamp_str:
                return datetime.strptime(timestamp_str, '%H:%M:%S.%f')
            else:
                return datetime.strptime(timestamp_str, '%H:%M:%S')
        elif 'T' in timestamp_str:
            return datetime.strptime(timestamp_str, '%Y-%m-%dT%H:%M:%S.%f')
        else:
            return datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError as e:
        print(f"Invalid time format: {e}")
        return None

def find_first_matches_after_time(log_file, reference_time_str, patterns):
    reference_time = parse_timestamp(reference_time_str)
    if not reference_time:
        return {}

    regex_patterns = {pattern: re.compile(pattern) for pattern in patterns}
    matches = {pattern: None for pattern in patterns}
    if log_file.endswith(".service"):
        try:
            result = subprocess.run(['journalctl', '--no-pager',
                                     '--since', reference_time_str,
                                     '--output=cat',
                                     #'--output=short-precise',
                                     '-u', log_file],
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE,
                                    text=True,
                                    check=True)
            logs = result.stdout.split('\n')
        except subprocess.CalledProcessError as e:
            print(f"Error reading logs: {e.stderr}")
            return None
    else:
        try:
            with open(log_file, 'r') as file:
                logs = file.readlines()
        except FileNotFoundError:
            print(f"File {log_file} does not exist.")
            return {}
    for line in logs:
        match = re.match(r'.*([0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.?[0-9]{,6})(.*)', line)
        if match:
            log_time_str, log_content = match.groups()
            log_time = parse_timestamp(log_time_str).time()
            if log_time and log_time > reference_time.time():
                for pattern, regex in list(regex_patterns.items()):
                    if matches[pattern] is None and regex.search(log_content):
                        matches[pattern] = [log_time, line]
                        del regex_patterns[pattern]
                if not regex_patterns:
                    break
    return matches

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python analyze_logs.py <timestamp> <log_file|systemd.service> <csv_file> <pattern1> [<pattern2> ...]")
        sys.exit(1)

    reference_time = sys.argv[1]
    log_file = sys.argv[2]
    csv_file = sys.argv[3]
    patterns = sys.argv[4:]

    results = find_first_matches_after_time(log_file, reference_time, patterns)
    if results:
        file_exists = os.path.isfile(csv_file)
        with open(csv_file, mode='a+') as file:
            writer = csv.writer(file)
            if not file_exists:
                writer.writerow(["time_taken"]+list(results.keys())+list(results.keys()))
            row = [reference_time]
            for value in results.values():
                row.append(value[0])
            for value in results.values():
                row.append(value[1])
            writer.writerow(row)
    else:
        sys.exit(2)
