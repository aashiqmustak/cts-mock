from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import time
import uuid
import os

from src.rules_engine.rules_engine import RuleEngine
from src.extraction.parser import DocumentProcessor
from src.decision_engine.decision_engine import DecisionEngine
from src.audit.logger import AuditLog

app = FastAPI(title="AI-Based Prior Authorization Automation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize modules
rules_engine = RuleEngine('rules/rules.txt')
doc_processor = DocumentProcessor()
decision_engine = DecisionEngine()
audit_log = AuditLog()

@app.post("/analyze")
async def analyze_document(
    file: UploadFile = File(...),
    service_type: str = Form("MRI")
):
    start_time = time.time()
    
    # Save the file temporarily
    file_path = f"uploads/{file.filename}"
    with open(file_path, "wb") as f:
        f.write(await file.read())
        
    # Read text content depending on file type
    text_content = ""
    file_ext = file.filename.lower()
    
    if file_ext.endswith(".txt"):
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            text_content = f.read()
    elif file_ext.endswith(".pdf"):
        try:
            from pypdf import PdfReader
            reader = PdfReader(file_path)
            pages_text = []
            for page in reader.pages:
                t = page.extract_text()
                if t:
                    pages_text.append(t)
            text_content = "\n".join(pages_text)
        except Exception as e:
            text_content = f"Failed to extract text from PDF: {str(e)}"
    elif file_ext.endswith(".docx") or file_ext.endswith(".doc"):
        try:
            import docx2txt
            text_content = docx2txt.process(file_path)
        except Exception as e:
            text_content = f"Failed to extract text from Word document: {str(e)}"
    else:
        text_content = f"Uploaded un-parsable document named {file.filename} for {service_type}."
        
    # Classify & Extract
    doc_type = doc_processor.classify_document(text_content)
    extracted_info = doc_processor.extract_information(text_content)
    extracted_info["service_type"] = service_type
    
    # Evaluate Rules
    rule_evaluations = rules_engine.evaluate(extracted_info)
    
    # Run Decision Layer
    decision_results = decision_engine.combine_decision(extracted_info, rule_evaluations)
    
    processing_time = round(time.time() - start_time, 2)
    request_id = str(uuid.uuid4())
    
    # Log the audit trail
    audit_log.log_request(
        request_id=request_id,
        file_name=file.filename,
        extracted_info=extracted_info,
        rule_evaluations=rule_evaluations,
        decision_results=decision_results,
        processing_time=processing_time
    )
    
    return {
        "request_id": request_id,
        "document_type": doc_type,
        "extracted_info": extracted_info,
        "rule_evaluations": rule_evaluations,
        "decision": decision_results["final_decision"],
        "ml_decision": decision_results["ml_decision"],
        "ml_confidence": decision_results["ml_confidence"],
        "rules_summary": decision_results["rules_summary"],
        "reason": decision_results["reason"],
        "processing_time": processing_time
    }

@app.get("/logs")
def get_audit_logs():
    return audit_log.get_logs()
