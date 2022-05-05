/*
Cleaning Data in SQL Queries
*/

Select *
from PortfolioProject..NashvilleHousing

-- *Standardize Date Format
Select SaleDate , CONVERT(Date,SaleDate )
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate  = CONVERT(Date,SaleDate )

-- *Update did not properly, try alter

ALTER TABLE NarshvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted  = CONVERT(Date,SaleDate )

-- *Dealing with NULL in PropertyAddress
-- Some PropertyAddress is null
-- Populate Property Address data


-- find the relatoion between the PropertyAddress null and parcelID
Select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by parcelid



Select N1.ParcelID,N1.PropertyAddress, N2.ParcelID,N2.PropertyAddress,N1.[UniqueID ]
from PortfolioProject..NashvilleHousing N1
join PortfolioProject..NashvilleHousing N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] < > N2.[UniqueID ]
where N1.PropertyAddress is null

-- the null will be filled with N2.PropertyAddress

Update N1
SET PropertyAddress  = ISNULL(N1.PropertyAddress,N2.PropertyAddress)
from PortfolioProject..NashvilleHousing N1
join PortfolioProject..NashvilleHousing N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] < > N2.[UniqueID ]
where n1.PropertyAddress is null

-- *Breaking out PropertyAddress into Individual Columns (Address, City, State)
-- Using substring

Select PropertyAddress
from PortfolioProject..NashvilleHousing

-- with this, "," will still be there
Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)) AS addresscomma
from PortfolioProject..NashvilleHousing


-- a way to eliminate ","
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) AS City
from PortfolioProject..NashvilleHousing

-- Update Address into Individual Columns (Address, City, State)

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress) )


-- *Breaking out OwnerAddress into Individual Columns (Address, City, State)
-- Using parsename,which only recognize '.', and the order is backward 

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

-- Update table
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing


-- *Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by(SoldAsVacant)

Select SoldAsVacant
,	Case When SoldAsVacant = 'Y' Then 'Yes'
	     When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

-- Update table


Update NashvilleHousing
SET SoldAsVacant =Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						END
From PortfolioProject.dbo.NashvilleHousing

-- *Remove Duplicates
--  Using CTE

Select *,
ROW_NUMBER() over(
PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--Where row_num > 1

With RowNumCTE AS(
Select *,
ROW_NUMBER() over(
PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--Where row_num > 1
)

-- In total, there are 104 duplicated rows, 

Select row_num , count(row_num)
From RowNumCTE
Where row_num >1
group by row_num

/* usually do not delete data from the table
   DELETE
   FROM RowNumCTE
   Where row_num > 1 */


Select *
From PortfolioProject.dbo.NashvilleHousing



-- *Delete Unused Columns
--  As we have already created OwnerAddress,PropertyAddress,SaleDate new columns, we can delete unused ones

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate