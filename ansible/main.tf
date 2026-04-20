terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.4.0"
    }
  }
}

provider "ansible" {}

action "ansible_playbook_run" "ansible" {
  config {
    playbooks = ["${path.module}/playbook.yml"]

    extra_vars = {
      hcp_token    = var.hcp_token
      project_name = var.project_name
    }
  }
}

resource "terraform_data" "run_ansible" {
  triggers_replace = [
    var.project_name
  ]

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.ansible_playbook_run.ansible]
    }
  }
}