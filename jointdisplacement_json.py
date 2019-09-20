#Read the json file generated by the openpose and convert it to the format 
#suitable for the RNN-LSTM network. This conversion takes only the first object 
#detected
import json
import numpy as np
from matplotlib import pyplot as plt
from numpy import array
from numpy import reshape
from pprint import pprint
import glob
from matplotlib.animation import FuncAnimation
import simplejson
from matplotlib import pyplot as plt
import pandas as pd
import math



#open('D:/ParamServerContents/KTH_TestTrain/boxing/Test/keypoints/person02_boxing_d1_uncomp_000000000000_keypoints.json').read())

Data_Set_Path = './datasets/UTKinect/'
NJOINTS = 20

#There are two action classes currently being used
action_classes = {'walk':1, 'sit down':2, 'stand up':3, 'pick up':4, 'carry':5, 'throw':6, 'push':7, 'pull':8, 'wave hands':9, 'clap hands':10}
frameCount = {'walk':0, 'sitDown':0, 'standUp':0, 'pickUp':0, 'carry':0, 'throw':0, 'push':0, 'pull':0, 'waveHands':0, 'clapHands':0}


data= np.empty((NJOINTS, 3))
flist = []


for key in action_classes:
	filelist = sorted(glob.glob('./sampledataset/' + key + '/*.json'))


	for filename in filelist:
		print 'Procesing file', filename
		outfile = filename[:-5] +'_dis.'+ 'txt'

		#For each of the avi file there is corresponding 
		jsonfile = json.load(open(filename))

		#get the number of frames in avi from json
		nframes = jsonfile['numberofframes']
		
		#For each of the frame in a video file, the openpose creates 
		#json file containing the skeleton points (x,y, confidencemap)
		#Read all those json files corresponding to one of the avi files
		
		fileFrameName =['./sampledataset/' + key + '/keypoints/'+ jsonfile['FileName'].encode("utf-8") + "_%012d_keypoints.json" % i for i in range(nframes)]
		
		frameNum = 0  
		X_prevdata=[];
		directionList=[]
		orientation_magnitude = np.zeros((2,NJOINTS,nframes),dtype=np.float64)
		for f in fileFrameName:
			#ret, frame = cap.read()
			

			jsonfile = json.load(open(f))
			people_objects=jsonfile["people"]
			if(len(people_objects) > 1):
 				people_objects = [people_objects[0]]
			if(len(people_objects) == 0):
 				continue#print "No objects found:"
 			objects = people_objects[0]
 			# 		for objects in people_objects:
			data = array(objects["pose_keypoints_2d"])
 		 	#split the coordinates and the confidence map
	 	 	#convert the 1-D to NX3 matrix
	 	 	data = data.reshape((data.shape[0]/3, 3))
	 	 	#X_data is the skeleton (x,y) coordinate the third dimension
	 	 	#is the frame number
	 	 	X_data = data[:,:2]
	 	 	#Extract only the third column
	 	 	confidencemap =data[:,2:]
	 	 		
	 	 	#third dimesion is the frame number 
	 	 	Zdim = np.ones((NJOINTS,1))
	 	 	X_data = np.array(X_data)
	 	 	X_data = np.append(X_data, Zdim,axis=1)
	 	 	orientation=np.zeros((NJOINTS,1))
	 	 	magnitude = np.zeros((NJOINTS,1))
			
	 	 	if(len(X_prevdata)!=0):
	 	 		displacement = X_prevdata - X_data;
	 	 		for p in range(0,displacement.shape[0]):
	 	 			orientation_magnitude[0][p][frameNum] = np.linalg.norm(displacement[p])
	 	 			orientation_magnitude[1][p][frameNum] = math.atan2(displacement[p][1],displacement[p][0]) *180/np.pi

	 	 	X_prevdata =X_data;
	 	 	frameNum = frameNum + 1

	 	 	
	 	with file(outfile, 'w') as ofile:
	 		for slice2d in orientation_magnitude:
	 			np.savetxt(ofile, np.array(slice2d), delimiter=",")
	 			#ofile.write('# New slice\n')

	 	
		
	 	#plt.imshow(frameangleMatrix, cmap="gray")
		#plt.show()

	 	 		



