import sys
import tokenization

"""
  I referred to pull requset here, https://github.com/google-research/bert/pull/228
  Thanks for @soheeyang
"""

text = u"Alice는 대학교 근처의 Cafe에서 part time으로 일합니다."

tokenizer = tokenization.FullTokenizer('config/vocab.txt', do_lower_case=True)

print(tokenizer.tokenize(text))