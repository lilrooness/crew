return {
    door = {
        calm_door_open = function(door_number)
            return "opening door " .. door_number
        end,
        calm_door_close = function(door_number)
            return "closing door " .. door_number
        end,
        calm_door_closed = function(door_number)
            return "door " .. door_number .. " is closed"
        end,
        calm_door_opened = function(door_number)
            return "door " .. door_number .. " is open"
        end,
        stressed_door_open = function(door_number)
            return "[heavey breathing 3s] opening door " .. door_number
        end,
        stressed_door_close = function(door_number)
            return "[heavey breathing 2s] closing door [inaud]" .. door_number
        end,
        stressed_door_closed = function(door_number)
            return "[wimper/inaud 0.5s] door " .. door_number .. " is closed"
        end,
        stressed_door_opened = function(door_number)
            return "[inaud 1.5s] door " .. door_number .. " is open"
        end,
        demand_door_open = function(door_number)
            return "[raised_voice]: OPEN DOOR " .. door_number .. " NOW"
        end,
        demand_door_close = function(door_number)
            return "[breathing/shaking]: we need to close door " .. door_number
        end
    },
    chatter = {
        calm_status_check = function(to_name)
            return "how's it going " .. to_name
        end,
        calm_status_response_good = function(to_name)
            return "all good " .. to_name
        end,
        calm_status_response_bad = function(to_name)
            return "[vocal inflection 1s] not so good " .. to_name
        end,
        calm_help_request = function(to_name)
            return "go[-]nna need some help over here"
        end,
        stressed_help_request = function(to_name)
            return "[loud]: " .. to_name .. " [pause 0.2s] help"
        end,
        maic_help_request = function(to_name)
            return "[loud_max]: help [inaud]" .. to_name
        end
    }
}
