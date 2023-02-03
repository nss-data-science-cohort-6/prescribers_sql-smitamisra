--UNderstanding the schemas/tables
SELECT *
from public.prescription;
--656058 rows
----------------------
SELECT *
from public.prescriber;
--25050 rows
------------
SELECT COUNT(DISTINCT npi) as npi_count
FROM prescriber
--25050 total number of prescribers
----------------------
SELECT COUNT(DISTINCT specialty_description) AS cpec_count
FROM prescriber
--107
----
SELECT COUNT(DISTINCT npi) as npi_count
FROM prescription
--20592 is the number of doctors
----------
SELECT *
FROM prescription
--656058 total doctor/drug combination
-------------------
SELECT COUNT(DISTINCT drug_name) as drug_types
FROM prescription
--1821 number of drugs name
----------------------------

-- Q1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS totalclaimcount
FROM prescription
GROUP BY npi
ORDER BY totalclaimcount DESC;

--npi 1881634483 has maximum prescription with count of 99707

-- Q1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
FROM prescriber
WHERE npi = 1881634483;

--1881634483	"BRUCE"	"PENDLEY"	"Family Practice"--

--Q2a.  Which specialty had the most total number of claims (totaled over all drugs)?

SELECT 
	specialty_description,
	SUM(total_claim_count) AS totalclaimcount
FROM prescription AS pres
INNER JOIN prescriber AS scr
	ON pres.npi = scr.npi
GROUP BY  specialty_description
ORDER BY totalclaimcount DESC;

--There are 92 speciality in the prescription with family Practice with 9752347
--Q2b. Which specialty had the most total number of claims for opioids?
select *
FROM drug
WHERE opioid_drug_flag = 'Y'
--91 drugs are flagged as OPIOID DRUGS
SELECT 
	specialty_description,
	SUM(total_claim_count) AS totalclaimcount
FROM prescription AS pres
LEFT JOIN prescriber AS scr
	ON pres.npi = scr.npi
LEFT JOIN drug as dr
	ON pres.drug_name = dr.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY  specialty_description
ORDER BY totalclaimcount DESC;
---number of drugs flagged Yes as opioid Rank#1: "Nurse Practitioner"#ofpres=900845, followed by Rank#2:"Family Practice"#ofpres=467246
------------------
--Q2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT specialty_description
FROM prescriber AS A
LEFT JOIN prescription AS B
ON A.npi = B.npi
--WHERE B.npi IS NULL
EXCEPT 
GROUP BY specialty_description; --needs to be modified for missing NPI to get speciality

--92 speciality out of 107 are not in the prescription dataset. 4458 prescribers are not there in the prescription dataset.

--Q2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--Q3a. Which drug (generic_name) had the highest total drug cost?
SELECT drug_name, MAX(total_drug_cost) AS high_cost
FROM prescription
GROUP BY drug_name
ORDER BY high_cost DESC;



