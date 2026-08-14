import json
import os
import time

class AuditLog:
    def __init__(self, log_path='uploads/audit_log.json'):
        self.log_path = log_path
        if not os.path.exists(log_path):
            with open(log_path, 'w') as f:
                json.dump([], f)
                
    def log_request(self, request_id, file_name, extracted_info, rule_evaluations, decision_results, processing_time):
        log_entry = {
            "request_id": request_id,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "uploaded_documents": [file_name],
            "extracted_information": extracted_info,
            "rules_checked": rule_evaluations,
            "ML_prediction": decision_results["ml_decision"],
            "ML_confidence": decision_results["ml_confidence"],
            "final_recommendation": decision_results["final_decision"],
            "reason": decision_results["reason"],
            "processing_time": processing_time
        }
        
        with open(self.log_path, 'r+') as f:
            data = json.load(f)
            data.append(log_entry)
            f.seek(0)
            json.dump(data, f, indent=4)
            f.truncate()
            
    def get_logs(self):
        if not os.path.exists(self.log_path):
            return []
        with open(self.log_path, 'r') as f:
            return json.load(f)
