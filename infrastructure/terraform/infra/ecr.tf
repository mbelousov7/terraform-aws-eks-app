resource "aws_ecr_repository" "ecr_repos" {
  for_each             = toset(var.ecr_repos)
  name                 = each.key
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = false
  }

}