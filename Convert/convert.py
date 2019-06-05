

from keras.models import load_model
import coremltools

coreModel = coremltools.converters.keras.convert("CustomRN2-10-10.hdf5", input_names = ["image"], output_names = ["Fruit", "Family"])

coreModel.save("Fruit.mlmodel")
