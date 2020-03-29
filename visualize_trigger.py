from PIL import Image

im1 = Image.open('/nfshomes/arjgpt27/Experiments/Hidden-Trigger-Backdoor-Attacks_cifar/data/triggers/trigger_10.png')
# im1.show(im1)
im1 = im1.resize((12, 12))
im1.save("./scaled.png")
