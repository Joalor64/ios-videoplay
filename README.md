# ios-videoplay
![](https://img.shields.io/github/repo-size/Joalor64/ios-videoplay) ![](https://badgen.net/github/open-issues/Joalor64/ios-videoplay) ![](https://badgen.net/badge/license/MIT/green)

A simple haxelib for video playback on iOS HaxeFlixel.

## Installation
To install **ios-videoplay**, follow these steps:

1. Install the latest stable version with this command:
	```bash
	haxelib install ios-videoplay
	```

	You can also install through Git for the latest updates.
	```bash
	haxelib git ios-videoplay https://github.com/Joalor64/ios-videoplay
	```

2. Add this code to your `Project.xml`:
	```xml
	<haxelib name="ios-videoplay" if="ios" />
	```

## Usage Example
```haxe
#if ios
import iosvideo.IOSVideo;
#end
import flixel.FlxBasic;

class VideoPlayer extends FlxBasic
{
	public var finishCallback:Void->Void = null;

	public function new(name:String)
	{
		super();

		#if ios
		IOSVideo.play('assets/videos/$name.mp4'); // the video format must be .mp4
		IOSVideo.onComplete = function()
		{
			if (finishCallback != null)
			{
				finishCallback();
			}
		}
		#end
	}
}
```

## Licensing
**ios-videoplay** is made available under the MIT License. Check [LICENSE](./LICENSE) for more information.

## Credits
* <a href = "https://github.com/Joalor64">Joalor64</a> - Creator of **ios-videoplay**