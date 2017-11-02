package config

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
)

func LoadBattle(filename string, v interface{}) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Println("load config err", err)
		return
	}

	err = json.Unmarshal(data, v)
	if err != nil {
		fmt.Println("json.unmarshal err", err)
		return
	}
}
