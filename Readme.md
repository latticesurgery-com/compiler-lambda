### Lattice Surgery Compiler Serverless Deployment

Deploys a lambda containing Python code and sets up an API gateway to call it. Soon this code will be the compiler.

Requires the AWS cli tools with credentials set up, Python 3.9 and pip's `merge-requirements` package with execytable in `$PATH`. Use `git clone --recursive` to clone this repository.

To deploy the first time, run
```
$ ./1-create-bucket.sh
$ ./2-build-layer.sh
$ ./3-deploy.sh
```
After the first time running 2 and 3 is enough.

The other scripts should be self explainatory.
