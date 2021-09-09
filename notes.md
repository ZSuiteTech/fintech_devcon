1) More architecture diagrams?
2) TF for env
    * TF -> AWS
    * define eks
    * vpc etc
    * dynamo or rds whichever is faster
    * ECR
    * EFS storage for sqlite
    * install argo into eks
    * create a project (wht kind?)
3) Argo for tenant
    * Helm deployment of eks of watchman
    * helm deployment of api 
    * helm for an edge server 
4) Have premade containers as an option
5) CDK or TF?

decisions
1. start with hcl
1. demonstrate equivalent TF in cdktf for comparison (lower priority)

steps
1. determine execution environment that devs will run
   1. cloud9 environment for users?
   1. ec2?
   1. other?
   1. codespaces
1. tf
   1. create bucket with aws cli?
   1. create project
   1. add s3 backend
   1. add aws provider
   1. add vpc module
   1. add eks module
   1. deploy argocd to eks*
      1. use tf provider?
      1. this does not exist in ZSP
   1. create helm chart git repo (for argo)