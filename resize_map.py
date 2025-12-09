import json
import os

map_path = 'maps/starter/map.json'

with open(map_path, 'r') as f:
    data = json.load(f)

old_width = data['width']
old_height = data['height']
new_width = 60
new_height = 60

data['width'] = new_width
data['height'] = new_height

def resize_layer_data(layer_data, old_w, old_h, new_w, new_h, fill_value=0):
    new_data = [fill_value] * (new_w * new_h)
    for y in range(old_h):
        for x in range(old_w):
            old_idx = y * old_w + x
            new_idx = y * new_w + x
            if old_idx < len(layer_data):
                new_data[new_idx] = layer_data[old_idx]
    return new_data

def fill_layer_data(layer_data, width, height, fill_value):
    return [fill_value] * (width * height)

def add_border(layer_data, width, height, border_value):
    for y in range(height):
        for x in range(width):
            if x == 0 or x == width - 1 or y == 0 or y == height - 1:
                layer_data[y * width + x] = border_value
    return layer_data

# Find the most common tile in the 'floor' layer to use as fill
floor_tile = 0
for layer in data['layers']:
    if layer['type'] == 'tilelayer' and layer['name'] == 'floor':
        counts = {}
        for tile in layer['data']:
            if tile != 0:
                counts[tile] = counts.get(tile, 0) + 1
        if counts:
            floor_tile = max(counts, key=counts.get)
        break

print(f"Detected floor tile: {floor_tile}")

if floor_tile == 0:
    floor_tile = 1 # Fallback

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        # Resize the layer
        # For 'floor' layer, we want to fill the new space with the floor tile
        # For 'collisions' layer, we want to add borders
        # For other layers, we just resize (pad with 0)
        
        fill_val = 0
        if layer['name'] == 'floor':
            # Create a full floor
            layer['data'] = fill_layer_data([], new_width, new_height, floor_tile)
            # Optionally copy the old floor back? No, let's just make a clean big floor.
            # But the user might want to keep the old design.
            # Let's try to copy the old design and fill the rest.
            # layer['data'] = resize_layer_data(layer['data'], old_width, old_height, new_width, new_height, floor_tile)
            # Actually, the user said "aumentar area". A clean big floor is probably better for 60 people.
            # Let's stick with a clean big floor for the 'floor' layer.
            pass
        elif layer['name'] == 'collisions':
            # Clear collisions and add border
            # Find collision tile
            coll_tile = 0
            counts = {}
            for tile in layer['data']:
                if tile != 0:
                    counts[tile] = counts.get(tile, 0) + 1
            if counts:
                coll_tile = max(counts, key=counts.get)
            
            if coll_tile == 0:
                coll_tile = 443 # Fallback
            
            layer['data'] = fill_layer_data([], new_width, new_height, 0)
            layer['data'] = add_border(layer['data'], new_width, new_height, coll_tile)
        elif layer['name'] == 'start':
             # Center the start tile
             start_tile = 0
             for tile in layer['data']:
                 if tile != 0:
                     start_tile = tile
                     break
             if start_tile == 0:
                 start_tile = 444
             
             layer['data'] = fill_layer_data([], new_width, new_height, 0)
             # Place in center
             center_x = new_width // 2
             center_y = new_height // 2
             layer['data'][center_y * new_width + center_x] = start_tile
             # Add a few around it
             layer['data'][center_y * new_width + center_x + 1] = start_tile
             layer['data'][(center_y + 1) * new_width + center_x] = start_tile
             layer['data'][(center_y + 1) * new_width + center_x + 1] = start_tile

        else:
            # For other layers (furniture, etc), just resize and keep old content in top-left
            # or clear them to avoid clutter in the middle of the room
            # Clearing might be safer to avoid floating objects.
            layer['data'] = fill_layer_data([], new_width, new_height, 0)
            
        layer['width'] = new_width
        layer['height'] = new_height

with open(map_path, 'w') as f:
    json.dump(data, f, indent=1)

print("Map resized successfully.")
