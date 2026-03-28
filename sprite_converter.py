import sys
from PIL import Image

if len(sys.argv) < 2:
    print("✗ Usage: python3 sprite_converter.py <bmp_file_path>")
    sys.exit(1)

img = Image.open(sys.argv[1]).convert('1')
width, height = img.size
print(f"⏱ Found: {sys.argv[1]} ({width}x{height})")

hex_file = sys.argv[1].replace('.bmp', '.hex')
with open(hex_file, 'w') as f:
    for y in range(height):
        for x in range(width):
            f.write('1' if img.getpixel((x, y)) else '0')
        f.write('\n')

print(f"✓ Created: {hex_file} ({width}x{height})")
