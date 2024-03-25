locals {

  alarm_count = var.alarm_enable == true ? 1 : 0


  names = {
    cpu_utilization    = "cpu-utilization-${var.labels.env}"
    memory_utilization = "memory-utilization-${var.labels.env}"
    aborted_clients    = "aborted-clients-${var.labels.env}"
    volume_read_iops   = "volume-read-iops-${var.labels.env}"
    volume_write_iops  = "volume-write-iops-${var.labels.env}"
  }
  thresholds = {
    cpu_utilization    = min(max(var.cpu_utilization_threshold, 0), 100)
    memory_utilization = 1000000000 * max(min(var.memory_utilization_threshold, 0), 0)
    aborted_clients    = min(max(var.aborted_clients_threshold, 0), 100)
    volume_read_iops   = 1000000 * min(max(var.volume_read_iops_threshold, 0), 100)
    volume_write_iops  = 1000000 * min(max(var.volume_write_iops_threshold, 0), 100)
  }

}


############################################### instance level alarms ###############################################

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = local.alarm_count == 1 ? (
    var.cluster_type == "primary" ? length(aws_rds_cluster_instance.primary) : length(aws_rds_cluster_instance.secondary)
  ) : 0

  alarm_name = var.cluster_type == "primary" ? (
    "${local.db_primary_instance}-${count.index + 1}-${local.names["cpu_utilization"]}") : (
  "${local.db_secondary_instance}-${count.index + 1}-${local.names["cpu_utilization"]}")

  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "6"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["cpu_utilization"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | CPU ) Average DB instance-${count.index} CPU utilization over last 30 minutes too high ~>${local.thresholds["cpu_utilization"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    DBInstanceIdentifier = var.cluster_type == "primary" ? (
      aws_rds_cluster_instance.primary[count.index].identifier) : (
    aws_rds_cluster_instance.secondary[count.index].identifier)
  }
  tags = merge(
    var.labels,
    var.tags
  )
}


resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count = local.alarm_count == 1 ? (
    var.cluster_type == "primary" ? length(aws_rds_cluster_instance.primary) : length(aws_rds_cluster_instance.secondary)
  ) : 0

  alarm_name = var.cluster_type == "primary" ? (
    "${local.db_primary_instance}-${count.index + 1}-${local.names["memory_utilization"]}") : (
  "${local.db_secondary_instance}-${count.index + 1}-${local.names["memory_utilization"]}")

  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "6"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["memory_utilization"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Memory ) Average DB instance-${count.index} Avaliable memory over last 30 minutes too low, < 8 GB ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    DBInstanceIdentifier = var.cluster_type == "primary" ? (
      aws_rds_cluster_instance.primary[count.index].identifier) : (
    aws_rds_cluster_instance.secondary[count.index].identifier)
  }
  tags = merge(
    var.labels,
    var.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "aborted_clients" {
  count = local.alarm_count == 1 ? (
    var.cluster_type == "primary" ? length(aws_rds_cluster_instance.primary) : length(aws_rds_cluster_instance.secondary)
  ) : 0

  alarm_name = var.cluster_type == "primary" ? (
    "${local.db_primary_instance}-${count.index + 1}-${local.names["aborted_clients"]}") : (
  "${local.db_secondary_instance}-${count.index + 1}-${local.names["aborted_clients"]}")

  comparison_operator = "GreaterThanThreshold"
  metric_name         = "AbortedClients"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "6"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["aborted_clients"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Connections ) Average DB instance-${count.index} AbortedClients over last 30 minutes too high ~>${local.thresholds["aborted_clients"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    DBInstanceIdentifier = var.cluster_type == "primary" ? (
      aws_rds_cluster_instance.primary[count.index].identifier) : (
    aws_rds_cluster_instance.secondary[count.index].identifier)
  }
  tags = merge(
    var.labels,
    var.tags
  )
}



############################################### Cluster level alarms ###############################################

resource "aws_cloudwatch_metric_alarm" "volume_read_iops" {
  count = local.alarm_count == 1 ? (
    var.cluster_type == "primary" ? length(aws_rds_cluster.primary) : length(aws_rds_cluster.secondary)
  ) : 0
  alarm_name = var.cluster_type == "primary" ? (
    "${join("", aws_rds_cluster.primary.*.cluster_identifier)}-${local.names["volume_read_iops"]}") : (
  "${join("", aws_rds_cluster.secondary.*.cluster_identifier)}-${local.names["volume_read_iops"]}")
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "VolumeReadIOPs"
  namespace           = "AWS/RDS"
  period              = "3600" //VolumeReadIOPs metric granularity is 3h
  evaluation_periods  = "3"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["volume_read_iops"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | IOPs ) Average DB cluster VolumeReadIOPs over last 3h minutes too high ${var.alarm_config}"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]
  dimensions = {
    DBClusterIdentifier = var.cluster_type == "primary" ? (
      join("", aws_rds_cluster.primary.*.cluster_identifier)) : (
    join("", aws_rds_cluster.secondary.*.cluster_identifier))
  }
  tags = merge(var.labels, var.tags)
}

resource "aws_cloudwatch_metric_alarm" "volume_write_iops" {
  count = local.alarm_count == 1 ? (
    var.cluster_type == "primary" ? length(aws_rds_cluster.primary) : length(aws_rds_cluster.secondary)
  ) : 0
  alarm_name = var.cluster_type == "primary" ? (
    "${join("", aws_rds_cluster.primary.*.cluster_identifier)}-${local.names["volume_write_iops"]}") : (
  "${join("", aws_rds_cluster.secondary.*.cluster_identifier)}-${local.names["volume_write_iops"]}")
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "VolumeWriteIOPs" //VolumeWriteIOPs metric granularity is 3h
  namespace           = "AWS/RDS"
  period              = "3600"
  evaluation_periods  = "3"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["volume_write_iops"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | IOPs ) Average DB cluster VolumeWriteIOPs over last 3h minutes too high ${var.alarm_config}"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]
  dimensions = {
    DBClusterIdentifier = var.cluster_type == "primary" ? (
      join("", aws_rds_cluster.primary.*.cluster_identifier)) : (
    join("", aws_rds_cluster.secondary.*.cluster_identifier))
  }
  tags = merge(var.labels, var.tags)
}