### Lattice Surgery Compiler Serverless Deployment

[![Unitary Fund](https://img.shields.io/badge/Supported%20By-UNITARY%20FUND-brightgreen.svg?style=for-the-badge)](http://unitary.fund)

Sets up a [serverless stack](https://aws.amazon.com/serverless/) to deploy [Lattice Surgery Error Correcting Compiler](https://github.com/latticesurgery-com/lattice-surgery-compiler) as service.

#### Dependecies
 * Python 3.9
 * Python Pip
 * Docker with daemon running
 * AWS CLI >= 1.19
 * Git version with support for submodules
 
##### Qiskit's build Dependecies 
Building Qiskit (i.e. running pip install) seems to have a slew of dependecies. Fortunately these don't get to the deployed code, but they can make setting up the environment on the deployment host tedious. Some things I noticed to be necessary are:
 * CMAKE
 * gcc
 * g++
 * Bison + Yacc
 
And probably more... I would expect a machine with basic build tools to have most of these (my laptop did), however be prepared to have to install some software, especially if deploying from a minimal installation (like on a fresh EC2 instance - I tried). If qiskit fails to build, then it's very likeley that because of missing some build dependncy. Try pasting the error message into Google.

Also, Qiskit won't build on 32 bit machines. 
 
#### Architecture
 
The serverless stack consists of:
 * An AWS Lambda containing the compiler. This lambda is deployed as a Docker image.
 * An ECS repository to hold the Docker images that
 * An API Gateway to interface the lambda with HTTP calls from the outside world
 * Configuration for logging and moitoring.
 
The Lambda, the API Gateway and the extra Configuration is controlled by the `template.yml` and managed with the numbered shell scripts, whereas the ECS repository is managed directly by the shell scripts.

Normally lambdas can hold pure Python code. The reason why we need to set up the Lambda's code as a Docker image is that Qiskit makes the package too large (>700M) to fit in a regular pure code Lambda (250M).

#### Deployment 

Compiler code is fetched from the respository [lattice-surgery-compiler](https://github.com/latticesurgery-com/lattice-surgery-compiler) as a git submodules. Then the compiler code and Lambda handler are assembled in one directory where the Python/Pip environment is set up. This code goes into

If the stack is already set up, and all you want to do is update the lambda code (i.e. update to a new commit from lattice-surgery-compiler or changes to the handler) then follow the steps in the next section. If you have to set up a new stack from scratch, or update a stack, jump to the section below.

##### Update the Lambda's code

1. Run `1-set-up-layer.sh` and `2-publish-image.sh`. If you run into problems check the explaination in the next section.
2. Then log into the console, go to Lambda, select the lambda you want to update and click "Deploy new image". Choose the repository (should be something like `123456789012.dkr.ecr.ca-central-1.amazonaws.com/lattice-surgery-compiler-lambda-ecr`) and pick the latest image.


##### Set up serverless stack from scratch or update a stack

Before getting started make sure you have an AWS account set up with the folllowing permissions:

 1. `1-set-up-layer.sh` fetches the compiler code and sets up code for the Lambda function in the `function` directory. If building Qiskit fails, do not be discouraged and about its build dependecies above.
 2. `2-publish-image.sh` creates and uploads to an ECS repository a Docker image containing the Lamnda code.
 3. `3-deploy-stack.sh ` creates/deploys with Cloudformation the serverless (SAM) stack consisting of Lambda, API Gateway and logging, as defined in the `template.yml` file.
 
After the whole stack is set up, to make the API public go to the AWS console and:
 1. Create and API Gateway stage.
 2. Create a subdomain endpoint for that API stage. Might have to set up certificates for it.
 3. Go to Route 53 and point the domain to the API endpoint
 
 
#### Troubleshooting
  * Qiskit fails to build: check the "Qiskit's build Dependecies" section.
  * Missing AWS Credentials: run `aws configure`
  * If the Cloud formation stack was once in successfully deployed and then broken - in the `ROLLBACK_COMPLETE_STATE` - delete it and try again.

Requires the AWS cli tools with credentials set up, Python 3.9 and pip's `merge-requirements` package with execytable in `$PATH`. Use `git clone --recursive` to clone this repository.

#### Appendix: patch qiskit-disable-default-aer-patch.diff

This patch disables the automatic loading of qiskit's default Aer provider. This provider loads Python's `multiprocessing` module on import. Importing this module throws an exception due to the fact that the AWS's Lambda environment doesn't implement some basic kernel functionality (namely `/dev/shm`, see https://stackoverflow.com/questions/59638035/using-python-multiprocessing-queue-inside-aws-lambda-function). This patch is applied by `1-set-up-layer.sh`.

