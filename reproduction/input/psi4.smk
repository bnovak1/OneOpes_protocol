configfile: "psi4.json"


# Structure names
# STRUCTURE_NAMES = {"host": ["CB8"], "guests": ["S6-G9"]}
# STRUCTURE_NAMES = {
#     "guests": ["S6-G3", "S6-G5", "S6-G7", "S6-G8", "S6-G9", "S8-G1", "S8-G2", "S8-G4", "S8-G6"]
# }
STRUCTURE_NAMES = {"guests": ["S6-G9"]}

# Number of cores on this machine.
import os

THREADS_MAX = os.cpu_count()


# Generate a rule graph
rule graph:
    input:
        snakefile="psi4.smk",
    output:
        graph="psi4_rulegraph.png",
    shell:
        "snakemake -s {input.snakefile} --rulegraph run_psi4_resp | dot -Tpng > {output.graph}"


# Convert CIF files to PDB files.
rule cif_to_pdb:
    input:
        cif="structure_files/{structure_type}/{structure_name}.cif",
        script="scripts/cif_to_pdb.py",
    output:
        pdb="structure_files/{structure_type}/{structure_name}.pdb",
    shell:
        """
        conda run -n OneOpes python {input.script} {input.cif}
        """


rule cifs_to_pdbs:
    input:
        [
            rules.cif_to_pdb.output.pdb.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Convert PDB files to XYZ files using openbabel
rule pdb_to_xyz:
    input:
        pdb="structure_files/{structure_type}/{structure_name}.pdb",
    output:
        xyz="structure_files/{structure_type}/{structure_name}.xyz",
    shell:
        "conda run -n OneOpes obabel -ipdb {input.pdb} -oxyz -O {output.xyz}"


rule pdbs_to_xyzs:
    input:
        [
            rules.pdb_to_xyz.output.xyz.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Fill in the psi4 input file jinja2 template for B3LYP optimization
rule fill_psi4_input_template_b3lyp:
    input:
        xyz=rules.pdb_to_xyz.output.xyz,
        template="templates/B3LYP_opt.j2",
        script="scripts/fill_psi4_input_template.py",
        json="psi4.json",
    output:
        inp="psi4/{structure_type}/{structure_name}/b3lyp_opt.psi4",
    shell:
        """
        conda run -n psi4_1.10 python {input.script} --template {input.template} --json {input.json} --structure_name {wildcards.structure_name} --structure_type {wildcards.structure_type} --xyz_file {input.xyz} --output {output.inp}
        """


rule fill_psi4_input_templates_b3lyp:
    input:
        [
            rules.fill_psi4_input_template_b3lyp.output.inp.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Run Psi4 B3LYP optimization
rule run_psi4_b3lyp:
    input:
        inp=rules.fill_psi4_input_template_b3lyp.output.inp,
    output:
        b3lyp_xyz="../output/psi4/{structure_type}/{structure_name}/b3lyp_opt.xyz",
        b3lyp_wfn="../output/psi4/{structure_type}/{structure_name}/b3lyp_wfn.npy",
    params:
        output_dir="../output/psi4/{structure_type}/{structure_name}",
    threads: THREADS_MAX
    shell:
        """
        conda run -n psi4_1.10 psi4 {input.inp}
        mv timer.dat {params.output_dir}/timer_b3lyp.dat
        """


rule run_psi4s_b3lyp:
    input:
        [
            rules.run_psi4_b3lyp.output.b3lyp_xyz.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Align the B3LYP optimized structure to the Gaussian structure using openbabel. Include only non-hydrogen atoms in the alignment.
rule align_b3lyp_to_gaussian:
    input:
        b3lyp_xyz=rules.run_psi4_b3lyp.output.b3lyp_xyz,
        gaussian_xyz="../../gaussian_results/{structure_type}/{structure_name}_gaussian/final_optimized.xyz",
    output:
        aligned_1="../analysis/{structure_type}/{structure_name}/psi4_gaussian_alignment_1.xyz",
        aligned_2="../analysis/{structure_type}/{structure_name}/psi4_gaussian_alignment_2.xyz",
    shell:
        """
        # First align and get both frames
        conda run -n OneOpes obabel -ixyz {input.b3lyp_xyz} -ixyz {input.gaussian_xyz} -oxyz -O tmp.xyz --align -at "!H,!H"
        
        # Extract the aligned frames
        conda run -n OneOpes obabel -ixyz tmp.xyz -f 1 -l 1 -oxyz -O {output.aligned_1}
        conda run -n OneOpes obabel -ixyz tmp.xyz -f 2 -l 2 -oxyz -O {output.aligned_2}
        rm tmp.xyz
        """


rule align_b3lyps_to_gaussians:
    input:
        [
            rules.align_b3lyp_to_gaussian.output.aligned_1.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES["guests"]
        ],

# Compute the RMSD between the aligned B3LYP and Gaussian structures using obrms
rule compute_rmsd_b3lyp_gaussian:
    input:
        aligned_1=rules.align_b3lyp_to_gaussian.output.aligned_1,
        aligned_2=rules.align_b3lyp_to_gaussian.output.aligned_2,
    output:
        rmsd="../analysis/{structure_type}/{structure_name}/psi4_gaussian_alignment_rmsd.txt",
    shell:
        """
        conda run -n OneOpes obrms {input.aligned_1} {input.aligned_2} > {output.rmsd}
        """

rule compute_rmsds_b3lyp_gaussians:
    input:
        [
            rules.compute_rmsd_b3lyp_gaussian.output.rmsd.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES["guests"]
        ],

# Fill in the psi4 input file jinja2 template for HF single point energy calculation in vacuum, starting from the B3LYP optimized geometry
rule fill_psi4_input_template_hf_vacuum:
    input:
        template="templates/HF_single_point_vacuum.j2",
        script="scripts/fill_psi4_input_template.py",
        json="psi4.json",
        b3lyp_xyz=rules.run_psi4_b3lyp.output.b3lyp_xyz,
    output:
        inp="psi4/{structure_type}/{structure_name}/hf_single_point_vacuum.psi4",
    shell:
        """
        conda run -n psi4_1.7 python {input.script} --template {input.template} --json {input.json} --structure_name {wildcards.structure_name} --structure_type {wildcards.structure_type} --xyz_file {input.b3lyp_xyz} --output {output.inp}
        """


rule fill_psi4_input_templates_hf_vacuum:
    input:
        [
            rules.fill_psi4_input_template_hf_vacuum.output.inp.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Run Psi4 HF optimization in vacuum
rule run_psi4_hf_vacuum:
    input:
        inp=rules.fill_psi4_input_template_hf_vacuum.output.inp,
    output:
        hf_wfn="../output/psi4/{structure_type}/{structure_name}/hf_wfn_vacuum.npy",
    params:
        output_dir="../output/psi4/{structure_type}/{structure_name}",
    threads: THREADS_MAX
    shell:
        """
        conda run -n psi4_1.7 psi4 {input.inp}
        mv timer.dat {params.output_dir}/timer_hf_vacuum.dat
        """


rule run_psi4s_hf_vacuum:
    input:
        [
            rules.run_psi4_hf_vacuum.output.hf_wfn.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Fill in the psi4 input file jinja2 template for HF optimization in implicit water
rule fill_psi4_input_template_hf_implicit_water:
    input:
        template="templates/HF_single_point_implicit_water.j2",
        script="scripts/fill_psi4_input_template.py",
        json="psi4.json",
        b3lyp_xyz=rules.run_psi4_b3lyp.output.b3lyp_xyz,
        wfn=rules.run_psi4_hf_vacuum.output.hf_wfn,
    output:
        inp="psi4/{structure_type}/{structure_name}/hf_single_point_implicit_water.psi4",
    shell:
        """
        conda run -n psi4_1.7 python {input.script} --template {input.template} --json {input.json} --structure_name {wildcards.structure_name} --structure_type {wildcards.structure_type} --xyz_file {input.b3lyp_xyz} --output {output.inp}
        """


rule fill_psi4_input_templates_hf_implicit_water:
    input:
        [
            rules.fill_psi4_input_template_hf_implicit_water.output.inp.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Run Psi4 HF optimization in implicit water
rule run_psi4_hf_implicit_water:
    input:
        inp=rules.fill_psi4_input_template_hf_implicit_water.output.inp,
    output:
        hf_wfn="../output/psi4/{structure_type}/{structure_name}/hf_wfn_implicit_water.npy",
    params:
        output_dir="../output/psi4/{structure_type}/{structure_name}",
    threads: THREADS_MAX
    shell:
        """
        conda run -n psi4_1.7 psi4 {input.inp}
        mv timer.dat {params.output_dir}/timer_hf_implicit_water.dat
        """


rule run_psi4s_hf_implicit_water:
    input:
        [
            rules.run_psi4_hf_implicit_water.output.hf_wfn.format(
                structure_type=structure_type, structure_name=structure_name
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
        ],


# Visualize the cavity.npz file generated for implicit solvent calculations
# This is optional and for debugging purposes only.
rule visualize_cavity:
    input:
        script="scripts/visualize_cavity.py",
        cavity="../output/psi4/{structure_type}/{structure_name}/cavity.npz",
    output:
        fig="../output/psi4/{structure_type}/{structure_name}/cavity_{structure_name}.png",
    shell:
        """
        conda run -n pyvista python {input.script} --cavity_file {input.cavity} --output_figure {output.fig}
        """


# Fill in the psi4 input file jinja2 template for RESP fitting
rule fill_psi4_input_template_resp:
    input:
        template="templates/RESP.j2",
        script="scripts/fill_psi4_input_template.py",
        json="psi4.json",
        wfn="../output/psi4/{structure_type}/{structure_name}/hf_wfn_{solvent_type}.npy",
    output:
        inp="psi4/{structure_type}/{structure_name}/resp_{solvent_type}.psi4",
    shell:
        """
        conda run -n psi4_1.7 python {input.script} --template {input.template} --json {input.json} --structure_name {wildcards.structure_name} --structure_type {wildcards.structure_type} --solvent {wildcards.solvent_type} --output {output.inp}
        """


rule fill_psi4_input_templates_resp:
    input:
        [
            rules.fill_psi4_input_template_resp.output.inp.format(
                structure_type=structure_type,
                structure_name=structure_name,
                solvent_type=solvent_type,
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
            for solvent_type in ["vacuum", "implicit_water"]
        ],


# Run Psi4 RESP fitting
rule run_psi4_resp:
    input:
        inp=rules.fill_psi4_input_template_resp.output.inp,
    output:
        charges1="../output/psi4/{structure_type}/{structure_name}/resp_stage1_{solvent_type}.txt",
        charges2="../output/psi4/{structure_type}/{structure_name}/resp_charges_{solvent_type}.txt",
        charges_antechamber="../output/psi4/{structure_type}/{structure_name}/resp_{solvent_type}.crg",
        grid="../output/psi4/{structure_type}/{structure_name}/1_grid_{solvent_type}.dat",
        grid_esp="../output/psi4/{structure_type}/{structure_name}/1_grid_esp_{solvent_type}.dat",
    params:
        output_dir="../output/psi4/{structure_type}/{structure_name}",
    threads: THREADS_MAX
    shell:
        """
        conda run -n psi4_1.7 psi4 {input.inp}
        mv *grid.dat {output.grid}
        mv *grid_esp.dat {output.grid_esp}
        mv timer.dat {params.output_dir}/timer_resp_{wildcards.solvent_type}.dat
        mv results.out {params.output_dir}/results_resp_{wildcards.solvent_type}.out
        """


rule run_psi4s_resp:
    input:
        [
            rules.run_psi4_resp.output.charges_antechamber.format(
                structure_type=structure_type,
                structure_name=structure_name,
                solvent_type=solvent_type,
            )
            for structure_type in STRUCTURE_NAMES
            for structure_name in STRUCTURE_NAMES[structure_type]
            for solvent_type in ["vacuum", "implicit_water"]
        ],


# # Step 1: Run Psi4 (generates RESP charges)
# psi4 {{ structure_name }}.in
# # Step 2: Create mol2 with RESP charges using antechamber
# antechamber -i {{ structure_name }}_hf_opt.xyz -fi xyz \
#             -o {{ structure_name }}.mol2 -fo mol2 \
#             -c rc -cf {{ structure_name }}_resp.crg \
#             -at gaff2 -rn MOL
# # Step 3: Generate missing force field parameters
# parmchk2 -i {{ structure_name }}.mol2 -f mol2 \
#          -o {{ structure_name }}.frcmod
# # Step 4: Create Amber topology
# tleap -f - <<EOF
# source leaprc.gaff2
# loadamberparams {{ structure_name }}.frcmod
# MOL = loadmol2 {{ structure_name }}.mol2
# saveamberparm MOL {{ structure_name }}.prmtop {{ structure_name }}.inpcrd
# quit
# EOF
# # Step 5: Convert to GROMACS format
# acpype -p {{ structure_name }}.prmtop -x {{ structure_name }}.inpcrd
