
## run

run from this project root with conda build or with mambabuild

```bash
conda build receipe -c conda-forge
or
mamba mambabuild recipe/ -c conda-forge --keep-old-work --dirty > log 2>&1
```

## install 

conda install -c ${CONDA_PREFIX}/conda-bld/ openfoam

# debug 

navigate in the ${CONDA_PREFIX}/conda-bld/ into openfoam-{number}/work and source the build_env_setup.sh 