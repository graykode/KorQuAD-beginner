cl run :KorQuAD_v1.0_dev.json :src :config "python src/run_KorQuAD.py --bert_config_file=config/bert_config.json --vocab_file=config/vocab.txt --init_checkpoint=config/model.ckpt-45000 --do_predict=True --output_dir=output config/KorQuAD_v1.0_dev.json predictions.json" -n run-predictions --request-docker-image tensorflow/tensorflow:1.12.0-gpu-py3 --request-memory 11g --request-gpus 1