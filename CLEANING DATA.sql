-- Data Cleaning

select *
from world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. NUll Values
-- 4. Remove Any Columns

CREATE TABLE layoffs_staging
Like layoffs;

insert layoffs_staging
select *
from layoffs;

select *
from layoffs_staging;

-- 1. Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
where row_num > 1;

SELECT *
FROM layoffs_staging2;

-- 2. Standardize the Data (check all the columns looking for issues and making adjustments where necessary)

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER by 1; -- returns two industries with crypto currency wher one has space and other does not

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; -- returns all rows with the industry begining with Crypto

UPDATE layoffs_staging2
set industry = 'Crypto'
where industry LIKE 'Crypto%'; -- set the indistry that the name starts with Crypto to all be Crypto

SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1; -- All okay

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1; 

UPDATE layoffs_staging2
set country = 'United States'
where country = 'United States.';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
where country like 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- Used to convert to date formart
FROM layoffs_staging2;

UPDATE layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 3. NUll Values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

SELECT *
FROM layoffs_staging2
WHERE industry is NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

update layoffs_staging2
set industry = null
where industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE t1.industry is NULL 
AND t2.industry is NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry is NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

SELECT *
FROM layoffs_staging2;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is null;

ALTER TABLE layoffs_staging2
drop row_num

