#!/bin/bash

sIODir=$3
sOutputDir=$2
sBiomPath=$1
sJavaDir=$4
rgsTaxa=(phylum class order family genus otu)
sEmpoField=empo_2
rgsEmpoCategories=(Animal Nonsaline Saline Plant All)
rgsModes=(overall)
rgsAxes=(sample observation)
rgsNullModels=(equiprobablefixed fixedequiprobable)

iTaxa=${#rgsTaxa[@]}
iTaxa=$((iTaxa-1))
iEmpoCategories=${#rgsEmpoCategories[@]}
iEmpoCategories=$((iEmpoCategories-1))
iModes=0
iAxes=1
iNullModels=1

cd $sIODir
rm -rf $sIODir/temp.*.*

#loading subsets of samples
java -cp $sJavaDir/Utilities.jar edu.ucsf.BIOM.PrintMetadata.PrintMetadataLauncher \
--sBIOMPath=$sBiomPath \
--sAxis=sample \
--sOutputPath=$sIODir/temp.3.csv

sqlite3 $sIODir/temp.4.sql ".import $sIODir/temp.3.csv tbl1"
sqlite3 $sIODir/temp.4.sql "select sample from tbl1 where empo_2='Animal'" | tail -n+3 > $sIODir/temp.Animal.csv
sqlite3 $sIODir/temp.4.sql "select sample from tbl1 where empo_2='Non-saline'" | tail -n+3 > $sIODir/temp.Nonsaline.csv
sqlite3 $sIODir/temp.4.sql "select sample from tbl1 where empo_2='Saline'" | tail -n+3 > $sIODir/temp.Saline.csv
sqlite3 $sIODir/temp.4.sql "select sample from tbl1 where empo_2='Plant'" | tail -n+3 > $sIODir/temp.Plant.csv
sqlite3 $sIODir/temp.4.sql "select sample from tbl1" | tail -n+3 > $sIODir/temp.All.csv

#intializing output
echo 'EMPO_SUBSET,AXIS,TAXONOMIC_LEVEL,NULL_MODEL,GRAPH_ID,GRAPH_EDGE_COUNT,NODF_OBSERVED,NODF_NULL_MEAN,NODF_NULL_STDEV,NODF_SES' > $sIODir/temp.2.csv

for i in $(seq 0 $iAxes)
do
	sAxis=${rgsAxes[i]}
	sNullModel=${rgsNullModels[i]}
	for j in $(seq 0 $iModes)
	do
		sMode=${rgsModes[j]}
		for k in $(seq 0 $iTaxa)
		do
			sTaxon=${rgsTaxa[k]}
			for m in $(seq 0 $iEmpoCategories)
			do
				sEmpoCategory=${rgsEmpoCategories[m]}
	
				#loading comparisons
				echo 'Loading comparisons...'
				java -Xmx5g -cp $sJavaDir/Autocorrelation.jar edu.ucsf.Nestedness.ComparisonSelector.ComparisonSelectorLauncher \
				--sBIOMPath=$sBiomPath \
				--sOutputPath=$sIODir/temp.0.csv \
				--bNormalize=false \
				--sTaxonRank=$sTaxon \
				--rgsSampleMetadataFields=$sEmpoField \
				--iRandomSeed=1234 \
				--sComparisonMode=$sMode \
				--iNestednessPairs=250 \
				--sSamplesToKeepPath=$sIODir/temp.$sEmpoCategory.csv \
				--sNestednessAxis=$sAxis \
				--iPrevalenceMinimum=1

				#running analysis
				echo 'Running analysis...'
				java -cp $sJavaDir/Autocorrelation.jar edu.ucsf.Nestedness.Calculator.CalculatorLauncher \
				--sBIOMPath=$sBiomPath \
				--sOutputPath=$sIODir/temp.1.csv \
				--bNormalize=false \
				--sTaxonRank=$sTaxon \
				--sComparisonsPath=$sIODir/temp.0.csv \
				--iNullModelIterations=10000 \
				--bOrdered=false \
				--sNestednessAxis=$sAxis \
				--sSamplesToKeepPath=$sIODir/temp.$sEmpoCategory.csv \
				--sNestednessNullModel=$sNullModel \
				--iPrevalenceMinimum=1 \
				--bSimulate=false

				#merging output
				tail -n+2 $sIODir/temp.1.csv  | sed "s|^|$sEmpoCategory\,$sAxis\,$sTaxon\,$sNullModel\,|g" >> $sIODir/temp.2.csv
			done
		done
	done
done

#sending results to sql database
rm -f $sOutputDir/statistics.sql
sqlite3 $sOutputDir/statistics.sql ".import $sIODir/temp.2.csv tbl1"

#extracting data for graphing
sqlite3 $sOutputDir/statistics.sql "select TAXONOMIC_LEVEL, EMPO_SUBSET, NODF_SES from tbl1 where axis='sample' and null_model='equiprobablefixed';" | tail -n+2 > $sOutputDir/statisticsgraph.ses.csv

sed -i "s|^TAXONOMIC_LEVEL|TAXONOMIC_LEVEL_RANK\,TAXONOMIC_LEVEL|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|phylum|1\,phylum|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|class|2\,class|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|order|3\,order|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|family|4\,family|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|genus|5\,genus|g" $sOutputDir/statisticsgraph.ses.csv
sed -i "s|otu|6\,otu|g" $sOutputDir/statisticsgraph.ses.csv

java -cp $sJavaDir/Utilities.jar edu.ucsf.FlatFileToPivotTable.FlatFileToPivotTableLauncher \
--sValueHeader=NODF_SES \
--rgsExpandHeaders=EMPO_SUBSET \
--sDataPath=$sOutputDir/statisticsgraph.ses.csv \
--sOutputPath=$sOutputDir/statisticsgraph.ses.csv

sqlite3 $sOutputDir/statistics.sql "select TAXONOMIC_LEVEL, EMPO_SUBSET, NODF_OBSERVED from tbl1 where axis='sample' and null_model='equiprobablefixed';" | tail -n+2 > $sOutputDir/statisticsgraph.raw.csv

sed -i "s|^TAXONOMIC_LEVEL|TAXONOMIC_LEVEL_RANK\,TAXONOMIC_LEVEL|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|phylum|1\,phylum|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|class|2\,class|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|order|3\,order|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|family|4\,family|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|genus|5\,genus|g" $sOutputDir/statisticsgraph.raw.csv
sed -i "s|otu|6\,otu|g" $sOutputDir/statisticsgraph.raw.csv

java -cp $sJavaDir/Utilities.jar edu.ucsf.FlatFileToPivotTable.FlatFileToPivotTableLauncher \
--sValueHeader=NODF_OBSERVED \
--rgsExpandHeaders=EMPO_SUBSET \
--sDataPath=$sOutputDir/statisticsgraph.raw.csv \
--sOutputPath=$sOutputDir/statisticsgraph.raw.csv

#cleaning up
rm $sIODir/temp.*.*
