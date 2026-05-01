import argparse
from pathlib import Path


def extract_topology_charges(topology_path):
    """Extract atom names (5th column) and charges (7th column) from the second [ atoms ] section."""
    atom_names = []
    charges = []
    atoms_count = 0
    with open(topology_path, 'r') as f:
        for line in f:
            stripped = line.strip()
            if stripped == '[ atoms ]':
                atoms_count += 1
                continue
            if atoms_count < 2:
                continue
            if atoms_count > 2:
                break
            if not stripped or stripped.startswith(';'):
                continue
            if stripped.startswith('['):
                break
            tokens = stripped.split()
            if len(tokens) >= 7:
                atom_names.append(tokens[4])   # 5th column (index 4)
                try:
                    charge = float(tokens[6])  # 7th column (index 6)
                    charges.append(charge)
                except ValueError:
                    pass
    return atom_names, charges


def main():
    parser = argparse.ArgumentParser(
        description="Extract Gaussian charges from a GROMACS topology file."
    )
    parser.add_argument(
        "--topology",
        type=Path,
        required=True,
        help="Path to the GROMACS topology (.top) file.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Path to the output file where charges will be written.",
    )
    args = parser.parse_args()

    atom_names, topology_charges = extract_topology_charges(args.topology)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with open(args.output, 'w') as f:
        for name, charge in zip(atom_names, topology_charges):
            f.write(f"{name} {charge}\n")


if __name__ == "__main__":
    main()
