SELECT *
from public.prescription;
SELECT *
from public.prescriber;

-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.



SELECT npi, SUM(total_claim_count) AS totalclaimcount
FROM prescription
GROUP BY npi
ORDER BY totalclaimcount DESC;

--npi 1881634483 has maximum prescription with count of 99707

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
FROM prescriber
WHERE npi = 1881634483;




