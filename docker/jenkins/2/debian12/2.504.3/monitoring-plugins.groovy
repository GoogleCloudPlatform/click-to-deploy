// Copyright (c) 2021 Google Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import jenkins.model.*

import hudson.model.*
import hudson.security.*
import hudson.util.VersionNumber

import jenkins.install.InstallState

def env = System.getenv()
def plugins = []

def install_monitoring = env['INSTALL_MONITORING']
def install_prometheus = env['INSTALL_PROMETHEUS']

if (install_monitoring) {
  plugins << "monitoring"
  plugins << "cloudbees-disk-usage-simple"
  println "### Monitoring plugin should be installed."
}

if (install_prometheus) {
  plugins << "prometheus"
  println "### Prometheus plugin should be installed."
}

if (!install_monitoring && !install_prometheus) {
  println "### INSTALL_MONITORING or INSTALL_PROMETHEUS environment variables should be set."
  println "### No plugins to be installed."
  return
}

def instance = Jenkins.getInstanceOrNull()

// Jenkins installation and configuration already completed
def retries = 0
def max_retries = 13

while (!instance.installState.isSetupComplete() && retries <= max_retries) {
  println "### Jenkins is not ready."
  sleep 6000
  retries++
}

if (retries == max_retries) {
  println "### Jenkins failed to start after ${max_retries} retries."
  return
}

def uc = instance.getUpdateCenter()
def requires_restart = false

plugins.each { plugin ->
  def pl = uc.getPlugin(plugin)

  c = 20
  while (pl == null && c != 0) {
    println "### Plugin ${plugin} retry..."
    sleep(1280)
    pl = uc.getPlugin(plugin)
    c--
  }

  println "### Plugin: ${plugin}"
  println "### Version: ${pl.version}"

  def installationStatus = pl.deploy()

  // Waiting for plugin to install
  while(!installationStatus.isDone()) {
    println "### Awaiting plugin setup..."
    sleep(1280)
  }

  // Mark to restart if a plugin requires restart
  if (!requires_restart && uc.isRestartRequiredForCompletion()) {
    requires_restart = true
  }
}

// Restart instance if required
if (requires_restart) {
  println "### Restart is required. Restarting it..."
  instance.save()
  instance.safeRestart()
}

println "### Monitoring plugins installation completed"
