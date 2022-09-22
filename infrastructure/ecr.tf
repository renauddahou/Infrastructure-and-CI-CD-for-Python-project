resource "aws_ecr_repository" "ecr-rep" {
  name = local.prefix
  tags = local.default_tags
  force_delete = true
}

resource "aws_ecr_repository_policy" "internal-access" {
  repository = aws_ecr_repository.ecr-rep.name
  policy = jsonencode (
    {
      "Version": "2008-10-17",
      "Statement": [
        {
          "Sid": "AllowPushPull",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "*"
            ]
          },
          "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload"
          ]
        }
      ]
    }
  )
}

resource "null_resource" "images" {
  depends_on = [
    aws_ecr_repository.ecr-rep
  ]
   provisioner "local-exec" {
    command = <<EOT
      cd ../boxer && docker build -t ${var.image_name} .
      docker tag ${var.image_name} ${aws_ecr_repository.ecr-rep.repository_url} 
      docker push ${aws_ecr_repository.ecr-rep.repository_url}
  EOT
  }
}