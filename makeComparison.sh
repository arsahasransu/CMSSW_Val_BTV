#!/bin/bash
set -e
shopt -s extglob

#############################################################

title="10_1_0_pre3 validation"
valrel=1010pre3
refrel=1010pre2
workdir=/afs/cern.ch/user/s/swertz/work/public/BTagValidation/
valdir=10_1_0_pre3
outdir=${valdir}
refdir=10_1_0_pre2
LIST="TTbar:FullSim TTbar:FullSim_PU25ns TTbar:FastSim TTbar:FastSim_PU25ns"
#export RUN_ON_DATA=True

#############################################################

VALPATH=${workdir}/CMSSW_${valdir}/src/Validation/RecoB/test
REFPATH=${workdir}/CMSSW_${refdir}/src/Validation/RecoB/test
PLOTTER=../../../../../../Validation-Tools/plotProducer/scripts/plotFactory.py
PREFIX=BTagRelVal

echo "<h1> ${title} </h1>" >> index.html
echo "${valrel} versus ${refrel} </br>" >> index.html

for SAMPLE in $LIST
do
    SAMPLENAME=`echo "$SAMPLE" | tr ':' ' ' | awk '{print $1}'`
    SAMPLETYPE=`echo "$SAMPLE" | tr ':' ' ' | awk '{print $2}'`

    mkdir ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}
    mkdir ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}_lowLevelVariables

    cd ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}
    ${PLOTTER} -b -f ${VALPATH}/${PREFIX}_${SAMPLENAME}_${SAMPLETYPE}_${valrel}.root -F ${REFPATH}/${PREFIX}_${SAMPLENAME}_${SAMPLETYPE}_${refrel}.root -r ${valrel} -R ${refrel} -s ${SAMPLENAME}_${SAMPLETYPE} -S ${SAMPLENAME}_${SAMPLETYPE} 2>&1 | grep -v "Info in"
    for File in `ls *diffEff*`; do mv ${File} zz_${File}; done
    for File in `ls AllTaggers*_ref.*`; do mv ${File} 1_${File}; done
    for File in `ls *jetPt*.*`;         do mv ${File} 2_${File}; done
    for File in `ls AllTaggers*_val.*`; do mv ${File} 3_${File}; done
    for File in `ls *+(jetEta)!(*diffEff*)`;        do mv ${File} 4_${File}; done
    for File in `ls *Correlation*.*`;        do mv ${File} z_${File}; done
    for File in `ls *+(Ctagger)!(*diffEff*|*Tag*)`;        do mv ${File} z_${File}; done
    cd ..

    mv ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}/CtaggerTag* ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}_lowLevelVariables
    mv ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}/CSVTag* ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}_lowLevelVariables
    mv ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}/IPTag* ${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}_lowLevelVariables

    echo '<a href="https://cms-btag-validation.web.cern.ch/cms-btag-validation/validation/index_RecoB_'CMSSW_${outdir}_${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}.html'">' >> index.html
    echo "(${SAMPLENAME},${SAMPLETYPE}) Algorithm performances" >> index.html
    echo '</a><br>' >> index.html
    echo '<a href="https://cms-btag-validation.web.cern.ch/cms-btag-validation/validation/index_RecoB_'CMSSW_${outdir}_${SAMPLENAME}_${valrel}_vs_${refrel}_${SAMPLETYPE}_lowLevelVariables.html'">' >> index.html
    echo "(${SAMPLENAME},${SAMPLETYPE}) Low-level variables" >> index.html
    echo '</a><br>' >> index.html
done
echo '<hr align="left">' >> index.html

if [ ! -d CMSSW_${outdir} ]; then mkdir CMSSW_${outdir}; fi
mv *_${valrel}_vs_${refrel}_* CMSSW_${outdir}/

echo "Move plots to www space : rsync -az CMSSW_${outdir} /afs/cern.ch/cms/btag/www/validation/packages/RecoB/"
echo "Move index to www space : mv index.html /afs/cern.ch/cms/btag/www/validation/CMSSW_${outdir}_topdir.html"
echo "Publish : python ../../../../../Validation-Tools/webInterface/scripts/make_webpage.py /afs/cern.ch/cms/btag/www/validation/"