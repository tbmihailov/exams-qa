import argparse
import json
from pathlib import Path

EXAMS_DIR = Path(__file__).resolve().parent / "exams"

def load_id_to_hits(file_name, max_hits):
    id_to_hits = {}
    with open(file_name, mode="r") as f_hits:
        for line_id, line in enumerate(f_hits):
            if (line_id+1) % 1000 == 0:
                print(f"{line_id+1} lines processed")
            item = json.loads(line.strip())
            item_id = list(item.keys())[0]
            
            choices_with_hits = {}
            for choice_key, hits_with_meta in item[item_id].items():
                choice_hits = [h["hit"]["text"] for h in hits_with_meta[:max_hits]]
                choices_with_hits[choice_key] = choice_hits
            
            id_to_hits[item_id] = choices_with_hits
    
    return id_to_hits


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-file", type=str, default="prepare_data/exams/multilingual/dev.jsonl")
    parser.add_argument("--output-file", type=str, default="prepare_data/exams/multilingual/with_hits/dev.jsonl")
    parser.add_argument("--hits-file", default="prepare_data/exams/resolved_hits.jsonl")
    parser.add_argument("--max-hits", type=int, default=10)

    args = parser.parse_args()
    max_hits = args.max_hits
    
    input_file = args.input_file
    output_file = args.input_file+".with_hits" if not args.output_file else args.output_file

    # load hits
    id_to_hits = load_id_to_hits(args.hits_file, max_hits)
    
    wrong_answer_key = []
    with open(output_file, mode="w") as f_out:
        with open(input_file, mode="r", encoding="utf8") as f_in:
            for line_id, line in enumerate(f_in):
                if line_id==0:
                    print(line)
                if (line_id+1) % 1000 == 0:
                    print(f"{line_id + 1} questions processed")
                    print(line)

                question_item = json.loads(line.strip())
                if question_item["answerKey"] == "@":
                    wrong_answer_key.append(question_item["id"])

                for ch in question_item["question"]["choices"]:
                    if "para" in ch:
                        del ch["para"]
                    ch["hits"] = id_to_hits[question_item["id"]][ch["label"]]
                
                out_str = json.dumps(question_item, ensure_ascii=False)
                f_out.write(out_str)
                #f_out.write("тест")
                f_out.write("\n")

    print(wrong_answer_key)

