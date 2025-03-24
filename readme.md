# Description
This repository demonstrates an example scenario that allows users to interact with a Bot based on a Genie Space using Microsoft Teams. It expands the following scenario: [Help secure your Microsoft Teams channel bot and web app behind a firewall](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/teams/securing-bot-teams-channel) and, as the original, implements the pillars of the [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) and can serve as the starting point for a POC or pilot.

## Architecture
![architecture](Genie-Teams.jpeg)

# Acknowledgement
The Bot code is based on this [repository](https://github.com/carrossoni/DatabricksGenieBOT/tree/main) authored by Luiz Carrossoni.  

# Pre-requisites
- An existing Databricks workspace with [Azure Private Link back-end and front-end connections](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link) enabled with a [Genie Space](https://learn.microsoft.com/en-us/azure/databricks/genie/set-up) accessible via API.
- An environment with a Bash shell and a recent version of the Azure CLI installed. The Bash version of the [Azure Cloud Shell](https://azure.microsoft.com/en-us/get-started/azure-portal/cloud-shell) is a fine option. 

# Steps
- Clone this repo: `git clone https://github.com/maucaro/secure_bot.git`
- Rename `setenv-samples.sh` to `setenv.sh` and modify it with your values and to conform to your naming standards. 
- Search for 'TO DO:' in the repository's files and adjust as necessary.
- Run `initial.sh`
- Run `bot.sh`
- Run `deploy.sh` Note, if you get the following error: "An error occurred during deployment. Status Code: 504, Details: 504.0 GatewayTimeout", check the logs; most times the deployment succeeds, despite the error message. 
- Test in Web Chat (Azure Portal -> Azure Bot instance -> Settings); if successful, continue.
- Add Microsoft Teams Channel (Azure Portal -> Azure Bot instance -> Settings -> Channels).
- Rename `appManifest\manifest-sample.json` to `appManifest\manifest.json` and update it with the ClientId (in the 'id' and and 'bots.botId' fiellds), and with your custom domain in 'validDomains'.
- Zip the files in the `appManifest` folder, upload the app to Teams and test it; if successful, continue.
- Map a custom domain for the Web App; add a DNS A record pointing the custom domain to the Firewall's public IP. 
- Run `private_endpoint.sh`
- Run `route_table.sh`
- Run `network_rules.sh`
- Run `peering.sh`
- Change Bot configuration's endpoint to custom domain

# Limitations and areas for improvement
- Azure Key Vault can be used to store the Databricks PAT token
- The Bot code only allows interactions from users in the configured Entra ID Tenant. For more granular control, organizations would need to manage access to the Teams App as described [here](https://learn.microsoft.com/en-us/microsoftteams/app-centric-management).
