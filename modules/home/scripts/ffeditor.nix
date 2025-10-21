{ pkgs }:
pkgs.writeShellScriptBin "ffeditor" ''
  # FFEditor
  # Author: Zaney
  # Date: May 17th, 2025

  #!/usr/bin/env bash

  # Check for input file
  if [ -n "$1" ]; then
    infile="$1"
  elif [ ! -t 0 ]; then
    infile=$(cat)
  else
    echo "Usage: $0 <video-file> or via stdin" >&2
    exit 1
  fi

  [ ! -f "$infile" ] && echo "Error: '$infile' not found." >&2 && exit 1

  # Check for required dependencies
  missing=""

  if ! command -v ffmpeg >/dev/null 2>&1; then
    missing="${missing}ffmpeg "
  fi

  if ! command -v sox >/dev/null 2>&1; then
    missing="${missing}sox "
  fi

  if [ -n "$missing" ]; then
    echo "Error: Missing required command(s): $missing"
    echo "Please install the missing dependencies and try again."
    exit 1
  fi

  # Detect audio channel layout
  audio_layout=$(ffprobe -v error -select_streams a:0 \
    -show_entries stream=channel_layout \
    -of default=noprint_wrappers=1:nokey=1 "$infile")

  echo "Output filename (without extension):"
  read outbase

  echo "Desired output file extension (e.g., mp4, mkv):"
  read outext

  # Strip extension from outbase if it exists
  outbase=$(printf "%s" "$outbase" | sed "s/\.[^.]*\$//")
  outfile="${outbase}.${outext}"

  afilters=""
  vfilters=""
  acodec="aac"
  vcodec="libx264"
  abitrate="192k"
  crf="18"
  preset="fast"
  basetmpdir="/tmp/ffeditor"
  audioraw="$basetmpdir/raw.flac"
  audioclean="$basetmpdir/clean.flac"
  audioprofile="$basetmpdir/noise.prof"
  tmpvideo="$basetmpdir/$(basename "$infile")"
  tmpclippedvideo="$basetmpdir/clipped_$(basename "$infile")"

  mkdir $basetmpdir

  convert_to_seconds() {
      case "$1" in
          *:*)  # Format MM:SS
              IFS=":" read -r m s <<EOF
  $1
  EOF
              echo $((10#$m * 60 + 10#$s))
              ;;
          *) echo "$1" ;;
      esac
  }

  echo "Remove background noise or hum/hiss? (y/n):"
  read ans
  case "$ans" in
    [yY] | [yY][eE][sS])
      echo "Time to start getting noise profile in seconds?"
      echo "(e.g, 0) for the beginning of the video"
      read start_prof
      echo "Time to end getting noise profile in seconds?"
      echo "(e.g, 0.5) for half a second into the video"
      read end_prof
      echo "Extracting the audio from the video..."
      ffmpeg -loglevel 16 -i $infile -vn -acodec flac $audioraw || {
      echo "Error: ffmpeg failed to extract audio." >&2
      rm -rf $basetmpdir && exit 1
      }
      echo "Getting the audio profile..."
      sox $audioraw -n trim $start_prof $end_prof noiseprof $audioprofile || {
      echo "Error: sox failed to get an audio profile." >&2
      rm -rf $basetmpdir && exit 1
      }
      echo "Applying noise reduction..."
      sox $audioraw $audioclean noisered $audioprofile 0.21 || {
      echo "Error: sox failed to apply noise reduction." >&2
      rm -rf $basetmpdir && exit 1
      }
      echo "Replace noise reduced audio with the original..."
      ffmpeg -loglevel 16 -i $infile -i $audioclean -map 0:v -map 1:a -c:v copy -c:a aac $tmpvideo || {
      echo "Error: ffmpeg failed to combine noise reduced audio and video." >&2
      rm -rf $basetmpdir && exit 1
      }
      infile=$tmpvideo
      echo "Successfully removed background noise!"
      ;;
  esac

  echo "Trim beginning of video? (y/n):"
  read ans
  case "$ans" in
    [yY] | [yY][eE][sS])
      echo "Enter the start time in seconds (e.g., 5.3):"
      read start_time
      # Basic validation
      case "$start_time" in
''| * [ !0-9. ] * )
  echo "Invalid time. Skipping trim."
  start_time=""
;;
esac
esac

cut_ranges=""
while :; do
echo "Do you want to cut out a clip from the video? (y/n):"
read cut_answer
case "$cut_answer" in
[Yy]*)
echo "Enter start time of the clip to cut (in seconds or mm:ss):"
read cut_start
echo "Enter end time of the clip to cut (in seconds or mm:ss):"
read cut_end

# Normalize mm:ss to seconds
cut_start_sec=$(convert_to_seconds "$cut_start")
cut_end_sec=$(convert_to_seconds "$cut_end")

if [ -n "$cut_start_sec" ] && [ -n "$cut_end_sec" ]; then
cut_ranges="$cut_ranges$cut_start_sec:$cut_end_sec
"
else
echo "Invalid input. Skipping this range."
fi
;;
[Nn]*)
break
;;
*)
echo "Please enter y or n."
;;
esac
done

