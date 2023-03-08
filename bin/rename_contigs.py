#!/usr/bin/env python3

import argparse
import os
import sys
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

# Arguments
def parse_args(args=None):
    Description = "Rename contigs in a FASTA file after assembly."
    Epilog = "Example usage: rename_contigs.py <FASTA> <ASSEMBLER> <OUTPUT>"

    parser = argparse.ArgumentParser(description = "Rename assembled contig headers produced from assembly programs")
    parser.add_argument('--input', metavar='FASTA', help='Assembly file in FASTA format')
    parser.add_argument('--assembler', metavar='ASSEMBLER', help='Assembly algorithm that produced the FASTA file for propagating in contig names')
    parser.add_argument('--output', metavar='OUTPUT', help='Output name of reconfigured assembly FASTA file with new contig header names')
    return parser.parse_args(args)

# Read in fasta file and rename contigs
def rename_contigs(fasta, assembler, output):
    contig_id = 0
    name = os.path.basename(fasta).replace(".fasta", "").strip().splitlines()[0]
    with open(output, "w") as outfile:
        for seq_record in SeqIO.parse(fasta, "fasta"):
            contig_id = contig_id + 1
            newid = str(contig_id).zfill(5)
            outfile.write(">" + name + "_" + assembler + "_" + str(newid) + "\n")
            outfile.write(str(seq_record.seq) + "\n")

def main(args=None):
    args = parse_args(args)
    rename_contigs(args.input, args.assembler, args.output)

if __name__ == "__main__":
    sys.exit(main())
