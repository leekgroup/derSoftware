## Usage
# sh step9-summaryInfo.sh brainspan run4-v1.0.10
# sh step9-summaryInfo.sh stem run4-v1.0.10
# sh step9-summaryInfo.sh snyder run3-v1.0.10
# sh step9-summaryInfo.sh hippo run3-v1.0.10

# Define variables
EXPERIMENT=$1
PREFIX=$2
SHORT="summInfo-${EXPERIMENT}"

# Directories
ROOTDIR=/dcs01/lieber/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}

# Construct shell files
sname="${SHORT}.${PREFIX}"
echo "Creating script ${sname}"

if [[ "${EXPERIMENT}" == "stem" ]]
then
    EXAMPLES='c("potentially new alternative transcript" = 1, "coverage dips" = 4, "and a long region matching DERs with known exons" = 5)'
elif [[ "${EXPERIMENT}" == "brainspan" ]]
then
    EXAMPLES=''
elif [[ "${EXPERIMENT}" == "snyder" ]]
then
    EXAMPLES='c("coverage dips" = 1, "alternative splicing" = 7, "and less pronounced coverage dips" = 13)'
elif [[ "${EXPERIMENT}" == "hippo" ]]
then
    EXAMPLES='c("a coverage dip" = 3, "the complex relationship with annotation" = 4, "and a potentially extended UTR" = 8)'
else
    echo "Specify a valid experiment: stem, brainspan, snyder, or hippo"
fi

WDIR=${MAINDIR}/summaryInfo/${PREFIX}

cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=50G,h_vmem=200G,h_fsize=10G
#$ -N ${sname}
#$ -hold_jid derM-${EXPERIMENT}.${PREFIX}
echo "**** Job starts ****"
date

# Make logs directory
mkdir -p ${WDIR}/logs

# Compare DERs vs regionMatrix
cd ${WDIR}
module load R/3.1.x
Rscript ${ROOTDIR}/step9-summaryInfo.R -s '${EXPERIMENT}' -r '${PREFIX}' -p '${EXAMPLES}' -v TRUE

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call