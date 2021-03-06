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
import cv2
import re
import os
import math

Data_Set_Path = './datasets/MSRAction3DSkeleton/'
subpath ='MSRAction3DSkeleton/'
NJOINTS = 20

#There are two action classes currently being used

actionClasses= {'high arm wave':1,'horizontal arm wave':2,'hammer':3,\
 'hand catch':4, 'forward punch':5,'high throw':6,'draw X':7,'draw tick':8,\
 'draw circle':9,'hand clap':10,'two hand wave':11,'side boxing':12,'bend':13,\
 'forward kick':14, 'side kick':15,'jogging':16,'tennis swing':17,\
 'tennis serve':18,'golf swing':19,'pickup and throw':20}
 
frameCount = {'walk':0, 'sitDown':0, 'standUp':0, 'pickUp':0, 'carry':0, 'throw':0, 'push':0, 'pull':0, 'waveHands':0, 'clapHands':0}

# #body_25 model has 25 Keypoints in the (x,y, confidencemap) format 25 X 3
data= np.empty((NJOINTS, 3))
flist = []


flist = os.listdir(Data_Set_Path + subpath)
for fileName in flist:
		X_data = []
		fullfileName = Data_Set_Path + subpath + fileName
		totalrows = 0 
		with open(fullfileName,'r') as fp:
			while True:
		 		strdata =  fp.readline()
		 		if not strdata:
					#input("Press enter..")
		 			break
		 		strdata=strdata.strip()
		 		linedata=" ".join(strdata.split())
		 		linedata = linedata.split(' ')
		 		data = [float(i) for i in linedata]

		 	# 	#Swap the y and Z coordinates
		 	# 	temp = data[1]
				# data [1] = data[2]
				# data[2] =temp



				data = data[:2]  #consider only (x,y)
				X_data.append(data)
	   			totalrows +=1

	   	Zdim = np.ones((totalrows,1)) #np.array(data[:,2:]);
	   	frameCount = totalrows / NJOINTS  #there are 20 rows per frame
	   	X_data = np.array(X_data) 
	 	X_data = np.append(X_data, Zdim,axis=1)
	   	print X_data.shape
	   	print frameCount
	   	
	   	orientation_magnitude = np.zeros((2,NJOINTS,frameCount),dtype=np.float64)

	   	outfile = Data_Set_Path + 'processed/' + fileName[:-4] + '_dis.txt'
	 	# jsondata ={}
		# jsondata['FileName']= fileName
	 	# jsondata['numberofframes'] = frameCount
	 	# jsonoutfilename = outfile[:-3]+'json'
	 	# with open(jsonoutfilename, 'w') as f:
	 	# 	json.dump(jsondata, f)
	 	X_prevdata = []
	 	X_framedata = []

	 	for i in range(0,frameCount):
	 		start_loc = NJOINTS*i
	 		X_framedata = X_data[start_loc : start_loc+NJOINTS, :]
	 		
	 		if(len(X_prevdata)!=0):
	 	 		displacement = X_prevdata - X_framedata;
	 	 		for p in range(0,displacement.shape[0]):
	 	 			orientation_magnitude[0][p][i] = np.linalg.norm(displacement[p])
	 	 			orientation_magnitude[1][p][i] = math.atan2(displacement[p][1],displacement[p][0]) *180/np.pi
	 	 	X_prevdata =X_framedata;
	 	 	
		with file(outfile, 'w') as ofile:
	 		for slice2d in orientation_magnitude:
	 			np.savetxt(ofile, np.array(slice2d), delimiter=",")
