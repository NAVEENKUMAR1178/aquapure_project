# Generates product images into public/images. Run: pip install pillow && python gen_images.py
import json
from PIL import Image, ImageDraw, ImageFont
col = {"Purifiers":"#1e88e5","Dispensers":"#00897b","Pumps":"#6d4c41","Filters":"#43a047","Spares":"#f4511e"}
f = ImageFont.load_default(size=26)
for p in json.load(open("public/products.json")):
    c = p["category"]; im = Image.new("RGB",(600,600),"#f5f9fc"); d = ImageDraw.Draw(im)
    d.rounded_rectangle((60,40,540,420),40,fill=col[c])
    if c in ("Purifiers","Dispensers"):
        d.rounded_rectangle((200,90,400,380),24,fill="white"); d.ellipse((270,130,330,190),fill=col[c]); d.rectangle((270,300,330,350),fill="#b3e5fc")
    elif c == "Pumps":
        d.ellipse((190,100,410,320),fill="white"); d.rectangle((270,320,330,380),fill="#ddd"); d.ellipse((260,180,340,260),fill=col[c])
    elif c == "Filters":
        d.rounded_rectangle((250,80,350,390),30,fill="white"); d.rectangle((250,200,350,230),fill="#b3e5fc")
    else:
        d.ellipse((200,100,400,300),outline="white",width=24); d.rectangle((280,300,320,390),fill="white")
    d.text((300,480),p["name"],fill="#222",anchor="mm",font=f); d.text((300,530),c,fill="#777",anchor="mm",font=f)
    im.save("public"+p["image"])
print("done")
