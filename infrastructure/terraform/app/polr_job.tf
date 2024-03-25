
// due to polr api doesn't have method to delete links use sqlselect to delete old data
resource "kubernetes_cron_job_v1" "polr_db_clean" {
  count    = local.polr_helm_count
  provider = kubernetes.eks
  metadata {
    name      = "${local.polr_chart_name}-db-clean"
    namespace = local.polr_namespce_name
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0 */6 * * *"
    timezone                      = "Etc/UTC"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 600
        template {
          metadata {}
          spec {
            container {
              name    = "polr-job"
              image   = "mysql"
              command = ["/bin/sh", "-c", "echo $(polr_dbhost); mysql -h $(polr_dbhost)  -u $(polr_dbuser) -p$(polr_dbpass) -se 'DELETE FROM mydatabase.links WHERE updated_at < (NOW() - INTERVAL 90 DAY);'"]

              env_from {
                secret_ref {
                  name = local.polr_chart_name
                }
              }
            }
          }
        }
      }
    }
  }
}