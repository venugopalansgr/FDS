# SketchUp to FDS
# Converts a Sketchup model into FDS format
# Usage: Copy the plugin and place it in the Plugins folder
# Usage: Choose "Export to FDS" under Tools menu and choose filename
# Output: FDS input file will be created
# Limitations: Each of the different geometry types (limited to "OBST","VENT" for now) need to be in their own layer.
# Limitations: Name of the layer same as the name of the geometry type
# Limitations: Each object needs to be a group
# Limitations: Slices need to be in Layer0 and a group with name containing "SLCF"
# Notes: No warranty on results. Use at your own risk/discretion
# Notes: Code is free. Appreciate feedback/acknowledgment when using it
# Created by: Venugopalan Raghavan

#EDIT:
# 04 Jun 2015 - Removed unnecessary : in if clause before SURF_ID
require 'sketchup.rb'

def fds_write
	model = Sketchup.active_model
	entities = model.entities
	path = model.path
	layers = model.layers
	n = path.split("\\")
	nn = n.length
	name = (n[nn-1]).split(".skp")[0]
	s = ""
	for i in 0..nn-2 do
		s = s + n[i] + "/"
	end
	out_name = s + name + ".fds"
	UI.messagebox("out_name = #{out_name}",MB_OK)
	oF = File.new(out_name, "w")
	eps = 1e-6
	obcnt = 0
	vecnt = 0
	hocnt = 0
	entcnt = 0
	oF.puts("&HEAD CHID='"+name+"'/")
	oF.puts("&TIME T_END=3600.0/")
	oF.puts("&DUMP RENDER_FILE="+name+".ge1', DT_RESTART=300.0/")
	oF.puts("&MISC TMPA=30.0/")
	oF.puts()
	
	gb = model.bounds
	
	gXmin = (gb.corner(0)[0].to_s).split("m")[0]
	gYmin = (gb.corner(0)[1].to_s).split("m")[0]
	gZmin = (gb.corner(0)[2].to_s).split("m")[0]
	gXmax = (gb.corner(7)[0].to_s).split("m")[0]
	gYmax = (gb.corner(7)[1].to_s).split("m")[0]
	gZmax = (gb.corner(7)[2].to_s).split("m")[0]
	
	if gXmin.include? "~"
		gXmin = gXmin.split("~ ")[1]
	end
	if gXmax.include? "~"
		gXmax = gXmax.split("~ ")[1]
	end
	if gYmin.include? "~"
		gYmin = gYmin.split("~ ")[1]
	end
	if gYmax.include? "~"
		gYmax = gYmax.split("~ ")[1]
	end
	if gZmin.include? "~"
		gZmin = gZmin.split("~ ")[1]
	end
	if gZmax.include? "~"
		gZmax = gZmax.split("~ ")[1]
	end
	
	nX = ((gXmax.to_f - gXmin.to_f)/0.1).to_i
	nY = ((gYmax.to_f - gYmin.to_f)/0.1).to_i
	nZ = ((gZmax.to_f - gZmin.to_f)/0.1).to_i
	
	flag = 0
	
	for p in 0..entities.length-1 do
		entity = entities[p]
		if (entity.typename=="Group")
			if entity.name.include? "mesh"
				mb = entity.bounds
				mXmin = (mb.corner(0)[0].to_s).split("m")[0]
				mYmin = (mb.corner(0)[1].to_s).split("m")[0]
				mZmin = (mb.corner(0)[2].to_s).split("m")[0]
				mXmax = (mb.corner(7)[0].to_s).split("m")[0]
				mYmax = (mb.corner(7)[1].to_s).split("m")[0]
				mZmax = (mb.corner(7)[2].to_s).split("m")[0]
	
				if mXmin.include? "~"
					mXmin = mXmin.split("~ ")[1]
				end
				if mXmax.include? "~"
					mXmax = mXmax.split("~ ")[1]
				end
				if mYmin.include? "~"
					mYmin = mYmin.split("~ ")[1]
				end
				if mYmax.include? "~"
					mYmax = mYmax.split("~ ")[1]
				end
				if mZmin.include? "~"
					mZmin = mZmin.split("~ ")[1]
				end
				if mZmax.include? "~"
					mZmax = mZmax.split("~ ")[1]
				end
			
				mX = (mXmax.to_f - mXmin.to_f)/0.1
				mY = (mYmax.to_f - mYmin.to_f)/0.1
				mZ = (mZmax.to_f - mZmin.to_f)/0.1
	
				mX = mX.to_i
				mY = mY.to_i
				mZ = mZ.to_i
				
				oF.puts("&MESH ID='MESH"+flag.to_s+"', IJK="+mX.to_s+","+mY.to_s+","+mZ.to_s+", XB="+mXmin.to_s+","+mXmax.to_s+","+mYmin.to_s+","+mYmax.to_s+","+mZmin.to_s+","+mZmax.to_s+"/")
				
				flag = flag + 1
			end
		end
	end
				
	if (flag==0)
		oF.puts("&MESH ID='MESH', IJK="+nX.to_s+","+nY.to_s+","+nZ.to_s+", XB="+gXmin.to_s+","+gXmax.to_s+","+gYmin.to_s+","+gYmax.to_s+","+gZmin.to_s+","+gZmax.to_s+"/")
	end
	
	UI.messagebox("Done writing mesh",MB_OK)
	
	oF.puts("\n")
	
	nL = layers.length
	
	for p in 1..nL-1 do
		nN = layers[p].name
			for q in 0..entities.length-1 do
				entity = entities[q]
				if entity.layer.name == nN
					bb = entity.bounds
					xmin = (bb.corner(0)[0].to_s).split("m")[0]
					ymin = (bb.corner(0)[1].to_s).split("m")[0]
					zmin = (bb.corner(0)[2].to_s).split("m")[0]
					xmax = (bb.corner(7)[0].to_s).split("m")[0]
					ymax = (bb.corner(7)[1].to_s).split("m")[0]
					zmax = (bb.corner(7)[2].to_s).split("m")[0]
			
					if xmin.include? "~"
						xmin = xmin.split("~ ")[1]
					end
					if xmax.include? "~"
						xmax = xmax.split("~ ")[1]
					end
					if ymin.include? "~"
						ymin = ymin.split("~ ")[1]
					end
					if ymax.include? "~"
						ymax = ymax.split("~ ")[1]
					end
					if zmin.include? "~"
						zmin = zmin.split("~ ")[1]
					end
					if zmax.include? "~"
						zmax = zmax.split("~ ")[1]
					end
				
					ename=""
				
					if entity.name!=""
						ename = entity.name
						s2 = ", SURF_ID='"+ename+"'/"
					elsif nN=="OBST"
						ename = "INERT"
						s2 = ", SURF_ID='"+ename+"'/"
					elsif nN=="VENT"
						ename = "OPEN"
						s2 = ", SURF_ID='"+ename+"'/"
					else
						s2 = "/"
					end
				
					s1 = "&"+nN+" XB="+xmin.to_s+","+xmax.to_s+","+ymin.to_s+","+ymax.to_s+","+zmin.to_s+","+zmax.to_s+ s2
				
					oF.puts(s1)
				end
			end
	end	
	
	s1 = ""
	oF.puts("\n")
	
	for q in 0..entities.length-1 do
		entity = entities[q]
		if (entity.layer.name=="Layer0") 
			if ((entity.typename=="Group") and (entity.name.include? "SLCF"))
				ety = entity.entities
				eb = entity.bounds
				for w in 0..ety.length-1 do
					e = ety[w]
					if e.typename=="Face"
						normal = e.normal
						break
					end
				end
				if ((normal.x==1) or (normal.x==-1))
					x = (eb.corner(0)[0].to_s).split("m")[0]
					s1 = "PBX=" + x
				elsif ((normal.y==1) or (normal.y==-1))
					y = (eb.corner(0)[1].to_s).split("m")[0]
					s1 = "PBY=" + y
				elsif ((normal.z==1) or (normal.z==-1))
					z = (eb.corner(0)[2].to_s).split("m")[0]
					s1 = "PBZ=" + z
				end
				oF.puts("&SLCF QUANTITY='VELOCITY', VECTOR=.TRUE., "+s1+"/")
				oF.puts("&SLCF QUANTITY='VISIBILITY', VECTOR=.TRUE., "+s1+"/")
				oF.puts("&SLCF QUANTITY='TEMPERATURE', VECTOR=.TRUE., "+s1+"/")
			end
		end
	end
	
	oF.puts("\n&TAIL /")
	oF.close
	
	UI.messagebox("Done writing FDS file!",MB_OK)
end

if( not file_loaded?("skp_to_fds.rb") )
   add_separator_to_menu("Tools")
   UI.menu("Tools").add_item("Export FDS format") { fds_write }
end

file_loaded("skp_to_fds.rb")
