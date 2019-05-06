"""
Plugwise Anna component for HomeAssistant

configurations.yaml

climate:
  - platform: anna
    name: Anna Thermostat
    username: smile
    password: short_id
    host: 192.168.1.60
    port: 80
    min_temp: 4
    max_temp: 30
    scan_interval: 10   # optional
"""

import voluptuous as vol
import logging

import xml.etree.cElementTree as Etree

import haanna

from homeassistant.components.climate import (
    ClimateDevice,
    PLATFORM_SCHEMA)

from homeassistant.components.climate.const import (
    DOMAIN,
    SUPPORT_HOLD_MODE,
    SUPPORT_AWAY_MODE,
    SUPPORT_OPERATION_MODE,
    SUPPORT_TARGET_TEMPERATURE,
    STATE_AUTO,
    STATE_IDLE,
    SERVICE_SET_HOLD_MODE)

from homeassistant.const import (
    CONF_NAME,
    CONF_HOST,
    CONF_PORT,
    CONF_USERNAME,
    CONF_PASSWORD,
    TEMP_CELSIUS,
    ATTR_TEMPERATURE,
    STATE_ON,
    STATE_OFF)

import homeassistant.helpers.config_validation as cv

from homeassistant.exceptions import PlatformNotReady

SUPPORT_FLAGS = ( SUPPORT_TARGET_TEMPERATURE | SUPPORT_HOLD_MODE )
#SUPPORT_FLAGS = ( SUPPORT_TARGET_TEMPERATURE | SUPPORT_OPERATION_MODE | SUPPORT_HOLD_MODE | SUPPORT_AWAY_MODE )

_LOGGER = logging.getLogger(__name__)

# Configuration directives
CONF_MIN_TEMP = 'min_temp'
CONF_MAX_TEMP = 'max_temp'

DEFAULT_NAME = 'Anna Thermostat'
DEFAULT_USERNAME = 'smile'
DEFAULT_TIMEOUT = 10
BASE_URL = 'http://{0}:{1}{2}'
DEFAULT_ICON = "mdi:thermometer"

# Hold modes
HOLD_MODE_HOME = "home"
HOLD_MODE_VACATION = "vacation"
HOLD_MODE_NO_FROST = "no_frost"
HOLD_MODE_SLEEP = "asleep"
HOLD_MODE_AWAY = "away"

HOLD_MODES = [ HOLD_MODE_HOME, HOLD_MODE_VACATION, HOLD_MODE_NO_FROST, HOLD_MODE_SLEEP, HOLD_MODE_AWAY ]
# Operation list
# todo; read these (schedules) from API
DEFAULT_OPERATION_LIST = [ STATE_AUTO, STATE_IDLE ]

# Change defaults to match Anna
DEFAULT_MIN_TEMP = 4
DEFAULT_MAX_TEMP = 30

# Read platform configuration
PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Optional(CONF_NAME, default=DEFAULT_NAME): cv.string,
    vol.Required(CONF_HOST): cv.string,
    vol.Optional(CONF_PORT, default=80): cv.port,
    vol.Optional(CONF_USERNAME, default=DEFAULT_USERNAME): cv.string,
    vol.Optional(CONF_MIN_TEMP, default=DEFAULT_MIN_TEMP): cv.positive_int,
    vol.Optional(CONF_MAX_TEMP, default=DEFAULT_MAX_TEMP): cv.positive_int,
    vol.Required(CONF_PASSWORD): cv.string
})

def setup_platform(hass, config, add_devices, discovery_info=None):
    """Setup the Anna thermostat"""
    add_devices([
        ThermostatDevice(
            config.get(CONF_NAME),
            config.get(CONF_USERNAME),
            config.get(CONF_PASSWORD),
            config.get(CONF_HOST),
            config.get(CONF_PORT),
            config.get(CONF_MIN_TEMP),
            config.get(CONF_MAX_TEMP)
        )
    ])

_LOGGER.debug("Anna: custom component loading (Anna PlugWise climate)")

