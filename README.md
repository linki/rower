# Rower Operating System

This is a Linux based operating system for container based operations. It is
similar to [CoreOS](https://coreos.com/) (look at it if you don't know it!) in
that it is meant to run all applications packaged in containers. The system
itself is immutable and only driven by a single configuration file. The major
difference is the chosen access level: CoreOS provides full system access
by letting you specify `systemd` units that get executed during boot. This
allows the configuration file to contain imperative logic which is impossible
to understand for a machine without executing it. It also enables the user to
run applications that are not containers at all. Rower only provides a
declarative configuration capability, based on
[Kubernetes' pods](http://kubernetes.io/docs/user-guide/pods/). This allows
other systems to precisly know which artifacts are deployed and running on the
machine. The configuration is typically given by cloud provider's native
metadata service like
[AWS EC2 instance metadata](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html).
This metadata is queryable by AWS users and services.

## Hello, World!

The configuration file for Rower is a
[Kubernetes pod specification](http://kubernetes.io/docs/api-reference/v1/definitions/#_v1_pod).
This is a very simple example of how such a configuration file can look like:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
  - name: webserver
    image: nginx
    ports:
    - containerPort: 80
      hostPort: 80
```

With that configuration, the official `nginx` Docker container will be started
and its port `80` will be exposed by the server.

When launching a new Rower AMI on AWS, provide this YAML configuration as user
data and the server will execute it on start.

TODO provide AWS CloudFormation template for full bootstrapping nginx

You can find more examples of pods in the
[Kubernetes examples](https://github.com/kubernetes/kubernetes/tree/master/examples)
section. Remember that this OS is only executing Pod specifications.
Replication controllers, auto scaling, load balancing and similar
infrastructure capabilities need to be solved by the cloud provider. This
easily integrates with for example the Amazon Web Services. Rower is
specifically made for operating Kubernetes' Pods within the normal AWS
infrastructure, leveraging auto scaling groups, elastic load balancers, etc,
where servers and not containers are the first-class citizens.

## Building the AMI

* Start up a small AWS instance with the Debian 8.x (Jessie) AMI.
* Check out the [bootstrap-vz](https://github.com/andsens/bootstrap-vz)
  repository (Debian official cloud image build tool).
* Check out this repository.
* Set the environment variables `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` to keys
  of an IAM user with EC2 API privileges. ([EC2 instance profiles are currently
  not supported by bootstrap-vz](https://github.com/andsens/bootstrap-vz/issues/259)).
* Run `../bootstrap-vz/bootstrap-vz bootstrap.yaml`.
  * `bootstrap-vz` will complain for all dependencies, that are missing.
    Install them when they pop up. The
    [Amazon EC2 EBS backed AMI](https://github.com/andsens/bootstrap-vz#amazon-ec2-ebs-backed-ami)
    documentation shows which dependencies you probably need.

## Rower on CoreOS

Spin up a CoreOS instance, provide a cloud config as well as a kube spec as metadata:

```
gcloud compute --project "serious-habitat-123456" instances create "coreos-rower-test" \
  --metadata-from-file "user-data=cloud-config.yml","kube-pods=example-userdata.yaml" \
  --image "/coreos-cloud/coreos-alpha-1010-1-0-v20160407" \
  --zone "europe-west1-d" \
  --machine-type "n1-standard-1" \
  --network "default" \
  --maintenance-policy "MIGRATE" \
  --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/cloud.useraccounts.readonly" \
  --boot-disk-size "10" \
  --boot-disk-type "pd-ssd" \
  --boot-disk-device-name "coreos-rower-test"
```

Login to your instance to see the pod running:

```
core@coreos-rower-test ~ $ docker ps
CONTAINER ID        IMAGE                                  COMMAND                  CREATED             STATUS              PORTS                NAMES
4f508375581d        nginx                                  "nginx -g 'daemon off"   8 minutes ago       Up 8 minutes                             k8s_webserver.cbef00d7_example-coreos-rower-test.c.serious-habitat-123456.internal_default_2688346410a632b665b5c91a9c5e0f0b_051ecc79
9ad419a12f0f        gcr.io/google_containers/pause:0.8.0   "/pause"                 8 minutes ago       Up 8 minutes        0.0.0.0:80->80/tcp   k8s_POD.b8dc0109_example-coreos-rower-test.c.serious-habitat-123456.internal_default_2688346410a632b665b5c91a9c5e0f0b_71cf358f
```
̨
## License

Copyright (c) 2016, Tobias Sarnowski

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted,
provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
