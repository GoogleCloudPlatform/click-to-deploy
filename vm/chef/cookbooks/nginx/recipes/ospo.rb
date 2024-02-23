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
https://github.com/golangci/golangci-lint.git
https://github.com/OpenPeeDeeP/depguard.git
https://github.com/denis-tingaikin/go-header.git
https://github.com/firefart/nonamedreturns.git
EOF
  licenses <<-EOF
Nginx;http://nginx.org/LICENSE
PHP;https://github.com/php/php-src/blob/master/LICENSE
Zend_Engine;https://github.com/php/php-src/blob/master/Zend/LICENSE
MySQL8;https://github.com/mysql/mysql-server/blob/8.0/LICENSE
cenkalti__backoff;https://github.com/cenkalti/backoff/blob/v4/LICENSE
fsnotify__fsnotify_v1.6.0;https://github.com/fsnotify/fsnotify/blob/main/LICENSE
gogo__protobuf_v1.3.2;https://github.com/gogo/protobuf/blob/master/LICENSE
golang__mock_v1.6.0;https://github.com/golang/mock/blob/main/LICENSE
golang__protobuf_v1.5.3;https://github.com/golang/protobuf/blob/master/LICENSE
google__go-cmp_v0.5.9;https://github.com/google/go-cmp/blob/master/LICENSE
google__uuid_v1.3.0;https://github.com/google/uuid/blob/master/LICENSE
klauspost__cpuid;https://github.com/klauspost/cpuid/blob/master/LICENSE
maxbrunsfeld__counterfeiter;https://github.com/maxbrunsfeld/counterfeiter/blob/master/LICENSE
mitchellh__mapstructure_v1.5.0;https://github.com/mitchellh/mapstructure/blob/main/LICENSE
mwitkow__go-proto-validators_v0.3.4;https://github.com/mwitkow/go-proto-validators/blob/master/LICENSE.txt
nginxinc__nginx-plus-go-client_v0.10.0;https://github.com/nginxinc/nginx-plus-go-client/blob/main/LICENSE
nginxinc__nginx-prometheus-exporter_v0.11.0;https://github.com/nginxinc/nginx-prometheus-exporter/blob/main/LICENSE
nxadm__tail_v1.4.8;https://github.com/nxadm/tail/blob/master/LICENSE
orcaman__concurrent-map_v1.0.0;https://github.com/orcaman/concurrent-map/blob/master/LICENSE
shirou__gopsutil_v3.23.6+incompatible;https://github.com/shirou/gopsutil/blob/master/LICENSE
shirou__gopsutil;https://github.com/shirou/gopsutil/blob/master/LICENSE
sirupsen__logrus_v1.9.0;https://github.com/sirupsen/logrus/blob/master/LICENSE
spf13__cobra_v1.7.0;https://github.com/spf13/cobra/blob/main/LICENSE.txt
spf13__pflag_v1.0.5;https://github.com/spf13/pflag/blob/master/LICENSE
spf13__viper_v1.16.0;https://github.com/spf13/viper/blob/master/LICENSE
stretchr__testify_v1.8.4;https://github.com/stretchr/testify/blob/master/LICENSE
trivago__grok_v1.0.0;https://github.com/trivago/grok/blob/master/LICENSE
vardius__message-bus_v1.1.5;https://github.com/vardius/message-bus/blob/master/LICENSE.md
go.uber.org__atomic_v1.11.0;https://pkg.go.dev/go.uber.org/atomic?tab=licenses
x__sync_v0.3.0;https://pkg.go.dev/golang.org/x/sync?tab=licenses
google.golang.org__grpc_v1.56.1;https://pkg.go.dev/google.golang.org/grpc?tab=licenses
grpc__cmd;https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc?tab=licenses
protobuf_v1.31.0____indirect;https://pkg.go.dev/google.golang.org/protobuf?tab=licenses
mcuadros__go-syslog.v2_v2.3.0;https://github.com/mcuadros/go-syslog/blob/v2.3.0/LICENSE
gopkg.in__yaml.v3_v3.0.1;https://github.com/go-yaml/yaml/blob/v3.0.1/LICENSE
bufbuild__buf_v1.18.0;https://github.com/bufbuild/buf/blob/main/LICENSE
evilmartians__lefthook_v1.4.3;https://github.com/evilmartians/lefthook/blob/master/LICENSE
go-resty__resty;https://github.com/go-resty/resty/blob/master/LICENSE
go-swagger__go-swagger_v0.30.5;https://github.com/go-swagger/go-swagger/blob/master/LICENSE
golangci__golangci-lint_v1.53.3;https://github.com/golangci/golangci-lint/blob/master/LICENSE
goreleaser__nfpm;https://github.com/goreleaser/nfpm/blob/main/LICENSE.md
nginx__agent;https://github.com/nginx/agent/blob/main/LICENSE
prometheus__client_golang_v1.16.0;https://github.com/prometheus/client_golang/blob/main/LICENSE
pseudomuto__protoc-gen-doc_v1.5.1;https://github.com/pseudomuto/protoc-gen-doc/blob/master/LICENSE.md
rs__cors_v1.9.0;https://github.com/rs/cors/blob/master/LICENSE
x__sys_v0.10.0;https://pkg.go.dev/golang.org/x/sys?tab=licenses
x__text_v0.11.0;https://pkg.go.dev/golang.org/x/text?tab=licenses
gopkg.in__yaml_v3.0.1;https://github.com/go-yaml/yaml/blob/v2.4.0/LICENSE
gocheckcompilerdirectives_v1.2.1____indirect;https://github.com/leighmcculloch/gocheckcompilerdirectives/blob/main/LICENSE
gochecknoglobals_v0.2.1____indirect;https://github.com/leighmcculloch/gochecknoglobals/blob/master/LICENSE
Abirdcfly__dupword_v0.0.11_;https://github.com/Abirdcfly/dupword/blob/main/LICENSE
AlekSi__pointer_v1.2.0_;https://github.com/AlekSi/pointer/blob/main/LICENSE
Antonboom__errname_v0.1.9_;https://github.com/Antonboom/errname/blob/master/LICENSE
Antonboom__nilnil_v0.1.3_;https://github.com/Antonboom/nilnil/blob/master/LICENSE
Azure__go-ansiterm_v0.0.0-20230124172434-306776ec8161_;https://github.com/Azure/go-ansiterm/blob/master/LICENSE
BurntSushi__toml_v1.3.2;https://github.com/BurntSushi/toml/blob/master/COPYING
Djarvur__go-err113_v0.0.0-20210108212216-aea10b59be24_;https://github.com/Djarvur/go-err113/blob/master/LICENSE
GaijinEntertainment__go-exhaustruct;https://github.com/GaijinEntertainment/go-exhaustruct/blob/master/LICENSE
MakeNowJust__heredoc_v2.0.1_;https://github.com/makenowjust/heredoc/blob/main/LICENSE
Masterminds__goutils_v1.1.1_;https://github.com/Masterminds/goutils/blob/master/LICENSE.txt
Masterminds__semver_v3.2.1;https://github.com/Masterminds/semver/blob/master/LICENSE.txt
Masterminds__semver;https://github.com/Masterminds/semver/blob/master/LICENSE.txt
Masterminds__sprig_v2.22.0+incompatible_;https://github.com/Masterminds/sprig/blob/master/LICENSE.txt
Masterminds__sprig;https://github.com/Masterminds/sprig/blob/master/LICENSE.txt
Microsoft__go-winio_v0.6.1_;https://github.com/microsoft/go-winio/blob/main/LICENSE
OpenPeeDeeP__depguard_v1.1.1_;https://github.com/OpenPeeDeeP/depguard/blob/v2/LICENSE
ProtonMail__go-crypto_v0.0.0-20210512092938-c05353c2d58c_;https://github.com/ProtonMail/go-crypto/blob/main/LICENSE
alexkohler__prealloc_v1.0.0_;https://github.com/alexkohler/prealloc/blob/master/LICENSE
alingse__asasalint_v0.0.11_;https://github.com/alingse/asasalint/blob/main/LICENSE
asaskevich__govalidator_v0.0.0-20210307081110-f21760c49a8d_;https://github.com/asaskevich/govalidator/blob/master/LICENSE
ashanbrown__forbidigo_v1.5.1_;https://github.com/ashanbrown/forbidigo/blob/master/LICENSE
ashanbrown__makezero_v1.1.1_;https://github.com/ashanbrown/makezero/blob/master/LICENSE
aymanbagabas__go-osc52;https://github.com/aymanbagabas/go-osc52/blob/master/LICENSE
beorn7__perks_v1.0.1_;https://github.com/beorn7/perks/blob/master/LICENSE
bkielbasa__cyclop_v1.2.0_;https://github.com/bkielbasa/cyclop/blob/master/LICENSE
blakesmith__ar_v0.0.0-20190502131153-809d4375e1fb_;https://github.com/blakesmith/ar/blob/master/COPYING
blizzy78__varnamelen_v0.8.0_;https://github.com/blizzy78/varnamelen/blob/master/LICENSE
bombsimon__wsl;https://github.com/bombsimon/wsl/blob/master/LICENSE
breml__bidichk_v0.2.4_;https://github.com/breml/bidichk/blob/master/LICENSE
breml__errchkjson_v0.3.1_;https://github.com/breml/errchkjson/blob/master/LICENSE
briandowns__spinner_v1.23.0_;https://github.com/briandowns/spinner/blob/master/LICENSE
bufbuild__connect-go_v1.7.0_;https://github.com/bufbuild/connect-go/blob/main/LICENSE
bufbuild__protocompile_v0.5.1_;https://github.com/bufbuild/protocompile/blob/main/LICENSE
butuzov__ireturn_v0.1.1_;https://github.com/butuzov/ireturn/blob/main/LICENSE
cavaliergopher__cpio_v1.0.1_;https://github.com/cavaliergopher/cpio/blob/main/LICENSE
cespare__xxhash;https://github.com/cespare/xxhash/blob/main/LICENSE.txt
charithe__durationcheck_v0.0.10_;https://github.com/charithe/durationcheck/blob/master/LICENSE
charmbracelet__lipgloss_v0.7.1_;https://github.com/charmbracelet/lipgloss/blob/master/LICENSE
chavacava__garif_v0.0.0-20230227094218-b8c73b2037b8_;https://github.com/chavacava/garif/blob/master/LICENSE
cpuguy83__go-md2man;https://github.com/cpuguy83/go-md2man/blob/master/LICENSE.md
creack__pty_v1.1.18_;https://github.com/creack/pty/blob/master/LICENSE
curioswitch__go-reassign_v0.2.0_;https://github.com/curioswitch/go-reassign/blob/main/LICENSE
daixiang0__gci_v0.10.1_;https://github.com/daixiang0/gci/blob/master/LICENSE
davecgh__go-spew_v1.1.1_;https://github.com/davecgh/go-spew/blob/master/LICENSE
denis-tingaikin__go-header_v0.4.3_;https://github.com/denis-tingaikin/go-header/blob/main/LICENSE
docker__cli_v24.0.2+incompatible_;https://github.com/docker/cli/blob/master/LICENSE
docker__distribution_v2.8.2+incompatible_;https://github.com/distribution/distribution/blob/main/LICENSE
docker__docker_v24.0.2+incompatible_;https://github.com/moby/moby/blob/master/LICENSE
docker__docker-credential-helpers_v0.7.0_;https://github.com/docker/docker-credential-helpers/blob/master/LICENSE
docker__go-connections_v0.4.0_;https://github.com/docker/go-connections/blob/master/LICENSE
docker__go-units_v0.5.0_;https://github.com/docker/go-units/blob/master/LICENSE
emirpasic__gods_v1.12.0_;https://github.com/emirpasic/gods/blob/master/LICENSE
envoyproxy__protoc-gen-validate_v1.0.2;https://github.com/bufbuild/protoc-gen-validate/blob/main/LICENSE
esimonov__ifshort_v1.0.4_;https://github.com/esimonov/ifshort/blob/main/LICENSE
ettle__strcase_v0.1.1_;https://github.com/ettle/strcase/blob/main/LICENSE
fatih__color_v1.15.0_;https://github.com/fatih/color/blob/main/LICENSE.md
fatih__structtag_v1.2.0_;https://github.com/fatih/structtag/blob/master/LICENSE
felixge__fgprof_v0.9.3_;https://github.com/felixge/fgprof/blob/master/LICENSE.txt
felixge__httpsnoop_v1.0.3_;https://github.com/felixge/httpsnoop/blob/master/LICENSE.txt
firefart__nonamedreturns_v1.0.4_;https://github.com/firefart/nonamedreturns/blob/main/LICENSE
fzipp__gocyclo_v0.6.0_;https://github.com/fzipp/gocyclo/blob/main/LICENSE
go-chi__chi;https://github.com/go-chi/chi/blob/master/LICENSE
go-critic__go-critic_v0.8.1_;https://github.com/go-critic/go-critic/blob/master/LICENSE
go-git__gcfg_v1.5.0_;https://github.com/go-git/gcfg/blob/v1/LICENSE
go-git__go-billy;https://github.com/go-git/go-billy/blob/master/LICENSE
go-git__go-git;https://github.com/go-git/go-git/blob/master/LICENSE
go-logr__logr_v1.2.4_;https://github.com/go-logr/logr/blob/master/LICENSE
go-logr__stdr_v1.2.2_;https://github.com/go-logr/stdr/blob/master/LICENSE
go-ole__go-ole_v1.2.6_;https://github.com/go-ole/go-ole/blob/master/LICENSE
EOF
end
