#! /usr/bin/env python3

from dataclasses import dataclass
from typing import List

import argparse
import json
import os
import re

import numpy

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
    
    def to_text_array(self) -> List[str]:
        return [self.branch_name, str(self.cache_enabled), str(self.runtime)]

@dataclass
class SampleAggregation:
    samples: List[Sample]

    def to_text_array(self) -> List[str]:
        if not self.samples:
            return []
        line  = self.samples[0].to_text_array()
        if len(self.samples) == 1:
            return line
        for i in range(1, len(self.samples)):
            sample = self.samples[i]
            line.append(str(sample.runtime))
        runtimes = [sample.runtime for sample in self.samples]
        line.append(str(numpy.median(runtimes)))
        line.append(str(numpy.average(runtimes)))
        line.append(str(numpy.std(runtimes)))

        return line

def inspect_sample(sample_folder):
    json_file, analysis_file = list_files(sample_folder)
    with open(json_file) as handle:
        json_report = json.load(handle)
        runtime = json_report["durationNanos"]
    cache_enabled = "with-cache" in analysis_file
    branch_name = re.search("sq\-.+\-cache-(?P<branch>.+)\.log", analysis_file).group("branch")
    return Sample(branch_name, cache_enabled, (runtime / 1_000_000_000))

def aggregate(samples: List[Sample]) -> List[SampleAggregation]:
    grouping = {}
    for sample in samples:
        key = sample.branch_name + str(sample.cache_enabled)
        if key in grouping:
            grouping[key].append(sample)
        else:
            grouping[key] = [sample]
    return [SampleAggregation(group) for group in grouping.values()]


def build_table(folder: str) -> List[str]:
    sample_folders = list_folders(folder)
    samples = []
    for sample_folder in sample_folders:
        sample = inspect_sample(sample_folder)
        samples.append(sample)
    groupings = aggregate(samples)

    header = ["Branch", "Cache enabled"]
    header += ["Runtime(s)" for _ in range(len(groupings[0].samples))]
    header += ["Median", "Average", "StdDev"]
    table = [header]

    for grouping in groupings:
        line = grouping.to_text_array()
        table.append(line)
    return table


def main():
    parser = argparse.ArgumentParser(__file__, "Parse analysis results")
    parser.add_argument("reportsfolder", help="Path where the reports were dumped", type=str)
    args = parser.parse_args()
    table = build_table(args.reportsfolder)
    for line in table:
        row = ""
        for token in line:
            row += f"{token},"
        print(row)
    
        

if __name__ == "__main__":
    main()
