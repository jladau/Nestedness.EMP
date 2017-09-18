#!/bin/bash

sIODir=$3
sOutputDir=$2
sBiomPath=$1
sJavaDir=$4
rgsTaxa=(phylum class order family genus otu)
sEmpoField=empo_2
rgsEmpoCategories=(Animal Non-saline Saline Plant)

iTaxa=${#rgsTaxa[@]}
iTaxa=$((iTaxa-1))
iEmpoCategories=${#rgsEmpoCategories[@]}
iEmpoCategories=$((iEmpoCategories-1))

cd $sIODir
rm -rf $sIODir/temp.*.*

#loading sample subsets
java -cp $sJavaDir/Utilities.jar edu.ucsf.BIOM.PrintMetadata.PrintMetadataLauncher \
--sDataPath=$sBiomPath \
--sOutputPath=$sIODir/temp.0.csv \
--sAxis=sample

sqlite3 temp.1.sql ".import $sIODir/temp.0.csv tbl1"
for i in $(seq 0 $iEmpoCategories)
do
	sEmpo=${rgsEmpoCategories[i]}	
	sqlite3 temp.1.sql "select sample from tbl1 where $sEmpoField='$sEmpo';" | tail -n+2 > temp.$sEmpo.csv
done

#intializing merged output
echo 'GRAPH_EMPO,GRAPH_TAXON,SAMPLE_RANK,OBSERVATION_RANK,SAMPLE_ID,OBSERVATION_ID,empo_3,METADATA_NUMERIC_CODE' > temp.2.csv

#looping through taxa, subsets
for i in $(seq 0 $iTaxa)
do
	
	sTaxonRank=${rgsTaxa[i]}	
	
	for j in $(seq 0 $iEmpoCategories)
	do

		sEmpo=${rgsEmpoCategories[j]}	

		echo 'Analyzing '$sTaxonRank', '$sEmpo'...'		
		java -cp $sJavaDir/Autocorrelation.jar edu.ucsf.Nestedness.Grapher.GrapherLauncher \
		--sSamplesToKeepPath=$sIODir/temp.$sEmpo.csv \
		--sBIOMPath=$sBiomPath \
		--bNormalize=false \
		--sTaxonRank=$sTaxonRank \
		--sOutputPath=$sOutputDir/graphs.$sTaxonRank.$sEmpo.csv \
		--rgsSampleMetadataFields=empo_3

		exit

		#sending to merged output
		tail -n+2 $sOutputDir/graphs.$sTaxonRank.$sEmpo.csv | sed "s|^|$sEmpo\,$sTaxonRank\,|g" >> temp.2.csv
	done
done

#looping through taxa, all samples
for i in $(seq 0 $iTaxa)
do
	
	sTaxonRank=${rgsTaxa[i]}	
	
	echo 'Analyzing '$sTaxonRank', all...'

	java -cp $sJavaDir/Autocorrelation.jar edu.ucsf.Nestedness.Grapher.GrapherLauncher \
	--sBIOMPath=$sBiomPath \
	--bNormalize=false \
	--sTaxonRank=$sTaxonRank \
	--sOutputPath=$sOutputDir/graphs.$sTaxonRank.allsamples.csv \
	--rgsSampleMetadataFields=empo_3

	#sending to merged output
	tail -n+2 $sOutputDir/graphs.$sTaxonRank.allsamples.csv | sed "s|^|allsamples\,$sTaxonRank\,|g" >> temp.2.csv
done

#converting merged output to sqlite database
sqlite3 $sOutputDir/graphs.sql ".import $sIODir/temp.2.csv tblGraphs"

#cleaning up
rm $sOutputDir/*.csv
rm $sIODir/temp.*.*

