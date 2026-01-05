# Runtime Layer Architecture Experiment

> **Testing the runtime-as-a-layer pattern for shell-based Lambda functions**

This experiment validates deploying the Go bootstrap runtime as a Lambda layer while keeping shell handlers as lightweight function packages.

## Architecture

### Traditional Monolithic Approach
```
function.zip (2.3MB)
├── bootstrap (Go runtime - 2.3MB)
└── handler.sh (Shell logic - ~1KB)
```

### Runtime Layer Approach
```
runtime-layer.zip (2.3MB)
└── bootstrap (Go runtime)

function.zip (~1KB)
└── handler.sh (Shell logic)
```

## Performance Results

**Runtime Layer Performance:**
```json
{
  "init_count": 63,
  "init_total_ms": 1373.42,
  "init_average_ms": 21.80,
  "p20_ms": 20.28,
  "p40_ms": 20.56,
  "p60_ms": 21.06,
  "p80_ms": 23.88
}
```

**Comparison with Monolithic:**

| Metric | Monolithic | Runtime Layer | Difference |
|--------|------------|---------------|------------|
| **Average Init** | 21.31ms | 21.80ms | +0.49ms |
| **P20** | 19.99ms | 20.28ms | +0.29ms |
| **P80** | 23.74ms | 23.88ms | +0.14ms |

## Key Findings

1. **Zero Performance Penalty** - Runtime layers add <0.5ms overhead (within measurement variance)
2. **Deployment Efficiency** - Runtime deployed once, shared across multiple functions
3. **Package Size** - Function packages reduced from 2.3MB to ~1KB (99.96% reduction)
4. **Architecture Benefits** - Clean separation between runtime and business logic

## Benefits

### For Development
- **Faster deployments** - Only redeploy function when handler changes
- **Smaller packages** - Function ZIP files are tiny
- **Version independence** - Runtime and handlers evolve separately

### For Operations
- **Shared runtime** - One layer serves multiple functions
- **Cost efficiency** - Reduced storage and transfer costs
- **Maintenance** - Runtime updates don't require function redeployment

## Usage

```hcl
# Deploy runtime layer once
module "shell_runtime_layer" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-layer.git"
  
  name       = "shell-runtime"
  source_dir = "./runtime/build"
  
  compatible_architectures = ["arm64"]
  compatible_runtimes      = ["provided.al2023"]
}

# Deploy multiple functions using the layer
module "my_function" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git"
  
  name       = "my-shell-function"
  source_dir = "./app/src"
  
  runtime      = "provided.al2023"
  handler      = "handler.run"
  architecture = "arm64"
  
  layers = [module.shell_runtime_layer.layer_arn]
}
```

## Conclusion

The runtime-as-a-layer pattern provides the optimal architecture for shell-based Lambda functions:
- **Performance**: Identical to monolithic approach
- **Efficiency**: 99.96% reduction in function package size
- **Scalability**: One runtime layer serves multiple functions
- **Maintainability**: Clean separation of concerns

This validates the pattern as the recommended approach for production shell Lambda deployments.