provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "idn_new_timmy_2" {
  bucket = "idn-new-timmy-2"
}

resource "aws_s3_bucket_public_access_block" "idn_new_timmy_2" {
  bucket = aws_s3_bucket.idn_new_timmy_2.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "idn_new_timmy_2" {
  bucket = aws_s3_bucket.idn_new_timmy_2.bucket

  policy = jsonencode({
    Version = "2024101502",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.idn_new_timmy_2.arn}/*", 
      },
    ],
  })
}

data "aws_s3_bucket" "bucket_new_timmy_idn" {
  bucket = "bucket-new-timmy-idn"
}

resource "aws_cloudfront_distribution" "new_timmy_2" {

  origin {
    domain_name = aws_s3_bucket.idn_new_timmy_2.bucket_regional_domain_name
    origin_id   = "S3-idn-new-timmy-2"
  }

  origin {
    domain_name = data.aws_s3_bucket.bucket_new_timmy_idn.bucket_regional_domain_name
    origin_id   = "S3-bucket-new-timmy-idn"
  }

  default_cache_behavior {
    target_origin_id       = "S3-idn-new-timmy-2"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/asset-img-broken.png"
    target_origin_id       = "S3-bucket-new-timmy-idn"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  default_root_object = "index.html"
  aliases 			  = [ "new-timmy-2.serverless.my.id" ]
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
	  locations = [ "IL" ]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:166190020492:certificate/1119d63b-db83-4afb-b726-4a8944f6ec7f" # Replace with your ACM certificate ARN
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}

resource "aws_route53_record" "subdomain" {
  zone_id = "Z03102443KHY48QVUVSK9"
  name    = "new-timmy-2.serverless.my.id"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.new_timmy_2.domain_name
    zone_id                = aws_cloudfront_distribution.new_timmy_2.hosted_zone_id
    evaluate_target_health = false
  }
}
