import datetime
import boto3
import random
import os

def run(event, lambda_context):
    ec2 = boto3.resource('ec2')

    instances = ec2.instances.filter(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])

    ROTATE_EVERY_MINUTES = int(os.environ.get('ROTATE_EVERY_MINUTES', 20))
    delta = datetime.timedelta(minutes=10)
    CUTOFF_TIME = (datetime.datetime.now() - delta).replace(tzinfo=None)
    print(CUTOFF_TIME)

    filtered = list(filter(lambda i: i.launch_time.replace(tzinfo=None) < CUTOFF_TIME, instances))
    size = len(filtered)
    if (size > 0):
        index = random.randint(0, size - 1)
        instance = filtered[index]
        print(
            "Terminating Id: {0},Public IPv4: {1},Launch time: {2}, State: {3}, Running for: {4}".format(
            instance.id, instance.public_ip_address, instance.launch_time.strftime("%Y-%m-%d %H:%M:%S"), instance.state['Name'], datetime.datetime.now().replace(tzinfo=None) - instance.launch_time.replace(tzinfo=None)
            )
        )

        ec2_client = boto3.client('ec2');
        ec2_client.terminate_instances(InstanceIds=[instance.id])
