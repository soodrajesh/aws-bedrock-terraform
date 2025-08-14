# Amazon Bedrock Terraform Setup

This Terraform configuration sets up Amazon Bedrock with the necessary IAM roles, S3 bucket for logs, and model invocation permissions.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Testing Bedrock Access](#testing-bedrock-access)
- [Invoking Models](#invoking-models)
- [Example: Using Claude v2](#example-using-claude-v2)
- [Clean Up](#clean-up)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## Features

- Creates IAM roles and policies for Bedrock access
- Sets up S3 bucket for model invocation logs
- Configures secure access controls and permissions
- Easy deployment and cleanup with Terraform

**Note:** Bedrock model invocation logging must be enabled via the AWS Console or CLI. Terraform cannot enable logging for Bedrock models directly; it only provisions the S3 bucket for logs.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) installed and configured with profile `raj-private`
- [Terraform](https://www.terraform.io/downloads.html) 1.0.0 or later
- AWS account with Bedrock access enabled
- Sufficient IAM permissions to create resources

## Project Structure

```
.
├── .gitignore           # Specifies intentionally untracked files to ignore
├── README.md            # This documentation file
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
└── outputs.tf           # Output values and next steps
```

## Getting Started

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd aws-bedrock-terraform
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the execution plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply -auto-approve
   ```

5. **Note the outputs** which include important information like the IAM role ARN and S3 bucket name.

## Testing Bedrock Access

After successful deployment, verify access to Bedrock by listing available foundation models:

```bash
aws bedrock list-foundation-models \
  --profile raj-private \
  --region eu-west-1 \
  --query 'modelSummaries[*].modelId' \
  --output table
```

## Invoking Models

### Using the Provided Bash Script (`invoke_claude.sh`)

You can quickly test the Anthropic Claude model via Amazon Bedrock using the included `invoke_claude.sh` script. This script:
- Builds a sample prompt (see `claude_prompt.json` for structure)
- Invokes the Claude 3 Haiku model using the AWS CLI
- Prints the model response or troubleshooting tips if the call fails

**Usage:**
```bash
bash invoke_claude.sh
```
By default, the script uses the profile and region set in `variables.tf`. To use different values, edit the script or export environment variables before running.

---

To invoke a model, you'll need to know its model ID. Here's a general command structure:

```bash
aws bedrock invoke-model \
  --model-id MODEL_ID \
  --content-type "application/json" \
  --body '{"prompt":"Your prompt here"}' \
  output.json \
  --profile raj-private \
  --region eu-west-1
```

## Example: Using Claude v2

```bash
# Create a prompt file
cat > claude_prompt.json << 'EOL'
{
  "prompt": "\n\nHuman: Explain quantum computing in simple terms\n\nAssistant:",
  "max_tokens_to_sample": 500,
  "temperature": 0.5,
  "top_k": 250,
  "top_p": 0.999,
  "stop_sequences": ["\n\nHuman:"],
  "anthropic_version": "bedrock-2023-05-31"
}
EOL

# Invoke Claude v2
aws bedrock invoke-model \
  --model-id anthropic.claude-v2 \
  --content-type "application/json" \
  --body file://claude_prompt.json \
  output.json \
  --profile raj-private \
  --region eu-west-1

# View the response
cat output.json | jq -r '.completion'
```

## Clean Up

To remove all resources created by this configuration:

```bash
terraform destroy -auto-approve
```

## Troubleshooting

### Common Issues

1. **Insufficient Permissions**:
   - Ensure your AWS user has the necessary permissions to create IAM roles, S3 buckets, and Bedrock resources.
   - The IAM user needs at least these permissions:
     - `bedrock:*`
     - `iam:*`
     - `s3:*`

2. **Region Availability**:
   - Verify that Amazon Bedrock is available in your selected region (eu-west-1).
   - Check the [AWS Regional Services List](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/).

3. **Rate Limiting**:
   - Bedrock has rate limits. If you encounter throttling errors, implement exponential backoff in your code.

## Security

- The S3 bucket for logs is configured with strict access controls.
- IAM policies follow the principle of least privilege.
- Sensitive data should never be committed to version control.
- The IAM role is set up for Bedrock service by default. If you wish to use this role with other services (e.g., Lambda, EC2), you may need to adjust the trust policy in `main.tf` accordingly.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
