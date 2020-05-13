function sysCall_init()
	-- self
    
    
    -- drive mechanism
    v1=sim.getObjectHandle('joint_wheel1')
    v2=sim.getObjectHandle('joint_wheel2')
    v3=sim.getObjectHandle('joint_wheel3')
    v4=sim.getObjectHandle('joint_wheel4')
    rack1=sim.getObjectHandle('joint_rack1')
    rack2=sim.getObjectHandle('joint_rack2')
    
    --gripper_bottom
    b_block=sim.getObjectHandle('joint_bot_mblock')
    b_actuator_ang=sim.getObjectHandle('joint_bot_actuator')
    b_actuator_pos=sim.getObjectHandle('joint_bot_actuator_rod')
    b_gripper_ang=sim.getObjectHandle('joint_bot_gripper')
    b_gripper_left=sim.getObjectHandle('joint_bot_gripper_left')
    b_gripper_right=sim.getObjectHandle('joint_bot_gripper_right')
    --gripper_bottom state
    
    
    --gripper_up
    u_block=sim.getObjectHandle('joint_up_mblock')
    u_actuator_ang=sim.getObjectHandle('joint_up_actuator')
    u_actuator_pos=sim.getObjectHandle('joint_up_actuator_rod')
    u_gripper_left=sim.getObjectHandle('joint_up_gripper_left')
    u_gripper_right=sim.getObjectHandle('joint_up_gripper_right')
    
    --sensor
    sl1=sim.getObjectHandle('sensor_line_1')
    sl2=sim.getObjectHandle('sensor_line_2')
    sensor_curvef=sim.getObjectHandle('sensor_curvef')
	sensor_curveb=sim.getObjectHandle('sensor_curveb')
	--others
	steer=0
	vel=1
	counter=0
	counter2=1
	counter3=0
	counter4=0
	t_count=0
    t_step=0
    state=1
	----------------------------------------------------------------------
	--initial position
	pos1=27
	pos2=1
	line=20
	dir=1
	dir_lr=0      -- 0: clockwise, 1: counter clockwise
	local_pos = {}
	for i= 0, pos1 do
		if (i==0) then
			local_pos[i]=0
		else
			local_pos[i] =local_pos[i-1]+1
		end
	end

	line_pos ={}
	for i=0, line do
		if (i==0) then
			line_pos[i]=0
		elseif (i==4 or i==11 or i==14) then
			line_pos[i] =line_pos[i-1]+3
		else
			line_pos[i] =line_pos[i-1]+1
    end
	end

	c_pos ={}
	for i=0,1 do
		c_pos[i]=i
	end

	t_pos ={}
	for i=0,1 do
    t_pos[i]=1
	end
	
	----------------------------------------------------------------------
    --console
    debugConsole = sim.auxiliaryConsoleOpen("Debug", 50, 1)
    rackconsole = sim.auxiliaryConsoleOpen("rack", 9, 1)
        edit = function()
		t_pos[0]=simUI.getEditValue(ui,1001)
		t_pos[1]=1
	end
    
	xml = [[
		<ui closeable="true" on-close="closeEventHandler" resizable="true">
			<label text="This is a demo of the CustomUI plugin. Browse through the tabs below to explore all the widgets that can be created with the plugin." wordwrap="true" />
			<tabs>
				<tab title="Target position">
					<label text="Type in target position" wordwrap="true" />
					<edit id="1001" value="number" />
					<button text="Set target postion" on-click="edit" />
					<button text="Go" on-click="go" />
					<stretch />
				</tab>
			</tabs>
		</ui>
	]]
	ui=simUI.create(xml)
    
	----------------------------------------------------------------------
    --function
	
	--calculation
    cal = function(x,v_c)  

		if x~=0 then   
			d=61.09919875*10^-3
			L1=71.74475294*10^-3
			L2=65.765*10^-3
			p1=d-x-0.140
			p2=p1^2-L1^2+0.085^2+L2^2
			n=(-2*p1*p2-math.sqrt(4*p1^2*p2^2-(4*p1^2+0.170^2)*(p2^2-(0.170*L2)^2)))/(4*p1^2+0.170^2)
			b1=1.418147625
			del_b=math.acos(n/L2)-b1
			a1=0.282505032
			del_a=math.asin((0.085-L2*math.sin(b1+del_b))/L1)-a1
			k1=2*d+L1*math.cos(a1+del_a)+L2*math.cos(b1+del_b)-0.280
			k2=k1^2-L1^2+0.085^2+L2^2
			m=(-2*k1*k2-math.sqrt(4*k1^2*k2^2-(4*k1^2+0.170^2)*(k2^2-(0.170*L2)^2)))/(4*k1^2+0.170^2)
			del_c=math.acos(m/L2)-b1
    
			wheelRadius=0.127/2
    
			r_i=0.5/math.sin(math.abs(del_b))
			r_o=0.5/math.sin(math.abs(del_c))
			r_c=0.5/math.tan(math.abs(del_b))+0.25
    
			Vel_R=v_c*r_i/r_c/wheelRadius
			Vel_L=v_c*r_o/r_c/wheelRadius
			if (dir==1) then
				sim.setJointTargetPosition(rack1,x)
				sim.setJointTargetPosition(rack2,x)
				sim.setJointTargetVelocity(v1,Vel_R)
				sim.setJointTargetVelocity(v2,Vel_L)
				sim.setJointTargetVelocity(v3,Vel_L)
				sim.setJointTargetVelocity(v4,Vel_R)   
			else
				sim.setJointTargetPosition(rack1,-x)
				sim.setJointTargetPosition(rack2,-x)
				sim.setJointTargetVelocity(v1,-Vel_L)
				sim.setJointTargetVelocity(v2,-Vel_R)
				sim.setJointTargetVelocity(v3,-Vel_R)
				sim.setJointTargetVelocity(v4,-Vel_L)   
			end
		else 
             wheelRadius=0.127/2
			if (dir==1) then
				sim.setJointTargetPosition(rack1,x)
				sim.setJointTargetPosition(rack2,x)
				sim.setJointTargetVelocity(v1,v_c/wheelRadius)
				sim.setJointTargetVelocity(v2,v_c/wheelRadius)
				sim.setJointTargetVelocity(v3,v_c/wheelRadius)
				sim.setJointTargetVelocity(v4,v_c/wheelRadius)  
			else
				sim.setJointTargetPosition(rack1,-x)
				sim.setJointTargetPosition(rack2,-x)
				sim.setJointTargetVelocity(v1,-v_c/wheelRadius)
				sim.setJointTargetVelocity(v2,-v_c/wheelRadius)
				sim.setJointTargetVelocity(v3,-v_c/wheelRadius)
				sim.setJointTargetVelocity(v4,-v_c/wheelRadius)
			end
		end   
	end
	
	----------------------------------------------------------------------
    --actuation
	act =function()
		if (math.abs(sc_y-0.5)<0.45) then
    
			if (sl1_c ~=0 and sl2_c ~= 0) then
				ang=180/math.pi*math.atan(0.05*(sl1_y-sl2_y)/0.4)
				if(math.abs(ang)>0.45) then
					avg=0.5-(sl1_y+sl2_y)/2
                    
                    if (dir==1) then
                        cal(-0.02/7*ang+0.01*ang/math.abs(ang),1)
                        sim.auxiliaryConsolePrint(rackconsole, string.format("angle control angle: %0.3f avg: %0.3f  rack1: %0.3f  rack2: %0.3f  \n",ang, avg, sim.getJointTargetPosition(rack1),sim.getJointTargetPosition(rack2)))
                    else 
                        cal(0.02/7*ang-0.01*ang/math.abs(ang),1)
                        sim.auxiliaryConsolePrint(rackconsole, string.format("angle control angle: %0.3f avg: %0.3f  rack1: %0.3f  rack2: %0.3f  \n",ang, avg, sim.getJointTargetPosition(rack1),sim.getJointTargetPosition(rack2)))
                    end
                end
    
				if (math.abs(ang)<0.3) then
					avg=0.5-(sl1_y+sl2_y)/2
					if (math.abs(avg)>0.005) then
						if (dir==1) then
							sim.setJointTargetPosition(rack1,0.02/0.5*avg)
							sim.setJointTargetPosition(rack2,-0.02/0.5*avg)
						else
							sim.setJointTargetPosition(rack2,0.02/0.5*avg)
							sim.setJointTargetPosition(rack1,-0.02/0.5*avg)
						end
					end
				end
				sim.auxiliaryConsolePrint(rackconsole, string.format("parallel control angle: %0.3f avg: %0.3f  rack1: %0.3f  rack2: %0.3f  \n",ang, avg, sim.getJointTargetPosition(rack1),sim.getJointTargetPosition(rack2)))
			end
		else
			if (math.abs(sc_y-0.5)>0.45) then
				if(sc_y >0.5) then
            		cal(-0.021/0.5*(sc_y-0.5),0.5)
				end
				if(sc_y < 0.5) then
					cal(-0.021/0.5*(sc_y-0.5),0.5)
				end
				sim.auxiliaryConsolePrint(rackconsole, string.format("curve angle: %0.3f avg: %0.3f  rack1: %0.3f  rack2: %0.3f  \n",ang, avg, sim.getJointTargetPosition(rack1),sim.getJointTargetPosition(rack2)))
			end       
		end
    end
   
	act_time = function(st,vt, t_time)
		t_step=0
		t_step=t_step+dt
        t_count=t_time
		steer=st
		vel=vt
		cal(steer,vel)
	end
   
	act_flow = function()
		if(t_step < t_count) then
			t_step=t_step + dt
			cal(steer,vel)
		else
			act()
			steer=0
		end
	end
	act_front = function()
	    if (counter ~= counter3) then
			act_time(0,1,1)
        else
			act_flow()
		end
	end
    go = function()
        state=0
        set_lr()
        act_time(0,1,dt)
        act_flow()
		posi=sim.setUserParameter(sim.handle_self,'poos',c_pos[1])
    end
   ----------------------------------------------------------------------	
	-- direction
	-- l_r setter
    set_lr = function()
        if (t_pos[0]-c_pos[0]<-14) then
            dir_lr=0
        elseif (t_pos[0]-c_pos[0]>=3 and t_pos[0]-c_pos[0]<=14) then
            dir_lr=0
        elseif (t_pos[0]-c_pos[0]<3 and t_pos[0]-c_pos[0]>=1 and c_pos[0]~=0) then
            dir_lr=1
        elseif (t_pos[0]-c_pos[0]>-3 and t_pos[0]-c_pos[0]<=-1 and c_pos[0]~=0) then
            dir_lr=0
        elseif (t_pos[0]-0<=2 and c_pos[0]==0) then
            dir_lr=0
        else
            dir_lr=1
        end
    end
    set_lr()
	-- exit initial
    exit_initial = function()
		if (c_pos[1]>=1) then
		--exit
			if (dir_lr==0) then
                cal(0,1)
				act()
                if (counter ~= counter3) then
					c_pos[1]=-1
					act_time(0,0.5,1)
				end
			else
				if (counter ~= counter3) then
					act_time(0.022,0.5,4.4)
					c_pos[1]=-1
				end
			end
		else
		act_flow()
            if (counter ~= counter3) then
                if (c_pos[1]==-1) then
                    if (dir_lr==0) then
                        c_pos[0]=0
						c_pos[1]=0
                        act()
                    else
                        c_pos[0]=27
						c_pos[1]=0
                        act()
                    end
                end
            end
        end
	end
    -- trigger_tip
    trip =function()
        if (dir_lr==0) then
				c_pos[0]=c_pos[0]+1
			else
				c_pos[0]=c_pos[0]-1
        end
    end
	-- exit normal
	exit_normal= function()
		if (c_pos[1]>=1) then
		--exit
        
        
			if (dir_lr==0) then
				act()
                if (counter ~= counter3) then
					c_pos[1]=-1
                    act_time(-0.02,0.42,5.8)
				end
			else
                act()
				if (counter ~= counter3) then
					c_pos[1]=-1
					act_time(0.02,0.42,5.8)
				end
            end
            
            
		else
		
			if(t_count==t_step) then
				cal(0,1)
            else
                act_flow()
			end
            if (counter ~= counter3) then
                if (c_pos[1]==-1) then
                    if (dir_lr==0) then
                        c_pos[0]=c_pos[0]+1
						c_pos[1]=0
						act()
                    else
                        c_pos[0]=c_pos[0]-1
						c_pos[1]=0
                        act()
                    end
                end
            end
        end
	end
	
   ----------------------------------------------------------------------
   ---counter reset
	counter_reset = function()
		counter=0
		counter2=1
		counter3=0
		counter4=0
	end
