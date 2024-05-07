terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# create an S3 bucket by using the aws_s3_bucket resource

resource "aws_s3_bucket" "terraform_state" { 
  bucket = "terraform‐up‐and‐running‐state" 
  
  # Prevent accidental deletion of this S3 bucket 
  lifecycle { 
    prevent_destroy = true 
  } 
} 

# enable versioning on the S3 bucket 
resource "aws_s3_bucket_versioning" "enabled" { 
  bucket = aws_s3_bucket.terraform_state.id 
  versioning_configuration { 
    status = "Enabled" 
  } 
} 

# use the aws_s3_bucket_server_side_encryption_configuration resource  
# to turn server‐side encryption on by default for all data written to this S3 bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "default" { 
  bucket = aws_s3_bucket.terraform_state.id 
  rule { 
    apply_server_side_encryption_by_default { 
      sse_algorithm = "AES256"
      	}
      }
   }

   resource "aws_s3_bucket_public_access_block" "public_access" { 
  bucket                  = aws_s3_bucket.terraform_state.id 
  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
} 

# use the aws_s3_bucket_public_access_block resource to block all public access to the S3 bucket. 

resource "aws_dynamodb_table" "terraform_locks" { 
  name         = "terraform‐up‐and‐running‐locks" 
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "LockID" 
   
  tags = { 
    Name = "DynamoDB Terraform State Lock Table" 
  } 
  attribute { 
    name = "LockID" 
    type = "S" 
  } 
} 

#output
output "s3_bucket_arn" { 
  value       = aws_s3_bucket.terraform_state.arn 
  description = "The ARN of the S3 bucket" 
} 
output "dynamodb_table_name" { 
  value       = aws_dynamodb_table.terraform_locks.name 
  description = "The name of the DynamoDB table" 
} 