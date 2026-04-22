---
title: Host-Guest Binding Free Energies a la Carte - An Automated OneOPES Protocol -- Reproduction of results
date created: 2025-11-09 09:41:35
date modified: 2026-04-21 20:36:36
source: https://www.scienceopen.com/document?vid=2b04bb41-a0f2-4600-bf65-80ea79bfe099
tags:
  - host-guest
  - OPES/OneOPES
  - GROMACS
  - PLUMED
---
**[[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol]]

# Notes

## Get code

* I forked the [Pefema/OneOpes_protocol](https://github.com/Pefema/OneOpes_protocol) and cloned it to `./OneOpes_protocol`

```shell
git clone git@github.com:bnovak1/OneOpes_protocol.git
```

* From the README:

```
This pipeline automates the following processes:

1. Structure file conversion and preparation
2. Gaussian input preparation and processing
3. Playmolecule output processing
4. Topology generation and system setup
5. Water model integration
6. Molecular docking for initial binding poses
7. System preparation for molecular dynamics
8. PLUMED configuration and analysis
```

## Create conda environment

* A conda environment file, `environment.yml`, is included in the repository. I successfully installed the conda environment named `OneOpes` using:

```shell
conda env create -f environment.yml
```

## Additional Required Software

The following software must be installed separately and added to your system PATH:

### GROMACS with MPI support (gmx_mpi) installation

* GROMACS 2023 was used in the paper
	* [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20251128214730978.pdf#page=4&selection=276,0,287,2|Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20250809190136682, page 4]]
* Downloaded GROMACS 2023.5:

```shell
cd ~/installed
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2023.5.tar.gz -O gromacs.tar.gz
tar -xzf gromacs.tar.gz
rm gromacs.tar.gz
```

* Installed GROMACS 2023.5:

```shell
cd gromacs-2023.5
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DGMX_MPI=ON
make -j 4
make install
. /usr/local/gromacs/bin/GMXRC
```

* Added `gmx_mpi` to my `PATH` in `~/.bashrc`:

```shell
# GROMACS
export PATH="$PATH:/usr/local/gromacs/bin"
```

### PLUMED (version 2.9 Or higher) installation

Downloaded PLUMED 2.9.4:

```shell
cd ~/installed
wget https://github.com/plumed/plumed2/releases/download/v2.9.4/plumed-src-2.9.4.tgz -O plumed.tgz
tar -xzf plumed.tgz
rm plumed.tgz
```

Installed PLUMED 2.9.4:

```shell
cd plumed-2.9.4
./configure --prefix=/usr/local
make -j 4
sudo make install
cd ..
rm -r plumed-2.9.4
```

Patched GROMACS with PLUMED:

```shell
cd gromacs-2023.5
echo 4 | plumed patch -p
```

### Psi4 instead of Gaussian16

- Gaussian16 was used in the paper which requires a license. Therefore, I have to use a different program in place of Gaussian16
* Wikipedia: [Alternatives to Gaussian](https://en.wikipedia.org/wiki/List_of_quantum_chemistry_and_solid-state_physics_software)
* From you.com research prompt: [[Best Free Alternatives to Gaussian16 for B3LYP Minimization, Hartree-Fock, and RESP Charge Fitting]]
	* psi4 seems to be the best option

#### Psi4 installation

There are conda packages available:

```shell
conda install psi4
```

There were conflicts. The following was output by `conda`:

```
LibMambaUnsatisfiableError: Encountered problems while solving:
  - nothing provides libint 2.7.3dev1.* needed by psi4-1.8-py310ha861

Could not solve for environment specs
The following packages are incompatible
├─ pin on python 3.7.* =* * is installable and it requires
│  └─ python =3.7 *, which can be installed;
└─ psi4 =* * is not installable because there are no viable options
   ├─ psi4 [1.10|1.9|1.9.1] would require
   │  └─ python >=3.10,<3.11.0a0 *, which conflicts with any installable versions previously reported;
   ├─ psi4 [1.10|1.9|1.9.1] would require
   │  └─ python >=3.11,<3.12.0a0 *, which conflicts with any installable versions previously reported;
   ├─ psi4 [1.10|1.9|1.9.1] would require
   │  └─ python >=3.12,<3.13.0a0 *, which conflicts with any installable versions previously reported;
   ├─ psi4 [1.10|1.9.1] would require
   │  └─ python >=3.13,<3.14.0a0 *, which conflicts with any installable versions previously reported;
   ├─ psi4 [1.8|1.8.1|1.8.2|1.9] would require
   │  └─ libint =2.7.3dev1 *, which does not exist (perhaps a missing channel);
   ├─ psi4 [1.9|1.9.1] would require
   │  └─ python >=3.8,<3.9.0a0 *, which conflicts with any installable versions previously reported;
   └─ psi4 [1.9|1.9.1] would require
      └─ python >=3.9,<3.10.0a0 *, which conflicts with any installable versions previously reported.

Pins seem to be involved in the conflict. Currently pinned specs:
 - python=3.7
```

Upgraded to `python 3.8`:

```shell
conda install python=3.8
```

There were conflicts. The following was output by `conda`:

```
LibMambaUnsatisfiableError: Encountered problems while solving:
  - package python-3.10.18-h1a3bd86_0 requires xz >=5.6.4,<6.0a0, but none of the providers can be installed

Could not solve for environment specs
The following packages are incompatible
├─ ambertools ==22.0 * is installable with the potential options
│  ├─ ambertools 22.0 would require
│  │  └─ python >=3.7,<3.8.0a0 * with the potential options
│  │     ├─ python [3.10.0|3.10.3|...|3.8.8] would require
│  │     │  └─ libffi >=3.3,<3.4.0a0 *, which can be installed;
│  │     ├─ python [3.7.0|3.7.1|...|3.8.2] would require
│  │     │  └─ readline >=7.0,<8.0a0 *, which can be installed;
│  │     ├─ python [3.7.3|3.7.6|3.7.7|3.7.8|3.8.2] would require
│  │     │  └─ libffi [>=3.2.1,<3.3.0a0 *|>=3.2.1,<3.3a0 *], which can be installed;
│  │     ├─ python [3.7.10|3.7.12|3.7.9] would require
│  │     │  └─ python_abi ==3.7 *_pypy37_pp73, which requires
│  │     │     └─ python =3.7 *_73_pypy, which conflicts with any installable versions previously reported;
│  │     └─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.10 *_cp310, which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.8 *_cp38, which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.9 *_cp39, which can be installed;
│  └─ ambertools 22.0 would require
│     └─ netcdf-fortran >=4.5.4,<4.6.0a0 *, which can be installed;
├─ libffi ==3.4.4 * is not installable because it conflicts with any installable versions previously reported;
├─ libzlib ==1.2.13 * is installable with the potential options
│  ├─ libzlib 1.2.13 would require
│  │  └─ zlib ==1.2.13 *_6, which can be installed;
│  ├─ libzlib 1.2.13 would require
│  │  └─ zlib ==1.2.13 *_5, which can be installed;
│  └─ libzlib 1.2.13 would require
│     └─ zlib ==1.2.13 *_4, which can be installed;
├─ netcdf-fortran ==4.6.0 * is not installable because it conflicts with any installable versions previously reported;
├─ python =3.8 * is installable with the potential options
│  ├─ python [3.10.15|3.10.16|...|3.8.20] would require
│  │  └─ libzlib >=1.3.1,<2.0a0 * with the potential options
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_1, which can be installed;
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_2, which can be installed;
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_0, which can be installed;
│  │     └─ libzlib 1.3.1 would require
│  │        └─ zlib ==1.3.1 *, which can be installed;
│  ├─ python [3.10.0|3.10.3|...|3.8.8], which can be installed (as previously explained);
│  ├─ python [3.8.15|3.8.16|...|3.8.20] conflicts with any installable versions previously reported;
│  ├─ python [3.8.10|3.8.12|...|3.8.8] would require
│  │  └─ python_abi =3.8 *_cp38, which conflicts with any installable versions previously reported;
│  ├─ python [3.8.12|3.8.13|3.8.16] would require
│  │  └─ python_abi ==3.8 *_pypy38_pp73, which can be installed;
│  ├─ python 3.8.5 would require
│  │  └─ python_abi =3.8 *_graalpy223_38_native, which can be installed;
│  ├─ python [3.8.0|3.8.1] would require
│  │  └─ python_abi =* *_cp38, which conflicts with any installable versions previously reported;
│  ├─ python [3.7.0|3.7.1|...|3.8.2], which can be installed (as previously explained);
│  └─ python [3.7.3|3.7.6|3.7.7|3.7.8|3.8.2], which can be installed (as previously explained);
├─ python_abi ==3.7 * is not installable because there are no viable options
│  ├─ python_abi 3.7, which cannot be installed (as previously explained);
│  ├─ python_abi 3.7 would require
│  │  └─ python =3.7 * with the potential options
│  │     ├─ python [3.10.0|3.10.3|...|3.8.8], which can be installed (as previously explained);
│  │     ├─ python [3.7.0|3.7.1|...|3.8.2], which can be installed (as previously explained);
│  │     ├─ python [3.7.3|3.7.6|3.7.7|3.7.8|3.8.2], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.9], which cannot be installed (as previously explained);
│  │     └─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  ├─ python_abi 3.7 would require
│  │  └─ python =3.7 *_cpython, which conflicts with any installable versions previously reported;
│  └─ python_abi 3.7 conflicts with any installable versions previously reported;
├─ readline ==8.2 * is not installable because it conflicts with any installable versions previously reported;
├─ unicodedata2 ==14.0.0 * is installable with the potential options
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python >=3.10,<3.11.0a0 * with the potential options
│  │     ├─ python [3.10.0|3.10.1|...|3.10.9] would require
│  │     │  └─ python_abi =3.10 *_cp310, which can be installed;
│  │     ├─ python [3.10.15|3.10.16|...|3.8.20], which can be installed (as previously explained);
│  │     ├─ python 3.10.8 would require
│  │     │  └─ python_abi =3.10 *_graalpy230_310_native, which can be installed;
│  │     ├─ python [3.10.10|3.10.11|...|3.10.9], which can be installed;
│  │     ├─ python [3.10.18|3.10.19] would require
│  │     │  └─ xz >=5.6.4,<6.0a0 *, which can be installed;
│  │     └─ python [3.10.0|3.10.3|...|3.8.8], which can be installed (as previously explained);
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.10 *_cp310, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.11 *_cp311, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python >=3.7,<3.8.0a0 * with the potential options
│  │     ├─ python [3.10.0|3.10.3|...|3.8.8], which can be installed (as previously explained);
│  │     ├─ python [3.7.0|3.7.1|...|3.8.2], which can be installed (as previously explained);
│  │     ├─ python [3.7.3|3.7.6|3.7.7|3.7.8|3.8.2], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.9], which cannot be installed (as previously explained);
│  │     └─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.7 *_pypy37_pp73, which cannot be installed (as previously explained);
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.8 *_cp38, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.8 *_pypy38_pp73, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.9 *_cp39, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.9 *_pypy39_pp73, which can be installed;
│  └─ unicodedata2 14.0.0 would require
│     └─ python_abi =3.7 *_cp37m but there are no viable options
│        ├─ python_abi 3.7, which cannot be installed (as previously explained);
│        ├─ python_abi 3.7, which cannot be installed (as previously explained);
│        └─ python_abi 3.7 conflicts with any installable versions previously reported;
├─ xz ==5.4.6 * is not installable because it conflicts with any installable versions previously reported;
└─ zlib ==1.2.13 * is not installable because it conflicts with any installable versions previously reported.
```

Upgraded to `python 3.9`:

```shell
conda install python=3.9
```

There were conflicts. The following was output by `conda`:

```
LibMambaUnsatisfiableError: Encountered problems while solving:
  - package python-3.7.0-h5001a0f_0 requires readline >=7.0,<8.0a0, but none of the providers can be installed

Could not solve for environment specs
The following packages are incompatible
├─ ambertools ==22.0 * is installable with the potential options
│  ├─ ambertools 22.0 would require
│  │  └─ python >=3.7,<3.8.0a0 * with the potential options
│  │     ├─ python [3.7.0|3.7.1|...|3.7.7] would require
│  │     │  └─ readline >=7.0,<8.0a0 *, which can be installed;
│  │     ├─ python [3.7.10|3.7.12|3.7.9] would require
│  │     │  └─ python_abi ==3.7 *_pypy37_pp73, which requires
│  │     │     └─ python =3.7 *_73_pypy, which can be installed;
│  │     ├─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  │     ├─ python [3.10.0|3.10.3|...|3.9.7] would require
│  │     │  └─ libffi >=3.3,<3.4.0a0 *, which can be installed;
│  │     └─ python [3.7.3|3.7.6|3.7.7|3.7.8] would require
│  │        └─ libffi [>=3.2.1,<3.3.0a0 *|>=3.2.1,<3.3a0 *], which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.10 *_cp310, which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.8 *_cp38, which can be installed;
│  ├─ ambertools 22.0 would require
│  │  └─ python_abi =3.9 *_cp39, which can be installed;
│  └─ ambertools 22.0 would require
│     └─ netcdf-fortran >=4.5.4,<4.6.0a0 *, which can be installed;
├─ libffi ==3.4.4 * is not installable because it conflicts with any installable versions previously reported;
├─ libzlib ==1.2.13 * is installable with the potential options
│  ├─ libzlib 1.2.13 would require
│  │  └─ zlib ==1.2.13 *_6, which can be installed;
│  ├─ libzlib 1.2.13 would require
│  │  └─ zlib ==1.2.13 *_5, which can be installed;
│  └─ libzlib 1.2.13 would require
│     └─ zlib ==1.2.13 *_4, which can be installed;
├─ netcdf-fortran ==4.6.0 * is not installable because it conflicts with any installable versions previously reported;
├─ python =3.9 * is installable with the potential options
│  ├─ python [3.10.0|3.10.3|...|3.9.7], which cannot be installed (as previously explained);
│  ├─ python [3.9.15|3.9.16|...|3.9.21] conflicts with any installable versions previously reported;
│  ├─ python [3.9.0|3.9.1|...|3.9.9] would require
│  │  └─ python_abi =3.9 *_cp39, which conflicts with any installable versions previously reported;
│  ├─ python [3.9.10|3.9.12|3.9.16|3.9.17|3.9.18] would require
│  │  └─ python_abi ==3.9 *_pypy39_pp73, which can be installed;
│  ├─ python [3.10.15|3.10.16|...|3.9.23] would require
│  │  └─ libzlib >=1.3.1,<2.0a0 * with the potential options
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_1, which can be installed;
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_2, which can be installed;
│  │     ├─ libzlib 1.3.1 would require
│  │     │  └─ zlib ==1.3.1 *_0, which can be installed;
│  │     └─ libzlib 1.3.1 would require
│  │        └─ zlib ==1.3.1 *, which can be installed;
│  └─ python [3.10.18|3.10.19|3.9.23|3.9.24|3.9.25] would require
│     └─ xz >=5.6.4,<6.0a0 *, which can be installed;
├─ python_abi ==3.7 * is installable with the potential options
│  ├─ python_abi 3.7 would require
│  │  └─ python =3.7 *_cpython, which conflicts with any installable versions previously reported;
│  ├─ python_abi 3.7 would require
│  │  └─ python =3.7 * with the potential options
│  │     ├─ python [3.7.0|3.7.1|...|3.7.7], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.9], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  │     ├─ python [3.10.0|3.10.3|...|3.9.7], which cannot be installed (as previously explained);
│  │     └─ python [3.7.3|3.7.6|3.7.7|3.7.8], which can be installed (as previously explained);
│  ├─ python_abi 3.7, which can be installed (as previously explained);
│  └─ python_abi 3.7 conflicts with any installable versions previously reported;
├─ readline ==8.2 * is not installable because it conflicts with any installable versions previously reported;
├─ unicodedata2 ==14.0.0 * is installable with the potential options
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python >=3.10,<3.11.0a0 * with the potential options
│  │     ├─ python [3.10.0|3.10.3|...|3.9.7], which cannot be installed (as previously explained);
│  │     ├─ python [3.10.15|3.10.16|...|3.9.23], which can be installed (as previously explained);
│  │     ├─ python [3.10.18|3.10.19|3.9.23|3.9.24|3.9.25], which can be installed (as previously explained);
│  │     ├─ python [3.10.0|3.10.1|...|3.10.9] would require
│  │     │  └─ python_abi =3.10 *_cp310, which can be installed;
│  │     ├─ python 3.10.8 would require
│  │     │  └─ python_abi =3.10 *_graalpy230_310_native, which can be installed;
│  │     └─ python [3.10.10|3.10.11|...|3.10.9], which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.10 *_cp310, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.11 *_cp311, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python >=3.7,<3.8.0a0 * with the potential options
│  │     ├─ python [3.7.0|3.7.1|...|3.7.7], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.9], which can be installed (as previously explained);
│  │     ├─ python [3.7.10|3.7.12|3.7.15|3.7.16], which can be installed;
│  │     ├─ python [3.10.0|3.10.3|...|3.9.7], which cannot be installed (as previously explained);
│  │     └─ python [3.7.3|3.7.6|3.7.7|3.7.8], which can be installed (as previously explained);
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.7 *_pypy37_pp73, which can be installed (as previously explained);
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.8 *_cp38, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.8 *_pypy38_pp73, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi =3.9 *_cp39, which can be installed;
│  ├─ unicodedata2 14.0.0 would require
│  │  └─ python_abi ==3.9 *_pypy39_pp73, which can be installed;
│  └─ unicodedata2 14.0.0 would require
│     └─ python_abi =3.7 *_cp37m but there are no viable options
│        ├─ python_abi 3.7, which cannot be installed (as previously explained);
│        ├─ python_abi 3.7, which cannot be installed (as previously explained);
│        └─ python_abi 3.7 conflicts with any installable versions previously reported;
├─ xz ==5.4.6 * is not installable because it conflicts with any installable versions previously reported;
└─ zlib ==1.2.13 * is not installable because it conflicts with any installable versions previously reported.
```

Installed `psi4` using the `classic` solver:

```shell
conda install --solver classic psi4
```

I stopped this because it was taking a very long time and probably would not have worked. Here is the output before I stopped it:

```
Retrieving notices: done
Collecting package metadata (current_repodata.json): done
Solving environment: unsuccessful initial attempt using frozen solve. Retrying with flexible solve.
Solving environment: unsuccessful attempt using repodata from current_repodata.json, retrying with next repodata source.
Collecting package metadata (repodata.json): done
Solving environment:
```

It is not necessary to install `psi4` in the current `conda` environment as long as `psi4` produces ESP files that can be read by `ambertools=22.0`. Here are the results of a you.com research prompt: 

[[PSI4 Versions Producing Electrostatic Potential Files Readable by AmberTools 22]]

Installed `psi4` in a new `conda` environment named psi4:

```shell
conda create -n psi4 psi4
```

Here is the installed version of `psi4` from the output of `conda list`:

```
psi4                       1.10             py313hc46b1df_0  conda-forge
```

This version is greater than 1.3 which was suggested in [[PSI4 Versions Producing Electrostatic Potential Files Readable by AmberTools 22]]

## Structure files

The `structure_files` folder contains `.cif` or `.sdf` files for guests and hosts. Only the `CB8` host structure is in the folder. 

I installed the `ipython` package into the `OneOpes` `conda` environment:

```shell
conda install ipython
```

The following packages were installed:

```
  backcall           pkgs/main/noarch::backcall-0.2.0-pyhd3eb1b0_1 
  decorator          pkgs/main/noarch::decorator-5.1.1-pyhd3eb1b0_0 
  ipython            pkgs/main/linux-64::ipython-7.31.1-py37h06a4308_1 
  jedi               pkgs/main/linux-64::jedi-0.18.1-py37h06a4308_1 
  matplotlib-inline  pkgs/main/linux-64::matplotlib-inline-0.1.6-py37h06a4308_0 
  parso              pkgs/main/noarch::parso-0.8.3-pyhd3eb1b0_0 
  pexpect            pkgs/main/noarch::pexpect-4.8.0-pyhd3eb1b0_3 
  pickleshare        pkgs/main/noarch::pickleshare-0.7.5-pyhd3eb1b0_1003 
  prompt-toolkit     pkgs/main/linux-64::prompt-toolkit-3.0.36-py37h06a4308_0 
  ptyprocess         pkgs/main/noarch::ptyprocess-0.7.0-pyhd3eb1b0_3 
  pygments           pkgs/main/noarch::pygments-2.11.2-pyhd3eb1b0_0 
  traitlets          pkgs/main/linux-64::traitlets-5.7.1-py37h06a4308_0 
  wcwidth            pkgs/main/noarch::wcwidth-0.2.5-pyhd3eb1b0_0
  ```

### CB8 host

I could not view the `CB8.cif` file using the `GMXHelper` `VSCode` extension and the `openbabel` package (`openbabel                  3.1.1            py37h6aa62a1_3   conda-forge`) did not work for converting it to a `PDB` file using any of the following commands:

```shell
obabel CB8.cif -O CB8.pdb
obabel -icif CB8.cif -opdb -O CB8.pdb
obabel -immcif CB8.cif -opdb -O CB8.pdb
```

It could be manually converted to a PDB file using the following: ^ec51e1

```python
from pathlib import Path

# Read the CIF file
with open('CB8.cif', 'r') as f:
    lines = f.readlines()

# Extract atom data
atoms = []
reading_atoms = False
for line in lines:
    if line.startswith('MOL '):
        parts = line.split()
        if len(parts) >= 10 and parts[3] in ['O', 'C', 'N', 'H']:
            atom_id = parts[1]
            element = parts[3]
            x = float(parts[6])
            y = float(parts[7])
            z = float(parts[8])
            atoms.append((atom_id, element, x, y, z))

# Write PDB file
with open('CB8.pdb', 'w') as f:
    f.write('REMARK   Generated from CB8.cif\n')
    for i, (atom_id, element, x, y, z) in enumerate(atoms, 1):
        f.write(f'HETATM{i:5d} {atom_id:4s} MOL     1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00          {element:>2s}\n')
    f.write('END\n')

print(f'Converted {len(atoms)} atoms to CB8.pdb')
```

The result could be opened with the `GMXHelper` `VSCode` extension and the structure looked correct:

![[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results-20251118194339646.png]]

I also tried using the `biopython` package to convert the `CIF` file:

```python
from Bio.PDB import MMCIFParser, PDBIO

parser = MMCIFParser()
structure = parser.get_structure('CB8', 'CB8.cif')
io = PDBIO()
io.set_structure(structure)
io.save('CB8.pdb')
```

It failed with the following output:

```python
KeyError                                  Traceback (most recent call last)
<ipython-input-1-005b8b3e096b> in <module>
      2 
      3 parser = MMCIFParser()
----> 4 structure = parser.get_structure('CB8', 'CB8.cif')
      5 io = PDBIO()
      6 io.set_structure(structure)

~/miniconda3/envs/OneOpes/lib/python3.7/site-packages/Bio/PDB/MMCIFParser.py in get_structure(self, structure_id, filename)
     60                 warnings.filterwarnings("ignore", category=PDBConstructionWarning)
     61             self._mmcif_dict = MMCIF2Dict(filename)
---> 62             self._build_structure(structure_id)
     63             self._structure_builder.set_header(self._get_header())
     64 

~/miniconda3/envs/OneOpes/lib/python3.7/site-packages/Bio/PDB/MMCIFParser.py in _build_structure(self, structure_id)
    132         mmcif_dict = self._mmcif_dict
    133 
--> 134         atom_serial_list = mmcif_dict["_atom_site.id"]
    135         atom_id_list = mmcif_dict["_atom_site.label_atom_id"]
    136         residue_id_list = mmcif_dict["_atom_site.label_comp_id"]

KeyError: '_atom_site.id'
```

I also tried the `gemmi` package to convert the `CIF` file:

```python
import gemmi

structure = gemmi.read_structure('CB8.cif')
structure.write_pdb('CB8.pdb')
```

It produced an empty `PDB` file:

```
CRYST1    1.000    1.000    1.000  90.00  90.00  90.00 P 1                      
END 
```

### S8-G1 Guest

The guests are shown in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20251128214730978.pdf#page=5&annotation=516R|Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20250809190136682, page 5]]: ^isy1wk

![[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results-20251118194340033.png]]

The `G1.sdf` file could be viewed with the `GMXHelper` `VSCode` extension:

![[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results-20251118194340457.png]]

This corresponds to `S8-G1` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20251128214730978.pdf#page=5&annotation=516R|Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol-20250809190136682, page 5]].

Renamed `SDF` file:

```shell
mv G1.sdf S8-G1.sdf
```

Converted the `SDF` file to `PDB` using `obabel`:

```shell
obabel -isdf S8-G1.sdf -opdb -O S8-G1.pdb
```

### S8-G2 Guest

I installed the `black` package:

```shell
conda install black
```

The following packages were added to the `OneOpes` `conda` environment:

```
  black              pkgs/main/linux-64::black-22.6.0-py37h06a4308_0 
  click              pkgs/main/linux-64::click-8.0.4-py37h06a4308_0 
  mypy_extensions    pkgs/main/linux-64::mypy_extensions-0.4.3-py37h06a4308_1 
  pathspec           pkgs/main/linux-64::pathspec-0.10.3-py37h06a4308_0 
  platformdirs       pkgs/main/linux-64::platformdirs-2.5.2-py37h06a4308_0 
  tomli              pkgs/main/linux-64::tomli-2.0.1-py37h06a4308_0 
  typed-ast          pkgs/main/linux-64::typed-ast-1.4.3-py37h7f8727e_
```

The `G2.cif` file and all guest structure files other than `G1.sdf` are `CIF` files which would not open with the `GMXHelper` `VSCode` extension. The code from [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^ec51e1]] was modified to take a `CIF` file name as input and output a `PDB` file with the same name in the same folder. This script was saved in the `structure_files` folder as [[cif_to_pdb.py]] and  used to convert all guest `CIF` files to `PDB` files.

The `G2` structure corresponds to `S8-G2` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results-20251118194340852.png]]

