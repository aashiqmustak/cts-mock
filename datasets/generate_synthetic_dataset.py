import os
import csv
import random

# Seed for reproducibility
random.seed(42)

# Fictional, realistic diagnoses, diagnosis codes, and related info
clinical_scenarios = [
    # (diagnosis, diagnosis_code, chronic_condition, possible_procedures, possible_medications, specialty)
    ("Essential Hypertension", "I10", "Hypertension", 
     [("Specialist Consultation", "99214"), ("Cardiology Consultation", "99244")], 
     [("Lisinopril", "10mg"), ("Amlodipine", "5mg"), ("Hydrochlorothiazide", "25mg")], "Cardiology"),
    
    ("Type 2 Diabetes Mellitus", "E11.9", "Diabetes", 
     [("Specialist Consultation", "99214"), ("Endocrinology Consultation", "99245")], 
     [("Metformin", "500mg"), ("Empagliflozin", "10mg"), ("Liraglutide", "1.2mg/mL")], "Endocrinology"),
    
    ("Osteoarthritis of Knee", "M17.11", "Osteoarthritis", 
     [("Knee MRI", "73721"), ("Knee Joint Injection", "20610"), ("Physical Therapy Session", "97110")], 
     [("Celecoxib", "200mg"), ("Naproxen", "500mg"), ("Meloxicam", "15mg")], "Orthopedics"),
    
    ("Major Depressive Disorder", "F32.9", "Depression", 
     [("Psychiatric Evaluation", "90791"), ("Psychotherapy Session", "90834")], 
     [("Sertraline", "50mg"), ("Escitalopram", "10mg"), ("Duloxetine", "60mg")], "Psychiatry"),
    
    ("Chronic Obstructive Pulmonary Disease", "J44.9", "COPD", 
     [("Pulmonary Function Test", "94010"), ("Chest CT Scan", "71250")], 
     [("Albuterol Inhaler", "90mcg"), ("Fluticasone/Salmeterol", "250/50mcg"), ("Tiotropium", "18mcg")], "Pulmonology"),
    
    ("Gastroesophageal Reflux Disease", "K21.9", "GERD", 
     [("Upper Endoscopy", "43239"), ("Gastroenterology Consultation", "99214")], 
     [("Omeprazole", "20mg"), ("Famotidine", "20mg"), ("Pantoprazole", "40mg")], "Gastroenterology"),
    
    ("Chronic Low Back Pain", "M54.50", "Chronic Pain", 
     [("Lumbar Spine MRI", "72148"), ("Physical Therapy Session", "97110"), ("Epidural Steroid Injection", "62323")], 
     [("Gabapentin", "300mg"), ("Tramadol", "50mg"), ("Cyclobenzaprine", "10mg")], "Pain Management"),
    
    ("Migraine", "G43.909", "Migraine", 
     [("Brain MRI", "70551"), ("Neurology Consultation", "99214")], 
     [("Sumatriptan", "50mg"), ("Erenumab", "70mg/mL"), ("Rimegepant", "75mg")], "Neurology"),
    
    ("Rheumatoid Arthritis", "M06.9", "Rheumatoid Arthritis", 
     [("Joint Ultrasound", "76881"), ("Rheumatology Consultation", "99214")], 
     [("Methotrexate", "15mg"), ("Adalimumab", "40mg/0.8mL"), ("Etanercept", "50mg/mL")], "Rheumatology"),
    
    ("Coronary Artery Disease", "I25.10", "Coronary Artery Disease", 
     [("Cardiac Stress Test", "93015"), ("Echocardiogram", "93306"), ("Coronary Angiogram", "93454")], 
     [("Atorvastatin", "40mg"), ("Clopidogrel", "75mg"), ("Metoprolol Succinate", "50mg")], "Cardiology")
]

# Urgency categories
urgency_weights = [0.80, 0.15, 0.05]  # Routine, Urgent, Emergency
urgencies = ["Routine", "Urgent", "Emergency"]

