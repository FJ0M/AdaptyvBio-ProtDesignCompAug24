# STRUCTCOMPARE
**STRUCTural COMparator for Performing Analysis of Related Entities**

Authors: Freddie J. O. Martin, Victor Klein de Sousa, Mar Pérez-Ruiz, Haidai Hu, Nicholas M. I. Taylor*

Affiliations:
Structural Biology of Molecular Machines Group, Protein Structure & Function Program, Novo Nordisk Foundation Center for Protein Research, Faculty of Health and Medical Sciences,
University of Copenhagen, Blegdamsvej 3B, 2200 Copenhagen, Denmark

*Correspondence nicholas.taylor@cpr.ku.dk

## About
STRUCTCOMPARE is a python based method to compare experimental biological structures and find statistically significant conformational changes in the molecular structure.

Check out the preprint here: _tbd._

Please cite: _tbd_.

### Prerequisites:
- These must be experimental structures (i.e. Cryo-EM, X-ray crystallography, NMR) **not** AlphaFold models as this method uses B-factors to score the significance.
- Currently this method only supports PDB files, not mmCIF.

## Installation and use:
*todo

### Colab notebook
*todo

### Python command line package
*todo

### Example use cases:
1. Showing that two structures are **not** different despite different experimental conditions.
We were asked in review for [this paper](https://www.nature.com/articles/s41467-023-39899-z) to show that two structures ([8BRD](https://www.rcsb.org/structure/8BRD), [8BRI](https://www.rcsb.org/structure/8BRI)) of the same protein were not significantly different despite different membrane conditions. However the RMSD value between the two was lower than the resolution of both structures. 

*insert image here*

2. Showing that two structures **are** different due to different experimental conditions.

*insert image here*

3. Comparing apo and holo structures.

*insert image here*

4. Comparing structures of mutated / altered molecules.

*insert image here*

5. Comparing structures of similar proteins

*insert image here*

### How it works
Calculating the position-dependent Z-score, involves using the model B-factor in the following manner:

$$
Z_{i} = \left( \frac{\Delta R_{i}}{\sigma_{i}} \right)
$$

Where $\Delta R_{i}$ is the distance between $C_{\alpha}$ atoms of residue $i$ in the two forms $\text{model 1}$ and $\text{model 2}$:

$$
\Delta R_{i} = \left\lvert R_{i} (\text{model 1}) - R_{i} (\text{model 2}) \right\rvert 
$$

The error ($\sigma$) on $\Delta R_{i}$ can be calculated as:

$$
\sigma = \sqrt{\sigma_{i}^{2} (\text{model 1}) + \sigma_{i}^{2} (\text{model 2})}
$$

Where $\sigma^{2}$ is the mean-square atomic displacement, measured in $Å^{2}$, and its relationship with B-factor ($B$) is:

$$
\sigma^{2} = \frac{3B}{8\pi^{2}}
$$

To calculate the Z-score ($Z_{i}$) based on the $C_{\alpha}$ distance and B-factors, we can rearrange the above equations to:

$$
Z_{i} = \left( \frac{2\pi\sqrt{2}\Delta R_{i}}{\sqrt{3(B_{i} (\text{model 1}) + B_{i} (\text{model 2}))}} \right)
$$


### Current limitions

tbd.

#### To Do
- Add compatibility for mmCIF files.
- Add align option
- Protein complexes
- RNA/DNA structures

### Acknowledgments and references.

STRUCTCOMPARE uses the US-align functionality from the Zhang lab [[1](https://www.nature.com/articles/s41592-022-01585-1)][[2](https://onlinelibrary.wiley.com/doi/10.1002/prot.20264)],[[3](https://academic.oup.com/bioinformatics/article/26/7/889/213219?login=false)],[[website](https://zhanggroup.org/TM-score/)].

The functions and proof came originally from Marc Delarue's lab, where Haidai Hu earned his PhD, to prove statistical significance of the structural changes in ion channels [[4](https://www.pnas.org/doi/epdf/10.1073/pnas.1717700115)]. This method proved useful to us for reviewing the significance of conformational changes in biomacromolecular structures, and we hope it is useful for the wider structural biology community.

Other useful stuff for coding:
-https://zhanggroup.org/US-align/help/
-https://pymolwiki.org/index.php/Command_Line_Options


