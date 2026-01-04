# Lambda Container vs ZIP Package Benchmark

> **Benchmarking Lambda cold start performance: Container images vs ZIP packages**

This repository contains the benchmark code and results for the blog post ["When Container Images Beat ZIP Packages: Lambda Cold Start Surprises"](https://cloudless.sh/log/lambda-container-images-beat-zip-packages/).

## Overview

This benchmark compares two Lambda packaging approaches using identical 5MB Go bootstrap code:

1. **ZIP Package**: Go bootstrap + shell handler deployed as ZIP with `provided.al2023` runtime
2. **Container Image**: Same bootstrap and handler packaged as container image

## Key Findings

Container images consistently outperformed ZIP packages:

| Metric | ZIP Package | Container Image | Improvement |
|--------|-------------|-----------------|-------------|
| **Average Init** | 42.61ms | 33.51ms | **21% faster** |
| **P80** | 47.30ms | 36.46ms | **23% faster** |

## Architecture

### Hybrid Go + Bash Runtime
- **Go binary** handles Lambda Runtime API communication (eliminates `curl` overhead)
- **Bash functions** handle business logic (simple scripting)

```go
// Fast HTTP client for Lambda API
func (c *runtimeAPIClient) getNextInvocation() (string, []byte, error) {
    resp, err := c.httpClient.Get(c.baseURL + "next")
    // ... handle response
}

// Execute shell function
func executeShellHandler(handlerFile, handlerFunc string, eventData []byte) ([]byte, error) {
    shellCmd := fmt.Sprintf("source %s && %s", handlerFile, handlerFunc)
    cmd := exec.Command("bash", "-c", shellCmd)
    return cmd.Output()
}
```

## Repository Structure

```
provided-dev/
├── app/src/
│   ├── bootstrap          # Compiled Go runtime (5MB)
│   └── handler.sh         # Shell handler functions
├── infra/
│   └── main.tf           # Terraform for both ZIP and container deployments
├── benchmark             # Benchmark runner script
├── invoke               # Lambda invocation script
└── data/                # Benchmark results
```

## Quick Start

### Prerequisites
- AWS CLI configured
- Terraform
- Go 1.21+
- Docker

### Deploy and Benchmark

1. **Build the Go bootstrap:**
```bash
cd app/src/hybrid
go build -ldflags="-w -s" -o ../bootstrap main.go
```

2. **Deploy infrastructure:**
```bash
cd infra
terraform init
terraform apply
```

3. **Run benchmarks:**
```bash
# Benchmark ZIP package
./benchmark cloudless-lambda-os-only-lab-function

# Benchmark container image  
./benchmark cloudless-lambda-os-only-lab-image
```

## Benchmark Methodology

### Forcing Cold Starts
The benchmark uses a clever approach to ensure all invocations are cold starts:

1. **Handler sleep**: Each handler includes `sleep 5` to keep containers busy
2. **High concurrency**: 60 parallel invocations force Lambda to create new containers
3. **No artificial updates**: Avoids function configuration changes that might interfere with caching

```bash
# Benchmark runner
seq 1 120 | parallel -j 60 "$INVOKE_SCRIPT"
```

### Data Collection
```bash
# Extract init durations from CloudWatch logs
aws logs tail --since 1h "/aws/lambda/your-function" \
  | grep "REPORT" \
  | grep -o -E 'Init Duration: (.+) ms' \
  | cut -d' ' -f 3
```

## Results

### ZIP Package (provided.al2023)
```json
{
  "init_count": 60,
  "init_total_ms": 2557.03,
  "init_average_ms": 42.61,
  "p20_ms": 40.41,
  "p40_ms": 40.92,
  "p60_ms": 41.16,
  "p80_ms": 47.30
}
```

### Container Image
```json
{
  "init_count": 60,
  "init_total_ms": 2010.67,
  "init_average_ms": 33.51,
  "p20_ms": 25.71,
  "p40_ms": 28.21,
  "p60_ms": 31.88,
  "p80_ms": 36.46
}
```

## Why Container Images Won

### ZIP Package Overhead
1. **S3 download**: 5MB bootstrap downloaded during cold start
2. **File extraction**: Unzip and filesystem setup
3. **Permission configuration**: Runtime permission setup

### Container Image Advantages  
1. **Pre-built layers**: Bootstrap already in optimized layers
2. **No runtime I/O**: No download/extraction during cold start
3. **Layer caching**: Efficient container infrastructure caching

## The 5MB Threshold

This benchmark suggests there's a **crossover point** where container images become more efficient:

- **Small functions** (< 1MB): ZIP extraction overhead is negligible
- **Large runtimes** (> 5MB): Container layer caching outperforms ZIP extraction

## Terraform Configuration

The infrastructure uses dynamic ECR image resolution:

```hcl
data "aws_ecr_image" "runtime_image" {
  repository_name = module.runtime.image.repository_name
  image_tag       = "latest"
}

module "lambda_image" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git?ref=v1.0.1"
  
  package_type = "Image"
  image_uri    = "${module.runtime.image.name}@${data.aws_ecr_image.runtime_image.image_digest}"
  # ...
}
```

## Running Your Own Benchmarks

1. **Modify the handler** to include appropriate sleep duration
2. **Adjust concurrency** based on your function's expected load
3. **Collect sufficient samples** (60+ cold starts recommended)
4. **Account for log propagation delay** (10-30 seconds)

## Key Insights

1. **Container images can be faster** than ZIP packages for larger runtimes
2. **Conventional wisdom** doesn't always apply at scale
3. **Real-world benchmarking** reveals performance characteristics not captured in documentation
4. **Packaging format choice** should be based on actual measurements, not assumptions

## Related Projects

- [lambda-shell-runtime](https://github.com/ql4b/lambda-shell-runtime) - Custom Lambda runtime for Bash functions
<!-- - [echo service](https://github.com/ql4b/echo) - Configurable echo API for load testing -->

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

*This benchmark was created to validate the findings in ["When Container Images Beat ZIP Packages: Lambda Cold Start Surprises"](https://cloudless.sh/log/lambda-container-images-beat-zip-packages). Results may vary based on function size, complexity, and AWS infrastructure changes.*