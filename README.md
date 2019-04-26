## KorQuAD-beginner

[English Guide](README(EN).md)

[KorQuAD](https://korquad.github.io/)를 처음 시작하시는 분들을 위한 가이드입니다. [google-research's BERT github](https://github.com/google-research/bert)의 BERT-multilingual(single)만 사용하여 f1 88.468 and EM(ExactMatch) 68.947의 결과를 낼 수 있었습니다.

![](leaderboard.jpg)

KorQuAD데이터를 fine-tuning하는 거는 쉬웠으나, `codalab`을 사용하여 리더보드를 올리는 것은 좀 어려웠는데요, 따라서 KorQuAD  리더보드에 결과 값을 올리는 것을 중점에 대한 가이드라인입니다.



### 1. fine-tuning KorQuAD

 [google-research's BERT github](https://github.com/google-research/bert)를 사용하시면 쉽게 fine-tuning할 수 있습니다. 아래 한 줄로 KorQuAD에 대한 학습이 완료됩니다. Google-research's BERT를 그대로 사용하신다면, `unicodedata.normalize("NFD", text)`로 인해 `UNK`으로 subtoken화 됩니다. [여기](https://github.com/google-research/bert/pull/228)와  pull request [code](https://github.com/google-research/bert/pull/228/commits/c26341272de7c0d22cd65ea58d884323f64b7a92)를 보신다면 해결 방안에 대해 더 자세히 볼 수 있습니다! 더불어 여기 repository에 그 부분 코드를 추가했습니다. `multi_cased_L-12_H-768_A-12 ` 폴더에 대해서는 [**BERT-Base, Multilingual Cased (New, recommended)**](https://storage.googleapis.com/bert_models/2018_11_23/multi_cased_L-12_H-768_A-12.zip) 를 사용하시면 됩니다.

```shell
$ python run_squad.py \
  --vocab_file=multi_cased_L-12_H-768_A-12/vocab.txt \
  --bert_config_file=multi_cased_L-12_H-768_A-12/bert_config.json \
  --init_checkpoint=multi_cased_L-12_H-768_A-12/bert_model.ckpt \
  --do_train=True \
  --train_file=config/KorQuAD_v1.0_train.json \
  --do_predict=True \
  --predict_file=config/KorQuAD_v1.0_dev.json \
  --train_batch_size=4 \
  --num_train_epochs=3.0 \
  --max_seq_length=384 \
  --output_dir=./output \
  --do_lower_case=False
```

GeForce RTX 2080와 11GB 메모리에서 학습을 하였고 3~4 시간이 걸렸습니다.

학습 후 다음과 같은 F1 스코어와 EM 결과 값을 얻으실수 있습니다.

```shell
$ python evaluate-v1.0.py config/KorQuAD_v1.0_dev.json output/predictions.json

{"f1": 88.57661204608746, "exact_match": 69.05091790786284}
```

**학습된 체크포인트 파일을 config 폴더에 넣어주세요.**



### 2. KorQuAD Submit Codalab Guide

##### 0. Codalab 회원가입

completion이 아니라 **worksheets**에 회원가입을 해주세요.



##### 1. Codalab Cli 설치

CLI는 파이썬 2.7에서만 작동을 해서 만약 Python 3이 디폴트 설정이라면, virtualenv보다`Anaconda` 설정을 통해 사용하시는 걸 추천드립니다.

```shell
$ conda create -n py27 python=2.7 anaconda
$ conda activate py27
(py27) $ pip install codalab -U --user
```



##### 2. Codalab에서 새로운 WorkSheet 만들기

오른쪽 상단에 `New Worksheet` 버튼을 눌러 Worksheet 이름을 지정하세요.



##### 3. fine-tuning시 만들어진 predictions.json 테스트.

> Dev set에 대한 evaluate를 안하시고 싶으시다면 3번을 뛰어 넘으셔도 됩니다.

1. `Upload` 버튼을 누르고  fine-tuning시 만들어진`output/predictions.json` 파일을 업로드하세요.

2. 페이지 상단의 웹 인터페이스 터미널을 이용하여 다음과 같이 명령어를 치시면 됩니다.

   `<name-of-your-uploaded-prediction-bundle>`는  `output/predictions.json`의 uuid[0:8]를 나타냅니다.

   ```shell
   # web interface terminal
   cl macro korquad-utils/dev-evaluate-v1.0 <name-of-your-uploaded-prediction-bundle>
   ```

   

##### 4.  `src` , `config` 폴더 업로드 하기

이렇게 두 개의 폴더를 나눈 이유는 config 폴더(체크포인트 파일)을 매번 업로드 하는데 많은 시간이 걸리기 때문입니다.

- src 폴더: 소스 코드만 들어있는 폴더로 실제로 Codalab에서 돌아가는 코드입니다. ex) `run_squad.py`
- config 폴더: `bert_config.json`, `KorQuAD_v1.0_dev.json`,  `KorQuAD_v1.0_dev.json`, `vocab.txt`, `checkpoint files(fine-tuning checkpoint file)`

이제  `Codalab Cli`커맨드를 통해 업로드를 합니다. Web UI를 통해 업로드를 할 수 있지만 매우 느리기 때문에 cl를 통해 업로그 하시면 됩니다.

```shell
# command on Anaconda-Python2.7
# cl upload <folder-name> -n <bundle-name>
$ cl upload Leaderboard -n src
$ cl upload config -n config
```



##### 5. Dev set을 위한 학습 모델 실행

```shell
# web interface terminal
cl add bundle korquad-data//KorQuAD_v1.0_dev.json .
```

 `bundle spec . doesn't match any bundles`이라는 문구가 떠도 계속 진행하는데 큰 문제가 되지 않습니다.

이제 Dev set을 위한 학습 모델을 실행하시면 됩니다!

:src, :config meaning of : `<bundle-name>`

> 세미콜론(:) 후의 이름은 위에 -n에서 지정한 bundle의 이름을 나타냅니다. 즉 폴더 안의 파일을 찾기 위해서는 꼭 명령어 앞에 번들 이름을 붙어 주어야 합니다. 아래 예시를 보시면 됩니다.

```shell
# command on Anaconda-Python2.7
$ cl run :KorQuAD_v1.0_dev.json :src :config "python src/run_KorQuAD.py --bert_config_file=config/bert_config.json --vocab_file=config/vocab.txt --init_checkpoint=config/model.ckpt-45000 --do_predict=True --output_dir=output config/KorQuAD_v1.0_dev.json predictions.json" -n run-predictions --request-docker-image tensorflow/tensorflow:1.12.0-gpu-py3 --request-memory 11g --request-gpus 1
```

###### Trouble shooting

1. argument에 대한 TS : [공식 KorQuAD 튜토리얼](https://worksheets.codalab.org/worksheets/0x7b06f2ebd0584748a3a281018e7d19b0/)에서 다음과 같은 argument를 추천하고 있습니다.

   ```
   python src/<path-to-prediction-program> <input-data-json-file> <output-prediction-json-path>
   ```

   위에 argument를 실행하기 위해서 아래와 같이 `<bundle-name>`/file-name으로 지정된 파일을 선택할 수 있습니다.

   ```
   python src/run_KorQuAD.py --bert_config_file=config/bert_config.json --vocab_file=config/vocab.txt --init_checkpoint=config/model.ckpt-45000 --do_predict=True --output_dir=output config/KorQuAD_v1.0_dev.json predictions.json
   ```

2.  ImportError: libcuda.so.1 error 에러에 대한 TS :  `tensorflow 1.12.0` 버전 `python3` docker를 사용하고 `--request-gpus 1`로 두어 핀 넘버를 명시적으로 지정해줬더니 해결할 수 있었습니다.

3. Out of memory에 대한 TS : `--request-memory 11g`



##### 6. Bundle에 prediction file( part 5의 결과) 추가하기

bundle에 결과값(`predictions.json`)을 다음과 같이 추가합니다: `MODELNAME`는 빈칸과 특수문자를 포함하면 안됩니다.

```shell
# web interface terminal
cl make run-predictions/predictions.json -n predictions-{MODELNAME}
```

이제 Dev Set의 `predictions.json` 파일을 evaluate할 수 있습니다.

```shell
# web interface terminal
cl macro korquad-utils/dev-evaluate-v1.0 predictions-{MODELNAME}
```



##### 7 Submit(제출)

여기서 부터는 리더보드에 제출하는 단계로 [공식 KorQuAD 튜토리얼](https://worksheets.codalab.org/worksheets/0x7b06f2ebd0584748a3a281018e7d19b0/)의 파트3부터 참고하시면 됩니다.

![](result.jpg)



## License

These Repository are all released under the same license as the source code (Apache 2.0) with [google-research BERT](https://github.com/google-research/bert), Tae Hwan Jung



## Author

- Tae Hwan Jung(Jeff Jung) @graykode, Kyung Hee Univ CE(Undergraduate).
- Author Email : [nlkey2022@gmail.com](mailto:nlkey2022@gmail.com)
- Reference : [Original KorQuAD tutorial](https://worksheets.codalab.org/worksheets/0x7b06f2ebd0584748a3a281018e7d19b0/), [The Land Of Galaxy Blog](http://mlgalaxy.blogspot.com/2019/02/bert-multilingual-model-korquad-part-2.html#comment-form)