# SDR Project – Phase II Dose-Response Simulation Study

## Overview

This repository contains the statistical analysis code and simulation framework for a Phase II randomized, double-blind, placebo-controlled dose-ranging clinical trial simulation evaluating Drug X in aging Canadian adults with established heart disease.

The project integrates SAS and R workflows to evaluate:
- Dose–response effects on left ventricular ejection fraction (LVEF)
- Optimal Dose–finding on for CVD drug
- Exploratory time-to-event outcomes (3-point MACE)

The analysis follows a pre-specified Statistical Analysis Plan (SAP) aligned with ICH E9(R1) estimand principles.

---

## Study Design

- Phase II randomized, double-blind, placebo-controlled trial
- 5 treatment arms (1:1:1:1:1 allocation):
  - Placebo  
  - Drug X 5 mg  
  - Drug X 10 mg  
  - Drug X 25 mg  
  - Drug X 50 mg  
- Treatment duration: 6 months
- Sample size: N = 300 (60 per arm)

---

## Primary Objective

To evaluate the dose–response relationship of Drug X on change from baseline to Month 6 in LVEF, compared with placebo, 

## Secondary Objective

To identify an optimal dose or dose range for Phase III development in aging Canadian adults with heart disease.

## Tertiary Objective

To evaluate the effect of Drug X dose on 3-point Major Adverse Cardiovascular Events (MACE) using time-to-event methods.

---

## Endpoints

### Primary Endpoint
- Change from baseline to Month 6 in LVEF (%)

### Secondary Endpoint
- Time to first 3-point MACE

### Safety Endpoints
- Treatment-emergent adverse events (TEAEs)
- Serious adverse events (SAEs)
- Laboratory and vital sign changes (descriptive only)

---

## Statistical Methods

### Primary Analysis
- Mixed Model for Repeated Measures (MMRM)
- Multiple Comparison Procedures and Modeling (MCP–Mod)
- Candidate dose–response models:
  - Linear, quadratic, exponential, Emax, sigmoid Emax
- Model selection based on AIC and clinical plausibility

### Secondary Analysis
- Cox proportional hazards models (cause-specific HRs)
- Kaplan–Meier survival curves
- Sensitivity analysis using IPCW Cox models for dropout

### Safety Analysis
- Descriptive summaries only
- No formal hypothesis testing

---

## Missing Data Handling

### Primary Endpoint (LVEF)
- Assumed Missing At Random (MAR)
- Handled via MMRM
- Sensitivity: Multiple Imputation + Rubin’s Rules

### Time-to-Event Outcomes (MACE)
- Right censoring at last follow-up
- Dropout assessed via sensitivity Cox models

### Safety
- No imputation (descriptive summaries only)

---

## Analysis Populations

- ITT Population: All randomized participants receiving ≥1 dose (primary efficacy)
- PP Population: Completers without MACE (sensitivity only)
- Safety Population: All participants receiving ≥1 dose
- Time-to-Event Population: ITT subset with valid follow-up data

---

## Study Workflow

1. Data simulation (SAS)
2. Data cleaning and transformation (SAS + R)
3. Primary modeling (MMRM + MCP–Mod in R)
4. Survival analysis (Cox models in R)
5. Safety summaries (R)
6. Reporting and visualization (R Markdown / Quarto)

---

## Software

- R (version 4.5.2) – data simulation, MCP-Mod 
- SAS (version 9.4) – descriptive analysis, MMRM, Cox modeling


SAS is executed in a VMware environment (R is executed in Mac).
Intermediate CSV outputs (mcpmod_*.csv) are transferred manually.

While all data is readily available, to reproduce from scratch:
1. Run scripts in order
2. Copy R/mac CSV outputs into SAS/windows folder
3. Copy SAS/windows CSV outputs into R/mac folder (/data/)
4. Continue on with MCP-Mod script in R

---

## Repository Structure

SDR-Project/
│
├── data/              # raw, processed, simulated datasets
├── R/                 # R analysis scripts
├── sas/               # SAS programs and macros
├── outputs/           # tables, figures, model outputs
├── docs/              # SAP, methodology, data dictionary
├── README.md

---

## Key Features

- Phase II clinical trial simulation
- Mixed Models for Repeated Measures (MMRM)
- Dose–response modeling / optimal dose-finding (MCP–Mod framework)
- Survival analysis (Cox proportional hazards models)
- R + SAS pipeline
- Estimand-aligned design (ICH E9 R1)

---

## Notes

- This is a simulated Phase II trial (no real patient data)
- Safety outputs are descriptive and illustrative

