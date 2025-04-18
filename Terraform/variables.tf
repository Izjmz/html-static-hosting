variable "ami_id" {
  description = "AMI's ID (e.g, i-08ad547f0af4a9xxx)"
  type    = "string"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}

variable "instance_type"{
	description = "Instance type"
	type 		= "string"
	default		= "t2.micro"
}

variable "region" {
  description = "Instance's region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.region in["us-east-1", "us-west-1", "eu-west-1"]
    error_message = "Region MUST be us-east-1, us-west-1, or eu-west-1."
  }
}
variable "volume_type"{
	description = "Instance's volume type"
	type 		= "string"
}

variable "volume_size"{
	description = "Instance's volume size"
	type 		= "number"
	default		= "15"
}
