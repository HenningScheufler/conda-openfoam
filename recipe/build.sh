#!/bin/bash

export FOAM_DIR_NAME="${SRC_DIR}/OpenFOAM-${PKG_VERSION}"

#   source foam dot file throws error if not compiled
sed -i 's/\$WM_PROJECT_DIR\/platforms\/\$WM_OPTIONS/\$\{PREFIX\}/g' ${FOAM_DIR_NAME}/etc/config.sh/settings
source "${FOAM_DIR_NAME}/etc/bashrc" || true

#
echo "cFLAGS += -I ${BUILD_PREFIX}/include" >> "${FOAM_DIR_NAME}/wmake/rules/linux64Gcc/c"
echo "c++FLAGS += -I ${BUILD_PREFIX}/include" >> "${FOAM_DIR_NAME}/wmake/rules/linux64Gcc/c++"

# remove Allwmake falsely sets the headers to the system
rm "${FOAM_DIR_NAME}/applications/utilities/mesh/manipulation/setSet/Allwmake"
# Allwmake sets wrong flags
sed -i 's/petsc4Foam\/Allwmake \$\*/\wmake libso petsc4Foam/g' ${FOAM_DIR_NAME}/modules/external-solver/src/Allwmake
# have_scotch metis does not set the env variable correctly
export DECOMPOSE_DIR=${FOAM_DIR_NAME}/src/parallel/decompose
sed -i 's/if have_kahip/if true/g' ${DECOMPOSE_DIR}/Allwmake
sed -i 's/if have_metis/if true/g' ${DECOMPOSE_DIR}/Allwmake
sed -i 's/if have_scotch/if true/g' ${DECOMPOSE_DIR}/Allwmake

sed -i 's/if have_scotch/if true/g' ${DECOMPOSE_DIR}/Allwmake-mpi
sed -i 's/if have_ptscotch/if true/g' ${DECOMPOSE_DIR}/Allwmake-mpi

# modify include path
sed -i 's/\$(METIS_INC_DIR)/.\/lnInclude/g' ${DECOMPOSE_DIR}/metisDecomp/Make/options
sed -i 's/\$(KAHIP_INC_DIR)/.\/lnInclude/g' ${DECOMPOSE_DIR}/kahipDecomp/Make/options
sed -i 's/\$(SCOTCH_INC_DIR)/.\/lnInclude/g' ${DECOMPOSE_DIR}/scotchDecomp/Make/options

#   compile openfoam
${FOAM_DIR_NAME}/Allwmake -j -q 8 -l

#   install
echo "Installing ..."

cd ${FOAM_DIR_NAME}
#copy header in the include folder
for f in $(find . -type d -name lnInclude)
do
    mkdir -p  $(dirname ${PREFIX}/include/OpenFOAM-${PKG_VERSION}/${f})
    cp -Lr ${f} $(dirname ${PREFIX}/include/OpenFOAM-${PKG_VERSION}/${f})
done

# copy config and script files
mkdir -p  ${PREFIX}/etc/OpenFOAM-${PKG_VERSION}/
cp -r etc ${PREFIX}/etc/OpenFOAM-${PKG_VERSION}/ 
cp -r bin ${PREFIX}/etc/OpenFOAM-${PKG_VERSION}/

#   activation and deactivation scripts
for SCRIPT_NAME in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${SCRIPT_NAME}.d"
    cp "${RECIPE_DIR}/openfoam_${SCRIPT_NAME}.sh" "${PREFIX}/etc/conda/${SCRIPT_NAME}.d/openfoam_${SCRIPT_NAME}.sh"
done