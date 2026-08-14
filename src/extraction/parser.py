import os
import json
import re

class DocumentProcessor:
    def __init__(self):
        pass

    def classify_document(self, text):
        text_lower = text.lower()
        if "prescription" in text_lower or "rx" in text_lower:
            return "Prescription"
        elif "lab report" in text_lower or "blood test" in text_lower:
            return "Lab Report"
        elif "prior authorization" in text_lower or "referral" in text_lower:
            return "Prior Auth Request Form"
        elif "physiotherapy" in text_lower or "physical therapy" in text_lower:
            return "Physical Therapy Note"
        else:
            return "Doctor Report / Note"

    def extract_information(self, text):
        """
        Parses raw text (from medical report) to extract key variables.
        """
        extracted = {
            "age": 45,                  # Defaults for demonstration
            "gender": "Female",
            "chronic_condition": "Hypertension",
            "diagnosis": "Essential Hypertension",
            "diagnosis_code": "I10",
            "symptom_severity": "Moderate",
            "symptom_duration_days": 30,
            "previous_treatment": "None",
            "previous_treatment_duration_weeks": 0,
            "treatment_response": "N/A",
            "supporting_evidence_available": "YES",
            "request_type": "Procedure",
            "procedure_name": "Specialist Consultation",
            "procedure_code": 99214,
            "drug_name": "N/A",
            "dosage": "N/A",
            "urgency": "Routine",
            "insurance_active": "YES",
            "procedure_or_drug_covered": "YES",
            "prior_auth_required": "YES",
            "network_status": "In-Network",
            "coverage_limit_available": "YES",
            "provider_specialty": "Cardiology",
            "provider_utilization_level": "Medium",
            "medical_necessity_score": 75,
            "policy_criteria_met": "YES",
            "alternative_treatment_tried": "NO",
            "alternative_treatment_available": "YES",
            "documentation_complete": "YES",
            "duplicate_request": "NO",
            "previous_authorization_status": "None",
            "estimated_cost": 250.0,
            "emergency_flag": "NO"
        }
        
        # Simple rule-based extraction from input text
        text_lower = text.lower()
        
        # Urgent / Emergency checks
        if "emergency" in text_lower or "urgent status" in text_lower or "immediate treatment" in text_lower:
            extracted["urgency"] = "Emergency"
            extracted["emergency_flag"] = "YES"
            
        # Age extraction
        age_match = re.search(r"age:\s*(\d+)", text_lower)
        if age_match:
            extracted["age"] = int(age_match.group(1))
            
        # Diagnosis Extraction
        if "osteoarthritis" in text_lower:
            extracted["diagnosis"] = "Osteoarthritis of Knee"
            extracted["diagnosis_code"] = "M17.11"
            extracted["chronic_condition"] = "Osteoarthritis"
            extracted["procedure_name"] = "Knee Joint Injection"
            extracted["procedure_code"] = 20610
            extracted["provider_specialty"] = "Orthopedics"
        elif "back pain" in text_lower:
            extracted["diagnosis"] = "Chronic Low Back Pain"
            extracted["diagnosis_code"] = "M54.50"
            extracted["chronic_condition"] = "Chronic Pain"
            extracted["procedure_name"] = "Lumbar Spine MRI"
            extracted["procedure_code"] = 72148
            extracted["provider_specialty"] = "Pain Management"
        elif "diabetes" in text_lower:
            extracted["diagnosis"] = "Type 2 Diabetes Mellitus"
            extracted["diagnosis_code"] = "E11.9"
            extracted["chronic_condition"] = "Diabetes"
            extracted["request_type"] = "Medication"
            extracted["drug_name"] = "Metformin"
            extracted["dosage"] = "500mg"
            extracted["provider_specialty"] = "Endocrinology"

        # Missing documentation indicator
        if "incomplete files" in text_lower or "missing form" in text_lower:
            extracted["documentation_complete"] = "NO"
            
        return extracted
