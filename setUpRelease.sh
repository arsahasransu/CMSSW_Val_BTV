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

echo ""
echo " > Get files list from DAS ..."
echo ""

dasgoclient --query="dataset=/RelValTTbar_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"         | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep    "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_13/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"         | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep -v "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_13/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"     | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep    "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_13/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"     | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep -v "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_13_UP*/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"     | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep    "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_13_UP*/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"     | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep -v "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"      | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep    "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*/DQMIO"      | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep -v "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"  | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep    "FastSim" >> relvals
dasgoclient --query="dataset=/RelValTTbar_14TeV/CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*/DQMIO"  | grep "DQMIO" | grep -v "design" | grep -v "HEfail" | grep -v "FastSim" >> relvals

echo "> You're now going to check the list of files to be downloaded (e.g. manually remove those that should not)."
echo "> Download will begin as as soon as the editor is exited."
echo "> Press ENTER to continue..."
read
vim relvals

echo ""
echo " > Downloading files ..."
echo ""

sed -i 's/\//__/g' relvals
sed -i "s|\(.*\)|${BASEURL}/DQM_V0001_R000000001\1\.root|g" relvals

openssl rsa -in ${KEY} -out TEMPKEY.pem
chmod 600 TEMPKEY.pem
KEY=TEMPKEY.pem

wget --certificate ${CERT} --private-key ${KEY} -O full_list ${BASEURL}
cat full_list | grep ${RELEASE} | sed "s|.*href='.*'>\(.*\)</a>.*|${BASEURL}/\1|g" > full_list_temp
cat full_list_temp > full_list
rm full_list_temp

for rel in $(cat relvals); do
    wget --certificate ${CERT} --private-key ${KEY} ${rel} || wget --certificate ${CERT} --private-key ${KEY} ${rel/0001/0002}
done

rm TEMPKEY.pem

cp ../../../../../makeComparison.sh .
cp ../../../../../RelValMove.sh .
ln -s ../../../../.. baseDir

rel=${RELEASE//_/}
# PU premixing samples
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2018*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2018*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*mc2017*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2017_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*mc2017*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2017_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*mcRun2*asymptotic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2016_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*mcRun2*asymptotic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2016_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2021_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2021_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2021_14TeV_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2021_14TeV_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2023*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_phase2_pmx.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PUpmx*_${GLOBALTAG_PREFIX}*upgrade2023*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_phase2_pmx.root" >> RenameRelVals.sh

# PU 25ns samples
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2018*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2018*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*mc2017*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2017.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*mc2017*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2017.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*mcRun2*asymptotic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2016.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*mcRun2*asymptotic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2016.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2021.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2021.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_2021_14TeV.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_2021_14TeV.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2023*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_PU25ns_${rel}_phase2.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-PU*_${GLOBALTAG_PREFIX}*upgrade2023*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_PU25ns_${rel}_phase2.root" >> RenameRelVals.sh

# no PU samples
echo "mv DQM_V000?_R000000001__RelValTTbar_13_UP*__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2018*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_${rel}.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2018*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}.root"  >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13_UP*__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*mc2017*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_${rel}_2017.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*mc2017*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}_2017.root"  >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*mcRun2*asymptotic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_${rel}_2016.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*mcRun2*asymptotic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}_2016.root"  >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_13__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}_2021.root"  >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2021*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_${rel}_2021_14TeV.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2021*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}_2021_14TeV.root"  >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2023*realistic*_FastSim*__DQMIO.root BTagRelVal_TTbar_FastSim_${rel}_phase2.root" >> RenameRelVals.sh
echo "mv DQM_V000?_R000000001__RelValTTbar_14TeV__CMSSW_${RELEASE}-${GLOBALTAG_PREFIX}*upgrade2023*realistic*__DQMIO.root BTagRelVal_TTbar_FullSim_${rel}_phase2.root"  >> RenameRelVals.sh
chmod +x RenameRelVals.sh

echo ""
echo " > Done!"
echo " > Check and call 'RenameRelVals.sh' to have the correct file names."
echo " > In case of issues, the full list of RelVals is available in 'full_list'."
echo " > Simply edit this list, and do 'cat full_list | xargs wget --certificate ~/.globus/usercert.pem --private-key ~/.globus/userkey.pem' to download the files."
echo ""
