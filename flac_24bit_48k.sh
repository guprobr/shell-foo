#!/bin/bash

convert_to_24bit_48khz() {
    find "$1" -type f -iname "*.flac" -print0 | xargs -0 -I {} bash -c '
        file="${1}"  # Assign the current file path to the variable "file"
        # Check if the file is already 24-bit and 48kHz
        bit_depth=$(ffmpeg -i "$file" 2>&1 | grep -oP "Stream.*Audio:.*?(\d+) Hz, \d+ channels, s(\d+)")
        sample_rate=$(ffmpeg -i "$file" 2>&1 | grep -oP "Stream.*Audio:.*?(\d+) Hz, \d+ channels, s\d+" | grep -oP "(\d+) Hz")
        if [[ $bit_depth =~ s24 && $sample_rate -eq 48000 ]]; then
            echo "*************************Skipping \"$file\" (already 24-bit, 48kHz)*************************"
        else
            # Convert to 24-bit, 48kHz with maximum quality resampling and dithering
            echo "---Converting \"$file\" to 24-bit, 48kHz"
            if ffmpeg -y -i "$file" -c:a flac -sample_fmt s32 -ar 48000 -af "aresample=resampler=soxr:precision=33:dither_method=shibata" "${file%.flac}_24bit_48khz.flac"; then
                mv -v "${file%.flac}_24bit_48khz.flac" "$file"
            else
                echo "FFMpeg failure, A B O R T i n g"; exit 1
            fi
        fi
    ' _ {}
}

# Starting point: current directory or specified directory
start_dir="${1:-.}"
convert_to_24bit_48khz "$start_dir"
