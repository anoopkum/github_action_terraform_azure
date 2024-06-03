# Create a Resource Group for the Terraform State File
resource "azurerm_resource_group" "state-rg" {
  name     = "kopicloud-tfstate-rg"
  location = var.location
}

# Create a Storage Account for the Terraform State File
resource "azurerm_storage_account" "state-sta" {
  depends_on = [azurerm_resource_group.state-rg]  
  
  name                = "kopicloudgitlabtfstate"
  resource_group_name = azurerm_resource_group.state-rg.name
  location            = azurerm_resource_group.state-rg.location

  account_kind = "StorageV2"
  account_tier = "Standard"
  access_tier  = "Hot"

  account_replication_type  = "ZRS"
  enable_https_traffic_only = true
}

# Create a Storage Container for the Core State File
resource "azurerm_storage_container" "core-container" {
  depends_on = [azurerm_storage_account.state-sta]  
  
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.state-sta.name
}

# Create the Resource Group
resource "azurerm_resource_group" "this" {
  name     = "kopicloud-github-actions-rg"
  location = "west europe"
}

# Create the VNET
resource "azurerm_virtual_network" "this" {
  name                = "kopicloud-github-actions-vnet"
  address_space       = ["10.10.10.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

# Create the Subnet
resource "azurerm_subnet" "this" {
  name                 = "kopicloud-github-actions-subnet"  
  address_prefixes     = ["10.10.10.0/24"]
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name  = azurerm_resource_group.this.name
}