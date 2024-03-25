locals {

  cluster_log_group_name = var.cluster_type == "primary" ? (
    "/aws/rds/cluster/${aws_rds_cluster.primary[0].cluster_identifier}") : (
  "/aws/rds/cluster/${aws_rds_cluster.secondary[0].cluster_identifier}")

  task_metric_namespace = var.cluster_type == "primary" ? (
    "/System/${aws_rds_cluster.primary[0].cluster_identifier}-log-metrics") : (
  "/System/${aws_rds_cluster.secondary[0].cluster_identifier}-log-metrics")

  alarm_log_configs = local.alarm_count == 1 ? {
    for k, v in var.alarm_log_configs :
    k => merge(v, { metric_namespace = local.task_metric_namespace },
    )
  } : {}

}

resource "aws_cloudwatch_log_metric_filter" "slowquery" {
  for_each       = local.alarm_log_configs
  name           = each.value.metric_name
  pattern        = each.value.filter_pattern
  log_group_name = "${local.cluster_log_group_name}/slowquery"

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.metric_default_value
  }
}

resource "aws_cloudwatch_metric_alarm" "slowquery" {
  for_each = local.alarm_log_configs

  alarm_name = var.cluster_type == "primary" ? (
    "${aws_rds_cluster.primary[0].cluster_identifier}-${each.value.alarm_name}") : (
  "${aws_rds_cluster.secondary[0].cluster_identifier}-${each.value.alarm_name}")

  comparison_operator = each.value.alarm_comparison_operator
  evaluation_periods  = each.value.alarm_evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.metric_namespace
  period              = each.value.alarm_period
  statistic           = each.value.alarm_statistic
  treat_missing_data  = each.value.alarm_treat_missing_data
  threshold           = each.value.alarm_threshold
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Logs-slowquery ) ${each.value.alarm_description} ${var.alarm_config}"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]
  tags = merge(
    var.labels,
    var.tags
  )

}
