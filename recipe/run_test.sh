

cp -r ${RECIPE_DIR}/tests .
cd tests

cd damBreak
./Allrun-runParallel
./Allclean
cd ..