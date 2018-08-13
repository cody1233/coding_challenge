#!/bin/bash

#This script takes a VCF file as input to annotate it with information from the ExAC database
#Usage: Bash vcf_annotation.sh <INPUT VCF FILE>
#Check if VCF file is provided
vcf=$1

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

#Convert VCF file to ANNOVAR input file format
./convert2annovar.pl -format vcf4 ${vcf} -outfile annovar.avinput -includeinfo
#Download ExAC database
./annotate_variation.pl -downdb -webfrom annovar -build hg19 exac03 humandb/
#Download RefGene database
./annotate_variation.pl -downdb -webfrom annovar -build hg19 refGene humandb/
#Create annotated vcf with ExAC allele frequencies and variant types
./table_annovar.pl annovar.avinput humandb/ -buildver hg19 -out annotation -protocol refGene,exac03 -operation g,f
#Extract Read Depth, Number of Reads Supporting the Variant, and Percentage of Reads supporting the Variant vs Supporting Reference Reads from ANNOVAR input file
cut -f 13 annovar.avinput | awk -F \; '{print $8, $33, $30, $10, $4}' | awk '{gsub(/[^0-9. ]/,"")}1' | awk '{print $1 "\t" $2 + $3 "\t" $4 "\t" $5}' > vcf_information.txt
#Create header for VCF information file
echo -e 'Read Depth\tNumber of Reads Supporting the Variant\tPercentage of Reads Supporting the Variant vs Supporting Reference Reads\tAlternate Allele Frequency' > header.txt
#Add header to VCF information file
cat header.txt vcf_information.txt > exac_header.txt
#combine VCF information with ANNOVAR output 
paste annotation.hg19_multianno.txt exac_header.txt > final_${vcf}.txt

#remove unneeded files
rm exac_header.txt
rm vcf_information.txt
rm header.txt
rm annovar.avinput

