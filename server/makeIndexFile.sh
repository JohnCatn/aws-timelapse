#!/bin/bash

# make_page - A script to produce an HTML file

cat <<- _EOF_
<html>
<head></head>
<body>
<h1>AWS Garden Cam</h1>
<p>This timelapse is generated automatically in teh following way:
<ul><li>RPi collects photos and stores on S3
<li>AWS lightsail instance generates timelapse from S3
</ul>
<p>The timelapse was last generated at <strong>$( TZ=GMT date +"%x %r %Z")</strong></p>
</p>
<div>
<video width="720" height="480" controls>
  <source src="timelapse.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>
</div>
</body>
</html>
_EOF_
