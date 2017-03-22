#!/usr/bin/env python

import os, sys
import boto3
from subprocess import call

import PIL
from PIL import ImageFont
from PIL import Image
from PIL import ImageDraw

font = ImageFont.truetype("/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",25)

#   set up the connection
import picamera
import datetime
timestamp=datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
hour=datetime.datetime.now().strftime("%H")
minute=datetime.datetime.now().strftime("%M")
camera = picamera.PiCamera()
try:
    camera.start_preview()
    camera.capture(timestamp+".jpg")
except:
    pass
finally:
    camera.close()
# Add meta data to image
imageFile = timestamp+".jpg"
im1=Image.open(imageFile)
draw = ImageDraw.Draw(im1)
draw.text((0, 0),datetime.datetime.now().strftime("%Y-%m-%d"),(255,255,0),font=font)
draw = ImageDraw.Draw(im1)
im1.save(timestamp+".jpg")
# Let's use Amazon S3
s3 = boto3.resource('s3',aws_access_key_id='<ACCESS_KEY>',
         aws_secret_access_key='<SECRET_ACCESS_KEY')
# Upload a new file
data = open(timestamp+'.jpg', 'rb')
s3.Bucket('gardencam').put_object(Key=hour+'/'+minute+'/'+timestamp+'.jpg', Body=data)
# remove the file from the  server
os.remove(timestamp+'.jpg')