Renamed structure files:

```shell
s="8"; n="2"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S6-G3 Guest

The `G3` structure corresponds to `S6-G3` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image.png]]


Renamed structure files:

```shell
s="6"; n="3"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S8-G4 Guest

The `G4` structure corresponds to `S8-G4` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-1.png]]

Renamed structure files:

```shell
s="8"; n="4"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S6-G5 Guest

The `G5` structure corresponds to `S6-G5` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-2.png]]

Renamed structure files:

```shell
s="6"; n="5"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S8-G6 Guest

The `G6` structure corresponds to `S8-G6` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-3.png]]

Renamed structure files:

```shell
s="8"; n="6"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S6-G7 Guest

The `G7` structure corresponds to `S6-G7` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-4.png]]

Renamed structure files:

```shell
s="6"; n="7"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S6-G8 Guest

The `G8` structure corresponds to `S6-G8` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-5.png]]

Renamed structure files:

```shell
s="6"; n="8"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

### S6-G9 Guest

The `G9` structure corresponds to `S6-G9` in [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol - Reproduction of results#^isy1wk]]:

![[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/000_Attachments/image-6.png]]

Renamed structure files:

```shell
s="6"; n="9"; git mv G$n.cif S$s-G$n.cif; mv G$n.pdb S$s-G$n.pdb
```

Created a new `git` branch:

```shell
git branch psi4
git checkout psi4
```

I had to set my identity using `git config` and add my `ED25519` `ssh` key:

```shell
git config --global user.email "tajrkala@gmail.com"
git config --global user.name "Brian Novak"
ssh-add ~/.ssh/id_ed25519
```

Commited and pushed guest structure file name changes to the `psi4` branch:

```shell
git commit -m "Renamed guest structure files"
git push --set-upstream origin psi4
```

## Psi4 geometry optimization

I will start by using the `CB8` host with the `S6-G9` guest which is both the smallest guest in terms of number of atoms and has a rigid structure. 

The `N` atom in `S6-G9` has too many hydrogen atoms for a neutral molecule. Therefore, I had to modify the `PDB` file in `avogadro` by removing the extra `H` atom and then optimizing the geometry using the `GAFF` force field.
 

### Installed `snakemake` in `base` `conda` environment

```shell
conda install snakemake
```

The following new packages were installed:

```
appdirs            pkgs/main/noarch::appdirs-1.4.4-pyhd3eb1b0_0 
argparse-dataclass conda-forge/noarch::argparse-dataclass-2.0.0-pyhd8ed1ab_0 
attrs              pkgs/main/linux-64::attrs-25.4.0-py312h06a4308_2 
blas               pkgs/main/linux-64::blas-1.0-openblas 
bottleneck         pkgs/main/linux-64::bottleneck-1.4.2-py312haa0f9ac_1 
coloredlogs        pkgs/main/linux-64::coloredlogs-15.0.1-py312h06a4308_3 
conda-inject       conda-forge/noarch::conda-inject-1.3.2-pyhd8ed1ab_0 
configargparse     pkgs/main/linux-64::configargparse-1.7.1-py312h06a4308_0 
connection_pool    conda-forge/noarch::connection_pool-0.0.3-pyhd3deb0d_0 
docutils           pkgs/main/linux-64::docutils-0.21.2-py312h06a4308_1 
dpath              conda-forge/noarch::dpath-2.2.0-pyha770c72_1 
eido               conda-forge/noarch::eido-0.2.4-pyhd8ed1ab_0 
gitdb              pkgs/main/linux-64::gitdb-4.0.12-py312h06a4308_0 
gitpython          pkgs/main/linux-64::gitpython-3.1.45-py312h06a4308_0 
humanfriendly      pkgs/main/linux-64::humanfriendly-10.0-py312h06a4308_2 
immutables         pkgs/main/linux-64::immutables-0.21-py312hee96239_0 
iniconfig          pkgs/main/linux-64::iniconfig-2.1.0-py312h06a4308_0 
jinja2             pkgs/main/linux-64::jinja2-3.1.6-py312h06a4308_0 
jsonschema         pkgs/main/linux-64::jsonschema-4.25.0-py312h06a4308_1 
jsonschema-specif~ pkgs/main/linux-64::jsonschema-specifications-2025.9.1-py312h06a4308_0 
jupyter_core       pkgs/main/linux-64::jupyter_core-5.8.1-py312h06a4308_0 
libgfortran-ng     pkgs/main/linux-64::libgfortran-ng-11.2.0-h00389a5_1 
libgfortran5       pkgs/main/linux-64::libgfortran5-11.2.0-h1234567_1 
libopenblas        pkgs/main/linux-64::libopenblas-0.3.30-h46f56fc_2 
logmuse            conda-forge/noarch::logmuse-0.2.8-pyhd8ed1ab_1 
markupsafe         pkgs/main/linux-64::markupsafe-3.0.2-py312h5eee18b_0 
nbformat           pkgs/main/linux-64::nbformat-5.10.4-py312h06a4308_0 
numexpr            pkgs/main/linux-64::numexpr-2.14.1-py312ha5a4a6c_0 
numpy              pkgs/main/linux-64::numpy-2.3.4-py312h816806e_1 
numpy-base         pkgs/main/linux-64::numpy-base-2.3.4-py312h7203c5b_1 
pandas             pkgs/main/linux-64::pandas-2.3.3-py312h23c847b_1 
pephubclient       conda-forge/noarch::pephubclient-0.4.4-pyhd8ed1ab_1 
peppy              conda-forge/noarch::peppy-0.40.8-pyhd8ed1ab_0 
plac               pkgs/main/linux-64::plac-1.4.5-py312h06a4308_0 
psutil             pkgs/main/linux-64::psutil-7.0.0-py312hee96239_1 
pulp               pkgs/main/linux-64::pulp-3.2.2-py312h06a4308_0 
pytest             pkgs/main/linux-64::pytest-8.4.2-py312h06a4308_0 
python-dateutil    pkgs/main/linux-64::python-dateutil-2.9.0post0-py312h06a4308_2 
python-fastjsonsc~ pkgs/main/linux-64::python-fastjsonschema-2.20.0-py312h06a4308_0 
python-tzdata      pkgs/main/noarch::python-tzdata-2025.2-pyhd3eb1b0_0 
pytz               pkgs/main/linux-64::pytz-2025.2-py312h06a4308_0 
pyyaml             pkgs/main/linux-64::pyyaml-6.0.3-py312h591646f_0 
referencing        pkgs/main/linux-64::referencing-0.37.0-py312h06a4308_0 
reretry            conda-forge/noarch::reretry-0.11.8-pyhd8ed1ab_1 
rpds-py            pkgs/main/linux-64::rpds-py-0.28.0-py312h498d7c9_0 
six                pkgs/main/linux-64::six-1.17.0-py312h06a4308_0 
slack-sdk          pkgs/main/linux-64::slack-sdk-3.36.0-py312h06a4308_0 
slack_sdk          pkgs/main/linux-64::slack_sdk-3.36.0-py312h06a4308_0 
smart_open         pkgs/main/linux-64::smart_open-7.3.1-py312h06a4308_0 
smmap              pkgs/main/linux-64::smmap-5.0.2-py312h06a4308_0 
snakemake          bioconda/noarch::snakemake-9.13.7-hdfd78af_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-common-1.22.0-pyhd4c3c12_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-executor-plugins-9.3.9-pyhdfd78af_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-logger-plugins-2.0.0-pyhd4c3c12_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-report-plugins-1.3.0-pyhd4c3c12_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-scheduler-plugins-2.0.2-pyhd4c3c12_0 
snakemake-interfa~ bioconda/noarch::snakemake-interface-storage-plugins-4.2.3-pyhd4c3c12_0 
snakemake-minimal  bioconda/noarch::snakemake-minimal-9.13.7-pyhdfd78af_0 
tabulate           pkgs/main/linux-64::tabulate-0.9.0-py312h06a4308_0 
throttler          conda-forge/noarch::throttler-1.2.2-pyhd8ed1ab_0 
traitlets          pkgs/main/linux-64::traitlets-5.14.3-py312h06a4308_0 
ubiquerg           conda-forge/noarch::ubiquerg-0.8.0-pyhd8ed1ab_0 
veracitools        conda-forge/noarch::veracitools-0.1.3-py_0 
wrapt              pkgs/main/linux-64::wrapt-1.17.0-py312h5eee18b_0 
yaml               pkgs/main/linux-64::yaml-0.2.5-h7b6447c_0 
yte                conda-forge/noarch::yte-1.8.1-pyha770c72_0`
```

