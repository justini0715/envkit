# Test Spec — macOS Experimental Support

## Verification
- `make lint`
- `make format-check`
- `./envkit test`
- `./tests/macos_experimental_smoke.sh`
- `./tests/phase3-packaging-smoke.sh`

## Expected
- Linux path stays green
- macOS smoke confirms brew-based package/bootstrap/doctor/verify/configure behavior
