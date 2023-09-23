--Coding so far
--1
SELECT *
FROM Animals AS A
CROSS JOIN 
Adoptions AS AD;

--Animals that aren't adopted shouldn't be here, cause there
--isn't an ID for adoption
SELECT AD.*, A.Implant_Chip_ID, A.Breed
FROM Animals AS A
INNER JOIN
Adoptions AS AD
ON AD.Name = A.Name
AND
AD.Species = A.Species;
--So if you want to recover the non adopted animals, you do a left 
--outer join:
SELECT AD.*, A.Implant_Chip_ID, A.Breed
FROM Animals AS A
LEFT OUTER JOIN
Adoptions AS AD
ON AD.Name = A.Name
AND
AD.Species = A.Species;
--There are nulls because they are calling AD table which doesn't have match in
--AD, so ofc is null!! you fix calling them in SELECT retreve them
SELECT A.Name, 
  A.Species, 
  AD.Adopter_Email,
  AD.Adoption_Date, 
  AD.Adoption_Fee, 
  A.Implant_Chip_ID, 
  A.Implant_Chip_ID, 
  A.Breed
FROM Animals AS A
LEFT OUTER JOIN
Adoptions AS AD
ON AD.Name = A.Name
AND
AD.Species = A.Species;

--2
SELECT *
FROM Animals AS A
INNER JOIN
Adoptions AS AD
  ON AD.Name = A.Name AND AD.Species = A.Species
INNER JOIN
Persons AS P
ON P.Email = AD.Adopter_Email;

SELECT *
FROM Animals AS A
LEFT OUTER JOIN 
Adoptions AS AD
  ON AD.Name = A.Name AND AD.Species = A.Species
INNER JOIN
Persons AS P
ON P.Email = AD.Adopter_Email;
--this will give 70 rows, the second inner join just cosinders adopted, not animals in general.
--So, the bad practice is to do this:
SELECT *
FROM Animals AS A
LEFT OUTER JOIN 
Adoptions AS AD
  ON AD.Name = A.Name AND AD.Species = A.Species
LEFT OUTER JOIN
Persons AS P
ON P.Email = AD.Adopter_Email;
--The good practice is to change orders.
SELECT *
FROM Animals AS A
LEFT OUTER JOIN 
(
Adoptions AS AD
INNER JOIN
Persons AS P
ON P.Email = AD.Adopter_Email
  )
ON AD.Name = A.Name AND AD.Species = A.Species;
--Which is the same to just delete parenthesis, because
--the trick was the movement of the ON clause!!!
SELECT *
FROM
Animals AS A
LEFT OUTER JOIN 
Adoptions AS AD
INNER JOIN
Persons AS P
ON P.Email = AD.Adopter_Email
ON AD.Name = A.Name AND AD.Species = A.Species;

--3
--animals, vaccinations, staff_assignments, persons
SELECT 
A.Name
,A.Species
,A.Breed
,A.Primary_Color
,V.Vaccination_Time
,V.Vaccine 
,P.First_Name
,P.Last_Name
,SA.Role
FROM

Animals AS A   
LEFT OUTER JOIN
(
Vaccinations AS V 
INNER JOIN
Staff_Assignments AS SA
INNER JOIN
Persons AS P 
ON SA.Email = P.Email
ON P.Email = V.Email 
)
ON A.Name = V.Name AND V.Species = A.Species;

--4
SELECT *
FROM
Animals
WHERE Species = 'Dog'
AND 
Breed <> 'Bullmastiff';
--we don't get the null values from this query! even tho nulls aren't
--bullmastiffs
--null: non-applicable attribute.

--5
--This query doesn't work: you can't use those comparatives for nulls
SELECT *
FROM Animals
WHERE Breed != NULL
OR Breed = NULL;
--another way to do this: but more complicated, it is too verbose, confusing
SELECT *
FROM Animals
WHERE Breed != 'Bullmastiff'
  OR
  Breed IS NULL;

--6
SELECT Name,
  Species,
  Count(*) AS Count
FROM Vaccinations
GROUP BY Name, Species;

--7
SELECT Species,
Breed,
COUNT(*) AS Number_Of_Animals
FROM Animals
GROUP BY Species,
Breed;

SELECT YEAR(Birth_Date) AS Year_Born,
COUNT(*) AS Number_Of_Persons
FROM Persons
GROUP BY YEAR(Birth_Date);

--A way to get the year:
SELECT YEAR(CURRENT_TIMESTAMP) - YEAR(Birth_Date) AS Age,
COUNT(*) AS Number_Of_Persons
FROM Persons
GROUP BY YEAR(Birth_Date);

--with error: because name and species dont have like count
SELECT DISTINCT Species, Name, Count(*)
FROM Vaccinations
GROUP BY Species, Name;

SELECT  Species, Count(*) AS Num_Vaccines
FROM Vaccinations
GROUP BY Species, Name
ORDER BY Species, Num_Vaccines;

SELECT  DISTINCT Species, Count(*) AS Num_Vaccines
FROM Vaccinations
GROUP BY Species, Name
ORDER BY Species, Num_Vaccines;

