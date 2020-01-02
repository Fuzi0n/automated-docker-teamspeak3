from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
import requests
import re
import validators

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

DOCUMENTATION = """
        lookup: teamspeak3
        author: Florian LEDUC <fuzion@gmail.com>
        version_added: "0.1"
        short_description: get latest version of teamspeak3 server for linux
        description:
            - This lookup plugins returns a variable that contains an URL for the latest version of TS3 server for linux.
        options:
          _terms:
            description: TS3 Downloads page URL
            required: True
        notes:
          - URL in terms will be evaluated and will raise an error if it's not a valid URL.
"""


TS_REGEX=r"(?P<ts_url>https?:\/\/.*teamspeak3-server_linux_amd64.*.bz2)"

class LookupModule(LookupBase):
        def get_latest_release(self, url, regex):
          """
          This method will return the latest url found on https://www.teamspeak.com/en/downloads/
          """
          try:
            response = requests.get(url, verify=False)
            if response.status_code == 200:
              match = re.search(regex, response.text)
              display.debug(match.group('ts_url'))
              if match.group('ts_url'):
                return [match.group('ts_url')]
              else:
                return []
          except:
            raise 

        def run(self, terms, variables, **kwargs):
          """ 
          This method is a hook for LookupModule plugins
          """
          url = terms[0]
          if validators.url(terms[0]):
            if requests.head(url, verify=False).status_code == 200:
              return self.get_latest_release(url, TS_REGEX)
            else:
              raise AnsibleError("HTTP HEAD failed on: {}".format(url))  
          else:
            raise AnsibleError("Argument provided is not a valid URL")
