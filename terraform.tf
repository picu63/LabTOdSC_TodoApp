
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "e1153580-058f-43cc-ade4-ffa315b2f513"
}

# Create a resource group
resource "azurerm_resource_group" "labtodsc" {
  name     = "labtodscpolearczyk"
  location = "East US"
}

# Create an app service to host the web app
resource "azurerm_app_service_plan" "service_plan" {
  name                = "todo_web_app_plan"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_app" {
  name                = "web-app-service"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name
  app_service_plan_id = azurerm_app_service_plan.service_plan.id

  site_config {
    dotnet_framework_version = "v6.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=${azurerm_mssql_database.test.name}.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_storage_account" "todo_sa" {
  name                     = "todosatodscpolearczyk"
  resource_group_name      = azurerm_resource_group.labtodsc.name
  location                 = azurerm_resource_group.labtodsc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "todo_db" {
  name                         = "todo-db-server"
  resource_group_name          = azurerm_resource_group.labtodsc.name
  location                     = azurerm_resource_group.labtodsc.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "test" {
  name           = "todo_db"
  server_id      = azurerm_mssql_server.todo_db.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.todo_sa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.todo_sa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    foo = "bar"
  }
}