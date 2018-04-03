# Example of interaction with a BLE UART finalDevice using a UART service
# implementation.
# Author: Tony DiCola
import Adafruit_BluefruitLE
from Adafruit_BluefruitLE.services import UART
import matplotlib.pyplot as plt
import time

# Get the BLE provider for the current platform.
ble = Adafruit_BluefruitLE.get_provider()


# Main function implements the program logic so it can run in a background
# thread.  Most platforms require the main thread to handle GUI events and other
# asyncronous events like BLE actions.  All of the threading logic is taken care
# of automatically though and you just need to provide a main function that uses
# the BLE provider.
def main():
    # Clear any cached data because both bluez and CoreBluetooth have issues with
    # caching data and it going stale.
    ble.clear_cached_data()

    # Get the first available BLE network adapter and make sure it's powered on.
    adapter = ble.get_default_adapter()
    adapter.power_on()
    print('Using adapter: {0}'.format(adapter.name))

    # Disconnect any currently connected UART finalDevices.  Good for cleaning up and
    # starting from a fresh state.
    print('Disconnecting any connected UART finalDevices...')
    UART.disconnect_devices()

    # Scan for UART finalDevices.
    print('Searching for UART finalDevice...')
    finalDevice = None
    gotDevice = False
    adapter.start_scan()
    while gotDevice is False:
        try:
        # Search for the first UART finalDevice found (will time out after 60 seconds
        # but you can specify an optional timeout_sec parameter to change it).
            finalDevices = set(UART.find_devices())
        finally:
            print("The list of finalDevices found is: ")
            print(finalDevices)
        for device in finalDevices:
            print('Found UART: {0} [{1}]'.format(device.name, device.id))
            if device.name == 'Chrestien':
                finalDevice = device
                gotDevice = True
                print ('found finalDevice')
        time.sleep(1.0)
    adapter.stop_scan()
    print (finalDevice.name)
    print('Connecting to finalDevice...')
    finalDevice.connect()  # Will time out after 60 seconds, specify timeout_sec parameter
                      # to change the timeout.

    print (finalDevice)
    # Once connected do everything else in a try/finally to make sure the finalDevice
    # is disconnected when done.
    try:
        # Wait for service discovery to complete for the UART service.  Will
        # time out after 60 seconds (specify timeout_sec parameter to override).
        print('Discovering services...')
        print(finalDevice)
        UART.discover(finalDevice)
        # Once service discovery is complete create an instance of the service
        # and start interacting with it.
        uart = UART(finalDevice)

        # Write a string to the TX characteristic.
        f= open('sketch_180403d/datat.txt', 'w+')
        #uart.write('Hello world!\r\n')
        #print("Sent 'Hello world!' to the finalDevice.")

        # Now wait up to one minute to receive data from the finalDevice.
        print('Waiting up to 60 seconds to receive data from the finalDevice...')
        received = uart.read(timeout_sec=60)

        while (True):
            if received is not None:
                # Received data, print it out.
                #print('Received: {0}'.format(received))
                print (received)
                f.write (received)
                try:
                    x = received.split(', ')[1]
                except IndexError:
                    continue
                received = uart.read(timeout_sec=60)
                try:
                    y = received.split(', ')[1]
                except IndexError:
                    continue
                #if x.length == 2 and y.length == 2:
                    #x = x.split(', ')[1]
                    #y = y.split(', ')[1]
                plt.plot(int(x), int(y),'ro')
                #plt.show()
            else:
                # Timeout waiting for data, None is returned.
                print('Received no data!')
                break
    finally:
        # Make sure finalDevice is disconnected on exit.
        print 'This is the' 
        print finalDevice
        finalDevice.disconnect()

# Initialize the BLE system.  MUST be called before other BLE calls!
ble.initialize()

# Start the mainloop to process BLE events, and run the provided function in
# a background thread.  When the provided main function stops running, returns
# an integer status code, or throws an error the program will exit.
ble.run_mainloop_with(main)
