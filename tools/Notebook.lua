local NotebookTool = {}

-- Tools for use in developing TTS mods

-- Record positions for all objects with the pos_find tag
function NotebookTool.pos_find(origin)
  for _,obj in ipairs(getObjectsWithTag("pos_find")) do
    NotebookTool.obj_coord(obj,origin)
  end
end

function NotebookTool.obj_coord(object,origin)

  local accuracy = 1000

  local new_text = "\n"..object.getName()
  local pos = object.getPosition()
  local rot = object.getRotation()
  local scale = object.getScale()

  local new_text = origin and new_text.." ("..origin.getName()..")" or new_text
  local pos = origin and origin.positionToLocal(pos) or pos

  local pos_x = math.floor(pos[1]*accuracy)/accuracy
  local pos_y = math.floor(pos[2]*accuracy)/accuracy
  local pos_z = math.floor(pos[3]*accuracy)/accuracy

  local rot_x = math.floor(rot[1]*accuracy)/accuracy
  local rot_y = math.floor(rot[2]*accuracy)/accuracy
  local rot_z = math.floor(rot[3]*accuracy)/accuracy

  local scale_x = math.floor(scale[1]*accuracy)/accuracy
  local scale_y = math.floor(scale[2]*accuracy)/accuracy
  local scale_z = math.floor(scale[3]*accuracy)/accuracy

  new_text = new_text.." = { "
  new_text = new_text.."pos = {"..pos_x..","..pos_y..","..pos_z.."}, "
  --new_text = new_text.."rot = {"..rot_x..","..rot_y..","..rot_z.."}, "
  --new_text = new_text.."scale = {"..scale_x..","..scale_y..","..scale_z.."} " 
  new_text = new_text.."}"

  NotebookTool.note(new_text)

end

function NotebookTool.decals(object)
  local new_text = ""
  for _,i in pairs(object.getDecals()) do
    new_text = new_text.."\n"..object.getName().." - "..i.name.." ( "..i.url.." ) "
  end
  NotebookTool.RecordToNotes(new_text)
end

function NotebookTool.note(new_text)
  local old_text = Notes.getNotebookTabs()[1].body
  --old_text = not old_text and ""
  Notes.editNotebookTab({index=0,body=old_text..new_text})
end

return NotebookTool