end

function sysCall_actuation() 
    dt=sim.getSimulationTimeStep()
    t=sim.getSimulationTime()
        
   -- self parameter
   posi=sim.setUserParameter(sim.handle_self,'poos',c_pos[1])
   --actuation

    if (state==0) then
    if(c_pos[1]==1 or c_pos[1]==-1) then
		if(c_pos[0]==0 or c_pos[0]==27) then
			exit_initial()
			if (counter ==3) then
				if(c_pos[0]==27) then
					c_pos[0]=26
				elseif(c_pos[0]==0) then
					c_pos[0]=1
				end
			end
		else
		exit_normal()
		end
    else
		if (dir_lr==0) then 
			if (c_pos[0]==t_pos[0]-2) then
				if (counter ~= counter3) then
					act_time(-0.021,0.4,5.7)
                    c_pos[0]=t_pos[0]
					c_pos[1]=-2
					else
					act()
				end
			elseif (c_pos[0]==t_pos[0]) then
                act_flow()
                if (counter ~= counter3) then
                    cal(0,0)
					c_pos[1]=t_pos[1]
                    state=1
					if (dir==1) then
						dir=0
					else
						dir=1
					end
					counter_reset()
                end
			elseif (counter ~= counter3) then
				if (c_pos[0]==27) then
					c_pos[0]=0
				else
					trip()
				end
            elseif (c_pos[0]==t_pos[0]+2 or c_pos[0]==t_pos[0]+3) then
                dir_lr = 1  
                dir=1
                c_pos[0]=c_pos[0]+1
			else
				act()
                if (counter ~= counter3) then
                    trip()
                end
			end
		else
			if (c_pos[0]==t_pos[0]+2) then
				if (counter ~= counter3) then
					act_time(0.021,0.4,5.7)
                    c_pos[0]=t_pos[0]
					c_pos[1]=-2
				else
					act()
				end
			elseif (c_pos[0]==t_pos[0]) then
                act_flow()
                if (counter ~= counter3) then
                    cal(0,0)
					state=1
                    c_pos[1]=t_pos[1]
					if (dir==1) then
						dir=0
					else
						dir=1
					end
					counter_reset()
                end
			elseif (counter ~= counter3) then
				if (c_pos[0]==0) then
					c_pos[0]=27
				else
					trip()
				end
            elseif (c_pos[0]==t_pos[0]-2 or c_pos[0]==t_pos[0]-3) then
                dir_lr=0
                dir=0
                c_pos[0]=c_pos[0]-1
            else
				act()
                if (counter ~= counter3) then
                    trip()
                end
			end
		end		
			
   	end
    else
        posi=sim.setUserParameter(sim.handle_self,'poos',c_pos[1])
    end
	

	counter3=counter
    
    --after arriving, start to adjust its position
   
        
        
    
    
    --
    
    
    
    
