variable vpc_cidr {
    type = string
    default = "10.0.0.0/16"
}

# for public ip's use odd numbers
variable public_subnets {
    type = list(string)
    default = [
        "10.0.1.0/24",
        "10.0.3.0/24",
        ]
}


# odd numbers for public subnets
variable "num_public_subnets" {
  description = "Number of public subnets"
  type        = number
#   change default number as much as you need
  default     = 2
}


variable access_ip {
    type = list(string)
    # for security find your ip addres and put it here
    default = ["0.0.0.0/0"]
}

variable main_instance_type {
  type = string
  default = "t2.micro"
}

variable main_instance_count {
  type = number
  default = 1
}

variable main_vol_size {
  type = number
  default = "20"
}

variable key_name {
    type = string
}

variable public_key_path {
    type = string
}