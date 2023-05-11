variable "tag" {
  type        = string
  description = "Project identification tag"
  default     = "static-website"
}

variable "www_url" {
  type        = string
  description = "the www url for the website"
  default     = "www.visham.org"
}

variable "favicon_path" {
  type        = string
  description = "path to favicon png file"
  default     = "images/favicon.png"
}

variable "url" {
  type        = string
  description = "The url for the website"
  default     = "visham.org"
}

variable "region" {
  type        = string
  description = "AWS default region"
  default     = "ap-southeast-2"
}

variable "route53_zone_id" {
  type        = string
  description = "zone id of the route53 hosted zone that contains our website"
  default     = "Z02024842F73WIP3EA0PB"
}

variable "root_html" {
  type        = string
  description = "HTML root file to be loaded first"
  default     = "index.html"
}