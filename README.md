# DigitalOcean Azure DevOps build agent 🕵️

A terraform/ansible script that sets up DigitalOcean droplets as build agents for Azure DevOps.
Use the `azure-pipelines.yaml` file and set up a few variables to quickly get a pipeline running that sets up build
agents for you in Azure DevOps.

## Getting started

_"This seems like a lot of steps, why so many?"_

Good question, this program requires the following objects to function:

- An [Azure Pipelines pipeline](https://azure.microsoft.com/nl-nl/services/devops/pipelines/), to kick off everything
- Access to your DigitalOcean account through [API tokens](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/), to set up the Droplets that will be our agents
- A [DigitalOcean Spaces object](https://www.digitalocean.com/community/tutorials/how-to-create-a-digitalocean-space-and-api-key), so we can store our [Terraform state](https://www.terraform.io/docs/state/index.html)
- [Azure DevOps](https://azure.microsoft.com/nl-nl/services/devops/) access, so it can set up your build agents for you

Let's first begin with the pipeline.

### Set up Azure Pipelines in your Azure DevOps project

1. Create a new pipeline and choose `Use an existing YAML pipeline` as a template
1. Choose the azure-pipelines.yaml from this repository
1. Keep this page open for the rest of the getting-started steps

### Setting up your state store in DigitalOcean

Terraform needs a place to store its current state, since this program is made for DigitalOcean, we're going to need
a Spaces object in our DO project.

1. Create a [Spaces object in DO with an access key](https://www.digitalocean.com/community/tutorials/how-to-create-a-digitalocean-space-and-api-key)
1. Go back to your pipeline and add secret variables:
    - **terraformBackendBucket** = The name of your Spaces object
    - **terraformBackendKey**: The name you want to give to your statefile, for example 'my-agent-state.tfstate'
    - **doAccessKey**: The access key of your Spaces object
    - **doSecretKey**: The secret associated with your access key

### API Token

To create our agents, Terraform needs access to our DigitalOcean resources.
To accomplish this, we need an API token.

1. Create a [DO API token with read/write access](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
1. Go back to your pipeline and add secret variables:
    - **apiToken**: Your api token

### Azure DevOps personal access token

At last, we need our build agents to connect to our Azure DevOps organization to actually start being an agent.
To do this, you're going to have to create a Personal Access token.

- Create your Azure DevOps [Access token with read/manage access to agent pools](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page)
- Go back to your pipeline and add secret variables:
    - **azureDevOpsAccountName**: The name of your organization
    - **azureDevOpsSecretKey**: Your personal access token

### Final steps

Now that all values are present in the pipeline and all access is set up, you can close your other browser windows
and start running the pipeline.

## What does it do?

Once you've set up all the required values, the following things will happen:

1. Terraform initializes itself using the DigitalOcean Spaces object
1. Terraform generates an SSH keypair and adds it to your DigitalOcean account
1. Terraform sets up _n_ build agents according to the **dropletAmount** variable in the pipeline, all containing the ssh public key for the root user
1. Terraform connects to the agents and makes sure Python3 is installed (and halts the process so the agents have had time to boot the SSH daemon)
1. Terraform kicks off Ansible, pointing to the ipv4 addresses of all created droplets
1. Ansible runs the [gsoft.azure_devops_agent ansible role](https://github.com/gsoft-inc/ansible-role-azure-devops-agent) for all agents and retrieves credentials from the environment

## Can I run this locally?

Yes you can!
All you need to do is:

1. Replace all default `variables.tf` with underscores (__) in them with your credentials OR deliver the credentials with a varfile/vars
1. Replace all `backend.tf` configuration that contains underscores (__) with your credentials

Then you can run your `terraform` commands like usual.

## Todos

- Currently the private key generated for the droplets is displayed in the Terraform plan step, this needs to be hidden OR an external ssh key should be used
- You can currently only create a simple build agent as of now, thinking of expanding it further later
