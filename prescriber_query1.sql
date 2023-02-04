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
--from Michael Holloway
--solution1 using the inner join


--solution2 using the inner join
--using subqueries
-- SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
-- FROM prescriber
-- WHERE npi= (
-- 	SELECT npi
-- 	from prescription
-- 	GROUP BY npi
-- 	ORDER BY SUM(total_claim_count) DESC
-- 	LIMIT 1);

--solution3 using the inner join
--from tomo using ct
-- WITH sum_claims AS (
-- SELECT npi, SUM(total_claim_count) AS total_claims
-- FROM prescription
-- GROUP BY npi
-- ORDER BY total_claims DESC
-- LIMIT 5
-- )
-- SELECT sum_claims.npi,
--  nppes_provider_first_name AS first_name,
--  nppes_provider_last_org_name AS last_name,
--  specialty_description,
--  total_claims
-- FROM sum_claims
-- INNER JOIN prescriber AS p
-- ON sum_claims.npi = p.npi
-- ORDER BY total_claims DESC;

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

--Note there are duplication in drug name and also the opioid labels that needs to be addressed
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription 
INNER JOIN prescriber
USING(npi)
INNER JOIN 
(
	SELECT DISTINCT drug_name, opioid_drug_flagFROM drug) sub
	USING(drug_name)WHERE opioid_drug_flag = 'Y'GROUP BY specialty_descriptionORDER BY total_claims DESC

------------------
--Q2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT specialty_description
FROM prescriber AS A
LEFT JOIN prescription AS B
ON A.npi = B.npi
--WHERE B.npi IS NULL
--EXCEPT 
GROUP BY specialty_description; --needs to be modified for missing NPI to get speciality

------
SELECT *
FROM (SELECT DISTINCT specialty_description
	  FROM prescriber -- There are 107 specialites here
	 ) AS all_specialties
WHERE specialty_description NOT IN (SELECT DISTINCT specialty_description
									FROM prescription as rx
									LEFT JOIN prescriber as doc
									USING(npi) -- There are 92 specialites here
								   )
---------

--92 speciality out of 107 are not in the prescription dataset. 4458 prescribers are not there in the prescription dataset.

--Q2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--Q3a. Which drug (generic_name) had the highest total drug cost?
-- SELECT drug_name, MAX(total_drug_cost) AS drugcost
-- FROM prescription
-- GROUP BY drug_name
-- ORDER BY drugcost DESC;

--"ESBRIET"	2829174.30 has the max drug price but we need the genric name so need the join with drug table
SELECT 
	fd.generic_name,
	SUM(p.total_drug_cost)::money AS drugcost
FROM prescription as p
INNER JOIN drug as fd
-- 	USING(drug_name)
	ON p.drug_name = fd.drug_name
GROUP BY fd.generic_name
ORDER BY drugcost DESC;


--Q3b. b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT 
	  generic_name, 
-- 	total_day_supply,
-- 	total_drug_cost,
	ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS perday_cost
FROM prescription AS A
INNER JOIN drug AS B
ON A.drug_name = B.drug_name
GROUP BY generic_name 
ORDER BY perday_cost DESC;

--"C1 Esterase Inhibitor" CINRYZE is the most expensive drug has a perday cost of 3495.22

--Q4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

-- SELECT fd.drug_name, (CASE WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'opioid'
--              WHEN opioid_drug_flag = 'N' AND antibiotic_drug_flag = 'Y' THEN 'antibiotic'
--              ELSE 'neither'
--         END) AS drug_type
--        --fd.drug_name
-- 	   FROM drug fd;
---output has 3425
---because there are duplicates in drug_name will use the distinct
SELECT DISTINCT fd.drug_name, (CASE WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'opioid'
             WHEN opioid_drug_flag = 'N' AND antibiotic_drug_flag = 'Y' THEN 'antibiotic'
             ELSE 'neither'
        END) AS drug_type
       --fd.drug_name
	   FROM drug fd;
--now we have 3260

