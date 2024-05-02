import boto3

def delete_all_security_groups():
    # Initialize Boto3 client for EC2 in eu-west-1 region
    ec2 = boto3.client('ec2', region_name='eu-west-1')
    
    # Retrieve all security groups
    response = ec2.describe_security_groups()
    security_groups = response['SecurityGroups']
    
    # Delete each security group
    for sg in security_groups:
        group_id = sg['GroupId']
        print("Deleting security group:", group_id)
        try:
            ec2.delete_security_group(GroupId=group_id)
            print("Security group {} deleted successfully.".format(group_id))
        except Exception as e:
            print("Failed to delete security group {}: {}".format(group_id, e))

if __name__ == "__main__":
    delete_all_security_groups()
