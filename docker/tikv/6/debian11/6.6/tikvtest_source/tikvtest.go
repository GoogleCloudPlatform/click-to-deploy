package main

import (
  "fmt"
  "os"
  "github.com/pingcap/tidb/config"
  "github.com/pingcap/tidb/store/tikv"
)

func main() {
  pd_addr := os.Getenv("PD_ENDPOINT")
  cli, err := tikv.NewRawKVClient([]string{pd_addr}, config.Security{})
  if err != nil {
    panic(err)
  }
  defer cli.Close()

  fmt.Printf("cluster ID: %d\n", cli.ClusterID())

  key := []byte("TestKey")
  val := []byte("TestValue")

  // put key into tikv
  err = cli.Put(key, val)
  if err != nil {
    panic(err)
  }
  fmt.Printf("Successfully put %s:%s to tikv\n", key, val)

  // get key from tikv
  val, err = cli.Get(key)
  if err != nil {
    panic(err)
  }
  fmt.Printf("found val: %s for key: %s\n", val, key)

  // delete key from tikv
  err = cli.Delete(key)
  if err != nil {
    panic(err)
  }
  fmt.Printf("key: %s deleted\n", key)

  // get key again from tikv
  val, err = cli.Get(key)
  if err != nil {
    panic(err)
  }
  fmt.Printf("found val: %s for key: %s\n", val, key)
}

