-- Riverlands Trait
-- Author: Furion
-- DateCreated: 4/16/2018 2:44:22 PM
--------------------------------------------------------------
print("Loaded")
--------------------------------------------------------------

----------Twin Tower Pillage Loose 100 Loyalty----------
function RVLOnDistrictPillaged(ownerPlayerID, districtID, cityID, x, y, districtType, percentComplete, isPillaged)
	--print("District Pillaged: "..tostring(districtType));
	local twinTower = GameInfo.Districts["DISTRICT_THE_TWIN_TOWERS"];
	if (twinTower) then
		local eTwinTower = twinTower.Index;
		--print("DISTRICT_THE_TWIN_TOWERS id is: "..eTwinTower);
		if (districtType == eTwinTower) then
			local pPlayer = Players[ownerPlayerID];
			local pCity = CityManager.GetCity(ownerPlayerID, cityID);
			--print(pCity:GetName());
			if (pCity ~= nil and pCity.ChangeLoyalty ~= nil) then
				--print("Going the reduce Loyalty by 100");
				pCity:ChangeLoyalty(-100);
			end
		else
			return;
		end
	end
end
----------In Game Events----------
function RVLOnLoadScreenClose()
	Events.DistrictPillaged.Add(RVLOnDistrictPillaged);
end
----------Events----------
Events.LoadScreenClose.Add(RVLOnLoadScreenClose);