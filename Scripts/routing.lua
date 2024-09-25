function OnStoredInstance(instanceId, tags, metadata)
    local query = {}
    query["Resources"] = {instanceId}
    query["Transcode"] = "1.2.840.10008.1.2.4.70"
    local response = RestApiPost('/peers/U4RAD/store', DumpJson(query))
end

