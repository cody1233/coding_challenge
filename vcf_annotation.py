import os
import sys

#This script takes a VCF file as input to annotate it with information from the ExAC database
#Usage: Python vcf_annotation.py <INPUT VCF FILE>

vcf=sys.argv[1]

#Convert VCF file to ANNOVAR input file format
os.system("./convert2annovar.pl -format vcf4 %s -outfile annovar.avinput -includeinfo" % vcf)
#Download ExAC database
os.system("./annotate_variation.pl -downdb -webfrom annovar -build hg19 exac03 humandb/")
#Download RefGene database
os.system("./annotate_variation.pl -downdb -webfrom annovar -build hg19 refGene humandb/") 
#Create annotated vcf with ExAC allele frequencies
os.stystem("./table_annovar.pl example.avinput humandb/ -buildver hg19 -out annotation -protocol refGene,exac03 -operation gx,f")
#Extract Read Depth, Number of Reads Supporting the Variant, and Percentage of Reads supporting the Variant vs Supporting Reference Reads from ANNOVAR input file
os.system("cut -f 13 annovar.avinput | awk -F \; '{print $8, $33, $30, $10}' | awk '{gsub(/[^0-9. ]/,"")}1' | awk '{print $1, $2 + $3, $4}' > vcf_information.txt") 
