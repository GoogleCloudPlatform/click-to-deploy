# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ospo_download 'Licenses and Source-code' do
  repos <<-EOF
https://github.com/python-pillow/Pillow.git
https://github.com/certifi/python-certifi.git
https://github.com/chardet/chardet.git
https://github.com/jwilk-mirrors/docutils.git
https://github.com/timotheus/ebaysdk-python.git
https://github.com/savoirfairelinux/num2words.git
https://github.com/arthurdejong/python-stdnum.git
https://github.com/zopefoundation/zope.event.git
https://github.com/zopefoundation/zope.interface.git
EOF
  licenses <<-EOF
Babel_2.9.1;https://github.com/python-babel/babel/blob/master/LICENSE
Jinja2_3.1.2;https://palletsprojects.com/p/jinja/
MarkupSafe_2.1.2;https://palletsprojects.com/license/
Pillow_9.4.0;https://github.com/python-pillow/Pillow/blob/main/LICENSE
PyPDF2_2.12.1;https://github.com/py-pdf/pypdf/blob/main/LICENSE
Werkzeug_2.0.2;https://palletsprojects.com/license/
XlsxWriter_1.1.2;https://github.com/jmcnamara/XlsxWriter/blob/main/LICENSE.txt
appdirs_1.4.4;https://github.com/ActiveState/appdirs/blob/master/LICENSE.txt
attrs_23.1.0;https://www.attrs.org/en/stable/license.html
beautifulsoup4_4.12.2;https://www.crummy.com/software/BeautifulSoup/bs4/
cached-property_1.5.2;https://github.com/pydanny/cached-property/blob/master/LICENSE
certifi_2023.5.7;https://github.com/certifi/python-certifi/blob/master/LICENSE
cffi_1.15.1;https://foss.heptapod.net/pypy/cffi/-/blob/branch/default/LICENSE
chardet_4.0.0;https://github.com/chardet/chardet/blob/main/LICENSE
cryptography_3.4.8;https://github.com/pyca/cryptography/blob/main/LICENSE
decorator_4.4.2;https://github.com/micheles/decorator/blob/master/LICENSE.txt
defusedxml_0.7.1;https://github.com/tiran/defusedxml/blob/main/LICENSE
docopt_0.6.2;https://github.com/docopt/docopt/blob/master/LICENSE-MIT
docutils_0.16;https://github.com/jwilk-mirrors/docutils/blob/trunk/COPYING.txt
ebaysdk_2.1.5;https://github.com/timotheus/ebaysdk-python/blob/master/LICENSE
freezegun_0.3.15;https://github.com/spulec/freezegun/blob/master/LICENSE
gevent_22.10.2;https://github.com/gevent/gevent/blob/master/LICENSE
greenlet_2.0.2;https://github.com/python-greenlet/greenlet/blob/master/LICENSE
idna_2.10;https://github.com/kjd/idna/blob/master/LICENSE.md
isodate_0.6.1;https://github.com/gweis/isodate/blob/master/LICENSE
libsass_0.20.1;https://mit-license.org/
lxml_4.9.2;https://lxml.de/index.html#license
num2words_0.5.9;https://github.com/savoirfairelinux/num2words/blob/master/COPYING
ofxparse_0.21;https://github.com/jseutter/ofxparse/blob/master/LICENSE
passlib_1.7.4;https://github.com/glic3rinu/passlib/blob/master/LICENSE
polib_1.1.0;https://github.com/izimobil/polib/blob/master/LICENSE
psutil_5.9.4;https://github.com/giampaolo/psutil/blob/master/LICENSE
pyOpenSSL_20.0.1;https://github.com/pyca/pyopenssl/blob/main/LICENSE
pycparser_2.21;https://github.com/eliben/pycparser/blob/master/LICENSE
pydot_1.4.2;https://github.com/pydot/pydot/blob/master/LICENSE
pyparsing_3.1.0;https://github.com/pyparsing/pyparsing/blob/master/LICENSE
pyserial_3.5;https://github.com/pyserial/pyserial/blob/master/LICENSE.txt
python-dateutil_2.8.1;https://dateutil.readthedocs.io
python-stdnum_1.16;https://github.com/arthurdejong/python-stdnum/blob/maste/COPYING
pytz_2023.3;http://pythonhosted.org/pytz
pyusb_1.2.1;https://github.com/pyusb/pyusb/blob/master/LICENSE
qrcode_6.1;https://github.com/lincolnloop/python-qrcode/blob/main/LICENSE
reportlab_3.6.12;https://github.com/MrBitBucket/reportlab-mirror/blob/master/LICENSE
requests_2.25.1;https://github.com/psf/requests/blob/main/LICENSE
requests-file_1.5.1;https://github.com/dashea/requests-file/blob/master/LICENSE
requests-toolbelt_1.0.0;https://github.com/requests/toolbelt/blob/master/LICENSE
six_1.16.0;https://github.com/benjaminp/six/blob/master/LICENSE
soupsieve_2.4.1;https://github.com/facelessuser/soupsieve/blob/main/LICENSE.md
urllib3_1.26.5;https://urllib3.readthedocs.io/
vobject_0.9.6.1;http://eventable.github.io/vobject/
xlrd_1.2.0;https://xlrd.readthedocs.io/en/latest/licenses.html
xlwt_1.3.0;https://xlwt.readthedocs.io/en/latest/licenses.html
zeep_4.0.0;https://github.com/mvantellingen/python-zeep/blob/main/LICENSE
zope.event_5.0;https://github.com/zopefoundation/zope.event/blob/master/LICENSE.txt
zope.interface_6.0;https://github.com/zopefoundation/zope.interface/blob/master/LICENSE.txt
EOF
end
