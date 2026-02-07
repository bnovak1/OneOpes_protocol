"""
Visualize cavity.npz file from implicit solvent calculation.
"""

import argparse
import numpy as np
import pyvista as pv

# Parse command line arguments
parser = argparse.ArgumentParser(description="Visualize cavity.npz file from implicit solvent calculation.")
parser.add_argument("--cavity_file", type=str, help="Path to the cavity.npz")
args = parser.parse_args()

# Load cavity data
data = np.load(args.cavity_file)

# Collect all vertices from vertices_0, vertices_1, ...
vertex_keys = [k for k in data.files if k.startswith('vertices_')]
all_vertices = np.concatenate([data[k] for k in vertex_keys], axis=1).T

# Create a point cloud and visualize
cloud = pv.PolyData(all_vertices)
cloud.plot(point_size=3, render_points_as_spheres=True)

# Optionally, save the point cloud to a file
# output_file = args.cavity_file.replace('.npz', '_cavity.ply')
# cloud.save(output_file)