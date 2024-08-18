import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import re

def TM_score(pdb, parent_pdb, outfile='out.txt',TM_bin='/Users/phr361/Documents/Coding/TM/TMscore'):
    os.system(f'{TM_bin} {pdb} {parent_pdb} > {outfile}')
    tm_score = None
    with open(outfile, 'r') as file:
        for line in file:

            match = re.search(r' = (0.\d+)', line)

            if match:
                tm_score = float(match.group(1))
                return tm_score
    if tm_score==None:
        print(f'No TM found, please check the output: {outfile}') 
        return tm_score

def avg_pLDDT(pdb_file):
    b_factors = []
    with open(pdb_file, 'r') as file:
        for line in file:
            if line.startswith('ATOM') or line.startswith('HETATM'):
                b_factor = float(line[60:66].strip())
                b_factors.append(b_factor)

    if len(b_factors) > 0:
        average_b_factor = sum(b_factors) / len(b_factors)
        return average_b_factor, b_factors
    else:
        print('No b-factors found, check input')
        return None

def create_sequencefile_for_afold(motb_seqs=None,mota_seq=None,output='file.fasta'):
    if '.fasta' in output:
        pass
    elif '.FASTA' in output:
        pass
    elif '.pdb' in output:
        output=output.replace('.pdb','.fasta')
    else: output=output+'.fasta'
    
    with open(output, 'w') as f:
        if len(mota_seq)<10 and len(mota_seq)>1:
            for seq in mota_seq:
                #f.write('>'+name+'_'+chain)
                #f.write('\n')
                f.write(seq)
                f.write('\n')
        else:
            f.write(mota_seq)
            f.write('\n')
        if len(motb_seqs)<10 and len(motb_seqs)>1:
            for seq in motb_seqs:
                #f.write('>'+name+'_'+chainsB[i])
                #f.write('\n')
                f.write(seq)
                f.write('\n')
        else:
            f.write(motb_seqs)
            f.write('\n')
        # write new fasta file
    f.close()

from Bio import PDB

def extract_sequence_from_pdb(pdb_filename):
    parser = PDB.PDBParser(QUIET=True)
    structure = parser.get_structure('protein', pdb_filename)

    # Assuming there is only one model in the PDB file
    model = structure[0]
    sequence = ''

    for chain in model:
        for residue in chain:
            if PDB.is_aa(residue):
                sequence += PDB.Polypeptide.three_to_one(residue.get_resname())

    return sequence
