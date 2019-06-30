# FlightGear Support

Ensure the Arduino Leonardo drivers are installed, and copy the `cgspeck` folder to [`$FG_ROOT/Input/Joysticks`](http://wiki.flightgear.org/$FG_ROOT).

## Windows 10

On Windows you **must** install the Arduino Leonardo drivers, which are part of the [Arduino IDE](https://www.arduino.cc/en/Main/Software) package.

There is a guide [here](https://www.arduino.cc/en/Guide/DriverInstallation) about installing the correct driver.

If you have more then one USB controller plugged in then you must tell Flightgear which configuration to use for which device.

See `joysticks.xml` for an example. This file goes into the `$FG_ROOT` folder.

`$FG_ROOT` tends to be `Program Files\FlightGear 2016.1.1\data\` on Windows systems.
