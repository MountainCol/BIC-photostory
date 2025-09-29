resource "aws_iam_policy" "terraform_state_policy"{
    name = "terraform_state_policy"
    description = "Policy for Terraform state file"
    

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
              "Resource": "aarn:aws:s3:::bic-photostory",
              "Condition": {
                "StringEquals": {
                  "s3:prefix": "bic-photstory/terraform.tfstate"
                }
            }
        },
        {
          "Effect": "Allow",
          "Action": ["s3:GetObject", "s3:PutObject"],
        "Resource": [
            "arn:aws:s3:::bic-photstory/terraform.tfstate"
        ]
    },
    {
        "Effect": "Allow",
        "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        "Resource": [
            "arn:aws:s3:::bic-photstory/terraform.tfstate.tflock"
        ]
        }
      ] 
    })
}
