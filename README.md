# OpenAI Reporting - Azure Function App

This project deploys an Azure Function App using the **Flex Consumption Plan** with infrastructure managed through Bicep and automated deployment via GitHub Actions.

## 🏗️ Architecture

- **Azure Function App (Flex Consumption Plan)**: Serverless compute for hosting multiple functions
- **Azure Storage Account**: Required for Function App runtime and deployments
- **Application Insights**: Monitoring and logging
- **Managed Identity**: Secure authentication without storing credentials

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions deployment pipeline
├── functions/                      # Azure Functions
│   ├── health_check/               # Health check endpoint
│   ├── generate_report/            # Generate OpenAI usage reports
│   ├── get_usage/                  # Retrieve usage data
│   └── sync_usage_data/            # Timer-triggered data sync
├── infra/                          # Bicep infrastructure as code
│   ├── modules/
│   │   ├── storage.bicep           # Storage Account module
│   │   ├── app-insights.bicep      # Application Insights module
│   │   └── function-app.bicep      # Function App module
│   ├── main.bicep                  # Main Bicep orchestration
│   └── main.bicepparam             # Parameters file
├── host.json                       # Function App host configuration
├── requirements.txt                # Python dependencies
└── README.md                       # This file
```

## 🚀 Functions Overview

### 1. Health Check (`/api/health`)
- **Trigger**: HTTP GET
- **Auth**: Anonymous
- **Purpose**: Basic health check endpoint

### 2. Generate Report (`/api/report/generate`)
- **Trigger**: HTTP POST
- **Auth**: Function key required
- **Purpose**: Generate OpenAI usage reports
- **Request Body**:
  ```json
  {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31",
    "report_type": "summary"
  }
  ```

### 3. Get Usage (`/api/usage`)
- **Trigger**: HTTP GET
- **Auth**: Function key required
- **Purpose**: Retrieve usage data for a date range
- **Query Parameters**: `start_date`, `end_date`

### 4. Sync Usage Data (Timer)
- **Trigger**: Timer (Daily at 2:00 AM UTC)
- **Purpose**: Automated daily sync of usage data

## 🔧 Prerequisites

- Azure subscription
- Azure CLI installed
- GitHub account
- Python 3.11

## 📝 Setup Instructions

### 1. Azure Setup

The project uses the existing resource group:

```bash
# Resource group (already exists)
Resource Group: f1-19cbd54c-playground-sandbox
Location: eastus
```

### 2. GitHub Secrets Configuration

Add the following secrets to your GitHub repository (already configured):

| Secret Name | Description |
|------------|-------------|
| `AZURE_CLIENT_ID` | Service Principal Client ID |
| `AZURE_CLIENT_SECRET` | Service Principal Client Secret |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `AZURE_TENANT_ID` | Your Azure AD Tenant ID |

**Resource Group**: `f1-19cbd54c-playground-sandbox` (pre-configured)

### 3. Local Development

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd a208790-openai-reporting
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Copy local settings**:
   ```bash
   cp local.settings.json.example local.settings.json
   ```

5. **Run locally** (requires Azure Functions Core Tools):
   ```bash
   func start
   ```

## 🚢 Deployment

### Automated Deployment (GitHub Actions)

The project has two separate deployment workflows:

1. **Infrastructure Deployment** (`.github/workflows/deploy.yml`)
   - Deploys Storage Account, Application Insights, and Function App
   - Runs when code is pushed to `main` branch

2. **Function App Deployment** (`.github/workflows/deploy-function.yml`)
   - Deploys only the function code
   - Runs when code is pushed to `main` branch
   - Faster deployment when only code changes

Both workflows run automatically when you push to the `main` branch.

### Manual Deployment

#### Deploy Infrastructure Only:

```bash
az deployment group create \
  --resource-group f1-19cbd54c-playground-sandbox \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

#### Deploy Function App Only:

```bash
func azure functionapp publish func-openai-reporting
```

## 🔐 Security Features

- **HTTPS Only**: All traffic encrypted
- **Managed Identity**: No stored credentials
- **TLS 1.2 Minimum**: Secure connections
- **Function Keys**: API authentication
- **CORS**: Configured for Azure Portal only
- **Private Storage**: No public blob access

## 📊 Monitoring

Application Insights is automatically configured. Access metrics:

1. Navigate to your Function App in Azure Portal
2. Select **Application Insights**
3. View logs, metrics, and traces

## 🧪 Testing

### Test Health Endpoint:
```bash
curl https://func-openai-reporting.azurewebsites.net/api/health
```

### Test Generate Report:
```bash
curl -X POST https://func-openai-reporting.azurewebsites.net/api/report/generate \
  -H "Content-Type: application/json" \
  -H "x-functions-key: <your-function-key>" \
  -d '{
    "start_date": "2024-01-01",
    "end_date": "2024-01-31",
    "report_type": "summary"
  }'
```

### Test Get Usage:
```bash
curl "https://func-openai-reporting.azurewebsites.net/api/usage?start_date=2024-01-01&end_date=2024-01-31" \
  -H "x-functions-key: <your-function-key>"
```

## 📦 Flex Consumption Plan Benefits

- **Automatic scaling**: Scales from 0 to 1000+ instances
- **Per-second billing**: Pay only for execution time
- **Fast cold starts**: Optimized startup performance
- **High concurrency**: Handle multiple requests per instance
- **Reserved capacity**: Always Ready instances for critical workloads

## 🔄 CI/CD Pipeline

The GitHub Actions workflows include:

1. **Infrastructure Deployment** (`deploy.yml`)
   - Validates and deploys Bicep templates
   - Creates/updates Azure resources
   - Runs on push to `main` branch

2. **Function Deployment** (`deploy-function.yml`)
   - Builds and deploys function code
   - Faster for code-only changes
   - Runs on push to `main` branch

## 🛠️ Customization

### Adding New Functions

1. Create a new folder under `functions/`
2. Add `__init__.py` with your function logic
3. Add `function.json` with bindings configuration
4. Functions are automatically included in deployment

### Updating Infrastructure

1. Modify Bicep files in `infra/`
2. Test locally: `az bicep build --file infra/main.bicep`
3. Push changes to trigger deployment

## 📚 Resources

- [Azure Functions Python Developer Guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-python)
- [Flex Consumption Plan Documentation](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Wait for validation to pass

## 📄 License

This project is internal to Thomson Reuters.

## 📞 Support

For issues or questions, please contact the development team.
