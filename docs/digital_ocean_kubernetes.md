# Guide
1. Create kubernetes cluster
2. Follow digital ocean to configure local kuberentes cluster via doctl
3. Check that you connected to correct kubernetes cluster
```bash
kubectl config current-context
#=> should return name of digital ocean kubernetes cluster
```
4. Change resources.txt and put targets there
5. In `run_all_kuber.sh` set REPLICAS to number of process to bombard.
6. run `./run_all_kuber.sh` to start attack
7. run `./stop_all_kuber.sh` to stop attack and remove all active targets

Kubernetes cheat sheat:
- Node is server, which connected to cluster and can run your code
- Pod is virtual machine instance, which execute code. Node can have multiple Pods
- Deployment is a set of pods, which has same parameters.

So Deployments consists of pods. And pods are running on multiple nods.

```bash
kubectl get pods
#=> return list of pods

kubectl get deployments
#=> return list of deployments and their status. You can see how many pods has been created

kubectl apply -f bombardier_dist.yaml
#=> manually apply kubernetes configuration

kubectl logs -f pod-name # example kubectl logs -f httpswww.rosbank.ru-75b6d8f986-s2277
#=> will print logs from specific pod

```