if [ -n "$cut_ranges" ]; then
echo "Processing cuts..."
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$infile")
duration=${duration%.*}
echo "Video's duration: $duration seconds."

# Extract the first cut's start time (first line's start value)
first_cut_start=$(echo "$cut_ranges" | awk -F: 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/' | sort -n | head -n1 | cut -d: -f1)
echo "Time of first cut: $first_cut_start"

# Sort and merge ranges to cut
# Also remove and clean empty lines
echo "$cut_ranges" | awk -F: 'NF==2 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ && $1 < $2' | sort -n > "$basetmpdir/cuts.txt"

keep_index=0
prev_end=0
concat_list=""
while IFS=":" read -r start end; do
if [ "$start" -gt "$prev_end" ]; then
out="$basetmpdir/part_$keep_index.mp4"
echo "Creating segment: $out from $prev_end to $start"
ffmpeg -loglevel 16 -y -i "$infile" -ss "$prev_end" -to "$start" -c:v libx264 -preset veryfast -crf 18 -c:a aac "$out" || {
echo "Error: ffmpeg failed to create a segment." >&2
rm -rf $basetmpdir && exit 1
}
concat_list="${concat_list}file '$out'
"
keep_index=$((keep_index + 1))
fi
prev_end=$end
done < $basetmpdir/cuts.txt

# Last segment (after final cut)
if [ "$prev_end" -lt "$duration" ]; then
out="$basetmpdir/part_$keep_index.mp4"
echo "Creating segment: $out from $prev_end to $duration"
ffmpeg -loglevel 24 -y -i "$infile" -ss "$prev_end" -to "$duration" -c:v libx264 -preset veryfast -crf 18 -c:a aac "$out" || {
echo "Error: ffmpeg failed to create the last segment." >&2
rm -rf $basetmpdir && exit 1
}
concat_list="${concat_list}file '$out'
"
fi

echo "$concat_list" > $basetmpdir/parts.txt
ffmpeg -loglevel 16 -y -f concat -safe 0 -i $basetmpdir/parts.txt -c copy "$tmpclippedvideo" || {
echo "Error: ffmpeg failed to rejoin video clips." >&2
rm -rf $basetmpdir && exit 1
}
infile=$tmpclippedvideo

# Clean up
rm -f $basetmpdir/part_*.mp4 $basetmpdir/parts.txt $basetmpdir/cuts.txt
echo "Finished cutting and rejoining the video."
fi

echo "Detected audio layout: ${audio_layout:-unknown}"

case "$audio_layout" in
mono)
echo "Convert mono to stereo? [y/n]"
read ans
case "$ans" in
[yY] | [yY][eE][sS])
afilters="${afilters:+$afilters,}aformat=channel_layouts=stereo"
;;
esac
;;
stereo)
echo "Convert stereo to mono? [y/n]"
read ans
case "$ans" in
[yY] | [yY][eE][sS])
afilters="${afilters:+$afilters,}aformat=channel_layouts=mono"
;;
esac
;;
*)
echo "Warning: Could not determine audio layout. Skipping channel conversion options."
;;
esac

echo "Apply loudnorm normalization? [y/n]"
read ans
case "$ans" in
[yY] | [yY][eE][sS])
afilters="${afilters:+$afilters,}loudnorm"
;;
esac

echo "Apply volume gain (e.g., 4dB)? Leave blank for none:"
read gain
case "$gain" in
# Ensures the proper format (e.g, 4dB not 4Db or 4DB)
*[dD][bB]) gain="$(printf '%s' "$gain" | sed 's/[dD][bB]$/dB/')" ;;
"") ;;                  # Skip if nothing
*) gain="${gain}dB" ;;  # If just number, add correct format
esac
[ -n "$gain" ] && afilters="${afilters:+$afilters,}volume=${gain}"

echo "Apply fade-in from black? [y/n]"
read ans
case "$ans" in
[yY] | [yY][eE][sS])
echo "Fade duration in seconds (e.g., 1):"
read fsec
vfilters="${vfilters:+$vfilters,}fade=t=in:st=0:d=${fsec}"
;;
esac

# Build filter args
[ -n "$vfilters" ] && vfilter_arg="-vf $vfilters"
[ -n "$afilters" ] && afilter_arg="-af $afilters"
[ -n "$start_time" ] && input_trim="-ss $start_time"

# Run ffmpeg
set -f # disable globbing
cmd="ffmpeg -loglevel 16 $input_trim -i \"$infile\" ${vfilter_arg:+$vfilter_arg} -c:v $vcodec -crf $crf -preset $preset ${afilter_arg:+$afilter_arg} -c:a $acodec -b:a $abitrate \"$outfile\""
echo "Running:"
echo "$cmd"
eval "$cmd" || {
echo "Error: ffmpeg failed to render final video." >&2
rm -rf $basetmpdir && exit 1
}

# Remove tmp directory
if [ -d "$basetmpdir" ]; then
rm -r "$basetmpdir" || {
echo "Failed to remove folder: $basetmpdir" >&2
exit 1
}
fi


''



