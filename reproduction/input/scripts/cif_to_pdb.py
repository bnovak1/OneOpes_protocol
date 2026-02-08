"""
Convert a CIF file from the structure_files directory to a PDB file with the same name and path.
"""

from pathlib import Path
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Convert CIF file to PDB format")
parser.add_argument("cif_file", type=str, help="Path to the CIF file")
args = parser.parse_args()

# Setup file paths
cif_path = Path(args.cif_file)
pdb_path = cif_path.with_suffix(".pdb")

# Read the CIF file
with open(cif_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Extract atom data
atoms = []
for line in lines:
    if line.startswith("MOL "):
        parts = line.split()
        if len(parts) >= 10 and parts[3] in ["O", "C", "N", "H"]:
            atom_id = parts[1]
            element = parts[3]
            x = float(parts[6])
            y = float(parts[7])
            z = float(parts[8])
            atoms.append((atom_id, element, x, y, z))

# Write PDB file
with open(pdb_path, "w", encoding="utf-8") as f:
    f.write(f"REMARK   Generated from {cif_path.name}\n")
    for i, (atom_id, element, x, y, z) in enumerate(atoms, 1):
        f.write(
            f"HETATM{i:5d} {atom_id:4s} MOL     1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00          {element:>2s}\n"
        )
    f.write("END\n")

print(f"Converted {len(atoms)} atoms from {cif_path} to {pdb_path}")
