# Quick Start Guide

Get your Azure Function App up and running in minutes!

## 🚀 5-Minute Setup

### 1. Prerequisites
```bash
# Your GitHub repository already has these secrets configured:
# - AZURE_CLIENT_ID
# - AZURE_CLIENT_SECRET  
# - AZURE_SUBSCRIPTION_ID
# - AZURE_TENANT_ID

# Resource Group: f1-19cbd54c-playground-sandbox (already exists)
```

### 2. Push Code to Deploy
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

This will trigger both workflows:
- Infrastructure deployment (first time only)
- Function app deployment

### 3. Monitor Deployment
- Go to **GitHub Actions** tab
- Watch the workflow run
- Wait for green checkmarks ✅

### 4. Test Your Function
```bash
# Get the Function App URL (or use func-openai-reporting.azurewebsites.net)
FUNCTION_APP="func-openai-reporting.azurewebsites.net"

# Test health endpoint
curl https://$FUNCTION_APP/api/health
```

You should see:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-04T...",
  "service": "openai-reporting-functions"
}
```

🎉 **Success!** Your Function App is running!

---

## 📝 Getting Function Keys

```bash
# Login to Azure first
az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# List all function keys
az functionapp keys list \
  --name func-openai-reporting \
  --resource-group f1-19cbd54c-playground-sandbox

# Get specific function key
az functionapp function keys list \
  --name func-openai-reporting \
  --resource-group f1-19cbd54c-playground-sandbox \
  --function-name generate_report
```

---

## 🧪 Test All Endpoints

### Health Check (No auth)
```bash
curl https://$FUNCTION_APP/api/health
```

### Generate Report (Function key required)
```bash
FUNCTION_KEY="<your-function-key>"

curl -X POST https://$FUNCTION_APP/api/report/generate \
  -H "Content-Type: application/json" \
  -H "x-functions-key: $FUNCTION_KEY" \
  -d '{
    "start_date": "2024-01-01",
    "end_date": "2024-01-31",
    "report_type": "summary"
  }'
```

### Get Usage (Function key required)
```bash
curl "https://$FUNCTION_APP/api/usage?start_date=2024-01-01&end_date=2024-01-31" \
  -H "x-functions-key: $FUNCTION_KEY"
```

---

## 🔍 View Logs
### CLI Method
```bash
az webapp log tail \
  --name func-openai-reporting \
  --resource-group f1-19cbd54c-playground-sandbox
```
### CLI Method
```bash
az webapp log tail \
  --name func-openai-reporting-dev \
  --resource-group rg-openai-reporting-dev
```

---

## 🛠️ Local Development

### 1. Install Azure Functions Core Tools

**Windows (PowerShell)**:
```powershell
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```

**Mac**:
```bash
brew tap azure/functions
brew install azure-functions-core-tools@4
```

**Linux (Ubuntu)**:
```bash
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install azure-functions-core-tools-4
```

### 2. Setup Local Environment
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy settings
cp local.settings.json.example local.settings.json

# Run locally
func start
```

Your functions will be available at:
- http://localhost:7071/api/health
- http://localhost:7071/api/report/generate
- http://localhost:7071/api/usage

---

## 📊 Monitor Costs

```bash
# View current month costs for resource group
az consumption usage list \
  --start-date $(date -u -d "1 day ago" '+%Y-%m-%dT%H:%M:%SZ') \
  --end-date $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  | jq '[.[] | select(.instanceName | contains("openai-reporting"))] | .[].pretaxCost | tonumber' \
  | jq -s add
```

---

## 🔄 Common Operations

### Deploy Code Only (Skip Infrastructure)
```bash
func azure functionapp publish func-openai-reporting-dev
```

### Deploy Infrastructure Only
```bash
az deployment group create \
  --resource-group rg-openai-reporting-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

### Restart Function App
```bash
az functionapp restart \
  --name func-openai-reporting-dev \
  --resource-group rg-openai-reporting-dev
```

### View Function App Settings
```bash
az functionapp config appsettings list \
  --name func-openai-reporting-dev \
  --resource-group rg-openai-reporting-dev
```

### Add New App Setting
```bash
az functionapp config appsettings set \
  --name func-openai-reporting-dev \
  --resource-group rg-openai-reporting-dev \
  --settings "NEW_SETTING=value"
```

---

## ❌ Clean Up Resources

```bash
# Note: Be careful! This will delete all resources in the deployment
# List resources first
az resource list --resource-group f1-19cbd54c-playground-sandbox --output table

# Delete only Function App resources (if needed)
az functionapp delete --name func-openai-reporting --resource-group f1-19cbd54c-playground-sandbox
az appinsights component delete --app appi-prod-* --resource-group f1-19cbd54c-playground-sandbox
az storage account delete --name st* --resource-group f1-19cbd54c-playground-sandbox
```

---

## 🐛 Troubleshooting

### Problem: "Deployment failed"
```bash
# Check deployment errors
az deployment group show \
  --resource-group f1-19cbd54c-playground-sandbox \
  --name <deployment-name> \
  --query properties.error
```

### Problem: "Function not responding"
```bash
# Check function app status
az functionapp show \
  --name func-openai-reporting \
  --resource-group f1-19cbd54c-playground-sandbox \
  --query state
```

### Problem: "Can't find function keys"
```bash
# Wait 2-3 minutes after deployment, then:
az functionapp keys list \
  --name func-openai-reporting \
  --resource-group f1-19cbd54c-playground-sandbox
```

### Problem: "Storage errors"
```bash
# Verify storage account exists
az storage account show \
  --name $(az functionapp show \
    --name func-openai-reporting \
    --resource-group f1-19cbd54c-playground-sandbox \
    --query 'storageAccountName' -o tsv) \
  --query provisioningState
```

---

## 📚 Next Steps

1. ✅ Read [README.md](README.md) for detailed documentation
2. ✅ Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment guide
3. ✅ Check [INFRASTRUCTURE.md](INFRASTRUCTURE.md) for infrastructure details
4. ✅ Customize functions in `functions/` directory
5. ✅ Update Bicep templates in `infra/` for your needs

---

## 💡 Pro Tips

- **Use VS Code**: Install Azure Functions extension for better development experience
- **Separate Workflows**: Infrastructure and function deployments run independently
- **Monitor Costs**: Set up budget alerts in Azure Portal
- **Application Insights**: Always check logs there first for debugging
- **Manual Trigger**: Use workflow_dispatch to manually trigger deployments from GitHub Actions

---

## 🆘 Need Help?

- 📖 [Full Documentation](README.md)
- 🏗️ [Infrastructure Guide](INFRASTRUCTURE.md)
- 🚀 [Deployment Guide](DEPLOYMENT.md)
- 📧 Contact: [Your Team Email]

**Happy Coding!** 🎉
