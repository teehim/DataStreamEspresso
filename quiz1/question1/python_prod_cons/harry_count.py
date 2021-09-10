# pip install kafka-python

from kafka import KafkaConsumer
from kafka import KafkaProducer

from datetime import datetime
import json

consumer = KafkaConsumer('word-count-stream', group_id='harry-count-py', bootstrap_servers=['localhost:9092','localhost:9192','localhost:9292'])
# producer = KafkaProducer(bootstrap_servers=['localhost:9092','localhost:9192','localhost:9292'])

harry_count = 0
start_at = datetime.now()

for msg in consumer:
    # print(msg)
    # text = msg.value.decode("utf-8")
    now = datetime.now()
    if (now - start_at).total_seconds() >= 5:
        start_at = now
        print(f'harry found: {harry_count}')
        harry_count = 0

        
    key = msg.key.split(b'\x00')[0].decode('utf-8')
    value = ord(msg.value.replace(b'\x00', b''))
    if (key == 'harry'):
        harry_count += value
    # print(f"{key}: {value}")
    # words = text['payload'].lower().strip().split(" ")
    # harry_count += words.count('harry')
    # producer.send('harry-count-stream', f'harry found: {harry_count}'.encode('utf-8'))

# 