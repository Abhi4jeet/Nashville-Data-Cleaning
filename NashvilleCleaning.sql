SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio].[dbo].[Nashville];

  -- Standardize Date Format

  UPDATE Nashville
  SET SaleDate = CONVERT(Date,SaleDate);

  -- Populate Property Address

  Select *
From dbo.Nashville
Where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Nashville AS  a
JOIN dbo.Nashville AS  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Nashville AS a
JOIN dbo.Nashville AS  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Address Into Individual Columns

Select PropertyAddress
From dbo.Nashville
-- Where PropertyAddress is null
-- order by ParcelID;

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

Select OwnerAddress
From dbo.Nashville;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.Nashville;

ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- Change Y and N to Yes and No im "Sold As vacant" column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.Nashville
Group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
     WHEN SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM dbo.Nashville;

UPDATE Nashville
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
     WHEN SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END;

-- remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.Nashville
)
Delete
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress;


-- delete unused columns


ALTER TABLE dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

select * from dbo.Nashville
order by UniqueID ASC


