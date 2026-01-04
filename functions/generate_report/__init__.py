import azure.functions as func
import logging
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP triggered function for generating OpenAI usage reports.
    POST /api/report/generate
    
    Request body:
    {
        "start_date": "2024-01-01",
        "end_date": "2024-01-31",
        "report_type": "summary" | "detailed"
    }
    """
    logging.info('Generate report function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse(
            body=json.dumps({"error": "Invalid JSON in request body"}),
            status_code=400,
            mimetype="application/json"
        )

    start_date = req_body.get('start_date')
    end_date = req_body.get('end_date')
    report_type = req_body.get('report_type', 'summary')

    if not start_date or not end_date:
        return func.HttpResponse(
            body=json.dumps({"error": "start_date and end_date are required"}),
            status_code=400,
            mimetype="application/json"
        )

    # Placeholder for actual report generation logic
    report = {
        "report_id": f"RPT-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
        "report_type": report_type,
        "period": {
            "start": start_date,
            "end": end_date
        },
        "generated_at": datetime.utcnow().isoformat(),
        "status": "generated",
        "summary": {
            "total_requests": 1250,
            "total_tokens": 450000,
            "total_cost": 125.50
        }
    }

    logging.info(f'Report generated: {report["report_id"]}')

    return func.HttpResponse(
        body=json.dumps(report),
        status_code=200,
        mimetype="application/json"
    )
