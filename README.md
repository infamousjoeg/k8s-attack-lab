# Kubernetes Attack Hands-On Lab

Attacking Kubernetes defaults to show insecurity out of the box and where to focus security improvements and recommendations.  This is used for CyberArk enablement internally.

## Setup

1. Open [startMultiple.sh]() and set the `for` loop to `1..n` where `n` is equal to the total number of namespaces you'd like to create.  For a classroom holding 40 users, the `for` loop would be `1..40`.
2. Run [startMultiple.sh]().
3. It will create a namespace with web terminal for each user. The web terminal is accessible at `http://<public_ip>:30001` through `http://<public_ip>:300xx` where `xx` is equal to `n` from Step 1.
4. Begin recon & attack of the application container you have gained root to.

## Capture the Flag (Goal)

You will need to navigate from the web terminal application container to a redis container within the same namespace. From the redis container, you will need to capture the flag that is a Kubernetes Secret given to redis.

## Solution

A video and text file is available in the [workshopSolution]() directory.

## Contributors

This hands-on lab was developed by CyberArk Labs.  It is not supported.

## License

MIT