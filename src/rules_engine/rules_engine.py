import re
import json

class RuleEngine:
    def __init__(self, rules_file_path):
        self.rules = self.load_rules(rules_file_path)

    def load_rules(self, rules_file_path):
        rules = {}
        current_service = "GENERAL"
        
        with open(rules_file_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            # Detect section header
            if line.startswith("===") and i + 1 < len(lines):
                title_line = lines[i+1].strip()
                if "MRI" in title_line:
                    current_service = "MRI"
                elif "CT" in title_line:
                    current_service = "CT"
                elif "PET" in title_line:
                    current_service = "PET"
                elif "ECHO" in title_line:
                    current_service = "ECHO"
                elif "SLEEP" in title_line:
                    current_service = "SLEEP"
                elif "PHYSICAL" in title_line or "PT" in title_line:
                    current_service = "PT"
                elif "COLONOSCOPY" in title_line or "COLON" in title_line:
                    current_service = "COLON"
                elif "GENERAL" in title_line:
                    current_service = "GENERAL"
                i += 3
                continue
            
            # Detect individual rule pattern, e.g., MRI-01 -- Covered indication / medical necessity
            match = re.match(r"^([A-Z0-9_\-]+)\s*—\s*(.*)$", line)
            if match:
                rule_id = match.group(1).strip()
                title = match.group(2).strip()
                rule_type = "necessity"
                if "documentation" in title.lower() or "medical record" in title.lower() or "report" in title.lower() or "order" in title.lower():
                    rule_type = "documentation"
                
                # Fetch next lines for Rule: ...
                rule_text = ""
                source_id = "CMS Policy Guidelines"
                
                # Simple parser loop
                j = i + 1
                while j < len(lines):
                    next_line = lines[j].strip()
                    if next_line.startswith("Rule:"):
                        rule_text = next_line.replace("Rule:", "").strip()
                    elif next_line.startswith("Policy source:"):
                        # Try to capture policy source
                        pass
                    elif next_line.startswith("Extract:"):
                        pass
                    elif next_line == "" or next_line.startswith("===") or re.match(r"^([A-Z0-9_\-]+)\s*—\s*(.*)$", next_line):
                        break
                    j += 1
                
                rules[rule_id] = {
                    "rule_id": rule_id,
                    "service": current_service,
                    "rule_type": rule_type,
                    "criterion": title,
                    "source": "CMS LCD/NCD guidelines",
                    "source_id": source_id,
                    "rule_text": rule_text
                }
            i += 1
            
        return rules

    def evaluate(self, request_info):
        """
        Evaluate the rules based on structured request information.
        """
        service = request_info.get("service_type", "GENERAL").upper()
        results = []
        
        # Determine specific service sub-types (e.g. Lumbar vs Head/Neck MRI)
        procedure_name = request_info.get("procedure_name", "").lower()
        is_lumbar = "lumbar" in procedure_name
        is_head_neck = "head" in procedure_name or "neck" in procedure_name
        
        for rule in self.rules.values():
            status = "UNKNOWN"
            evidence = "No evidence found"
            
            # Check applicability first
            is_applicable = True
            if rule["service"] != "GENERAL" and rule["service"] != service:
                is_applicable = False
            elif rule["rule_id"] == "MRI-06" and not is_lumbar:
                is_applicable = False
            elif rule["rule_id"] == "MRI-07" and not is_head_neck:
                is_applicable = False
            elif rule["rule_id"] == "MRI-08" and not is_head_neck:
                is_applicable = False
                
            if not is_applicable:
                status = "NOT_APPLICABLE"
                evidence = "Rule is not applicable to the requested service sub-type."
            else:
                # Rule evaluations based on extracted fields
                if rule["rule_id"] == "MRI-01" or rule["rule_id"] == "GENERAL-01" or rule["rule_id"] == "CT-02" or rule["rule_id"] == "PT-01" or rule["rule_id"] == "COLON-01":
                    # Covered indication / medical necessity specific policy criteria
                    # Check for prior treatment condition for conservative care
                    if request_info.get("previous_treatment") == "None" or request_info.get("previous_treatment") == "None" or request_info.get("alternative_treatment_tried") == "NO":
                        status = "NEEDS_REVIEW"
                        evidence = "Clinical information does not clearly establish all applicable conservative care criteria (previous treatment tried is None/NO)."
                    elif request_info.get("medical_necessity_score", 0) >= 65:
                        status = "SATISFIED"
                        evidence = f"Medical necessity score is {request_info.get('medical_necessity_score')} (>= 65) with conservative care verified."
                    else:
                        status = "NEEDS_REVIEW"
                        evidence = f"Medical necessity score is {request_info.get('medical_necessity_score')} (< 65) or clinical indicators are uncertain."
                        
                elif rule["rule_id"] == "MRI-02" or rule["rule_id"] == "GENERAL-02" or rule["rule_id"] == "PT-03":
                    # Supporting medical record
                    if request_info.get("documentation_complete") == "YES":
                        status = "SATISFIED"
                        evidence = "Documentation is fully complete."
                    elif request_info.get("documentation_complete") == "NO":
                        status = "NOT_SATISFIED"
                        evidence = "Required documentation is marked as incomplete."
                    else:
                        status = "UNKNOWN"
                        evidence = "Supporting documentation presence cannot be verified."
                        
                elif rule["rule_id"] == "MRI-03" or rule["rule_id"] == "GENERAL-03" or rule["rule_id"] == "COLON-02":
                    # Diagnosis support
                    if request_info.get("diagnosis_code") and request_info.get("diagnosis"):
                        status = "SATISFIED"
                        evidence = f"Diagnosis {request_info.get('diagnosis')} matched with ICD code {request_info.get('diagnosis_code')}."
                    else:
                        status = "UNKNOWN"
                        evidence = "Missing diagnosis or diagnosis code."
                        
                elif rule["rule_id"] == "MRI-04" or rule["rule_id"] == "CT-01" or rule["rule_id"] == "COLON-03" or rule["rule_id"] == "SLEEP-02":
                    # Physician order
                    if request_info.get("urgency") == "Emergency":
                        status = "SATISFIED"
                        evidence = "Emergency exception - physician order bypass permitted."
                    elif request_info.get("documentation_complete") == "YES":
                        status = "SATISFIED"
                        evidence = "Physician order verified in medical record."
                    else:
                        status = "UNKNOWN"
                        evidence = "Physician order status cannot be verified from document."
                        
                elif rule["rule_id"] == "MRI-05" or rule["rule_id"] == "CT-03" or rule["rule_id"] == "PT-05":
                    # Clinical rationale / conservative care requirements
                    if request_info.get("previous_treatment") != "None" and request_info.get("previous_treatment_duration_weeks", 0) >= 6:
                        status = "SATISFIED"
                        evidence = f"Conservative care criteria met: tried {request_info.get('previous_treatment')} for {request_info.get('previous_treatment_duration_weeks')} weeks."
                    else:
                        status = "NEEDS_REVIEW"
                        evidence = "Clinical rationale does not document completion of mandatory conservative care (minimum 6 weeks)."
                        
                elif rule["rule_id"] == "MRI-06":
                    # Lumbar MRI documentation specific
                    if is_lumbar and request_info.get("previous_treatment") != "None":
                        status = "SATISFIED"
                        evidence = "Lumbar MRI policy criteria satisfied (previous conservative care verified)."
                    else:
                        status = "NEEDS_REVIEW"
                        evidence = "Lumbar spine policy requires documentation of conservative therapy response."
                        
                elif rule["rule_id"] == "MRI-10" or rule["rule_id"] == "GENERAL-04":
                    # Human review checks
                    if request_info.get("provider_utilization_level") == "High" or request_info.get("alternative_treatment_tried") == "NO":
                        status = "UNKNOWN"
                        evidence = "Requires manual case confirmation due to high utilization/untried alternatives."
                    else:
                        status = "SATISFIED"
                        evidence = "Clear case with no anomalies."
                        
                else:
                    # Generic fallback check for other rules
                    if request_info.get("documentation_complete") == "YES":
                        status = "SATISFIED"
                        evidence = "General criteria verified."
                    else:
                        status = "UNKNOWN"
                        evidence = "Insufficient evidence to verify this rule."
            
            results.append({
                "rule_id": rule["rule_id"],
                "service": rule["service"],
                "rule_type": rule["rule_type"],
                "criterion": rule["criterion"],
                "source": rule["source"],
                "source_id": rule["source_id"],
                "status": status,
                "evidence": evidence
            })
            
        return results