--Q4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT (CASE WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'opioid'
             WHEN opioid_drug_flag = 'N' AND antibiotic_drug_flag = 'Y' THEN 'antibiotic'
             ELSE 'neither'
        END) AS drug_type,
		COALESCE(SUM(B.total_drug_cost), 0) AS cost
       --fd.drug_name
	   FROM drug fd
LEFT JOIN prescription AS B
ON fd.drug_name = B.drug_name
GROUP BY drug_type
ORDER BY cost DESC;

---more money is spent on opioid compared to antibiotics.

--Q5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee

SELECT *
FROM cbsa;
--there are three columns and 1238 rows in cbsa
SELECT cbsaname, COUNT(DISTINCT c.cbsa)
FROM cbsa AS c
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname;
--There are 10 cbsa for TN

--Q5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsa, c.cbsaname, 
	SUM(p.population)as total_pop
FROM population as p
LEFT JOIN cbsa as c
	ON p.fipscounty = c.fipscounty
GROUP BY c.cbsa, c.cbsaname
--ORDER BY total_pop ASC;
ORDER BY total_pop DESC;

--SMALLEST::"34100"	"Morristown, TN"	116352
--LARGEST::"34980"	"Nashville-Davidson--Murfreesboro--Franklin, TN"	1830410

--Q5c.What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population

SELECT  p.population, fc.county
FROM population as p
LEFT JOIN fips_county as fc
	ON p.fipscounty = fc.fipscounty
LEFT JOIN cbsa as c
	ON c.fipscounty = fc.fipscounty
WHERE c.fipscounty IS NULL
ORDER BY p.population DESC;

--SEVIER county is not included population as 95523. Total 53 county are not included.

--Q6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
--9 drugs have above 3000 caims

--Q6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT fd.drug_name, B.total_claim_count,
		(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid_YES'
         ELSE 'opioid_NO'
        END) AS drug_type
	FROM drug as fd
LEFT JOIN prescription AS B
	ON fd.drug_name = B.drug_name
WHERE B.total_claim_count >= 3000
-- 	AND fd.opioid_drug_flag = 'Y'
	
ORDER BY B.total_claim_count DESC;
--out of 9 two are YES for opioid

--Q6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT fd.drug_name, 
		b.total_claim_count, 
		p.nppes_provider_first_name AS provider_first_name,
		p.nppes_provider_last_org_name AS provider_last_name,
		(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid_YES'
         ELSE 'opioid_NO'
        END) AS drug_type
	FROM drug as fd
LEFT JOIN prescription AS B
	ON fd.drug_name = B.drug_name
LEFT JOIN prescriber AS p
	ON B.npi = p.npi
WHERE B.total_claim_count >= 3000
ORDER BY B.total_claim_count DESC;
--DAVID COFFEY is the provider giving both the OPIOID prescription with a clam count over 3000.

--Q7a a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT fd.drug_name, 
-- 		p.npi 
-- 		p.nppes_provider_first_name AS provider_first_name,
-- 		p.nppes_provider_last_org_name AS provider_last_name,
-- 		(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid_YES'
--          ELSE 'opioid_NO'
--         END) AS drug_type
-- FROM drug as fd
-- LEFT JOIN prescription AS b
-- 	ON fd.drug_name = b.drug_name
-- LEFT JOIN prescriber AS p
-- 	ON p.npi = b.npi
-- WHERE p.specialty_description = 'Pain Management'
-- 	AND p.nppes_provider_city = 'NASHVILLE'
-- -- 	AND fd.opiod_drug_flag = 'Y';

-- SELECT specialty_description
-- FROM prescriber AS p
-- GROUP BY specialty_description
-- ORDER BY specialty_description DESC;
-- WHERE p.specialty_description = 'Pain Management'
-- 	AND p.nppes_provider_city = 'NASHVILLE'

-----MAGIC of "CROSS JOIN" does not need overlapping colbut uses the condition
SELECT p.npi,
	fd.drug_name
