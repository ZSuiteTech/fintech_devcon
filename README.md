# fintech_devcon

## Environment Setup

### Step 1 - Create Amazon Web Services (AWS) Account

1. Navigate to [AWS Event Page](https://dashboard.eventengine.run/login)
2. Enter the code `54be-13a09159a4-77`
3. Choose how to sign in (AWS Recommends Email One Time Password)
4. Enter the one time password

### Step 2 - Create Cloud9 Instance

1. TBC

### Step 3 - Configure Cloud9

We'll run a script in Cloud9 to perform the following:

- Removes unnecessary software (PHP, etc)
- Install `kubectl` Kubernetes CLI
- Pull down and fork helm charts repo (https://github.com/ZSuiteTech/fintech_devcon_charts)

```
git clone https://github.com/ZSuiteTech/fintech_devcon.git
cd fintech_devcon
./setup.sh
```

#### Instructions:

- Follow instructions in console (copy one-time code) 😊
- Click on link and select "Open"
- Switch to tab/window and follow instructions

Example Output:

```
! First copy your one-time code: ....-....
- Press Enter to open github.com in your browser... 
! Failed opening a web browser at https://github.com/login/device
  exec: "xdg-open,x-www-browser,www-browser,wslview": executable file not found in $PATH
  Please try entering the URL in your browser manually
  
✓ Authentication complete. Press Enter to continue...
```

## Reference

1. [Terraform](reference.md)

## Workshop

### Step 1: Create EKS cluster using Terraform

1. Create s3 bucket from command prompt
   1.
      ```sh
      YOUR_BUCKET_NAME=zstfdemo-ftdc21-${GH_USER,,}`
      ```
   
   2.
      ```sh
      aws s3 mb s3://$YOUR_BUCKET_NAME
      ```

2. Initialize Terraform
   
   ```sh
   terraform init -backend-config="bucket=$YOUR_BUCKET_NAME"
   ```

3. Run Terraform, passing in the variable file
   
   ```sh
   terraform apply -var-file=demo.tfvars
   ```

4. Approve changes by typing `yes` and pressing Enter.
5. Creating resources will take over 10 minutes.

## Step 2: Verify EKS deployment with `kubectl`

1. Setup `kubectl`
   
   ```sh
   export KUBECONFIG=./kubeconfig_zsuite-devcon-<RANDOM>
   ```

2. Test command via
   
   ```sh
   kubectl get namespace
   ```

## Step 3: Deploy ArgoCD with terraform

1. Replace repoUrl in `argocd/manifests/apps.yaml` with your forked Helm charts repository
   
   ```sh
   gh repo view --json url --jq '.url'
   ```

2. Uncomment `argocd` module usage in `main.tf`
3. Run `terraform init` again to install new dependency
4. Run terraform apply again

   ```sh
   terraform apply -var-file=demo.tfvars
   ```

5. Confirm `argocd` namespace exists cluster namespaces
6. Check ArgoCD services
   
   ```sh
   kubectl -n argocd get all
   ```

7. Log in to UI
   1. Get argo password
      1.
         ```sh
         kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
         ```
      
      2. Do not include the last character `%` that's a newline
   2. Get argo-server pod
      
      ```sh
      kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server
      ```
   
   3. Port forward to pod
      1.
         ```sh
         ARGO_POD=argocd-server-?????????-?????
         ```
         
      2.
         ```sh
         kubectl -n argocd port-forward pod/$ARGO_POD 8080:8080
         ```
   
   4. NOPE: In browser go to [localhost:8080](http://localhost:8080)
   5. Login with username `admin` and password from above

## Step 4: Add app to ArgoCD

1. Go to forked helm charts repo
2. Edit `apps/values.yaml`
   1. Set `deployWatchman` to `true`
   2. Commit and push changes
3. Confirm watchman resources exist

   ```sh
   kubectl -n moov get all
   ```

4. Test watchman api
   1. Get pod 
      
      ```sh
      kubectl -n moov get pods -l app.kubernetes.io/instance=my-watchman
      ```
   
   2. Port forward to pod
      1.
         ```sh
         MOOV_POD=my-watchman-?????????-?????
         ```
      
      2.
         ```sh
         kubectl -n moov port-forward pod/$MOOV_POD 8081:8080
         ```
   
   3. Test endpoint [http://localhost:8081/downloads](http://localhost:8081/downloads)
      
      ```sh
      curl -uri http://localhost:8081/downloads
      ```

### Step 5: Enable ingress for Watchman API

1. Install AWS Load Balancer controller
   1. Uncomment `alb_ingress_controller` module in main.tf
   2. Run
     
      ```sh
      terraform init
      ```
      
      again to install new dependency
   3. Run terraform apply again
      
      ```sh
      terraform apply -var-file=demo.tfvars
      ```

2. In helm charts repo, set `deployWatchmanIngress` variable to `true`
3. Commit and push changes for helm charts repo
4. Aws load balancer provisioning can take several minutes
   1. Can view load balancer in aws console
5. Get dns entry for watchman api from argocd
   1. Open `watchman-gateway` app
   2. Select `ingress`
   3. Go to `live manifest`
   4. Find dns address
6. Test api from public address
   1.
      ```sh
      MOOV_DNS=??????.us-east-1.elb.amazonaws.com
      ```

   2.
      ```sh
      curl -uri http://$MOOV_DNS:8081/downloads
      ```

### Step 6: destroy

1. Delete argo apps
   1. Disable variables in helm charts repo
      1. `deployWatchman`
      2. `deployWatchmanIngress`
   2. This cleans up ELB nicely
2. Run terraform destroy
   1.
      ```sh
      terraform destroy -var-file=demo.tfvars
      ```

   2. Confirm by typing `yes`
   3. This will take around 4 minutes
