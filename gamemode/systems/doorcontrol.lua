SYS.FullName = "Door Control"
SYS.SGUIName = "doorcontrol"

SYS.Powered = true

if SERVER then
    local OPEN_DISTANCE = 160
    local POWER_PER_DOOR = 0.2

	resource.AddFile("materials/systems/doorcontrol.png")

    SYS._sorted = nil

    function SYS:GetPowerNeeded()
        local needed = 0
        for _, door in pairs(self:GetShip():GetDoors()) do
            if door:IsUnlocked() then
                needed = needed + POWER_PER_DOOR
            end
        end
        return needed
    end

    function SYS:_FindSortedDoorList()
        local doors = {}
        for _, v in pairs(self:GetShip():GetDoors()) do
            table.insert(doors, v)
        end

        local pos = self.Room:GetPos()
        self._sorted = {}

        while table.Count(doors) > 0 do
            local mini = 0
            local minv = 0
            for i, v in pairs(doors) do
                local dist = v:GetPos():Distance(pos)
                if mini == 0 or dist < minv then
                    mini = i
                    minv = dist
                end
            end
            table.insert(self._sorted, doors[mini])
            table.remove(doors, mini)
        end
    end

    function SYS:Think()
        if not self._sorted or table.Count(self._sorted) ~= table.Count(self:GetShip():GetDoors()) then
            self:_FindSortedDoorList()
        end

        local power = self:GetPower()
        for _, door in pairs(self._sorted) do
            if door:IsUnlocked() then
                power = power - POWER_PER_DOOR
                door:SetIsPowered(power >= 0)

                if door:IsPowered() then
                    local pos = door:GetPos()
                    if door:IsOpen() then
                        local shouldClose = true
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(pos) <= OPEN_DISTANCE then
                                shouldClose = false
                                break
                            end
                        end
                        
                        if shouldClose then
                            door:Close()
                        end
                    else
                        local shouldOpen = false
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(pos) <= OPEN_DISTANCE then
                                shouldOpen = true
                                break
                            end
                        end
                        
                        if shouldOpen then
                            door:Open()
                        end
                    end
                end
            end
        end
    end
elseif CLIENT then
	SYS.Icon = Material("systems/doorcontrol.png", "smooth")
end