FROM prescriber AS p
CROSS JOIN drug AS fd
WHERE p.specialty_description = 'Pain Management'
	AND p.nppes_provider_city = 'NASHVILLE'
	AND fd.opioid_drug_flag = 'Y'
--got 637 rows now

--Q7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi,
	fd.drug_name,
	c.total_claim_count
FROM prescriber AS p
CROSS JOIN drug AS fd
FULL JOIN prescription AS c
	USING(npi, drug_name)
	WHERE p.specialty_description = 'Pain Management'
	AND p.nppes_provider_city = 'NASHVILLE'
	AND fd.opioid_drug_flag = 'Y'
--these are shared columns from the cross join now

--Q7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT p.npi,
	fd.drug_name,
	COALESCE(c.total_claim_count, 0)
FROM prescriber AS p
CROSS JOIN drug AS fd
FULL JOIN prescription AS c
	USING(npi, drug_name)
	WHERE p.specialty_description = 'Pain Management'
	AND p.nppes_provider_city = 'NASHVILLE'
	AND fd.opioid_drug_flag = 'Y'
----bonus Questions
--B1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT COUNT(DISTINCT npi)
FROM prescriber as p
LEFT JOIN prescription as rx
	USING(npi)
WHERE rx.npi IS NULL
--4458 npi not in prescription but in prescriber
--B2a Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT fd.generic_name,
	SUM(c.total_claim_count) as totalcount
FROM prescription as c
LEFT JOIN prescriber as p
	USING(npi)
LEFT JOIN drug as fd
	USING(drug_name)
WHERE p.specialty_description = 'Family Practice'	
GROUP BY fd.generic_name
ORDER BY totalcount DESC
LIMIT 5;

--top five 406547 drugs LEVOTHYROXINE SODIUM, LISINOPRIL, ATORVASTATIN CALCIUM, AMLODIPINE BESYLATE, OMEPRAZOLE

--B2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT fd.generic_name,
	SUM(c.total_claim_count) as totalcount
FROM prescription as c
LEFT JOIN prescriber as p
	USING(npi)
LEFT JOIN drug as fd
	USING(drug_name)
WHERE p.specialty_description = 'Cardiology'	
GROUP BY fd.generic_name
ORDER BY totalcount DESC
LIMIT 5;

--top 5 for cardiologist are ATORVASTATIN CALCIUM, CARVEDILOL, METOPROLOL TARTRATE, CLOPIDOGREL BISULFATE, AMLODIPINE BESYLATE

--Q2c. Which drugs appear in the top five prescribed for both Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

-- SELECT fd.generic_name,
-- 	SUM(c.total_claim_count) as totalcount
-- FROM prescription as c
-- LEFT JOIN prescriber as p
-- 	USING(npi)
-- LEFT JOIN drug as fd
-- 	USING(drug_name)
-- WHERE p.specialty_description IN ('Cardiology', 'Family Practice')	
-- GROUP BY fd.generic_name
-- ORDER BY totalcount DESC
-- LIMIT 5;

-----
SELECT fam.generic_name,
	fam.totalcount as fam_total,
	car.totalcount as car_total
FROM (
SELECT fd.generic_name,
	SUM(c.total_claim_count) as totalcount
FROM prescription as c
LEFT JOIN prescriber as p
	USING(npi)
LEFT JOIN drug as fd
	USING(drug_name)
WHERE p.specialty_description = 'Family Practice'	
GROUP BY fd.generic_name
ORDER BY totalcount DESC
	LIMIT 5
)AS fam
INNER JOIN (
	SELECT fd.generic_name,
	SUM(c.total_claim_count) as totalcount
FROM prescription as c
LEFT JOIN prescriber as p
	USING(npi)
LEFT JOIN drug as fd
	USING(drug_name)
WHERE p.specialty_description = 'Cardiology'	
GROUP BY fd.generic_name
ORDER BY totalcount DESC
	LIMIT 5
)AS car
USING(generic_name)

	


