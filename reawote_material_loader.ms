title = "Reawote PBR Loader"
renderEngines = #("Corona", "VRay")
labelWidth = 100  -- Width of the labels
fullWidthElement = 375  -- Width of the dropdown and the editText
buttonWidth = 80  -- Width of the Browse button

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
        -- Code to handle the folder browsing and selection
        local selectedFolder = getSavePath()
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
				local item = dotNetObject "System.Windows.Forms.ListViewItem" ""
				item.Checked = false
				item.SubItems.Add(filenameFromPath folder)  -- Name of the material
				lvItems.Items.Add(item)
				print ("  Folder: " + (filenameFromPath folder))
			)
        )
    )
	
	-- Event handler for the Load Materials button
    on btnLoadMaterials pressed do
    (
        -- Code to handle material loading
        -- Add your logic here
    )
)

-- Display the rollout
createdialog ReawoteMatLoader width:390 height: 410