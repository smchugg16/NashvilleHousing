/* 

---Cleaning Data using SQL Queries---

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------

---Standardizing Date Formatting---
SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------

---Populating Property Address Data---

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
---WHERE PropertyAdress IS NULL
ORDER BY ParcelID

/*SELF JOIN TO FILL NULL ADDRESSSES*/
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

/* Updating Table using the self join query above- run again afterwards to check if it contains no rows */
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueId] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL 

------------------------------------------------------------------------------------------

---Breaking PropertyAddress into Individual Columns (Address, City, State)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
---WHERE PropertyAdress IS NULL
---ORDER BY ParcelID



/*Split Property Address using SUBSTRING - Address and City */ 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing


/*Splitting Address via ALTER TABLE to Create New Columns & UPDATE using above query*/
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
PropertySplitCity Nvarchar(255);


UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))



/*Splitting up Owner Address into Address, City, State using PARSENAME*/ 

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) AS State
FROM PortfolioProject.dbo.NashvilleHousing


/*Adding Address, State, City columns to table & UPDATE using above query to split */ 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
OwnerSplitState Nvarchar(255),
OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
 OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
 OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)


 /*Checking to see if above queries worked as desired*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

 ------------------------------------------------------------------------------------------

 ---Changing Y and N to Yes and No in "Sold as Vacant" field---

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM PortfolioProject.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2


 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing


 UPDATE PortfolioProject.dbo.NashvilleHousing
 SET SoldAsVacant = 
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------------------------

---Removing Duplicates---

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1 
---ORDER BY PropertyAddress

------------------------------------------------------------------------------------------

---Deleting Unused Columns---

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
