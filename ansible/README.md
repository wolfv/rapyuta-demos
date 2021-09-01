# How to deploy via ansible

You need to add two environment variables to your bash / zsh environment (they can be placed in `~/.bashrc` or `~/.zshrc`)

```
export RIO_PROJECT_ID="project-myidblabla"
export RIO_AUTH_TOKEN="thisisatokenfromrapyutaio"
```

Copy and fill out the `deploy_configs_template.yaml`: `cp deploy_configs_template.yaml deploy_configs.yaml`

Then you can run (from within the `ansible/niryo` folder):

`ansible-playbook sim_deploy.yaml -vvv --extra-vars "@deploy_configs.yaml"`

To deprovision the deployment and everything else, pass in `present=false`:

`ansible-playbook playbooks/deploy.yaml -vvv --extra-vars "@deploy_configs.yaml" --extra-vars "present=false"`
