import plotly.graph_objects as go
import pandas as pd

# Data from the provided comparison
comparison_data = [
    {"feature": "Target Support", "original": "Single Domain Only", "upgraded": "Single + Multi-Target"},
    {"feature": "Banner Style", "original": "Simple Text Banner", "upgraded": "Professional ASCII Art"},
    {"feature": "Sudomy Handling", "original": "Basic Single Domain", "upgraded": "Loop for Multi-Target"},
    {"feature": "Tool Commands", "original": "Generic Implementation", "upgraded": "User-Specified Commands"},
    {"feature": "Reporting", "original": "Basic Summary", "upgraded": "Per-Target Breakdown"},
    {"feature": "Author Credit", "original": "Not Included", "upgraded": "Coded by: Youssef Hamdi"},
    {"feature": "Input Validation", "original": "Basic", "upgraded": "File/Domain Detection"},
    {"feature": "Error Handling", "original": "Standard", "upgraded": "Enhanced Multi-Target"}
]

# Extract data for the table
features = [item["feature"] for item in comparison_data]
original_values = [item["original"] for item in comparison_data]
upgraded_values = [item["upgraded"] for item in comparison_data]

# Abbreviate longer text to meet 15 character limit
features_short = []
original_short = []
upgraded_short = []

for feature in features:
    if len(feature) > 15:
        if feature == "Target Support":
            features_short.append("Target Support")
        elif feature == "Banner Style":
            features_short.append("Banner Style")
        elif feature == "Sudomy Handling":
            features_short.append("Sudomy Handle")
        elif feature == "Tool Commands":
            features_short.append("Tool Commands")
        elif feature == "Author Credit":
            features_short.append("Author Credit")
        elif feature == "Input Validation":
            features_short.append("Input Valid.")
        elif feature == "Error Handling":
            features_short.append("Error Handle")
        else:
            features_short.append(feature[:15])
    else:
        features_short.append(feature)

for orig in original_values:
    if len(orig) > 15:
        if orig == "Single Domain Only":
            original_short.append("Single Domain")
        elif orig == "Simple Text Banner":
            original_short.append("Simple Banner")
        elif orig == "Basic Single Domain":
            original_short.append("Basic Single")
        elif orig == "Generic Implementation":
            original_short.append("Generic Impl.")
        elif orig == "Basic Summary":
            original_short.append("Basic Summary")
        elif orig == "Not Included":
            original_short.append("Not Included")
        else:
            original_short.append(orig[:15])
    else:
        original_short.append(orig)

for upg in upgraded_values:
    if len(upg) > 15:
        if upg == "Single + Multi-Target":
            upgraded_short.append("Single+Multi")
        elif upg == "Professional ASCII Art":
            upgraded_short.append("Pro ASCII Art")
        elif upg == "Loop for Multi-Target":
            upgraded_short.append("Loop Multi")
        elif upg == "User-Specified Commands":
            upgraded_short.append("User Commands")
        elif upg == "Per-Target Breakdown":
            upgraded_short.append("Per-Target")
        elif upg == "Coded by: Youssef Hamdi":
            upgraded_short.append("Y. Hamdi")
        elif upg == "File/Domain Detection":
            upgraded_short.append("File/Dom Detect")
        elif upg == "Enhanced Multi-Target":
            upgraded_short.append("Enhanced Multi")
        else:
            upgraded_short.append(upg[:15])
    else:
        upgraded_short.append(upg)

# Create the table
fig = go.Figure(data=[go.Table(
    header=dict(
        values=['Feature', 'Original Scripts', 'Upgraded Scripts'],
        fill_color='#1FB8CD',
        font=dict(color='white', size=14),
        align='center',
        height=40
    ),
    cells=dict(
        values=[features_short, original_short, upgraded_short],
        fill_color=[['#f8f9fa']*len(features_short), 
                   ['#ffebee']*len(original_short), 
                   ['#e8f5e8']*len(upgraded_short)],
        font=dict(color=['black']*len(features_short)*3, size=12),
        align='left',
        height=35
    )
)])

fig.update_layout(
    title="Script Features Comparison",
    font=dict(family="Arial, sans-serif")
)

fig.write_image("script_comparison_table.png")