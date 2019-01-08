-- Riverlands Trait
-- Author: Furion
-- DateCreated: 4/16/2018 2:44:22 PM
--------------------------------------------------------------
print("Loaded")
--------------------------------------------------------------
-- UTILITY FUNCTIONS
--CivilizationHasTrait
function CivilizationHasTrait(sCiv, sTrait)
	for tRow in GameInfo.CivilizationTraits() do
		if (tRow.CivilizationType == sCiv and tRow.TraitType == sTrait) then
			return true;
		end
	end
	return false;
end

function LeaderHasTrait(sLeader, sTrait)
	for tRow in GameInfo.LeaderTraits() do
		if (tRow.LeaderType == sLeader and tRow.TraitType == sTrait) then return true end
	end
	return false;
end
----------Set Civilization Trait to The Riverlands----------
local sFamilyDutyHonor = "TRAIT_CIVILIZATION_FAMILY_DUTY_HONOR";
local sAdvantageousBetrothal = "TRAIT_ADVANTAGEOUS_BETROTHAL";

----------Random Brotherhood Types----------
function OnBrotherhoodStartRandomTypes(playerID,unitID)
	local pPlayer = Players[playerID];
	local unit = UnitManager.GetUnit(playerID, unitID);
	if (pPlayer~=nil) then
		--print("Player is valid...");
		if (unit~=nil) then
			--print("Unit is valid...");
			local unitType = GameInfo.Units[unit:GetType()];
			if unitType.UnitType == "UNIT_BROTHERHOOD_WITHOUT_BANNERS" then
				local unitMovesRemaining = unit:GetMovesRemaining();
				print("InGame Move Remaining: "..unitMovesRemaining);
				local unitX = unit:GetX();
				local unitY = unit:GetY();
				UnitManager.Kill(unit, false);
				local UnitNID = math.random(1,3);
				--print(UnitNID);
				if (UnitNID == 1) then
					local cUnit = pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BROTHERHOOD_WITHOUT_BANNERS_EXILE_KNIGHT"].Index, unitX, unitY);
					if (unitMovesRemaining == 0) then
						UnitManager.ChangeMovesRemaining(cUnit,-4);
					end
				elseif (UnitNID == 2) then
					local cUnit = pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BROTHERHOOD_WITHOUT_BANNERS_LONGBOW"].Index, unitX, unitY);
					if (unitMovesRemaining == 0) then
						UnitManager.ChangeMovesRemaining(cUnit,-2);
					end
				else
					local cUnit = pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BROTHERHOOD_WITHOUT_BANNERS_WARRIOR_MONK_OF_MYR"].Index, unitX, unitY);
					if (unitMovesRemaining == 0) then
						UnitManager.ChangeMovesRemaining(cUnit,-2);
					end
				end
			end
		end
	end
end

