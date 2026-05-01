# cloud-projects

Bunch of cloud mini-projects on aws, gcp & terraform for teaching and reference.

<p align="center">
  <img src="https://cdn.simpleicons.org/amazonaws/232F3E" alt="AWS" width="56" height="56" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.simpleicons.org/googlecloud/4285F4" alt="Google Cloud" width="56" height="56" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.simpleicons.org/terraform/844FBA" alt="Terraform" width="56" height="56" />
</p>

## Projects

- **[Serverless Api & Auth](./serverless-api/README.md)** — Serverless HTTP API (API Gateway REST + Lambda authorizer/read/write + DynamoDB) via Terraform.  
**Tags:** `AWS` `Terraform` `Lambda` `API Gateway` `DynamoDB` `Typescript`

- **[Light Switch](./light-switch/README.md)** — Lambda + EventBridge Scheduler to start/stop tagged Dev EC2 and RDS on a weekly cron.  
**Tags:** `AWS` `Terraform` `Lambda` `EventBridge Scheduler` `EC2` `RDS` `Python`

## Conventions (for new projects)

- Each project lives in its own folder and has its own `README.md`.
- Prefer folder links like `./some-project/` so GitHub renders that folder’s `README.md` automatically.
- Keep tags from a small, consistent vocabulary to avoid duplicates.

