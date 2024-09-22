local serializer = {}

serializer.block_codes = {
    water = 1,
    sand = 2,
    grass = 3,
    podzole = 4,
    gravel = 5,
    granite = 6,
    mountain = 7,
}

serializer.object_codes = {
    none = 0,
    tree = 1,
    grass = 2,
    rock = 3,
    wall = 4,
}

-- Assuming we can create a new Data instance
function serializer.serialize(data)
    -- Create a new Data object
    local binary_data = Data()
    for _, row in ipairs(data) do
        for _, cell in ipairs(row) do
            local block_code = serializer.block_codes[cell.block] or 0
            local object_code = serializer.object_codes[cell.object] or 0
            binary_data:WriteUInt8(block_code)
            binary_data:WriteUInt8(object_code)
        end
    end
    binary_data:WriteUInt8(0)
    return binary_data
end

function serializer.deserialize(binary_data, width, height)
    local data = {}
    binary_data.Cursor = 1 -- Reset cursor to the beginning
    for i = 1, height do
        local row = {}
        for j = 1, width do
            local object_code = binary_data:ReadUInt8()
            local block_code = binary_data:ReadUInt8()
            local block = "unknown"
            for name, code in pairs(serializer.block_codes) do
                if code == block_code then
                    block = name
                    break
                end
            end
            local object = "unknown"
            for name, code in pairs(serializer.object_codes) do
                if code == object_code then
                    object = name
                    break
                end
            end
            table.insert(row, {block = block, object = object})
        end
        table.insert(data, row)
    end
    return data
end

return serializer