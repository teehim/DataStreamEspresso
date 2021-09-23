from confluent_kafka import Consumer

kafka_topic_name = "stream-expresso-output"
kafka_bootstrap_servers = 'ec2-13-229-46-113.ap-southeast-1.compute.amazonaws.com:9092'

c = Consumer({
    'bootstrap.servers': kafka_bootstrap_servers,
    'group.id': 'test-group',
    'auto.offset.reset': 'largest'
})

c.subscribe([kafka_topic_name])

while True:
    msg = c.poll(1.0)

    if msg is None:
        continue
    if msg.error():
        print("Consumer error: {}".format(msg.error()))
        continue

    print('Received message: {}'.format(msg.value().decode('utf-8')))

c.close()