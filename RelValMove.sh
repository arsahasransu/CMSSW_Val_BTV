#!/bin/bash
#$1 is the argument, ex : ./ReValMove.sh 920_2017

if [ "$1" != "" ]
then

        mv TTbar_FastSim/DQM_V0001_R000000001__POG__BTAG__BJET.root    BTagRelVal_TTbar_FastSim_$1.root
        mv TTbar_FullSim/DQM_V0001_R000000001__POG__BTAG__BJET.root    BTagRelVal_TTbar_FullSim_$1.root
        mv TTbar_FastSim_PU25ns/DQM_V0001_R000000001__POG__BTAG__BJET.root BTagRelVal_TTbar_FastSim_PU25ns_$1.root
        mv TTbar_FullSim_PU25ns/DQM_V0001_R000000001__POG__BTAG__BJET.root BTagRelVal_TTbar_FullSim_PU25ns_$1.root
        mv QCD_FastSim/DQM_V0001_R000000001__POG__BTAG__BJET.root      BTagRelVal_QCD_FastSim_$1.root
        mv QCD_FullSim/DQM_V0001_R000000001__POG__BTAG__BJET.root      BTagRelVal_QCD_FullSim_$1.root
else
        echo "No release tag specified!"
fi