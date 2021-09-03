version: 0.2
phases:
  build:
    commands:
      - aws cloudfront create-invalidation --distribution-id ${distribution_id} --paths "/*"