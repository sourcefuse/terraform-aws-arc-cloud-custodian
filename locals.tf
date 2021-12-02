locals {
  tags = merge(var.tags, tomap({
    Stage     = var.stage
    Namespace = var.namespace
  }))
}
