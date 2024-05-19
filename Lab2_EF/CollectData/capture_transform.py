# -*- coding: utf-8 -*-
"""
Created on Fri Apr 28 19:11:47 2023

@author: ekolo
"""

import cv2 
import numpy as np
import matplotlib.pyplot as plt



#%%

def correct_perspective(img):
    # specify desired output size 
    width = 1000    
    height = 500
    
    # specify conjugate x,y coordinates (not y,x)
    
    top_left = [1508,985]
    top_right = [2257, 958]
    bottom_right = [2269, 1416]
    bottom_left = [1513, 1415]
    input = np.float32([top_left, top_right, bottom_right, bottom_left])
    
    output = np.float32([[0,0], [width-1,0], [width-1,height-1], [0,height-1]])
    
    # compute perspective matrix
    matrix = cv2.getPerspectiveTransform(input,output)
    
    # do perspective transformation setting area outside input to black
    imgOutput = cv2.warpPerspective(img, matrix, 
                                    (width,height), cv2.INTER_LINEAR, 
                                    borderMode=cv2.BORDER_CONSTANT, borderValue=(0,0,0))
    return imgOutput
#%%    

cam = cv2.VideoCapture(1) # this is the magic!

print(f"Frame default resolution: ( {cam.get(cv2.CAP_PROP_FRAME_WIDTH)} {cam.get(cv2.CAP_PROP_FRAME_HEIGHT)}")
cam.set(cv2.CAP_PROP_FRAME_WIDTH, 3840)
cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 2160)



#cap.set(cv2.CAP_PROP_FRAME_WIDTH, 600)
#cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

cv2.namedWindow("test")

img_counter = 300
records = ''

while True:
    ret, frame = cam.read()
    if not ret:
        print("failed to grab frame")
        break
    cv2.imshow("test", frame)

    k = cv2.waitKey(1)
    if k%256 == 27:
        # ESC pressed
        print("Escape hit, closing...")
        break
    elif k%256 == 32:
        # SPACE pressed
        image = correct_perspective(frame)

        Ua, Up, I = list(map(np.float32, input('Enter Ua Up I:').split(' ')))
        
        img_name = f'{img_counter:03d} Ua {Ua:.1f} Up {Up:.1f} I {I:.3f}.png'
        cv2.imwrite(img_name, image)
        cv2.imwrite('frame.png', frame)
        print(f"{img_name} written!")      
        records += f'{img_counter}, {Ua}, {Up}, {I}\n' 
        img_counter += 1

with open('experiments.csv', 'a') as file:
    file.write(records)
print(f'experiments.csv written with {img_counter} records')
cam.release()

cv2.destroyAllWindows()

  
#%%
#%% Perspective transform

# read input
fname = 'opencv_frame_0.png'
img = cv2.imread(fname)

# specify desired output size 
width = 1000    
height = 500

# specify conjugate x,y coordinates (not y,x)

top_left = [1490,1004]
top_right = [2194, 982]
bottom_right = [2200, 1410]
bottom_left = [1495, 1410]
input = np.float32([top_left, top_right, bottom_right, bottom_left])

output = np.float32([[0,0], [width-1,0], [width-1,height-1], [0,height-1]])

# compute perspective matrix
matrix = cv2.getPerspectiveTransform(input,output)

print(matrix.shape)
print(matrix)

# do perspective transformation setting area outside input to black
imgOutput = cv2.warpPerspective(img, matrix, (width,height), cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=(0,0,0))
print(imgOutput.shape)

# save the warped output
cv2.imwrite("warped.jpg", imgOutput)

# show the result
cv2.imshow("result", imgOutput)
cv2.waitKey(0)
cv2.destroyAllWindows()

