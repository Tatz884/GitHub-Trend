variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "github-trend"
}

variable "container_cpu" {
  description = "Container cpu"
  default     = "2000m"
}

variable "container_memory" {
  description = "Container memory"
  default     = "2G"
}

variable "project_id" {
  type        = string
  description = "The name of the project"
  default     = "ringed-reach-414622"
}

variable "region" {
  type        = string
  description = "The default compute region"
  default     = "asia-northeast1"
}

variable "zone" {
  type        = string
  description = "The default compute zone"
  default     = "asia-northeast1-b"
}

variable "repository" {
  type        = string
  description = "The name of the Artifact Registry repository to be created"
  default     = "mage-data-prep"
}

# variable "database_user" {
#   type        = string
#   description = "The username of the Postgres database."
#   default     = "mageuser"
# }

# variable "database_password" {
#   type        = string
#   description = "The password of the Postgres database."
#   sensitive   = true
# }

variable "docker_image" {
  type        = string
  description = "The docker image to deploy to Cloud Run."
  default     = "tty884/github-trend:latest"
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type        = string
  default     = ""
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = false
}
