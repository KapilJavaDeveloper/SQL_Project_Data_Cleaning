-------------------- DATA CLEANING ------------------

USE world_layoffs ;
SELECT *
FROM world_layoffs.layoffs ;

----- 1. Remove Duplicates 
---- 2. Stamdardize the Data 
---- 3. Null Values or blank Values
---- 4. Remove Any Columns 

CREATE TABLE layoffs_staging LIKE layoffs ;

INSERT layoffs_staging
SELECT * 
FROM layoffs ;

SELECT *
FROM layoffs_staging ; 

----- ADDING A COLUMN FOR UNIQUELY IDENTIFY EACH ROW --------------

--- CHECKING DUPLICATES IN A TABLE ---
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location , industry , total_laid_off, percentage_laid_off , `date` , stage , country , funds_raised_millions)
AS row_num
FROM layoffs_staging 
) 
SELECT  * 
FROM duplicate_cte
WHERE 
row_num > 1 ;


----- CREATE ANOTHER TABLE LIKE layoffs_staging WITH extra column row_num ----
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- CHECKING A VIEW OF A TABLE ----
SELECT * 
FROM 
layoffs_staging2 ;


-----  INSERT INTO layoffs_staging2 FROM layoffs_staging 
INSERT INTO   
layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company , location , industry , total_laid_off, percentage_laid_off , `date` , stage , country , funds_raised_millions) 
AS row_num
FROM layoffs_staging
;

--- RETRIEVE THE TABLE -----
SELECT * 
FROM layoffs_staging2 ;

SELECT *
FROM layoffs_staging2 
WHERE row_num>1 ; 

DELETE FROM 
layoffs_staging2
WHERE row_num>1 ;

-------------  STANDARDIZE THE DATA --------------


----- FINDING THE UNSTANDARDIZE DATA ----------------
SELECT company , TRIM(company)
FROM layoffs_staging2 ;

--- Standardizing the data -----
UPDATE layoffs_staging2
SET company = TRIM(company) ;


--- checking for Company ----
SELECT DISTINCT industry 
FROM layoffs_staging2 ORDER BY 1 ;

----- Find crypto and crytocurrency industry which are same ---

SELECT *
FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%' ;


---- UPADTE ALL 'Cypto%' TO 'Crypto'-----
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' ;

---- Checking For Countries ----
SELECT
DISTINCT country
FROM layoffs_staging2
ORDER BY 1 ;

---- United States is Represented By Two Ways---
SELECT
DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1 ;

SELECT
DISTINCT country , TRIM( TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1 ;


---- Update Country ----
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United Stat%' ;


-------- date format be text -------
SELECT 
	`date` ,
	STR_TO_DATE(`date` , '%m/%d/%Y') 
FROM 
	layoffs_staging2 ;
    
UPDATE 
	layoffs_staging2
SET 
	`date` = STR_TO_DATE(`date` , '%m/%d/%Y') ;
    
ALTER TABLE 
	layoffs_staging2 
MODIFY COLUMN 
	`date` DATE ;
   
   
   
   ---------- Handling NULL Values---------

-- check for blank or null industry---
SELECT 
	*
FROM 
	layoffs_staging2
WHERE 
	industry = ''
OR
	industry IS NULL ;
    


SELECT 
	t1.industry , t2.industry 
FROM 
	layoffs_staging2 AS t1
JOIN 
	layoffs_staging2 AS t2
ON
	t1.company = t2.company
AND
	t1.location = t2.location 
WHERE 
	(t1.industry IS NULL OR t1.industry = '')
AND
	t2.industry IS NOT NULL ;
    
    
UPDATE 
	layoffs_staging2 
SET 
	industry = NULL
WHERE 
	industry = '' ;
    
-- Update null industry ---
UPDATE
	layoffs_staging2 t1 
JOIN 
	layoffs_staging2 t2
ON 
	t1.company = t2.company
SET 
	t1.industry = t2.industry
WHERE 
	t1.industry IS NULL 
AND 
	t2.industry IS NOT NULL  ;

	
  	
------- REMOVE UNWANTED data ---------

----- searching for data having 0 layoffs and 0 percentage_layoff ------
SELECT *
FROM 
	layoffs_staging2
WHERE 
	total_laid_off IS NULL 
		AND
	percentage_laid_off IS NULL 
;

--- Deleting the data---
DELETE
FROM
	layoffs_staging2
WHERE
	total_laid_off IS NULL 
AND 
	percentage_laid_off IS NULL ;
    
--- Deleting column row_num -----

ALTER 
TABLE 
	layoffs_staging2
DROP COLUMN
	row_num ;

SELECT 
*
FROM 
	layoffs_staging2 ;



















