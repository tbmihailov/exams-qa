# Prepare EXAMS with hits


Uncompress data:
```
exams_data_dir=prepare_data/exams
rm -rf $exams_data_dir
mkdir -p prepare_data
cp -r data/exams $exams_data_dir

# base questions without paragraphs
for f in $exams_data_dir/*/*.tar.gz; do
    f_dir="$( cd "$( dirname "${f}" )" >/dev/null 2>&1 && pwd )"
    tar -xf $f -C $f_dir
    echo $f
    rm $f
done

# with paragraphs
for f in $exams_data_dir/*/*/*.tar.gz; do
    f_dir="$( cd "$( dirname "${f}" )" >/dev/null 2>&1 && pwd )"
    tar -xf $f -C $f_dir
    echo $f
    rm $f
done

tar -xf $exams_data_dir/resolved_hits.tar.gz -C $exams_data_dir/
```

Map hits to quesitons
```
exams_data_dir=prepare_data/exams
exams_multi=$exams_data_dir/multilingual/
exams_multi_with_hits=$exams_data_dir/multilingual/with_hits/
mkdir -p $exams_multi_with_hits

python scripts/download/prepare_data_with_hits.py --input-file=$exams_multi/dev.jsonl --output-file=$exams_multi_with_hits/dev.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl
python scripts/download/prepare_data_with_hits.py --input-file=$exams_multi/train.jsonl --output-file=$exams_multi_with_hits/train.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl
python scripts/download/prepare_data_with_hits.py --input-file=$exams_multi/test.jsonl --output-file=$exams_multi_with_hits/test.jsonl --hits-file ${exams_data_dir}/resolved_hits.jsonl


```