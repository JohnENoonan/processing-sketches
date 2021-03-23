import subprocess
import os, sys
import argparse

"""
CLI to create quick h264 renders from frames
"""

def render(infile, outfile, framerate):
	subprocess.call(['ffmpeg', '-framerate', str(framerate), '-i', infile, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', outfile])

def get_input_format(input_folder):
	files = sorted(os.listdir(input_folder))
	first = files[0]
	for i, char in enumerate(first):
		if char.isdigit():
			break
	text = first[:i]
	digits = first[i:].split('.')
	ext = digits[1]
	digits = digits[0]
	digits = [int(s) for s in digits if s.isdigit()]
	num_digits = len(digits)
	return "{}%0{}d.{}".format(text, num_digits, ext)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("image_folder", help="Folder with rendered images")
	parser.add_argument("out", help="Output file")
	parser.add_argument('--framerate', default=60, help="Framerate to render at")
	args = parser.parse_args()

	try:
		img_format = get_input_format(args.image_folder)
	except (NotADirectoryError, FileNotFoundError) as e:
		parser.error('image_folder is not a folder. Make sure the path is correct')
		sys.exit(1)
	render(	os.path.join(os.path.dirname(args.image_folder), img_format), 
			args.out,
			args.framerate)

if __name__ == '__main__':
	main()