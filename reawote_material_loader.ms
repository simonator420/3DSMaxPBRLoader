title = "Reawote PBR Loader"
renderEngines = #("Corona", "VRay")
labelWidth = 100  -- Width of the labels
fullWidthElement = 375  -- Width of the dropdown and the editText
buttonWidth = 80  -- Width of the Browse button
global folderPaths = #()

rollout ReawoteMatLoader title
(
    -- Label for Material Folder text
    label lblMaterialFolder "Material Folder" pos:[10,5] width:labelWidth

    -- Browse button
    button btnBrowse "Browse" pos:[300,5] width:buttonWidth

    -- Label for Select Renderer text
    label lblSelectRenderer "Select Renderer" pos:[10,30] width:labelWidth

    -- ComboBox for renderer selection
    dropdownlist ddlRenderer items:renderEngines pos:[300,30] width:buttonWidth enabled:false

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

	
	dotNetControl lvItems "System.Windows.Forms.ListView" pos:[5, 235] width:fullWidthElement height:150
	
	on ReawoteMatLoader open do
    (
        -- Configuration for the ListView
        lvItems.View = lvItems.View.Details
        lvItems.CheckBoxes = true
        lvItems.FullRowSelect = true
        lvItems.GridLines = true

        local checkColumnWidth = 50 -- Width for the "Check" column
		local nameColumnWidth = 320 -- Width for the "Name" column

		lvItems.columns.add("Check") checkColumnWidth
		lvItems.columns.add("Name") nameColumnWidth

    )

    -- Event handler for the Browse button
    on btnBrowse pressed do
    (
		print(RendererClass.classes)
        -- Code to handle the folder browsing and selection
        local selectedFolder = getSavePath()
		-- Clear the existing items and folderPaths
		lvItems.Items.Clear()
		folderPaths = #()
        if selectedFolder != undefined do
        (
            -- Handle the selected folder
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
			
			-- local allFiles = getFiles (selectedFolder + "\\*")
			local allFolders = getDirectories (selectedFolder + "\\*")

			-- print ("Files in " + selectedFolder + ":")
			-- for file in allFiles do
			-- (
			-- 	print ("  File: " + (filenameFromPath file))
			-- )

			print ("Folders in " + selectedFolder + ":")
			for folder in allFolders do
			(
				local folderName = filenameFromPath folder
				local parts = filterString folderName "_"
				local matName = if parts.count >= 3 then
					(parts[1] + "_" + parts[2] + "_" + parts[3])
				else
					(folderName)  -- Fallback to the original folder name if not enough parts


				print(parts)

				local mat = dotNetObject "System.Windows.Forms.ListViewItem" ""
				mat.Checked = false
				mat.SubItems.Add(matName)  -- Name of the material
				lvItems.Items.Add(mat)
				print ("  Folder: " + (filenameFromPath folder))
				append folderPaths folder
			)
        )
    )

	fn createCoronaBitmapNode filePath = (
		local bitmapNode = CoronaBitmap()
		bitmapNode.filename = filePath
		return bitmapNode
	)
	
	-- Event handler for the Load Materials button
    on btnLoadMaterials pressed do
    (
		-- Check the selected renderer
		local selectedRenderer = ddlRenderer.selected
		local slotIndex = 1 -- Start from the first slot
		local diffuseMapPath = "C:\Users\Simon Salaj\Documents\reawote_remote\ADO\ADO_0550_TALISMAN-3314-110_F03\4K\ADO_0550_TALISMAN-3314-110_COL_4K.jpg"

		local diffMap = createCoronaBitmapNode diffuseMapPath
        -- Iterate through all materials in the ListView
		for i = 1 to lvItems.Items.Count do
		(
			local mat = lvItems.Items.Item[i-1]

			-- Check if the material is selected
			if mat.Checked then
			(

				-- Switch renderer to Corona if it's selected
				if selectedRenderer == "Corona" then  -- Assuming 'Corona' is the first item in ddlRenderer
				(
					local materialName = mat.SubItems.Item[1].Text
					renderers.current = Corona()
					local materialToAssign  = CoronaPhysicalMtl ()
					materialToAssign.name = materialName
					materialToAssign.roughnessMode = 1
					materialToAssign.baseTexmap = diffMap
					showProperties diffMap
					print ("Switching to Corona Renderer for material: " + mat.SubItems.Item[1].Text)
				)

				-- Switch renderer to VRay if it's selected
				else if selectedRenderer == "VRay" then
				(
					-- TODO Make it so it takes all versions of VRAy
					renderers.current = V_Ray_6__update_2()
					print ("Switching to VRay Renderer for material: " + mat.SubItems.Item[1].Text)
				)
				else(
					print("Renderer nevybran")
				)

				if slotIndex <= meditMaterials.count then
				(
					meditMaterials[slotIndex] = materialToAssign
					format "Assigned material to Material Editor slot: %\n" slotIndex
					slotIndex += 1 -- Increment slot index for the next material
				)
				else
				(
					print "Ran out of Material Editor slots."
					break -- Exit the loop if no more slots are available
				)

				local actualFolderPath = folderPaths[i]
				local subfolders = getDirectories (actualFolderPath + "\\*")
				-- Print out all subfolders of the actual material folder
				if subfolders.count > 0 then
				(
					print ("Subfolders in " + actualFolderPath + ":")
					for subfolder in subfolders do
					(
						print ("  Subfolder: " + (filenameFromPath subfolder))
						local parts = filterString subfolder "\\"
						arrLength = parts.count
						desiredFolder = parts[arrLength]
						local folderEndings = #("1K", "2K", "3K", "4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "14K", "15K", "16K")
						print(desiredFolder)
						if findItem folderEndings desiredFolder != 0 then  -- Added check for folderEndings
						(
							local filesInSubfolder = getFiles (subfolder + "\\*")
							for file in filesInSubfolder do
							(
								print ("    File: " + file)
							)
						)
					)
				)
				else
				(
					print ("No subfolders in " + actualFolderPath)
				)
			)
		)
    )
)

-- Display the rollout
createdialog ReawoteMatLoader width:390 height: 410