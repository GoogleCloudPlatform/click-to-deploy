/*
Library for parsing versions.yaml file.
*/
package versions

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"time"

	yaml "gopkg.in/yaml.v2"
)

type Package struct {
  Version string
  Minor   string
  Major   string
  Gpg     string
  Sha1    string
  Sha256  string
  Sha512  string
  Md5     string
}

type Annotation struct {
  Key 						string	`yaml:"key"`
  AnnotationValue	string	`yaml:"value"`
  IsTimestamp 		bool		`yaml:"timestamp"`
}

func (l Annotation) Value() string {
  if (l.IsTimestamp) {
    return time.Now().Format(time.RFC3339)
  }
  return l.AnnotationValue
}

type Version struct {
  Dir                  string
  TemplateSubDir       string 						`yaml:"templateSubDir"`
  Repo                 string
  Tags                 []string
  From                 string
  TemplateArgs         map[string]string 	`yaml:"templateArgs"`
  Packages             map[string]Package
  ExcludeTests         []string 					`yaml:"excludeTests"`
  Builder              bool
  BuilderImage         string   					`yaml:"builderImage"`
  BuilderArgs          []string 					`yaml:"builderArgs"`
  ImageNameFromBuilder string   					`yaml:"imageNameFromBuilder"`
  Annotations         []Annotation  			`yaml:"annotations"`
  Labels              []Annotation        `yaml:"labels"`
}

type Spec struct {
  Versions []Version
}

func ReadFile(path string) []byte {
  data, err := ioutil.ReadFile(path)
  if err != nil {
    log.Fatalf("error: %v", err)
  }
  return []byte(data)
}

func LoadVersions(path string) Spec {
  spec := Spec{}
  err := yaml.Unmarshal(ReadFile(path), &spec)
  if err != nil {
    log.Fatalf("error: %v", err)
  }

  validateUniqueTags(spec)

  return spec
}

// Config represents setting for a program call. Arguments can be provided in file, as a key-value
// map, or as a command-line parameters.
type Config map[string]string

func LoadConfig(path, config string) Config {
  var whole map[string]interface{}
  err := yaml.Unmarshal(ReadFile(path), &whole)
  if err != nil {
    log.Fatalf("error: %v", err)
  }

  if c, ok := whole[config]; ok {
    configMap := map[string]string{}
    mapInterface := c.(map[interface{}]interface{})
    for key, value := range mapInterface {
      configMap[key.(string)] = fmt.Sprintf("%v", value)
    }
    return configMap
  }
  return map[string]string{}
}

func (c Config) StringOption(name, defaultVal, helper string) *string {
  if configVal, ok := c[name]; ok {
    defaultVal = configVal
  }
  return flag.String(name, defaultVal, helper)
}

func (c Config) BoolOption(name string, defaultVal bool, helper string) *bool {
  if configVal, ok := c[name]; ok {
    b, err := strconv.ParseBool(configVal)
    if err != nil {
      log.Fatalf("error: %v", err)
    }
    defaultVal = b
  }
  return flag.Bool(name, defaultVal, helper)
}

func (c Config) IntOption(name string, defaultVal int, helper string) *int {
  if configVal, ok := c[name]; ok {
    i, err := strconv.Atoi(configVal)
    if err != nil {
      log.Fatalf("error: %v", err)
    }
    defaultVal = i
  }
  return flag.Int(name, defaultVal, helper)
}

func (c Config) Parse() {
  flag.Parse()
}

func validateUniqueTags(spec Spec) {
  repoTags := make(map[string]bool)
  for _, version := range spec.Versions {
    for _, tag := range version.Tags {
      repoTag := fmt.Sprintf("%s:%s", version.Repo, tag)
      if repoTags[repoTag] {
        log.Fatalf("error: duplicate repo tag %v", repoTag)
      }
      repoTags[repoTag] = true
    }
  }
}
