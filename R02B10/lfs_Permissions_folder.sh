RES=R02B10
EXPNAME="DYAMOND_${RES}L120"
EXPDIR="${SCRATCH}/DYAMOND_experiments/${EXPNAME}_main"

export EXPDIR="${SCRATCH}/DYAMOND_experiments/${EXPNAME}_main"
for ((k=1; k<=15; k++)); do
    outdir="${EXPDIR}/out_${k}"
    mkdir -p "${outdir}"
    lfs setstripe -i 0 -c 20 ${outdir}
done
