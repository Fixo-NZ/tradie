# OpenStreetMap Tile Usage Compliance

## Issue Fixed
Your app was blocked by OpenStreetMap's tile servers due to policy violations. The following changes have been made to comply with their [Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/):

## Changes Made

### 1. Proper User Agent
- Changed from generic `"com.example.app"` to your actual app package: `"com.fixo.tradie.tradie"`

### 2. Attribution Display
- Added visible "© OpenStreetMap contributors" attribution overlay on the map
- Required by OSM license terms

### 3. Zoom Limits
- Set appropriate `maxZoom` and `maxNativeZoom` to respect server resources

### 4. Code Comments
- Added documentation explaining compliance requirements

## For Production Use

While the current implementation should work for development and light usage, consider these alternatives for production:

### Commercial Tile Providers
- **Mapbox** - Professional maps with generous free tier
- **Google Maps** - Reliable but more expensive
- **HERE Maps** - Good for location services
- **MapTiler** - OSM-based with commercial support

### Self-Hosted Options
- Host your own tile server using OpenStreetMap data
- Use services like TileServer GL or Tegola

### Implementation Example (Mapbox)
```dart
TileLayer(
  urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token={accessToken}",
  additionalOptions: {
    'accessToken': 'your_mapbox_token_here',
  },
),
```

## OSM Usage Guidelines
- Don't make excessive requests
- Cache tiles appropriately
- Always include attribution
- Use proper user agent identification
- Consider donating to OSM if using their tiles heavily

## Current Status
✅ Your app should now work with OSM tiles without being blocked.