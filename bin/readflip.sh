#!/bin/sh

name=$1
echo $name

fn=$(basename -- $name)
fn="${fn%_*_*.*.*}"
echo $fn
samtools view -@ 32 -h -b -f 0x0040 ${name} > ${name}.R1
samtools view -@ 32 -h -b -f 0x0080 ${name} > ${name}.R2
genome=hg19
bedtools genomecov -bg -split -strand - -ibam ${name}.R1 -g $genome | bedtools sort -i - > ${fn}.r1.pos
bedtools genomecov -bg -split -strand + -ibam ${name}.R1 -g $genome | awk -F '\t' -v OFS='\t' '{ $4 = - $4 ; print $0 }' | bedtools sort -i - > ${fn}.r1.neg
bedtools genomecov -bg -split -strand + -ibam ${name}.R2 -g $genome > ${fn}.r2.pos
bedtools genomecov -bg -split -strand - -ibam ${name}.R2 -g $genome | awk -F '\t' -v OFS='\t' '{ $4 = - $4 ; print $0 }' | bedtools sort -i - > ${fn}.r2.neg
bedtools unionbedg -i ${fn}.r1.pos ${fn}.r2.pos | awk -F '\t' '{OFS="\t"; print $1,$2,$3,$4+$5;}' - > ${fn}.pos.BedGraph
bedtools unionbedg -i ${fn}.r1.neg ${fn}.r2.neg | awk -F '\t' '{OFS="\t"; print $1,$2,$3,$4+$5;}' - > ${fn}.neg.BedGraph
cat ${fn}.pos.BedGraph ${fn}.neg.BedGraph | bedtools sort -i - > ${fn}.BedGraph

samtools view -@ 8 -F 0x904 -c ${name} > ${fn}.millionsmapped
python /fh/scratch/delete30/blancomelo_d/RNAseq_pipeline/RNAseq_NextFlow/bin/rcc.py ${fn}.BedGraph ${fn}.millionsmapped ${fn}.rcc.BedGraph
igvtools toTDF ${fn}.rcc.BedGraph ${fn}.tdf /fh/scratch/delete30/blancomelo_d/RNAseq_pipeline/ref/hg19.chrom.sizes

