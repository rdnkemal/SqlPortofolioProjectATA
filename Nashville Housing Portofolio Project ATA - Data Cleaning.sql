/*

Cleaning data in sql

*/

select *
from nashvillehousing

---------------------------------------------------------------------------------------------------------------------------

-- Standardize the format


select saledate, str_to_date(SaleDate,'%d-%b-%y') as SaleDateConverted 
from nashvillehousing 


update nashvillehousing 
set saledate = str_to_date(SaleDate,'%d-%b-%y')


---------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


select *
from nashvillehousing
-- where PropertyAddress = ''
order by ParcelID 


select a. ParcelID , a.PropertyAddress , b.ParcelID, b.PropertyAddress , if(a.PropertyAddress = '', b.PropertyAddress,a.PropertyAddress) 
from nashvillehousing a
join nashvillehousing b
  on a. ParcelID = b.ParcelID 
  and a. UniqueID  <> b.UniqueID 
where a.PropertyAddress = ''


update nashvillehousing a
join nashvillehousing b
  on a. ParcelID = b.ParcelID 
  and a. UniqueID  <> b.UniqueID 
set a.PropertyAddress  = if(a.PropertyAddress = '', b.PropertyAddress,a.PropertyAddress)
where a.PropertyAddress = ''


---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from nashvillehousing
-- where PropertyAddress = ''
-- order by ParcelID 


select 
substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,locate(',',PropertyAddress)+1, length (PropertyAddress)) as Address
from nashvillehousing 


alter table nashvillehousing 
add column PropertySplitAddress nvarchar(255)

update nashvillehousing 
set PropertySplitAddress = substring(PropertyAddress,1,locate(',',PropertyAddress)-1)

alter table nashvillehousing 
add column PropertySplitCity nvarchar(255)

update nashvillehousing 
set PropertySplitCity = substring(PropertyAddress,locate(',',PropertyAddress)+1, length (PropertyAddress))


select *
from nashvillehousing

 -- note : instr(PropertyAddress,',') atau locate(',',PropertyAddress) = CHARINDEX

select OwnerAddress 
from nashvillehousing

select OwnerAddress,
substring_index(OwnerAddress,',', 1),
substring_index(substring_index(OwnerAddress,',', -2),',', 1),
substring_index(OwnerAddress,',', -1)
from nashvillehousing n 


alter table nashvillehousing 
add column OwnerSplitAddress nvarchar(255)

update nashvillehousing 
set OwnerSplitAddress = substring_index(OwnerAddress,',', 1)


alter table nashvillehousing 
add column OwnerSplitCity nvarchar(255)

update nashvillehousing 
set OwnerSplitCity = substring_index(substring_index(OwnerAddress,',', -2),',', 1)


alter table nashvillehousing 
add column OwnerSplitState nvarchar(255)

update nashvillehousing 
set OwnerSplitState = substring_index(OwnerAddress,',', -1)


---------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant"


select distinct SoldAsVacant, count(SoldAsVacant) 
from nashvillehousing 
group by SoldAsVacant 
order by 2


select SoldAsVacant ,
 case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
 end
from nashvillehousing 
group by SoldAsVacant 


update nashvillehousing 
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant 
end

 
---------------------------------------------------------------------------------------------------------------------------
 
-- Remove Duplicates 
 
with rownumCTE as( 
select *,
 row_number () over (
 partition by ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 order by UniqueID 
			 ) as row_num
from nashvillehousing 
 -- order by ParcelID 
)
select *
from rownumCTE
where row_num > 1

-- deleting
delete from  nashvillehousing
where  (ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, UniqueID) 
  in (
    select  ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, UniqueID
    from (
        select *,
               row_number () over (
                   partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
                   order by  UniqueID
               ) as row_num
        from nashvillehousing
    ) as subquery
    where row_num > 1
)



---------------------------------------------------------------------------------------------------------------------------

-- Delete unsude columns

select *
from nashvillehousing


alter table nashvillehousing 
drop column PropertyAddress, 
drop column TaxDistrict,
drop column OwnerAddress
drop column SaleDate
 
 