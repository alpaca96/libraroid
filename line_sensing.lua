function sysCall_init()
end

function sysCall_vision(inData)
    -- callback function automatically added for backward compatibility
    -- (vision sensor have no filters anymore, but rather a callback function where image processing can be performed)
    set_color=0
    set_tol=0.1
    frame=sim.getObjectHandle('frame')
    position=sim.getUserParameter(frame,'poos')
    if (position==0 ) then
        set_color=0.1
        set_tol=0.05
    elseif (position==-1) then
        set_color=0.25
        set_tol=0.2
    elseif (position==-2) then
        set_color=0.25
        set_tol=0.1
    elseif (position==1) then
        set_color=0.25
        set_tol=0.1    
    else
        set_color=0.2
        set_tol=0.1
    end
    local retVal={}
    retVal.trigger=false
    retVal.packedPackets={}
    simVision.sensorImgToWorkImg(inData.handle)
    simVision.selectiveColorOnWorkImg(inData.handle,{1.000000,1.0000,set_color},{0.1,0.1,set_tol},true,true,false)
    simVision.workImgToSensorImg(inData.handle,false)
    local trig,packedPacket=simVision.blobDetectionOnWorkImg(inData.handle,0.500000,0.000000,true) if trig then retVal.trigger=true end if packedPacket then retVal.packedPackets[#retVal.packedPackets+1]=packedPacket end
    return retVal
end
