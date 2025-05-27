RES=R02B10
EXPNAME="DYAMOND_${RES}L120"
EXPDIR="${SCRATCH}/DYAMOND_experiments/${EXPNAME}_main"

export EXPDIR="${SCRATCH}/DYAMOND_experiments/${EXPNAME}_main"
for ((k=2; k<=14; k++)); do
    outdir="${EXPDIR}/out_${k}"
    mkdir -p "${outdir}"
    lfs setstripe -i 0 -c 20 ${outdir}
done


#Mannually do this

mkdir -p ${EXPDIR}/out_1_1
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_1_1
mkdir -p ${EXPDIR}/out_1_2
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_1_2
mkdir -p ${EXPDIR}/out_1_3
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_1_3
mkdir -p ${EXPDIR}/out_1_4
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_1_4
mkdir -p ${EXPDIR}/out_1_5
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_1_5



mkdir -p ${EXPDIR}/out_15_1
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_1
mkdir -p ${EXPDIR}/out_15_2
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_2
mkdir -p ${EXPDIR}/out_15_3
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_3
mkdir -p ${EXPDIR}/out_15_4
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_4
mkdir -p ${EXPDIR}/out_15_5
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_5
mkdir -p ${EXPDIR}/out_15_6
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_6
mkdir -p ${EXPDIR}/out_15_7
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_7
mkdir -p ${EXPDIR}/out_15_8
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_8
mkdir -p ${EXPDIR}/out_15_9
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_9
mkdir -p ${EXPDIR}/out_15_10
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_10
mkdir -p ${EXPDIR}/out_15_11
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_11
mkdir -p ${EXPDIR}/out_15_12
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_12
mkdir -p ${EXPDIR}/out_15_13
lfs setstripe -i 0 -c 20 ${EXPDIR}/out_15_13
