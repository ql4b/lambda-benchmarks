# lambda-benchmarks

> **AWS Lambda performance benchmarks and cold start analysis**

Real-world performance testing for AWS Lambda packaging formats, runtimes, and deployment strategies.

## Current Benchmarks

### [Packaging Performance](./packaging/)
Container images vs ZIP packages for Lambda cold start performance. **Key finding**: Container images are 21-36% faster for larger runtimes (5MB+).

- **ZIP Package**: 42.61ms average init time
- **Container Image**: 33.51ms average init time
- **Improvement**: 21% faster cold starts

Read the full analysis](https://cloudless.sh/log/lambda-container-images-beat-zip-packages/)

## Planned Benchmarks

- **Memory allocation** - Performance across different memory configurations
- **Runtime comparison** - Python vs Node.js vs Go vs custom runtimes
- **Architecture** - x86_64 vs ARM64 performance characteristics
- **Cold start scenarios** - Various triggers and optimization strategies

## Methodology

- **Controlled environments** - Identical code across test scenarios
- **Statistical significance** - 60+ measurements per benchmark
- **Real cold starts** - No artificial function updates that interfere with caching
- **Comprehensive metrics** - Average, percentiles, and variance analysis

## Complete Journey

This research culminated in the definitive guide: [Shell Functions as Lambda: The Complete Journey to Sub-25ms Cold Starts](https://cloudless.sh/log/shell-functions-lambda-complete-journey/)

The journey from pure Bash to optimized runtime layers, with complete performance data and architectural insights.

## Contributing

Have ideas for Lambda performance tests? Open an issue or submit a PR with your benchmark scenario.

