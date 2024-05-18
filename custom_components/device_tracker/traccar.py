"""
Support for the TRACCAR platform.
"""
import logging
import requests, json
import voluptuous as vol

CONF_HOST = "host"

from homeassistant.components.device_tracker import (
    PLATFORM_SCHEMA, ATTR_ATTRIBUTES)
from homeassistant.const import CONF_NAME, CONF_USERNAME, CONF_PASSWORD
import homeassistant.helpers.config_validation as cv
from homeassistant.helpers.event import track_utc_time_change
from homeassistant.util import slugify

_LOGGER = logging.getLogger(__name__)

PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Required(CONF_USERNAME): cv.string,
    vol.Required(CONF_PASSWORD): cv.string,
    vol.Required(CONF_HOST): cv.string
})

def setup_scanner(hass, config: dict, see, discovery_info=None):
    """Validate the configuration and return a Traccar scanner."""
    TraccarDeviceScanner(hass, config, see)
    return True

class TraccarDeviceScanner(object):
    """A class representing a Traccar device."""

    def __init__(self, hass, config: dict, see) -> None:
        """Initialize the Traccar device scanner."""
        self.hass = hass
        self._host = config.get(CONF_HOST)
        self._username = config.get(CONF_USERNAME)
        self._password = config.get(CONF_PASSWORD)
        self.see = see
        self._update_info()
        track_utc_time_change(self.hass, self._update_info,
                              second=range(0, 60, 30))

    def _update_info(self, now=None) -> None:
        """Update the device info."""
        _LOGGER.debug('Updating devices %s', now)
        self._devices = requests.get(self._host + '/api/devices', auth=(self._username, self._password))
        self._device_data = json.loads(self._devices.text)
        self._positions = requests.get(self._host + '/api/positions', auth=(self._username, self._password))
        self._positions_data = json.loads(self._positions.text)
        for dev_id in self._device_data:
            _id=dev_id['id']
            _name = dev_id['name']
            for position_id in self._positions_data:
                if position_id['id'] == dev_id['positionId']:
                    _gps=(position_id['latitude'], position_id['longitude'])
                    _gps_accuracy=position_id['accuracy']
                    _attrs = {
                        'totalDistance': position_id['attributes']['totalDistance'],
                        'ip': position_id['attributes'].get('ip','127.0.0.1'),
                        'protocol': position_id['protocol'],
                        'speed': position_id['speed'],
                        'address': position_id['address'],
                        'status':  dev_id['status'],
                        'lastUpdate': dev_id['lastUpdate']
                        }
                    self.see(
                        dev_id=_id,
                        host_name=slugify(_name),
                        gps=_gps,
                        gps_accuracy=_gps_accuracy,
                        attributes=_attrs
                    )
