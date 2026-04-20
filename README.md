# 🏦 Loans Data Governance & Data Quality Project

This project was developed as a final assignment for a graduate-level **Data Governance and Data Quality** course. It covers the full data governance lifecycle for a **Loans domain** in a banking context — from database design to data quality scoring.

---

## 📁 Repository Structure

```
├── sql/
│   ├── CUSTOMERS.sql                    # CREATE TABLE - Customers
│   ├── LOAN_ACCOUNT.sql                 # CREATE TABLE - Loan Account
│   ├── LOAN_PAYMENT.sql                 # CREATE TABLE - Loan Payment
│   ├── Section7_8_DQ_Rules_Score.sql    # DQ Rules + Score (Loans)
│   └── Section9_Update_Procedure.sql    # Update Procedure - loan_status
│
├── python/
│   ├── customers_insert.py              # Test data - 5000 rows (Customers)
│   ├── loan_account_insert.py           # Test data - 5000 rows (Loan Account)
│   └── loan_payment_insert.py           # Test data - 5000 rows (Loan Payment)
│
├── excel/
│   ├── Section4_CDE.xlsx                # Critical Data Elements
│   ├── Section5_Metadata.xlsx           # Metadata Definition
│   ├── Section6_SensitivityLevel.xlsx   # Sensitivity Levels
│   └── Section8_DQ_Score.xlsx           # DQ Score Calculations
│
├── drawio/
│   └── Section3_ER_Diagram.xml          # ER Diagram (draw.io)
│
└── README.md
```

---

## 📌 Project Sections

### 1. Domain Selection
Banking **Loans** domain was selected. The domain covers customer information, loan accounts, and payment records.

### 2. Database Design
Three relational tables were designed:

| Table | Description |
|-------|-------------|
| `CUSTOMERS` | Stores customer personal and credit information |
| `LOAN_ACCOUNT` | Stores loan details per customer |
| `LOAN_PAYMENT` | Stores monthly payment records per loan |

**Relationships:**
- `CUSTOMERS` (1) → `LOAN_ACCOUNT` (N)
- `LOAN_ACCOUNT` (1) → `LOAN_PAYMENT` (N)

### 3. ER Diagram (Domain Map)
The ER diagram was created using **draw.io**. It includes all columns, PK/FK labels, and 1:N relationships.

> 📂 File: `drawio/Section3_ER_Diagram.xml`
> Open with: [draw.io](https://app.diagrams.net) → Extras → Edit Diagram → Paste XML

### 4. Critical Data Elements (CDE)
8 CDEs were selected across the 3 tables:

| # | CDE | Table |
|---|-----|-------|
| 1 | `serial_number` | CUSTOMERS |
| 2 | `internal_score` | CUSTOMERS |
| 3 | `principal_amount` | LOAN_ACCOUNT |
| 4 | `interest_rate` | LOAN_ACCOUNT |
| 5 | `loan_status` | LOAN_ACCOUNT |
| 6 | `outstanding_balance` | LOAN_ACCOUNT |
| 7 | `payment_status` | LOAN_PAYMENT |
| 8 | `amount_paid` | LOAN_PAYMENT |

### 5. Metadata Definition
Each CDE is documented with: Column Name, Business Name, Primary Source, Data Location, Secondary Source, Source/Derived flag, and Business Description including how it is used in the business process.

> 📂 File: `excel/Section5_Metadata.xlsx`

### 6. Sensitivity Level
All columns in the Domain Map are assigned a sensitivity level with risk justification.

| Level | Description |
|-------|-------------|
| 🔴 Personal Data | Directly identifies a person |
| 🟠 High Sensitivity | Confidential financial or behavioral data |
| 🟡 Medium Sensitivity | Indirect risk when combined with other data |
| 🟢 Low Sensitivity | Technical metadata, no direct risk |

> 📂 File: `excel/Section6_SensitivityLevel.xlsx`

### 7. Data Quality Rules
22 DQ rules defined across 8 CDEs covering:

| Rule Type | Applied To |
|-----------|------------|
| Completeness | All CDEs |
| Validity | All CDEs |
| Uniqueness | `serial_number` |
| Consistency | `outstanding_balance`, `payment_status`, `amount_paid` |
| Accuracy | `outstanding_balance`, `amount_paid` |

> 📂 File: `sql/Section7_8_DQ_Rules_Score.sql`

### 8. DQ Score Calculation
DQ Score is calculated per CDE based on applicable rule types, then averaged into an **Overall DQ Score**.

```
CDE Score    = Average of applicable rule scores
Overall Score = Average of all CDE scores
```

> 📂 Files: `sql/Section7_8_DQ_Rules_Score.sql`, `excel/Section8_DQ_Score.xlsx`

### 9. Update Procedure
A stored procedure `SP_UPDATE_LOAN_STATUS` was created for the `loan_status` field.

**Input Parameters:**
- `p_loan_id` — Loan ID to update
- `p_new_status` — New status value
- `p_updated_by` — User performing the update

**Validations:**
- Loan must exist
- New status must be valid (`ACTIVE`, `CLOSED`, `DEFAULT`, `DELINQUENT`)
- Status must differ from current
- `CLOSED` loans cannot be reactivated

> 📂 File: `sql/Section9_Update_Procedure.sql`

---

## 🧪 Test Data

Python scripts generate **5000 rows** per table with ~1000 intentional errors for DQ testing purposes.

| Script | Table | Rows | Errors |
|--------|-------|------|--------|
| `customers_insert.py` | CUSTOMERS | 5000 | ~1000 |
| `loan_account_insert.py` | LOAN_ACCOUNT | 5000 | ~1000 |
| `loan_payment_insert.py` | LOAN_PAYMENT | 5000 | ~1000 |

**Error types include:** invalid formats, NULL values, out-of-range values, invalid status codes, future dates, and swapped fields.

---

## 🛠️ Tech Stack

| Tool | Usage |
|------|-------|
| Oracle SQL / PL/SQL | Database, DQ Rules, Stored Procedure |
| Python (cx_Oracle) | Test data generation |
| draw.io | ER Diagram |
| Microsoft Excel | CDE, Metadata, Sensitivity, DQ Score |

---

## ▶️ How to Run

1. Run `CREATE TABLE` scripts in order: `CUSTOMERS` → `LOAN_ACCOUNT` → `LOAN_PAYMENT`
2. Run Python insert scripts to populate test data
3. Run `Section7_8_DQ_Rules_Score.sql` to calculate DQ scores
4. Compile and test `Section9_Update_Procedure.sql`

```sql
-- Test the procedure
DECLARE
    v_code NUMBER;
    v_msg  VARCHAR2(500);
BEGIN
    SP_UPDATE_LOAN_STATUS(
        p_loan_id     => 1,
        p_new_status  => 'DELINQUENT',
        p_updated_by  => 'test_user',
        p_result_code => v_code,
        p_result_msg  => v_msg
    );
    DBMS_OUTPUT.PUT_LINE('Code: ' || v_code);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_msg);
END;
/
```
👤 Author

Name: Rahman

LinkedIn: https://www.linkedin.com/in/mammadovrahman/

---

## 📝 Notes

- All Excel documents are in **Azerbaijani**
- ER Diagram has no *Out of Scope* elements — all columns are included in the Domain Map
- CDEs are highlighted in **green** in the ER Diagram
