#!/usr/bin/env python3

import argparse
import os
import sys
import gzip
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord


# Arguments
def parse_args(args=None):
    Description = "Rename contigs in a FASTA file after assembly."
    Epilog = "Example usage: rename_contigs.py <FASTA> <ASSEMBLER> <OUTPUT>"

    parser = argparse.ArgumentParser(description="Rename assembled contig headers produced from assembly programs")
    parser.add_argument("--input", metavar="FASTA", help="Assembly file in FASTA format")
    parser.add_argument(
        "--assembler",
        metavar="ASSEMBLER",
        nargs="?",
        help="Assembly algorithm that produced the FASTA file for propagating in contig names",
    )
    parser.add_argument(
        "--output",
        metavar="OUTPUT",
        help="Output name of reconfigured assembly FASTA file with new contig header names",
    )
    return parser.parse_args(args)


# Read in fasta file and rename contigs
def rename_contigs(fasta, assembler, output):
    contig_id = 0
    name = os.path.basename(fasta).replace(".fasta.gz", "").strip().splitlines()[0]
    with gzip.open(output, "wb") as outfile:
        with gzip.open(fasta, "rt") as handle:
            for seq_record in SeqIO.parse(handle, "fasta"):
                contig_id = contig_id + 1
                newid = str(contig_id).zfill(7)
                if assembler is not None:
                    header = ">" + assembler + "_" + name + "_contig_" + str(newid) + "\n"
                else:
                    header = ">" + name + "_contig_" + str(newid) + "\n"
                seq = str(seq_record.seq) + "\n"
                outfile.write(header.encode())
                outfile.write(seq.encode())
    handle.close()
    outfile.close()


def main(args=None):
    args = parse_args(args)
    rename_contigs(args.input, args.assembler, args.output)


if __name__ == "__main__":
    sys.exit(main())
