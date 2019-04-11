name_of_project=$1

for dir in Scripts; do cp -r $dir $name_of_project/.; done
cd $name_of_project
mkdir Data
mkdir Data/Original
mkdir -p Models/CRF
mkdir Models/RankedSents
mkdir Results
mkdir Data/Preprocessed
mkdir Data/Tokenized
mkdir Data/Prepared
mkdir Data/Splits
mkdir Data/Features
mkdir Data/Gazatteers