genders = ["Male", "Female", "Non-binary"]
gender_weights = [0.48, 0.49, 0.03]

insurance_statuses = [True, False]
insurance_weights = [0.95, 0.05]

covered_statuses = [True, False]
covered_weights = [0.90, 0.10]

auth_required_statuses = [True, False]
auth_required_weights = [0.95, 0.05]

network_statuses = ["In-Network", "Out-of-Network"]
network_weights = [0.88, 0.12]

coverage_limit_statuses = [True, False]
coverage_limit_weights = [0.93, 0.07]

provider_utilization_levels = ["Low", "Medium", "High"]
provider_utilization_weights = [0.25, 0.60, 0.15]

boolean_choices = [True, False]

# Generate records
num_records = 10000
records = []

for i in range(num_records):
    # Patient info
    patient_id = f"PT{i+10001:05d}"
    age = random.randint(18, 90)
    gender = random.choices(genders, weights=gender_weights)[0]
    
    # Select a random base scenario
    scenario = random.choice(clinical_scenarios)
    diagnosis, diagnosis_code, chronic_condition, possible_procedures, possible_medications, provider_specialty = scenario
    
    # Clinical details
    symptom_severity = random.choice(["Mild", "Moderate", "Severe"])
    symptom_duration_days = random.randint(3, 180)
    
    # Request Info
    request_type = random.choice(["Procedure", "Medication"])
    procedure_name = "N/A"
    procedure_code = "N/A"
    drug_name = "N/A"
    dosage = "N/A"
    estimated_cost = 0.0
    
    if request_type == "Procedure":
        proc = random.choice(possible_procedures)
        procedure_name, procedure_code = proc
        # Estimate cost based on type
        if "MRI" in procedure_name or "CT" in procedure_name:
            estimated_cost = round(random.uniform(800.0, 2500.0), 2)
        elif "Injection" in procedure_name or "Angiogram" in procedure_name:
            estimated_cost = round(random.uniform(1000.0, 5000.0), 2)
        elif "Therapy" in procedure_name:
            estimated_cost = round(random.uniform(100.0, 300.0), 2)
        else:
            estimated_cost = round(random.uniform(200.0, 800.0), 2)
    else:
        med = random.choice(possible_medications)
        drug_name, dosage = med
        # Estimate cost based on drug name (some biologic/specialty drugs like Adalimumab are expensive)
        if drug_name in ["Adalimumab", "Etanercept"]:
            estimated_cost = round(random.uniform(3000.0, 7000.0), 2)
        elif drug_name in ["Liraglutide", "Erenumab", "Rimegepant"]:
            estimated_cost = round(random.uniform(600.0, 1200.0), 2)
        else:
            estimated_cost = round(random.uniform(10.0, 150.0), 2)
            
    urgency = random.choices(urgencies, weights=urgency_weights)[0]
    
    # Previous treatment
    # Normally, if symptom duration is short or severity is mild, previous treatment is less likely to be tried
    has_prev_treatment_weights = [0.75, 0.25] if symptom_duration_days > 30 else [0.30, 0.70]
    has_prev_treatment = random.choices([True, False], weights=has_prev_treatment_weights)[0]
    
    if has_prev_treatment:
        previous_treatment = f"Standard First-Line therapy for {diagnosis}"
        previous_treatment_duration_weeks = random.randint(2, 12)
        # Treatment response: did it help?
        treatment_response = random.choice(["No Improvement", "Partial Response", "Adverse Reaction"])
    else:
        previous_treatment = "None"
        previous_treatment_duration_weeks = 0
        treatment_response = "N/A"
        
    supporting_evidence_available = random.choices([True, False], weights=[0.85, 0.15])[0]
    
    # Insurance/Coverage
    insurance_active = random.choices(insurance_statuses, weights=insurance_weights)[0]
    procedure_or_drug_covered = random.choices(covered_statuses, weights=covered_weights)[0]
    prior_auth_required = random.choices(auth_required_statuses, weights=auth_required_weights)[0]
    network_status = random.choices(network_statuses, weights=network_weights)[0]
    coverage_limit_available = random.choices(coverage_limit_statuses, weights=coverage_limit_weights)[0]
    
    # Provider
    provider_utilization_level = random.choices(provider_utilization_levels, weights=provider_utilization_weights)[0]
    
    # Authorization info
    # Medical necessity score helper
    # Score is higher if symptom severity is high, longer duration, previous treatment failed, supporting evidence is available
    base_score = 40
    if symptom_severity == "Severe":
        base_score += 25
    elif symptom_severity == "Moderate":
        base_score += 12
        
    if symptom_duration_days > 60:
        base_score += 15
    elif symptom_duration_days > 14:
        base_score += 8
        
    if has_prev_treatment and treatment_response in ["No Improvement", "Adverse Reaction"]:
        base_score += 20
        
    if supporting_evidence_available:
        base_score += 10
        
    medical_necessity_score = min(max(base_score + random.randint(-10, 10), 0), 100)
    
    # Policy criteria met: highly correlated with medical necessity and previous treatment
    if medical_necessity_score >= 65 and (not has_prev_treatment or treatment_response != "Partial Response"):
        policy_criteria_met = random.choices([True, False], weights=[0.90, 0.10])[0]
    else:
        policy_criteria_met = random.choices([True, False], weights=[0.20, 0.80])[0]
        
    # Alternative treatment
    alternative_treatment_available = random.choices([True, False], weights=[0.60, 0.40])[0]
    if alternative_treatment_available and random.random() > 0.4:
        alternative_treatment_tried = random.choices([True, False], weights=[0.70, 0.30])[0]
    else:
        alternative_treatment_tried = False
        
    documentation_complete = random.choices([True, False], weights=[0.88, 0.12])[0]
    duplicate_request = random.choices([True, False], weights=[0.02, 0.98])[0]
    
    previous_authorization_status = random.choice(["Approved", "Rejected", "None"])
    
    # Emergency Flag
    emergency_flag = "YES" if (urgency == "Emergency" or (urgency == "Urgent" and random.random() < 0.2)) else "NO"
    
    # Calculate TARGET Decision
    decision = "HUMAN_REVIEW" # Default fallback
    
    # Rule 1: Rejected conditions (Inactive insurance, non-covered service, major issues)
    # Note: If emergency rule applies (emergency_flag = YES and urgency = Emergency), do not reject simply due to insurance/auth info missing.
    is_emergency_case = (emergency_flag == "YES" and urgency == "Emergency")
    
    if duplicate_request:
        decision = "REJECTED"
    elif not insurance_active and not is_emergency_case:
        decision = "REJECTED"
    elif not procedure_or_drug_covered and not is_emergency_case:
        decision = "REJECTED"
    elif medical_necessity_score < 33 and not is_emergency_case:
        decision = "REJECTED"
    elif not policy_criteria_met and medical_necessity_score < 40 and not is_emergency_case:
        decision = "REJECTED"
    elif not documentation_complete and not is_emergency_case:
        decision = "REJECTED"
        
    # Rule 2: Approved conditions
    elif (insurance_active and 
          procedure_or_drug_covered and 
          documentation_complete and 
          not duplicate_request and 
          medical_necessity_score >= 47 and 
          policy_criteria_met and 
          coverage_limit_available and
          (network_status == "In-Network" or random.random() < 0.85) # Allow some out of network to be approved
         ):
        # Additional checks: if alternative treatment is available and not tried, sometimes reject or human review
        if alternative_treatment_available and not alternative_treatment_tried and random.random() < 0.15:
            decision = "HUMAN_REVIEW"
        else:
            decision = "APPROVED"
            
    # Rule 3: Human Review / Emergency Fallbacks
    else:
        decision = "HUMAN_REVIEW"
        
    # Let's adjust slightly to match target distributions: APPROVED: 50–60%, REJECTED: 20–30%, HUMAN_REVIEW: 15–25%
    # If decision is HUMAN_REVIEW, let's see if we can promote/demote based on rules to keep realistic behavior:
    # Check if approved criteria are mostly met but slightly borderline
    if decision == "HUMAN_REVIEW":
        if (insurance_active and procedure_or_drug_covered and documentation_complete and not duplicate_request):
            # Borderline medical necessity score or borderline policy criteria
            if (42 <= medical_necessity_score < 48) or (not policy_criteria_met and medical_necessity_score >= 42):
                decision = "HUMAN_REVIEW"
            # High utilization provider requesting expensive treatment
            elif provider_utilization_level == "High" and estimated_cost > 4000:
                decision = "HUMAN_REVIEW"
            # Complex medication request (biologics like Adalimumab/Etanercept)
            elif request_type == "Medication" and drug_name in ["Adalimumab", "Etanercept"] and random.random() < 0.4:
                decision = "HUMAN_REVIEW"
            # Otherwise, if it's generally fine and above 40, approve
            elif medical_necessity_score >= 40 and policy_criteria_met:
                decision = "APPROVED"
        elif is_emergency_case:
            # For emergency case: if clinical and coverage indicators are strong -> APPROVED, else HUMAN_REVIEW (never rejected directly if emergency)
            if medical_necessity_score >= 35 and (procedure_or_drug_covered or procedure_or_drug_covered is None):
                decision = "APPROVED"
            else:
                decision = "HUMAN_REVIEW"
                
    # Format Booleans for CSV
    def fmt_bool(val):
        if val is True: return "YES"
        if val is False: return "NO"
        return val

    records.append({
        "patient_id": patient_id,
        "age": age,
        "gender": gender,
        "chronic_condition": chronic_condition,
        "diagnosis": diagnosis,
        "diagnosis_code": diagnosis_code,
        "symptom_severity": symptom_severity,
        "symptom_duration_days": symptom_duration_days,
        "previous_treatment": previous_treatment,
        "previous_treatment_duration_weeks": previous_treatment_duration_weeks,
        "treatment_response": treatment_response,
        "supporting_evidence_available": fmt_bool(supporting_evidence_available),
        "request_type": request_type,
        "procedure_name": procedure_name,
        "procedure_code": procedure_code,
        "drug_name": drug_name,
        "dosage": dosage,
        "urgency": urgency,
        "insurance_active": fmt_bool(insurance_active),
        "procedure_or_drug_covered": fmt_bool(procedure_or_drug_covered),
        "prior_auth_required": fmt_bool(prior_auth_required),
        "network_status": network_status,
        "coverage_limit_available": fmt_bool(coverage_limit_available),
        "provider_specialty": provider_specialty,
        "provider_utilization_level": provider_utilization_level,
        "medical_necessity_score": medical_necessity_score,
        "policy_criteria_met": fmt_bool(policy_criteria_met),
        "alternative_treatment_tried": fmt_bool(alternative_treatment_tried),
        "alternative_treatment_available": fmt_bool(alternative_treatment_available),
        "documentation_complete": fmt_bool(documentation_complete),
        "duplicate_request": fmt_bool(duplicate_request),
        "previous_authorization_status": previous_authorization_status,
        "estimated_cost": estimated_cost,
        "emergency_flag": emergency_flag,
        "authorization_decision": decision
    })

# Count distribution
counts = {"APPROVED": 0, "REJECTED": 0, "HUMAN_REVIEW": 0}
for r in records:
    counts[r["authorization_decision"]] += 1

print("Distribution:")
for k, v in counts.items():
    print(f"{k}: {v} ({v / num_records * 100:.2f}%)")

# Write to CSV file
csv_file_path = "c:/Users/msush/cog/datasets/synthetic_prior_auth_records.csv"
with open(csv_file_path, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=records[0].keys())
    writer.writeheader()
    writer.writerows(records)

print(f"Dataset generated and saved to {csv_file_path}")
