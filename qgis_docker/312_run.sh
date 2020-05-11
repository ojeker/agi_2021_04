xhost +

docker run --rm -it --name qgis_312 \
    -v /tmp/.X11-unix:/tmp/.X11-unix  \
    -e DISPLAY=unix$DISPLAY \
    qgis/qgis:final-3_10_5 \
    /bin/bash
    
xhost -