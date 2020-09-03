#!/usr/bin/env python

import serial, time

class UTGauge(object):
    units = ['mm', '"']

    DEFAULT_V = 6400.0 # m/s
    material = 'core ten steel'

    material_v = {
        'aluminium alloy'     : 6380,
        'aluminium 2014'      : 6320,
        'aluminium 2024 T4'   : 6370,
        'aluminium 2117 T4'   : 6500,
        'brass CuZn40'        : 4400,
        'brass naval'         : 4330,
        'brass CuZn30'        : 4700,
        'copper'              : 4850,
        'grey cast iron'      : 4600,
        'inconel'             : 5700,
        'lead'                : 2150,
        'monel'               : 5400,
        'nickel'              : 5630,
        'phosphor bronze'     : 3530,
        'mild steel'          : 5920,
        'stainless steel 302' : 5660,
        'stainless steel 347' : 5790,
        'stainless steel 314' : 5715,
        'stainless steel 316' : 5750,
        'f51 duplex steel'    : 5725, # UNS S31803
        'core ten steel'      : 5920, # EN12223 S355-J0
        'tin'                 : 3320,
        'titanium'            : 6165,
        'tungsten carbide'    : 6660,
        'epoxy resin'         : 2500,
        'acrylic'             : 2730,
        'nylon polyamide'     : 2620,
    }

    def __init__(self, material=material, port='/dev/ttyUSB0', baudrate=2400):
        ''' A UT Gauge with the specified material and comms properties. '''
        self.set_material(material)
        self.port     = port
        self.baudrate = baudrate

    def set_material(self, material):
        ''' Sets the material as specified. '''
        self._conversion = self.material_v[material] / self.DEFAULT_V

    def __enter__(self):
        ''' Entry to a context - start serial communication. '''
        self._serial = serial.Serial(self.port, self.baudrate)
        self._serial.__enter__()
        return self

    def __exit__(self, *args):
        ''' Exit a context - end serial communication and clean up. '''
        self._serial.__exit__(*args)

    def get_value(self, string_result=False):
        ''' Get the next available reading, as a float or string. '''
        self._serial.read_until(b'\x01') # get to start of a sequence
        value = self._serial.read_until(b'\x17')[:-1] # end of the reading
        status = bytearray(value[0])[0]
        invalid = status & (1 << 0)
        if invalid:
            if string_result:
                return 'no reading'
            return -1.0

        # 1<<7 == 1, gauge type always 1
        high_resolution = status & (1 << 6)
        imperial = status & (1 << 5)
        high_range = status & (1 << 4)
        echo_count = (status & 0b11 << 2) >> 2
        # 1<<1 == 1, calibration = remote
        value = value[1:]
        out = value[0]
        if imperial and not high_range:
            out += '.' + value[1:]
        else:
            out += value[1]
            if (imperial and high_range) or \
            (not imperial and high_resolution and not high_range):
                out += '.' + value[2:]
            else:
                out += value[2] + '.' + value[3]
        result = float(out) * self._conversion
        if not string_result:
            return result

        return str(result) + ' ' + self.units[imperial] \
              + ' - ' + str(echo_count) + ' echoes'


def wait_conn(autopilot):
    """ Sends a ping to develop UDP communication and waits for a response. """
    global boot_time
    msg = None
    while not msg:
        autopilot.mav.ping_send(
            int((time.time() - boot_time) * 1e6), # Unix time since boot (microseconds)
            0, # Ping number
            0, # Request ping of all systems
            0  # Request ping of all components
        )
        msg = autopilot.recv_match()
        time.sleep(0.5)


if __name__ == '__main__':
    import sys

    if len(sys.argv) == 2:
        # operating manually - print meaningful string output
        def command(ut):
            print(ut.get_value(string_result=True))
    else:
        # operating automatically - connect to autopilot and transmit readings
        from pymavlink import mavutil
        # establish connection on UDP port 9000
        autopilot = mavutil.mavlink_connection('udpout:0.0.0.0:9000')
        # set now as the 'boot time'
        boot_time = time.time()
        # wait for connection confirmation
        wait_conn(autopilot)

        def command(ut):
            autopilot.mav.named_value_float_send(
                int((time.time() - boot_time) * 1e3), # Unix time since boot (milliseconds)
                'UTGauge',
                ut.get_value()
            )

    with UTGauge() as ut:
        try:
            while True:
                command(ut)
        except KeyboardInterrupt:
            print('\b\b\nUser quit')
