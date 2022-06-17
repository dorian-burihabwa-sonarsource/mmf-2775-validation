#! /usr/bin/env python3

from dataclasses import dataclass

import csv
import json
import os
import re

__FOLDER="./reports"

def list_entries(root):
    return sorted([os.path.join(root, entry) for entry in os.listdir(root)])

def list_folders(root):
    return [entry for entry in list_entries(root) if os.path.isdir(entry)]

def list_files(root):
    return [entry for entry in list_entries(root) if os.path.isfile(entry)]


@dataclass
class Sample:
    branch_name: str
    cache_enabled: bool
    runtime: int
    
    def to_text_array(self):
        return [self.branch_name, str(self.cache_enabled), str(self.runtime)]

def inspect_sample(sample_folder):
    json_file, analysis_file = list_files(sample_folder)
    with open(json_file) as handle:
        json_report = json.load(handle)
        runtime = json_report["durationNanos"]
    cache_enabled = "with-cache" in analysis_file
    branch_name = re.search("sq\-.+\-cache-(?P<branch>.+)\.log", analysis_file).group("branch")
    return Sample(branch_name, cache_enabled, runtime).to_text_array()


def build_table():
    table = [["Branch", "Cache enabled", "Runtime (ns)"]]
    sample_folders = list_folders(__FOLDER)
    for sample_folder in sample_folders:
        line = inspect_sample(sample_folder)
        table.append(line)
    return table


def main():
    table = build_table()
    for line in table:
        row = ""
        for token in line:
            row += f"{token},"
        print(row)
    
        

if __name__ == "__main__":
    main()