end

function sysCall_sensing()
    -- put your sensing code here
   if (dir==1) then   
		result,pack1,pack2 = sim.readVisionSensor(sl1)
		sl1_c = pack2[1]
		sl1_s = pack2[3]
		sl1_x = pack2[5]
		sl1_y = pack2[6]
		result,pack1,pack2 = sim.readVisionSensor(sl2)
		sl2_c = pack2[1]
		sl2_s = pack2[3]
		sl2_x = pack2[5]
		sl2_y = pack2[6]    
		result,pack1,pack2 = sim.readVisionSensor(sensor_curvef)
		sc_c = pack2[1]
		sc_s = pack2[3]
		sc_x = pack2[5]
		sc_y = pack2[6]
	else
		result,pack1,pack2 = sim.readVisionSensor(sl2)
		sl1_c = pack2[1]
		sl1_s = pack2[3]
		sl1_x = pack2[5]
		sl1_y = pack2[6]
		result,pack1,pack2 = sim.readVisionSensor(sl1)
		sl2_c = pack2[1]
		sl2_s = pack2[3]
		sl2_x = pack2[5]
		sl2_y = pack2[6]    
		result,pack1,pack2 = sim.readVisionSensor(sensor_curveb)
		sc_c = pack2[1]
		sc_s = pack2[3]
		sc_x = pack2[5]
		sc_y = pack2[6]
    end
	if (sl2_c >2) then
		if (counter2<sl2_c) then
			counter=counter + 1
		end
		counter2=sl2_c
	else
		counter2=1
	end
	sim.auxiliaryConsolePrint(debugConsole, string.format("dir: %1.f, lr: %1.f, counter: %1.f,  [%1.f, %1.f], [%1.f, %1.f] %1.3f %1.3f \n",dir, dir_lr, counter, t_pos[0], t_pos[1], c_pos[0], c_pos[1], t_count, t_step))
    
end

function sysCall_cleanup()
    -- do some clean-up here
end

-- See the user manual or the available code snippets for additional callback functions and details
   