### Installed `snakefmt` in `base` `conda` environment

```shell
conda install snakefmt
```

The following NEW packages were INSTALLED:

```
black              pkgs/main/linux-64::black-24.10.0-py312h06a4308_0 
mypy_extensions    pkgs/main/linux-64::mypy_extensions-1.0.0-py312h06a4308_0 
pathspec           pkgs/main/linux-64::pathspec-0.12.1-py312h06a4308_1 
snakefmt           bioconda/noarch::snakefmt-0.11.1-pyhdfd78af_0
```

Since I found out about `conda run`, I don't need to install packages that I commonly use into the `OneOpes` or `psi4` environments. In the end I will just create another environment file for important things I used like `snakemake`. 

The `ipython` package and dependencies were removed from the `OneOpes` environment:

```shell
conda remove ipython backcall decorator jedi matplotlib-inline parso pexpect pickleshare prompt-toolkit ptyprocess pygments traitlets wcwidth
```

The `black` package and dependencies were removed from the `OneOpes` environment:

```shell
conda remove black click mypy_extensions pathspec platformdirs tomli typed-ast
```

### Added `snakemake` rules in [[psi4.smk]]

* `cif_to_pdb_neutralize` to convert the `CIF` files to `PDB` files, and minimize the geometries using the `GAFF` force field.
* `pdb_to_xyz` to convert the `PDB` files to `XYZ` files.
* `fill_psi4_input_template` to fill the `psi4` input template [[psi4_two_step_opt.j2]]. This rule uses the `XYZ` file coordinates produced by the `pdb_to_xyz` rule.

