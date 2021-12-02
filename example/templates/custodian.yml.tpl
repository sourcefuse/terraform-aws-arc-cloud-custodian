---
policies:
  - name: ec2-tag-compliance
    resource: aws.ec2
    comments: Tag non-compliant ec2 instances.
    mode:
      type: cloudtrail
      role: ${EC2_TAG_ROLE}
      events:
        - source: ec2.amazonaws.com
          event: RunInstances
          ids: "responseElements.instancesSet.items[].instanceId"
    filters:
      - "State.Name": running
      - "tag:aws:autoscaling:groupName": absent
      - or:
          - "tag:Example": absent
          - "tag:AnotherExample": absent
    actions:
      - type: tag
        tags:
          Example: true
          AnotherExample: alsoTrue
