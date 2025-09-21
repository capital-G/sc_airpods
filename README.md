# SC AirPods

SC AirPods exposes the gyroscope and acceleration data from connected AirPods via an UGen within SuperCollider.

Currently only macOS is supported since macOS provides a native API for the data.

## Installation

> **Attention**: This requires a special build of SuperCollider since macOS demands the [`NSMotionUsageDescription`](https://developer.apple.com/documentation/bundleresources/information-property-list/nsmotionusagedescription?language=objc) attribute to be specified.
The most recent 3.15-dev version of SuperCollider adds this attribute to the SuperCollider app on macOS, which allows SuperCollider access to the AirPods tracking information.

* Download the latest version from <https://github.com/capital-g/sc_airpods/releases>
* Extract the content of the archive to your SuperCollider user extension directory - run `Platform.userExtensionDir.openOS;` within sclang to open the directory.

### De-Quarantine

Since the plugin is not notarized it needs to be de-quarantined.
Run the following command within SuperCollider, assuming you have installed SC AirPods like specified above

```supercollider
"xattr -rd com.apple.quarantine \"%/SC_AirPods\"".format(Platform.userExtensionDir).unixCmd;
```

### Building

If you want to build the project yourself use

```shell
# replace DSC_SRC_PATH w/ your local source code copy of SuperCollider
# and adjust the CMAKE_INSTALL_PREFIX if necessary
cmake -G Xcode \
    -S . -B build \
    -DSC_SRC_PATH=/Users/scheiba/github/supercollider \
    -DCMAKE_INSTALL_PREFIX=$PWD/install
cmake --build build --config Release
cmake --install build --config Release
```

## Audio configuration

Since bi-directional bluetooth connections often only offers a [rather limited bandwidth](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Hands-Free_Profile_(HFP)) it is currently advised to not use the AirPods as input and output device at the same time - use e.g.

```supercollider
(
s.options.numInputBusChannels = 0;
s.options.inDevice = "BlackHole 16ch";
s.reboot;
)

// check if this has any samplerate artifacts
().play;
```

Do not specify your airpods directly as output device (i.e. `s.options.outDevice = "Dennis’s AirPo";`) since this will invoke a different Audio API which scsynth does not support and will result in a 24 kHz limited signal.
Instead choose your AirPods as default audio device on a system level and do not specify any output device within SuperCollider (like above) - this way the server will connect to the AirPods using 48 kHz.

## License

GPL-3.0
