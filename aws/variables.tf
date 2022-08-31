# number of spot instances
variable instances {
    default = 20
}  

variable scale_on_instance {
    default = 5
}

variable rotate_every_minutes {
    default = 20
}

# region
variable region {
    default = "eu-west-1"
}
