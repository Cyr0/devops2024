locals {
    env_to_azs = {
    dev = ["il-central-1a"],
    test = ["il-central-1a"],
    preprod = ["il-central-1a", "il-central-1b"],
    prod = ["il-central-1a", "il-central-1b"]
  }
}
