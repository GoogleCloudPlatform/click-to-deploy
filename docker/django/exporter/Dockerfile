# Copyright 2024 Google LLC
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7
ENV EXPORTER_VERSION 1.3.0

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends ca-certificates curl \
    && apt-get install -y --only-upgrade libpcre2-8-0 perl perl-base zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o uwsgi.tar.gz https://github.com/timonwong/uwsgi_exporter/releases/download/v${EXPORTER_VERSION}/uwsgi_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
    && tar -xvf uwsgi.tar.gz --strip-components=1 \
    && mv uwsgi_exporter /usr/local/bin/uwsgi_exporter \
    && rm -f uwsgi.tar.gz

ENTRYPOINT ["uwsgi_exporter"]
