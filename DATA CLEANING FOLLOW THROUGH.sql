select * from NashvilleDC

--CONVERT DATE FORMAT

ALTER table nashvilledc
add converteddate date;

update nashvilledc
set converteddate = convert(date,saledate)

--REPLACE PROPERTY ADDRESSES THAT ARE NULL

SELECT PropertyAddress
from NashvilleDC

UPDATE pa
SET PropertyAddress = ISNULL(pa.propertyaddress, ra.propertyaddress)
FROM NashvilleDC pa
JOIN NashvilleDC ra
	ON pa.ParcelID = ra.ParcelID
	AND pa.uniqueID <> ra.uniqueid
WHERE pa.propertyaddress is null

--SEPARATING THE PROPERTY ADDRESS COLUMN
SELECT 
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress) -1) AS Adress,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress)) AS [Address City]
FROM NashvilleDC

ALTER TABLE nashvilledc
ADD Address NVARCHAR(255)

UPDATE  Nashvilledc
SET Address = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress) -1)

ALTER TABLE nashvilledc
ADD [Address City] NVARCHAR(255)

UPDATE  Nashvilledc
SET [Address City] = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress))

--SEPARATING THE OWNER ADDRESS COLUMN
SELECT owneraddress
FROM NashvilleDC

SELECT
PARSENAME(REPLACE(Owneraddress,',','.'), 3),
PARSENAME(REPLACE(Owneraddress,',','.'), 2),
PARSENAME(REPLACE(Owneraddress,',','.'), 1)
FROM NashvilleDC

ALTER TABLE nashvilledc
ADD [Owner Address] NVARCHAR(255)

UPDATE  Nashvilledc
SET [Owner Address] = PARSENAME(REPLACE(Owneraddress,',','.'), 3)

ALTER TABLE nashvilledc
ADD [Owner Address City] NVARCHAR(255)

UPDATE  Nashvilledc
SET [Owner Address City] = PARSENAME(REPLACE(Owneraddress,',','.'), 2)

ALTER TABLE nashvilledc
ADD [Owner Address State] NVARCHAR(255)

UPDATE  Nashvilledc
SET [Owner Address State] = PARSENAME(REPLACE(Owneraddress,',','.'), 1)

--CHANGE Y TO YES AND N TO NO

SELECT Soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE soldasvacant
	END

FROM NashvilleDC

UPDATE NashvilleDC
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE soldasvacant
		 END

--REMOVE DUPLICATE DATA
WITH RowNumCTE AS (
SELECT *, 
		ROW_NUMBER() OVER( PARTITION BY parcelid,
								   propertyaddress,
								   saledate,
								   saleprice,
								   legalreference
								   ORDER BY uniqueid) Rownum
FROM NashvilleDC)


DELETE
from RowNumCTE
WHERE Rownum > 1

--DELETE UNWANTED/UNUSED COLUMNS
ALTER TABLE Nashvilledc
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate

SELECT *
FROM NashvilleDC