import boto3

def is_security_group_in_use(ec2, group_id):
    """
    Check if the specified security group is in use by any EC2 instances.
    """
    response = ec2.describe_instances(Filters=[
        {'Name': 'instance.group-id', 'Values': [group_id]}
    ])
    instances = response['Reservations']
    return len(instances) > 0

def delete_all_security_groups(event, context):
    # Initialize Boto3 client for EC2 in eu-west-1 region
    ec2 = boto3.client('ec2', region_name='eu-west-1')
    
    # Retrieve all security groups
    response = ec2.describe_security_groups()
    security_groups = response['SecurityGroups']
    
    # Delete each security group
    for sg in security_groups:
        group_id = sg['GroupId']
        description = sg.get('Description', '')
        
        # Skip deletion if description contains 'Terraform' or 'DELETE'
        if 'Terraform' in description or 'DELETE' in description:
            print("Skipping security group {} due to protected description.".format(group_id))
            continue

        print("Checking if security group {} is in use...".format(group_id))
        if is_security_group_in_use(ec2, group_id):
            print("Security group {} is in use. Skipping deletion.".format(group_id))
        else:
            print("Deleting security group:", group_id)
            try:
                ec2.delete_security_group(GroupId=group_id)
                print("Security group {} deleted successfully.".format(group_id))
            except Exception as e:
                print("Failed to delete security group {}: {}".format(group_id, e))

if __name__ == "__main__":
    delete_all_security_groups()
