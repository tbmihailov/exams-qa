#!/bin/bash

set -e
set -x

target_dir=./prepare_data/exams

rm -rf $target_dir
mkdir -p $target_dir

# Download EXAMS REPO
EXAMS_DATA_URL="https://github.com/mhardalov/exams-qa/archive/main.zip"
wget $EXAMS_DATA_URL

unzip $(basename $EXAMS_DATA_URL)

# copy data and delete repo
mv exams-qa-main/data/exams $target_dir
rm -rf exams-qa-main

# base questions without paragraphs
exams_data_dir=$target_dir/exams
for f in $exams_data_dir/*/*.tar.gz; do
    f_dir="$( cd "$( dirname "${f}" )" >/dev/null 2>&1 && pwd )"
    tar -xf $f -C $f_dir
    echo $f
    rm $f
done

# with paragraphs
exams_data_dir=$target_dir/exams
for f in $exams_data_dir/*/*/*.tar.gz; do
    f_dir="$( cd "$( dirname "${f}" )" >/dev/null 2>&1 && pwd )"
    tar -xf $f -C $f_dir
    echo $f
    rm $f
done
rm main.zip

# reorganize dataset for fairseq
mv $exams_data_dir/multilingual/with_paragraphs $exams_data_dir/multilingual/with_paragraphs_wiki
cd $exams_data_dir/multilingual/with_paragraphs_wiki
mv train_with_para.jsonl train.jsonl
mv dev_with_para.jsonl valid.jsonl
mv test_with_para.jsonl test.jsonl

sleep 5
# extract hits
tar -xf $exams_data_dir/resolved_hits.tar.gz -C $exams_data_dir/

# create examples with hits
exams_multi_with_para=$exams_data_dir/multilingual/with_paragraphs_wiki/
exams_multi_with_hits=$exams_data_dir/multilingual/with_hits_wiki/
mkdir -p $exams_multi_with_hits

bash_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
python $bash_dir/prepare_data_with_hits.py --input-file=$exams_multi_with_para/valid.jsonl --output-file=$exams_multi_with_hits/valid.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl
python $bash_dir/prepare_data_with_hits.py --input-file=$exams_multi_with_para/train.jsonl --output-file=$exams_multi_with_hits/train.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl
python $bash_dir/prepare_data_with_hits.py --input-file=$exams_multi_with_para/test.jsonl --output-file=$exams_multi_with_hits/test.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl

