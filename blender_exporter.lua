-- This object starts recording the pose of all visible objects when the simulation starts. 
-- When the simulation stops it exports all meshes and movements. 
-- The script is composed of calls to functions that manage all this. These functions can easily be used in other projects.
-- forked from https://github.com/BorisBogaerts/CoppeliaSim-Blender-Tools
function sysCall_init()
    exportFolder = "C:\\Program Files\\V-REP3\\V-REP_PRO_EDU\\cadFiles\\"
    
    -- First get the handles of all visible meshes
    visibleHandles = getVisibleHandles()

    -- Create pose matrix
    pose = {}
    for i = 1, #visibleHandles, 1 do
        pose[i] = {}
    end
end

function sysCall_actuation()
    -- Do with this what you want
    recordPose()
end



function sysCall_cleanup()
    -- This can be called whenever you want
    exportContent()

    -- During getVisibleHandles, merged objects are split, here they are remerged
    if (toRestore==nil)==false then
		for i = 1, #toRestore, 1 do
			sim.groupShapes(toRestore[i]) -- vrep does not seem to do this correctly 
		end
	end
end

getVisibleHandles = function()
	handles = sim.getObjectsInTree(sim.handle_scene, sim.object_shape_type, 0)
	local visibleHandles = {}
	if (toRestore==nil) then
		toRestore = {}
	end
	for i = 1, #handles, 1 do
		property=sim.getObjectSpecialProperty(handles[i])
        val = sim.boolAnd32(property, sim.objectspecialproperty_renderable)
		if val>0 then
			simpleShapeHandles=sim.ungroupShape(handles[i])
			--simpleShapeHandles = {handles[i]}
			if #simpleShapeHandles>1 then
				toRestore[#toRestore + 1] = simpleShapeHandles
			end
			for ii = 1, #simpleShapeHandles, 1 do
				visibleHandles[#visibleHandles+1] = simpleShapeHandles[ii]
			end
		end
	end
    handles = sim.getObjectsInTree(sim.handle_scene, sim.object_shape_type, 0)
	numberOfObjects = #handles
	return visibleHandles
end

function recordPose()
    -- adapt this as you want, exportContent expects pairs of 8 numbers (t,x,y,z,rx,ry,rz,rw) per keyframe
    for i = 1, #visibleHandles, 1 do
        t = sim.getObjectPosition(visibleHandles[i], -1)
        o =  sim.getObjectQuaternion(visibleHandles[i], -1)
        pose[i][#pose[i]+1]=sim.getSimulationTime()
        pose[i][#pose[i]+1] = t[1]
        pose[i][#pose[i]+1] = t[2]
        pose[i][#pose[i]+1] = t[3]
        pose[i][#pose[i]+1] = o[4]
        pose[i][#pose[i]+1] = o[1]
        pose[i][#pose[i]+1] = o[2]
        pose[i][#pose[i]+1] = o[3]
    end
end

function exportContent()

    -- Write scene content into file
    local contentName = exportFolder.."content.txt"
    file = io.open (contentName,"w")
    for i = 1, #visibleHandles, 1 do
        file:write(tostring(exportFolder..sim.getObjectName(visibleHandles[i]).."\n"))
    end
    io.close(file)

    -- Write meshes
    for i = 1, #visibleHandles, 1 do
        local meshName = exportFolder..sim.getObjectName(visibleHandles[i])..".obj"
        vertices,indices=sim.getShapeMesh(visibleHandles[i])
        sim.exportMesh(0,meshName,0,1,{vertices},{indices})
    
        file = io.open (exportFolder..sim.getObjectName(visibleHandles[i])..".mtl","a")
        dump, color=sim.getShapeColor(visibleHandles[i], nil ,sim.colorcomponent_ambient_diffuse)
        file:write("Ka "..color[1].." "..color[2].." "..color[3].."\n")
        file:write("Kd "..color[1].." "..color[2].." "..color[3].."\n")

        dump, color=sim.getShapeColor(visibleHandles[i], nil ,sim.colorcomponent_specular)
        file:write("Ks "..color[1].." "..color[1].." "..color[1].."\n")
        io.close(file)
    end
    
    -- Write animation
    for i = 1, #visibleHandles, 1 do
        local animationName = exportFolder..sim.getObjectName(visibleHandles[i])..".txt"
        file = io.open (animationName,"w")
        file:write("t,x,y,z,rw,rx,ry,rz\n")

        for ii = 1, #pose[i], 8 do
            file:write(tostring(pose[i][ii])..","..
                       tostring(pose[i][ii+1])..","..
                       tostring(pose[i][ii+2])..","..
                       tostring(pose[i][ii+3])..","..
                       tostring(pose[i][ii+4])..","..
                       tostring(pose[i][ii+5])..","..
                       tostring(pose[i][ii+6])..","..
                       tostring(pose[i][ii+7]).." \n")
        end
        io.close(file)
    end
end