### Input template preparation

I created a jinja2 template for the geometry optimizations (B3LYP/6-31G(d) followed by HF/6-31G(d)) in the `input/templates` directory:

[[psi4_two_step_opt.j2]]

#### `Gaussian` Settings

[[G9.com]]
```run-bash
cat /home/brian-novak/Google_Drive/obsidian/Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/OneOpes_protocol/gaussian_results/G9_gaussian/G9.com
```

Looking at the `S6-G9` guest, the `Gaussian` input file [[G9.com]] indicates that the B3LYP minimization was performed in vacuum using the 6-31G(p, d) basis set ([[Is it possible to run psi4 with equivalent settings to the Gaussian settings in G1_2.com?]], [[Is 6-31G** in Gaussian equivalent to 6-31G(d,p) in psi4?]]). Nothing was constrained ([[2026-04-16 -- OneOPES_reproduction]]).

Looking at the `S8-G1` guest, the Gaussian input file [[G9_2.com]] indicates that a single point Hartree-Fock energy calculation was performed in implicit water using the 6-31G(p, d) basis set ([[Is it possible to run psi4 with equivalent settings to the Gaussian settings in G1_2.com?]], [[Is 6-31G** in Gaussian equivalent to 6-31G(d,p) in psi4?]], [[How do I use implicit water in psi4?]], [[Fix S matrix is not positive-definite! psi4 error]], [[Maximum Area Value for Psi4 PCM]], [[Resolving the Gauss' Theorem Nuclear ASC Error in Psi4 PCM Calculations]], [[What are the differences between the IEFPCM and CPCM solvers?]], [[Should I use a non-zero value for "correction" with the CPCM solver and water as the solvent?]], [[What are the default cavity parameters for SCRF in Gaussian 16?]], [[UA0 Radii for H, C, N, O and UA0 implementation in psi4]], [[2026-04-16 -- OneOPES_reproduction]]). 

[[G9_2.com]]
```run-bash
cat /home/brian-novak/Google_Drive/obsidian/Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/OneOpes_protocol/gaussian_results/G9_gaussian/G9_2.com
```

#### Stage 1 fitting

##### Equivalence groups

I needed to obtain lists of indices for equivalence groups of polar atoms for first stage `RESP` fitting. That was accomplished by using `VMD` with the `%i` format code. The indices were 1 based. The lists were:

```
[[24, 25, 26]]
```

#### Stage 2 fitting

##### Constrained charges

I needed to obtain a list of indices for atoms whose charges were constrained for second stage `RESP` fitting (polar atoms). That was accomplished by using `VMD` with the `%i` (index) format code. The indices were 0 based. The list was:

![[image-10.png]]

`[9, 23, 24, 25]`

##### Equivalence groups

I needed to obtain lists of indices for equivalence groups for second stage `RESP` fitting. That was accomplished by using `VMD` with the `%i` format code. The indices were 1 based. Note that the polar hydrogens were not included since their charges were fixed in stage 2 and equivalence was enforced in stage 1. See [[Treatment of Hydrogen Atoms and Equivalence Constraints in Two-Stage RESP Fitting]]. The lists were:

| ![[image-8.png\|300]]       | ![[image-9.png\|300]] |
| --------------------------- | --------------------- |
| 0-based indices in pictures |                       |

```
[2, 3]
[4, 5]
[6, 7]
[11, 12]
[13, 14, 15, 16]
[17, 18, 19, 20]
[21, 22]
```

#### Equivalence groups check

I checked the equivalence groups against [[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/OneOpes_protocol/OneOpes_input_files/CB8/CB8_S6-G9/0/topol.top]] line 1917 which has a 1-based index:

![[CB8_S6-G9_0_topol.top line 1917]]

```
2         c3      1    MOL     C2      2 -0.19280000  12.010000   ; qtot -0.313900
3         c3      1    MOL     C3      3 -0.19280000  12.010000   ; qtot -0.509300
```

```
4         c3      1    MOL     C4      4 -0.22750000  12.010000   ; qtot -0.723700
5         c3      1    MOL     C5      5 -0.22750000  12.010000   ; qtot -0.938100
```

```
6         c3      1    MOL     C6      6 0.06230000  12.010000   ; qtot -0.871000
7         c3      1    MOL     C7      7 0.06230000  12.010000   ; qtot -0.803900
```

```
11         hc      1    MOL     H1     11 0.06440000   1.008000   ; qtot -0.900500
12         hc      1    MOL     H2     12 0.06440000   1.008000   ; qtot -0.850300
```

```
13         hc      1    MOL     H3     13 0.08650000   1.008000   ; qtot -0.776700
14         hc      1    MOL     H4     14 0.08650000   1.008000   ; qtot -0.703100
15         hc      1    MOL     H5     15 0.08650000   1.008000   ; qtot -0.629500
16         hc      1    MOL     H6     16 0.08650000   1.008000   ; qtot -0.555900
```

```
17         hc      1    MOL     H7     17 0.09190000   1.008000   ; qtot -0.469500
18         hc      1    MOL     H8     18 0.09190000   1.008000   ; qtot -0.383100
19         hc      1    MOL     H9     19 0.09190000   1.008000   ; qtot -0.296700
20         hc      1    MOL    H10     20 0.09190000   1.008000   ; qtot -0.210300
```

```
21         hc      1    MOL    H11     21 0.06590000   1.008000   ; qtot -0.165400
22         hc      1    MOL    H12     22 0.06590000   1.008000   ; qtot -0.120500
```

```
24         zd      1    MOL    H14     24 0.33580000   1.008000   ; qtot 0.297800
25         zd      1    MOL    H15     25 0.33580000   1.008000   ; qtot 0.648800
26         zd      1    MOL    H16     26 0.33580000   1.008000   ; qtot 0.999800
```

### Running

#### Installed the `resp` package in `psi4` environment

I needed to install the [`resp` package](https://github.com/cdsgroup/resp) in the `psi4` `conda` environment:

```shell
conda install resp -c psi4
```

The version installed was:

```
Name                       Version          Build            Channel
resp                       1.0              pyh31278eb_0     psi4
```

#### Installed the `pytest` package in `psi4` environment

I also installed `pytest` in the `psi4` `conda` environment so I could test the `resp` package:

```shell
conda install pytest
```

The following NEW packages were INSTALLED:

```
iniconfig          pkgs/main/linux-64::iniconfig-2.1.0-py313h06a4308_0 
pluggy             pkgs/main/linux-64::pluggy-1.5.0-py313h06a4308_0 
pygments           pkgs/main/linux-64::pygments-2.19.2-py313h06a4308_0 
pytest             pkgs/main/linux-64::pytest-8.4.2-py313h06a4308_0
```

#### Tested the `resp` package

```shell
python -c "import resp, sys; sys.exit(resp.test('long'))"
```

```
================================================== test session starts ===================================================
platform linux -- Python 3.13.9, pytest-8.4.2, pluggy-1.5.0 -- /home/brian-novak/miniconda3/envs/psi4/bin/python
cachedir: .pytest_cache
rootdir: /home/brian-novak
collected 2 items                                                                                                        

../../../../../../../../../../miniconda3/envs/psi4/lib/python3.13/site-packages/resp/tests/test_resp.py::test_resp_1 PASSED [ 50%]
../../../../../../../../../../miniconda3/envs/psi4/lib/python3.13/site-packages/resp/tests/test_resp.py::test_resp_2 PASSED [100%]

=================================================== 2 passed in 2.91s ====================================================
```

#### Numerical problems

##### S matrix is not positive-definite! with implicit water

With the PCM settings below from [[HF_opt_implicit_water.j2]] using `psi4 1.10`, I got the error `S matrix is not positive-definite!` for ==all guests== even though `Area` was already high compared to `0.2` which is usually used ([[Fix S matrix is not positive-definite! psi4 error]], [[What are the default cavity parameters for SCRF in Gaussian 16?]]):

```
set {
    basis 6-31G(d,p)
    geom_maxiter 200
    opt_coordinates cartesian
    step_type nr
    dynamic_level 1
    scf_type pk
    pcm true
    pcm_scf_type total
}
pcm = {
    Units = Angstrom
    Medium {
        SolverType = IEFPCM #CPCM
        Solvent = Water
    }
    Cavity {
        RadiiSet = Bondi
        Type = GePol
        Scaling = True
        Area = 0.4
        Mode = Atoms
        Atoms = {{ element_list | default('[]') }}
        Radii = {{ radius_list | default('[]') }}
    }
}
```

Switching to `psi4 1.9.1` did not fix the issue. The problem appears to be the version of the `pcmsolver` package, and a possible solution is to switch to `psi4 1.7` ([[S matrix is not positive-definite errors with pcmsolver 1.2.3]]). 

However, you.com also gave me the wrong advice to increase the `Area` parameter to try to fix this problem ([[Fix S matrix is not positive-definite! psi4 error]]) when the `Area` parameter should have been decreased ([[Area Parameter Advice for "S Matrix is Not Positive-Definite" Errors in PCM]]). Therefore, I am first trying to reduce the `Area` parameter with `psi4 1.10` before trying `psi4 1.7`.  

Decreasing the `Area` parameter as low as `0.05` still gave the the S matrix is not positive-definite! error, so I am switching to `psi4 1.7` for Hatree-Fock optimizations in vacuum and implicit water, and still using `psi4 1.10` for the B3LYP optimization since it is easy to freeze all dihedrals (dihedrals have to be listed explicity in versions `< 1.10`).

##### Installed the `pyvista` package in a new `pyvista` environment for cavity visualization

Due to numerical errors ("S matrix is not positive-definite!" and "Absolute value of the relative difference between the Gauss' theorem and computed values of the total nuclear ASC higher than threshold") with implicit solvent, I tried to visualize the cavity used for numerical integration ([[Visualizing cavity.npz file]]). I installed `pyvista` in the  `psi4` `conda` environment:

```shell
conda create -n pyvista pyvista
```

```
The following NEW packages will be INSTALLED:

  _libgcc_mutex      pkgs/main/linux-64::_libgcc_mutex-0.1-main 
  _openmp_mutex      pkgs/main/linux-64::_openmp_mutex-5.1-1_gnu 
  aom                pkgs/main/linux-64::aom-3.12.1-h7934f7d_0 
  blas               pkgs/main/linux-64::blas-1.0-openblas 
  blosc              pkgs/main/linux-64::blosc-1.21.6-hf7d4471_0 
  brotlicffi         pkgs/main/linux-64::brotlicffi-1.2.0.0-py314h7354ed3_0 
  bzip2              pkgs/main/linux-64::bzip2-1.0.8-h5eee18b_6 
  c-ares             pkgs/main/linux-64::c-ares-1.34.5-hef5626c_0 
  ca-certificates    pkgs/main/linux-64::ca-certificates-2025.12.2-h06a4308_0 
  cairo              pkgs/main/linux-64::cairo-1.18.4-h44eff21_0 
  certifi            pkgs/main/linux-64::certifi-2026.01.04-py314h06a4308_0 
  cffi               pkgs/main/linux-64::cffi-2.0.0-py314h4eded50_1 
  charset-normalizer pkgs/main/linux-64::charset-normalizer-3.4.4-py314h06a4308_0 
  contourpy          pkgs/main/linux-64::contourpy-1.3.3-py314hdb19cb5_0 
  cycler             pkgs/main/linux-64::cycler-0.12.1-py314h06a4308_0 
  cyrus-sasl         pkgs/main/linux-64::cyrus-sasl-2.1.28-h1110e0f_3 
  dav1d              pkgs/main/linux-64::dav1d-1.2.1-h5eee18b_0 
  double-conversion  pkgs/main/linux-64::double-conversion-3.3.1-h6a678d5_0 
  expat              pkgs/main/linux-64::expat-2.7.3-h7354ed3_4 
  fmt                pkgs/main/linux-64::fmt-11.2.0-hca5f364_0 
  fontconfig         pkgs/main/linux-64::fontconfig-2.15.0-h2c49b7f_0 
  fonttools          pkgs/main/linux-64::fonttools-4.60.1-py314hee96239_0 
  freetype           pkgs/main/linux-64::freetype-2.13.3-h4a9f257_0 
  fribidi            pkgs/main/linux-64::fribidi-1.0.10-h7b6447c_0 
  gettext            pkgs/main/linux-64::gettext-0.21.0-hedfda30_2 
  gl2ps              pkgs/main/linux-64::gl2ps-1.4.2-h70c0345_1 
  graphite2          pkgs/main/linux-64::graphite2-1.3.14-h295c915_1 
  harfbuzz           pkgs/main/linux-64::harfbuzz-10.2.0-hdfddeaa_1 
  hdf4               pkgs/main/linux-64::hdf4-4.2.13-h3ca952b_2 
  hdf5               pkgs/main/linux-64::hdf5-1.14.5-h2b7332f_2 
  icu                pkgs/main/linux-64::icu-73.1-h6a678d5_0 
  idna               pkgs/main/linux-64::idna-3.11-py314h06a4308_0 
  jansson            pkgs/main/linux-64::jansson-2.14-h5eee18b_1 
  jpeg               pkgs/main/linux-64::jpeg-9f-h5ce9db8_0 
  jsoncpp            pkgs/main/linux-64::jsoncpp-1.9.6-hfbf14b3_0 
  kiwisolver         pkgs/main/linux-64::kiwisolver-1.4.9-py314h24d9097_0 
  lcms2              pkgs/main/linux-64::lcms2-2.17-heab6991_0 
  ld_impl_linux-64   pkgs/main/linux-64::ld_impl_linux-64-2.44-h153f514_2 
  lerc               pkgs/main/linux-64::lerc-4.0.0-h6a678d5_0 
  libaec             pkgs/main/linux-64::libaec-1.1.3-h6a678d5_0 
  libavif            pkgs/main/linux-64::libavif-1.3.0-h3539ee5_0 
  libboost           pkgs/main/linux-64::libboost-1.88.0-h9d9b81f_0 
  libcups            pkgs/main/linux-64::libcups-2.4.15-hbe4054b_0 
  libcurl            pkgs/main/linux-64::libcurl-8.17.0-hc93bc37_0 
  libdeflate         pkgs/main/linux-64::libdeflate-1.22-h5eee18b_0 
  libdrm             pkgs/main/linux-64::libdrm-2.4.124-h5eee18b_0 
  libegl             pkgs/main/linux-64::libegl-1.7.0-h5eee18b_2 
  libev              pkgs/main/linux-64::libev-4.33-h7f8727e_1 
  libevent           pkgs/main/linux-64::libevent-2.1.12-hdbd6064_1 
  libexpat           pkgs/main/linux-64::libexpat-2.7.3-h7354ed3_4 
  libffi             pkgs/main/linux-64::libffi-3.4.4-h6a678d5_1 
  libgcc             pkgs/main/linux-64::libgcc-15.2.0-h69a1729_7 
  libgcc-ng          pkgs/main/linux-64::libgcc-ng-15.2.0-h166f726_7 
  libgfortran        pkgs/main/linux-64::libgfortran-15.2.0-h166f726_7 
  libgfortran-ng     pkgs/main/linux-64::libgfortran-ng-15.2.0-h166f726_7 
  libgfortran5       pkgs/main/linux-64::libgfortran5-15.2.0-hc633d37_7 
  libgl              pkgs/main/linux-64::libgl-1.7.0-h5eee18b_2 
  libglib            pkgs/main/linux-64::libglib-2.84.4-h77a78f3_0 
  libglvnd           pkgs/main/linux-64::libglvnd-1.7.0-h5eee18b_2 
  libglx             pkgs/main/linux-64::libglx-1.7.0-h5eee18b_2 
  libgomp            pkgs/main/linux-64::libgomp-15.2.0-h4751f2c_7 
  libhwloc           pkgs/main/linux-64::libhwloc-2.12.1-default_hf1bbc79_1000 
  libiconv           pkgs/main/linux-64::libiconv-1.16-h5eee18b_3 
  libidn2            pkgs/main/linux-64::libidn2-2.3.8-hf80d704_0 
  libkrb5            pkgs/main/linux-64::libkrb5-1.21.3-h520c7b4_4 
  libllvm15          pkgs/main/linux-64::libllvm15-15.0.7-he89c38a_4 
  libmpdec           pkgs/main/linux-64::libmpdec-4.0.0-h5eee18b_0 
  libnetcdf          pkgs/main/linux-64::libnetcdf-4.9.3-h71f9cbe_0 
  libnghttp2         pkgs/main/linux-64::libnghttp2-1.67.1-h697f920_0 
  libogg             pkgs/main/linux-64::libogg-1.3.5-h27cfd23_1 
  libopenblas        pkgs/main/linux-64::libopenblas-0.3.30-h46f56fc_2 
  libopenjpeg        pkgs/main/linux-64::libopenjpeg-2.5.4-hee96239_1 
  libpciaccess       pkgs/main/linux-64::libpciaccess-0.18-h5eee18b_0 
  libpng             pkgs/main/linux-64::libpng-1.6.50-h2ed474d_0 
  libpq              pkgs/main/linux-64::libpq-17.6-ha51bf15_0 
  libsodium          pkgs/main/linux-64::libsodium-1.0.20-heac8642_0 
  libssh2            pkgs/main/linux-64::libssh2-1.11.1-h251f7ec_0 
  libstdcxx          pkgs/main/linux-64::libstdcxx-15.2.0-h39759b7_7 
  libstdcxx-ng       pkgs/main/linux-64::libstdcxx-ng-15.2.0-hc03a8fd_7 
  libtheora          pkgs/main/linux-64::libtheora-1.2.0-h32ad74f_1 
  libtiff            pkgs/main/linux-64::libtiff-4.7.1-h029b1ac_0 
  libunistring       pkgs/main/linux-64::libunistring-1.3-hb25bd0a_0 
  libuuid            pkgs/main/linux-64::libuuid-1.41.5-h5eee18b_0 
  libvorbis          pkgs/main/linux-64::libvorbis-1.3.7-h7b6447c_0 
  libwebp-base       pkgs/main/linux-64::libwebp-base-1.6.0-hb7bb969_0 
  libxcb             pkgs/main/linux-64::libxcb-1.17.0-h9b100fa_0 
  libxkbcommon       pkgs/main/linux-64::libxkbcommon-1.9.1-h69220b7_0 
  libxml2            pkgs/main/linux-64::libxml2-2.13.9-h2c43086_0 
  libzip             pkgs/main/linux-64::libzip-1.8.0-h6ac8c49_1 
  libzlib            pkgs/main/linux-64::libzlib-1.3.1-hb25bd0a_0 
  lmdb               pkgs/main/linux-64::lmdb-0.9.31-hb25bd0a_0 
  lz4-c              pkgs/main/linux-64::lz4-c-1.9.4-h6a678d5_1 
  matplotlib-base    pkgs/main/linux-64::matplotlib-base-3.10.7-py314h54cb298_0 
  mesalib            pkgs/main/linux-64::mesalib-25.1.5-h31e3550_0 
  mysql-common       pkgs/main/linux-64::mysql-common-9.3.0-h9e076cb_4 
  mysql-libs         pkgs/main/linux-64::mysql-libs-9.3.0-h6ecde68_4 
  ncurses            pkgs/main/linux-64::ncurses-6.5-h7934f7d_0 
  nlohmann_json      pkgs/main/linux-64::nlohmann_json-3.11.2-h6a678d5_0 
  numpy              pkgs/main/linux-64::numpy-2.3.5-py314hda7dee8_0 
  numpy-base         pkgs/main/linux-64::numpy-base-2.3.5-py314h5cadfd5_0 
  openldap           pkgs/main/linux-64::openldap-2.6.10-he9288cc_1 
  openssl            pkgs/main/linux-64::openssl-3.0.18-hd6dcaed_0 
  packaging          pkgs/main/linux-64::packaging-25.0-py314h06a4308_1 
  pcre2              pkgs/main/linux-64::pcre2-10.46-hf426167_0 
  pillow             pkgs/main/linux-64::pillow-12.0.0-py314h3b88751_1 
  pip                pkgs/main/noarch::pip-25.3-pyh0d26453_0 
  pixman             pkgs/main/linux-64::pixman-0.46.4-h7934f7d_0 
  platformdirs       pkgs/main/linux-64::platformdirs-4.5.0-py314h06a4308_0 
  pooch              pkgs/main/linux-64::pooch-1.8.2-py314h06a4308_0 
  proj               pkgs/main/linux-64::proj-9.3.1-h4591001_1 
  pthread-stubs      pkgs/main/linux-64::pthread-stubs-0.3-h0ce48e5_1 
  pycparser          pkgs/main/noarch::pycparser-2.21-pyhd3eb1b0_0 
  pyparsing          pkgs/main/linux-64::pyparsing-3.2.5-py314h06a4308_0 
  pysocks            pkgs/main/linux-64::pysocks-1.7.1-py314h06a4308_1 
  python             pkgs/main/linux-64::python-3.14.2-h90eec9f_101_cp314 
  python-dateutil    pkgs/main/linux-64::python-dateutil-2.9.0post0-py314h06a4308_2 
  python_abi         pkgs/main/linux-64::python_abi-3.14-2_cp314 
  pyvista            conda-forge/noarch::pyvista-0.46.4-pyhd8ed1ab_0 
  qtbase             pkgs/main/linux-64::qtbase-6.9.2-hd13baf8_5 
  readline           pkgs/main/linux-64::readline-8.3-hc2a1206_0 
  requests           pkgs/main/linux-64::requests-2.32.5-py314h06a4308_1 
  scooby             conda-forge/noarch::scooby-0.11.0-pyhd8ed1ab_0 
  six                pkgs/main/linux-64::six-1.17.0-py314h06a4308_0 
  spirv-tools        pkgs/main/linux-64::spirv-tools-2025.1-hdb19cb5_0 
  sqlite             pkgs/main/linux-64::sqlite-3.51.1-he0a8d7e_0 
  tbb                pkgs/main/linux-64::tbb-2022.3.0-h698db13_0 
  tk                 pkgs/main/linux-64::tk-8.6.15-h54e0aa7_0 
  typing-extensions  pkgs/main/linux-64::typing-extensions-4.15.0-py314h06a4308_0 
  typing_extensions  pkgs/main/linux-64::typing_extensions-4.15.0-py314h06a4308_0 
  tzdata             pkgs/main/noarch::tzdata-2025b-h04d1e81_0 
  urllib3            pkgs/main/linux-64::urllib3-2.6.3-py314h06a4308_0 
  utfcpp             pkgs/main/linux-64::utfcpp-3.2.1-h06a4308_0 
  vtk-base           pkgs/main/linux-64::vtk-base-9.5.2-py314h947d9a0_1 
  xcb-util           pkgs/main/linux-64::xcb-util-0.4.1-h5eee18b_2 
  xcb-util-cursor    pkgs/main/linux-64::xcb-util-cursor-0.1.5-h5eee18b_0 
  xcb-util-image     pkgs/main/linux-64::xcb-util-image-0.4.0-h5eee18b_2 
  xcb-util-keysyms   pkgs/main/linux-64::xcb-util-keysyms-0.4.1-h5eee18b_0 
  xcb-util-renderut~ pkgs/main/linux-64::xcb-util-renderutil-0.3.10-h5eee18b_0 
  xcb-util-wm        pkgs/main/linux-64::xcb-util-wm-0.4.2-h5eee18b_0 
  xkeyboard-config   pkgs/main/linux-64::xkeyboard-config-2.44-h382ed1a_1 
  xorg-libice        pkgs/main/linux-64::xorg-libice-1.1.2-h9b100fa_0 
  xorg-libsm         pkgs/main/linux-64::xorg-libsm-1.2.6-h9b100fa_0 
  xorg-libx11        pkgs/main/linux-64::xorg-libx11-1.8.12-h9b100fa_1 
  xorg-libxau        pkgs/main/linux-64::xorg-libxau-1.0.12-h9b100fa_0 
  xorg-libxdmcp      pkgs/main/linux-64::xorg-libxdmcp-1.1.5-h9b100fa_0 
  xorg-libxext       pkgs/main/linux-64::xorg-libxext-1.3.6-h9b100fa_0 
  xorg-libxfixes     pkgs/main/linux-64::xorg-libxfixes-6.0.1-h9b100fa_0 
  xorg-libxrandr     pkgs/main/linux-64::xorg-libxrandr-1.5.4-h9b100fa_0 
  xorg-libxrender    pkgs/main/linux-64::xorg-libxrender-0.9.12-h9b100fa_0 
  xorg-libxshmfence  pkgs/main/linux-64::xorg-libxshmfence-1.3.3-h9b100fa_0 
  xorg-libxxf86vm    pkgs/main/linux-64::xorg-libxxf86vm-1.1.6-h9b100fa_0 
  xorg-xorgproto     pkgs/main/linux-64::xorg-xorgproto-2024.1-h5eee18b_1 
  xz                 pkgs/main/linux-64::xz-5.6.4-h5eee18b_1 
  zlib               pkgs/main/linux-64::zlib-1.3.1-hb25bd0a_0 
  zstd               pkgs/main/linux-64::zstd-1.5.7-h11fc155_0
```

##### [[How do I fix the psi4 error - Could not converge geometry optimization in 50 iterations]]

* I had this problem with B3LYP and HF in vacuum optimizations for [[S6-G3.pdb]] and with HF in vacuum for [[S8-G4.pdb]]

###### Fix for [[S6-G3.pdb]]

* It was fixed by adding the following to the `set` block in the `psi4` template input files [[B3LYP_opt.j2]] & [[HF_opt_vacuum.j2]]:
```python
geom_maxiter 200
opt_coordinates cartesian
step_type nr
dynamic_level 1    
```
*  
	* These are perhaps not all necessary to fix the problem

###### Fix for [[S8-G4.pdb]]

* `geom_maxiter` was increased to `500`, but that did not fix the problem:
```python
geom_maxiter 500
opt_coordinates cartesian
step_type nr
dynamic_level 1
```
* I optimized the structure using `obabel` before running `B3LYP` optimization:
```shell
conda run -n OneOpes obabel structure_files/guests/S8-G4.orig.pdb -O input/structure_files/guests/S8-G4.pdb --minimize
```
* That still did not fix the problem, so I used `engine='geometric'`:
```python
energy_hf, wfn_hf = optimize('hf', engine='geometric', return_wfn=True)
```
which requried installation of the `geometric` package in the psi4 conda environment:
```shell
conda install geometric
```
```
The following NEW packages will be INSTALLED:

  geometric          conda-forge/noarch::geometric-1.1-pyhd8ed1ab_1
```

### Results

#### B3LYP Optimization

##### Comparison to structure from Gaussian after B3LYP Optimization

Visually, there is not much difference in the positions of the non-hydrogen atoms in the structures. | [[2026-04-21]]
![[Host-Guest Binding Free Energies a la Carte - An Automated OneOPES Protocol -- Reproduction of results-20260421194824301.png|400]]

The non-hydrogen atom RMSD is 0.0125 Å ([[psi4_gaussian_alignment_rmsd.txt]]). | [[2026-04-21]]

#### Vacuum

##### First stage charges

[[resp_stage1_vacuum.txt]] | [[2026-03-28]]

Atoms 24, 25, & 26 have the same charge, so the equivalence group definition worked.

##### Second stage charges

[[resp_charges_vacuum.txt]] | [[2026-03-28]]

Atoms 10, 24, 25, 26 had the same charges as in stage 1, so they were successfully constrained. Atoms 2, 3; 4, 5; 6, 7; 11, 12; 13, 14, 15, 16; 17, 18, 19, 20; and 
21, 22 had the same charges so the equivalence group definitions worked correctly. 

#### Implicit water

##### Area = 0.9

From [[HF_opt_implicit_water.j2]]: | [[2026-03-28]]
```
pcm = {
    Units = Angstrom
    Medium {
        SolverType = IEFPCM #CPCM
        Solvent = Water
    }
    Cavity {
        RadiiSet = Bondi
        Type = GePol
        Scaling = True
        Area = 0.9
        Mode = Atoms
        Atoms = {{ element_list | default('[]') }}
        Radii = {{ radius_list | default('[]') }}
    }
}
```

###### First stage charges

[[resp_stage1_implicit_water.txt]] | [[2026-03-28]]

###### Second stage charges

[[resp_charges_implicit_water.txt]] | [[2026-03-28]]

##### Area = 1.0

From [[HF_opt_implicit_water.j2]]: | [[2026-03-28]]
```
pcm = {
    Units = Angstrom
    Medium {
        SolverType = IEFPCM #CPCM
        Solvent = Water
    }
    Cavity {
        RadiiSet = Bondi
        Type = GePol
        Scaling = True
        Area = 1.0
        Mode = Atoms
        Atoms = {{ element_list | default('[]') }}
        Radii = {{ radius_list | default('[]') }}
    }
}
```

##### Comparison of Area = 0.9 and Area = 1.0 charges

The Area parameter has very little effect on the partial charges. In the plot below, Charge Difference 1 refers to the first stage RESP fit, and Charge Difference 2 refers to the second stage RESP fit. | [[2026-03-29]]
 
 ![[charge_difference_area1.0_minus_0.9.png|The Area parameter has very little effect on the partial charges]]  | [[2026-03-29]]

#### Charges from topol.top file used for [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol]]

[[Career/research/reviews/Host–Guest_Binding_Free_Energies_a_la_Carte_An_Automated_OneOPES_Protocol/OneOpes_protocol/OneOpes_input_files/CB8/CB8_S6-G9/0/topol.top]] line 1916 | [[2026-03-28]]

#### Comparison of partial charges (Area = 0.9)

In the plot below Implicit Water Charges 1 refers to first stage RESP fitting and Implicit Water Charges 2 refers to 2nd stage RESP fitting. | [[2026-03-29]]

[[compare_charges.py]] | [[2026-03-28]]
![[charge_comparison_area0.9.png]] | [[2026-03-28]]

The RESP charges (after stage 1 or stage 2) obtained with psi4 are not very close to those from [[Host–Guest Binding Free Energies à la Carte - An Automated OneOPES Protocol]] using Gaussian 16.