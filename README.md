# DO NOT USE THIS REPO - MIGRATED TO GITLAB


# aws-uc-feature-infrastructure

This repo contains the infrastructure required for the UC Feature data product.

After cloning this repo, please generate `terraform.tf` and `terraform.tfvars` files:  
`make bootstrap`

## How the E2E tests work right now

A completed output is taken from `analytical-dataset-generation` and put into the `published_bucket` in a folder labelled `e2e-test-uc-feature-dataset` this is done in the dev and qa environments.  
If those files are ever deleted they will need to be manually replaced. The reason we don't dynamically recreate them is that they require to have the encryption metadata attached to those files and ADG is the provider of those.  

The UC Feature dataset for the E2E is built on the small dataset in the above prefix and a comparison is made on one of the collections.

## Object tagging

UC feature requires no object tagging as fine grained access control is not required for this dataset.

## Concourse pipeline

There is a concourse pipeline for UC Feature named `aws-uc-feature`. The code for this pipeline is in the `ci` folder. The main part of the pipeline (the `master` group) deploys the infrastructure and runs the e2e tests. There are a number of groups for rotating passwords and there are also admin groups for each environment.

### Admin jobs

There are a number of available admin jobs for each environment. These can be found in the [Concourse Utility pipeline](https://ci.dataworks.dwp.gov.uk/teams/utility/pipelines/uc-feature-emr-admin)

#### Start cluster

This job will start an UC Feature cluster running. In order to make the cluster do what you want it to do, you can alter the following environment variables in the pipeline config and then run `aviator` to update the pipeline before kicking it off:

1. S3_PREFIX (required) -> the S3 output location for the HTME data to process, i.e. `analytical-dataset/2020-08-13_22-16-58/`
1. EXPORT_DATE (required) -> the date the data was exported, i.e `2021-04-01`
1. CORRELATION_ID (required) -> the correlation id for this run, i.e. `<some_unique_correlation_id>`
1. SNAPSHOT_TYPE (required) -> `full`


#### Stop clusters

For stopping clusters, you can run the `stop-cluster` job to terminate ALL current `uc-feature` clusters in the environment.

### Clear dynamo row (i.e. for a cluster restart)

Sometimes the UC Feature cluster is required to restart from the beginning instead of restarting from the failure point.
To be able to do a full cluster restart, delete the associated DynamoDB row if it exists. The keys to the row are `Correlation_Id` and `DataProduct` in the DynamoDB table storing cluster state information (see [Retries](#retries)).   
The `clear-dynamodb-row` job is responsible for carrying out the row deletion.

To do a full cluster restart

* Manually enter CORRELATION_ID and DATA_PRODUCT of the row to delete to the `clear-dynamodb-row` job and run aviator.


    ```
    jobs:
      - name: dev-clear-dynamodb-row
        plan:
          - .: (( inject meta.plan.clear-dynamodb-row ))
            config:
              params:
                AWS_ROLE_ARN: arn:aws:iam::((aws_account.development)):role/ci
                AWS_ACC: ((aws_account.development))
                CORRELATION_ID: <Correlation_Id of the row to delete>
                DATA_PRODUCT: <DataProduct of the row to delete>

    ```
* Run the admin job to `<env>-clear-dynamodb-row`

* You can then run `start-cluster` job with the same `Correlation_Id` from fresh.

### Pipeline not running in QA?

There is an automated AMI upgrade pipeline embedded into the pipeline of this repo (`ci/jobs/ami-test`). This is in a `serial_group` with the QA deployment pipeline to ensure that they do not interfere with each other.

Please let the tests run and the deployment pipeline will continue automatically.
