
# About

This repository provisions the AWS infrastructure used to train a deep learning model using either `P3` or Habana `DL1` instances. Specifically, this infrastructure aids in training a PyTorch [re-implementation of DCGAN]([msls-dcgan](https://github.com/DMW2151/msls-pytorch-dcgan)). Generally, the system architecture can be described by the image below:

![msls-gan-architecture](images/arch.png)

## Usage

**N.B**:

- **WARNING:** This module deploys live resources into your AWS account, please be mindful of the costs associated with those resources.
  
- **NOTE:** This module does not download (nor provision pipelines to download) MSLS data, you may access it from your own signed URL [here](https://www.mapillary.com/dataset/places)

If you're so inclined, you can replicate the full architecure by running `terraform apply` from this repository. However, I suspect your time would be better served by simply cloning `msls-dcgan` to a standalone Sagemaker or EC2 (`DL1`) instance. If you're resolute in your desire to run this precise architecture, please review the variable definitions in each of the modules' `variable.tf` files and adjust accordingly.
