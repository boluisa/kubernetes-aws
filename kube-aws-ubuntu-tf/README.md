# tf-aws-kubernetes

This is a PoC for using [Terraform](https://terraform.io) to build and deploy a [Kubernetes](http://kubernetes.io/) cluster to an AWS VPC.

Currently this is a PoC, and proper security measures are not implemented.

Repeat after me: **not for production use**

## Things you will need

  * An Amazon Web Services account
  * Potentially a few $ (this demo spawns several t2.small / m3.mediums)
  * [Terraform](https://terraform.io)

## Create a keypair in AWS
  * [There's plenty of ways to do this.](http://bfy.tw/Zlu) Remember your `keypair` name.

## Create your tfvars file
```bash
$ cp terraform.tfvars.tmpl terraform.tfvars
```
This file serves as your main config for your AWS keys etc. Use your `keypair` name here. Also make sure to use your IP CIDR for `allowed_network`, otherwise
you won't be able to connect to the cluster.


## Build the cluster
```bash
$ terraform apply
```

## Create a tunnel for `kubectl`
```bash
$ $(terraform output create-tunnel)
```

## Check your nodes
```bash
$ kubectl get nodes
```
```
NAME         LABELS                              STATUS
10.0.0.110   kubernetes.io/hostname=10.0.0.110   Ready
10.0.0.16    kubernetes.io/hostname=10.0.0.16    Ready
10.0.0.52    kubernetes.io/hostname=10.0.0.52    Ready
```

## Open the UI in your browser
```bash
$ open $(terraform output ui-url)
```

## SSH into the master
```bash
$ ssh core@$(terraform output master-ip)
```
