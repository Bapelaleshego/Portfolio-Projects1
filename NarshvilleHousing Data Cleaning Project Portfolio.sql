--Cleaning Data In SQL Queries

SELECT *
FROM PortfolioProjects.dbo.NarshvilleHousing

--Standerdize Date Format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProjects.dbo.NarshvilleHousing

UPDATE NarshvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NarshvilleHousing
ADD SaleDateConverted DATE;

UPDATE NarshvilleHousing
SET  SaleDateConverted = CONVERT(DATE,SaleDate)


--Populate Proparty Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NarshvilleHousing a
JOIN PortfolioProjects.dbo.NarshvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NarshvilleHousing a
JOIN PortfolioProjects.dbo.NarshvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


--Breaking out the Address into Individual Columns(Address, City, States)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as City
FROM  PortfolioProjects.dbo.NarshvilleHousing

ALTER TABLE NarshvilleHousing
ADD PropertySpiltAddress VARCHAR(255);

UPDATE NarshvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NarshvilleHousing
ADD PropertySpiltCity VARCHAR(255)

UPDATE NarshvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))

SELECT *
FROM PortfolioProjects.dbo.NarshvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProjects.dbo.NarshvilleHousing

ALTER TABLE NarshvilleHousing
ADD OwnerSpiltaddress VARCHAR(255)

UPDATE NarshvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NarshvilleHousing
ADD OwnerSpiltCity VARCHAR(255)

UPDATE NarshvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NarshvilleHousing
ADD OwnerSpiltStates VARCHAR(255)

UPDATE NarshvilleHousing
SET OwnerSpiltStates = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProjects.dbo.NarshvilleHousing


--Change Y and N to Yes and NO in "Sold as Vacant" flead

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.NarshvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
  
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjects.dbo.NarshvilleHousing

UPDATE NarshvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE as (
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				       UniqueID
					   )row_num
FROM PortfolioProjects.dbo.NarshvilleHousing
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


--Delete Unused Columns

SELECT *
FROM PortfolioProjects.dbo.NarshvilleHousing

ALTER TABLE PortfolioProjects.dbo.NarshvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate