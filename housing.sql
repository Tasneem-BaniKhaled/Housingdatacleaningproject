select *
from housing

--standarize date format
select saledate, convert(date,saledate)
from housing

alter table housing 
add saledateconverted date;

update housing
 set saledateconverted = convert(date, saledate)
 
select saledateconverted
from housing

-- populate property address data
select *
from housing
where propertyaddress is null


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM housing a
JOIN housing b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
where a.propertyaddress is null

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
FROM housing a
JOIN housing b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
where a.propertyaddress is null


update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
FROM housing a
JOIN housing b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
where a.propertyaddress is null


-- breaking out address into individual columns (address, city, state)
select propertyaddress
from housing

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as address
, SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress) +1, len (propertyaddress)) as ad
from housing

alter table housing 
add propertysplitaddress nvarchar(255);
update housing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) 


alter table housing 
add propertysplitcity nvarchar(225);
update housing
set propertysplitcity = SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress) +1, len (propertyaddress))


select *
from housing

select
parsename(replace(owneraddress, ',', '.'), 3)
, parsename(replace(owneraddress, ',', '.'), 2)
, parsename(replace(owneraddress, ',', '.'), 1)
from housing


alter table housing 
add ownersplitaddress nvarchar(225);
update housing
set ownersplitaddress = parsename(replace(owneraddress, ',', '.'), 3)

alter table housing 
add ownersplitcity nvarchar(225);
update housing
set ownersplitcity = parsename(replace(owneraddress, ',', '.'), 2)

alter table housing 
add ownersplitstate nvarchar(225);
update housing
set ownersplitstate = parsename(replace(owneraddress, ',', '.'), 1)

--Change Y and N into Yes and No

select distinct (soldasvacant), count(soldasvacant)
from housing
group by soldasvacant
order by 2

select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
else soldasvacant
end
from housing

update housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
else soldasvacant
end


-- remove duplicates

WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM housingproject..housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;


-- Delete unused columns
Alter table housingproject..housing
drop column owneraddress, taxdistrict, propertyaddress

select * 
from housingproject..housing

Alter table housingproject..housing
drop column saledate