import time
from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers=['localhost:9092','localhost:9192','localhost:9292'])

with open('./text/book.txt', 'r', newline='', encoding='utf-8') as file:
    for line in file.readlines():
        producer.send('read-harry-stream', line.strip().encode('utf-8'))
        time.sleep(1)