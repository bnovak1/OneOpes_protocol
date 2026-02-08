"""
Fills a Jinja2 template for Psi4 input files using data from a JSON file and optionally an XYZ file.
"""

import argparse
import json
import os

import jinja2

# Read command line inputs
parser = argparse.ArgumentParser()
parser.add_argument("--template", type=str, help="Template file path")
parser.add_argument("--json", type=str, help="Input JSON file path")
parser.add_argument("--structure_name", type=str, help="Structure name")
parser.add_argument("--structure_type", type=str, help="Structure type")
parser.add_argument("--xyz_file", type=str, default=None, help="XYZ file path")
parser.add_argument("--output", type=str, help="Filled template file path")
args = parser.parse_args()

# Create the output directory if it doesn't exist (Snakemake usually does this, but being safe)
os.makedirs(os.path.dirname(args.output), exist_ok=True)

# Get coordinates and element list and UA0 radius list for implicit solvent from XYZ file
if args.xyz_file is not None:
    
    with open(args.xyz_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
        # Skip the first two lines (atom count and comment)
        coordinates = "".join(lines[2:]).rstrip()
        
        # Element list from first column in the XYZ file
        element_list = [line.split()[0] for line in lines[2:]]

        # UA0 radius list and element index list for implicit solvent model        
        radius_list = []
        element_index_list = []
        for index, element in enumerate(element_list, start=1):
            if element == "H":
                element_index_list.append(str(index))
                radius_list.append("1.17")
            elif element == "C":
                element_index_list.append(str(index))
                radius_list.append("1.72")
        
        # Convert lists to string format for Jinja2
        radius_list = "[" + ", ".join(radius_list) + "]"
        element_index_list = "[" + ", ".join(element_index_list) + "]"
        
else:
    
    coordinates = None
    radius_list = None
    element_index_list = None
    
# Read JSON file
with open(args.json, "r", encoding="utf-8") as f:
    json_data = json.load(f)[args.structure_name]

# Setup Jinja2 environment
template_dir = os.path.dirname(args.template)
template_name = os.path.basename(args.template)
env = jinja2.Environment(loader=jinja2.FileSystemLoader(template_dir))
template = env.get_template(template_name)

# Render the template
rendered_content = template.render(
    structure_name=args.structure_name,
    structure_path=f"structure_files/{args.structure_type}",
    output_path=f"../output/psi4/{args.structure_type}/{args.structure_name}",
    charge=json_data["CHARGE"],
    coordinates=coordinates,
    constrained_atoms=json_data["CONSTRAINED_ATOMS"],
    equiv_groups1=json_data["EQUIV_GROUPS"]["STAGE1"],
    equiv_groups2=json_data["EQUIV_GROUPS"]["STAGE2"],
    element_list=element_index_list,
    radius_list=radius_list,
)

# Write to output file
with open(args.output, "w", encoding="utf-8") as f:
    f.write(rendered_content)