--8
SELECT Adopter_Email,
COUNT(*) AS Number_Of_Adoptions
FROM Adoptions
GROUP BY Adopter_Email
ORDER BY Number_Of_Adoptions DESC;

--now we add a condition that more than 1 adoption made

SELECT Adopter_Email,
COUNT(*) AS Number_Of_Adoptions
FROM Adoptions
GROUP BY Adopter_Email
HAVING COUNT(*) > 1 
  AND
  Adopter_Email NOT LIKE '%gmail.com'
ORDER BY Number_Of_Adoptions DESC;

--wrong! do it in the WHERE
SELECT Adopter_Email,
COUNT(*) AS Number_Of_Adoptions
FROM Adoptions
WHERE Adopter_Email NOT LIKE '%gmail.com'
GROUP BY Adopter_Email
HAVING COUNT(*) > 1 
ORDER BY Number_Of_Adoptions DESC;

--9
--vaccinations, animals
SELECT 
A.Species,
A.Name,
MAX(A.Primary_Color) AS Primary_Color,
MAX(A.Breed) AS Breed,
COUNT(V.Vaccine) AS Num_Vaccinations
--V.Vaccination_Time
FROM Animals AS A 
LEFT JOIN 
  Vaccinations AS V
ON V.Name = A.Name AND V.Species = A.Species
WHERE A.Species <> 'Rabbit'
AND (V.Vaccine <> 'Rabies' OR V.Vaccine IS NULL)
--AND V.Vaccination_Time > '2019-10-01 00:00:00.000'
GROUP BY A.Species, A.Name
HAVING MAX(V.Vaccination_Time) < '20191001' OR MAX(V.Vaccination_Time) IS NULL
ORDER BY A.Species, A.Name


--10
SELECT *
FROM Animals
ORDER BY 2,5,1;
--or
SELECT *
FROM Animals
ORDER BY Species, Breed, Name;
--which the second one is better

--11
SELECT 
Adoption_Date, Species, Name
FROM 
Adoptions
ORDER BY
Adoption_Date DESC;

SELECT Species, Name
FROM 
Adoptions
ORDER BY
Adoption_Date DESC;

SELECT * --Adoption_Date, Species, Name
FROM Animals
ORDER BY Species, Name;

--12
SELECT TOP(3) *
FROM Animals;
--is not very useful, no guarantee which 3 rows will be return

SELECT *
FROM Animals
ORDER BY Admission_Date DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;


--PARTE 2
--1
--show adoption rows including fees. MAX fee ever paid. 
--Discount from MAX in percent
SELECT MAX(Adoption_Fee)
FROM Adoptions;

SELECT *, (SELECT MAX(Adoption_Fee) FROM Adoptions),
  (((SELECT MAX(Adoption_Fee) FROM Adoptions) - Adoption_Fee) * 100)/(SELECT MAX(Adoption_Fee) FROM Adoptions) AS Discount_Percent
FROM Adoptions;

--MAX fee per species 
SELECT *,
  ( SELECT MAX(Adoption_Fee)
  FROM Adoptions AS A2
  WHERE A2.Species = A1.Species
  ) AS Max_Fee
FROM Adoptions AS A1
--at runtime: A1 species will be replaces with the species from the
--outer row, and the max from A2 will be picked among the rows only
--for that same species in the second instance of the table A1.

--show all attributes for people that adopted at least one animal
SELECT DISTINCT P.*
FROM Persons AS P
INNER JOIN
Adoptions AS A
ON A.Adopter_Email = P.Email;
--other way to do it:
SELECT *
FROM Persons
WHERE Email IN (SELECT Adopter_Email FROM Adoptions);
--other way with EXIST
SELECT *
FROM Persons AS P
WHERE EXISTS (
  SELECT NULL
  FROM Adoptions AS A
  WHERE A.Adopter_Email = P.Email
  );


--2
--Animals not adopted
--one way:
SELECT DISTINCT
AN.Name, AN.Species
FROM Animals AS AN
LEFT OUTER JOIN
  Adoptions AS AD
ON AD.Name = AN.Name AND AD.Species = AN.Species
WHERE AD.Name IS NULL;
--another way:
SELECT Name, Species
FROM Animals AS AN
WHERE NOT EXISTS(
  SELECT NULL
  FROM Adoptions AS AD
  WHERE AD.Name = AN.Name AND AD.Species = AN.Species
  );
--set operator: SQL AT ITS BEST! SIMPLE CONCISE EFFICIENT
SELECT Name, Species
FROM Animals 
EXCEPT
SELECT Name, Species
FROM Adoptions 

--3
SELECT DISTINCT
AN.Breed 
FROM Animals AS AN
LEFT OUTER JOIN
  Adoptions AS AD
ON AD.Name = AN.Name AND AD.Species = AN.Species
WHERE AD.Name IS NULL AND AN.Breed IS NOT NULL;

--a better way:
SELECT Species, Breed
FROM Animals
EXCEPT
SELECT AN.Species, AN.Breed
FROM Animals AS AN
INNER JOIN
Adoptions AS AD
ON AN.Species = AD.Species
AND
AN.Name = AD.Name;
--compare it with the join table!! easy peasy

 
