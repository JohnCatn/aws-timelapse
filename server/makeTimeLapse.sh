#################
# Script to perform teh following
# Get image files from S3
# compress the files and upload back to S3 to save storage
# Delete raw images from S3
# Collate files into a single folder
# Process all images in a folder into a timelapse
# Add latest timelapse to existing timelapse from S3
# Post the timelapse to S3
# Write an html file to S3 to state updated date
###################

# get the latest files from S3
aws s3 cp s3://gardencam /pics --recursive --exclude "*.tar.gz"

# tar the images
cd /pics
DATE=$(date +"%Y%m%d%H%M")
tar -pczf $DATE.tar.gz /pics --exclude='/pics/backup'


# Upload the tar to s3
aws s3 cp $DATE.tar.gz s3://gardencam/backup/$DATE.tar.gz

# remove the images from s3 (risk we may lost a single image)
aws s3 rm s3://gardencam/ --recursive --exclude "*.tar.gz"

#Create the HTML File
sh /home/ec2-user/aws-timelapse/server/makeIndexFile.sh > /pics/index.html

# now move all images into a single directory
cp `find . -name "*.jpg"` /pics

# create the latest timelapse
ffmpeg -i '%*.jpg' -r 30 -q:v 2 $DATE.mp4 -y

# get the last timelapse from S3
aws s3 cp  s3://johncat/gardencam/timelapse.mp4 /pics/timelapse.mp4 --region eu-west-2
mv timelapse.mp4 baseline.mp4

# join the timelapses to create a full one
ffmpeg -i baseline.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts intermediate1.ts
ffmpeg -i $DATE.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts intermediate2.ts
ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc timelapse.mp4

# copy the timelapse to S3
aws s3 cp /pics/timelapse.mp4 s3://johncat/gardencam/timelapse.mp4 --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers --region eu-west-2
aws s3 cp /pics/index.html s3://johncat/gardencam/index.html --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers --region eu-west-2

#Clean Up
rm -rf *