----------Twin Tower Pillage Loose 100 Loyalty----------
function RVLOnDistrictPillaged(ownerPlayerID, districtID, cityID, x, y, districtType, percentComplete, isPillaged)
	--print("District Pillaged: "..tostring(districtType));
	local twinTower = GameInfo.Districts["DISTRICT_THE_TWIN_TOWERS"];
	if (twinTower) then
		local isEnemyInPlot = false;
		local eTwinTower = twinTower.Index;
		local ePlot = Map.GetPlot(x, y);
		if ePlot:GetUnitCount() >= 1 then
			local eUnits = Units.GetUnitsInPlot(ePlot);
			for i, eUnit in ipairs(eUnits) do
				local unitOwner = eUnit:GetOwner();
				if unitOwner:GetDiplomacy():IsAtWarWith(Players[ownerPlayerID]) then
					isEnemyInPlot = true;
				end
			end
		end
		--print("DISTRICT_THE_TWIN_TOWERS id is: "..eTwinTower);
		if (districtType == eTwinTower and isEneyInPlot == true) then
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
----------Hoster Tully Annex City State----------
function OnLocalPlayerAnnexCityState(localPlayerID,citStateID, builtUnits:table, iCities:table, envoyTokens,iAnnexCost)
	print("Annex Called Here...! Local Player ID is: "..tostring(localPlayerID).." ;City State ID is: "..tostring(citStateID));
	local pPlayer = Players[localPlayerID];
	local iPlayer = Players[citStateID];
	local iLeader	:string = PlayerConfigurations[citStateID]:GetLeaderTypeName();
	local iLeaderInfo:table	= GameInfo.Leaders[iLeader];
	--Destroy all city state units
	local iPlayerUnits:table = iPlayer:GetUnits();
	for i, iUnit in iPlayerUnits:Members() do
		UnitManager.Kill(iUnit, false);
	end
	--Destroy city state
	local iPlayerCities:table = iPlayer:GetCities();
	for _, iCity in iPlayerCities:Members() do
		CityManager.DestroyCity(iCity);
	end
	--Create Cities for Player	
	for i, iCity in ipairs(iCities) do
		local iCityX = iCity.CityX;
		local iCityY = iCity.CityY;
		local city = pPlayer:GetCities():Create(iCityX, iCityY)
		--Get City Plots Back
		local iCityPlots:table = iCity.CityPlots;
		if (iCityPlots ~= nil) then
			for _,iPlotImprovement in ipairs(iCityPlots) do
				local iPlot:table =  iPlotImprovement.cityPlot;
				if (iPlot:IsCity() == false) then
					iPlot:SetOwner(-1);
					WorldBuilder.CityManager():SetPlotOwner(iPlot, city);
				end
				--Add Improvements
				local iImprovement:number = iPlotImprovement.plotImprovement;
				if iImprovement then
					WorldBuilder.MapManager():SetImprovementType(iPlot, iImprovement,localPlayerID);
				end
			end
		end
		--Set City Population
		local iCityPop = iCity.CityPopulation;
		local iPopulation :number= city:GetPopulation();
		city:ChangePopulation(iCityPop-iPopulation);
		--Set City Name
		local iCityName = iCity.CityName;
		city:SetName(iCityName);
		--Place Districts
		local iCityDistricts = iCity.CityDistricts;
		if (iCityDistricts ~= nil) then
			for i, iCityDistrict in ipairs(iCityDistricts) do
				local districtType = iCityDistrict.DType;
				local districtX = iCityDistrict.DX;
				local districtY = iCityDistrict.DY;
				local plot = Map.GetPlot(districtX, districtY)
				WorldBuilder.CityManager():CreateDistrict(city, districtType, 100, plot);
			end
		end
		--Place Buildings
		local iCityBuildings:table = iCity.CityBuildings;
		if (iCityBuildings ~= nil) then
			for i, iCityBuilding in ipairs(iCityBuildings) do
				local buildingType = iCityBuilding.BType;
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings[buildingType].Index, 100);
			end
		end
		if (iLeader == "LEADER_MINOR_CIV_SCIENTIFIC" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_SCIENTIFIC") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_SCIENCE_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_SCIENCE_T2"].Index, 100);
			end
		elseif (iLeader == "LEADER_MINOR_CIV_RELIGIOUS" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_RELIGIOUS") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_RELIGIOUS_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_RELIGIOUS_T2"].Index, 100);
			end
		elseif (iLeader == "LEADER_MINOR_CIV_TRADE" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_TRADE") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_TRADE_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_TRADE_T2"].Index, 100);
			end
		elseif (iLeader == "LEADER_MINOR_CIV_CULTURAL" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_CULTURAL") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_CULTURAL_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_CULTURAL_T2"].Index, 100);
			end	
		elseif (iLeader == "LEADER_MINOR_CIV_MILITARISTIC" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_MILITARISTIC") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_MILITARISTIC_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_MILITARISTIC_T2"].Index, 100);
			end	
		elseif (iLeader == "LEADER_MINOR_CIV_INDUSTRIAL" or iLeaderInfo.InheritFrom == "LEADER_MINOR_CIV_INDUSTRIAL") then
			if (envoyTokens >= 6) then
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_INDUSTRIAL_T3"].Index, 100);
			else
				local pCityBuildQueue = city:GetBuildQueue();
				pCityBuildQueue:CreateIncompleteBuilding(GameInfo.Buildings["BUILDING_SOLAR_OF_TULLYS_DAUGHTER_INDUSTRIAL_T2"].Index, 100);
			end		
		end
	end
	--Add Units
	if (builtUnits ~= nil) then
		for i, iUnit in ipairs(builtUnits) do
			local iUnitType = iUnit.UType;
			local iUnitX = iUnit.UX;
			local iUnitY = iUnit.UY;
			pPlayer:GetUnits():Create(GameInfo.Units[iUnitType.UnitType].Index, iUnitX, iUnitY);
		end
	end
	--Calc Gold Balance
	pPlayer:GetTreasury():ChangeGoldBalance(-iAnnexCost);
end
LuaEvents.LocalPlayerAnnexCityState.Add(OnLocalPlayerAnnexCityState);

----------In Game Events----------
function RVLOnLoadScreenClose()
	Events.DistrictPillaged.Add(RVLOnDistrictPillaged);
	Events.UnitAddedToMap.Add(OnBrotherhoodStartRandomTypes);
end
----------Events----------
Events.LoadScreenClose.Add(RVLOnLoadScreenClose);