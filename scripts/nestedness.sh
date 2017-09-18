#!/bin/bash

sIODir=$HOME/Documents/Research/Projects/EMP_Nestedness

sDataDir=$sIODir/data
sJavaDir=$sIODir/bin

sOutDir=$sIODir/results/subset_1
sBiomPath=$sDataDir/revision_subsets/emp_deblur_90bp.modMapping1.subset_2k.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir

exit

bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

sOutDir=$sIODir/results/subset_2
sBiomPath=$sDataDir/revision_subsets/emp_deblur_90bp.modMapping2.subset_2k.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

sOutDir=$sIODir/results/subset_3
sBiomPath=$sDataDir/revision_subsets/emp_deblur_90bp.modMapping3.subset_2k.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

sOutDir=$sIODir/results/subset_4
sBiomPath=$sDataDir/revision_subsets/emp_deblur_90bp.modMapping4.subset_2k.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

sOutDir=$sIODir/results/subset_5
sBiomPath=$sDataDir/revision_subsets/emp_deblur_90bp.modMapping5.subset_2k.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

#running 1% subset analysis
sOutDir=$sIODir/results/1_percent
sBiomPath=$sDataDir/Global.Global2000Subset.BacteriaSubset1.EMP.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

#running 5% subset analysis
sOutDir=$sIODir/results/5_percent
sBiomPath=$sDataDir/Global.Global2000Subset.BacteriaSubset5.EMP.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

#running 10% subset analysis
sOutDir=$sIODir/results/10_percent
sBiomPath=$sDataDir/Global.Global2000Subset.BacteriaSubset10.EMP.biom
mkdir -p $sOutDir
#bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir

#running full analysis
sOutDir=$sIODir/results/all
sBiomPath=$sDataDir/Global.Global2000Subset.Bacteria.EMP.biom
mkdir -p $sOutDir
bash $sIODir/scripts/nestedness_graphs.sh $sBiomPath $sOutDir $sIODir $sJavaDir
bash $sIODir/scripts/nestedness_statistics.sh $sBiomPath $sOutDir $sIODir $sJavaDir
