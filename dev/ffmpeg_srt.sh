VCODEC=libx264
COLOR=bt709
FPS=30

video_size="1280x720"
# Testsrc
INPUT="-f lavfi -re -i testsrc=s=$video_size:r=$FPS"
#INPUT="-f lavfi -i smptehdbars=rate=$FPS:size=$video_size -f lavfi -i sine=frequency=1000:sample_rate=48000"

PUT_TIMESTAMP="${put_timestamp:-0}"
FONT_PATH="${font_path:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}"
# timestamp format: T -> time N->millisecond
# use millisecond with caution, it may not work all the time!
TS_FORMAT="${ts_format:-%T.%3N}"
# construct video filter
VIDEO_FILTER="drawtext=fontfile='$FONT_PATH':fontsize=80:box=1:boxborderw=4:boxcolor=black@0.6:fontcolor=white:x=32:y=H-80:text='T0\: %{localtime\:$TS_FORMAT}'[time];"


res="1280x720"
bitrate="3000000"
bufsize="6M"

#gop_size=30
gop_size=$FPS

ffmpeg -hide_banner -probesize 10M $INPUT -fflags nobuffer -pix_fmt yuv420p \
	    -c:v $VCODEC \
		-s:v:0 ${res} -b:v:0 ${bitrate} -minrate ${bitrate} -maxrate ${bitrate} -bufsize ${bufsize} \
		-vf "$VIDEO_FILTER" \
		-g:v $gop_size -keyint_min:v $gop_size -sc_threshold:v 0 -streaming 1 -tune zerolatency \
		-color_primaries ${COLOR} -color_trc ${COLOR} -colorspace ${COLOR} \
		-f mpegts "srt://63.176.244.153:9000"