---
policies:
  - name: ec2-tag-compliance
    comment: |
      Tag non-compliant ec2 instances.
    resource: aws.ec2
    mode:
      type: ec2-instance-state
      role: ${EC2_TAG_ROLE}
    filters:
      - "State.Name": running
      - "tag:aws:autoscaling:groupName": absent
      - or:
          - "tag:Environment": absent
          - "tag:ResourceOwner": absent
    actions:
      - type: tag
        tags:
          Environment: POC2
          ResourceOwner: Example
