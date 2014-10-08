#!/bin/sh

## Usage
# sh step4-mergeResults.sh brainspan run1-v0.99.6
# sh step4-mergeResults.sh stem run1-v0.99.6

# Define variables
EXPERIMENT=$1
SHORT="derM-${EXPERIMENT}"
PREFIX=$2

# Directories
ROOTDIR=/dcs01/lieber/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/derAnalysis

# Construct shell files
outdir="${PREFIX}"
sname="${SHORT}.${PREFIX}"
echo "Creating script ${sname}"
cat > ${WDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=100G,h_vmem=200G,h_fsize=10G
#$ -N ${sname}
#$ -hold_jid derA-${EXPERIMENT}.${PREFIX}.chr*

echo "**** Job starts ****"
date

mkdir -p ${WDIR}/${outdir}/logs

# merge results
cd ${WDIR}
module load R/3.1.x
Rscript -e "library(derfinder); load('/dcs01/lieber/ajaffe/Brain/derRuns/derfinderExample/derGenomicState/GenomicState.Hsapiens.UCSC.hg19.knownGene.Rdata'); load('${WDIR}/${PREFIX}/chr1/optionsStats.Rdata'); mergeResults(prefix = '${PREFIX}', genomicState = GenomicState.Hsapiens.UCSC.hg19.knownGene[['fullGenome']], optionsStats = optionsStats); Sys.time(); proc.time(); devtools::session_info()"

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/${outdir}/logs/

echo "**** Job ends ****"
date
EOF
call="qsub .${sname}.sh"
echo $call
$call
