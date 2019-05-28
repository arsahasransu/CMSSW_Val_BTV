# No shebang, this should be sourced, not executed

RELEASE=10_6_0_pre4
GLOBALTAG_PREFIX=106X

# Make sure we can access DAS
echo ""
echo " > Creating proxy allowing DAS access ..." 
echo ""
voms-proxy-init -rfc -voms cms

echo ""
echo " > Setting up CMSSW release $REL ..."
echo ""

scramv1 project CMSSW CMSSW_$RELEASE
cd CMSSW_$RELEASE/src
eval `scramv1 runtime -sh`

echo ""
echo " > Checking out Validation and DQM packages ..."
echo ""

git cms-addpkg Validation/RecoB
git cms-addpkg DQMOffline/RecoB

echo ""
echo " > Compiling packages ..."
echo ""

scram b -j 8

echo ""
echo " > Create folders for validation ..."
echo ""

cd Validation/RecoB/test

mkdir TTbar_FastSim        && cp Harvest_validation_cfg.py TTbar_FastSim/harvester_cfg.py
mkdir TTbar_FullSim        && cp Harvest_validation_cfg.py TTbar_FullSim/harvester_cfg.py
mkdir TTbar_FastSim_PU25ns && cp Harvest_validation_cfg.py TTbar_FastSim_PU25ns/harvester_cfg.py
mkdir TTbar_FullSim_PU25ns && cp Harvest_validation_cfg.py TTbar_FullSim_PU25ns/harvester_cfg.py
mkdir QCD_FastSim          && cp Harvest_validation_cfg.py QCD_FastSim/harvester_cfg.py
mkdir QCD_FullSim          && cp Harvest_validation_cfg.py QCD_FullSim/harvester_cfg.py
mkdir TTbar_FullSim2023        && cp Harvest_validation_cfg.py TTbar_FullSim2023/harvester_cfg.py
mkdir TTbar_FullSim2023_PU25ns && cp Harvest_validation_cfg.py TTbar_FullSim2023_PU25ns/harvester_cfg.py

echo ""
echo " > Get files list from DAS ..."
echo ""


sed -i '/]/d' TTbar_FastSim/harvester_cfg.py
sed -i '/]/d' TTbar_FullSim/harvester_cfg.py
sed -i '/]/d' TTbar_FastSim_PU25ns/harvester_cfg.py
sed -i '/]/d' TTbar_FullSim_PU25ns/harvester_cfg.py
sed -i '/]/d' QCD_FastSim/harvester_cfg.py
sed -i '/]/d' QCD_FullSim/harvester_cfg.py
sed -i '/]/d' TTbar_FullSim2023/harvester_cfg.py
sed -i '/]/d' TTbar_FullSim2023_PU25ns/harvester_cfg.py

dasgoclient --query="file dataset=/RelValTTbar_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"         | grep "store" | grep    "FastSim" >> TTbar_FastSim/harvester_cfg.py
dasgoclient --query="file dataset=/RelValTTbar_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"         | grep "store" | grep -v "FastSim" >> TTbar_FullSim/harvester_cfg.py
dasgoclient --query="file dataset=/RelValTTbar_13/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"  | grep "store" | grep "FastSim" >> TTbar_FastSim_PU25ns/harvester_cfg.py
dasgoclient --query="file dataset=/RelValTTbar_13/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"  | grep "store" | grep -v "FastSim" >> TTbar_FullSim_PU25ns/harvester_cfg.py
dasgoclient --query="file dataset=/RelValQCD_Pt_80_120_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO" | grep "store" | grep "FastSim" >> QCD_FastSim/harvester_cfg.py
dasgoclient --query="file dataset=/RelValQCD_Pt_80_120_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO" | grep "store" | grep -v "FastSim" >> QCD_FullSim/harvester_cfg.py
dasgoclient --query="file dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"         | grep "store" >> TTbar_FullSim2023/harvester_cfg.py
dasgoclient --query="file dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"  | grep "store" >> TTbar_FullSim2023_PU25ns/harvester_cfg.py

sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FastSim/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FullSim/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FastSim_PU25ns/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FullSim_PU25ns/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" QCD_FastSim/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" QCD_FullSim/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FullSim2023/harvester_cfg.py
sed -i "s|\(^/store.*\.root$\)|'\1',|g" TTbar_FullSim2023_PU25ns/harvester_cfg.py

echo "]" >> TTbar_FastSim/harvester_cfg.py
echo "]" >> TTbar_FullSim/harvester_cfg.py
echo "]" >> TTbar_FastSim_PU25ns/harvester_cfg.py
echo "]" >> TTbar_FullSim_PU25ns/harvester_cfg.py
echo "]" >> QCD_FastSim/harvester_cfg.py
echo "]" >> QCD_FullSim/harvester_cfg.py
echo "]" >> TTbar_FullSim2023/harvester_cfg.py
echo "]" >> TTbar_FullSim2023_PU25ns/harvester_cfg.py

# Needed because of https://github.com/cms-sw/cmssw/pull/12642
sed -i "s/bTagCollectorSequenceMC/bTagCollectorSequenceMCbcl/g" *FastSim*/harvester_cfg.py

cp ../../../../../makeComparison.sh .
cp ../../../../../RelValMove.sh .

# CAREFUL - this is done for convenience but if you want to re-run scram, you MUST delete this symlink otherwise scram will just hang.
ln -s ../../../../../ baseDir

echo " > Now you should check that the harvester_cfg.py input files are correctly filled and/or comment what you don't need"
