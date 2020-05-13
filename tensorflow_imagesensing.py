import tensorflow.keras
from PIL import Image, ImageOps
import numpy as np

# Disable scientific notation for clarity
np.set_printoptions(suppress=True)

# Load the model
model = tensorflow.keras.models.load_model('keras_model.h5',compile=False)

# Create the array of the right shape to feed into the keras model
# The 'length' or number of images you can put into the array is
# determined by the first position in the shape tuple, in this case 1.
data = np.ndarray(shape=(1, 224, 224, 3), dtype=np.float32)

# Replace this with the path to your image
image = Image.open('img.jpg')

#resize the image to a 224x224 with the same strategy as in TM2:
#resizing the image to be at least 224x224 and then cropping from the center
size = (224, 224)
image = ImageOps.fit(image, size, Image.ANTIALIAS)

#turn the image into a numpy array
image_array = np.asarray(image)

# display the resized image
image.show()

# Normalize the image
normalized_image_array = (image_array.astype(np.float32) / 127.0) - 1

# Load the image into the array
data[0] = normalized_image_array

# run the inference
prediction = model.predict(data)
max_number = max(prediction[0][0:1])
if max_number == prediction[0][0]:
    print("the number is 1234")
elif max_number == prediction[0][1]:
    print("the number is undefined")
#elif max_number == prediction[0][2]:
 #   print("the number is 3")
#elif max_number == prediction[0][3]:
#    print("the number is 4")
#elif max_number == prediction[0][4]:
 #   print("the number is 5")
#elif max_number == prediction[0][5]:
 #   print("the number is 6")
#elif max_number == prediction[0][6]:
 #   print("the number is 7")
#elif max_number == prediction[0][7]:
 #   print("the number is 8")
#elif max_number == prediction[0][8]:
 #   print("the number is 9")
#elif max_number == prediction[0][9]:
#    print("the number is 0")
