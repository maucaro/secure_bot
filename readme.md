# Description
This repository demonstrates an example scenario that allows users to interact with a Bot based on a Genie Space using Microsoft Teams. It expands the following scenario: [Help secure your Microsoft Teams channel bot and web app behind a firewall](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/teams/securing-bot-teams-channel) and, as the original, implements the pillars of the [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) and can serve as the starting point for a POC or pilot.

## Architecture
![architecture](Genie-Teams.jpeg)

# Acknowledgement
The Bot code is based on this (repository)[https://github.com/carrossoni/DatabricksGenieBOT/tree/main].  

# Pre-requisites
An existing Databricks workspace with [Azure Private Link back-end and front-end connections](https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link) enabled with a [Genie Space](https://learn.microsoft.com/en-us/azure/databricks/genie/set-up) accessible via API.

# Steps
- Rename `setenv-samples.sh` to `setenv.sh` and modify it with your values and to conform to your naming standards. 
- Search for 'TO DO:' in the repository's files and adjust as necessary.
- Run `initial.sh`
- Run `bot.sh`
- Run `deploy.sh` Note, if you get the following error: "An error occurred during deployment. Status Code: 504, Details: 504.0 GatewayTimeout", check the logs; most times the deployment succeeds, despite the error message. 
- Test in Web Chat (Azure Portal -> Azure Bot instance -> Settings); if successful, continue.
- Add Microsoft Teams Channel (Azure Portal -> Azure Bot instance -> Settings -> Channels).
- Update `appManifest\manifest.json` with the ClientId (in the 'id' and and 'bots.botId' fiellds), and your custom domain in 'validDomains'.
- Zip the files in the `appManifest` folder, upload the app to Teams and test it; if successful, continue.
- Map a custom domain for the Web App; add a DNS A record pointing the custom domain to the Firewall's public IP. 
- Run `private_endpoint.sh`
- Run `route_table.sh`
- Run `network_rules.sh`
- Run `peering.sh`
- Change Bot configuration's endpoint to custom domain

# Limitations and areas for improvement
- Azure Key Vault can be used to store the Databricks PAT token
- Authentication to the Bot should be added as described [here](https://learn.microsoft.com/en-us/azure/bot-service/bot-builder-authentication?view=azure-bot-service-4.0&tabs=userassigned%2Caadv2%2Cjavascript#register-the-microsoft-entra-id-identity-provider-with-the-bot) and then SSO to Teams can be enabled as described [here](https://learn.microsoft.com/en-us/microsoftteams/platform/bots/how-to/authentication/bot-sso-overview). Unfortunately, as of the last update to this file, there is a [bug](https://github.com/microsoft/BotBuilder-Samples/issues/3829) that prevents this from being implemented using Python.