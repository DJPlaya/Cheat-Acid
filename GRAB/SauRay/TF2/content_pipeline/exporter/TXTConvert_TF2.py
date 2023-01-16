#!BPY

bl_info = {
    "name": "SauRay TXT Converter for TF2",
    "author": "Baktash Abdollah-Shamshir-saz",
    "version": (3, 0),
    "blender": (2, 7, 7),
    "location": "File > Export",
    "description": "Export to TXT (TF2)",
    "warning": "",
    "category": "Import-Export"}

import os
import bpy
import math
import struct
from math import *
from mathutils import *
from bpy.props import *

outData = bytearray(b'')

def write_dataline(inpTuple):
	global outData
	for i in inpTuple:
		outData += bytearray(struct.pack ('f', i))

def write_obj (fh):
	for cur_obj in bpy.data.objects:
		if cur_obj.data.name in bpy.data.meshes:

			mat_world = cur_obj.matrix_world.copy()

			for cur_poly in cur_obj.data.polygons:
				tc = len (cur_poly.vertices)

				e1i = cur_poly.vertices[0]
				e2i = cur_poly.vertices[1]
				e3i = cur_poly.vertices[2]
				if tc == 4:
					e4i = cur_poly.vertices[3]
					
				e1 = 100.0 * mat_world * cur_obj.data.vertices[e1i].co
				e2 = 100.0 * mat_world * cur_obj.data.vertices[e2i].co
				e3 = 100.0 * mat_world * cur_obj.data.vertices[e3i].co
				write_dataline ((e1.x, e1.y, e1.z, e2.x, e2.y, e2.z, e3.x, e3.y, e3.z))
				if tc == 4:
					e4 = 100.0 * mat_world * cur_obj.data.vertices[e4i].co
					write_dataline ((e3.x, e3.y, e3.z, e4.x, e4.y, e4.z, e1.x, e1.y, e1.z))


	fh.write(outData)

	print ("Done with export!")

class _TXTConverter(bpy.types.Operator):
	bl_idname = "export.txt"
	bl_label = "Export TXT (TF2)"

	filepath = StringProperty(subtype='FILE_PATH')

	def execute(self, context):
		global outData
		FilePath = bpy.path.ensure_ext(self.filepath, ".txt")

		outData = bytearray(b'')
		fh = open(FilePath, "wb")
		write_obj (fh)
		fh.close ()

		return {"FINISHED"}

	def invoke(self, context, event):
		WindowManager = context.window_manager
		WindowManager.fileselect_add(self)
		return {"RUNNING_MODAL"}

def menu_func(self, context):
	self.layout.operator(_TXTConverter.bl_idname, text="TF2 TXT (.TXT)")

def register():
	bpy.utils.register_module(__name__)
	bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
	bpy.utils.unregister_module(__name__)
	bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
	register()