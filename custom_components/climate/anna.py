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
    scan_interval: 10
"""
REQUIREMENTS = ['haanna==0.6.1']

import voluptuous as vol
import logging

from homeassistant.components.climate import (ClimateDevice, PLATFORM_SCHEMA, SUPPORT_TARGET_TEMPERATURE)
from homeassistant.const import (CONF_NAME, CONF_HOST, CONF_PORT, CONF_USERNAME, CONF_PASSWORD, TEMP_CELSIUS, ATTR_TEMPERATURE)
import homeassistant.helpers.config_validation as cv

SUPPORT_FLAGS = SUPPORT_TARGET_TEMPERATURE

_LOGGER = logging.getLogger(__name__)

DEFAULT_NAME = 'Anna Thermostat'
DEFAULT_USERNAME = 'smile'
DEFAULT_TIMEOUT = 10
BASE_URL = 'http://{0}:{1}{2}'

PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Optional(CONF_NAME, default=DEFAULT_NAME): cv.string,
    vol.Required(CONF_HOST): cv.string,
    vol.Optional(CONF_PORT, default=80): cv.string,
    vol.Optional(CONF_USERNAME, default=DEFAULT_USERNAME): cv.string,
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
            config.get(CONF_PORT)
        )
    ])


class ThermostatDevice(ClimateDevice):
    """Representation of an Anna thermostat"""
    def __init__(self, name, username, password, host, port):
        self._name = name
        self._username = username
        self._password = password
        self._host = host
        self._port = port
        self._temperature = None
        self._current_temperature = None
        self._outdoor_temperature = None
        self._target_min_temperature = 4
        self._target_max_temperature = 30
        self._away_mode = False
        _LOGGER.debug("Init called")
        self.update()

    @property
    def should_poll(self):
        """Polling is needed"""
        return True

    def update(self):
        """Update the data from the thermostat"""
        import haanna
        api = haanna.Haanna(self._username, self._password, self._host)
        domain_objects = api.get_domain_objects()
        self._current_temperature = api.get_temperature(domain_objects)
        self._outdoor_temperature = api.get_outdoor_temperature(domain_objects)
        self._temperature = api.get_target_temperature(domain_objects)
        _LOGGER.debug("Update called")

    @property
    def name(self):
        return self._name

    @property
    def current_temperature(self):
        return self._current_temperature

    @property
    def target_temperature(self):
        return self._temperature

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
        import haanna
        temperature = kwargs.get(ATTR_TEMPERATURE)
        if temperature is not None:
            self._temperature = temperature
            api = haanna.Haanna(self._username, self._password, self._host)
            domain_objects = api.get_domain_objects()
            api.set_temperature(domain_objects, temperature)
            self.schedule_update_ha_state()

