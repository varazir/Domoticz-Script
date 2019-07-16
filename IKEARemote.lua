--
-- Creater Varazir ( And big help from waaren and others on domotiz forum )
-- e-mail: varazir .. gmail.com
-- Version: 1.2
--
groups = {'group1', 'group2', 'group3', 'group4', 'group5', 'group6', 'group7' }
return  {
    on =        {
                    devices         = { 'IKEA Remote*' }},

    logging =   { 
                    level           = domoticz.LOG_DEBUG, 
                    marker          = "IKEARemote" 
                },

    data =      { 
                    currentGroup    = { initial = 1 }
                }, 

    execute = function(dz, item)
        
        control = 
        {
            group1 =
            { 
                name            = 'Taklampa Sovrum',
                IKEAlamp        = { idx = 13, toggle = true, blink = true, dimmer = true}
            },

			group2 =
            { 
                name            = 'Rullgardin Sovrum',
                Blinder         = { idx = 59, toggle = true, blinder = true }, 
            
            group3 =  
            {
                name            = 'Taklampa Hall',
                IKEAlamp        = { idx = 40, blink = true }, 
                IKEAlampGroup   = { idx = 65, toggle = true, dimmer = true},
			},
        
			group4 =
            { 
                name            = 'Taklampa Datorrum',
                IKEAlamp        =  { idx = 73, toggle = true, blink = true, dimmer = true}
            },
        
            group5 =
            { 
                name            = 'Taklampa Vardagsrum',
                IKEAlampGroup   = { idx = 36, toggle = true, dimmer = true, blink = true} 
            },

			group6 = 
            { 
                name            = 'Tv Bänk',
                Lamp            = { idx = 42, toggle = true, blink = true},
                TvGroup         = { idx = 2,  toggle = true, group = true}
            },
        
            },			
			group7 =
            { 
                name            = 'Rullgardin Vardagsrum',
                Blinder         = { idx = 83, toggle = true, blinder = true }, 

            },
        }

        local function logWrite(str,level)
            dz.log(tostring(str),level or dz.LOG_DEBUG)
        end
        
        local selectedGroupNumber = dz.data.currentGroup
        logWrite("Current Group " .. selectedGroupNumber)
        local maxGroup = #groups
        local dummyDimmer = dz.devices(82)

        local function doAction(action, direction)
            logWrite("Current group number......" .. selectedGroupNumber)
            selectedGroup = 'group' .. selectedGroupNumber
            logWrite("Current selected group is." .. selectedGroup)
            logWrite("Current acction is........" .. action)
            logWrite(control[selectedGroup])
            for device, attributes in pairs(control[selectedGroup]) do
                logWrite("Current device is........." .. device)
                if device == "name" then
                    logWrite('Name:.....................'  .. attributes)
                    selectedGroupName = attributes
                    dz.devices('IKEA Remote Groups').switchSelector(attributes).silent()
                    -- dz.notify("Aktuell grupp",attributes,dz.PRIORITY_NORMAL,dz.NSS_HTTP)
                else
                    currentIDx = selectedGroup["idx"]
                    logWrite("Current device IDx is....." .. currentIDx)
                    if attributes["group"] then currentDevice = dz.groups(currentIDx) else  currentDevice = dz.devices(currentIDx) end
                    logWrite("Current device name is........." .. currentDevice.name)
                    for attribute, value in pairs(attributes) do
                        logWrite("Current attribute is......" .. attribute)
                        if attribute == action then
                            logWrite("Current acction is " .. action)
                            -- Blinking 
                            if action == 'blink' then
    							local blinkDevice = dz.devices(currentDevice.name)
    							local blinkLevel = currentDevice.level
    							logWrite("Device " .. blinkDevice.name .. " will blink")
    							--if blinkDevice.state == "Off" then 
    							--	blinkDevice.switchOn()
    							--	blinkDevice.switchOff().afterSec(0.5)
    							--else
    							--	blinkDevice.switchOff()
    							--	blinkDevice.switchOn().afterSec(0.5)
    							--end
    							
    				        elseif action == 'dimmer' then 
    							local dimDevice = dz.devices(currentDevice.name)
    							local dimLevel = dimDevice.level
    							local delay = 0
                                logWrite(dimDevice.name .. " direction is " .. direction)
    							if direction == "stop" then 
    							    dimDevice.cancelQueuedCommands()
    							    logWrite('Stop dimming of ' .. dimDevice.name .. ' at ' .. dimLevel ..'%')
    							elseif direction == 'down' then
    								repeat
    									delay = delay + 0.1
    									if direction == "down" then dimLevel = dimLevel - 1	else dimLevel = dimLevel + 1 end
    									logWrite('Set ' .. dimDevice.name .. ' to dimLevel '.. dimLevel .. '%, after ' .. delay .. ' seconds')
    									dimDevice.dimTo(dimLevel).afterSec(delay)
    								until dimLevel <= 0
    						    elseif direction == 'up' then
                                    repeat
                                        delay = delay + 0.1
                                        dimLevel = dimLevel + 1
                                        logWrite('Set ' .. dimDevice.name .. ' to dimLevel '.. dimLevel .. '%, after ' .. delay .. ' seconds')
                                        dimDevice.dimTo(dimLevel).afterSec(delay)
                                    until dimLevel >= 100
    							end
                            elseif action == 'toggle' then
                                local toggleDevice = currentDevice
                                if attributes["group"] then
                                    toggleDevice.toggleGroup()
                                else 
                                    toggleDevice.toggleSwitch()
                                end
                            end
                        end
                    end
                end
            end
        end
        
        
        local function findGroup(groupname)
            local GroupNumber = 0
            repeat 
                GroupNumber = GroupNumber + 1
                local Group = control[GroupNumber]
                for device, attributes in pairs(control[Group]) do
                    if device == "name" then
                        if attributes == groupname then
                            selectedGroupNumber = GroupNumber
                            return
                        end
                    end
                end
            until GroupNumber == maxGroup
        end
        
        local action = 'blink'
        local direction = 'up'
        
        if item.state == 'Click' and item.name == 'IKEA Remote Left' then 
            selectedGroupNumber = selectedGroupNumber - 1 
            if selectedGroupNumber == 0 then selectedGroupNumber = maxGroup end
            -- dz.notify("Aktuell grupp",control[selectedGroupNumber],dz.PRIORITY_NORMAL,dz.NSS_HTTP)
        elseif item.state == 'Click' and item.name == 'IKEA Remote Right' then 
            selectedGroupNumber = selectedGroupNumber + 1 
            if selectedGroupNumber > maxGroup then selectedGroupNumber = 1 end
            -- dz.notify("Aktuell grupp",control[selectedGroupNumber],dz.PRIORITY_NORMAL,dz.NSS_HTTP)
        elseif item.name == 'IKEA Remote' then
            action = 'toggle'
        elseif item.state == 'Hold' and item.name == "IKEA Remote Up"  then
            action = 'dimmer'
        elseif item.state == 'Hold' and item.name == 'IKEA Remote Down' then
            action = 'dimmer' 
            direction = 'down'
        elseif item.state == 'Release' and item.name == 'IKEA Remote Down' or item.name == 'IKEA Remote Up' then
            action = 'dimmer'
            direction = 'stop'
        elseif item.name == 'IKEA Remote Groups' then 
            findGroup(item.levelName)
        else
            logWrite('Unknown action requested; ignored', dz.LOG_INFO )
            return
        end
        
        if item.state ==  'Click' then 
            logWrite('Turning off ' .. item.name)
            dz.devices(item.name).switchOff().silent()
        end
        
        dz.data.currentGroup = selectedGroupNumber
        logWrite("Next Group " .. dz.data.currentGroup)
        doAction(action, direction) 
        
        
    end
}
