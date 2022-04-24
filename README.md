# Wasserflug tvOS
An unofficial Floatplane client for Apple TV/tvOS. View it on the Apple TV App Store at https://apps.apple.com/us/app/wasserflug/id1611976921.

## Screenshots

See https://imgur.com/a/vXAcEJy for screenshots of Wasserflug.

## Features

### Implemented Floatplane Features
✅ Login (with 2FA)  
✅ Aggregated home screem  
✅ Creator screens with proper branding (banner image, profile picture, "About" information)  
✅ Search a creator for videos  
✅ Floatplane tags (viewing only)  
✅ Formatted post descriptions  
✅ Attachment views  

- ✅ Videos
- ✅ Pictures
- ❌ Audio
- ❌ Gallery

✅ Creator Livestream  
❌ Livestream chat  
❌ Notifications(?)  
❌ Creator discovery  
❌ Search by tags  

- Note: You can currently manually search a tag by typing a `#` before the tag name in the creator's search screen, same as Floatplane.com.
- This is more about clicking a tag button to search it automatically.

### Extra Features
✅ Watch progress (client-side only, will not sync across other Apple TVs or with the Floatplane website)  
❌ Picture-in-Picture  

## Beta Testing

If you would like to enter the beta testing via Test Flight for Wasserflug or to receive advanced updates, please use this Test Flist invite link: https://testflight.apple.com/join/aYwKPFNF.

## Development

Cloning the git repository and opening/running it in Xcode, with some slight changes for provisioning/signing should be all that is needed at this time. There are some dependencies; please allow time for Xcode to automatically fetch those before/during initial compilation.

This uses an Xcode tvOS SwiftUI template, including a `.xcodeproj` file. Opening the `.xcodeproj` file is the main way of accessing this project. Wasserflug uses SwiftUI instead of UIKit, and targets tvOS 15.0.

For accessing the Floatplane API, this uses an accompanying project that maps out the API in the OpenAPI specification for automatic code and documentation generation. Check it out at https://jman012.github.io/FloatplaneAPIDocs/. The `floatplane-openapi-specification-trimmed.json` in this repository is copied over from that project, and the auto-generated code is generated using ``generate-floatplane-api-client.sh` and included in this repository in the `FloatplaneAPIClient` folder.

# Related

See bmlzootown's Hydravion projects and Discord server and more for other Floatplane-related software and discussion:
- https://github.com/bmlzootown/Hydravion
- https://github.com/bmlzootown/Hydravion-AndroidTV
- https://discord.gg/4xKDGz5M5B
- https://jman012.github.io/FloatplaneAPIDocs/

# Legal
Application created by James Linnell.

Wasserflug logo copyright to Yaroslav Shkuro via [Shutterstock](https://www.shutterstock.com/image-vector/small-seaplane-isolated-vector-illustration-single-1091024861).