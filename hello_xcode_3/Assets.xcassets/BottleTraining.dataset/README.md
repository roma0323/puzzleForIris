# Bottle Detection Training Images

## Image Requirements

1. **Quantity**: Collect at least 30-50 different bottle images
2. **Format**:
   - JPG or PNG format
   - Resolution: At least 640x640 pixels
   - File size: Less than 5MB per image

## Image Capturing Guidelines

1. **Angles**:

   - Front view
   - Side view (both left and right)
   - 45-degree angles
   - Top view
   - Bottom view

2. **Lighting Conditions**:

   - Natural daylight
   - Indoor lighting
   - Low light conditions
   - Bright direct light

3. **Backgrounds**:

   - Plain backgrounds
   - Natural environments
   - Indoor settings
   - Cluttered backgrounds

4. **Bottle Types**:

   - Different sizes
   - Different colors
   - Different materials (plastic, glass, metal)
   - Different contents (empty, filled)

5. **Distance**:
   - Close-up (1-2 feet)
   - Medium distance (3-4 feet)
   - Far distance (5-6 feet)

## File Naming Convention

Name your images using the following format:
`bottle_[type]_[angle]_[lighting]_[number].jpg`

Example:
`bottle_plastic_front_natural_001.jpg`

## Annotation Requirements

Once you have collected the images, we'll need to annotate them with bounding boxes using Create ML. Each annotation should:

1. Tightly encompass the entire bottle
2. Include the cap/lid
3. Be consistent across all images

## Next Steps

1. Collect images following these guidelines
2. Place all images in this dataset folder
3. We'll then use Create ML to train the object detection model
