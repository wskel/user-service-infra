# user-service Infrastructure

## Overview

This project manages the infrastructure for the user-service application using Terraform. It's designed to support
multiple environments and is organized into modules for better maintainability and flexibility. The application is
deployed using Amazon ECS with Fargate launch type.

## Project Structure

The project is organized as follows:

- `modules/`: Reusable Terraform modules
    - `vpc/`: Network infrastructure module
    - `rds/`: Database infrastructure module
    - `ecs/`: Compute resources module
    - `ses/`: Email service module
- `environments/`: Environment-specific configurations
    - `dev/`: Development environment configuration
    - `prod/`: Production environment configuration
- `dns/`: DNS setup configuration (separate subproject)
    - `environments/`: Environment-specific DNS configurations
        - `dev/`: Development DNS configuration
        - `prod/`: Production DNS configuration
- `config.tf`: Contains a `locals` block with derived configurations
- `container_env_config.tf`: Environment variables for the container
- `main.tf`: Main Terraform configuration file
- `provider.tf`: Provider configuration
- `variables.tf`: Input variable definitions

## Configuration

The project uses several configuration files:

1. `variables.tf`: Defines input variables for the project.
2. `config.tf`: Contains a `locals` block with derived configurations.
3. `container_env_config.tf`: Defines environment variables for the container.
4. `environments/<env>/terraform.tfvars`: Environment-specific variable values.
5. `environments/<env>/variables.tf`: Defines environment-specific input variables.

## Prerequisites

This Terraform configuration requires the following setup and AWS resources:

### 1. S3 Bucket for Terraform State

An S3 bucket to store the Terraform state files:

- Name: `01929810-289b-71b6-b4e1-f1252fcef840`
- Region: `us-east-1`
- Versioning: Enabled
- Server-side encryption: Enabled (use AES-256)
- Block Public Access: Enabled (block all public access)

To create this bucket using the AWS CLI:

```
aws s3api create-bucket --bucket 01929810-289b-71b6-b4e1-f1252fcef840 --region us-east-1
aws s3api put-bucket-versioning --bucket 01929810-289b-71b6-b4e1-f1252fcef840 --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket 01929810-289b-71b6-b4e1-f1252fcef840 --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
aws s3api put-public-access-block --bucket 01929810-289b-71b6-b4e1-f1252fcef840 --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### 2. DynamoDB Table for State Locking

A DynamoDB table for state locking and consistency:

- Table Name: `01929810-289b-71b6-b4e1-f1252fcef840-locks`
- Partition Key: `LockID` (String)
- Region: Same as the S3 bucket

To create this table using the AWS CLI:

```
aws dynamodb create-table \
    --table-name 01929810-289b-71b6-b4e1-f1252fcef840-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

### 3. DNS Configuration and Route 53 Hosted Zones

Before running the main Terraform configuration, set up the Route 53 hosted zone using the DNS subproject:

1. Navigate to the appropriate environment directory in the DNS subproject (e.g., `dns/environments/dev/`).
2. Create or update the `terraform.tfvars` file with the necessary values:
   ```
   echo 'domain_name = "example.com" > terraform.tfvars
   ```
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Review the planned changes:
   ```
   terraform plan
   ```
5. Apply the configuration:
   ```
   terraform apply
   ```
6. After applying the DNS configuration, note the outputs:
    - `route53_zone_id`: Required for the main infrastructure configuration.
    - `name_servers`: Required for configuring the domain registrar.
7. Update the domain registrar's NS records with the name servers provided in the output.
8. Wait for the DNS changes to propagate (this can take up to 48 hours, but often happens much faster).

Important Notes:

- The state for the DNS configuration is stored in the shared S3 backend in a separate state. This is
  intentional, as the hosted zone should persist even if the main infrastructure is torn down.
- Each environment (dev, prod) has its own DNS configuration and state file.

## Usage

To manage the infrastructure, follow these steps:

1. Navigate to the desired environment directory (e.g., `environments/dev/`).

2. Create or update the `terraform.tfvars` file with the necessary values:
   ```
   echo 'domain_name = "example.com"
   route53_zone_id = "Z0123456789ABCDEFGHIJ"' > terraform.tfvars
   ```

3. Initialize Terraform:
   ```
   terraform init
   ```

4. Review the planned changes:
   ```
   terraform plan
   ```

5. Apply the changes:
   ```
   terraform apply
   ```

6. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Notes

- Each environment (dev, prod) has its own state file in the S3 backend.
- Ensure the correct environment directory is selected before running Terraform commands.
- The root module is referenced by the environment-specific configurations.
- The DNS subproject follows the same environment-based structure as the main project.

## Post-Deployment Steps

After successfully deploying the infrastructure with Terraform:

### 1. Generate and Set up JWT Secret

To generate a secure random string and add it as the JWT secret to AWS Secrets Manager, use the following AWS CLI
command:

```
aws secretsmanager put-secret-value \
    --secret-id "<environment>/<app_name>/jwt/secret" \
    --secret-string "$(aws secretsmanager get-random-password \
        --password-length 512 \
        --exclude-punctuation \
        --require-each-included-type)"
```

### 2. Verify Secret Creation

After setting up the secret, verify its existence and metadata (without exposing the secret value) using the
following AWS CLI command:

```
aws secretsmanager describe-secret --secret-id "<environment>/<app_name>/jwt/secret"
```

This command will return metadata about the secret, including its ARN, name, and other details, but not the secret value
itself.

### Important Notes

- This process temporarily exposes the secret on the local machine. Ensure this is done in a secure environment.
- Restrict access to the secret in AWS Secrets Manager to authorized personnel only.

### 3. Set Up Continuous Integration for ECR Deployments

After setting up the secrets, configure the CI pipeline to build and push the Docker image to the ECR
repository:

1. In the CI configuration, add steps to authenticate with ECR:
   ```yaml
   - name: Configure AWS credentials
     uses: aws-actions/configure-aws-credentials@v4
     with:
       aws-access-key-id: ${{ secrets.CI_AWS_ACCESS_KEY_ID }}
       aws-secret-access-key: ${{ secrets.CI_AWS_SECRET_ACCESS_KEY }}
       aws-region: <region>

   - name: Login to Amazon ECR
     id: login-ecr
     uses: aws-actions/amazon-ecr-login@v1
   ```

2. Add a step to build and tag the Docker image:
   ```yaml
   - name: Build and tag Docker image
     env:
       ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
       ECR_REPOSITORY: <app_name>-repo-<environment>
       IMAGE_TAG: ${{ github.sha }}
     run: |
       docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
       docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
   ```

3. Add a step to push the image to ECR:
   ```yaml
   - name: Push image to Amazon ECR
     env:
       ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
       ECR_REPOSITORY: <app_name>-repo-<environment>
       IMAGE_TAG: ${{ github.sha }}
     run: |
       docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
       docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
   ```

4. Grant the CI pipeline the required AWS permissions for ECR pushes, typically via an IAM user with appropriate
   access.
