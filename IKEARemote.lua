--
-- Creater Varazir ( And big helt from waaren and others on domotiz forum )
-- e-mail: varazir .. gmail.com
-- Version: 1.0
--



groups = {'group1', 'group2', 'group3', 'group4', 'group5', 'group6' }

return  {
    on = {  devices = { 'IKEA Remote*' }},

    logging = { level = domoticz.LOG_DEBUG, 
                marker = "IKEARemote" },

    data = { currentGroup = { initial = 1 }}, 

    execute = function(dz, item)
        
        control = 
        {
            group3 = --Hallway    
            {
                lamp =  { idx = 40, toggle = true, dimmer = true, blink = true }, 
                --spot1 = { idx = 15, toggle = true, dimmer = true},
				--spot2 = { idx = 17, toggle = true, dimmer = true},
				--spot3 = { idx = 19, toggle = true, dimmer = true}
            },
            
            group1 = --Bedroom
            { 
                lamp =  { idx = 13, toggle = true, blink = true, dimmer = true}
            },
            group4 = --Lilvingroom
            { 
                --spot1 = { idx = 21, toggle = true, dimmer = true},
                spot2 = { idx = 36, toggle = true, dimmer = true, blink = true} 
                --spot3 = { idx = 25, toggle = true, dimmer = true}
            },
			group6 = --Computeroom
            { 
                lamp =  { idx = 73, toggle = true, blink = true, dimmer = true}

            },
			group5 = --TvBench  
            { 
                lamp =  { idx = 42, toggle = true, blink = true},
                onkyoHW = { idx = 74, toggle = true},
                tv =    { idx = 45, toggle = true},
				onkyo = { idx = 43, toggle = true}
            },
--			group2 = --BedroomBlilnder
--            { 
--               blinder = { idx = 59, toggle = true, dimmer = true }, 
--
--            },
        }
        local selectedGroupNumber = dz.data.currentGroup
        local maxGroup = #groups
        
        local function doAction(action, direction)
            selectedGroup = groups[selectedGroupNumber]
            dz.log("Current selected group is." .. selectedGroup)
            dz.log("Current acction is........" .. action)
            for device, attributes in pairs(control[selectedGroup]) do
                dz.log("Current typ is............" .. device)
                currentIDx = attributes["idx"]
                currentDevice = dz.devices(currentIDx)
                dz.log("Current device is........." .. currentDevice.name)
                dz.log("Current device IDx is....." .. currentIDx)
                for attribute, value in pairs(attributes) do
                    dz.log("Current attribute is......" .. attribute)
                    if attribute == action then
                        dz.log("Current acction is " .. action)
                        -- Blinking 
                        if action == 'blink' then
							local blinkDevice = dz.devices(currentDevice.name)
							local blinkLevel = currentDevice.level
							dz.log("Device " .. blinkDevice.name .. " will blink")
							if blinkDevice.state == "Off" then 
								blinkDevice.switchOn()
								blinkDevice.switchOff().afterSec(0.5)
							else
								blinkDevice.switchOff()
								blinkDevice.switchOn().afterSec(0.5)
							end
				        elseif action == 'dimmer' then 
							local dimDevice = dz.devices(currentDevice.name)
							local dimLevel = dimDevice.level
							local delay = 0
                            dz.log(dimDevice.name .. " direction is " .. direction)
							if direction == "stop" then 
							    dimDevice.cancelQueuedCommands()
							    dz.log('Stop dimming of ' .. dimDevice.name .. ' at ' .. dimLevel ..'%')
							elseif direction == 'down' then
								repeat
									delay = delay + 0.1
									if direction == "down" then dimLevel = dimLevel - 1	else dimLevel = dimLevel + 1 end
									dz.log('Set ' .. dimDevice.name .. ' to dimLevel '.. dimLevel .. '%, after ' .. delay .. ' seconds', dz.LOG_INFO)
									dimDevice.dimTo(dimLevel).afterSec(delay)
								until dimLevel <= 0
						    elseif direction == 'up' then
                                repeat
                                    delay = delay + 0.1
                                    dimLevel = dimLevel + 1
                                    dz.log('Set ' .. dimDevice.name .. ' to dimLevel '.. dimLevel .. '%, after ' .. delay .. ' seconds', dz.LOG_INFO)
                                    dimDevice.dimTo(dimLevel).afterSec(delay)
                                until dimLevel >= 100
							end
                        elseif action == 'toggle' then
                            local toggleDevice = dz.devices(currentDevice.name)
                            local toggleState = toggleDevice.state
                            if toggleState  == 'On' then toggleDevice.switchOff() else toggleDevice.switchOn() end
                        end
                        
                    end
                end
            end
        end

        local action = 'blink'
        local direction = 'up'
        
        if item.state == 'Click' and item.name == 'IKEA Remote Left' then 
            selectedGroupNumber = selectedGroupNumber - 1 
            if selectedGroupNumber == 0 then selectedGroupNumber = maxGroup end
        elseif item.state == 'Click' and item.name == 'IKEA Remote Right' then 
            selectedGroupNumber = selectedGroupNumber + 1 
            if selectedGroupNumber > maxGroup then selectedGroupNumber = 1 end
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
        else
            dz.log('Unknown action requested; ignored' )
            return
        end
        doAction(action, direction) 
        if item.levelName ==  'Click' then 
            dz.log('Turning off' .. item.name)
            dz.devices(item.name).switchOff().silent()
        end
        dz.data.currentGroup = selectedGroupNumber
        
    end
}
