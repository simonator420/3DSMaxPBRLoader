/* ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK ##### */

title = "Reawote PBR Loader"
renderEngines = #("Corona", "VRay")
labelWidth = 100  -- Width of the labels
fullWidthElement = 425  -- Width of the dropdown and the editText
buttonWidth = 80  -- Width of the Browse button
global ReawotePBRLoader
global folderPaths = #()
global allFolderPaths = #()


rollout ReawotePBRLoader title
(
    -- Label for Material Folder text
    label lblMaterialFolder "Material Folder" pos:[10,5] width:labelWidth

    -- Browse button
    button btnBrowse "Browse" pos:[350,5] width:buttonWidth

    -- Label for Select Renderer text
    label lblSelectRenderer "Select Renderer" pos:[10,30] width:labelWidth

    -- ComboBox for renderer selection
    dropdownlist ddlRenderer items:renderEngines pos:[350,30] width:buttonWidth enabled:false

    -- EditText for displaying selected path
    edittext edtSelectedPath "" pos:[5,60] width:fullWidthElement enabled:false
	
	-- Checkboxes for custom loading
	checkbox loadAO "Include ambient occlusion (AO) maps" checked:False pos:[7.5, 90] enabled:false
	checkbox loadDisp "Include displacement maps" checked:False pos:[7.5, 110] enabled:false
	checkbox load16Disp "Use 16 bit displacement maps (when available)" checked:False pos:[7.5, 130] enabled:false
	checkbox load16Nrm "Use 16 bit normal maps (when available)" checked:False pos:[7.5, 150] enabled:false
	
	-- Button for loading materials
	button btnLoadMaterials "Load selected materials" pos:[5, 175] width:fullWidthElement enabled:false
	
	button btnSelectAll "Select All" pos:[5, 205] width:buttonWidth enabled:false
	button btnRefresh "Refresh" pos:[90, 205] width:buttonWidth enabled:false
	button btnAddToQueue "Add To Queue" pos:[175, 205] width:buttonWidth enabled:false
	button btnClean "Clean" pos:[260, 205] width:buttonWidth enabled:false

	dotNetControl lvItems "System.Windows.Forms.ListView" pos:[5, 235] width:fullWidthElement height:250

	dotNetControl imgDisplay "System.Windows.Forms.PictureBox" pos:[500, 500] width:76 height:76
	label lblMatPreview "" pos:[90, 532] width:315

	on lvItems ItemCheck sender args do
	(
		local index = args.Index
		local item = sender.Items.Item[index]
		local itemName = item.SubItems.Item[1].Text
		local clickedPath = folderPaths[index + 1]
		-- print(clickedPath)
	)

	on lvItems MouseClick sender args do
	(
		local clickedItem = sender.GetItemAt(args.X) (args.Y)
		local itemName = clickedItem.SubItems.Item[1].Text
		local index = sender.Items.IndexOf(clickedItem)
		-- print(itemName)
		local clickedPath = folderPaths[index + 1]
		local subfolders = getDirectories (clickedPath + "\\*")
		for subfolder in subfolders do
        (
			-- print(subfolder)
            local folderName = filenameFromPath(subfolder)
			-- print(folderName)
            if folderName == "PREVIEW\\" do
            (
                local files = getFiles (subfolder + "\\*")
				for file in files do
				(
					local filename = filenameFromPath(file)
					if (matchPattern filename pattern:"*SPHERE*") or (matchPattern filename pattern:"*FABRIC*") do
					(
						local filePath = file + "\\"
						local image = dotNetObject "System.Drawing.Bitmap" file
						imgDisplay.Image = image
						imgDisplay.SizeMode = imgDisplay.SizeMode.StretchImage
						imgDisplay.pos = [5, 500]
						lblMatPreview.text = itemName
						-- print(itemName)
					)
				)
			)
        )
	)
	
	on ReawotePBRLoader open do
    (
        -- Configuration for the ListView
        lvItems.View = lvItems.View.Details
        lvItems.CheckBoxes = true
        lvItems.FullRowSelect = true
        lvItems.GridLines = true

        local checkColumnWidth = 50 -- Width for the "Check" column
		local nameColumnWidth = 370 -- Width for the "Name" column

		lvItems.columns.add("Check") checkColumnWidth
		lvItems.columns.add("Name") nameColumnWidth

		try (
			d = (windows.getChildHWND 0 title)[1]
			icon = dotnetobject "System.Drawing.Icon" ((getDir #usericons) +"\\reawote_icon.ico")
			print(icon)
			windows.SendMessage d 0x0080 0 icon.handle
		) catch (
			print "Error setting icon."
		)

    )

    -- Event handler for the Browse button
    on btnBrowse pressed do
    (
		-- print(RendererClass.classes)
        -- Code to handle the folder browsing and selection
        local selectedFolder = getSavePath()
		-- Clear the existing items and folderPaths
		-- print(allFolderPaths)
		lvItems.Items.Clear()
		folderPaths = #()
        if selectedFolder != undefined do
        (

			initiallySelectedFolder = selectedFolder
			
			-- local allFiles = getFiles (selectedFolder + "\\*")
			local allFolders = getDirectories (selectedFolder + "\\*")
			local validSubfolderExists = false


			for folder in allFolders do
			(
				local folderName = filenameFromPath folder
				local subfolders = getDirectories (folder + "\\*")
				local validSubfolderFound = false
			
				for subfolder in subfolders do
				(
					-- print(subfolder)
					local parts = filterString subfolder "\\"
					arrLength = parts.count
					desiredFolder = parts[arrLength]
					local folderEndings = #("1K", "2K", "3K", "4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "14K", "15K", "16K")
					if findItem folderEndings desiredFolder != 0 do
					(
						validSubfolderFound = true
						validSubfolderExists = true
						exit
					)
				)
			
				if validSubfolderFound do
				(
					local parts = filterString folderName "_"
					local matName = if parts.count >= 3 then (parts[1] + "_" + parts[2] + "_" + parts[3]) else (folderName)
					local mat = dotNetObject "System.Windows.Forms.ListViewItem" ""
					mat.Checked = false
					mat.SubItems.Add(matName)
					lvItems.Items.Add(mat)
					append folderPaths folder
				)
			)

			if validSubfolderExists do
			(
				append allFolderPaths selectedFolder
				edtSelectedPath.text = selectedFolder
				-- Handle the enabling
				edtSelectedPath.enabled = true
				ddlRenderer.enabled = true
				loadAO.enabled = true
				loadDisp.enabled = true
				load16Nrm.enabled = true
				load16Disp.enabled = true
				btnLoadMaterials.enabled = true
				btnSelectAll.enabled = true
				btnRefresh.enabled = true
				btnAddToQueue.enabled = true
				btnClean.enabled = true

				load16Disp.checked = true
				loadDisp.checked = true
				load16Nrm.checked = true
				loadAO.checked = true

				btnBrowse.enabled = false
			)			
        )
    )

	fn createCoronaBitmapNode filePath = (
		local bitmapNode = CoronaBitmap()
		bitmapNode.filename = filePath
		return bitmapNode
	)

	fn createVrayBitmapNode filePath =
	(
		local vrayNode = VRayBitmap()
		vrayNode.filename = filePath
		return vrayNode
	)

	
	-- Event handler for the Load Materials button
    on btnLoadMaterials pressed do
    (
		-- Check the selected renderer
		local selectedRenderer = ddlRenderer.selected
		local slotIndex = 1 -- Start from the first slot
        -- Iterate through all materials in the ListView
		for i = 1 to lvItems.Items.Count do
		(
			local mat = lvItems.Items.Item[i-1]

			-- Check if the material is selected
			if mat.Checked then
			(
				local actualFolderPath = folderPaths[i]
				local subfolders = getDirectories (actualFolderPath + "\\*")

				-- Switch renderer to Corona if it's selected
				if selectedRenderer == "Corona" then
				(
					local materialName = mat.SubItems.Item[1].Text
					renderers.current = Corona()
					local materialToAssign  = CoronaPhysicalMtl ()
					materialToAssign.name = materialName
					materialToAssign.roughnessMode = 1

					-- -- print out all subfolders of the actual material folder
					if subfolders.count > 0 then
					(
						-- print ("Subfolders in " + actualFolderPath + ":")
						for subfolder in subfolders do
						(
							-- print ("  Subfolder: " + (filenameFromPath subfolder))
							local parts = filterString subfolder "\\"
							arrLength = parts.count
							desiredFolder = parts[arrLength]
							local folderEndings = #("1K", "2K", "3K", "4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "14K", "15K", "16K")
							-- print(desiredFolder)
							if findItem folderEndings desiredFolder != 0 then  -- Added check for folderEndings
							(
								local filesInSubfolder = getFiles (subfolder + "\\*")
								local mapsList = #()
								for file in filesInSubfolder do
								(
									local validMapTypes = #("COL", "AO", "GLOSS", "NRM", "NRM16", "DISP", "DISP16", "METAL", "OPAC", "SSS", "SHEENGLOSS")
									local matParts = filterString file "\\"
									local matPartsLength = matParts.count
									local fileName = matParts[matPartsLength]

									local fileNameParts = filterString fileName "_"
									local fileNamePartsLength = fileNameParts.count
									if fileNamePartsLength > 1 do (
										local map = fileNameParts[fileNamePartsLength-1]
										if findItem validMapTypes map > 0 then (
											append mapsList map
											)
										)
								)
								
								-- print(mapsList)
								local compositeLoaded = false
								local compositeMap = None
								for file in filesInSubfolder do
								(
									local matParts = filterString file "\\"
									local matPartsLength = matParts.count
									local fileName = matParts[matPartsLength]

									local fileNameParts = filterString fileName "_"
									local fileNamePartsLength = fileNameParts.count
									if fileNamePartsLength > 1 do (
										local map = fileNameParts[fileNamePartsLength-1]
										)

									-- print(fileName)
									if map == "COL" then
									(
										if loadAO.checked and (findItem mapsList "AO") != 0 then
										(
											local baseColorMapPath = file
											local baseColorMap = createCoronaBitmapNode baseColorMapPath
											baseColorMap.name = map
											
											if compositeLoaded != 1 then
											(
												compositeMap = CompositeTexturemap()
												compositeMap.mapEnabled.count = 2
												compositeMap.blendMode[2] = 5
												materialToAssign.baseTexmap = compositeMap
												compositeLoaded = true
											)
											compositeMap.mapList[1] = baseColorMap
											-- print(map)
										)
										else
										(
											local baseColorMapPath = file
											local baseColorMap = createCoronaBitmapNode baseColorMapPath
											baseColorMap.name = map
											materialToAssign.baseTexmap = baseColorMap
											-- print(compositeLoaded)
											-- print(map)
										)
											
									)
									else if map == "AO" then
									(
										if loadAO.checked and (findItem mapsList "AO") != 0 then
										(
											local aoMapPath = file
											local aoMap = createCoronaBitmapNode aoMapPath
											aoMap.name = map

											if compositeLoaded != 1 then
											(
												compositeMap = CompositeTexturemap()
												compositeMap.mapEnabled.count = 2
												compositeMap.blendMode[2] = 5
												materialToAssign.baseTexmap = compositeMap
												compositeLoaded = true
											)

											compositeMap.mapList[2] = aoMap
											-- print(compositeLoaded)
											-- print(map)
										) 
									)
									else if map == "GLOSS" then
									(
										local baseGlossMapPath = file
										local baseGlossMap = createCoronaBitmapNode baseGlossMapPath
										baseGlossMap.name = Map
										materialToAssign.baseRoughnessTexmap = baseGlossMap
										-- print(map)
									)
									else if map == "METAL" then
									(
										local metalnessMapPath = file
										local metalnessMap = createCoronaBitmapNode metalnessMapPath
										metalnessMap.name = map
										materialToAssign.metalnessTexmap = metalnessMap
										-- print(map)
									)
									else if map == "OPAC" then
									(
										local opacityColorMapPath = file
										local opacityColorMap = createCoronaBitmapNode opacityColorMapPath
										opacityColorMap.name = map
										materialToAssign.opacityTexmap = opacityColorMap
										-- print(map)
									)
									else if map == "SSS" then
									(
										local sssMapPath = file
										local sssMap = createCoronaBitmapNode sssMapPath
										sssMap.name = map
										materialToAssign.sssAmount = 1.0
										materialToAssign.sssScatterTexmap = sssMap
										-- print(map)
									)
									else if map == "SHEEN" then
									(
										local sheenMapPath = file
										local sheenMap = createCoronaBitmapNode sheenMapPath
										sheenMap.name = map
										materialToAssign.sheenAmountTexmap = sheenMap
										-- print(map)
									)
									else if map == "SHEENGLOSS" then
									(
										local sheenglossMapPath = file
										local sheenglossMap = createCoronaBitmapNode sheenglossMapPath
										sheenglossMap.name = map
										materialToAssign.sheenAmount = 1.0
										materialToAssign.sheenRoughnessTexmap = sheenglossMap
										-- print(map)
									)
									else if map == "NRM" then
									(
										if (load16Nrm.checked == 0) or (findItem mapsList "NRM16" == 0) then
										(
											local nrmMapNode = CoronaNormal()
											local nrmMapPath = file
											local nrmMap = createCoronaBitmapNode nrmMapPath
											nrmMap.name = map
											nrmMapNode.normalMap = nrmMap
											nrmMapNode.flipgreen = on
											nrmMapNode.addGamma = on
											materialToAssign.baseBumpTexmap = nrmMapNode
											-- print(map)
										)
									)
									else if map == "NRM16" then
									(
										if (load16Nrm.checked != 0) and (findItem mapsList "NRM16" != 0) then
										(
											local nrmMapNode = CoronaNormal()
											local nrmMapPath = file
											local nrmMap = createCoronaBitmapNode nrmMapPath
											nrmMap.name = map
											nrmMapNode.normalMap = nrmMap
											nrmMapNode.flipgreen = on
											nrmMapNode.addGamma = on
											materialToAssign.baseBumpTexmap = nrmMapNode
											-- print(map)
										)
									)
									else if (map == "DISP") and (loadDisp.checked == 1) then
									(
										if (load16Disp.checked == 0) or (findItem mapsList "DISP16" == 0) then
										(
											local dispMapPath = file
											local dispMap = createCoronaBitmapNode dispMapPath
											dispMap.name = map
											materialToAssign.displacementTexmap = dispMap
											-- print(map)
										)
									)
									else if (map == "DISP16") and (loadDisp.checked == 1) then
									(
										if (load16Disp.checked != 0) and (findItem mapsList "DISP16" != 0) then
										(
											local dispMapPath = file
											local dispMap = createCoronaBitmapNode dispMapPath
											dispMap.name = map
											materialToAssign.displacementTexmap = dispMap
											-- print(map)
										)
									)

									-- print ("    File: " + file)
								)
							)
						)
					)
					else
					(
						-- print ("No subfolders in " + actualFolderPath)
					)
					-- print ("Switching to Corona Renderer for material: " + mat.SubItems.Item[1].Text)
				)

				-- Switch renderer to VRay if it's selected
				else if selectedRenderer == "VRay" then
				(
					vrayRenderers = #()

					-- Iterate over all available renderers
					for rendererClass in RendererClass.classes do (
						-- Get the renderer's name as a string
						rendererName = rendererClass as string
						-- Check if the renderer's name starts with any of the specified prefixes
						-- Included future versions
						if (matchPattern rendererName pattern:"V_Ray_6*" ignoreCase:true) or
						(matchPattern rendererName pattern:"V_Ray_7*" ignoreCase:true) or
						-- (matchPattern rendererName pattern:"V_Ray_*" ignoreCase:true) or
						(matchPattern rendererName pattern:"V_Ray_8*" ignoreCase:true) then (
							append vrayRenderers rendererClass
						)
					)

					if vrayRenderers.count > 0 then (
					-- Assume the first one is the highest
					highestVersionRenderer = vrayRenderers[1]

					-- Iterate over the list to find the highest version
					for rendererClass in vrayRenderers do (
						if (getFilenameFile (rendererClass as string)) > (getFilenameFile (highestVersionRenderer as string)) then (
							highestVersionRenderer = rendererClass
						)
					)
						-- Set the highest version renderer as the current renderer
						renderers.current = highestVersionRenderer()
					) else (
						print "No matching V-Ray renderer versions found."
					)

					-- print ("Switching to VRay Renderer for material: " + mat.SubItems.Item[1].Text)
					local materialName = mat.SubItems.Item[1].Text
					local materialToAssign  = VRayMtl ()
					materialToAssign.name = materialName

					local actualFolderPath = folderPaths[i]
					local subfolders = getDirectories (actualFolderPath + "\\*")
					-- -- print out all subfolders of the actual material folder
					if subfolders.count > 0 then
					(
						-- print ("Subfolders in " + actualFolderPath + ":")
						for subfolder in subfolders do
						(
							-- print ("  Subfolder: " + (filenameFromPath subfolder))
							local parts = filterString subfolder "\\"
							arrLength = parts.count
							desiredFolder = parts[arrLength]
							local folderEndings = #("1K", "2K", "3K", "4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "14K", "15K", "16K")
							-- print(desiredFolder)
							if findItem folderEndings desiredFolder != 0 then  -- Added check for folderEndings
							(
								local filesInSubfolder = getFiles (subfolder + "\\*")
								local mapsList = #()
								for file in filesInSubfolder do
								(
									local validMapTypes = #("COL", "AO", "GLOSS", "NRM", "NRM16", "DISP", "DISP16", "METAL", "OPAC", "SSS", "SHEENGLOSS")
									local matParts = filterString file "\\"
									local matPartsLength = matParts.count
									local fileName = matParts[matPartsLength]

									local fileNameParts = filterString fileName "_"
									local fileNamePartsLength = fileNameParts.count
									if fileNamePartsLength > 1 do (
										local map = fileNameParts[fileNamePartsLength-1]
										
										-- Check if 'map' is in the list of valid map types
										if findItem validMapTypes map > 0 then (
											append mapsList map
											)
										)
								)
								
								-- print(mapsList)
								local compositeLoaded = false
								local compositeMap = None
								for file in filesInSubfolder do
								(
									local matParts = filterString file "\\"
									local matPartsLength = matParts.count
									local fileName = matParts[matPartsLength]

									local fileNameParts = filterString fileName "_"
									local fileNamePartsLength = fileNameParts.count
									if fileNamePartsLength > 1 do (
										local map = fileNameParts[fileNamePartsLength-1]
										)

									-- print(fileName)
									if map == "COL" then
									(
										if loadAO.checked and (findItem mapsList "AO") != 0 then
										(
											local colourMapPath = file
											local colourMap = createVrayBitmapNode colourMapPath
											colourMap.name = map
											colourMap.color_space = 2
											colourMap.rgbColorSpace = 1
											if compositeLoaded != 1 then
											(
												compositeMap = CompositeTexturemap()
												compositeMap.mapEnabled.count = 2
												compositeMap.blendMode[2] = 5
												materialToAssign.texmap_diffuse = compositeMap
												compositeLoaded = true
											)
											compositeMap.mapList[1] = colourMap
										)
										else
										(
											local colourMapPath = file
											local colourMap = createVrayBitmapNode colourMapPath
											colourMap.name = map
											colourMap.color_space = 2
											colourMap.rgbColorSpace = 1
											materialToAssign.texmap_diffuse = colourMap
										)
									)
									else if map == "AO" then
									(
										if loadAO.checked and (findItem mapsList "AO") != 0 then
										(
											local aoMapPath = file
											local aoMap = createVrayBitmapNode aoMapPath
											aoMap.name = map
											aoMap.color_space = 2
											aoMap.rgbColorSpace = 1

											if compositeLoaded != 1 then
											(
												compositeMap = CompositeTexturemap()
												compositeMap.mapEnabled.count = 2
												compositeMap.blendMode[2] = 5
												materialToAssign.texmap_diffuse = compositeMap
												compositeLoaded = true
											)

											compositeMap.mapList[2] = aoMap
											-- print(compositeLoaded)
											-- print(map)
										) 
									)
									else if map == "GLOSS" then -- done
									(
										local glossMapPath = file
										local glossMap = createVrayBitmapNode glossMapPath
										glossMap.name = map
										glossMap.color_space = 0 -- None
										glossMap.rgbColorSpace = 3 -- Raw
										glossMap.gamma = 0.7
										glossMap.type = 1
										materialToAssign.Reflection = white
										materialToAssign.texmap_reflectionGlossiness = glossMap
									)
									else if map == "NRM" then -- done
									(
										if (load16Nrm.checked == 0) or (findItem mapsList "NRM16" == 0) then
										(
											local nrmMapNode = VRayNormalMap()
											local nrmMapPath = file
											local nrmMap = createVrayBitmapNode nrmMapPath
											nrmMap.name = map
											nrmMap.color_space = 0 -- None
											nrmMap.rgbColorSpace = 3 -- Raw
											nrmMapNode.NormalMap = nrmMap
											materialToAssign.texmap_bump_multiplier = 100.0
											materialToAssign.texmap_bump = nrmMapNode
										)
									)
									else if map == "NRM16" then -- done
									(
										if (load16Nrm.checked != 0) and (findItem mapsList "NRM16" != 0) then
										(
											local nrmMapNode = VRayNormalMap()
											local nrmMapPath = file
											local nrmMap = createVrayBitmapNode nrmMapPath
											nrmMap.name = map
											nrmMap.color_space = 0 -- None
											nrmMap.rgbColorSpace = 3 -- Raw
											nrmMapNode.NormalMap = nrmMap
											materialToAssign.texmap_bump_multiplier = 100.0
											materialToAssign.texmap_bump = nrmMapNode
										)
									)
									else if (map == "DISP") and (loadDisp.checked == 1) then
									(
										if (load16Disp.checked == 0) or (findItem mapsList "DISP16" == 0) then
										(
											local dispMapPath = file
											local dispMap = createVrayBitmapNode dispMapPath
											dispMap.name = map
											dispMap.color_space = 0 -- None
											dispMap.rgbColorSpace = 3 -- Raw
											materialToAssign.texmap_displacement_multiplier = 1.0
											materialToAssign.texmap_displacement = dispMap
											-- print(map)
										)
									)
									else if (map == "DISP16") and (loadDisp.checked == 1) then
									(
										if (load16Disp.checked != 0) and (findItem mapsList "DISP16" != 0) then
										(
											local dispMapPath = file
											local dispMap = createVrayBitmapNode dispMapPath
											dispMap.name = map
											dispMap.color_space = 0 -- None
											dispMap.rgbColorSpace = 3 -- Raw
											materialToAssign.texmap_displacement_multiplier = 1.0
											materialToAssign.texmap_displacement = dispMap
											-- print(map)
										)
									)
									else if map == "METAL" then
									(
										local metalnessMapPath = file
										local metalnessMap = createVrayBitmapNode metalnessMapPath
										metalnessMap.name = map
										metalnessMap.color_space = 0 -- None
										metalnessMap.rgbColorSpace = 3 -- Raw
										metalnessMap.gamma = 0.7
										metalnessMap.type = 1
										materialToAssign.texmap_metalness = metalnessMap
										-- print(map)
									)
									else if map == "OPAC" then
									(
										local opacityColorMapPath = file
										local opacityColorMap = createVrayBitmapNode opacityColorMapPath
										opacityColorMap.name = map
										opacityColorMap.color_space = 0 -- None
										opacityColorMap.rgbColorSpace = 3 -- Raw
										materialToAssign.texmap_opacity = opacityColorMap
										-- print(map)
									)
									else if map == "SSS" then
									(
										local sssMapPath = file
										local sssMap = createVrayBitmapNode sssMapPath
										sssMap.name = map
										sssMap.color_space = 2
										sssMap.rgbColorSpace = 1
										materialToAssign.translucency_on = 6
										materialToAssign.texmap_translucent = sssMap
										-- print(map)
									)
									else if map == "SHEENGLOSS" then
									(
										local sheenglossMapPath = file
										local sheenglossMap = createVrayBitmapNode sheenglossMapPath
										sheenglossMap.name = map
										sheenglossMap.color_space = 0 -- None
										sheenglossMap.rgbColorSpace = 3 -- Raw
										materialToAssign.texmap_sheen_glossiness = sheenglossMap
										-- print(map)
									)
								)
							)
						)
					)
				)
				else(
					-- print("Renderer nevybran")
				)

				if slotIndex <= meditMaterials.count then
				(
					meditMaterials[slotIndex] = materialToAssign
					format "Assigned material to Material Editor slot: %\n" slotIndex
					slotIndex += 1 -- Increment slot index for the next material
				)
				else
				(
					-- print "Ran out of Material Editor slots."
					break -- Exit the loop if no more slots are available
				)
			)
		)
    )

	-- Event handler for the Select All button
	on btnSelectAll pressed do
	(
		-- Check if all items are currently selected
		local allSelected = true
		for matIndex = 1 to lvItems.Items.Count do
		(
			local mat = lvItems.Items.Item[matIndex - 1]
			if not mat.Checked then
			(
				allSelected = false
				break
			)
		)

		-- If all items are selected, deselect all. Otherwise, select all.
		for matIndex = 1 to lvItems.Items.Count do
		(
			local mat = lvItems.Items.Item[matIndex - 1]
			mat.Checked = not allSelected
		)
	)

	-- Event handler for the Refresh button
	on btnRefresh pressed do
	(
		lvItems.Items.Clear() -- Clear existing items in the ListView

		-- Iterate through all folders in allFolderPaths and their subfolders
		for folder in allFolderPaths do
		(
			local allSubFolders = getDirectories (folder + "\\*")

			for subFolder in allSubFolders do
			(
				local folderName = filenameFromPath subFolder
				local parts = filterString folderName "_"
				local matName = if parts.count >= 3 then
					(parts[1] + "_" + parts[2] + "_" + parts[3])
				else
					(folderName)  -- Fallback to the original folder name if not enough parts

				local mat = dotNetObject "System.Windows.Forms.ListViewItem" ""
				mat.Checked = false
				mat.SubItems.Add(matName)  -- Name of the material
				lvItems.Items.Add(mat)
			)
		)
	)


	on btnAddToQueue pressed do
	(
		local additionalFolder = getSavePath() -- Get additional folder path
		-- print(allFolderPaths)
		if additionalFolder != undefined do
		(
			local allFolders = getDirectories (additionalFolder + "\\*")
			local validSubfolderExists = false

			-- Add new folders to ListView
			for folder in allFolders do
			(
				local folderName = filenameFromPath folder
				local subfolders = getDirectories (folder + "\\*")
				local validSubfolderFound = false

				for subfolder in subfolders do
				(
					local parts = filterString subfolder "\\"
					arrLength = parts.count
					desiredFolder = parts[arrLength]
					local folderEndings = #("1K", "2K", "3K", "4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "14K", "15K", "16K")
					if findItem folderEndings desiredFolder != 0 do
					(
						validSubfolderFound = true
						validSubfolderExists = true
						exit
					)
				)

				if validSubfolderFound do
				(
					local parts = filterString folderName "_"
					local matName = if parts.count >= 3 then (parts[1] + "_" + parts[2] + "_" + parts[3]) else (folderName)

					local mat = dotNetObject "System.Windows.Forms.ListViewItem" ""
					mat.Checked = false
					mat.SubItems.Add(matName)
					lvItems.Items.Add(mat)
					append folderPaths folder
				)
			)

			if validSubfolderExists do 
			(
				append allFolderPaths additionalFolder
			)
		)
	)

	-- Event handler for the Clean button
	on btnClean pressed do
	(
		-- Uncheck all materials in the ListView
		for matIndex = 1 to lvItems.Items.Count do
		(
			local mat = lvItems.Items.Item[matIndex - 1]
			mat.Checked = false
		)

		-- Clear the ListView items
		lvItems.Items.Clear()

		-- Reset the global lists
		folderPaths = #()
		allFolderPaths = #()
		btnBrowse.enabled = true

		-- Reset the EditText for displaying selected path
		edtSelectedPath.text = ""
		edtSelectedPath.enabled = false

		-- Disable and reset the checkboxes
		loadAO.checked = false
		loadAO.enabled = false
		loadDisp.checked = false
		loadDisp.enabled = false
		load16Nrm.checked = false
		load16Nrm.enabled = false
		load16Disp.checked = false
		load16Disp.enabled = false

		-- Disable the buttons
		btnLoadMaterials.enabled = false
		btnSelectAll.enabled = false
		btnRefresh.enabled = false
		btnAddToQueue.enabled = false
		btnClean.enabled = false

		-- Disable the dropdown
		ddlRenderer.enabled = false

		local whiteBitmap = dotNetObject "System.Drawing.Bitmap" 75 75
		
		imgDisplay.Image = whiteBitmap
		imgDisplay.SizeMode = imgDisplay.SizeMode.StretchImage
		imgDisplay.pos = [500, 500]
		lblMatPreview.text = ""
	)
)

-- Display the rollout
createdialog ReawotePBRLoader width:440 height: 595