class ThermostatDevice(ClimateDevice):
    """Representation of an Anna thermostat"""
    def __init__(self, name, username, password, host, port, min_temp, max_temp):
        _LOGGER.debug("Anna: Init called")
        self._name = name
        self._username = username
        self._password = password
        self._host = host
        self._port = port
        self._temperature = None
        self._current_temperature = None
        self._outdoor_temperature = None
        self._state = None
        self._hold_mode = None
        self._away_mode = False
        self._min_temp = min_temp
        self._max_temp = max_temp
        self._operation_list = DEFAULT_OPERATION_LIST

        _LOGGER.debug("Anna: Initializing API")
        self._api = haanna.Haanna(self._username, self._password, self._host, self._port)
        try:
             self._api.ping_anna_thermostat()
        except:
            _LOGGER.error("Anna: Unable to ping, platform not ready")
            raise PlatformNotReady
        _LOGGER.debug("Anna: platform ready")
        self.update()

    @property
    def should_poll(self):
        """Polling is needed"""
        return True

    @property
    def state(self):
        """Return the current state"""
        return self._state

    def update(self):
        """Update the data from the thermostat"""
        _LOGGER.debug("Anna: Update called")
        domain_objects = self._api.get_domain_objects()
        self._current_temperature = self._api.get_temperature(domain_objects)
        self._outdoor_temperature = self._api.get_outdoor_temperature(domain_objects)
        self._temperature = self._api.get_target_temperature(domain_objects)
        self._hold_mode = self._api.get_current_preset(domain_objects)
        if self._api.get_mode(domain_objects) == True:
          self._operation_mode=STATE_AUTO
        else:
          self._operation_mode=STATE_IDLE
        if self._api.get_heating_status(domain_objects) == True:
          self._state=STATE_ON
        else:
          self._state=STATE_OFF

    @property
    def name(self):
        return self._name

    @property
    def current_hold_mode(self):
        """Return the current hold mode, e.g., home, away, temp."""
        return self._hold_mode

    @property
    def operation_list(self):
        """Return the operation modes list."""
        return self._operation_list

    @property
    def current_operation(self):
        """Return current operation ie. auto, idle."""
        return self._operation_mode

    @property
    def icon(self):
        """Return the icon to use in the frontend."""
        return DEFAULT_ICON

    @property
    def current_temperature(self):
        return self._current_temperature

    @property
    def min_temp(self):
        return self._min_temp

    @property
    def max_temp(self):
        return self._max_temp

    @property
    def target_temperature(self):
        return self._temperature

    @property
    def outdoor_temperature(self):
        return self._outdoor_temperature

    @property
    def supported_features(self):
        """Return the list of supported features."""
        return SUPPORT_FLAGS

    @property
    def temperature_unit(self):
        return TEMP_CELSIUS

    def set_temperature(self, **kwargs):
        """Set new target temperature"""
        _LOGGER.debug("Anna: Adjusting temperature")
        import haanna
        temperature = kwargs.get(ATTR_TEMPERATURE)
        if temperature is not None and temperature >= self.min_temp() and temperature <= self.max_temp():
            self._temperature = temperature
            domain_objects = self._api.get_domain_objects()
            self._api.set_temperature(domain_objects, temperature)
            self.schedule_update_ha_state()
            _LOGGER.debug('Anna: Changing temporary temperature')
        else:
            _LOGGER.error('Anna: Failed to change temperature (invalid temperature given)')

    def set_hold_mode(self, hold_mode):
        """Set the hold mode."""
        _LOGGER.debug("Anna: Adjusting hold_mode (i.e. preset)")
        if hold_mode is not None and hold_mode in HOLD_MODES:
            domain_objects = self._api.get_domain_objects()
            self._hold_mode = hold_mode
            self._api.set_preset(domain_objects, hold_mode)
            _LOGGER.debug('Anna: Changing hold mode/preset')
        else:
            _LOGGER.error('Anna: Failed to change hold mode (invalid or no preset given)')

