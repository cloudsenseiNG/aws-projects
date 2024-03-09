output "loadbalancer" {
  value = module.loadbalancer.loadbalancer_dns
}

output "cloudfront_url" {
  value = module.cloudfront.cloudfront_url
}