| Column                           | Type        | Description                                                |
| -------------------------------- | ----------- | ---------------------------------------------------------- |
| `appeal_id`                      | String      | Unique appeal identifier                                   |
| `patient_age`                    | Integer     | Patient age                                                |
| `procedure`                      | Categorical | Requested medical procedure or treatment                   |
| `denial_reason`                  | Categorical | Reason for initial authorization denial                    |
| `medical_necessity_score`        | Integer     | Synthetic medical-necessity score from 20–100              |
| `documentation_completeness_pct` | Integer     | Percentage of required documentation available             |
| `patient_severity`               | Categorical | Patient condition severity: Low, Medium, High              |
| `previous_treatment_failed`      | Categorical | Whether previous treatment failed                          |
| `clinical_guideline_match`       | Categorical | Whether the request matches applicable clinical guidelines |
| `previous_authorization_history` | Categorical | Previous authorization history                             |
| `appeal_submitted`               | Categorical | Whether an appeal was submitted                            |
| `appeal_success_probability`     | Float       | Synthetic probability of successful appeal                 |
| `actual_appeal_outcome`          | Categorical | **Actual appeal result — target variable**                 |
| `predicted_appeal_outcome`       | Categorical | Synthetic baseline prediction based on probability         |
