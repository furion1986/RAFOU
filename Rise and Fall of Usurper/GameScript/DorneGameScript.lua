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
local sUnbowedUnbentUnbroken = "TRAIT_CIVILIZATION_UNBOWED_UNBENT_UNBROKEN";
local sABigGameOfCyvasse = "TRAIT_A_BIG_GAME_OF_CYVASSE";

----------Random Sand Snake Promotion Types----------
function OnSandSnakeRandomPromotion(playerID,unitID)
	local pPlayer = Players[playerID];
	local unit = UnitManager.GetUnit(playerID, unitID);
	if (pPlayer~=nil) then
		--print("Player is valid...");
		if (unit~=nil) then
			--print("Unit is valid...");
			local unitType = GameInfo.Units[unit:GetType()];
			if unitType.UnitType == "UNIT_SAND_SNAKE" then
				local UnitNID = math.random(1,5);
				--print(UnitNID);
				if (UnitNID == 1) then
					local pPromotion = GameInfo.UnitPromotions["PROMOTION_WALK_IN_SHADOW"].Index;
					unit:GetExperience():SetPromotion(pPromotion);
				elseif (UnitNID == 2) then
					local pPromotion = GameInfo.UnitPromotions["PROMOTION_BORN_LEADER"].Index;
					unit:GetExperience():SetPromotion(pPromotion);
				elseif (UnitNID == 3) then
					local pPromotion = GameInfo.UnitPromotions["PROMOTION_ASSASSIN"].Index;
					unit:GetExperience():SetPromotion(pPromotion);
				elseif (UnitNID == 4) then
					local pPromotion = GameInfo.UnitPromotions["PROMOTION_SCHOLAR"].Index;
					unit:GetExperience():SetPromotion(pPromotion);
				else
					local pPromotion = GameInfo.UnitPromotions["PROMOTION_SEDUCTION"].Index;
					unit:GetExperience():SetPromotion(pPromotion);					
				end
			end
		end
	end
end

----------Dynamic Desert Yields----------
function DORNEOnPlayerTurnActivated(ePlayer:number, bFirstTimeThisTurn:boolean)
	local pPlayer = Players[ePlayer];
	local pPlayerConfig = PlayerConfigurations[ePlayer];
	local sCiv = pPlayerConfig:GetCivilizationTypeName();
	if (not CivilizationHasTrait(sCiv,sUnbowedUnbentUnbroken)) then return; end
	----------Loop Through Cities----------
	local pPlayerCities	:table = pPlayer:GetCities();
	for _, pCity in pPlayerCities:Members() do
		local pCityHappiness:number = pCity:GetGrowth():GetHappiness();
		print(tostring(pCityHappiness));
		local iBuilding = GameInfo.Buildings["BUILDING_DORNISH_CANAL"].Index;
		local jBuilding = GameInfo.Buildings["BUILDING_DORNISH_SPIDER_CANAL"].Index;
		----------If Happy----------
		if (pCityHappiness == 5) then
			----------Check if City has Canal----------
			if not pCity:GetBuildings():HasBuilding(iBuilding) then
				pCity:GetBuildQueue():CreateIncompleteBuilding(iBuilding, 100);
			end
			if pCity:GetBuildings():HasBuilding(jBuilding) then
				pCity:GetBuildings():RemoveBuilding(jBuilding);
			end
			if pCity:GetBuildings():IsPillaged(iBuilding) then
				pCity:GetBuildings():SetPillaged(iBuilding, false);
			end
		----------If Ecstatic----------
		elseif (pCityHappiness == 6) then
			----------Check if City has Canal----------
			if not pCity:GetBuildings():HasBuilding(jBuilding) then
				pCity:GetBuildQueue():CreateIncompleteBuilding(jBuilding, 100);
			end
			if pCity:GetBuildings():HasBuilding(iBuilding) then
				pCity:GetBuildings():RemoveBuilding(iBuilding);
			end
			if pCity:GetBuildings():IsPillaged(jBuilding) then
				pCity:GetBuildings():SetPillaged(jBuilding, false);
			end
		----------If not Happy----------
		else
			----------Check if City has Canal----------
			if pCity:GetBuildings():HasBuilding(iBuilding) then
				pCity:GetBuildings():RemoveBuilding(iBuilding);
			end
			if pCity:GetBuildings():HasBuilding(jBuilding) then
				pCity:GetBuildings():RemoveBuilding(jBuilding);
			end			
		end
	end
end

----------In Game Events----------
function RVLOnLoadScreenClose()
	Events.UnitAddedToMap.Add(OnSandSnakeRandomPromotion);
	Events.PlayerTurnActivated.Add(DORNEOnPlayerTurnActivated);
end
----------Events----------
Events.LoadScreenClose.Add(RVLOnLoadScreenClose);