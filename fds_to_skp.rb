# FDS to SketchUp
# Converts a FDS file into a SketchUp model
# Usage: Copy the plugin and place it in the Plugins folder
# Usage: Choose "Import FDS" under Tools menu and choose filename
# Output: SketchUp model will be created with each type geometry type in a separate layer
# Limitations: For "HOLE", volume subtraction from "OBST" is not done. Instead "HOLE" is created as another solid
# Notes: No warranty on results. Use at your own risk/discretion
# Notes: Code is free. Appreciate feedback/acknowledgment when using it
# Created by: Venugopalan Raghavan

require 'sketchup.rb'

def fds_read
	filename = UI.openpanel("Choose FDS file to read",nil,"*.fds")
	UI.messagebox("Current file = #{filename}",MB_OK)
	model = Sketchup.active_model
	entities = model.entities
	layers = model.layers
	eps = 1e-6
	IO.foreach(filename) do |line|
		line.chomp!
		if ((line[/XB=/]))
			flag = 0
			e1 = line.split()[0]
			e2 = e1.split("&")[1]
			
			for p in 0..layers.length-1 do
				if ((e2.include? layers[p].name))
					model.active_layer = e2
					flag = 1
					break
				end
			end
			
			if flag == 0
				layers.add(e2)
				model.active_layer = e2
			end
			
			s1 = line.split("XB=")[1]
			p1x, p7x, p1y, p7y, p1z, p7z = s1.split(",")[0..5]
			p1 = Geom::Point3d.new(p1x.to_f.m,p1y.to_f.m,p1z.to_f.m)
			p7 = Geom::Point3d.new(p7x.to_f.m,p7y.to_f.m,p7z.to_f.m)
			vec = p7 - p1
			if (vec.x.abs < eps)
				p2 = p1 + Geom::Vector3d.new(0,vec.y,0)
				p3 = p1 + Geom::Vector3d.new(0,vec.y,vec.z)
				p4 = p1 + Geom::Vector3d.new(0,0,vec.z)
				face1 = entities.add_face([p1,p2,p3,p4])
			elsif (vec.y.abs < eps)
				p2 = p1 + Geom::Vector3d.new(vec.x,0,0)
				p3 = p1 + Geom::Vector3d.new(vec.x,0,vec.z)
				p4 = p1 + Geom::Vector3d.new(0,0,vec.z)
				face1 = entities.add_face([p1,p2,p3,p4])
			elsif (vec.z.abs < eps)
				p2 = p1 + Geom::Vector3d.new(vec.x,0,0)
				p3 = p1 + Geom::Vector3d.new(vec.x,vec.y,0)
				p4 = p1 + Geom::Vector3d.new(0,vec.y,0)
				face1 = entities.add_face([p1,p2,p3,p4])
			else
				p2 = p1 + Geom::Vector3d.new(vec.x,0,0)
				p3 = p1 + Geom::Vector3d.new(vec.x,vec.y,0)
				p4 = p1 + Geom::Vector3d.new(0,vec.y,0)
				face1 = entities.add_face([p1,p2,p3,p4])
				
				p5 = p1 + Geom::Vector3d.new(0,0,vec.z)
				p6 = p2 + Geom::Vector3d.new(0,0,vec.z)
				p8 = p4 + Geom::Vector3d.new(0,0,vec.z)
				
				face2 = entities.add_face([p1,p2,p6,p5])
				face3 = entities.add_face([p2,p3,p7,p6])
				face4 = entities.add_face([p3,p4,p8,p7])
				face5 = entities.add_face([p4,p1,p5,p8])
				face6 = entities.add_face([p5,p6,p7,p8])
			end		
		end
	end
	UI.messagebox("FDS file read in successfully!",MB_OK)
end

if( not file_loaded?("fds_to_skp.rb") )
   add_separator_to_menu("Tools")
   UI.menu("Tools").add_item("Import FDS") { fds_read }
end

file_loaded("fds_to_skp.rb")
