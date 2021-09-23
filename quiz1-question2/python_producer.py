import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from confluent_kafka import Producer
import time
import os
import re
import string

nltk.download('stopwords')
nltk.download('punkt')


import nltk
from nltk.corpus import stopwords
# nltk.download('stopwords')
# nltk.download('punkt')
from nltk.tokenize import word_tokenize


pageList = []
def read_Harry_Potter():
    file_name = "book.txt"
    count = 0
    with open(file_name, encoding="utf8") as f:
        lines = f.readlines()
        pageText = ""
        for line in lines:
            formatText = line.replace("\n", "")
            removeComma = formatText.replace(",", "")
            lowerCase = removeComma.replace("\\", "").lower()
            lowerCase = lowerCase.replace("!", "")
            lowerCase = lowerCase.replace("!", "")
            lowerCase = lowerCase.replace("'", "")
            lowerCase = lowerCase.replace("\"", "")
            lowerCase = lowerCase.replace("”", "")
            lowerCase = lowerCase.replace("“", "")
            lowerCase = lowerCase.replace(".", "")
            lowerCase = lowerCase.replace("—", "")
            lowerCase = lowerCase.replace("?", "")
            text_tokens = word_tokenize(lowerCase)
            
            tokens_without_stopwords = [word for word in text_tokens if not word in stopwords.words("english")]
            
            rows = tokens_without_stopwords
            for text in rows:
            
                if text == '|':
                    pageList.append(pageText + " #####")
                    count+=1
                    pageText = ""

                    if count > 9:
                        pageList.append("@@@@@@@")
                        print(f'List size = {len(pageList)}')
                        return

                else:
                    if text != 'Page' and text != '' and not text.isdigit():
                        pageText = pageText + " " + text
        
        pageList.append(pageText)
        # print(f'List size = {len(pageList)}')
        print(pageList)

# print(stopwords.words("english"))
read_Harry_Potter()

kafka_topic_name = "stream-expresso-input"
kafka_bootstrap_servers = 'ec2-13-229-46-113.ap-southeast-1.compute.amazonaws.com:9092'

p = Producer({'bootstrap.servers': kafka_bootstrap_servers, 'message.max.bytes': '2048576'})

def delivery_report(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))


for index, page in enumerate(pageList) :
    key = f"page{index}"
    print(key)
    p.poll(1)
    p.produce(kafka_topic_name, page, key=key, callback=delivery_report)
    p.flush()


# pageList = [pageList[0], pageList[1]]
# pageList = ['The doctor is kind #####', 'The police is kind #####', 'The test is yooo #####', '@@@@@@@']



