{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::bic-photstory",
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
}
