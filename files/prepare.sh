#!/usr/bin/env bash

git clone https://github.com/cloud-custodian/cloud-custodian.git;
cd cloud-custodian/;
pip install virtualenv;
go get -u github.com/canadiannomad/terraform-provider-cli
