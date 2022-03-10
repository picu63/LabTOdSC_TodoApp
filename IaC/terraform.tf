
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
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "labtodsc" {
  name     = "labtodscpolearczyk"
  location = "West Europe"
}

resource "azurerm_api_management" "api_mg" {
  name                = "todo-api-mg-${random_integer.ri.result}"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name
  publisher_name      = "Piotr Olearczyk"
  publisher_email     = "po049691@student.ath.edu.pl"

  sku_name = "Developer_1"
}

# Create an app service to host the web app
resource "azurerm_app_service_plan" "service_plan" {
  name                = "todo_web_plan"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_api" {
  name                = "web-api-service"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name
  app_service_plan_id = azurerm_app_service_plan.service_plan.id

  site_config {
    dotnet_framework_version = "v6.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
  }

  connection_string {
    name  = "TodosDatabase"
    type  = "Custom"
    value = "AccountEndpoint=${azurerm_cosmosdb_account.db.endpoint};AccountKey=${azurerm_cosmosdb_account.db.primary_key};"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                = "todosa"
  resource_group_name = azurerm_resource_group.labtodsc.name

  location                 = azurerm_resource_group.labtodsc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "todo-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.labtodsc.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "todo_db_sql" {
  name                = "todo-cosmos-mongo-db"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}

resource "azurerm_application_insights" "appinsights" {
  name                = "todo-appinsights"
  location            = azurerm_resource_group.labtodsc.location
  resource_group_name = azurerm_resource_group.labtodsc.name
  application_type    = "web"
}
