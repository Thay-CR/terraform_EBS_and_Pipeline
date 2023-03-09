# resource "aws_codecommit_repository" "test" {
#   repository_name = "MyTestRepository"
#   description     = "This is the Sample App Repository"
# }

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"


  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = { # Required for CodeCommit and GitHub actions, optional for S3 actions.  

        RepositoryName = "MyTestRepository" #aws_codecommit_repository.test.repository_name

        BranchName = "main" # Optional for all types of source action - defaults to main if omitted for CodeCommit and GitHub, and no versioning if omitted for S3 actions.  

        PollForSourceChanges = true # Optional - defaults to false if omitted (not recommended).  

        # Additional configuration options may be available depending on the source provider used (e.g., OAuth token).   Refer to the Terraform documentation or the provider's documentation for more information on available options and their usage/syntax/etc..  

      }
    }
  }

  # stage {
  #   name = "Build"
  #   action {
  #     name             = "Build"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     input_artifacts  = ["source_output"]
  #     output_artifacts = ["build_output"]
  #     version          = "1"

  #     configuration = {
  #       enabled = false
  #       ProjectName = "test" 
  #     }

  #   }

  # }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = "tentando"
        EnvironmentName = "tentando"
      }
    }
  }
}


resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "my-test-pipeline"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "codecommit:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
      {
      "Effect": "Allow",
      "Action": [
          "elasticbeanstalk:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
        {
      "Effect": "Allow",
      "Action": [
          "cloudformation:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
  {
      "Effect": "Allow",
      "Action": [
          "ec2:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
    {
      "Effect": "Allow",
      "Action": [
          "autoscaling:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
{
      "Effect": "Allow",
      "Action": [
          "logs:*"
      ],
      "Resource": [
          "*"  
      ] 
  },
  {
      "Effect": "Allow",
      "Action": [
          "elasticloadbalancing:*"
      ],
      "Resource": [
          "*"  
      ] 
  }

  ]
}
EOF
}



