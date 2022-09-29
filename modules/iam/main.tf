resource "aws_iam_role" "Ec2DefaultInstanceRole" {
  name = "Ec2DefaultInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.Ec2DefaultInstanceRole.name
}

resource "aws_iam_instance_profile" "profile" {
  name = "Ec2DefaultInstanceRole"
  role = aws_iam_role.Ec2DefaultInstanceRole.name
}

output "name" {
  value = aws_iam_role.Ec2DefaultInstanceRole.name
}
