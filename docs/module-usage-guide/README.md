# Terraform AWS ARC Cloud Custodian Module Usage Guide

## Introduction

### Purpose of the Document

This document provides guidelines and instructions for users looking to implement Terraform module for managing administering Cloud Custodian.

### Module Overview

The [terraform-aws-arc-security](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian) module provides a secure and modular foundation for managing Security Hub components.

### Prerequisites

Before using this module, ensure you have the following:
- AWS credentials configured.
- Terraform installed.
- Python 3.8 or above installed.
- Pip installed.

## Getting Started

### Module Source

To use the module in your Terraform configuration, include the following source block:

```hcl
module "cloud_security" {
  source  = "sourcefuse/arc-cloud-custodian/aws"
  version = "0.0.6"
  # insert the required variables here
}
```
Refer to the [Terraform Registry](https://registry.terraform.io/modules/sourcefuse/arc-cloud-custodian/aws/latest) for the latest version.

### Integration with Existing Terraform Configurations

Integrate the module with your existing Terraform mono repo configuration, follow the steps below:

1. Create a new folder in `terraform/` named `cloud-custodian`.
2. Create the required files, see the [examples](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian/tree/main/example) to base off of.
3. Configure with your backend
  - Create the environment backend configuration file: `config.<environment>.hcl`
    - **region**: Where the backend resides
    - **key**: `<working_directory>/terraform.tfstate`
    - **bucket**: Bucket name where the terraform state will reside
    - **dynamodb_table**: Lock table so there are not duplicate tfplans in the mix
    - **encrypt**: Encrypt all traffic to and from the backend

### Required AWS Permissions

Ensure that the AWS credentials used to execute Terraform have the necessary permissions to set up a cloud custodian infrastructure on AWS.

## Module Configuration

### Input Variables

For a list of input variables, see the README [Inputs](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian#inputs) section.

### Output Values

For a list of outputs, see the README [Outputs](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian#outputs) section.

## Module Usage

### Basic Usage

For basic usage, see the [example](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian/tree/main/example) folder.

This example will create:

The CloudTrail Terraform module by CloudPosse simplifies the implementation and management of AWS CloudTrail configurations. 

By leveraging the hashicorp/aws Terraform provider, this module allows users to effortlessly deploy CloudTrail with customizable settings, such as log file validation, event selectors, and multi-region trail support. 

The module ensures comprehensive visibility into AWS account activity by associating CloudTrail with an S3 bucket for log storage, and provides flexibility in defining IAM roles and policies. 

With built-in tagging and dependency management, this CloudTrail module offers a streamlined solution for enhancing AWS security and compliance.

### Tips and Recommendations

The module focuses on setting up a cloud custodian infrastructure on AWS. Adjust the configuration parameters as needed for your specific use case.

## Troubleshooting

### Reporting Issues

If you encounter a bug or issue, please report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-cloud-custodian/issues).

## Security Considerations

### AWS VPC

Understand the security considerations related to Cloud Custodian when using this module.

### Best Practices for AWS Cloud Custodian

Follow best practices to ensure best Security configurations.
[Cloud Custodian on AWS](https://aws.amazon.com/blogs/opensource/compliance-as-code-and-auto-remediation-with-cloud-custodian/)

## Contributing and Community Support

### Contributing Guidelines

Contribute to the module by following the guidelines outlined in the [CONTRIBUTING.md](https://github.com/sourcefuse/terraform-aws-arc-security/blob/main/CONTRIBUTING.md) file.

### Reporting Bugs and Issues

If you find a bug or issue, report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-security/issues).

## License

### License Information

This module is licensed under the Apache 2.0 license. Refer to the [LICENSE](https://github.com/sourcefuse/terraform-aws-arc-security/blob/main/LICENSE) file for more details.

### Open Source Contribution

Contribute to open source by using and enhancing this module. Your contributions are welcome!